import 'package:drift/drift.dart';

import '../core/db/database.dart';
import '../core/domain/ledger.dart';
import '../core/util/dates.dart';
import '../features/money/record_payment.dart' show localBalance;
import 'settings_queries.dart';

Expression<bool> _ok(GeneratedColumn<String> s) => s.equals('rejected').not();

// ---------------------------------------------------------------- instructor

class InstructorCard {
  const InstructorCard({
    required this.enrollment,
    required this.meta,
    required this.theoryDone,
    required this.practicalDone,
    required this.running,
  });
  final EnrollmentRow enrollment;

  /// "خصوصي · عادي"
  final String meta;
  final int theoryDone;
  final int practicalDone;

  /// This student's lesson that is running now (any instructor on the car).
  final LessonRow? running;

  String get name => enrollment.studentName;
  bool get inTheory => enrollment.stage == 'theory';
  String get kindLabel => inTheory ? 'نظري' : 'عملي';
  int get done => inTheory ? theoryDone : practicalDone;

  /// null when the plan isn't known on this phone (older registrations).
  int? get planned => inTheory ? enrollment.plannedTheory : enrollment.plannedPractical;
  bool get beyondPlan => planned != null && done >= planned!;
  int get next => done + 1;
  String get counter => planned == null ? '$done' : '$done/$planned';
}

class InstructorHomeData {
  const InstructorHomeData({required this.cards, required this.myRunning, required this.myRunningStudent, required this.lessonsToday, required this.lessonMinutes, required this.withoutDriving, required this.todayRows});
  final List<InstructorCard> cards;

  /// My lesson that is running now (one at a time, D4).
  final LessonRow? myRunning;
  final String? myRunningStudent;
  final int lessonsToday;
  final int lessonMinutes;
  final bool withoutDriving;
  final List<(LessonRow, String)> todayRows;
}

// ---------------------------------------------------------------- student

class StudentHomeData {
  const StudentHomeData({
    required this.enrollment,
    required this.licenseName,
    required this.theoryDone,
    required this.practicalDone,
    required this.balance,
    required this.exams,
    required this.lessons,
    required this.payments,
    this.charges = const [],
  });
  final EnrollmentRow enrollment;
  final String licenseName;
  final int theoryDone;
  final int practicalDone;
  final StudentBalance balance;
  final List<ExamRow> exams;
  final List<LessonRow> lessons;
  final List<LedgerRowData> payments;

  /// Fees and discounts (lesson charges are summed, not listed one by one).
  final List<LedgerRowData> charges;

  /// Latest exam with a result (for the banner after a failed attempt).
  ExamRow? get lastResult => exams.where((e) => e.result != 'pending').firstOrNull;

  bool get theoryPassed => exams.any((e) => e.type != 'practical' && e.result == 'passed') || !['theory'].contains(enrollment.stage);
  ExamRow? get pendingExam => exams.where((e) => e.result == 'pending').firstOrNull;
}

class RoleQueries {
  RoleQueries(this.db);
  final AppDatabase db;

  Future<Set<String>> endedLessons() async => (await db.kvGet('endedLessons') ?? '').split(',').where((s) => s.isNotEmpty).toSet();

  /// "إنهاء الدرس الآن": the lesson stops counting down on this phone (lessons have no end time on the server).
  Future<void> endLesson(String lessonId) async {
    final ended = [...await endedLessons(), lessonId];
    await db.kvSet('endedLessons', ended.reversed.take(50).join(','));
  }

  Future<InstructorHomeData> instructorHome({required String? employeeId, required List<String> carIds}) async {
    final settings = SettingsQueries(db);
    final minutes = await settings.intOf('lessonDurationMin');
    final withoutDriving = await settings.boolOf('withoutDrivingEnabled');
    final theoryLessons = await settings.boolOf('theoryLessonsEnabled');
    final stages = [if (theoryLessons) 'theory', 'practical', 'ready_practical'];
    final now = DateTime.now();
    final today = todayStr();
    final ended = await endedLessons();
    final cars = {for (final c in await db.select(db.cars).get()) c.id: c};
    final licenses = {for (final l in await db.select(db.licenseTypes).get()) l.id: l.name};
    final enrollments = carIds.isEmpty
        ? <EnrollmentRow>[]
        : await (db.select(db.enrollments)
              ..where((t) => t.carId.isIn(carIds) & t.archived.equals(false) & t.stage.isIn(stages) & _ok(t.syncState))
              ..orderBy([(t) => OrderingTerm.asc(t.studentName)]))
            .get();
    bool isRunning(LessonRow l) {
      final start = DateTime.tryParse(l.startedAt);
      return start != null && !ended.contains(l.id) && !now.isBefore(start) && now.difference(start).inMinutes < minutes;
    }

    final todayLessons = await (db.select(db.lessons)
          ..where((t) => t.businessDate.equals(today) & t.archived.equals(false) & _ok(t.syncState))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
    final cards = <InstructorCard>[];
    for (final e in enrollments) {
      final lessons = await (db.select(db.lessons)..where((t) => t.enrollmentId.equals(e.id) & t.archived.equals(false) & _ok(t.syncState))).get();
      final car = cars[e.carId];
      cards.add(InstructorCard(
        enrollment: e,
        meta: [licenses[e.licenseTypeId] ?? '', if (car != null) car.gearbox == 'auto' ? 'أوتوماتيك' : 'عادي', ?car?.name].where((x) => x.isNotEmpty).join(' · '),
        theoryDone: lessons.where((l) => l.type == 'theory').length,
        practicalDone: lessons.where((l) => l.type == 'practical').length,
        running: todayLessons.where((l) => l.enrollmentId == e.id && isRunning(l)).firstOrNull,
      ));
    }
    // Running lessons first, then by name.
    cards.sort((a, b) => (a.running == null ? 1 : 0).compareTo(b.running == null ? 1 : 0));
    final mine = todayLessons.where((l) => l.employeeId == employeeId).toList();
    final myRunning = mine.where(isRunning).firstOrNull;
    final names = {for (final e in await db.select(db.enrollments).get()) e.id: e.studentName};
    return InstructorHomeData(
      cards: cards,
      myRunning: myRunning,
      myRunningStudent: myRunning == null ? null : names[myRunning.enrollmentId],
      lessonsToday: mine.length,
      lessonMinutes: minutes,
      withoutDriving: withoutDriving,
      todayRows: [for (final l in mine) (l, names[l.enrollmentId] ?? '')],
    );
  }

  Future<StudentHomeData?> studentHome(String? studentId) async {
    if (studentId == null) return null;
    final all = await (db.select(db.enrollments)..where((t) => t.studentId.equals(studentId) & _ok(t.syncState))..orderBy([(t) => OrderingTerm.desc(t.registeredOn)])).get();
    if (all.isEmpty) return null;
    final e = all.where((x) => !['graduated', 'withdrawn'].contains(x.stage)).firstOrNull ?? all.first;
    final lessons = await (db.select(db.lessons)
          ..where((t) => t.enrollmentId.equals(e.id) & t.archived.equals(false) & _ok(t.syncState))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
    final exams = await (db.select(db.exams)..where((t) => t.enrollmentId.equals(e.id) & _ok(t.syncState))..orderBy([(t) => OrderingTerm.desc(t.scheduledDate)])).get();
    final payments = await (db.select(db.ledgerEntries)
          ..where((t) => t.enrollmentId.equals(e.id) & t.kind.equals('payment') & _ok(t.syncState))
          ..orderBy([(t) => OrderingTerm.desc(t.businessDate)]))
        .get();
    final charges = await (db.select(db.ledgerEntries)
          ..where((t) => t.enrollmentId.equals(e.id) & t.kind.isIn(const ['registration_fee', 'exam_fee', 'retake_fee', 'discount']) & _ok(t.syncState))
          ..orderBy([(t) => OrderingTerm.desc(t.businessDate)]))
        .get();
    final lt = await (db.select(db.licenseTypes)..where((t) => t.id.equals(e.licenseTypeId))).getSingleOrNull();
    return StudentHomeData(
      charges: charges,
      enrollment: e,
      licenseName: lt?.name ?? '',
      theoryDone: lessons.where((l) => l.type == 'theory').length,
      practicalDone: lessons.where((l) => l.type == 'practical').length,
      balance: await localBalance(db, e.id),
      exams: exams,
      lessons: lessons.take(5).toList(),
      payments: payments,
    );
  }
}
