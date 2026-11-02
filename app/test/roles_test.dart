import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:driving_school/core/db/database.dart';
import 'package:driving_school/core/sync/outbox.dart';
import 'package:driving_school/core/sync/puller.dart';
import 'package:driving_school/core/util/dates.dart';
import 'package:driving_school/data/role_queries.dart';
import 'package:driving_school/features/students/student_actions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_db.dart';

void main() {
  late AppDatabase db;
  late Outbox outbox;
  late RoleQueries q;

  setUp(() async {
    db = memoryDb();
    outbox = Outbox(db, testSession);
    q = RoleQueries(db);
    await db.into(db.cars).insert(CarsCompanion.insert(id: 'car1', name: 'سيارة 1'));
    await db.into(db.cars).insert(CarsCompanion.insert(id: 'car2', name: 'سيارة 2'));
    await db.into(db.licenseTypes).insert(LicenseTypesCompanion.insert(id: 'lt', name: 'خصوصي'));
    Future<void> enr(String id, String name, String car, String stage) => db.into(db.enrollments).insert(EnrollmentsCompanion.insert(
        id: id, studentId: 's_$id', studentName: name, licenseTypeId: 'lt', carId: car, stage: Value(stage), registeredOn: '2026-09-01',
        plannedTheory: const Value(8), plannedPractical: const Value(10), syncState: const Value('synced')));
    await enr('e1', 'أحمد خالد', 'car1', 'practical');
    await enr('e2', 'سارة يوسف', 'car2', 'practical');
    await enr('e3', 'نور حسن', 'car1', 'theory');
  });
  tearDown(() => db.close());

  test('instructors pull scoped data only (no money, no student docs)', () {
    final c = pullCollectionsFor(kind: 'instructor', can: (k) => k == 'students' || k == 'lesson');
    expect(c, containsAll(['enrollment', 'lesson', 'exam', 'car_instructor', 'setting']));
    expect(c, isNot(contains('student')));
    expect(c, isNot(contains('student_ledger')));
    expect(c, isNot(contains('license_price')));
    final s = pullCollectionsFor(kind: 'student', can: (_) => false);
    expect(s, containsAll(['student', 'student_ledger', 'student_summary', 'enrollment']));
    expect(s, isNot(contains('employee')));
  });

  test('an instructor sees only the students of their cars, with counters', () async {
    final d = await q.instructorHome(employeeId: 'emp_m', carIds: ['car1']);
    expect(d.cards.map((c) => c.name), ['أحمد خالد', 'نور حسن']);
    expect(d.cards.first.counter, '0/10');
    expect(d.cards.last.kindLabel, 'نظري');
  });

  test('logging without prices, one running lesson at a time, end now', () async {
    final r = await LogLesson(db, outbox, testSession)('e1', businessDate: todayStr(), employeeId: 'emp_m', withMoney: false);
    expect(r.number, 1);
    expect(await db.select(db.ledgerEntries).get(), isEmpty); // the server charges it
    var d = await q.instructorHome(employeeId: 'emp_m', carIds: ['car1']);
    expect(d.myRunning?.id, r.lessonId);
    expect(d.myRunningStudent, 'أحمد خالد');
    expect(d.cards.first.running?.id, r.lessonId);
    expect(d.lessonsToday, 1);
    await q.endLesson(r.lessonId);
    d = await q.instructorHome(employeeId: 'emp_m', carIds: ['car1']);
    expect(d.myRunning, isNull);
  });

  test('student home: own enrollment, lessons, payments', () async {
    await db.into(db.ledgerEntries).insert(LedgerEntriesCompanion.insert(id: 'p1', enrollmentId: 'e1', studentId: 's_e1', kind: 'payment', amount: 50000, businessDate: '2026-10-01', receiptNo: const Value('1-0001')));
    final d = await q.studentHome('s_e1');
    expect(d!.enrollment.id, 'e1');
    expect(d.payments.single.receiptNo, '1-0001');
    expect(d.theoryPassed, isTrue); // already in practical
    expect(await q.studentHome('nobody'), isNull);
  });
}
