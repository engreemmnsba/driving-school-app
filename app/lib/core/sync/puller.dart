import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';

/// One server document as delivered by the change feed.
class RemoteDoc {
  const RemoteDoc({required this.id, required this.serverSeq, required this.data});
  final String id;
  final int serverSeq;
  final Map<String, dynamic> data;
}

/// Reads server changes for one collection after a cursor (Firestore query in production, fake in tests).
/// Scope (instructor cars, money visibility…) is enforced by security rules on the server side.
abstract class ChangeSource {
  Future<List<RemoteDoc>> fetch(String collection, {required int afterSeq, required int limit});
}

class PullReport {
  const PullReport(this.applied);
  final Map<String, int> applied;
  int get total => applied.values.fold(0, (a, b) => a + b);
}

typedef _Apply = Future<void> Function(AppDatabase db, RemoteDoc d);

/// Pulls each collection by `serverSeq` cursor, page by page; a page and its cursor are saved in one transaction.
class Puller {
  Puller(this.db, this.source, {this.pageSize = 500, List<String>? collections})
      : collections = collections ?? _appliers.keys.toList();

  final AppDatabase db;
  final ChangeSource source;
  final int pageSize;
  final List<String> collections;
  bool _running = false;

  Future<PullReport> pullAll() async {
    if (_running) return const PullReport({});
    _running = true;
    final applied = <String, int>{};
    try {
      for (final c in collections) {
        final apply = _appliers[c];
        if (apply == null) throw ArgumentError('No applier for $c');
        var cursor = await _cursor(c);
        while (true) {
          final page = await source.fetch(c, afterSeq: cursor, limit: pageSize);
          if (page.isEmpty) break;
          final maxSeq = page.map((d) => d.serverSeq).reduce((a, b) => a > b ? a : b);
          await db.transaction(() async {
            for (final d in page) {
              await apply(db, d);
            }
            await db.into(db.syncCursors).insertOnConflictUpdate(
                SyncCursorsCompanion.insert(collection: c, lastSeq: Value(maxSeq)));
          });
          applied[c] = (applied[c] ?? 0) + page.length;
          cursor = maxSeq;
          if (page.length < pageSize) break;
        }
      }
      return PullReport(applied);
    } finally {
      _running = false;
    }
  }

  Future<int> _cursor(String c) async {
    final row = await (db.select(db.syncCursors)..where((t) => t.collection.equals(c))).getSingleOrNull();
    return row?.lastSeq ?? 0;
  }
}

// ---------- appliers: server doc → local row (server wins; row becomes 'synced') ----------

String _s(Map<String, dynamic> d, String k) => (d[k] ?? '') as String;
String? _sn(Map<String, dynamic> d, String k) => d[k] as String?;
int _i(Map<String, dynamic> d, String k) => ((d[k] ?? 0) as num).toInt();
bool _b(Map<String, dynamic> d, String k) => d[k] == true;
Value<String?> _op(Map<String, dynamic> d) => Value(d['opId'] as String?);
const _synced = Value('synced');
Value<String?> _at(Map<String, dynamic> d) => Value(d['serverTime'] as String?);

final Map<String, _Apply> _appliers = {
  // Catalog first, so screens never show an id without its name.
  'license_type': (db, d) => db.into(db.licenseTypes).insertOnConflictUpdate(LicenseTypesCompanion.insert(
        id: d.id,
        name: _s(d.data, 'name'),
        active: Value(d.data['active'] != false),
        sortOrder: Value(_i(d.data, 'sortOrder')),
        serverSeq: Value(d.serverSeq),
      )),
  'car': (db, d) => db.into(db.cars).insertOnConflictUpdate(CarsCompanion.insert(
        id: d.id,
        name: _s(d.data, 'name'),
        plate: Value(_sn(d.data, 'plate')),
        active: Value(d.data['active'] != false),
        gearbox: Value(d.data['gearbox'] == 'auto' ? 'auto' : 'manual'),
        serverSeq: Value(d.serverSeq),
      )),
  'employee': (db, d) => db.into(db.employees).insertOnConflictUpdate(EmployeesCompanion.insert(
        id: d.id,
        name: _s(d.data, 'name'),
        role: _s(d.data, 'role'),
        active: Value(d.data['active'] != false),
        phone: Value(_sn(d.data, 'phone')),
        userId: Value(_sn(d.data, 'userId')),
        salary: Value(_i(d.data, 'salary')),
        serverSeq: Value(d.serverSeq),
      )),
  'car_instructor': (db, d) => db.into(db.carInstructors).insertOnConflictUpdate(CarInstructorsCompanion.insert(
        id: d.id,
        carId: _s(d.data, 'carId'),
        employeeId: _s(d.data, 'employeeId'),
        from: Value(_sn(d.data, 'from')),
        to: Value(_sn(d.data, 'to')),
        serverSeq: Value(d.serverSeq),
      )),
  'treasury_account': (db, d) => db.into(db.treasuryAccounts).insertOnConflictUpdate(TreasuryAccountsCompanion.insert(
        id: d.id,
        name: _s(d.data, 'name'),
        kind: _s(d.data, 'kind'),
        active: Value(d.data['active'] != false),
        openingBalance: Value(_i(d.data, 'openingBalance')),
        serverSeq: Value(d.serverSeq),
      )),
  'student': (db, d) => db.into(db.students).insertOnConflictUpdate(StudentsCompanion.insert(
        id: d.id,
        name: _s(d.data, 'name'),
        nationalId: _s(d.data, 'nationalId'),
        phone: Value(_sn(d.data, 'phone')),
        archived: Value(_b(d.data, 'archived')),
        opId: _op(d.data),
        syncState: _synced,
        serverSeq: Value(d.serverSeq),
        at: _at(d.data),
      )),
  'enrollment': (db, d) => db.into(db.enrollments).insertOnConflictUpdate(EnrollmentsCompanion.insert(
        id: d.id,
        studentId: _s(d.data, 'studentId'),
        studentName: _s(d.data, 'studentName'),
        licenseTypeId: _s(d.data, 'licenseTypeId'),
        carId: _s(d.data, 'carId'),
        stage: Value(_s(d.data, 'stage')),
        registeredOn: _s(d.data, 'registeredOn'),
        archived: Value(_b(d.data, 'archived')),
        graduatedOn: Value(_sn(d.data, 'graduatedOn')),
        withdrawReason: Value(_sn(d.data, 'withdrawReason')),
        finalSummaryJson: Value(d.data['finalSummary'] == null ? null : jsonEncode(d.data['finalSummary'])),
        plannedTheory: Value(d.data['plannedTheory'] == null ? null : _i(d.data, 'plannedTheory')),
        plannedPractical: Value(d.data['plannedPractical'] == null ? null : _i(d.data, 'plannedPractical')),
        opId: _op(d.data),
        syncState: _synced,
        serverSeq: Value(d.serverSeq),
        at: _at(d.data),
      )),
  'lesson': (db, d) => db.into(db.lessons).insertOnConflictUpdate(LessonsCompanion.insert(
        id: d.id,
        enrollmentId: _s(d.data, 'enrollmentId'),
        studentId: _s(d.data, 'studentId'),
        type: _s(d.data, 'type'),
        number: _i(d.data, 'number'),
        withoutDriving: Value(_b(d.data, 'withoutDriving')),
        employeeId: _s(d.data, 'employeeId'),
        carId: Value(_sn(d.data, 'carId')),
        startedAt: _s(d.data, 'startedAt'),
        businessDate: _s(d.data, 'businessDate'),
        archived: Value(_b(d.data, 'archived')),
        opId: _op(d.data),
        syncState: _synced,
        serverSeq: Value(d.serverSeq),
        at: _at(d.data),
      )),
  'student_ledger': (db, d) => db.into(db.ledgerEntries).insertOnConflictUpdate(LedgerEntriesCompanion.insert(
        id: d.id,
        enrollmentId: _s(d.data, 'enrollmentId'),
        studentId: _s(d.data, 'studentId'),
        kind: _s(d.data, 'kind'),
        amount: _i(d.data, 'amount'),
        accountId: Value(_sn(d.data, 'accountId')),
        purpose: Value(_sn(d.data, 'purpose')),
        receiptNo: Value(_sn(d.data, 'receiptNo')),
        lessonId: Value(_sn(d.data, 'lessonId')),
        reversesId: Value(_sn(d.data, 'reversesId')),
        reversed: Value(_b(d.data, 'reversed')),
        businessDate: _s(d.data, 'businessDate'),
        opId: _op(d.data),
        syncState: _synced,
        serverSeq: Value(d.serverSeq),
        at: _at(d.data),
      )),
  'treasury_movement': (db, d) => db.into(db.treasuryMovements).insertOnConflictUpdate(TreasuryMovementsCompanion.insert(
        id: d.id,
        accountId: _s(d.data, 'accountId'),
        direction: _s(d.data, 'direction'),
        amount: _i(d.data, 'amount'),
        kind: _s(d.data, 'kind'),
        refId: _s(d.data, 'refId'),
        businessDate: _s(d.data, 'businessDate'),
        note: Value(_sn(d.data, 'note')),
        opId: _op(d.data),
        syncState: _synced,
        serverSeq: Value(d.serverSeq),
        at: _at(d.data),
      )),
  'license_price': (db, d) => db.into(db.licensePrices).insertOnConflictUpdate(LicensePricesCompanion.insert(
        id: d.id,
        licenseTypeId: _s(d.data, 'licenseTypeId'),
        effectiveFrom: _s(d.data, 'effectiveFrom'),
        registrationFee: _i(d.data, 'registrationFee'),
        practicalLessonPrice: _i(d.data, 'practicalLessonPrice'),
        theoryRetakeFee: _i(d.data, 'theoryRetakeFee'),
        practicalExamFee: _i(d.data, 'practicalExamFee'),
        plannedTheoryLessons: Value(_i(d.data, 'plannedTheoryLessons')),
        plannedPracticalLessons: Value(_i(d.data, 'plannedPracticalLessons')),
        minTheoryBeforeExam: Value(_i(d.data, 'minTheoryBeforeExam')),
        minPracticalBeforeExam: Value(_i(d.data, 'minPracticalBeforeExam')),
        practicalAfterTheory: Value(d.data['practicalAfterTheory'] != false),
        opId: _op(d.data),
        syncState: _synced,
        serverSeq: Value(d.serverSeq),
        at: _at(d.data),
      )),
  'student_summary': (db, d) => db.into(db.studentSummaries).insertOnConflictUpdate(StudentSummariesCompanion.insert(
        enrollmentId: d.id,
        studentId: _s(d.data, 'studentId'),
        charged: Value(_i(d.data, 'charged')),
        paid: Value(_i(d.data, 'paid')),
        discounts: Value(_i(d.data, 'discounts')),
        theoryLessons: Value(_i(d.data, 'theoryLessons')),
        practicalLessons: Value(_i(d.data, 'practicalLessons')),
        serverSeq: Value(d.serverSeq),
      )),
  'expense': (db, d) => db.into(db.expenses).insertOnConflictUpdate(ExpensesCompanion.insert(
        id: d.id,
        kind: _s(d.data, 'kind'),
        item: _s(d.data, 'item'),
        label: _s(d.data, 'label'),
        carId: Value(_sn(d.data, 'carId')),
        liters: Value(d.data['liters'] == null ? null : _i(d.data, 'liters')),
        studentId: Value(_sn(d.data, 'studentId')),
        amount: _i(d.data, 'amount'),
        accountId: _s(d.data, 'accountId'),
        note: Value(_sn(d.data, 'note')),
        businessDate: _s(d.data, 'businessDate'),
        reversed: Value(_b(d.data, 'reversed')),
        opId: _op(d.data),
        syncState: _synced,
        serverSeq: Value(d.serverSeq),
        at: _at(d.data),
      )),
  'account_balance': (db, d) => db.into(db.accountBalances).insertOnConflictUpdate(AccountBalancesCompanion.insert(
        accountId: d.id,
        balance: _i(d.data, 'balance'),
        serverSeq: Value(d.serverSeq),
      )),
  'day_close': (db, d) => db.into(db.dayCloses).insertOnConflictUpdate(DayClosesCompanion.insert(
        id: d.id,
        state: _s(d.data, 'state'),
        mode: _s(d.data, 'mode'),
        closedByName: Value(_sn(d.data, 'closedByName')),
        diffs: Value(_i(d.data, 'diffs')),
        lateEntries: Value(_i(d.data, 'lateEntries')),
        reopenReason: Value(_sn(d.data, 'reopenReason')),
        opId: _op(d.data),
        syncState: _synced,
        serverSeq: Value(d.serverSeq),
        at: _at(d.data),
      )),
  'day_close_count': (db, d) => db.into(db.dayCloseCounts).insertOnConflictUpdate(DayCloseCountsCompanion.insert(
        id: d.id,
        businessDate: _s(d.data, 'businessDate'),
        accountId: _s(d.data, 'accountId'),
        expected: _i(d.data, 'expected'),
        counted: _i(d.data, 'counted'),
        diff: _i(d.data, 'diff'),
        reason: Value(_sn(d.data, 'reason')),
        opId: _op(d.data),
        syncState: _synced,
        serverSeq: Value(d.serverSeq),
        at: _at(d.data),
      )),
  'exam': (db, d) => db.into(db.exams).insertOnConflictUpdate(ExamsCompanion.insert(
        id: d.id,
        enrollmentId: _s(d.data, 'enrollmentId'),
        studentId: _s(d.data, 'studentId'),
        studentName: _s(d.data, 'studentName'),
        carId: Value(_sn(d.data, 'carId')),
        type: _s(d.data, 'type'),
        attempt: _i(d.data, 'attempt'),
        scheduledDate: _s(d.data, 'scheduledDate'),
        result: Value(_s(d.data, 'result')),
        fee: Value(_i(d.data, 'fee')),
        historyJson: Value(jsonEncode(d.data['history'] ?? const [])),
        opId: _op(d.data),
        syncState: _synced,
        serverSeq: Value(d.serverSeq),
        at: _at(d.data),
      )),
  'salary_rate': (db, d) => db.into(db.salaryRates).insertOnConflictUpdate(SalaryRatesCompanion.insert(
        id: d.id,
        employeeId: _s(d.data, 'employeeId'),
        effectiveFrom: _s(d.data, 'effectiveFrom'),
        monthlyAmount: _i(d.data, 'monthlyAmount'),
        serverSeq: Value(d.serverSeq),
      )),
  'payroll_item': (db, d) => db.into(db.payrollItems).insertOnConflictUpdate(PayrollItemsCompanion.insert(
        id: d.id,
        employeeId: _s(d.data, 'employeeId'),
        employeeName: _s(d.data, 'employeeName'),
        payrollMonth: _s(d.data, 'payrollMonth'),
        kind: _s(d.data, 'kind'),
        reason: _s(d.data, 'reason'),
        note: Value(_sn(d.data, 'note')),
        amount: _i(d.data, 'amount'),
        accountId: Value(_sn(d.data, 'accountId')),
        businessDate: _s(d.data, 'businessDate'),
        recordedByName: Value(_sn(d.data, 'recordedByName')),
        opId: _op(d.data),
        syncState: _synced,
        serverSeq: Value(d.serverSeq),
        at: _at(d.data),
      )),
  'salary_payment': (db, d) => db.into(db.salaryPayments).insertOnConflictUpdate(SalaryPaymentsCompanion.insert(
        id: d.id,
        employeeId: _s(d.data, 'employeeId'),
        employeeName: _s(d.data, 'employeeName'),
        payrollMonth: _s(d.data, 'payrollMonth'),
        salaryAtMonth: _i(d.data, 'salaryAtMonth'),
        bonuses: _i(d.data, 'bonuses'),
        deductions: _i(d.data, 'deductions'),
        advances: _i(d.data, 'advances'),
        net: _i(d.data, 'net'),
        accountId: _s(d.data, 'accountId'),
        businessDate: _s(d.data, 'businessDate'),
        early: Value(_b(d.data, 'early')),
        paidByName: Value(_sn(d.data, 'paidByName')),
        opId: _op(d.data),
        syncState: _synced,
        serverSeq: Value(d.serverSeq),
        at: _at(d.data),
      )),
  'user': (db, d) async {
    // Student logins are managed from the student profile; the users screen lists staff only.
    if (d.data['kind'] == 'student') return;
    await db.into(db.appUsers).insertOnConflictUpdate(AppUsersCompanion.insert(
          id: d.id,
          name: _s(d.data, 'name'),
          nationalId: _s(d.data, 'nationalId'),
          phone: Value(_sn(d.data, 'phone')),
          kind: _s(d.data, 'kind'),
          status: Value(_s(d.data, 'status').isEmpty ? 'active' : _s(d.data, 'status')),
          job: Value(_sn(d.data, 'job')),
          employeeId: Value(_sn(d.data, 'employeeId')),
          permissionsJson: Value(jsonEncode(d.data['permissions'] ?? const {})),
          permVersion: Value(d.data['permVersion'] == null ? 1 : _i(d.data, 'permVersion')),
          opId: _op(d.data),
          syncState: _synced,
          serverSeq: Value(d.serverSeq),
          at: _at(d.data),
        ));
  },
  'activity_log': (db, d) => db.into(db.activityLogs).insertOnConflictUpdate(ActivityLogsCompanion.insert(
        id: d.id,
        opType: _s(d.data, 'opType'),
        entity: _s(d.data, 'entity'),
        recordId: _s(d.data, 'recordId'),
        recordLabel: _s(d.data, 'recordLabel'),
        changesJson: Value(jsonEncode(d.data['changes'] ?? const [])),
        reason: Value(_sn(d.data, 'reason')),
        actorId: _s(d.data, 'actorId'),
        actorName: _s(d.data, 'actorName'),
        deviceId: Value(_sn(d.data, 'deviceId')),
        opId: Value(_sn(d.data, 'opId')),
        at: _s(d.data, 'serverTime'),
        lateAfterClose: Value(_b(d.data, 'lateAfterClose')),
        serverSeq: Value(d.serverSeq),
      )),
  'month_lock': (db, d) => db.into(db.monthLocks).insertOnConflictUpdate(MonthLocksCompanion.insert(
        id: d.id,
        locked: Value(d.data['locked'] != false),
        lockedByName: Value(_sn(d.data, 'lockedByName')),
        unlockReason: Value(_sn(d.data, 'unlockReason')),
        serverSeq: Value(d.serverSeq),
      )),
  'setting': (db, d) => db.into(db.settings).insertOnConflictUpdate(SettingsCompanion.insert(
        key: d.id,
        valueJson: jsonEncode(d.data['value']),
        serverSeq: Value(d.serverSeq),
      )),
};

/// Collections this person may pull (firestore.rules refuse the others, which would stop the whole pull).
/// Instructors and students pull scoped queries (see FirestoreChangeSource.scope).
List<String> pullCollectionsFor({required String kind, required bool Function(String task) can, bool logAll = false}) {
  final admin = kind == 'admin';
  final staff = kind == 'staff';
  final instructor = kind == 'instructor';
  final student = kind == 'student';
  final allowed = <String, bool>{
    'license_type': true,
    'car': true,
    'employee': !student,
    'car_instructor': !student,
    'treasury_account': admin || (staff && can('seeMoney')),
    'student': admin || staff || student,
    'enrollment': true,
    'lesson': true,
    'student_ledger': admin || student || (staff && can('seeMoney')),
    'treasury_movement': admin || (staff && can('cashbook')),
    'license_price': admin || (staff && can('seeMoney')),
    'student_summary': admin || student || (staff && can('seeMoney')),
    'expense': admin || (staff && (can('seeExp') || can('addExp'))),
    'account_balance': admin || (staff && can('seeBal')),
    'day_close': admin || (staff && can('closeDay')),
    'day_close_count': admin || (staff && can('closeDay')),
    'exam': true,
    'salary_rate': admin || (staff && can('payroll')),
    'payroll_item': admin || (staff && can('payroll')),
    'salary_payment': admin || (staff && can('payroll')),
    'user': admin || (staff && can('users')),
    // "Own actions only" needs a query filtered by actor; until then only the full log is pulled.
    'activity_log': admin || (staff && can('log') && logAll),
    'month_lock': !student,
    'setting': true,
  };
  if (instructor) allowed['student'] = false;
  return [for (final c in _appliers.keys) if (allowed[c] == true) c];
}
