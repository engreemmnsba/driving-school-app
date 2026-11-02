import 'package:flutter/widgets.dart';

import '../data/money_queries.dart';
import '../data/queries.dart';
import '../features/exams/exam_actions.dart';
import '../features/money/money_actions.dart';
import '../features/money/record_payment.dart';
import '../features/oversight/ops_actions.dart';
import '../features/settings/settings_actions.dart';
import '../features/staff/staff_actions.dart';
import '../features/students/student_actions.dart';
import 'auth/auth_service.dart';
import 'db/database.dart';
import 'sync/op.dart';
import 'sync/outbox.dart';
import 'sync/sync_engine.dart';

/// Everything a signed-in screen needs: who, the local database, actions, and sync.
class AppServices {
  AppServices({required this.user, required this.db, required this.session, required this.outbox, required this.engine, required this.signOut})
      : queries = Queries(db),
        recordPayment = RecordPayment(db, outbox, session),
        reversePayment = ReversePayment(db, outbox),
        registerStudent = RegisterStudent(db, outbox),
        logLesson = LogLesson(db, outbox, session),
        undoLesson = UndoLesson(db, outbox),
        editStudent = EditStudent(db, outbox),
        money = MoneyQueries(db),
        addExpense = AddExpense(db, outbox),
        reverseExpense = ReverseExpense(db, outbox),
        moveMoney = MoveMoney(db, outbox),
        closeDay = CloseDay(db, outbox),
        reopenDay = ReopenDay(db, outbox),
        exams = ExamActions(db, outbox),
        staff = StaffActions(db, outbox, user.name),
        ops = OpsActions(db, outbox, user.name),
        settings = SettingsActions(db, outbox);

  final AppUser user;
  final AppDatabase db;
  final SessionInfo session;
  final Outbox outbox;
  final SyncEngine engine;
  final Future<void> Function() signOut;

  final Queries queries;
  final RecordPayment recordPayment;
  final ReversePayment reversePayment;
  final RegisterStudent registerStudent;
  final LogLesson logLesson;
  final UndoLesson undoLesson;
  final EditStudent editStudent;
  final MoneyQueries money;
  final AddExpense addExpense;
  final ReverseExpense reverseExpense;
  final MoveMoney moveMoney;
  final CloseDay closeDay;
  final ReopenDay reopenDay;
  final ExamActions exams;
  final StaffActions staff;
  final OpsActions ops;
  final SettingsActions settings;

  /// Push soon after a local write (the periodic sync also catches it).
  void syncSoon() => engine.syncNow();

  /// Removes a rejected op from "needs you" once reviewed (it stays in the server's activity log).
  Future<void> dismissRejected(String opId) => (db.delete(db.rejectedOps)..where((t) => t.opId.equals(opId))).go();

  /// Recently opened students for the "last dealt with" chips.
  Future<List<String>> recentStudents() async => (await db.kvGet('recentStudents') ?? '').split(',').where((s) => s.isNotEmpty).toList();

  Future<void> touchStudent(String enrollmentId) async {
    final list = [enrollmentId, ...(await recentStudents()).where((e) => e != enrollmentId)].take(6);
    await db.kvSet('recentStudents', list.join(','));
  }
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});
  final AppServices services;

  static AppServices of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.services;

  @override
  bool updateShouldNotify(AppScope oldWidget) => oldWidget.services != services;
}
