import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Students,
  Enrollments,
  Lessons,
  LedgerEntries,
  TreasuryMovements,
  LicensePrices,
  StudentSummaries,
  OutboxOps,
  RejectedOps,
  SyncCursors,
  KvEntries,
  Cars,
  CarInstructors,
  Employees,
  LicenseTypes,
  TreasuryAccounts,
  Expenses,
  AccountBalances,
  DayCloses,
  DayCloseCounts,
  Exams,
  SalaryRates,
  PayrollItems,
  SalaryPayments,
  AppUsers,
  ActivityLogs,
  MonthLocks,
  Settings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Android: SQLite file in app-private storage. Web: sqlite3 WASM (assets in web/).
  /// One database per signed-in user, so people sharing a phone never see each other's data.
  factory AppDatabase.open({String name = 'driving_school'}) => AppDatabase(
        driftDatabase(
          name: name,
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Batch 1: catalog tables, "at" time on synced rows, lesson plan fields on prices.
            await m.createTable(cars);
            await m.createTable(carInstructors);
            await m.createTable(employees);
            await m.createTable(licenseTypes);
            await m.createTable(treasuryAccounts);
            await m.addColumn(students, students.at);
            await m.addColumn(enrollments, enrollments.at);
            await m.addColumn(lessons, lessons.at);
            await m.addColumn(ledgerEntries, ledgerEntries.at);
            await m.addColumn(treasuryMovements, treasuryMovements.at);
            await m.addColumn(licensePrices, licensePrices.at);
            await m.addColumn(licensePrices, licensePrices.plannedTheoryLessons);
            await m.addColumn(licensePrices, licensePrices.plannedPracticalLessons);
            await m.addColumn(licensePrices, licensePrices.minTheoryBeforeExam);
            await m.addColumn(licensePrices, licensePrices.minPracticalBeforeExam);
            await m.addColumn(licensePrices, licensePrices.practicalAfterTheory);
          }
          if (from < 3) {
            // Batch 2: money.
            await m.createTable(expenses);
            await m.createTable(accountBalances);
            await m.createTable(dayCloses);
            await m.createTable(dayCloseCounts);
            await m.addColumn(treasuryMovements, treasuryMovements.note);
            // From v1 the accounts table was just created with the current columns.
            if (from == 2) await m.addColumn(treasuryAccounts, treasuryAccounts.openingBalance);
          }
          if (from < 4) {
            // Batch 3: exams + enrollment outcome fields.
            await m.createTable(exams);
            await m.addColumn(enrollments, enrollments.graduatedOn);
            await m.addColumn(enrollments, enrollments.withdrawReason);
            await m.addColumn(enrollments, enrollments.finalSummaryJson);
          }
          if (from < 5) {
            // Batch 4: staff, payroll, users.
            await m.createTable(salaryRates);
            await m.createTable(payrollItems);
            await m.createTable(salaryPayments);
            await m.createTable(appUsers);
            // From v1 these catalog tables were just created with the current columns.
            if (from >= 2) {
              await m.addColumn(cars, cars.gearbox);
              await m.addColumn(employees, employees.phone);
              await m.addColumn(employees, employees.userId);
              await m.addColumn(employees, employees.salary);
            }
          }
          if (from < 6) {
            // Batch 5: activity log + month locks.
            await m.createTable(activityLogs);
            await m.createTable(monthLocks);
          }
          if (from < 7) {
            // Batch 6: settings. Batch 7: planned lesson counts on enrollments.
            await m.createTable(settings);
            await m.addColumn(enrollments, enrollments.plannedTheory);
            await m.addColumn(enrollments, enrollments.plannedPractical);
          }
          // Re-pull everything once so new tables and fields are filled.
          await delete(syncCursors).go();
        },
        onCreate: (m) async {
          await m.createAll();
        },
        // Every open (IF NOT EXISTS = no-op when present): phones upgraded from older versions get new indexes too.
        beforeOpen: (_) => _indexes(),
      );

  /// Indexes used by screens (docs/04). IF NOT EXISTS: safe on every create/upgrade.
  Future<void> _indexes() async {
    for (final sql in const [
      'CREATE INDEX IF NOT EXISTS idx_lesson_enr ON lessons (enrollment_id, started_at)',
      'CREATE INDEX IF NOT EXISTS idx_lesson_day ON lessons (business_date)',
      'CREATE INDEX IF NOT EXISTS idx_ledger_enr ON student_ledger (enrollment_id, business_date)',
      'CREATE INDEX IF NOT EXISTS idx_exam_enr ON exams (enrollment_id)',
      'CREATE INDEX IF NOT EXISTS idx_mov_acc ON treasury_movements (account_id, business_date)',
      'CREATE INDEX IF NOT EXISTS idx_mov_day ON treasury_movements (business_date)',
      'CREATE INDEX IF NOT EXISTS idx_payroll_emp ON payroll_items (employee_id, payroll_month)',
      'CREATE INDEX IF NOT EXISTS idx_log_at ON activity_logs (at)',
    ]) {
      await customStatement(sql);
    }
  }

  /// Tables whose rows carry opId/syncState (updated when an op's result arrives).
  List<TableInfo<Table, Object?>> get syncedTables =>
      [students, enrollments, lessons, ledgerEntries, treasuryMovements, expenses, dayCloses, dayCloseCounts, exams, payrollItems, salaryPayments, appUsers];

  /// Sign-out (A4): removes everything this user pulled or typed from the phone. Keeps only the
  /// device identity and counters, so receipt numbers and op order never repeat on this device.
  /// Callers make sure nothing is waiting to sync first.
  Future<void> wipeUserData() => transaction(() async {
        for (final t in allTables) {
          if (t != kvEntries) await delete(t).go();
        }
        await (delete(kvEntries)..where((k) => k.key.isNotIn(const ['deviceId', 'deviceCode', 'receiptCounter', 'deviceSeq']))).go();
      });

  // ---------- key/value ----------
  Future<String?> kvGet(String key) async {
    final row = await (select(kvEntries)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> kvSet(String key, String value) =>
      into(kvEntries).insertOnConflictUpdate(KvEntriesCompanion.insert(key: key, value: value));

  /// Atomically increments an integer counter stored in kv and returns the new value.
  Future<int> kvNext(String key) async {
    final current = int.tryParse(await kvGet(key) ?? '') ?? 0;
    final next = current + 1;
    await kvSet(key, '$next');
    return next;
  }
}
