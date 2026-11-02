import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:driving_school/core/db/database.dart';
import 'package:driving_school/core/sync/outbox.dart';
import 'package:driving_school/data/queries.dart';
import 'package:driving_school/features/exams/exam_actions.dart';
import 'package:driving_school/features/students/student_actions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_db.dart';

void main() {
  late AppDatabase db;
  late ExamActions exams;

  setUp(() async {
    db = memoryDb();
    exams = ExamActions(db, Outbox(db, testSession));
    await db.into(db.licensePrices).insert(LicensePricesCompanion.insert(
        id: 'pr', licenseTypeId: 'lt', effectiveFrom: '2026-01-01', registrationFee: 50000, practicalLessonPrice: 12000,
        theoryRetakeFee: 8000, practicalExamFee: 10000, minTheoryBeforeExam: const Value(2), minPracticalBeforeExam: const Value(3)));
    await db.into(db.enrollments).insert(EnrollmentsCompanion.insert(
        id: 'en1', studentId: 'st1', studentName: 'أحمد خالد', licenseTypeId: 'lt', carId: 'car1', registeredOn: '2026-10-01', syncState: const Value('synced')));
    await db.into(db.treasuryAccounts).insert(TreasuryAccountsCompanion.insert(id: 'cash', name: 'كاش', kind: 'cash'));
  });
  tearDown(() => db.close());

  Future<void> lessons(int n, String type) async {
    for (var i = 0; i < n; i++) {
      await db.into(db.lessons).insert(LessonsCompanion.insert(
          id: '$type$i', enrollmentId: 'en1', studentId: 'st1', type: type, number: i + 1, employeeId: 'e', startedAt: '2026-10-19T08:00:00Z', businessDate: '2026-10-19'));
    }
  }

  test('first theory exam: free, needs the minimum (same rules as the server)', () async {
    await expectLater(exams.book(enrollmentId: 'en1', scheduledDate: '2026-10-30', businessDate: '2026-10-19'), throwsA(isA<ActionError>()));
    await lessons(2, 'theory');
    final plan = await examPlan(db, 'en1', '2026-10-19');
    expect((plan!.type, plan.attempt, plan.fee.agorot, plan.reachedMinimum), ('theory', 1, 0, true));
    await exams.book(enrollmentId: 'en1', scheduledDate: '2026-10-30', businessDate: '2026-10-19');
    expect(await db.select(db.expenses).get(), isEmpty);
    final card = await Queries(db).studentCard('en1');
    expect(card!.pendingExam, isNotNull);
    expect(card.readyForExam, isFalse); // already booked
  });

  test('practical exam: charge + ministry expense + money out, then pass → graduate', () async {
    await (db.update(db.enrollments)..where((t) => t.id.equals('en1'))).write(const EnrollmentsCompanion(stage: Value('practical')));
    await lessons(3, 'practical');
    final id = await exams.book(enrollmentId: 'en1', scheduledDate: '2026-10-19', accountId: 'cash', businessDate: '2026-10-19');
    expect((await db.select(db.ledgerEntries).getSingle()).kind, 'exam_fee');
    expect((await db.select(db.expenses).getSingle()).kind, 'ministry');
    expect((await db.select(db.treasuryMovements).getSingle()).direction, 'out');
    await exams.result(id, 'passed');
    expect((await Queries(db).studentCard('en1'))!.passedPractical, isTrue);
    final ops = (await db.select(db.outboxOps).get()).map((o) => o.type).toList();
    expect(ops, ['exam.book', 'exam.result']);
  });

  test('theory lessons switched off: no theory lesson button, theory exam ready at once (same as the server)', () async {
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'theoryLessonsEnabled', valueJson: 'false'));
    final card = (await Queries(db).studentCard('en1'))!;
    expect((card.canLesson, card.readyForExam, card.minForExam, card.counter), (false, true, 0, ''));
    final plan = await examPlan(db, 'en1', '2026-10-19');
    expect(plan!.reachedMinimum, isTrue);
    await exams.book(enrollmentId: 'en1', scheduledDate: '2026-10-30', businessDate: '2026-10-19');
    await (db.update(db.enrollments)..where((t) => t.id.equals('en1'))).write(const EnrollmentsCompanion(stage: Value('practical')));
    expect((await Queries(db).studentCard('en1'))!.canLesson, isTrue); // practical as usual
  });
}
