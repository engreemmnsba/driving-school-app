import 'dart:math';

import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/domain/money.dart';
import '../../core/sync/op.dart';
import '../../core/sync/outbox.dart';
import '../../data/queries.dart';

/// User-facing failure with a ready-to-show message.
class ActionError implements Exception {
  const ActionError(this.message);
  final String message;
  @override
  String toString() => message;
}

String _now() => DateTime.now().toUtc().toIso8601String();

/// 8 characters, no look-alikes (0/O, 1/l/I). Sent once on WhatsApp; never stored.
String tempPassword() {
  const chars = 'abcdefghjkmnpqrstuvwxyz23456789';
  final r = Random.secure();
  return List.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
}

class RegisteredStudent {
  const RegisteredStudent({required this.studentId, required this.enrollmentId, required this.fee, required this.password});
  final String studentId;
  final String enrollmentId;
  final Money fee;
  final String password;
}

/// Registers a new student + first enrollment + registration fee. Payload = functions studentRegister.
class RegisterStudent {
  RegisterStudent(this.db, this.outbox);
  final AppDatabase db;
  final Outbox outbox;

  Future<RegisteredStudent> call({
    required String name,
    required String nationalId,
    String? phone,
    required String licenseTypeId,
    required String carId,
    required String businessDate,
  }) async {
    final q = Queries(db);
    if (await q.nationalIdTaken(nationalId)) throw const ActionError('رقم الهوية مسجّل لطالب ثاني');
    final price = await q.priceOn(licenseTypeId, businessDate);
    if (price == null) throw const ActionError('ما في أسعار لهالرخصة · لازم تنحط بالإعدادات');
    final studentId = newId();
    final enrollmentId = newId();
    final chargeId = newId();
    final opId = newId();
    final password = tempPassword();
    final at = _now();
    await db.transaction(() async {
      await db.into(db.students).insert(StudentsCompanion.insert(
          id: studentId, name: name, nationalId: nationalId, phone: Value(phone), opId: Value(opId), at: Value(at)));
      await db.into(db.enrollments).insert(EnrollmentsCompanion.insert(
          id: enrollmentId,
          studentId: studentId,
          studentName: name,
          licenseTypeId: licenseTypeId,
          carId: carId,
          registeredOn: businessDate,
          opId: Value(opId),
          at: Value(at)));
      await db.into(db.ledgerEntries).insert(LedgerEntriesCompanion.insert(
          id: chargeId,
          enrollmentId: enrollmentId,
          studentId: studentId,
          kind: 'registration_fee',
          amount: price.registrationFee,
          businessDate: businessDate,
          opId: Value(opId),
          at: Value(at)));
      await outbox.enqueue('student.register', {
        'studentId': studentId,
        'enrollmentId': enrollmentId,
        'chargeId': chargeId,
        'name': name,
        'nationalId': nationalId,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'licenseTypeId': licenseTypeId,
        'carId': carId,
        'businessDate': businessDate,
        'tempPassword': password,
      }, opId: opId);
    });
    return RegisteredStudent(studentId: studentId, enrollmentId: enrollmentId, fee: Money(price.registrationFee), password: password);
  }
}

class LoggedLesson {
  const LoggedLesson({required this.lessonId, required this.type, required this.number, required this.charge});
  final String lessonId;
  final String type;
  final int number;
  final Money charge;
  String get label => '${type == 'practical' ? 'عملي' : 'نظري'} $number';
}

/// Logs the next lesson (theory while in the theory stage, practical after). Payload = functions lessonLog.
class LogLesson {
  LogLesson(this.db, this.outbox, this.session);
  final AppDatabase db;
  final Outbox outbox;
  final SessionInfo session;

  /// [withMoney] = false for people who can't see prices (instructors): the server still charges the lesson.
  Future<LoggedLesson> call(String enrollmentId, {required String businessDate, String? employeeId, bool withMoney = true, bool withoutDriving = false}) async {
    final q = Queries(db);
    final e = await (db.select(db.enrollments)..where((t) => t.id.equals(enrollmentId))).getSingle();
    if (e.stage == 'graduated' || e.stage == 'withdrawn') throw const ActionError('الطالب خلص أو انسحب من هالرخصة');
    final type = e.stage == 'theory' ? 'theory' : 'practical';
    final instructor = employeeId ?? await q.instructorOfCar(e.carId);
    if (instructor == null) throw const ActionError('ما في مدرب مربوط بهالسيارة · من شاشة السيارات والمدربين');
    var charge = 0;
    if (type == 'practical' && withMoney) {
      final price = await q.priceOn(e.licenseTypeId, businessDate);
      if (price == null) throw const ActionError('ما في سعر للدرس العملي بهالتاريخ');
      charge = price.practicalLessonPrice;
    }
    final number = await q.lessonCount(enrollmentId, type) + 1; // provisional; the server decides
    final lessonId = newId();
    final chargeId = newId();
    final opId = newId();
    final at = _now();
    await db.transaction(() async {
      await db.into(db.lessons).insert(LessonsCompanion.insert(
          id: lessonId,
          enrollmentId: enrollmentId,
          studentId: e.studentId,
          type: type,
          number: number,
          employeeId: instructor,
          carId: Value(type == 'practical' ? e.carId : null),
          withoutDriving: Value(type == 'practical' && withoutDriving),
          startedAt: at,
          businessDate: businessDate,
          opId: Value(opId),
          at: Value(at)));
      if (type == 'practical' && withMoney) {
        await db.into(db.ledgerEntries).insert(LedgerEntriesCompanion.insert(
            id: chargeId,
            enrollmentId: enrollmentId,
            studentId: e.studentId,
            kind: 'lesson_charge',
            amount: charge,
            lessonId: Value(lessonId),
            businessDate: businessDate,
            opId: Value(opId),
            at: Value(at)));
      }
      await outbox.enqueue('lesson.log', {
        'lessonId': lessonId,
        'chargeId': chargeId,
        'enrollmentId': enrollmentId,
        'type': type,
        'employeeId': instructor,
        if (type == 'practical' && withoutDriving) 'withoutDriving': true,
        'startedAt': at,
        'businessDate': businessDate,
      }, opId: opId);
    });
    return LoggedLesson(lessonId: lessonId, type: type, number: number, charge: Money(charge));
  }
}

/// Cancels the latest lesson (Undo). Payload = functions lessonArchive.
class UndoLesson {
  UndoLesson(this.db, this.outbox);
  final AppDatabase db;
  final Outbox outbox;

  Future<void> call(String lessonId, {String? reason}) async {
    final l = await (db.select(db.lessons)..where((t) => t.id.equals(lessonId))).getSingle();
    final reversalId = newId();
    final opId = newId();
    final at = _now();
    await db.transaction(() async {
      await (db.update(db.lessons)..where((t) => t.id.equals(lessonId))).write(const LessonsCompanion(archived: Value(true)));
      final charges = await (db.select(db.ledgerEntries)
            ..where((t) => t.lessonId.equals(lessonId) & t.kind.equals('lesson_charge') & t.reversed.equals(false)))
          .get();
      for (final c in charges) {
        await (db.update(db.ledgerEntries)..where((t) => t.id.equals(c.id))).write(const LedgerEntriesCompanion(reversed: Value(true)));
        await db.into(db.ledgerEntries).insert(LedgerEntriesCompanion.insert(
            id: reversalId,
            enrollmentId: c.enrollmentId,
            studentId: c.studentId,
            kind: 'charge_reversal',
            amount: c.amount,
            reversesId: Value(c.id),
            lessonId: Value(lessonId),
            businessDate: l.businessDate,
            opId: Value(opId),
            at: Value(at)));
      }
      await outbox.enqueue('lesson.archive', {
        'lessonId': lessonId,
        'reversalId': reversalId,
        'reason': ?reason,
        'businessDate': l.businessDate,
      }, opId: opId);
    });
  }
}

/// Edits name / national ID / phone; the server logs each change "from A to B". Payload = functions studentEdit.
class EditStudent {
  EditStudent(this.db, this.outbox);
  final AppDatabase db;
  final Outbox outbox;

  Future<void> call(String studentId, {String? name, String? nationalId, String? phone, String? reason}) async {
    final s = await (db.select(db.students)..where((t) => t.id.equals(studentId))).getSingle();
    final payload = <String, dynamic>{'studentId': studentId};
    if (name != null && name != s.name) payload['name'] = name;
    if (nationalId != null && nationalId != s.nationalId) {
      if (await Queries(db).nationalIdTaken(nationalId, exceptStudent: studentId)) {
        throw const ActionError('رقم الهوية مسجّل لطالب ثاني');
      }
      payload['nationalId'] = nationalId;
    }
    if (phone != null && phone != (s.phone ?? '')) payload['phone'] = phone.isEmpty ? null : phone;
    if (payload.length == 1) throw const ActionError('ما في تغيير');
    if (reason != null && reason.isNotEmpty) payload['reason'] = reason;
    final opId = newId();
    await db.transaction(() async {
      await (db.update(db.students)..where((t) => t.id.equals(studentId))).write(StudentsCompanion(
            name: payload.containsKey('name') ? Value(name!) : const Value.absent(),
            nationalId: payload.containsKey('nationalId') ? Value(nationalId!) : const Value.absent(),
            phone: payload.containsKey('phone') ? Value(payload['phone'] as String?) : const Value.absent(),
          ));
      if (payload.containsKey('name')) {
        await (db.update(db.enrollments)..where((t) => t.studentId.equals(studentId))).write(EnrollmentsCompanion(studentName: Value(name!)));
      }
      await outbox.enqueue('student.edit', payload, opId: opId);
    });
  }
}
