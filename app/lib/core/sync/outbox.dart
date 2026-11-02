import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import 'op.dart';

const _uuid = Uuid();

/// Client-generated, time-ordered id (UUIDv7) for ops and records.
String newId() => _uuid.v7();

/// Queues an op. MUST be called inside the same `db.transaction` that writes the op's local rows,
/// so a local change and its op are saved together or not at all (docs/05 rule 2).
class Outbox {
  Outbox(this.db, this.session, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final SessionInfo session;
  final DateTime Function() _clock;

  Future<String> enqueue(String type, Map<String, dynamic> payload, {String? opId}) async {
    final id = opId ?? newId();
    final seq = await db.kvNext('deviceSeq');
    await db.into(db.outboxOps).insert(OutboxOpsCompanion.insert(
          opId: id,
          type: type,
          payloadJson: jsonEncode(payload),
          deviceSeq: seq,
          deviceTime: _clock().toIso8601String(),
          userId: session.userId,
        ));
    return id;
  }

  /// Number shown in the "N pending" badge.
  Stream<int> watchPendingCount() {
    final count = db.outboxOps.opId.count();
    return (db.selectOnly(db.outboxOps)..addColumns([count])).map((r) => r.read(count) ?? 0).watchSingle();
  }

  /// Wire format expected by applyOps.
  Map<String, dynamic> toWire(OutboxOpRow row) => {
        'opId': row.opId,
        'schoolId': session.schoolId,
        'type': row.type,
        'payload': jsonDecode(row.payloadJson),
        'deviceId': session.deviceId,
        'deviceSeq': row.deviceSeq,
        'deviceTime': row.deviceTime,
        'userId': row.userId,
      };
}
