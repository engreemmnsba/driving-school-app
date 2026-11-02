import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/config/version.dart';
import '../core/db/database.dart';
import '../core/domain/money.dart';
import '../core/util/dates.dart';
import '../core/util/period.dart';
import 'queries.dart';
import 'settings_queries.dart';
import 'staff_queries.dart' show addMonths, currentMonth, monthLabel;

Expression<bool> _ok(GeneratedColumn<String> s) => s.equals('rejected').not();

// ---------------------------------------------------------------- activity log

class LogChange {
  const LogChange(this.field, this.before, this.after);
  final String field;
  final String before;
  final String after;
}

class LogEntry {
  const LogEntry({required this.row, required this.tag, required this.changes, required this.local});
  final ActivityRow row;

  /// دفعة · درس · مصروف · رواتب · تسجيل · تعديل · أرشفة · إعدادات
  final String tag;
  final List<LogChange> changes;
  final DateTime? local;

  String get time => local == null ? '' : (businessDateOf(local!) == todayStr() ? hhmm(local!) : dateShort(businessDateOf(local!)));

  /// One readable line ("تعديل · الجوال من 059… إلى 059…"), gender-neutral (no verbs tied to the actor).
  String? get changeLine {
    if (changes.isEmpty && row.reason == null) return null;
    final parts = [for (final c in changes.take(2)) '${c.field} من ${c.before} إلى ${c.after}'];
    if (changes.length > 2) parts.add('و${changes.length - 2} تغييرات كمان');
    if (row.reason != null) parts.add('السبب: ${row.reason}');
    return parts.join(' · ');
  }
}

const logTags = ['دفعة', 'درس', 'مصروف', 'رواتب', 'تسجيل', 'تعديل', 'أرشفة', 'إعدادات'];

String _tagOf(ActivityRow r) {
  switch (r.opType) {
    case 'edit' || 'postpone':
      return 'تعديل';
    case 'archive':
      return 'أرشفة';
    case 'settings' || 'permission' || 'close' || 'reopen':
      return 'إعدادات';
  }
  return switch (r.entity) {
    'payment' || 'discount' => 'دفعة',
    'lesson' => 'درس',
    'expense' || 'treasury_movement' => 'مصروف',
    'payroll_item' || 'salary_payment' => 'رواتب',
    _ => 'تسجيل',
  };
}

String verbOf(ActivityRow r) => switch (r.opType) {
      'create' => 'تسجيل',
      'edit' => 'تعديل',
      'archive' => 'إلغاء',
      'postpone' => 'تأجيل',
      'settings' => 'تغيير إعدادات',
      'permission' => 'صلاحيات',
      'close' => 'إغلاق',
      'reopen' => 'إعادة فتح',
      _ => r.opType,
    };

LogEntry logEntryOf(ActivityRow r) {
  final changes = <LogChange>[];
  try {
    for (final c in jsonDecode(r.changesJson) as List) {
      final m = c as Map;
      String s(Object? v) => v == null || v == '' ? '—' : '$v';
      changes.add(LogChange('${m['field']}', s(m['old']), s(m['new'])));
    }
  } on FormatException {
    // keep the entry without details
  }
  return LogEntry(row: r, tag: _tagOf(r), changes: changes, local: DateTime.tryParse(r.at)?.toLocal());
}

// ---------------------------------------------------------------- notifications

class AppNotice {
  const AppNotice({required this.id, required this.kind, required this.title, required this.meta, required this.time, required this.warn, required this.target, this.arg});
  final String id;

  /// money | exam | sync | sys
  final String kind;
  final String title;
  final String meta;
  final String time;
  final bool warn;

  /// closeDay | exams | rejected | payroll | readyStudents | pending
  final String target;
  final String? arg;
}

// ---------------------------------------------------------------- reports

class ReportData {
  const ReportData({
    required this.revenue,
    required this.byKind,
    required this.expenses,
    required this.salaries,
    required this.debts,
    required this.lessonsByInstructor,
    required this.theoryLessons,
    required this.practicalLessons,
    required this.passedTheory,
    required this.passedPractical,
    required this.examAttempts,
    required this.studentsByStage,
  });

  /// Student payments received (reversals subtracted).
  final Money revenue;

  /// cash | wallet | bank → amount
  final Map<String, Money> byKind;

  /// Expenses (cars, ministry, other) — salaries separately.
  final Money expenses;

  /// salary + bonuses − deductions of salaries paid in the period (advances are not counted twice).
  final Money salaries;
  final Money debts;
  final List<(String, int)> lessonsByInstructor;
  final int theoryLessons;
  final int practicalLessons;
  final int passedTheory;
  final int passedPractical;
  final int examAttempts;
  final Map<String, int> studentsByStage;

  Money get spending => expenses + salaries;
  Money get net => revenue - spending;
  int get passRate => examAttempts == 0 ? 0 : ((passedTheory + passedPractical) * 100 / examAttempts).round();
}

class MonthLockState {
  const MonthLockState({required this.month, required this.lock, required this.openDays});
  final String month;
  final MonthLockRow? lock;

  /// Days with money movement that are not closed yet (the month can't be locked until they are).
  final List<String> openDays;
  bool get locked => lock?.locked == true;
}

class OpsQueries {
  OpsQueries(this.db);
  final AppDatabase db;

  Future<List<LogEntry>> log(Period p, {String? actorId, String? tag, String q = ''}) async {
    final rows = await (db.select(db.activityLogs)..orderBy([(t) => OrderingTerm.desc(t.at)])..limit(2000)).get();
    final query = q.trim();
    final out = <LogEntry>[];
    for (final r in rows) {
      final e = logEntryOf(r);
      final day = e.local == null ? '' : businessDateOf(e.local!);
      if (!p.contains(day)) continue;
      if (actorId != null && r.actorId != actorId) continue;
      if (tag != null && e.tag != tag) continue;
      if (query.isNotEmpty && !r.recordLabel.contains(query) && !r.actorName.contains(query) && !(e.changeLine?.contains(query) ?? false)) continue;
      out.add(e);
    }
    return out;
  }

  /// People who appear in the log (for the filter chips), most active first.
  Future<List<(String, String)>> logActors() async {
    final rows = await db.select(db.activityLogs).get();
    final count = <String, int>{};
    final names = <String, String>{};
    for (final r in rows) {
      count[r.actorId] = (count[r.actorId] ?? 0) + 1;
      names[r.actorId] = r.actorName;
    }
    final ids = count.keys.toList()..sort((a, b) => count[b]!.compareTo(count[a]!));
    return [for (final id in ids) (id, names[id]!)];
  }

  Future<LogEntry?> logEntry(String id) async {
    final r = await (db.select(db.activityLogs)..where((t) => t.id.equals(id))).getSingleOrNull();
    return r == null ? null : logEntryOf(r);
  }

  /// The student enrollment a log line is about (to open the profile), when there is one.
  Future<String?> enrollmentOf(ActivityRow r) async {
    switch (r.entity) {
      case 'student':
        final e = await (db.select(db.enrollments)..where((t) => t.studentId.equals(r.recordId))..orderBy([(t) => OrderingTerm.desc(t.registeredOn)])..limit(1)).getSingleOrNull();
        return e?.id;
      case 'enrollment':
        return r.recordId;
      case 'lesson':
        return (await (db.select(db.lessons)..where((t) => t.id.equals(r.recordId))).getSingleOrNull())?.enrollmentId;
      case 'payment' || 'discount':
        return (await (db.select(db.ledgerEntries)..where((t) => t.id.equals(r.recordId))).getSingleOrNull())?.enrollmentId;
      case 'exam':
        return (await (db.select(db.exams)..where((t) => t.id.equals(r.recordId))).getSingleOrNull())?.enrollmentId;
    }
    return null;
  }

  // ---------- notifications (derived from local data; read state kept on this phone) ----------

  Future<List<AppNotice>> notices({required bool closeDay, required bool exams, required bool payroll, required int pendingOps}) async {
    final out = <AppNotice>[];
    final today = todayStr();
    final now = DateTime.now();
    if (closeDay) {
      final close = await (db.select(db.dayCloses)..where((t) => t.id.equals(today))).getSingleOrNull();
      final moves = await (db.select(db.treasuryMovements)..where((t) => t.businessDate.equals(today) & _ok(t.syncState))).get();
      final closeHour = await SettingsQueries(db).intOf('closeReminderHour');
      if (now.hour >= closeHour && close?.state != 'closed' && moves.isNotEmpty) {
        var net = 0;
        for (final m in moves) {
          if (m.kind == 'transfer_in' || m.kind == 'transfer_out') continue;
          net += m.direction == 'in' ? m.amount : -m.amount;
        }
        out.add(AppNotice(
          id: 'close-$today',
          kind: 'money',
          title: 'اليوم لسا ما انغلق · صافي ${net < 0 ? '−' : ''}${Money(net.abs()).format()}',
          meta: 'المطابقة والإغلاق',
          time: '$closeHour:00',
          warn: true,
          target: 'closeDay',
          arg: today,
        ));
      }
      final from = businessDateOf(now.subtract(const Duration(days: 14)));
      final older = await (db.select(db.treasuryMovements)..where((t) => t.businessDate.isBetweenValues(from, today) & t.businessDate.equals(today).not() & _ok(t.syncState))).get();
      final closed = {for (final c in await db.select(db.dayCloses).get()) if (c.state == 'closed') c.id};
      final open = older.map((m) => m.businessDate).where((d) => !closed.contains(d)).toSet().toList()..sort();
      if (open.isNotEmpty) {
        out.add(AppNotice(
          id: 'open-days-${open.join(',')}',
          kind: 'money',
          title: open.length == 1 ? 'يوم ${friendlyDate(open.first)} لسا مش مسكّر' : '${open.length} أيام قديمة لسا مش مسكّرة',
          meta: 'سجلات المطابقة',
          time: friendlyDate(open.first),
          warn: true,
          target: 'closeDay',
          arg: open.first,
        ));
      }
    }
    if (exams) {
      final due = await (db.select(db.exams)..where((t) => t.result.equals('pending') & t.scheduledDate.isSmallerOrEqualValue(today) & _ok(t.syncState))).get();
      for (final e in due) {
        final type = e.type == 'practical' ? 'عملي' : 'نظري';
        out.add(AppNotice(
          id: 'exam-${e.id}-${e.scheduledDate}',
          kind: 'exam',
          title: e.scheduledDate == today ? '${e.studentName} · اختبار $type اليوم' : '${e.studentName} · اختبار $type من ${friendlyDate(e.scheduledDate)}',
          meta: 'النتيجة لسا ما انسجّلت',
          time: friendlyDate(e.scheduledDate),
          warn: true,
          target: 'exams',
        ));
      }
      final ready = (await Queries(db).studentCards()).where((c) => c.readyForExam).toList();
      if (ready.isNotEmpty) {
        out.add(AppNotice(
          id: 'ready-${ready.map((c) => c.id).join(',')}',
          kind: 'exam',
          title: ready.length == 1 ? '${ready.first.name} وصل الحد الأدنى للاختبار' : '${ready.length} طلاب وصلوا الحد الأدنى للاختبار',
          meta: ready.take(3).map((c) => c.name).join(' · '),
          time: 'اليوم',
          warn: false,
          target: 'readyStudents',
        ));
      }
    }
    if (payroll) {
      final prev = addMonths(currentMonth(), -1);
      final unpaid = (await _unpaidCount(prev));
      if (unpaid > 0) {
        out.add(AppNotice(
          id: 'payroll-$prev',
          kind: 'money',
          title: 'رواتب ${monthLabel(prev)}: $unpaid موظف لسا ما انصرفله',
          meta: 'المال ← الرواتب',
          time: monthLabel(prev),
          warn: true,
          target: 'payroll',
        ));
      }
    }
    for (final r in await (db.select(db.rejectedOps)..orderBy([(t) => OrderingTerm.desc(t.rejectedAt)])).get()) {
      final at = DateTime.tryParse(r.rejectedAt);
      out.add(AppNotice(
        id: 'rejected-${r.opId}',
        kind: 'sync',
        title: 'تغيير مرفوض من السيرفر',
        meta: r.message.isEmpty ? r.reason : r.message,
        time: at == null ? '' : friendlyDate(businessDateOf(at), atIso: r.rejectedAt),
        warn: true,
        target: 'rejected',
        arg: r.opId,
      ));
    }
    final rel = await SettingsQueries(db).raw('appVersion');
    if (rel is Map && rel['build'] is num && (rel['build'] as num).toInt() > appBuild) {
      out.add(AppNotice(
        id: 'update-${rel['build']}',
        kind: 'sys',
        title: 'تحديث جديد متاح ${rel['version'] ?? ''}',
        meta: [for (final n in (rel['notes'] as List?) ?? const []) '$n'].take(2).join(' · '),
        time: '${rel['date'] ?? ''}',
        warn: false,
        target: 'update',
      ));
    }
    if (pendingOps > 0) {
      out.add(AppNotice(
        id: 'pending-$today-$pendingOps',
        kind: 'sync',
        title: '$pendingOps عمليات لسا ما وصلت للسيرفر',
        meta: 'بتنبعت لحالها أول ما يرجع الإنترنت',
        time: 'هلأ',
        warn: false,
        target: 'pending',
      ));
    }
    return out;
  }

  Future<int> _unpaidCount(String month) async {
    final emps = await (db.select(db.employees)..where((t) => t.active.equals(true))).get();
    var n = 0;
    for (final e in emps) {
      final rate = await (db.select(db.salaryRates)..where((t) => t.employeeId.equals(e.id) & t.effectiveFrom.isSmallerOrEqualValue(month))..limit(1)).getSingleOrNull();
      if (rate == null) continue;
      final paid = await (db.select(db.salaryPayments)..where((t) => t.employeeId.equals(e.id) & t.payrollMonth.equals(month) & _ok(t.syncState))).getSingleOrNull();
      if (paid == null) n++;
    }
    return n;
  }

  Future<Set<String>> readNotices() async => (await db.kvGet('noticesRead') ?? '').split('\n').where((s) => s.isNotEmpty).toSet();

  Future<void> markRead(Iterable<String> ids) async {
    final all = {...await readNotices(), ...ids};
    // Keep the list short: ids embed dates, old ones stop appearing.
    await db.kvSet('noticesRead', all.toList().reversed.take(300).join('\n'));
  }

  // ---------- reports ----------

  Future<ReportData> report(Period p, {String? employeeId, String? carId, String? licenseTypeId}) async {
    final accounts = {for (final a in await db.select(db.treasuryAccounts).get()) a.id: a.kind};
    final moves = await (db.select(db.treasuryMovements)
          ..where((t) => t.businessDate.isBetweenValues(p.from, p.to) & t.kind.equals('student_payment') & _ok(t.syncState)))
        .get();
    var revenue = 0;
    final byKind = <String, int>{'cash': 0, 'wallet': 0, 'bank': 0};
    for (final m in moves) {
      final v = m.direction == 'in' ? m.amount : -m.amount;
      revenue += v;
      final k = accounts[m.accountId] ?? 'cash';
      byKind[k] = (byKind[k] ?? 0) + v;
    }
    final exps = await (db.select(db.expenses)..where((t) => t.businessDate.isBetweenValues(p.from, p.to) & t.reversed.equals(false) & _ok(t.syncState))).get();
    final pays = await (db.select(db.salaryPayments)..where((t) => t.businessDate.isBetweenValues(p.from, p.to) & _ok(t.syncState))).get();
    final salaries = pays.fold<int>(0, (s, x) => s + x.salaryAtMonth + x.bonuses - x.deductions);

    // Debts: what active students still owe now.
    final cards = (await Queries(db).studentCards()).where((c) =>
        (carId == null || c.enrollment.carId == carId) && (licenseTypeId == null || c.enrollment.licenseTypeId == licenseTypeId));
    final debts = cards.fold<Money>(const Money.zero(), (s, c) => c.remaining.isPositive ? s + c.remaining : s);

    final enrollmentIds = licenseTypeId == null
        ? null
        : {for (final e in await (db.select(db.enrollments)..where((t) => t.licenseTypeId.equals(licenseTypeId))).get()) e.id};
    final allLessons = await (db.select(db.lessons)
          ..where((t) => t.businessDate.isBetweenValues(p.from, p.to) & t.archived.equals(false) & _ok(t.syncState)))
        .get();
    final ls = allLessons
        .where((l) =>
            (employeeId == null || l.employeeId == employeeId) &&
            (carId == null || l.carId == carId) &&
            (enrollmentIds == null || enrollmentIds.contains(l.enrollmentId)))
        .toList();
    final names = {for (final e in await db.select(db.employees).get()) e.id: e.name};
    final per = <String, int>{};
    for (final l in ls) {
      per[l.employeeId] = (per[l.employeeId] ?? 0) + 1;
    }
    final byInstructor = [for (final e in per.entries) (names[e.key] ?? '—', e.value)]..sort((a, b) => b.$2.compareTo(a.$2));

    final exams = (await (db.select(db.exams)
                ..where((t) => t.scheduledDate.isBetweenValues(p.from, p.to) & t.result.isIn(['passed', 'failed', 'absent']) & _ok(t.syncState)))
            .get())
        .where((x) => (carId == null || x.carId == carId) && (enrollmentIds == null || enrollmentIds.contains(x.enrollmentId)))
        .toList();
    final stages = <String, int>{};
    for (final c in cards) {
      stages[stageLabel(c.stage)] = (stages[stageLabel(c.stage)] ?? 0) + 1;
    }
    return ReportData(
      revenue: Money(revenue),
      byKind: {for (final e in byKind.entries) e.key: Money(e.value)},
      expenses: Money(exps.fold(0, (s, x) => s + x.amount)),
      salaries: Money(salaries),
      debts: debts,
      lessonsByInstructor: byInstructor,
      theoryLessons: ls.where((l) => l.type == 'theory').length,
      practicalLessons: ls.where((l) => l.type == 'practical').length,
      passedTheory: exams.where((x) => x.result == 'passed' && x.type != 'practical').length,
      passedPractical: exams.where((x) => x.result == 'passed' && x.type == 'practical').length,
      examAttempts: exams.length,
      studentsByStage: stages,
    );
  }

  Future<MonthLockState> monthLock(String month) async {
    final lock = await (db.select(db.monthLocks)..where((t) => t.id.equals(month))).getSingleOrNull();
    final moves = await (db.select(db.treasuryMovements)..where((t) => t.businessDate.like('$month-%') & _ok(t.syncState))).get();
    final closed = {for (final c in await db.select(db.dayCloses).get()) if (c.state == 'closed') c.id};
    final open = moves.map((m) => m.businessDate).where((d) => !closed.contains(d)).toSet().toList()..sort();
    return MonthLockState(month: month, lock: lock, openDays: open);
  }

  Future<bool> isLocked(String month) async => (await (db.select(db.monthLocks)..where((t) => t.id.equals(month))).getSingleOrNull())?.locked == true;
}
