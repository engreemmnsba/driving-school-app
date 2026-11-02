import 'package:drift/drift.dart';

/// Columns every synced table carries (docs/04 conventions).
mixin SyncColumns on Table {
  /// The op that created/changed this row (links local rows to outbox results).
  TextColumn get opId => text().nullable()();

  /// pending | synced | rejected
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  IntColumn get serverSeq => integer().nullable()();

  /// When it happened (ISO-8601): device time while pending, server time once synced.
  TextColumn get at => text().nullable()();
}

@DataClassName('StudentRow')
class Students extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get nationalId => text()();
  TextColumn get phone => text().nullable()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EnrollmentRow')
class Enrollments extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get studentId => text()();

  /// Denormalized so instructors never need the student doc (national ID, phone).
  TextColumn get studentName => text()();
  TextColumn get licenseTypeId => text()();
  TextColumn get carId => text()();

  /// theory | practical | ready_practical (legacy) | passed (practical passed, not graduated yet) | graduated | withdrawn
  TextColumn get stage => text().withDefault(const Constant('theory'))();
  TextColumn get registeredOn => text()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  TextColumn get graduatedOn => text().nullable()();
  TextColumn get withdrawReason => text().nullable()();

  /// JSON {charged, paid, discounts, theoryLessons, practicalLessons} written at graduation.
  TextColumn get finalSummaryJson => text().nullable()();

  /// Planned lesson counts copied from the price at registration (instructors can't read prices).
  IntColumn get plannedTheory => integer().nullable()();
  IntColumn get plannedPractical => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LessonRow')
class Lessons extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get enrollmentId => text()();
  TextColumn get studentId => text()();

  /// theory | practical
  TextColumn get type => text()();

  /// Provisional on the phone until the server assigns the final number.
  IntColumn get number => integer()();
  BoolColumn get withoutDriving => boolean().withDefault(const Constant(false))();
  TextColumn get employeeId => text()();
  TextColumn get carId => text().nullable()();
  TextColumn get startedAt => text()();
  TextColumn get businessDate => text()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Student money (charges, payments, discounts, reversals). Amounts are positive agorot; kind decides direction.
@DataClassName('LedgerRowData')
class LedgerEntries extends Table with SyncColumns {
  @override
  String get tableName => 'student_ledger';

  TextColumn get id => text()();
  TextColumn get enrollmentId => text()();
  TextColumn get studentId => text()();

  /// registration_fee | lesson_charge | exam_fee | retake_fee | payment | discount | reversal (of a payment) | charge_reversal
  TextColumn get kind => text()();
  IntColumn get amount => integer()();
  TextColumn get accountId => text().nullable()();
  TextColumn get purpose => text().nullable()();
  TextColumn get receiptNo => text().nullable()();
  TextColumn get lessonId => text().nullable()();
  TextColumn get reversesId => text().nullable()();
  BoolColumn get reversed => boolean().withDefault(const Constant(false))();
  TextColumn get businessDate => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MovementRow')
class TreasuryMovements extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get accountId => text()();

  /// in | out
  TextColumn get direction => text()();
  IntColumn get amount => integer()();
  TextColumn get kind => text()();
  TextColumn get refId => text()();
  TextColumn get businessDate => text()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LicensePriceRow')
class LicensePrices extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get licenseTypeId => text()();
  TextColumn get effectiveFrom => text()();
  IntColumn get registrationFee => integer()();
  IntColumn get practicalLessonPrice => integer()();
  IntColumn get theoryRetakeFee => integer()();
  IntColumn get practicalExamFee => integer()();
  IntColumn get plannedTheoryLessons => integer().withDefault(const Constant(0))();
  IntColumn get plannedPracticalLessons => integer().withDefault(const Constant(0))();
  IntColumn get minTheoryBeforeExam => integer().withDefault(const Constant(0))();
  IntColumn get minPracticalBeforeExam => integer().withDefault(const Constant(0))();
  BoolColumn get practicalAfterTheory => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Server-maintained summary per enrollment (docs/05 §8).
@DataClassName('StudentSummaryRow')
class StudentSummaries extends Table {
  TextColumn get enrollmentId => text()();
  TextColumn get studentId => text()();
  IntColumn get charged => integer().withDefault(const Constant(0))();
  IntColumn get paid => integer().withDefault(const Constant(0))();
  IntColumn get discounts => integer().withDefault(const Constant(0))();
  IntColumn get theoryLessons => integer().withDefault(const Constant(0))();
  IntColumn get practicalLessons => integer().withDefault(const Constant(0))();

  /// Summary reflects every server change up to this sequence.
  IntColumn get serverSeq => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {enrollmentId};
}

/// Pending operations, sent in deviceSeq order.
@DataClassName('OutboxOpRow')
class OutboxOps extends Table {
  TextColumn get opId => text()();
  TextColumn get type => text()();
  TextColumn get payloadJson => text()();
  IntColumn get deviceSeq => integer().unique()();
  TextColumn get deviceTime => text()();
  TextColumn get userId => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {opId};
}

/// Ops the server refused — kept visible with the reason, never silently lost.
@DataClassName('RejectedOpRow')
class RejectedOps extends Table {
  TextColumn get opId => text()();
  TextColumn get type => text()();
  TextColumn get payloadJson => text()();
  TextColumn get reason => text()();
  TextColumn get message => text()();
  TextColumn get rejectedAt => text()();

  @override
  Set<Column> get primaryKey => {opId};
}

@DataClassName('SyncCursorRow')
class SyncCursors extends Table {
  TextColumn get collection => text()();
  IntColumn get lastSeq => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {collection};
}

/// Small key/value store: session, device seq counter, receipt counter, clock offset.
@DataClassName('KvRow')
class KvEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// ---------- catalog (pulled from the server, read-only on the phone) ----------

@DataClassName('CarRow')
class Cars extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get plate => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  IntColumn get serverSeq => integer().nullable()();

  /// manual | auto
  TextColumn get gearbox => text().withDefault(const Constant('manual'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Which instructor drives which car, from a date (to = null → current).
@DataClassName('CarInstructorRow')
class CarInstructors extends Table {
  TextColumn get id => text()();
  TextColumn get carId => text()();
  TextColumn get employeeId => text()();
  TextColumn get from => text().named('from_date').nullable()();
  TextColumn get to => text().named('to_date').nullable()();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EmployeeRow')
class Employees extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// instructor | staff
  TextColumn get role => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  IntColumn get serverSeq => integer().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get userId => text().nullable()();

  /// Current monthly salary (agorot); past months use [SalaryRates].
  IntColumn get salary => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LicenseTypeRow')
class LicenseTypes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TreasuryAccountRow')
class TreasuryAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// cash | wallet | bank
  TextColumn get kind => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  IntColumn get openingBalance => integer().withDefault(const Constant(0))();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------- money (batch 2) ----------

@DataClassName('ExpenseRow')
class Expenses extends Table with SyncColumns {
  TextColumn get id => text()();

  /// cars | ministry | other  (salaries and advances live in Payroll)
  TextColumn get kind => text()();
  TextColumn get item => text()();
  TextColumn get label => text()();
  TextColumn get carId => text().nullable()();
  IntColumn get liters => integer().nullable()();
  TextColumn get studentId => text().nullable()();
  IntColumn get amount => integer()();
  TextColumn get accountId => text()();
  TextColumn get note => text().nullable()();
  TextColumn get businessDate => text()();
  BoolColumn get reversed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Server-maintained balance per account; shown = this + movements newer than it (like student summaries).
@DataClassName('AccountBalanceRow')
class AccountBalances extends Table {
  TextColumn get accountId => text()();
  IntColumn get balance => integer()();
  IntColumn get serverSeq => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {accountId};
}

@DataClassName('DayCloseRow')
class DayCloses extends Table with SyncColumns {
  /// = businessDate
  TextColumn get id => text()();

  /// closed | reopened
  TextColumn get state => text()();

  /// blind | full
  TextColumn get mode => text()();
  TextColumn get closedByName => text().nullable()();
  IntColumn get diffs => integer().withDefault(const Constant(0))();
  IntColumn get lateEntries => integer().withDefault(const Constant(0))();
  TextColumn get reopenReason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DayCloseCountRow')
class DayCloseCounts extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get businessDate => text()();
  TextColumn get accountId => text()();
  IntColumn get expected => integer()();
  IntColumn get counted => integer()();
  IntColumn get diff => integer()();
  TextColumn get reason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------- exams (batch 3) ----------

@DataClassName('ExamRow')
class Exams extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get enrollmentId => text()();
  TextColumn get studentId => text()();
  TextColumn get studentName => text()();
  TextColumn get carId => text().nullable()();

  /// theory | theory_retake | practical
  TextColumn get type => text()();
  IntColumn get attempt => integer()();
  TextColumn get scheduledDate => text()();

  /// pending | passed | failed | absent
  TextColumn get result => text().withDefault(const Constant('pending'))();
  IntColumn get fee => integer().withDefault(const Constant(0))();

  /// JSON list of postponements [{from, to, reason, details, by}]
  TextColumn get historyJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------- staff (batch 4) ----------

/// Monthly salary versions: the salary of a payroll month = latest effectiveFrom <= month.
@DataClassName('SalaryRateRow')
class SalaryRates extends Table {
  TextColumn get id => text()();
  TextColumn get employeeId => text()();

  /// YYYY-MM
  TextColumn get effectiveFrom => text()();
  IntColumn get monthlyAmount => integer()();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Advance (money out now) · deduction · bonus, always on one payroll month (the month worked).
@DataClassName('PayrollItemRow')
class PayrollItems extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get employeeId => text()();
  TextColumn get employeeName => text()();

  /// YYYY-MM
  TextColumn get payrollMonth => text()();

  /// advance | deduction | bonus
  TextColumn get kind => text()();
  TextColumn get reason => text()();
  TextColumn get note => text().nullable()();
  IntColumn get amount => integer()();
  TextColumn get accountId => text().nullable()();
  TextColumn get businessDate => text()();
  TextColumn get recordedByName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SalaryPaymentRow')
class SalaryPayments extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get employeeId => text()();
  TextColumn get employeeName => text()();
  TextColumn get payrollMonth => text()();
  IntColumn get salaryAtMonth => integer()();
  IntColumn get bonuses => integer()();
  IntColumn get deductions => integer()();
  IntColumn get advances => integer()();
  IntColumn get net => integer()();
  TextColumn get accountId => text()();
  TextColumn get businessDate => text()();
  BoolColumn get early => boolean().withDefault(const Constant(false))();
  TextColumn get paidByName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Logins of the school (Admin / user managers only). Students are not listed here.
@DataClassName('AppUserRow')
class AppUsers extends Table with SyncColumns {
  @override
  String get tableName => 'app_users';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get nationalId => text()();
  TextColumn get phone => text().nullable()();

  /// admin | staff | instructor | student
  TextColumn get kind => text()();

  /// active | disabled
  TextColumn get status => text().withDefault(const Constant('active'))();

  /// accountant | secretary | instructor | manager
  TextColumn get job => text().nullable()();
  TextColumn get employeeId => text().nullable()();

  /// JSON {tasks, allowedAccounts, expenseCategories, discountMax, closeMode, logScope, backdateDays}
  TextColumn get permissionsJson => text().withDefault(const Constant('{}'))();
  IntColumn get permVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------- oversight (batch 5) ----------

/// "Who changed what from A to B" — written by the server for every accepted op, never edited.
@DataClassName('ActivityRow')
class ActivityLogs extends Table {
  TextColumn get id => text()();

  /// create | edit | archive | restore | postpone | settings | permission | close | reopen
  TextColumn get opType => text()();
  TextColumn get entity => text()();
  TextColumn get recordId => text()();
  TextColumn get recordLabel => text()();

  /// JSON [{field, old, new}]
  TextColumn get changesJson => text().withDefault(const Constant('[]'))();
  TextColumn get reason => text().nullable()();
  TextColumn get actorId => text()();
  TextColumn get actorName => text()();
  TextColumn get deviceId => text().nullable()();
  TextColumn get opId => text().nullable()();

  /// Server time (ISO-8601).
  TextColumn get at => text()();
  BoolColumn get lateAfterClose => boolean().withDefault(const Constant(false))();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A locked accounting month (nothing dated in it can change). locked=false after "فتح الشهر".
@DataClassName('MonthLockRow')
class MonthLocks extends Table {
  /// YYYY-MM
  TextColumn get id => text()();
  BoolColumn get locked => boolean().withDefault(const Constant(true))();
  TextColumn get lockedByName => text().nullable()();
  TextColumn get unlockReason => text().nullable()();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------- settings (batch 6) ----------

/// General settings from the server (key → JSON value): school, lessonDurationMin, closeReminderHour,
/// overdueAmount, overdueDays, salaryDueDay, withoutDrivingEnabled.
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get valueJson => text()();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}
