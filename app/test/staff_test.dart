import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:driving_school/core/db/database.dart';
import 'package:driving_school/core/domain/money.dart';
import 'package:driving_school/core/domain/permissions.dart';
import 'package:driving_school/core/sync/outbox.dart';
import 'package:driving_school/core/sync/puller.dart';
import 'package:driving_school/data/money_queries.dart';
import 'package:driving_school/data/staff_queries.dart';
import 'package:driving_school/features/staff/staff_actions.dart';
import 'package:driving_school/features/students/student_actions.dart' show ActionError;
import 'package:flutter_test/flutter_test.dart';

import 'support/test_db.dart';

void main() {
  test('months: labels and arithmetic across years', () {
    expect(addMonths('2026-01', -1), '2025-12');
    expect(addMonths('2026-11', 2), '2027-01');
    expect(monthLabel('2026-10'), 'تشرين الأول 2026');
    expect(lastDayOfMonth('2026-02'), '2026-02-28');
  });

  test('job templates match the dependency rules', () {
    for (final job in jobTemplates.keys) {
      final tasks = jobTasks(job);
      expect(withDependencies(tasks), tasks, reason: job);
    }
  });

  test('each person pulls only what the server lets them read', () {
    final accountant = pullCollectionsFor(kind: 'staff', can: (t) => jobTasks('accountant')[t] == true);
    expect(accountant, containsAll(['student', 'student_ledger', 'treasury_movement', 'expense', 'day_close']));
    expect(accountant, isNot(contains('account_balance')));
    expect(accountant, isNot(contains('payroll_item')));
    expect(accountant, isNot(contains('user')));
    final admin = pullCollectionsFor(kind: 'admin', can: (_) => true);
    expect(admin, containsAll(['payroll_item', 'salary_payment', 'salary_rate', 'user']));
  });

  group('payroll', () {
    late AppDatabase db;
    late Outbox outbox;
    late StaffQueries q;
    late EmployeeRow mahmoud;
    final month = currentMonth();

    setUp(() async {
      db = memoryDb();
      outbox = Outbox(db, testSession);
      q = StaffQueries(db);
      await db.into(db.treasuryAccounts).insert(TreasuryAccountsCompanion.insert(id: 'cash', name: 'كاش', kind: 'cash', openingBalance: const Value(500000)));
      await db.into(db.employees).insert(EmployeesCompanion.insert(id: 'emp_m', name: 'محمود', role: 'instructor', salary: const Value(150000)));
      await db.into(db.salaryRates).insert(SalaryRatesCompanion.insert(id: 'r1', employeeId: 'emp_m', effectiveFrom: addMonths(month, -3), monthlyAmount: 150000));
      mahmoud = await (db.select(db.employees)..where((t) => t.id.equals('emp_m'))).getSingle();
    });
    tearDown(() => db.close());

    test('net = salary + bonus − deduction − advances; an advance leaves the cash at once', () async {
      final add = AddPayrollItem(db, outbox, 'المدير');
      final today = '$month-05';
      await add(employee: mahmoud, kind: 'advance', amount: Money.shekels(200), payrollMonth: month, businessDate: today, accountId: 'cash');
      await add(employee: mahmoud, kind: 'bonus', amount: Money.shekels(100), payrollMonth: month, businessDate: today, reason: 'إضافي');
      await add(employee: mahmoud, kind: 'deduction', amount: Money.shekels(50), payrollMonth: month, businessDate: today, reason: 'غياب يوم');
      final v = await q.payrollMonth(month);
      final l = v.lines.single;
      expect(l.net, Money.shekels(1500 + 100 - 50 - 200));
      expect(l.line, contains('سلف ₪200 (1)'));
      expect(v.left, Money.shekels(1350));
      final cash = (await MoneyQueries(db).accounts()).single;
      expect(cash.balance, Money.shekels(5000 - 200));
      final ops = await db.select(db.outboxOps).get();
      expect(ops.map((o) => o.type), ['payroll.item', 'payroll.item', 'payroll.item']);
      expect(jsonDecode(ops.first.payloadJson), containsPair('accountId', 'cash'));
      expect(jsonDecode(ops[1].payloadJson), isNot(contains('accountId')));
    });

    test('paying closes the month: net leaves the account, later items go to next month', () async {
      final add = AddPayrollItem(db, outbox, 'المدير');
      await add(employee: mahmoud, kind: 'advance', amount: Money.shekels(300), payrollMonth: month, businessDate: '$month-02', accountId: 'cash');
      final line = (await q.payrollMonth(month)).lines.single;
      final net = await PaySalary(db, outbox, 'المدير')(line: line, payrollMonth: month, accountId: 'cash', businessDate: '$month-03');
      expect(net, Money.shekels(1200));
      final after = (await q.payrollMonth(month)).lines.single;
      expect(after.paid, isTrue);
      expect(after.paidInfo, contains('قبل الموعد'));
      expect((await MoneyQueries(db).accounts()).single.balance, Money.shekels(5000 - 300 - 1200));
      expect(await q.openMonthFor('emp_m'), addMonths(month, 1));
      await expectLater(
        add(employee: mahmoud, kind: 'bonus', amount: Money.shekels(10), payrollMonth: month, businessDate: '$month-04'),
        throwsA(isA<ActionError>()),
      );
    });

    test('a past month keeps the salary it had; months list shows what is unpaid', () async {
      await db.into(db.salaryRates).insert(SalaryRatesCompanion.insert(id: 'r2', employeeId: 'emp_m', effectiveFrom: month, monthlyAmount: 180000));
      expect((await q.payrollMonth(addMonths(month, -1))).lines.single.salary, Money.shekels(1500));
      expect((await q.payrollMonth(month)).lines.single.salary, Money.shekels(1800));
      final months = await q.payrollMonths();
      expect(months.first.month, month);
      expect(months.length, 4);
      expect((await q.olderUnpaid(month))?.month, addMonths(month, -1));
    });

    test('statement groups by payroll month with who and account', () async {
      await AddPayrollItem(db, outbox, 'المدير')(employee: mahmoud, kind: 'advance', amount: Money.shekels(200), payrollMonth: month, businessDate: '$month-02', accountId: 'cash');
      final s = await q.statement('emp_m', fromMonth: addMonths(month, -2), toMonth: month);
      expect(s!.months.first.month, month);
      final row = s.months.first.rows.single;
      expect(row.kind, 'advance');
      expect(row.when, contains('من كاش'));
      expect(row.who, 'سجّلها المدير');
      expect(s.advanceTotal, Money.shekels(200));
      expect(s.thisMonth.net, Money.shekels(1300));
    });
  });

  group('cars and users', () {
    late AppDatabase db;
    late Outbox outbox;
    setUp(() async {
      db = memoryDb();
      outbox = Outbox(db, testSession);
      await db.into(db.treasuryAccounts).insert(TreasuryAccountsCompanion.insert(id: 'cash', name: 'كاش', kind: 'cash'));
      await db.into(db.cars).insert(CarsCompanion.insert(id: 'car1', name: 'سيارة 1'));
      await db.into(db.employees).insert(EmployeesCompanion.insert(id: 'emp_m', name: 'محمود', role: 'instructor'));
    });
    tearDown(() => db.close());

    test('toggling an instructor opens and ends a link (history kept)', () async {
      final toggle = ToggleCarInstructor(db, outbox);
      await toggle(carId: 'car1', employeeId: 'emp_m', on: true, today: '2026-10-20');
      expect((await StaffQueries(db).cars()).single.instructorIds, {'emp_m'});
      await toggle(carId: 'car1', employeeId: 'emp_m', on: false, today: '2026-10-26');
      expect((await StaffQueries(db).cars()).single.instructorIds, isEmpty);
      final links = await db.select(db.carInstructors).get();
      expect(links.single.to, '2026-10-26');
      expect((await db.select(db.outboxOps).get()).map((o) => o.type), ['car.instructor', 'car.instructor']);
    });

    test('a new accountant starts on cash only; the password is never stored locally', () async {
      final created = await CreateUser(db, outbox)(name: 'هالة', nationalId: '402345678', role: 'staff', job: 'accountant', salary: Money.shekels(1000), businessDate: '2026-10-26');
      final u = await (db.select(db.appUsers)..where((t) => t.id.equals(created.userId))).getSingle();
      final perms = jsonDecode(u.permissionsJson) as Map<String, dynamic>;
      expect(perms['allowedAccounts'], ['cash']);
      expect(perms['closeMode'], 'blind');
      expect(u.permissionsJson, isNot(contains(created.password)));
      final op = (await db.select(db.outboxOps).get()).single;
      expect(jsonDecode(op.payloadJson), containsPair('tempPassword', created.password));
      expect(await StaffQueries(db).salaryAt(u.employeeId!, '2026-10'), Money.shekels(1000));
      await expectLater(
        CreateUser(db, outbox)(name: 'ثاني', nationalId: '402345678', role: 'staff', businessDate: '2026-10-26'),
        throwsA(isA<ActionError>()),
      );
    });

    test('permissions save with their dependencies and options', () async {
      final created = await CreateUser(db, outbox)(name: 'سلمى', nationalId: '402345670', role: 'staff', job: 'secretary', businessDate: '2026-10-26');
      final u = await (db.select(db.appUsers)..where((t) => t.id.equals(created.userId))).getSingle();
      await SavePermissions(db, outbox)(user: u, job: null, tasks: {'moveMoney': true}, options: const PermissionOptions(closeMode: 'full'));
      final after = await (db.select(db.appUsers)..where((t) => t.id.equals(created.userId))).getSingle();
      final perms = jsonDecode(after.permissionsJson) as Map<String, dynamic>;
      expect(perms['tasks'], {'moveMoney': true, 'seeBal': true});
      expect(perms['allowedAccounts'], 'all');
      expect(after.permVersion, 2);
      expect((await db.select(db.outboxOps).get()).last.type, 'user.permissions');
    });
  });
}
