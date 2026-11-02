import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_scope.dart';
import '../../core/db/database.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/money_queries.dart';
import '../../data/staff_queries.dart';

Future<T?> staffSheet<T>(BuildContext context, Widget child) => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.tokens.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheet) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheet).bottom), child: SafeArea(top: false, child: child)),
    );

/// Accounts this person may pay from (balances only with the balances permission).
class AccountChips extends StatelessWidget {
  const AccountChips({super.key, required this.accounts, required this.selected, required this.onSelect, required this.showBalance});
  final List<AccountView> accounts;
  final String? selected;
  final ValueChanged<String> onSelect;
  final bool showBalance;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    if (accounts.isEmpty) return Text('ما في صندوق مسموح', style: TextStyle(color: t.problem, fontSize: 13));
    return Row(children: [
      for (final (i, a) in accounts.indexed) ...[
        if (i > 0) const SizedBox(width: 8),
        Expanded(
          child: Panel(
            radius: 12,
            padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
            border: Border.all(color: selected == a.id ? t.primary : t.border, width: selected == a.id ? 2 : 1),
            color: selected == a.id ? t.tonalBg : t.card,
            onTap: () => onSelect(a.id),
            child: Column(children: [
              Text(a.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: selected == a.id ? t.info : t.text)),
              if (showBalance) MoneyText(a.balance, color: t.textSecondary, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ],
    ]);
  }
}

Future<List<AccountView>> allowedAccounts(BuildContext context) async {
  final app = AppScope.of(context);
  return (await app.money.accounts()).where((a) => app.user.canUseAccount(a.id)).toList();
}

// ---------------------------------------------------------------- advance / deduction / bonus

const _reasons = {
  'advance': ['سلفة عادية'],
  'deduction': ['غياب يوم', 'تأخير', 'ضرر بالسيارة', 'غير ذلك'],
  'bonus': ['إضافي', 'مكافأة أداء', 'غير ذلك'],
};
const _titles = {'advance': 'سلفة', 'deduction': 'خصم', 'bonus': 'مكافأة'};

/// Canvas EmployeeStatement sheet: reason chips, amount, (advance) the account, and the effect on the net.
Future<void> showPayrollItemSheet(BuildContext context, EmployeeRow employee, String kind) =>
    staffSheet<void>(context, _ItemSheet(employee: employee, kind: kind));

class _ItemSheet extends StatefulWidget {
  const _ItemSheet({required this.employee, required this.kind});
  final EmployeeRow employee;
  final String kind;

  @override
  State<_ItemSheet> createState() => _ItemSheetState();
}

class _ItemSheetState extends State<_ItemSheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late String _reason = _reasons[widget.kind]!.first;
  List<AccountView> _accounts = const [];
  String? _account;
  String? _month;
  PayrollLine? _line;
  bool _busy = false;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _load();
  }

  Future<void> _load() async {
    final app = AppScope.of(context);
    final accounts = await allowedAccounts(context);
    final month = await app.staff.queries.openMonthFor(widget.employee.id);
    final line = await app.staff.queries.line(widget.employee, month);
    if (!mounted) return;
    setState(() {
      _accounts = accounts;
      _account = accounts.isEmpty ? null : accounts.first.id;
      _month = month;
      _line = line;
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Money get _value => Money.shekels(int.tryParse(_amount.text) ?? 0);
  bool get _isAdv => widget.kind == 'advance';

  Future<void> _save() async {
    final app = AppScope.of(context);
    setState(() => _busy = true);
    try {
      final other = _reason == 'غير ذلك';
      final note = _note.text.trim();
      if (other && note.isEmpty) throw const FormatException('شو السبب؟ (بالملاحظة)');
      await app.staff.addItem(
        employee: widget.employee,
        kind: widget.kind,
        amount: _value,
        payrollMonth: _month!,
        businessDate: todayStr(),
        reason: _isAdv ? null : (other ? note : _reason),
        note: other || note.isEmpty ? null : note,
        accountId: _isAdv ? _account : null,
      );
      app.syncSoon();
      if (!mounted) return;
      final nav = Navigator.of(context);
      final acc = _accounts.where((a) => a.id == _account).firstOrNull?.name;
      nav.pop();
      if (nav.context.mounted) {
        showUndoSnack(
          nav.context,
          _isAdv
              ? 'سلفة ${_value.format()} لـ${widget.employee.name} · من ${acc ?? ''} · بتنخصم من راتب ${monthName(_month!)}'
              : '${_titles[widget.kind]} ${_value.format()} لـ${widget.employee.name} · على راتب ${monthName(_month!)}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showErrorSnack(context, e is FormatException ? e.message : 'ما انحفظت: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final line = _line;
    final month = _month;
    if (line == null || month == null) return const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()));
    final netNow = line.net;
    final netAfter = widget.kind == 'bonus' ? netNow + _value : netNow - _value;
    final effect = switch (widget.kind) {
      'advance' => 'بتطلع من الصندوق هلأ وبتنخصم من راتب ${monthName(month)}',
      'deduction' => 'بينقص من صافي راتب ${monthName(month)} · ما في حركة صندوق',
      _ => 'بيزيد على صافي راتب ${monthName(month)} · ما في حركة صندوق',
    };
    final valid = _value.isPositive && (!_isAdv || _account != null);
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('${_titles[widget.kind]} · ${widget.employee.name}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        if (!_isAdv) ...[
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final r in _reasons[widget.kind]!)
              ChoiceChip(
                label: Text(r),
                selected: _reason == r,
                showCheckmark: false,
                selectedColor: t.tonalBg,
                backgroundColor: t.card,
                side: BorderSide(color: _reason == r ? t.primary : t.border, width: _reason == r ? 2 : 1),
                labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _reason == r ? t.info : t.text),
                onSelected: (_) => setState(() => _reason = r),
              ),
          ]),
          const SizedBox(height: 10),
        ],
        TextField(
          controller: _amount,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
          textDirection: TextDirection.ltr,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: '0',
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(start: 14, end: 6),
              child: Text('₪', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: t.textSecondary)),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: t.primary, width: 2)),
          ),
        ),
        const SizedBox(height: 8),
        Text(effect, style: TextStyle(fontSize: 13, color: t.textSecondary)),
        if (month != currentMonth()) ...[
          const SizedBox(height: 6),
          Text('راتب ${monthName(currentMonth())} انصرف، فبتنحط على ${monthLabel(month)}', style: TextStyle(fontSize: 12, color: t.debt, fontWeight: FontWeight.w600)),
        ],
        if (_isAdv) ...[
          const SizedBox(height: 10),
          const Text('من أي صندوق؟', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          AccountChips(accounts: _accounts, selected: _account, onSelect: (a) => setState(() => _account = a), showBalance: AppScope.of(context).user.can('seeBal')),
        ],
        const SizedBox(height: 10),
        TextField(controller: _note, decoration: InputDecoration(hintText: _reason == 'غير ذلك' ? 'شو السبب؟' : 'ملاحظة (اختياري)')),
        const SizedBox(height: 12),
        AppButton(
          '',
          height: 56,
          expand: true,
          busy: _busy,
          onPressed: valid ? _save : null,
          child: MoneyRichText('حفظ ${_titles[widget.kind]} ${_value.format()} · الصافي يصير ${netAfter.isNegative ? '−' : ''}${netAfter.abs().format()}',
              style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------- pay salary

Future<void> showPaySalarySheet(BuildContext context, PayrollLine line, String month) =>
    staffSheet<void>(context, _PaySheet(line: line, month: month));

class _PaySheet extends StatefulWidget {
  const _PaySheet({required this.line, required this.month});
  final PayrollLine line;
  final String month;

  @override
  State<_PaySheet> createState() => _PaySheetState();
}

class _PaySheetState extends State<_PaySheet> {
  List<AccountView> _accounts = const [];
  String? _account;
  bool _busy = false;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    allowedAccounts(context).then((a) {
      if (!mounted) return;
      setState(() {
        _accounts = a;
        // Salaries usually leave the bank (canvas); fall back to the first allowed account.
        _account = (a.where((x) => x.account.kind == 'bank').firstOrNull ?? a.firstOrNull)?.id;
      });
    });
  }

  Future<void> _pay() async {
    final app = AppScope.of(context);
    setState(() => _busy = true);
    try {
      final net = await app.staff.paySalary(line: widget.line, payrollMonth: widget.month, accountId: _account!, businessDate: todayStr());
      app.syncSoon();
      if (!mounted) return;
      final acc = _accounts.where((a) => a.id == _account).firstOrNull?.name ?? '';
      final nav = Navigator.of(context);
      nav.pop();
      if (nav.context.mounted) {
        showUndoSnack(nav.context, 'انصرف راتب ${widget.line.employee.name} ${net.format()} من $acc${widget.line.advances.isZero ? '' : ' · السلف انسكّرت'}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showErrorSnack(context, '$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = widget.line;
    final early = todayStr().compareTo(lastDayOfMonth(widget.month)) < 0;
    Widget row(String label, Money m, {String sign = '', Color? color, bool strong = false}) => Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
          child: Row(children: [
            Expanded(child: Text(label, style: TextStyle(fontSize: strong ? 15 : 14, fontWeight: strong ? FontWeight.w700 : FontWeight.w500))),
            MoneyText(m, sign: sign, color: color, style: TextStyle(fontSize: strong ? 18 : 14, fontWeight: FontWeight.w700)),
          ]),
        );
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('صرف راتب ${l.employee.name} · ${monthLabel(widget.month)}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Panel(
          color: t.bg,
          child: Column(children: [
            row('الراتب', l.salary),
            if (!l.bonuses.isZero) row('مكافآت', l.bonuses, sign: '+', color: t.info),
            if (!l.deductions.isZero) row('خصومات', l.deductions, sign: '−'),
            if (!l.advances.isZero) row('سلف (${l.advanceCount})', l.advances, sign: '−'),
            Divider(color: t.border),
            row('الصافي', l.net, strong: true, color: l.net.isNegative ? t.problem : null),
          ]),
        ),
        if (l.net.isNegative) ...[
          const SizedBox(height: 8),
          Text('السلف والخصومات أكثر من الراتب · ما بينفع الصرف', style: TextStyle(color: t.problem, fontWeight: FontWeight.w600)),
        ],
        if (early) ...[
          const SizedBox(height: 8),
          Text('قبل نهاية الشهر · بينكتب "قبل الموعد"، وأي سلفة بعدها بتنحط على الشهر الجاي', style: TextStyle(fontSize: 12, color: t.textSecondary)),
        ],
        const SizedBox(height: 12),
        const Text('من أي صندوق؟', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        AccountChips(accounts: _accounts, selected: _account, onSelect: (a) => setState(() => _account = a), showBalance: AppScope.of(context).user.can('seeBal')),
        const SizedBox(height: 14),
        AppButton(
          '',
          height: 56,
          expand: true,
          busy: _busy,
          onPressed: _account == null || l.net.isNegative ? null : _pay,
          child: MoneyRichText('صرف ${l.net.format()} من ${_accounts.where((a) => a.id == _account).firstOrNull?.name ?? ''}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------- month picker

Future<String?> showPayrollMonthPicker(BuildContext context, List<MonthState> months, String current) =>
    staffSheet<String>(context, _MonthPicker(months: months, current: current));

class _MonthPicker extends StatefulWidget {
  const _MonthPicker({required this.months, required this.current});
  final List<MonthState> months;
  final String current;

  @override
  State<_MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<_MonthPicker> {
  late String _year = widget.current.substring(0, 4);

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final years = widget.months.map((m) => m.month.substring(0, 4)).toSet().toList()..sort((a, b) => b.compareTo(a));
    final now = currentMonth();
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Expanded(child: Text('شهور الرواتب', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
          for (final y in years)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 6),
              child: ChoiceChip(
                label: Text(y),
                selected: _year == y,
                showCheckmark: false,
                selectedColor: t.tonalBg,
                backgroundColor: t.card,
                side: BorderSide(color: _year == y ? t.tonalBg : t.border),
                labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _year == y ? t.info : t.text),
                onSelected: (_) => setState(() => _year = y),
              ),
            ),
        ]),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.5),
          child: ListView(shrinkWrap: true, children: [
            for (final m in widget.months.where((m) => m.month.startsWith(_year)))
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 8),
                child: Panel(
                  radius: 12,
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 14),
                  color: m.month == widget.current ? t.tonalBg : t.card,
                  border: Border.all(color: m.month == widget.current ? t.primary : t.border, width: m.month == widget.current ? 2 : 1),
                  onTap: () => Navigator.of(context).pop(m.month),
                  child: Row(children: [
                    Expanded(child: Text('${monthLabel(m.month)}${m.month == now ? ' · الحالي' : ''}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
                    Text(
                      m.employees == 0 ? 'ما في موظفين' : m.unpaid > 0 ? '${m.unpaid} لسا' : 'انصرف كله ✓',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: m.unpaid > 0 ? t.debt : t.money),
                    ),
                  ]),
                ),
              ),
          ]),
        ),
        Text('الشهور القديمة بتضل محفوظة · الراتب بيضل زي ما كان بهداك الشهر', style: TextStyle(fontSize: 12, color: t.textSecondary)),
      ]),
    );
  }
}
