import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:driving_school/core/db/database.dart';
import 'package:driving_school/core/domain/money.dart';
import 'package:driving_school/core/sync/outbox.dart';
import 'package:driving_school/core/util/period.dart';
import 'package:driving_school/data/ops_queries.dart';
import 'package:driving_school/features/oversight/ops_actions.dart';
import 'package:driving_school/features/students/student_actions.dart' show ActionError;
import 'package:flutter_test/flutter_test.dart';

import 'support/test_db.dart';

ActivityLogsCompanion _log(String id, String opType, String entity, String label, {String changes = '[]', String? reason, String at = '2026-10-20T09:00:00Z'}) =>
    ActivityLogsCompanion.insert(
      id: id,
      opType: opType,
      entity: entity,
      recordId: 'r_$id',
      recordLabel: label,
      changesJson: Value(changes),
      reason: Value(reason),
      actorId: 'admin',
      actorName: 'المدير',
      at: at,
    );

void main() {
  late AppDatabase db;
  late OpsQueries q;
  setUp(() {
    db = memoryDb();
    q = OpsQueries(db);
  });
  tearDown(() => db.close());

  test('log lines: tags, "from A to B", filters', () async {
    await db.into(db.activityLogs).insert(_log('1', 'create', 'payment', 'دفعة ₪500 · وصل 1-1'));
    await db.into(db.activityLogs).insert(_log('2', 'edit', 'student', 'أحمد خالد', changes: '[{"field":"الجوال","old":"0599","new":"0597"}]'));
    await db.into(db.activityLogs).insert(_log('3', 'archive', 'lesson', 'عملي 3', reason: 'مكرر'));
    final p = Period.of(PeriodKind.custom, from: '2026-10-01', to: '2026-10-31');
    final all = await q.log(p);
    expect(all.map((e) => e.tag).toSet(), {'دفعة', 'تعديل', 'أرشفة'});
    final edit = all.firstWhere((e) => e.row.id == '2');
    expect(edit.changeLine, 'الجوال من 0599 إلى 0597');
    expect(all.firstWhere((e) => e.row.id == '3').changeLine, 'السبب: مكرر');
    expect((await q.log(p, tag: 'دفعة')).single.row.id, '1');
    expect((await q.log(p, q: 'أحمد')).single.row.id, '2');
    expect(await q.log(Period.of(PeriodKind.custom, from: '2026-09-01', to: '2026-09-30')), isEmpty);
  });

  test('report: revenue by account kind, salaries counted once, net', () async {
    await db.into(db.treasuryAccounts).insert(TreasuryAccountsCompanion.insert(id: 'cash', name: 'كاش', kind: 'cash'));
    await db.into(db.treasuryAccounts).insert(TreasuryAccountsCompanion.insert(id: 'bank', name: 'البنك', kind: 'bank'));
    Future<void> mv(String id, String acc, String dir, int amount, String kind) => db.into(db.treasuryMovements).insert(TreasuryMovementsCompanion.insert(
        id: id, accountId: acc, direction: dir, amount: amount, kind: kind, refId: id, businessDate: '2026-10-10', syncState: const Value('synced')));
    await mv('p1', 'cash', 'in', 50000, 'student_payment');
    await mv('p2', 'bank', 'in', 30000, 'student_payment');
    await mv('r1', 'cash', 'out', 10000, 'student_payment'); // a reversed payment
    await mv('a1', 'cash', 'out', 20000, 'advance');
    await db.into(db.expenses).insert(ExpensesCompanion.insert(id: 'e1', kind: 'cars', item: 'بنزين', label: 'بنزين', amount: 15000, accountId: 'cash', businessDate: '2026-10-11'));
    await db.into(db.salaryPayments).insert(SalaryPaymentsCompanion.insert(
        id: 's1', employeeId: 'e', employeeName: 'محمود', payrollMonth: '2026-09', salaryAtMonth: 150000, bonuses: 10000, deductions: 5000, advances: 20000, net: 135000, accountId: 'bank', businessDate: '2026-10-01'));
    final r = await q.report(Period.of(PeriodKind.custom, from: '2026-10-01', to: '2026-10-31'));
    expect(r.revenue, Money.shekels(700));
    expect(r.byKind['cash'], Money.shekels(400));
    expect(r.byKind['bank'], Money.shekels(300));
    expect(r.expenses, Money.shekels(150));
    expect(r.salaries, Money.shekels(1550)); // the advance is inside the salary, not counted again
    expect(r.net, Money.shekels(700 - 150 - 1550));
  });

  test('a month locks only when every day with money is closed', () async {
    final outbox = Outbox(db, testSession);
    await db.into(db.treasuryMovements).insert(TreasuryMovementsCompanion.insert(id: 'm1', accountId: 'cash', direction: 'in', amount: 100, kind: 'top_up', refId: 'm1', businessDate: '2026-09-03'));
    final lock = LockMonth(db, outbox, 'المدير');
    await expectLater(lock('2026-09'), throwsA(isA<ActionError>()));
    await db.into(db.dayCloses).insert(DayClosesCompanion.insert(id: '2026-09-03', state: 'closed', mode: 'full'));
    await lock('2026-09');
    expect((await q.monthLock('2026-09')).locked, isTrue);
    expect((await db.select(db.outboxOps).get()).single.type, 'month.lock');
    await UnlockMonth(db, outbox)('2026-09', 'فاتورة متأخرة');
    expect(await q.isLocked('2026-09'), isFalse);
  });

  test('notices: a rejected change shows up and can be marked read', () async {
    await db.into(db.rejectedOps).insert(RejectedOpsCompanion.insert(opId: 'op1', type: 'payment.record', payloadJson: '{}', reason: 'permission_denied', message: 'ما في صلاحية', rejectedAt: '2026-10-20T10:00:00Z'));
    final n = await q.notices(closeDay: false, exams: false, payroll: false, pendingOps: 2);
    expect(n.map((x) => x.target), ['rejected', 'pending']);
    expect(n.first.meta, 'ما في صلاحية');
    await q.markRead([n.first.id]);
    expect(await q.readNotices(), {n.first.id});
  });
}
