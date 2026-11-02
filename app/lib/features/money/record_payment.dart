import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/domain/ledger.dart';
import '../../core/domain/money.dart';
import '../../core/sync/op.dart';
import '../../core/sync/outbox.dart';

/// Student pays into a treasury account. One local transaction: ledger row + movement + outbox op.
/// Payload matches functions/src/handlers/money.ts paymentRecord.
class RecordPayment {
  RecordPayment(this.db, this.outbox, this.session);

  final AppDatabase db;
  final Outbox outbox;
  final SessionInfo session;

  Future<String> call({
    required String enrollmentId,
    required String studentId,
    required Money amount,
    required String accountId,
    required String purpose,
    required String businessDate,
  }) async {
    if (!amount.isPositive) throw ArgumentError('المبلغ لازم يكون أكبر من صفر');
    final paymentId = newId();
    final movementId = newId();
    final opId = newId();
    final at = DateTime.now().toUtc().toIso8601String();
    await db.transaction(() async {
      final counter = await db.kvNext('receiptCounter');
      final receiptNo = '${session.deviceCode}-${counter.toString().padLeft(4, '0')}';
      await db.into(db.ledgerEntries).insert(LedgerEntriesCompanion.insert(
            id: paymentId,
            enrollmentId: enrollmentId,
            studentId: studentId,
            kind: 'payment',
            amount: amount.agorot,
            accountId: Value(accountId),
            purpose: Value(purpose),
            receiptNo: Value(receiptNo),
            businessDate: businessDate,
            opId: Value(opId),
            at: Value(at),
          ));
      await db.into(db.treasuryMovements).insert(TreasuryMovementsCompanion.insert(
            id: movementId,
            accountId: accountId,
            direction: 'in',
            amount: amount.agorot,
            kind: 'student_payment',
            refId: paymentId,
            businessDate: businessDate,
            opId: Value(opId),
            at: Value(at),
          ));
      await outbox.enqueue('payment.record', {
        'paymentId': paymentId,
        'movementId': movementId,
        'enrollmentId': enrollmentId,
        'accountId': accountId,
        'amount': amount.agorot,
        'purpose': purpose,
        'receiptNo': receiptNo,
        'businessDate': businessDate,
      }, opId: opId);
    });
    return paymentId;
  }
}

/// Balance shown on screen = server summary + synced rows newer than the summary + pending rows.
/// Rejected rows never count (docs/05 §8).
Future<StudentBalance> localBalance(AppDatabase db, String enrollmentId) async {
  final summary = await (db.select(db.studentSummaries)..where((t) => t.enrollmentId.equals(enrollmentId))).getSingleOrNull();
  final base = StudentBalance(
    charged: Money(summary?.charged ?? 0),
    paid: Money(summary?.paid ?? 0),
    discounts: Money(summary?.discounts ?? 0),
  );
  final summarySeq = summary?.serverSeq ?? 0;
  final rows = await (db.select(db.ledgerEntries)
        ..where((t) =>
            t.enrollmentId.equals(enrollmentId) &
            (t.syncState.equals('pending') | (t.syncState.equals('synced') & t.serverSeq.isBiggerThanValue(summarySeq)))))
      .get();
  return base.plus(rows.map(_toDomain));
}

LedgerRow _toDomain(LedgerRowData r) => LedgerRow(
      id: r.id,
      kind: ledgerKindOf(r.kind),
      amount: Money(r.amount),
      reversesId: r.reversesId,
      reversed: r.reversed,
    );

/// Undo / correction of a payment: a reversal row + money out of the same account. Never deletes.
/// Payload matches functions/src/handlers/money.ts paymentReverse.
class ReversePayment {
  ReversePayment(this.db, this.outbox);

  final AppDatabase db;
  final Outbox outbox;

  Future<void> call(String paymentId, {String? reason, required String businessDate}) async {
    final pay = await (db.select(db.ledgerEntries)..where((t) => t.id.equals(paymentId))).getSingle();
    if (pay.kind != 'payment' || pay.reversed) throw StateError('already reversed');
    final reversalId = newId();
    final movementId = newId();
    final opId = newId();
    final at = DateTime.now().toUtc().toIso8601String();
    await db.transaction(() async {
      await (db.update(db.ledgerEntries)..where((t) => t.id.equals(paymentId))).write(const LedgerEntriesCompanion(reversed: Value(true)));
      await db.into(db.ledgerEntries).insert(LedgerEntriesCompanion.insert(
            id: reversalId,
            enrollmentId: pay.enrollmentId,
            studentId: pay.studentId,
            kind: 'reversal',
            amount: pay.amount,
            reversesId: Value(paymentId),
            businessDate: businessDate,
            opId: Value(opId),
            at: Value(at),
          ));
      await db.into(db.treasuryMovements).insert(TreasuryMovementsCompanion.insert(
            id: movementId,
            accountId: pay.accountId ?? 'cash',
            direction: 'out',
            amount: pay.amount,
            kind: 'student_payment',
            refId: reversalId,
            businessDate: businessDate,
            opId: Value(opId),
            at: Value(at),
          ));
      await outbox.enqueue('payment.reverse', {
        'paymentId': paymentId,
        'reversalId': reversalId,
        'movementId': movementId,
        'reason': ?reason,
        'businessDate': businessDate,
      }, opId: opId);
    });
  }
}
