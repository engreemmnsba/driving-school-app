import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/db/database.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/period_picker.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../core/util/period.dart';
import '../../data/money_queries.dart';
import '../../data/queries.dart';
import '../home/home_screen.dart' show openStudent;
import '../staff/payroll_view.dart';
import 'add_expense_sheet.dart';
import 'close_day_screen.dart';
import 'move_money_sheet.dart';
import 'recon_log_screen.dart';

enum MoneyTab { cashbook, treasury, expenses, payroll }

/// The "المال" tab: الوارد والصادر · الصناديق · المصروفات · الرواتب — each only with its permission.
class MoneyScreen extends StatefulWidget {
  const MoneyScreen({super.key});

  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> {
  MoneyTab? _tab;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    final tabs = <(MoneyTab, String)>[
      if (app.user.can('cashbook') || app.user.can('seeMoney')) (MoneyTab.cashbook, 'الوارد والصادر'),
      if (app.user.can('seeBal')) (MoneyTab.treasury, 'الصناديق'),
      if (app.user.can('seeExp')) (MoneyTab.expenses, 'المصروفات'),
      if (app.user.can('payroll')) (MoneyTab.payroll, 'الرواتب'),
    ];
    if (tabs.isEmpty) {
      return const Scaffold(body: SafeArea(child: Padding(padding: EdgeInsetsDirectional.all(16), child: EmptyState(icon: Icons.lock_outline, title: 'ما في صلاحية للمال', body: 'الصلاحية من المدير'))));
    }
    final tab = tabs.any((x) => x.$1 == _tab) ? _tab! : tabs.first.$1;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 10),
            child: Container(
              padding: const EdgeInsetsDirectional.all(4),
              decoration: BoxDecoration(color: t.card, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                for (final (k, label) in tabs)
                  Expanded(
                    child: Semantics(
                      selected: k == tab,
                      button: true,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(9),
                        onTap: () => setState(() => _tab = k),
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: k == tab ? t.primary : Colors.transparent, borderRadius: BorderRadius.circular(9)),
                          child: Text(label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, fontWeight: k == tab ? FontWeight.w700 : FontWeight.w600, color: k == tab ? t.onPrimary : t.text)),
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
          Expanded(
            child: switch (tab) {
              MoneyTab.cashbook => const CashBookView(),
              MoneyTab.treasury => const TreasuryView(),
              MoneyTab.expenses => const ExpensesView(),
              MoneyTab.payroll => const PayrollView(),
            },
          ),
        ]),
      ),
    );
  }
}

Widget _filterChips<T>(BuildContext context, List<(T, String)> items, T selected, ValueChanged<T> onSelect) {
  final t = context.tokens;
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(children: [
      for (final (v, label) in items)
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 6),
          child: ChoiceChip(
            label: Text(label),
            selected: v == selected,
            showCheckmark: false,
            selectedColor: t.tonalBg,
            backgroundColor: t.card,
            side: BorderSide(color: v == selected ? t.primary : t.border, width: v == selected ? 2 : 1),
            shape: const StadiumBorder(),
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: v == selected ? t.info : t.text),
            onSelected: (_) => onSelect(v),
          ),
        ),
    ]),
  );
}

class _Totals extends StatelessWidget {
  const _Totals({required this.moneyIn, required this.moneyOut});
  final Money moneyIn;
  final Money moneyOut;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final net = moneyIn - moneyOut;
    Widget cell(String label, Money m, Color c, {String sign = '', bool strong = false}) => Expanded(
          child: Column(children: [
            Text(label, style: TextStyle(fontSize: 12, color: strong ? t.info : t.textSecondary, fontWeight: strong ? FontWeight.w600 : FontWeight.w400)),
            MoneyText(m, sign: sign, color: c, style: TextStyle(fontSize: strong ? 20 : 18, fontWeight: FontWeight.w700)),
          ]),
        );
    return Panel(
      radius: 14,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 4),
      child: IntrinsicHeight(
        child: Row(children: [
          cell('وارد', moneyIn, t.money),
          VerticalDivider(color: t.border, width: 1),
          cell('صادر', moneyOut, t.text),
          VerticalDivider(color: t.border, width: 1),
          cell('صافي', net.abs(), net.isNegative ? t.problem : t.info, sign: net.isNegative ? '−' : '', strong: true),
        ]),
      ),
    );
  }
}

class MovementTile extends StatelessWidget {
  const MovementTile({super.key, required this.m, this.showAccount = true});
  final MovementView m;
  final bool showAccount;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Panel(
        radius: 12,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
        onTap: m.enrollmentId == null ? null : () => openStudent(context, m.enrollmentId!),
        child: Row(children: [
          SizedBox(width: 60, child: Text(m.time, style: TextStyle(fontSize: 12, color: t.textSecondary))),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.what, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text('${m.type}${showAccount ? ' · ${m.accountName}' : ''}${m.pending ? ' · مستني مزامنة' : ''}',
                  style: TextStyle(fontSize: 12, color: t.textSecondary)),
            ]),
          ),
          MoneyText(m.amount, sign: m.isIn ? '+' : '−', color: m.isIn ? t.money : t.text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

/// Canvas: CashBook — every money movement in a period, by account and type.
class CashBookView extends StatefulWidget {
  const CashBookView({super.key});

  @override
  State<CashBookView> createState() => _CashBookViewState();
}

class _CashBookViewState extends State<CashBookView> {
  Period _period = Period.of(PeriodKind.today);
  String _account = '';
  String _type = '';
  Stream<(List<MovementView>, List<AccountView>, DayView)>? _stream;

  void _listen() {
    final app = AppScope.of(context);
    final p = _period;
    _stream = watchLoad(app.db, () async => (await app.money.movements(p), await app.money.accounts(), await app.money.day(todayStr())));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stream == null) _listen();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    return StreamBuilder<(List<MovementView>, List<AccountView>, DayView)>(
      stream: _stream,
      builder: (context, snap) {
        final d = snap.data;
        final all = d?.$1;
        final shown = (all ?? const <MovementView>[]).where((m) => (_account.isEmpty || m.row.accountId == _account) && (_type.isEmpty || m.type == _type)).toList();
        var i = 0, o = 0;
        for (final m in shown) {
          if (m.type == 'تحويلات' && _account.isEmpty) continue;
          if (m.isIn) {
            i += m.row.amount;
          } else {
            o += m.row.amount;
          }
        }
        final today = d?.$3;
        return ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
          children: [
            if (app.user.can('closeDay') && today != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 10),
                child: Row(children: [
                  Expanded(
                    child: AppButton(today.isClosed ? 'اليوم مغلق ✓' : 'مطابقة وإغلاق اليوم',
                        kind: today.isClosed ? AppButtonKind.outline : AppButtonKind.accent,
                        icon: Icons.lock_outline,
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CloseDayScreen(date: todayStr())))),
                  ),
                  const SizedBox(width: 8),
                  AppButton('سجلات المطابقة', kind: AppButtonKind.outline, onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ReconLogScreen()))),
                ]),
              ),
            PeriodButton(period: _period, onChanged: (p) => setState(() {
                  _period = p;
                  _listen();
                })),
            const SizedBox(height: 10),
            if (d != null) ...[
              _filterChips<String>(context, [('', 'كل الصناديق'), for (final a in d.$2) (a.id, a.name)], _account, (v) => setState(() => _account = v)),
              const SizedBox(height: 6),
              _filterChips<String>(context, [('', 'كل الأنواع'), for (final ty in movementTypes) (ty, ty)], _type, (v) => setState(() => _type = v)),
              const SizedBox(height: 10),
              _Totals(moneyIn: Money(i), moneyOut: Money(o)),
              const SizedBox(height: 10),
              Text('${shown.length} حركة · ${_period.label}', style: TextStyle(fontSize: 13, color: t.textSecondary)),
              const SizedBox(height: 8),
              if (shown.isEmpty)
                const EmptyState(icon: Icons.receipt_long_outlined, title: 'ما في حركات بهالفترة')
              else
                for (final m in shown) MovementTile(m: m),
            ] else
              const SkeletonCards(),
          ],
        );
      },
    );
  }
}

/// Canvas: Treasury — balance of every account + movements in a period; top-up / withdraw / transfer.
class TreasuryView extends StatefulWidget {
  const TreasuryView({super.key});

  @override
  State<TreasuryView> createState() => _TreasuryViewState();
}

class _TreasuryViewState extends State<TreasuryView> {
  Period _period = Period.of(PeriodKind.month);
  String? _account;
  Stream<(List<AccountView>, List<MovementView>)>? _stream;

  void _listen() {
    final app = AppScope.of(context);
    final p = _period;
    _stream = watchLoad(app.db, () async => (await app.money.accounts(), await app.money.movements(p)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stream == null) _listen();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    return StreamBuilder<(List<AccountView>, List<MovementView>)>(
      stream: _stream,
      builder: (context, snap) {
        final d = snap.data;
        if (d == null) return const Padding(padding: EdgeInsetsDirectional.all(16), child: SkeletonCards());
        final (accounts, moves) = d;
        final shown = moves.where((m) => _account == null || m.row.accountId == _account).toList();
        final total = accounts.fold<Money>(const Money.zero(), (s, a) => s + a.balance);
        return ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
          children: [
            Panel(
              radius: 14,
              child: Row(children: [
                Expanded(child: Text('مجموع الصناديق', style: TextStyle(fontSize: 13, color: t.textSecondary))),
                MoneyText(total, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.6,
              children: [
                for (final a in accounts)
                  Builder(builder: (context) {
                    final r = moves.where((m) => m.row.accountId == a.id);
                    final inP = r.where((m) => m.isIn).fold<int>(0, (s, m) => s + m.row.amount);
                    final outP = r.where((m) => !m.isIn).fold<int>(0, (s, m) => s + m.row.amount);
                    final sel = _account == a.id;
                    return Panel(
                      radius: 14,
                      border: Border.all(color: sel ? t.primary : t.card, width: 2),
                      color: sel ? t.tonalBg : t.card,
                      padding: const EdgeInsetsDirectional.all(12),
                      onTap: () => setState(() => _account = sel ? null : a.id),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(a.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        MoneyText(a.balance, color: a.balance.isNegative ? t.problem : t.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        Row(children: [
                          MoneyText(Money(inP), sign: '+', color: t.money, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          MoneyText(Money(outP), sign: '−', color: t.textSecondary, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                      ]),
                    );
                  }),
              ],
            ),
            if (app.user.can('moveMoney')) ...[
              const SizedBox(height: 10),
              AppButton('شحن · سحب · تحويل', kind: AppButtonKind.outline, icon: Icons.swap_horiz_rounded, expand: true, onPressed: () => showMoveMoney(context)),
            ],
            const SizedBox(height: 12),
            PeriodButton(period: _period, onChanged: (p) => setState(() {
                  _period = p;
                  _listen();
                })),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: Text('${_account == null ? 'كل الحركات' : 'حركات ${accounts.firstWhere((a) => a.id == _account).name}'} · ${_period.label}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              if (_account != null) TextButton(onPressed: () => setState(() => _account = null), child: const Text('عرض الكل')),
            ]),
            const SizedBox(height: 6),
            if (shown.isEmpty)
              const EmptyState(icon: Icons.account_balance_wallet_outlined, title: 'ما في حركات بهالفترة')
            else
              for (final m in shown) MovementTile(m: m, showAccount: _account == null),
          ],
        );
      },
    );
  }
}

/// Canvas: Expenses — period, totals per kind, drill down, list.
class ExpensesView extends StatefulWidget {
  const ExpensesView({super.key});

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  Period _period = Period.of(PeriodKind.month);
  String _kind = '';
  String _sub = '';
  Stream<(List<ExpenseRow>, Map<String, String>, Map<String, String>)>? _stream;

  static const _kinds = {'cars': 'سيارات', 'ministry': 'وزارة', 'other': 'أخرى'};

  void _listen() {
    final app = AppScope.of(context);
    final p = _period;
    _stream = watchLoad(app.db, () async {
      final accounts = {for (final a in await app.db.select(app.db.treasuryAccounts).get()) a.id: a.name};
      final cars = {for (final c in await app.db.select(app.db.cars).get()) c.id: c.name};
      return (await app.money.expenses(p), accounts, cars);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stream == null) _listen();
  }

  String _subOf(ExpenseRow e, Map<String, String> cars) => e.kind == 'cars' ? (cars[e.carId] ?? '') : e.item;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    return StreamBuilder<(List<ExpenseRow>, Map<String, String>, Map<String, String>)>(
      stream: _stream,
      builder: (context, snap) {
        final d = snap.data;
        final rows = d?.$1 ?? const <ExpenseRow>[];
        final cars = d?.$3 ?? const <String, String>{};
        final shown = rows.where((e) => (_kind.isEmpty || e.kind == _kind) && (_sub.isEmpty || _subOf(e, cars) == _sub)).toList();
        final total = Money(shown.fold(0, (s, e) => s + e.amount));
        final subs = _kind.isEmpty ? const <String>[] : rows.where((e) => e.kind == _kind).map((e) => _subOf(e, cars)).toSet().toList();
        Money sumOf(String k) => Money(rows.where((e) => k.isEmpty || e.kind == k).fold(0, (s, e) => s + e.amount));
        return ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
          children: [
            if (app.user.can('addExp'))
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: AppButton('مصروف', kind: AppButtonKind.accent, icon: Icons.add_rounded, height: 44, onPressed: () => showAddExpense(context)),
              ),
            const SizedBox(height: 8),
            PeriodButton(period: _period, onChanged: (p) => setState(() {
                  _period = p;
                  _listen();
                })),
            const SizedBox(height: 10),
            Panel(
              radius: 14,
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                  child: Text('مصروفات ${_period.label}${_kind.isEmpty ? '' : ' · ${_kinds[_kind]}'}${_sub.isEmpty ? '' : ' · $_sub'}',
                      style: TextStyle(fontSize: 13, color: t.textSecondary)),
                ),
                MoneyText(total, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 3.4,
              children: [
                for (final k in [..._kinds.keys, ''])
                  Panel(
                    radius: 12,
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
                    border: Border.all(color: _kind == k ? t.primary : t.border, width: _kind == k ? 2 : 1),
                    color: _kind == k ? t.tonalBg : t.card,
                    onTap: () => setState(() {
                      _kind = _kind == k ? '' : k;
                      _sub = '';
                    }),
                    child: Row(children: [
                      Expanded(child: Text(k.isEmpty ? 'الكل' : _kinds[k]!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kind == k ? t.info : t.text))),
                      MoneyText(sumOf(k), color: _kind == k ? t.info : t.text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ]),
                  ),
              ],
            ),
            if (subs.length > 1) ...[
              const SizedBox(height: 8),
              _filterChips<String>(context, [for (final s in subs) (s, s)], _sub, (v) => setState(() => _sub = _sub == v ? '' : v)),
            ],
            const SizedBox(height: 6),
            Text('الرواتب والسلف بتبويب الرواتب', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.primary)),
            const SizedBox(height: 8),
            if (d == null)
              const SkeletonCards()
            else if (shown.isEmpty)
              const EmptyState(icon: Icons.receipt_long_outlined, title: 'ما في مصروفات بهالفترة')
            else
              for (final e in shown)
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 8),
                  child: Panel(
                    radius: 12,
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
                    onTap: () => _expenseActions(context, e),
                    child: Row(children: [
                      Container(
                        constraints: const BoxConstraints(minWidth: 52),
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: t.bg, borderRadius: BorderRadius.circular(8)),
                        child: Text(_kinds[e.kind] ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${e.label}${e.liters == null ? '' : ' · ${e.liters} لتر'}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('${friendlyDate(e.businessDate)} · ${d.$2[e.accountId] ?? ''}${e.syncState == 'pending' ? ' · مستني مزامنة' : ''}',
                              style: TextStyle(fontSize: 12, color: t.textSecondary)),
                        ]),
                      ),
                      MoneyText(Money(e.amount), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
          ],
        );
      },
    );
  }

  void _expenseActions(BuildContext context, ExpenseRow e) {
    final app = AppScope.of(context);
    final own = e.syncState == 'pending' || e.businessDate == todayStr();
    if (!(app.user.can('editExp') || (own && app.user.can('addExp')))) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(e.label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            MoneyRichText('${Money(e.amount).format()} · ${friendlyDate(e.businessDate)}'),
            const SizedBox(height: 16),
            AppButton('إلغاء المصروف (المبلغ بيرجع للصندوق)', kind: AppButtonKind.danger, expand: true, onPressed: () async {
              await app.reverseExpense(e.id, reason: 'إلغاء من شاشة المصروفات');
              app.syncSoon();
              if (sheet.mounted) Navigator.of(sheet).pop();
            }),
          ]),
        ),
      ),
    );
  }
}

/// Cash book opened from Home's "today's page".
class CashBookScreen extends StatelessWidget {
  const CashBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 10), child: BackHeader(title: 'الوارد والصادر')),
          Expanded(child: CashBookView()),
        ]),
      ),
    );
  }
}
