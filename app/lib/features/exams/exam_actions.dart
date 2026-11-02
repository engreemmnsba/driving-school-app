import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/domain/money.dart';
import '../../core/sync/outbox.dart';
import '../../data/queries.dart';
import '../../data/settings_queries.dart';
import '../students/student_actions.dart' show ActionError;

String _now() => DateTime.now().toUtc().toIso8601String();

const examTypeLabel = {'theory': 'نظري', 'theory_retake': 'إعادة نظري', 'practical': 'عملي'};
const postponeReasons = {'ministry': 'الوزارة أجّلت', 'student': 'الطالب طلب', 'car': 'السيارة مش جاهزة', 'other': 'سبب ثاني'};

/// What booking the next exam would mean for this enrollment (same rules as functions/src/handlers/exams.ts).
class ExamPlan {
  const ExamPlan({required this.type, required this.attempt, required this.fee, required this.minLessons, required this.lessonsDone, this.pending});
  final String type;
  final int attempt;
  final Money fee;
  final int minLessons;
  final int lessonsDone;
  final ExamRow? pending;
  bool get reachedMinimum => minLessons == 0 || lessonsDone >= minLessons;
  String get label => examTypeLabel[type]!;
}

Future<ExamPlan?> examPlan(AppDatabase db, String enrollmentId, String businessDate) async {
  final e = await (db.select(db.enrollments)..where((t) => t.id.equals(enrollmentId))).getSingle();
  if (!['theory', 'practical', 'ready_practical'].contains(e.stage)) return null;
  final exams = await (db.select(db.exams)..where((t) => t.enrollmentId.equals(enrollmentId) & t.syncState.equals('rejected').not())).get();
  final pending = exams.where((x) => x.result == 'pending').firstOrNull;
  final family = e.stage == 'theory' ? 'theory' : 'practical';
  final prior = exams.where((x) => family == 'theory' ? x.type.startsWith('theory') : x.type == 'practical').length;
  final type = family == 'practical' ? 'practical' : (prior == 0 ? 'theory' : 'theory_retake');
  final q = Queries(db);
  final price = await q.priceOn(e.licenseTypeId, businessDate);
  final fee = type == 'theory' ? 0 : (type == 'practical' ? price?.practicalExamFee ?? 0 : price?.theoryRetakeFee ?? 0);
  final theoryOn = await SettingsQueries(db).boolOf('theoryLessonsEnabled');
  final min = family == 'theory' ? (theoryOn ? price?.minTheoryBeforeExam ?? 0 : 0) : price?.minPracticalBeforeExam ?? 0;
  return ExamPlan(type: type, attempt: prior + 1, fee: Money(fee), minLessons: min, lessonsDone: await q.lessonCount(enrollmentId, family), pending: pending);
}

class ExamActions {
  ExamActions(this.db, this.outbox);
  final AppDatabase db;
  final Outbox outbox;

  /// One step: exam + (fee > 0) student charge + ministry expense + money out.
  Future<String> book({required String enrollmentId, required String scheduledDate, String? accountId, required String businessDate, bool override = false}) async {
    final plan = await examPlan(db, enrollmentId, businessDate);
    if (plan == null) throw const ActionError('الطالب مش بمرحلة اختبار');
    if (plan.pending != null) throw const ActionError('في اختبار محجوز لسا ما إله نتيجة');
    if (!plan.reachedMinimum && !override) throw ActionError('لسا ${plan.minLessons - plan.lessonsDone} دروس للحد الأدنى (${plan.minLessons})');
    if (plan.fee.isPositive && accountId == null) throw const ActionError('من أي صندوق بتندفع الرسوم؟');
    final e = await (db.select(db.enrollments)..where((t) => t.id.equals(enrollmentId))).getSingle();
    final examId = newId();
    final chargeId = newId();
    final expenseId = newId();
    final movementId = newId();
    final opId = newId();
    final at = _now();
    await db.transaction(() async {
      await db.into(db.exams).insert(ExamsCompanion.insert(
            id: examId,
            enrollmentId: enrollmentId,
            studentId: e.studentId,
            studentName: e.studentName,
            carId: Value(plan.type == 'practical' ? e.carId : null),
            type: plan.type,
            attempt: plan.attempt,
            scheduledDate: scheduledDate,
            fee: Value(plan.fee.agorot),
            opId: Value(opId),
            at: Value(at),
          ));
      if (plan.fee.isPositive) {
        await db.into(db.ledgerEntries).insert(LedgerEntriesCompanion.insert(
              id: chargeId,
              enrollmentId: enrollmentId,
              studentId: e.studentId,
              kind: plan.type == 'practical' ? 'exam_fee' : 'retake_fee',
              amount: plan.fee.agorot,
              businessDate: businessDate,
              opId: Value(opId),
              at: Value(at),
            ));
        await db.into(db.expenses).insert(ExpensesCompanion.insert(
              id: expenseId,
              kind: 'ministry',
              item: 'رسوم اختبار',
              label: 'رسوم اختبار ${plan.label} — ${e.studentName}',
              studentId: Value(e.studentId),
              amount: plan.fee.agorot,
              accountId: accountId!,
              businessDate: businessDate,
              opId: Value(opId),
              at: Value(at),
            ));
        await db.into(db.treasuryMovements).insert(TreasuryMovementsCompanion.insert(
              id: movementId,
              accountId: accountId,
              direction: 'out',
              amount: plan.fee.agorot,
              kind: 'expense',
              refId: expenseId,
              businessDate: businessDate,
              opId: Value(opId),
              at: Value(at),
            ));
      }
      await outbox.enqueue('exam.book', {
        'examId': examId,
        'enrollmentId': enrollmentId,
        'scheduledDate': scheduledDate,
        'businessDate': businessDate,
        'accountId': ?accountId,
        'chargeId': chargeId,
        'expenseId': expenseId,
        'movementId': movementId,
        if (override) 'override': true,
      }, opId: opId);
    });
    return examId;
  }

  Future<void> postpone(String examId, {required String toDate, required String reason, String? details, required String byName}) async {
    final x = await (db.select(db.exams)..where((t) => t.id.equals(examId))).getSingle();
    final history = [
      ...(jsonDecode(x.historyJson) as List),
      {'from': x.scheduledDate, 'to': toDate, 'reason': reason, 'details': details, 'by': byName},
    ];
    final opId = newId();
    await db.transaction(() async {
      await (db.update(db.exams)..where((t) => t.id.equals(examId)))
          .write(ExamsCompanion(scheduledDate: Value(toDate), historyJson: Value(jsonEncode(history))));
      await outbox.enqueue('exam.postpone', {'examId': examId, 'toDate': toDate, 'reason': reason, 'details': ?details}, opId: opId);
    });
  }

  Future<void> result(String examId, String result) async {
    final x = await (db.select(db.exams)..where((t) => t.id.equals(examId))).getSingle();
    final opId = newId();
    await db.transaction(() async {
      await (db.update(db.exams)..where((t) => t.id.equals(examId))).write(ExamsCompanion(result: Value(result)));
      if (result == 'passed') {
        await (db.update(db.enrollments)..where((t) => t.id.equals(x.enrollmentId)))
            .write(EnrollmentsCompanion(stage: Value(x.type == 'practical' ? 'passed' : 'practical')));
      }
      await outbox.enqueue('exam.result', {'examId': examId, 'result': result}, opId: opId);
    });
  }

  Future<void> graduate(String enrollmentId, {required String today}) async {
    final opId = newId();
    await db.transaction(() async {
      await (db.update(db.enrollments)..where((t) => t.id.equals(enrollmentId)))
          .write(EnrollmentsCompanion(stage: const Value('graduated'), graduatedOn: Value(today)));
      await outbox.enqueue('enrollment.graduate', {'enrollmentId': enrollmentId}, opId: opId);
    });
  }

  Future<void> withdraw(String enrollmentId, String reason) async {
    final pending = await (db.select(db.exams)..where((t) => t.enrollmentId.equals(enrollmentId) & t.result.equals('pending'))).get();
    if (pending.isNotEmpty) throw const ActionError('في اختبار محجوز · لازمه نتيجة أو تأجيل أول');
    final opId = newId();
    await db.transaction(() async {
      await (db.update(db.enrollments)..where((t) => t.id.equals(enrollmentId)))
          .write(EnrollmentsCompanion(stage: const Value('withdrawn'), withdrawReason: Value(reason)));
      await outbox.enqueue('enrollment.withdraw', {'enrollmentId': enrollmentId, 'reason': reason}, opId: opId);
    });
  }

  /// A new license for an existing student.
  Future<String> addEnrollment({required String studentId, required String licenseTypeId, required String carId, required String businessDate}) async {
    final active = await (db.select(db.enrollments)
          ..where((t) => t.studentId.equals(studentId) & t.licenseTypeId.equals(licenseTypeId) & t.stage.isNotIn(['graduated', 'withdrawn'])))
        .get();
    if (active.isNotEmpty) throw const ActionError('عنده هالرخصة شغّالة');
    final st = await (db.select(db.students)..where((t) => t.id.equals(studentId))).getSingle();
    final price = await Queries(db).priceOn(licenseTypeId, businessDate);
    if (price == null) throw const ActionError('ما في أسعار لهالرخصة');
    final enrollmentId = newId();
    final chargeId = newId();
    final opId = newId();
    final at = _now();
    await db.transaction(() async {
      await db.into(db.enrollments).insert(EnrollmentsCompanion.insert(
            id: enrollmentId,
            studentId: studentId,
            studentName: st.name,
            licenseTypeId: licenseTypeId,
            carId: carId,
            registeredOn: businessDate,
            opId: Value(opId),
            at: Value(at),
          ));
      await db.into(db.ledgerEntries).insert(LedgerEntriesCompanion.insert(
            id: chargeId,
            enrollmentId: enrollmentId,
            studentId: studentId,
            kind: 'registration_fee',
            amount: price.registrationFee,
            businessDate: businessDate,
            opId: Value(opId),
            at: Value(at),
          ));
      await outbox.enqueue('enrollment.add', {
        'enrollmentId': enrollmentId,
        'chargeId': chargeId,
        'studentId': studentId,
        'licenseTypeId': licenseTypeId,
        'carId': carId,
        'businessDate': businessDate,
      }, opId: opId);
    });
    return enrollmentId;
  }

  /// Discount (server checks the per-user maximum). Payload = functions discountGive.
  Future<void> discount({required String enrollmentId, required Money amount, String? reason, required String businessDate}) async {
    final e = await (db.select(db.enrollments)..where((t) => t.id.equals(enrollmentId))).getSingle();
    final discountId = newId();
    final opId = newId();
    await db.transaction(() async {
      await db.into(db.ledgerEntries).insert(LedgerEntriesCompanion.insert(
            id: discountId,
            enrollmentId: enrollmentId,
            studentId: e.studentId,
            kind: 'discount',
            amount: amount.agorot,
            businessDate: businessDate,
            opId: Value(opId),
            at: Value(_now()),
          ));
      await outbox.enqueue('discount.give', {
        'discountId': discountId,
        'enrollmentId': enrollmentId,
        'amount': amount.agorot,
        'reason': ?reason,
        'businessDate': businessDate,
      }, opId: opId);
    });
  }
}
