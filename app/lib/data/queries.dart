import 'dart:async';

import 'package:drift/drift.dart';

import '../core/db/database.dart';
import '../core/domain/ledger.dart';
import '../core/domain/money.dart';
import '../core/util/dates.dart';
import '../features/money/record_payment.dart' show localBalance;
import 'money_queries.dart';
import 'settings_queries.dart';

/// Re-runs [load] whenever any local table changes (sync, own writes). Screens build from this.
Stream<T> watchLoad<T>(AppDatabase db, Future<T> Function() load) {
  late StreamController<T> c;
  StreamSubscription<void>? sub;
  var running = false;
  var again = false;
  Future<void> run() async {
    if (running) {
      again = true;
      return;
    }
    running = true;
    try {
      do {
        again = false;
        final v = await load();
        if (!c.isClosed) c.add(v);
      } while (again);
    } catch (e, s) {
      if (!c.isClosed) c.addError(e, s);
    } finally {
      running = false;
    }
  }

  c = StreamController<T>(
    onListen: () {
      sub = db.tableUpdates().listen((_) => run());
      run();
    },
    onCancel: () => sub?.cancel(),
  );
  return c.stream;
}

String stageLabel(String stage) => switch (stage) {
      'theory' => 'نظري',
      'practical' => 'عملي',
      'ready_practical' => 'جاهز للتست',
      'passed' => 'نجح بالعملي',
      'graduated' => 'خرّيج',
      'withdrawn' => 'منسحب',
      _ => stage,
    };

/// One student/enrollment as shown on lists and the profile.
class StudentCard {
  const StudentCard({
    required this.enrollment,
    required this.student,
    required this.licenseName,
    required this.carName,
    required this.theoryDone,
    required this.practicalDone,
    required this.plannedTheory,
    required this.plannedPractical,
    required this.minPractical,
    required this.balance,
    required this.lastAt,
    this.price,
    this.pendingExam,
    this.theoryLessons = true,
    this.overdue = false,
  });

  /// A2: owes more than the overdue amount and paid nothing for the overdue days (shown red).
  final bool overdue;

  /// Settings switch "تسجيل الدروس النظري": off → no theory lesson button and no theory minimum.
  final bool theoryLessons;

  /// The booked exam without a result (if any).
  final ExamRow? pendingExam;

  final EnrollmentRow enrollment;
  final StudentRow? student;
  final String licenseName;
  final String carName;
  final int theoryDone;
  final int practicalDone;
  final int plannedTheory;
  final int plannedPractical;
  final int minPractical;
  final StudentBalance balance;
  final String lastAt;

  /// Price version effective today (for "expected full price" and exam rules).
  final LicensePriceRow? price;

  String get name => enrollment.studentName;
  String get id => enrollment.id;
  String get stage => enrollment.stage;
  bool get inTheory => stage == 'theory';
  int get done => inTheory ? theoryDone : practicalDone;
  int get planned => inTheory ? plannedTheory : plannedPractical;
  /// "13/8"; nothing for theory when theory lessons are switched off.
  String get counter => inTheory && !theoryLessons ? '' : ' $done/$planned';
  double get progress => planned == 0 || (inTheory && !theoryLessons) ? 0 : (done / planned).clamp(0, 1).toDouble();
  String get nextLessonLabel => inTheory ? 'نظري ${theoryDone + 1}' : 'عملي ${practicalDone + 1}';
  bool get inExamStage => stage == 'theory' || stage == 'practical' || stage == 'ready_practical';
  bool get canLesson => inExamStage && !(inTheory && !theoryLessons);
  int get minForExam => inTheory ? (theoryLessons ? price?.minTheoryBeforeExam ?? 0 : 0) : (price?.minPracticalBeforeExam ?? 0);

  /// Reached the minimum lessons for the next exam and nothing is booked (canvas: "حجز اختبار" on the card).
  bool get readyForExam => inExamStage && pendingExam == null && (stage == 'ready_practical' || (inTheory && !theoryLessons) || (minForExam > 0 ? done >= minForExam : done > 0)); // no minimum set: ready after the first lesson
  bool get passedPractical => stage == 'passed';
  Money get remaining => balance.remaining;
}

class CarNow {
  const CarNow({required this.car, required this.running, required this.line, required this.pill, required this.progress, this.enrollmentId});
  final CarRow car;
  final bool running;
  final String line;
  final String pill;
  final double progress;
  final String? enrollmentId;
}

class TodayOp {
  const TodayOp({required this.time, required this.what, required this.amount, required this.kind, this.enrollmentId});
  final String time;
  final String what;
  final Money? amount;

  /// in | out | lesson | info
  final String kind;
  final String? enrollmentId;
}

class HomeData {
  const HomeData({
    required this.cars,
    required this.lessonsToday,
    required this.cashIn,
    required this.cashOut,
    required this.ops,
    required this.opsCount,
    required this.rejected,
    required this.readyNoBooking,
    this.todayClosed = false,
    this.olderOpenDay,
    this.dueExams = const [],
    this.closeHour = 16,
  });

  /// "إغلاق اليوم" shows from this hour (Settings → closeReminderHour).
  final int closeHour;

  /// Exams on or before today still without a result.
  final List<ExamRow> dueExams;
  final bool todayClosed;

  /// The oldest earlier day with money that was never closed (null = none).
  final String? olderOpenDay;
  final List<CarNow> cars;
  final int lessonsToday;
  final Money cashIn;
  final Money cashOut;
  final List<TodayOp> ops;
  final int opsCount;
  final List<RejectedOpRow> rejected;
  final List<StudentCard> readyNoBooking;
}


class Queries {
  Queries(this.db);
  final AppDatabase db;

  Future<bool> nationalIdTaken(String nationalId, {String? exceptStudent}) async {
    final rows = await (db.select(db.students)..where((t) => t.nationalId.equals(nationalId.trim()))).get();
    return rows.any((r) => r.id != exceptStudent && r.syncState != 'rejected');
  }

  Future<LicensePriceRow?> priceOn(String licenseTypeId, String businessDate) async {
    final rows = await (db.select(db.licensePrices)
          ..where((t) => t.licenseTypeId.equals(licenseTypeId) & t.effectiveFrom.isSmallerOrEqualValue(businessDate))
          ..orderBy([(t) => OrderingTerm.desc(t.effectiveFrom), (t) => OrderingTerm.desc(t.at)]) // same day: the last saved wins (as on the server)
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<String?> instructorOfCar(String carId) async {
    final rows = await (db.select(db.carInstructors)..where((t) => t.carId.equals(carId) & t.to.isNull())).get();
    return rows.isEmpty ? null : rows.first.employeeId;
  }

  Future<int> lessonCount(String enrollmentId, String type) async {
    final c = db.lessons.id.count();
    final q = db.selectOnly(db.lessons)
      ..addColumns([c])
      ..where(db.lessons.enrollmentId.equals(enrollmentId) &
          db.lessons.type.equals(type) &
          db.lessons.archived.equals(false) &
          db.lessons.syncState.equals('rejected').not());
    return (await q.getSingle()).read(c) ?? 0;
  }

  Future<List<LicenseTypeRow>> licenseTypes() =>
      (db.select(db.licenseTypes)..where((t) => t.active.equals(true))..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();

  Future<List<CarRow>> cars() => (db.select(db.cars)..where((t) => t.active.equals(true))..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Future<List<TreasuryAccountRow>> accounts() async {
    final rows = await (db.select(db.treasuryAccounts)..where((t) => t.active.equals(true))).get();
    const order = {'cash': 0, 'wallet': 1, 'bank': 2};
    rows.sort((a, b) => (order[a.kind] ?? 9).compareTo(order[b.kind] ?? 9));
    return rows;
  }

  Future<Map<String, String>> employeeNames() async =>
      {for (final e in await db.select(db.employees).get()) e.id: e.name};

  Future<StudentCard> _card(EnrollmentRow e, Map<String, String> lts, Map<String, String> carNames, {required bool theoryLessons}) async {
    final student = await (db.select(db.students)..where((t) => t.id.equals(e.studentId))).getSingleOrNull();
    final price = await priceOn(e.licenseTypeId, todayStr());
    final last = await (db.select(db.ledgerEntries)
          ..where((t) => t.enrollmentId.equals(e.id))
          ..orderBy([(t) => OrderingTerm.desc(t.at)])
          ..limit(1))
        .getSingleOrNull();
    // A2 overdue debt: remaining > overdueAmount and no payment for overdueDays (from registration if none).
    final balance = await localBalance(db, e.id);
    final settings = SettingsQueries(db);
    final lastPay = await (db.select(db.ledgerEntries)
          ..where((t) => t.enrollmentId.equals(e.id) & t.kind.equals('payment') & t.reversed.equals(false) & t.syncState.equals('rejected').not())
          ..orderBy([(t) => OrderingTerm.desc(t.businessDate)])
          ..limit(1))
        .getSingleOrNull();
    final since = DateTime.tryParse(lastPay?.businessDate ?? e.registeredOn);
    final overdue = since != null &&
        balance.remaining.agorot > await settings.intOf('overdueAmount') &&
        DateTime.now().difference(since).inDays >= await settings.intOf('overdueDays');
    return StudentCard(
      overdue: overdue,
      enrollment: e,
      student: student,
      licenseName: lts[e.licenseTypeId] ?? '',
      carName: carNames[e.carId] ?? '',
      theoryDone: await lessonCount(e.id, 'theory'),
      practicalDone: await lessonCount(e.id, 'practical'),
      plannedTheory: price?.plannedTheoryLessons ?? 0,
      plannedPractical: price?.plannedPracticalLessons ?? 0,
      minPractical: price?.minPracticalBeforeExam ?? 0,
      balance: balance,
      lastAt: last?.at ?? e.at ?? '',
      price: price,
      theoryLessons: theoryLessons,
      pendingExam: await (db.select(db.exams)..where((t) => t.enrollmentId.equals(e.id) & t.result.equals('pending') & t.syncState.equals('rejected').not())
            ..limit(1))
          .getSingleOrNull(),
    );
  }

  Future<(Map<String, String>, Map<String, String>)> _names() async {
    final lts = {for (final l in await db.select(db.licenseTypes).get()) l.id: l.name};
    final cars = {for (final c in await db.select(db.cars).get()) c.id: c.name};
    return (lts, cars);
  }

  /// Active students (not archived, not graduated/withdrawn, not rejected), most recent activity first.
  Future<List<StudentCard>> studentCards() async {
    final (lts, cars) = await _names();
    final rows = await (db.select(db.enrollments)
          ..where((t) => t.archived.equals(false) & t.syncState.equals('rejected').not() & t.stage.isNotIn(['graduated', 'withdrawn'])))
        .get();
    final theory = await SettingsQueries(db).boolOf('theoryLessonsEnabled');
    final out = <StudentCard>[for (final e in rows) await _card(e, lts, cars, theoryLessons: theory)];
    out.sort((a, b) => b.lastAt.compareTo(a.lastAt));
    return out;
  }

  Future<StudentCard?> studentCard(String enrollmentId) async {
    final e = await (db.select(db.enrollments)..where((t) => t.id.equals(enrollmentId))).getSingleOrNull();
    if (e == null) return null;
    final (lts, cars) = await _names();
    return _card(e, lts, cars, theoryLessons: await SettingsQueries(db).boolOf('theoryLessonsEnabled'));
  }

  /// Other enrollments (licenses) of the same student.
  Future<List<StudentCard>> enrollmentsOf(String studentId) async {
    final (lts, cars) = await _names();
    final rows = await (db.select(db.enrollments)..where((t) => t.studentId.equals(studentId))).get();
    final theory = await SettingsQueries(db).boolOf('theoryLessonsEnabled');
    return [for (final e in rows) await _card(e, lts, cars, theoryLessons: theory)];
  }

  Future<List<LedgerRowData>> ledger(String enrollmentId) => (db.select(db.ledgerEntries)
        ..where((t) => t.enrollmentId.equals(enrollmentId) & t.syncState.equals('rejected').not())
        ..orderBy([(t) => OrderingTerm.desc(t.businessDate), (t) => OrderingTerm.desc(t.at)]))
      .get();

  Future<List<LessonRow>> lessons(String enrollmentId) => (db.select(db.lessons)
        ..where((t) => t.enrollmentId.equals(enrollmentId) & t.syncState.equals('rejected').not())
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
      .get();

  Future<HomeData> home({required bool money}) async {
    final today = todayStr();
    final now = DateTime.now();
    final settings = SettingsQueries(db);
    final lessonMinutes = await settings.intOf('lessonDurationMin');
    final closeHour = await settings.intOf('closeReminderHour');
    final carRows = await cars();
    final names = await employeeNames();
    final enrollments = {for (final e in await db.select(db.enrollments).get()) e.id: e};
    final todayLessons = await (db.select(db.lessons)
          ..where((t) => t.businessDate.equals(today) & t.archived.equals(false) & t.syncState.equals('rejected').not())
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();

    final carList = <CarNow>[];
    for (final c in carRows) {
      final mine = todayLessons.where((l) => l.carId == c.id && l.type == 'practical').toList();
      LessonRow? running;
      for (final l in mine) {
        final start = DateTime.tryParse(l.startedAt);
        if (start != null && now.difference(start).inMinutes < lessonMinutes && !now.isBefore(start)) running = l;
      }
      if (running != null) {
        final start = DateTime.parse(running.startedAt);
        final elapsed = now.difference(start).inMinutes;
        final who = names[running.employeeId] ?? '';
        final student = enrollments[running.enrollmentId]?.studentName ?? '';
        carList.add(CarNow(
          car: c,
          running: true,
          line: '$who مع $student · درس ${running.number}',
          pill: 'ضايل ${lessonMinutes - elapsed} د',
          progress: elapsed / lessonMinutes,
          enrollmentId: running.enrollmentId,
        ));
      } else if (mine.isNotEmpty) {
        final last = mine.first;
        carList.add(CarNow(
          car: c,
          running: false,
          line: 'آخر درس ${hhmm(DateTime.parse(last.startedAt))} · ${names[last.employeeId] ?? ''}',
          pill: 'فاضية',
          progress: 0,
        ));
      } else {
        carList.add(CarNow(car: c, running: false, line: 'ما في دروس اليوم', pill: 'فاضية', progress: 0));
      }
    }

    var cashIn = 0;
    var cashOut = 0;
    if (money) {
      final mv = await (db.select(db.treasuryMovements)..where((t) => t.businessDate.equals(today) & t.syncState.equals('rejected').not())).get();
      for (final m in mv) {
        if (m.direction == 'in') {
          cashIn += m.amount;
        } else {
          cashOut += m.amount;
        }
      }
    }

    final ops = <(String, TodayOp)>[];
    for (final l in todayLessons) {
      final t = DateTime.tryParse(l.startedAt) ?? now;
      final student = enrollments[l.enrollmentId]?.studentName ?? '';
      ops.add((l.startedAt, TodayOp(
        time: hhmm(t),
        what: 'درس ${l.type == 'practical' ? 'عملي' : 'نظري'} ${l.number} · $student · ${names[l.employeeId] ?? ''}',
        amount: null,
        kind: 'lesson',
        enrollmentId: l.enrollmentId,
      )));
    }
    if (money) {
      final ledger = await (db.select(db.ledgerEntries)..where((t) => t.businessDate.equals(today) & t.syncState.equals('rejected').not())).get();
      final accounts = {for (final a in await db.select(db.treasuryAccounts).get()) a.id: a.name};
      for (final r in ledger) {
        final student = enrollments[r.enrollmentId]?.studentName ?? '';
        final at = r.at ?? '';
        final t = DateTime.tryParse(at) ?? now;
        final (what, kind) = switch (r.kind) {
          'payment' => ('دفعة $student · ${accounts[r.accountId] ?? ''}', 'in'),
          'registration_fee' => ('تسجيل $student', 'info'),
          'reversal' => ('إرجاع دفعة · $student', 'out'),
          'discount' => ('خصم · $student', 'info'),
          _ => ('', ''),
        };
        if (what.isEmpty) continue;
        ops.add((at, TodayOp(time: hhmm(t), what: what, amount: Money(r.amount), kind: kind, enrollmentId: r.enrollmentId)));
      }
    }
    ops.sort((a, b) => b.$1.compareTo(a.$1));

    final rejected = await db.select(db.rejectedOps).get();
    final ready = (await studentCards()).where((c) => c.readyForExam).toList();
    final due = await (db.select(db.exams)
          ..where((t) => t.result.equals('pending') & t.scheduledDate.isSmallerOrEqualValue(today) & t.syncState.equals('rejected').not()))
        .get();
    final close = await (db.select(db.dayCloses)..where((t) => t.id.equals(today))).getSingleOrNull();
    final older = money ? await MoneyQueries(db).openEarlierDays() : const <String>[];
    return HomeData(
      closeHour: closeHour,
      todayClosed: close?.state == 'closed',
      olderOpenDay: older.isEmpty ? null : older.first,
      cars: carList,
      lessonsToday: todayLessons.where((l) => l.type == 'practical').length,
      cashIn: Money(cashIn),
      cashOut: Money(cashOut),
      ops: ops.take(5).map((o) => o.$2).toList(),
      opsCount: ops.length,
      rejected: rejected,
      readyNoBooking: ready,
      dueExams: due,
    );
  }
}
