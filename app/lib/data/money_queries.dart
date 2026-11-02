import 'package:drift/drift.dart';

import '../core/db/database.dart';
import '../core/domain/money.dart';
import '../core/util/dates.dart';
import '../core/util/period.dart';

/// Type groups used by the cash-book filter (canvas CashBook).
const movementTypes = ['دروس', 'تسجيل', 'اختبارات', 'رواتب وسلف', 'سيارات', 'وزارة', 'أخرى', 'تحويلات'];

class AccountView {
  const AccountView(this.account, this.balance);
  final TreasuryAccountRow account;
  final Money balance;
  String get id => account.id;
  String get name => account.name;
}

class MovementView {
  const MovementView({
    required this.row,
    required this.what,
    required this.type,
    required this.accountName,
    required this.when,
    required this.time,
    this.enrollmentId,
  });
  final MovementRow row;
  final String what;
  final String type;
  final String accountName;

  /// "اليوم 11:42" / "15 تشرين الأول"
  final String when;
  final String time;
  final String? enrollmentId;
  bool get isIn => row.direction == 'in';
  Money get amount => Money(row.amount);
  bool get pending => row.syncState == 'pending';
}

class DayView {
  const DayView({required this.date, required this.close, required this.counts, required this.moneyIn, required this.moneyOut});
  final String date;
  final DayCloseRow? close;
  final List<DayCloseCountRow> counts;
  final Money moneyIn;
  final Money moneyOut;
  Money get net => moneyIn - moneyOut;
  bool get isClosed => close?.state == 'closed';
  Money get diffTotal => Money(counts.fold(0, (s, c) => s + c.diff));
}

class MoneyQueries {
  MoneyQueries(this.db);
  final AppDatabase db;

  static Expression<bool> _notRejected(GeneratedColumn<String> c) => c.equals('rejected').not();

  /// Balance shown = server balance + movements newer than it (pending or synced after it), like student summaries.
  Future<List<AccountView>> accounts() async {
    final rows = await (db.select(db.treasuryAccounts)..where((t) => t.active.equals(true))).get();
    const order = {'cash': 0, 'wallet': 1, 'bank': 2};
    rows.sort((a, b) => (order[a.kind] ?? 9).compareTo(order[b.kind] ?? 9));
    final out = <AccountView>[];
    for (final a in rows) {
      final bal = await (db.select(db.accountBalances)..where((t) => t.accountId.equals(a.id))).getSingleOrNull();
      final seq = bal?.serverSeq ?? 0;
      final base = bal?.balance ?? a.openingBalance;
      final newer = await (db.select(db.treasuryMovements)
            ..where((t) =>
                t.accountId.equals(a.id) &
                (t.syncState.equals('pending') | (t.syncState.equals('synced') & t.serverSeq.isBiggerThanValue(seq)))))
          .get();
      final delta = newer.fold<int>(0, (s, m) => s + (m.direction == 'in' ? m.amount : -m.amount));
      out.add(AccountView(a, Money(base + delta)));
    }
    return out;
  }

  Future<List<MovementView>> movements(Period p, {String? accountId}) async {
    final rows = await (db.select(db.treasuryMovements)
          ..where((t) =>
              t.businessDate.isBetweenValues(p.from, p.to) &
              _notRejected(t.syncState) &
              (accountId == null ? const Constant(true) : t.accountId.equals(accountId)))
          ..orderBy([(t) => OrderingTerm.desc(t.businessDate), (t) => OrderingTerm.desc(t.at)]))
        .get();
    final accounts = {for (final a in await db.select(db.treasuryAccounts).get()) a.id: a.name};
    final enrollments = {for (final e in await db.select(db.enrollments).get()) e.id: e.studentName};
    final out = <MovementView>[];
    for (final m in rows) {
      var what = '';
      var type = 'أخرى';
      String? enrollmentId;
      switch (m.kind) {
        case 'student_payment':
          final l = await (db.select(db.ledgerEntries)..where((t) => t.id.equals(m.refId))).getSingleOrNull();
          enrollmentId = l?.enrollmentId;
          final name = enrollments[l?.enrollmentId] ?? '';
          if (l?.kind == 'reversal') {
            what = 'إرجاع دفعة · $name';
            type = 'دروس';
          } else {
            what = 'دفعة $name';
            type = switch (l?.purpose) { 'registration' => 'تسجيل', 'exam' => 'اختبارات', 'general' => 'أخرى', _ => 'دروس' };
          }
        case 'expense' || 'expense_reversal':
          final e = await (db.select(db.expenses)..where((t) => t.id.equals(m.refId))).getSingleOrNull();
          what = '${m.kind == 'expense_reversal' ? 'إلغاء مصروف: ' : ''}${e?.label ?? 'مصروف'}${e?.liters == null ? '' : ' · ${e!.liters} لتر'}';
          type = switch (e?.kind) { 'cars' => 'سيارات', 'ministry' => 'وزارة', _ => 'أخرى' };
        case 'top_up':
          what = 'شحن${m.note == null ? '' : ' · ${m.note}'}';
        case 'withdraw':
          what = 'سحب${m.note == null ? '' : ' · ${m.note}'}';
        case 'transfer_out' || 'transfer_in':
          final other = await (db.select(db.treasuryMovements)..where((t) => t.id.equals(m.refId))).getSingleOrNull();
          final otherName = accounts[other?.accountId] ?? '';
          what = m.kind == 'transfer_out' ? 'تحويل إلى $otherName' : 'تحويل من $otherName';
          type = 'تحويلات';
        case 'salary' || 'advance':
          what = m.note ?? (m.kind == 'salary' ? 'راتب' : 'سلفة');
          type = 'رواتب وسلف';
        default:
          what = m.kind;
      }
      final at = DateTime.tryParse(m.at ?? '');
      out.add(MovementView(
        row: m,
        what: what,
        type: type,
        accountName: accounts[m.accountId] ?? '',
        when: friendlyDate(m.businessDate, atIso: m.at),
        time: m.businessDate == todayStr() && at != null ? hhmm(at) : friendlyDate(m.businessDate),
        enrollmentId: enrollmentId,
      ));
    }
    return out;
  }

  Future<List<ExpenseRow>> expenses(Period p) => (db.select(db.expenses)
        ..where((t) => t.businessDate.isBetweenValues(p.from, p.to) & _notRejected(t.syncState) & t.reversed.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.businessDate), (t) => OrderingTerm.desc(t.at)]))
      .get();

  Future<(Money, Money)> totals(String from, String to) async {
    final rows = await (db.select(db.treasuryMovements)..where((t) => t.businessDate.isBetweenValues(from, to) & _notRejected(t.syncState))).get();
    var i = 0, o = 0;
    for (final m in rows) {
      // Transfers move money between our own accounts: not income or spending.
      if (m.kind == 'transfer_in' || m.kind == 'transfer_out') continue;
      if (m.direction == 'in') {
        i += m.amount;
      } else {
        o += m.amount;
      }
    }
    return (Money(i), Money(o));
  }

  Future<DayView> day(String date) async {
    final close = await (db.select(db.dayCloses)..where((t) => t.id.equals(date))).getSingleOrNull();
    final counts = await (db.select(db.dayCloseCounts)..where((t) => t.businessDate.equals(date))).get();
    final (i, o) = await totals(date, date);
    return DayView(date: date, close: close, counts: counts, moneyIn: i, moneyOut: o);
  }

  /// Days with money movement (or a close row) in the period, newest first.
  Future<List<DayView>> days(Period p) async {
    final dates = <String>{};
    final mv = await (db.select(db.treasuryMovements)..where((t) => t.businessDate.isBetweenValues(p.from, p.to))).get();
    dates.addAll(mv.map((m) => m.businessDate));
    final closes = await (db.select(db.dayCloses)..where((t) => t.id.isBetweenValues(p.from, p.to))).get();
    dates.addAll(closes.map((c) => c.id));
    final sorted = dates.toList()..sort((a, b) => b.compareTo(a));
    return [for (final d in sorted) await day(d)];
  }

  /// Earlier days (last 14) with movements that were never closed — shown as "another open day".
  Future<List<String>> openEarlierDays() async {
    final today = todayStr();
    final from = businessDateOf(DateTime.now().subtract(const Duration(days: 14)));
    final mv = await (db.select(db.treasuryMovements)..where((t) => t.businessDate.isBetweenValues(from, today))).get();
    final closed = {for (final c in await db.select(db.dayCloses).get()) if (c.state == 'closed') c.id};
    final open = mv.map((m) => m.businessDate).where((d) => d != today && !closed.contains(d)).toSet().toList()..sort();
    return open;
  }
}
