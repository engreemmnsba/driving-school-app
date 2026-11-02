import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/db/database.dart';
import '../core/domain/money.dart';
import '../core/util/dates.dart';
import '../core/util/period.dart';

const _monthNames = ['كانون الثاني', 'شباط', 'آذار', 'نيسان', 'أيار', 'حزيران', 'تموز', 'آب', 'أيلول', 'تشرين الأول', 'تشرين الثاني', 'كانون الأول'];

/// "2026-10" for a business date.
String monthOf(String businessDate) => businessDate.substring(0, 7);
String currentMonth() => monthOf(todayStr());

/// "تشرين الأول 2026"
String monthLabel(String month) {
  final y = month.substring(0, 4);
  final m = int.parse(month.substring(5, 7));
  return '${_monthNames[m - 1]} $y';
}

/// "تشرين الأول" (no year)
String monthName(String month) => _monthNames[int.parse(month.substring(5, 7)) - 1];

String addMonths(String month, int n) {
  final y = int.parse(month.substring(0, 4));
  final m = int.parse(month.substring(5, 7)) - 1 + n;
  final yy = y + (m >= 0 ? m ~/ 12 : (m - 11) ~/ 12);
  final mm = m % 12 + 1;
  return '$yy-${mm.toString().padLeft(2, '0')}';
}

String _lastDay(String month) {
  final y = int.parse(month.substring(0, 4));
  final m = int.parse(month.substring(5, 7));
  return businessDateOf(DateTime(y, m + 1, 0));
}

Expression<bool> _ok(GeneratedColumn<String> syncState) => syncState.equals('rejected').not();

// ---------------------------------------------------------------- payroll

class PayrollLine {
  const PayrollLine({
    required this.employee,
    required this.salary,
    required this.bonuses,
    required this.deductions,
    required this.advances,
    required this.advanceCount,
    required this.payment,
    required this.paymentAccountName,
  });
  final EmployeeRow employee;
  final Money salary;
  final Money bonuses;
  final Money deductions;
  final Money advances;
  final int advanceCount;
  final SalaryPaymentRow? payment;
  final String? paymentAccountName;

  bool get paid => payment != null;
  bool get pending => payment?.syncState == 'pending';

  /// salary + bonuses − deductions − advances (what a "صرف" pays now), or what was paid.
  Money get net => payment != null ? Money(payment!.net) : salary + bonuses - deductions - advances;

  /// "راتب ₪1,500 · مكافأة ₪100 · سلف ₪400 (2)"
  String get line {
    final s = payment == null ? salary : Money(payment!.salaryAtMonth);
    final parts = ['راتب ${s.format()}'];
    if (!bonuses.isZero) parts.add('مكافأة ${bonuses.format()}');
    if (!deductions.isZero) parts.add('خصم ${deductions.format()}');
    if (!advances.isZero) parts.add('سلف ${advances.format()} ($advanceCount)');
    return parts.join(' · ');
  }

  /// "انصرف 1/10 · البنك · قبل الموعد"
  String? get paidInfo {
    final p = payment;
    if (p == null) return null;
    final parts = ['انصرف ${dateShort(p.businessDate)}', ?paymentAccountName, if (p.early) 'قبل الموعد'];
    return parts.join(' · ');
  }
}

class PayrollMonthView {
  const PayrollMonthView({required this.month, required this.lines, this.locked = false});
  final String month;
  final List<PayrollLine> lines;

  /// The accounting month is locked: read-only (corrections go in the open month).
  final bool locked;
  int get unpaid => lines.where((l) => !l.paid).length;
  Money get salaries => lines.fold(const Money.zero(), (s, l) => s + (l.payment == null ? l.salary : Money(l.payment!.salaryAtMonth)));
  Money get advances => lines.fold(const Money.zero(), (s, l) => s + l.advances);
  Money get left => lines.where((l) => !l.paid && !l.net.isNegative).fold(const Money.zero(), (s, l) => s + l.net);
}

class MonthState {
  const MonthState(this.month, this.unpaid, this.employees);
  final String month;
  final int unpaid;
  final int employees;
}

class EmployeeStatementRow {
  const EmployeeStatementRow({required this.kind, required this.what, required this.when, required this.who, required this.amount, required this.month, required this.sortKey, this.pending = false});

  /// advance | deduction | bonus | pay
  final String kind;
  final String what;
  final String when;
  final String who;
  final Money amount;
  final String month;
  final String sortKey;
  final bool pending;
}

class StatementMonth {
  const StatementMonth({required this.month, required this.rows, required this.payment, required this.netSoFar});
  final String month;
  final List<EmployeeStatementRow> rows;
  final SalaryPaymentRow? payment;
  final Money netSoFar;
}

class EmployeeStatement {
  const EmployeeStatement({required this.employee, required this.salary, required this.months, required this.paidTotal, required this.advanceTotal, required this.thisMonth, required this.subtitle});
  final EmployeeRow employee;
  final Money salary;
  final List<StatementMonth> months;
  final Money paidTotal;
  final Money advanceTotal;

  /// The current month's line (net so far or paid).
  final PayrollLine thisMonth;
  final String subtitle;
}

// ---------------------------------------------------------------- cars

class CarView {
  const CarView({required this.car, required this.students, required this.instructorIds});
  final CarRow car;
  final int students;
  final Set<String> instructorIds;
  String get gearLabel => car.gearbox == 'auto' ? 'أوتوماتيك' : 'عادي';
}

class CarReportRow {
  const CarReportRow({required this.car, required this.instructors, required this.lessons, required this.fuel, required this.liters, required this.other});
  final CarRow car;
  final String instructors;
  final int lessons;
  final Money fuel;
  final int liters;

  /// Maintenance and every other car cost (not fuel).
  final Money other;

  /// null when there were no lessons (nothing to divide by).
  Money? get fuelPerLesson => lessons == 0 ? null : Money((fuel.agorot / lessons).round());
  Money? get allPerLesson => lessons == 0 ? null : Money(((fuel.agorot + other.agorot) / lessons).round());
}

// ---------------------------------------------------------------- instructors

class InstructorStudent {
  const InstructorStudent({required this.enrollment, required this.carName, required this.meta, required this.lessonsWith});
  final EnrollmentRow enrollment;
  final String carName;
  final String meta;
  final int lessonsWith;
}

class InstructorView {
  const InstructorView({
    required this.employee,
    required this.carNames,
    required this.lessons,
    required this.students,
    required this.passRate,
    required this.examsCounted,
    required this.lessonRows,
    required this.payments,
  });
  final EmployeeRow employee;
  final List<String> carNames;
  final int lessons;
  final List<InstructorStudent> students;

  /// null when no practical exam result in the period.
  final int? passRate;
  final int examsCounted;
  final List<(LessonRow, String)> lessonRows;
  final List<SalaryPaymentRow> payments;
}

// ---------------------------------------------------------------- users

class UserView {
  const UserView({required this.user, required this.meta, required this.permissions});
  final AppUserRow user;
  final String meta;
  final Map<String, dynamic> permissions;
  bool get active => user.status == 'active';
  bool get pending => user.syncState == 'pending';
}

String roleName(String kind) => switch (kind) { 'admin' => 'مدير', 'instructor' => 'مدرب', 'staff' => 'موظف', _ => kind };

class StaffQueries {
  StaffQueries(this.db);
  final AppDatabase db;

  Future<Map<String, String>> _accountNames() async => {for (final a in await db.select(db.treasuryAccounts).get()) a.id: a.name};

  /// Salary of a payroll month = latest version from that month or before.
  Future<Money> salaryAt(String employeeId, String month) async {
    final r = await (db.select(db.salaryRates)
          ..where((t) => t.employeeId.equals(employeeId) & t.effectiveFrom.isSmallerOrEqualValue(month))
          ..orderBy([(t) => OrderingTerm.desc(t.effectiveFrom)])
          ..limit(1))
        .getSingleOrNull();
    return Money(r?.monthlyAmount ?? 0);
  }

  Future<String?> _firstMonth(String employeeId) async {
    final r = await (db.select(db.salaryRates)
          ..where((t) => t.employeeId.equals(employeeId))
          ..orderBy([(t) => OrderingTerm.asc(t.effectiveFrom)])
          ..limit(1))
        .getSingleOrNull();
    return r?.effectiveFrom;
  }

  Future<PayrollLine> line(EmployeeRow e, String month, {Map<String, String>? accounts}) async {
    final items = await (db.select(db.payrollItems)..where((t) => t.employeeId.equals(e.id) & t.payrollMonth.equals(month) & _ok(t.syncState))).get();
    final pay = await (db.select(db.salaryPayments)..where((t) => t.employeeId.equals(e.id) & t.payrollMonth.equals(month) & _ok(t.syncState))).getSingleOrNull();
    int sum(String k) => items.where((i) => i.kind == k).fold(0, (s, i) => s + i.amount);
    final names = accounts ?? await _accountNames();
    return PayrollLine(
      employee: e,
      salary: await salaryAt(e.id, month),
      bonuses: Money(sum('bonus')),
      deductions: Money(sum('deduction')),
      advances: Money(sum('advance')),
      advanceCount: items.where((i) => i.kind == 'advance').length,
      payment: pay,
      paymentAccountName: pay == null ? null : names[pay.accountId],
    );
  }

  /// Employees on a payroll month: active ones whose salary started by then, plus anyone with movements that month.
  Future<List<EmployeeRow>> _employeesOf(String month) async {
    final all = await (db.select(db.employees)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
    final out = <EmployeeRow>[];
    for (final e in all) {
      final first = await _firstMonth(e.id);
      final started = first != null && first.compareTo(month) <= 0;
      final hasRows = (await (db.select(db.payrollItems)..where((t) => t.employeeId.equals(e.id) & t.payrollMonth.equals(month))).get()).isNotEmpty ||
          (await (db.select(db.salaryPayments)..where((t) => t.employeeId.equals(e.id) & t.payrollMonth.equals(month))).get()).isNotEmpty;
      if ((e.active && started) || hasRows) out.add(e);
    }
    return out;
  }

  Future<PayrollMonthView> payrollMonth(String month) async {
    final accounts = await _accountNames();
    final lines = [for (final e in await _employeesOf(month)) await line(e, month, accounts: accounts)];
    lines.sort((a, b) => (a.paid ? 1 : 0).compareTo(b.paid ? 1 : 0));
    final lock = await (db.select(db.monthLocks)..where((t) => t.id.equals(month))).getSingleOrNull();
    return PayrollMonthView(month: month, lines: lines, locked: lock?.locked == true);
  }

  /// Every payroll month from the first salary to this month, newest first, with its state.
  Future<List<MonthState>> payrollMonths() async {
    final first = await (db.select(db.salaryRates)..orderBy([(t) => OrderingTerm.asc(t.effectiveFrom)])..limit(1)).getSingleOrNull();
    final now = currentMonth();
    var m = first?.effectiveFrom ?? now;
    if (m.compareTo(addMonths(now, -36)) < 0) m = addMonths(now, -36);
    final out = <MonthState>[];
    while (m.compareTo(now) <= 0) {
      final v = await payrollMonth(m);
      out.add(MonthState(m, v.unpaid, v.lines.length));
      m = addMonths(m, 1);
    }
    return out.reversed.toList();
  }

  /// The newest month before [month] that still has unpaid employees (banner on the current month).
  Future<MonthState?> olderUnpaid(String month) async {
    for (final s in await payrollMonths()) {
      if (s.month.compareTo(month) < 0 && s.unpaid > 0) return s;
    }
    return null;
  }

  /// Payroll month an advance / deduction / bonus goes on today: this month, or next month once it's paid.
  Future<String> openMonthFor(String employeeId) async {
    final m = currentMonth();
    final paid = await (db.select(db.salaryPayments)..where((t) => t.employeeId.equals(employeeId) & t.payrollMonth.equals(m) & _ok(t.syncState))).getSingleOrNull();
    return paid == null ? m : addMonths(m, 1);
  }

  Future<List<(EmployeeRow, bool)>> employeesForPicker() async {
    final all = await (db.select(db.employees)..orderBy([(t) => OrderingTerm.desc(t.active), (t) => OrderingTerm.asc(t.name)])).get();
    final m = currentMonth();
    return [
      for (final e in all)
        (e, (await (db.select(db.salaryPayments)..where((t) => t.employeeId.equals(e.id) & t.payrollMonth.equals(m) & _ok(t.syncState))).getSingleOrNull()) != null),
    ];
  }

  Future<String> _roleLine(EmployeeRow e) async {
    if (e.role != 'instructor') {
      final u = e.userId == null ? null : await (db.select(db.appUsers)..where((t) => t.id.equals(e.userId!))).getSingleOrNull();
      return u?.job == 'accountant' ? 'محاسب' : u?.job == 'secretary' ? 'سكرتاريا' : 'موظف';
    }
    final cars = await carNamesOf(e.id);
    return cars.isEmpty ? 'مدرب' : 'مدرب · ${cars.join(' و')}';
  }

  Future<List<String>> carNamesOf(String employeeId) async {
    final links = await (db.select(db.carInstructors)..where((t) => t.employeeId.equals(employeeId) & t.to.isNull())).get();
    final names = {for (final c in await db.select(db.cars).get()) c.id: c.name};
    return [for (final l in links) ?names[l.carId]]..sort();
  }

  /// Every salary, advance, deduction, bonus and payment of one employee, grouped by payroll month (newest first).
  Future<EmployeeStatement?> statement(String employeeId, {required String fromMonth, required String toMonth}) async {
    final e = await (db.select(db.employees)..where((t) => t.id.equals(employeeId))).getSingleOrNull();
    if (e == null) return null;
    final accounts = await _accountNames();
    final items = await (db.select(db.payrollItems)
          ..where((t) => t.employeeId.equals(employeeId) & t.payrollMonth.isBetweenValues(fromMonth, toMonth) & _ok(t.syncState)))
        .get();
    final pays = await (db.select(db.salaryPayments)
          ..where((t) => t.employeeId.equals(employeeId) & t.payrollMonth.isBetweenValues(fromMonth, toMonth) & _ok(t.syncState)))
        .get();
    String when(String bd, String? at, String? accountId) {
      final dt = DateTime.tryParse(at ?? '');
      final parts = [friendlyDate(bd) == 'اليوم' || friendlyDate(bd) == 'مبارح' ? friendlyDate(bd) : '${friendlyDate(bd)}${bd.startsWith(todayStr().substring(0, 4)) ? '' : ' ${bd.substring(0, 4)}'}'];
      if (dt != null) parts.add(hhmm(dt));
      if (accountId != null && accounts[accountId] != null) parts.add('من ${accounts[accountId]}');
      return parts.join(' · ');
    }

    final rows = <EmployeeStatementRow>[
      for (final i in items)
        EmployeeStatementRow(
          kind: i.kind,
          what: i.kind == 'advance' ? 'سلفة${i.note == null ? '' : ' · ${i.note}'}' : '${i.kind == 'bonus' ? 'مكافأة' : 'خصم'}: ${i.reason}${i.note == null ? '' : ' · ${i.note}'}',
          when: when(i.businessDate, i.at, i.accountId),
          who: 'سجّلها ${i.recordedByName ?? 'المدير'}',
          amount: Money(i.amount),
          month: i.payrollMonth,
          sortKey: '${i.businessDate}${i.at ?? ''}',
          pending: i.syncState == 'pending',
        ),
      for (final p in pays)
        EmployeeStatementRow(
          kind: 'pay',
          what: 'صرف راتب ${monthName(p.payrollMonth)}',
          when: when(p.businessDate, p.at, p.accountId),
          who: [
            'صرفه ${p.paidByName ?? 'المدير'}',
            if (p.advances > 0 || p.deductions > 0 || p.bonuses > 0)
              'من راتب ${Money(p.salaryAtMonth).format()}${p.advances > 0 ? ' بعد خصم سلف ${Money(p.advances).format()}' : ''}${p.deductions > 0 ? ' وخصم ${Money(p.deductions).format()}' : ''}${p.bonuses > 0 ? ' ومكافأة ${Money(p.bonuses).format()}' : ''}',
            if (p.early) 'قبل الموعد',
          ].join(' · '),
          amount: Money(p.net),
          month: p.payrollMonth,
          sortKey: '${p.businessDate}${p.at ?? ''}',
          pending: p.syncState == 'pending',
        ),
    ]..sort((a, b) => b.sortKey.compareTo(a.sortKey));
    final months = rows.map((r) => r.month).toSet().toList()..sort((a, b) => b.compareTo(a));
    final cur = currentMonth();
    if (cur.compareTo(fromMonth) >= 0 && cur.compareTo(toMonth) <= 0 && !months.contains(cur)) months.insert(0, cur);
    final out = <StatementMonth>[];
    for (final m in months) {
      final l = await line(e, m, accounts: accounts);
      out.add(StatementMonth(month: m, rows: rows.where((r) => r.month == m).toList(), payment: l.payment, netSoFar: l.net));
    }
    final thisMonth = await line(e, cur, accounts: accounts);
    final salary = await salaryAt(e.id, cur);
    return EmployeeStatement(
      employee: e,
      salary: salary,
      months: out,
      paidTotal: Money(pays.fold(0, (s, p) => s + p.net)),
      advanceTotal: Money(items.where((i) => i.kind == 'advance').fold(0, (s, i) => s + i.amount)),
      thisMonth: thisMonth,
      subtitle: '${await _roleLine(e)} · راتب ${salary.format()}',
    );
  }

  // ---------------------------------------------------------------- cars

  Future<List<EmployeeRow>> instructors() =>
      (db.select(db.employees)..where((t) => t.role.equals('instructor') & t.active.equals(true))..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Future<List<CarView>> cars() async {
    final cars = await (db.select(db.cars)..where((t) => t.active.equals(true))..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
    final links = await (db.select(db.carInstructors)..where((t) => t.to.isNull())).get();
    final enrollments = await (db.select(db.enrollments)
          ..where((t) => t.archived.equals(false) & t.stage.isNotIn(['graduated', 'withdrawn']) & _ok(t.syncState)))
        .get();
    return [
      for (final c in cars)
        CarView(
          car: c,
          students: enrollments.where((e) => e.carId == c.id).length,
          instructorIds: links.where((l) => l.carId == c.id).map((l) => l.employeeId).toSet(),
        ),
    ];
  }

  Future<List<CarReportRow>> carReport(Period p) async {
    final cars = await (db.select(db.cars)..where((t) => t.active.equals(true))..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
    final names = {for (final e in await db.select(db.employees).get()) e.id: e.name};
    final links = await (db.select(db.carInstructors)..where((t) => t.to.isNull())).get();
    final out = <CarReportRow>[];
    for (final c in cars) {
      final lessons = await (db.select(db.lessons)
            ..where((t) =>
                t.carId.equals(c.id) &
                t.type.equals('practical') &
                t.withoutDriving.equals(false) &
                t.archived.equals(false) &
                _ok(t.syncState) &
                t.businessDate.isBetweenValues(p.from, p.to)))
          .get();
      final exp = await (db.select(db.expenses)
            ..where((t) => t.carId.equals(c.id) & t.reversed.equals(false) & _ok(t.syncState) & t.businessDate.isBetweenValues(p.from, p.to)))
          .get();
      final fuel = exp.where((x) => x.item == 'بنزين');
      out.add(CarReportRow(
        car: c,
        instructors: [for (final l in links.where((l) => l.carId == c.id)) ?names[l.employeeId]].join(' · '),
        lessons: lessons.length,
        fuel: Money(fuel.fold(0, (s, x) => s + x.amount)),
        liters: fuel.fold(0, (s, x) => s + (x.liters ?? 0)),
        other: Money(exp.where((x) => x.item != 'بنزين').fold(0, (s, x) => s + x.amount)),
      ));
    }
    return out;
  }

  // ---------------------------------------------------------------- instructors

  Future<InstructorView?> instructor(String employeeId, Period p) async {
    final e = await (db.select(db.employees)..where((t) => t.id.equals(employeeId))).getSingleOrNull();
    if (e == null) return null;
    final links = await (db.select(db.carInstructors)..where((t) => t.employeeId.equals(employeeId) & t.to.isNull())).get();
    final carIds = links.map((l) => l.carId).toSet();
    final carNames = {for (final c in await db.select(db.cars).get()) c.id: c.name};
    final lessons = await (db.select(db.lessons)
          ..where((t) => t.employeeId.equals(employeeId) & t.archived.equals(false) & _ok(t.syncState) & t.businessDate.isBetweenValues(p.from, p.to))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
    final allWith = await (db.select(db.lessons)..where((t) => t.employeeId.equals(employeeId) & t.archived.equals(false) & _ok(t.syncState))).get();
    final enrollments = carIds.isEmpty
        ? <EnrollmentRow>[]
        : await (db.select(db.enrollments)
              ..where((t) => t.carId.isIn(carIds) & t.archived.equals(false) & t.stage.isNotIn(['graduated', 'withdrawn']) & _ok(t.syncState))
              ..orderBy([(t) => OrderingTerm.asc(t.studentName)]))
            .get();
    final students = <InstructorStudent>[];
    final names = <String, String>{};
    for (final en in enrollments) {
      names[en.id] = en.studentName;
      final practical = allWith.where((l) => l.enrollmentId == en.id && l.type == 'practical').length;
      final total = (await (db.select(db.lessons)..where((t) => t.enrollmentId.equals(en.id) & t.type.equals('practical') & t.archived.equals(false) & _ok(t.syncState))).get()).length;
      final planned = (await (db.select(db.licensePrices)
                ..where((t) => t.licenseTypeId.equals(en.licenseTypeId))
                ..orderBy([(t) => OrderingTerm.desc(t.effectiveFrom)])
                ..limit(1))
              .getSingleOrNull())
          ?.plannedPracticalLessons;
      final stage = switch (en.stage) {
        'theory' => 'نظري',
        'passed' => 'نجح بالعملي',
        'ready_practical' => 'جاهز للتست',
        _ => planned == null || planned == 0 ? 'عملي $total' : 'عملي $total/$planned',
      };
      students.add(InstructorStudent(enrollment: en, carName: carNames[en.carId] ?? '', meta: '${carNames[en.carId] ?? ''} · $stage', lessonsWith: practical + allWith.where((l) => l.enrollmentId == en.id && l.type == 'theory').length));
    }
    for (final l in lessons) {
      if (!names.containsKey(l.enrollmentId)) {
        final en = await (db.select(db.enrollments)..where((t) => t.id.equals(l.enrollmentId))).getSingleOrNull();
        names[l.enrollmentId] = en?.studentName ?? '';
      }
    }
    // Pass rate: practical exam results in the period for students of the instructor's cars.
    final exams = carIds.isEmpty
        ? <ExamRow>[]
        : await (db.select(db.exams)
              ..where((t) => t.carId.isIn(carIds) & t.type.equals('practical') & t.result.isIn(['passed', 'failed', 'absent']) & _ok(t.syncState) & t.scheduledDate.isBetweenValues(p.from, p.to)))
            .get();
    final passed = exams.where((x) => x.result == 'passed').length;
    final pays = await (db.select(db.salaryPayments)..where((t) => t.employeeId.equals(employeeId) & _ok(t.syncState))..orderBy([(t) => OrderingTerm.desc(t.payrollMonth)])).get();
    return InstructorView(
      employee: e,
      carNames: [for (final id in carIds) ?carNames[id]]..sort(),
      lessons: lessons.length,
      students: students,
      passRate: exams.isEmpty ? null : (passed * 100 / exams.length).round(),
      examsCounted: exams.length,
      lessonRows: [for (final l in lessons) (l, names[l.enrollmentId] ?? '')],
      payments: pays,
    );
  }

  // ---------------------------------------------------------------- users

  Future<List<UserView>> users() async {
    final rows = await (db.select(db.appUsers)..where((t) => t.kind.isNotIn(['student']) & _ok(t.syncState))).get();
    const order = {'admin': 0, 'instructor': 1, 'staff': 2};
    rows.sort((a, b) {
      final s = (a.status == 'active' ? 0 : 1).compareTo(b.status == 'active' ? 0 : 1);
      if (s != 0) return s;
      final k = (order[a.kind] ?? 9).compareTo(order[b.kind] ?? 9);
      return k != 0 ? k : a.name.compareTo(b.name);
    });
    final out = <UserView>[];
    for (final u in rows) {
      final perms = _decode(u.permissionsJson);
      final parts = <String>[roleName(u.kind)];
      if (u.kind == 'instructor' && u.employeeId != null) {
        final cars = await carNamesOf(u.employeeId!);
        if (cars.isNotEmpty) parts.add(cars.join(' و'));
      } else if (u.kind == 'staff') {
        parts.add(switch (u.job) { 'accountant' => 'محاسب', 'secretary' => 'سكرتاريا', 'manager' => 'كل الصلاحيات', _ => 'صلاحيات خاصة' });
      }
      if (u.syncState == 'pending') parts.add('لسا ما وصل السيرفر');
      out.add(UserView(user: u, meta: u.status == 'active' ? parts.join(' · ') : 'موقوف · ما بيقدر يدخل', permissions: perms));
    }
    return out;
  }

  Future<UserView?> user(String id) async => (await users()).where((u) => u.user.id == id).firstOrNull;

  Future<bool> nationalIdTaken(String nationalId) async =>
      (await (db.select(db.appUsers)..where((t) => t.nationalId.equals(nationalId) & _ok(t.syncState))).get()).isNotEmpty;

  Map<String, dynamic> _decode(String json) {
    try {
      final v = jsonDecode(json);
      return v is Map<String, dynamic> ? v : <String, dynamic>{};
    } on FormatException {
      return <String, dynamic>{};
    }
  }
}

/// The last day of a payroll month (salary due at month end, A1).
String lastDayOfMonth(String month) => _lastDay(month);
