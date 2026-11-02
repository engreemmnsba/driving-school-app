import 'package:drift/drift.dart';

import '../db/database.dart';
import 'op.dart';
import 'outbox.dart';

class PushReport {
  const PushReport({this.accepted = 0, this.rejected = 0, this.failed = false, this.busy = false});
  final int accepted;
  final int rejected;

  /// Transport failed; remaining ops stay queued.
  final bool failed;

  /// Another push was already running.
  final bool busy;
}

/// Sends queued ops in deviceSeq order, in batches, and applies each result locally.
class Pusher {
  Pusher(this.db, this.outbox, this.transport, {this.batchSize = 50, DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final Outbox outbox;
  final OpsTransport transport;
  final int batchSize;
  final DateTime Function() _clock;
  bool _running = false;

  Future<PushReport> pushAll() async {
    if (_running) return const PushReport(busy: true);
    _running = true;
    var accepted = 0;
    var rejected = 0;
    try {
      while (true) {
        final batch = await (db.select(db.outboxOps)
              ..orderBy([(t) => OrderingTerm.asc(t.deviceSeq)])
              ..limit(batchSize))
            .get();
        if (batch.isEmpty) break;

        List<OpResult> results;
        try {
          results = await transport.send(batch.map(outbox.toWire).toList());
        } on TransportException catch (e) {
          await _markAttempt(batch, e.message);
          return PushReport(accepted: accepted, rejected: rejected, failed: true);
        }

        final byId = {for (final r in results) r.opId: r};
        for (final op in batch) {
          final r = byId[op.opId];
          if (r == null) {
            // Server did not answer this op: keep it (and everything after it) for the next push.
            await _markAttempt([op], 'no result');
            return PushReport(accepted: accepted, rejected: rejected, failed: true);
          }
          if (r.accepted) {
            await _applyAccepted(op, r);
            accepted++;
          } else {
            await _applyRejected(op, r);
            rejected++;
          }
        }
      }
      return PushReport(accepted: accepted, rejected: rejected);
    } finally {
      _running = false;
    }
  }

  Future<void> _markAttempt(List<OutboxOpRow> ops, String error) async {
    await db.batch((b) {
      for (final op in ops) {
        b.update(db.outboxOps, OutboxOpsCompanion(attempts: Value(op.attempts + 1), lastError: Value(error)),
            where: (t) => t.opId.equals(op.opId));
      }
    });
  }

  Future<void> _applyAccepted(OutboxOpRow op, OpResult r) => db.transaction(() async {
        for (final table in db.syncedTables) {
          await db.customUpdate(
            'UPDATE ${table.actualTableName} SET sync_state = ?, server_seq = ? WHERE op_id = ?',
            variables: [Variable.withString('synced'), Variable.withInt(r.serverSeq!), Variable.withString(op.opId)],
            updates: {table},
          );
        }
        // Fields the server decides (e.g. the final lesson number).
        final number = r.assigned['number'];
        if (number is num) {
          await (db.update(db.lessons)..where((t) => t.opId.equals(op.opId)))
              .write(LessonsCompanion(number: Value(number.toInt())));
        }
        await (db.delete(db.outboxOps)..where((t) => t.opId.equals(op.opId))).go();
      });

  Future<void> _applyRejected(OutboxOpRow op, OpResult r) => db.transaction(() async {
        for (final table in db.syncedTables) {
          await db.customUpdate(
            'UPDATE ${table.actualTableName} SET sync_state = ? WHERE op_id = ?',
            variables: [Variable.withString('rejected'), Variable.withString(op.opId)],
            updates: {table},
          );
        }
        await db.into(db.rejectedOps).insertOnConflictUpdate(RejectedOpsCompanion.insert(
              opId: op.opId,
              type: op.type,
              payloadJson: op.payloadJson,
              reason: r.reason ?? 'unknown',
              message: r.message ?? '',
              rejectedAt: _clock().toIso8601String(),
            ));
        await (db.delete(db.outboxOps)..where((t) => t.opId.equals(op.opId))).go();
      });
}
