import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/domain/money.dart';
import '../../core/sync/outbox.dart';

String _now() => DateTime.now().toUtc().toIso8601String();

/// Expense from an account: local expense + money out, queued as `expense.add`.
class AddExpense {
  AddExpense(this.db, this.outbox);
  final AppDatabase db;
  final Outbox outbox;

  Future<String> call({
    required String kind,
    required String item,
    required String label,
    String? carId,
    int? liters,
    String? studentId,
    required Money amount,
    required String accountId,
    String? note,
    required String businessDate,
  }) async {
    final expenseId = newId();
    final movementId = newId();
    final opId = newId();
    final at = _now();
    await db.transaction(() async {
      await db.into(db.expenses).insert(ExpensesCompanion.insert(
            id: expenseId,
            kind: kind,
            item: item,
            label: label,
            carId: Value(carId),
            liters: Value(liters),
            studentId: Value(studentId),
            amount: amount.agorot,
            accountId: accountId,
            note: Value(note),
            businessDate: businessDate,
            opId: Value(opId),
            at: Value(at),
          ));
      await db.into(db.treasuryMovements).insert(TreasuryMovementsCompanion.insert(
            id: movementId,
            accountId: accountId,
            direction: 'out',
            amount: amount.agorot,
            kind: 'expense',
            refId: expenseId,
            businessDate: businessDate,
            opId: Value(opId),
            at: Value(at),
          ));
      await outbox.enqueue('expense.add', {
        'expenseId': expenseId,
        'movementId': movementId,
        'kind': kind,
        'item': item,
        'carId': ?carId,
        'liters': ?liters,
        'studentId': ?studentId,
        'amount': amount.agorot,
        'accountId': accountId,
        'note': ?note,
        'businessDate': businessDate,
      }, opId: opId);
    });
    return expenseId;
  }
}

class ReverseExpense {
  ReverseExpense(this.db, this.outbox);
  final AppDatabase db;
  final Outbox outbox;

  Future<void> call(String expenseId, {String? reason}) async {
    final e = await (db.select(db.expenses)..where((t) => t.id.equals(expenseId))).getSingle();
    final movementId = newId();
    final opId = newId();
    final at = _now();
    await db.transaction(() async {
      await (db.update(db.expenses)..where((t) => t.id.equals(expenseId))).write(const ExpensesCompanion(reversed: Value(true)));
      await db.into(db.treasuryMovements).insert(TreasuryMovementsCompanion.insert(
            id: movementId,
            accountId: e.accountId,
            direction: 'in',
            amount: e.amount,
            kind: 'expense_reversal',
            refId: expenseId,
            businessDate: e.businessDate,
            opId: Value(opId),
            at: Value(at),
          ));
      await outbox.enqueue('expense.reverse', {
        'expenseId': expenseId,
        'movementId': movementId,
        'reason': ?reason,
        'businessDate': e.businessDate,
      }, opId: opId);
    });
  }
}

/// top_up | withdraw | transfer — queued as `money.move`.
class MoveMoney {
  MoveMoney(this.db, this.outbox);
  final AppDatabase db;
  final Outbox outbox;

  Future<void> call({required String kind, String? fromAccountId, String? toAccountId, required Money amount, String? note, required String businessDate}) async {
    final outId = newId();
    final inId = newId();
    final opId = newId();
    final at = _now();
    Future<void> move(String id, String account, String direction, String k, String ref) => db.into(db.treasuryMovements).insert(TreasuryMovementsCompanion.insert(
          id: id,
          accountId: account,
          direction: direction,
          amount: amount.agorot,
          kind: k,
          refId: ref,
          businessDate: businessDate,
          note: Value(note),
          opId: Value(opId),
          at: Value(at),
        ));
    await db.transaction(() async {
      switch (kind) {
        case 'top_up':
          await move(inId, toAccountId!, 'in', 'top_up', inId);
        case 'withdraw':
          await move(outId, fromAccountId!, 'out', 'withdraw', outId);
        default:
          await move(outId, fromAccountId!, 'out', 'transfer_out', inId);
          await move(inId, toAccountId!, 'in', 'transfer_in', outId);
      }
      await outbox.enqueue('money.move', {
        'kind': kind,
        'fromAccountId': ?fromAccountId,
        'toAccountId': ?toAccountId,
        'amount': amount.agorot,
        'outId': outId,
        'inId': inId,
        'note': ?note,
        'businessDate': businessDate,
      }, opId: opId);
    });
  }
}

class CountInput {
  const CountInput({required this.accountId, required this.expected, required this.counted, this.reason});
  final String accountId;
  final Money expected;
  final Money counted;
  final String? reason;
  Money get diff => counted - expected;
}

/// Closes a day with the counted amount per account; the server recomputes "expected" and is the referee.
class CloseDay {
  CloseDay(this.db, this.outbox);
  final AppDatabase db;
  final Outbox outbox;

  Future<void> call({required String businessDate, required String mode, required String closedByName, required List<CountInput> counts}) async {
    final opId = newId();
    final at = _now();
    await db.transaction(() async {
      await db.into(db.dayCloses).insertOnConflictUpdate(DayClosesCompanion.insert(
            id: businessDate,
            state: 'closed',
            mode: mode,
            closedByName: Value(closedByName),
            diffs: Value(counts.where((c) => !c.diff.isZero).length),
            opId: Value(opId),
            syncState: const Value('pending'),
            at: Value(at),
          ));
      for (final c in counts) {
        await db.into(db.dayCloseCounts).insertOnConflictUpdate(DayCloseCountsCompanion.insert(
              id: '${businessDate}_${c.accountId}',
              businessDate: businessDate,
              accountId: c.accountId,
              expected: c.expected.agorot,
              counted: c.counted.agorot,
              diff: c.diff.agorot,
              reason: Value(c.reason),
              opId: Value(opId),
              syncState: const Value('pending'),
              at: Value(at),
            ));
      }
      await outbox.enqueue('day.close', {
        'businessDate': businessDate,
        'mode': mode,
        'counts': [
          for (final c in counts) {'accountId': c.accountId, 'counted': c.counted.agorot, 'reason': ?c.reason},
        ],
      }, opId: opId);
    });
  }
}

class ReopenDay {
  ReopenDay(this.db, this.outbox);
  final AppDatabase db;
  final Outbox outbox;

  Future<void> call(String day, String reason) async {
    final opId = newId();
    await db.transaction(() async {
      await (db.update(db.dayCloses)..where((t) => t.id.equals(day)))
          .write(DayClosesCompanion(state: const Value('reopened'), reopenReason: Value(reason), opId: Value(opId), syncState: const Value('pending')));
      await outbox.enqueue('day.reopen', {'day': day, 'reason': reason}, opId: opId);
    });
  }
}
