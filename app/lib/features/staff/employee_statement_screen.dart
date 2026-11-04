import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/db/database.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../data/queries.dart';
import '../../data/staff_queries.dart';
import 'payroll_sheets.dart';

enum _Range { thisMonth, last3, thisYear }

const _rangeLabel = {_Range.thisMonth: 'هذا الشهر', _Range.last3: 'آخر 3 شهور', _Range.thisYear: 'هالسنة'};

/// Canvas EmployeeStatement: every salary, advance, deduction, bonus and payment of one employee, by payroll month.
class EmployeeStatementScreen extends StatefulWidget {
  const EmployeeStatementScreen({super.key, this.employeeId});
  final String? employeeId;

  @override
  State<EmployeeStatementScreen> createState() => _EmployeeStatementScreenState();
}

class _EmployeeStatementScreenState extends State<EmployeeStatementScreen> {
  late String? _employee = widget.employeeId;
  _Range _range = _Range.last3;
  Stream<EmployeeStatement?>? _stream;
  String? _key;

  (String, String) get _months {
    final now = currentMonth();
    return switch (_range) {
      _Range.thisMonth => (now, now),
      _Range.last3 => (addMonths(now, -2), now),
      _Range.thisYear => ('${now.substring(0, 4)}-01', now),
    };
  }

  Stream<EmployeeStatement?> _watch(BuildContext context, String employeeId) {
    final key = '$employeeId|$_range';
    if (_stream != null && _key == key) return _stream!;
    final app = AppScope.of(context);
    final (from, to) = _months;
    _key = key;
    return _stream = watchLoad(app.db, () => app.staff.queries.statement(employeeId, fromMonth: from, toMonth: to));
  }

  Future<void> _pickEmployee() async {
    final app = AppScope.of(context);
    final list = await app.staff.queries.employeesForPicker();
    if (!mounted) return;
    final picked = await staffSheet<String>(context, _EmployeePicker(list: list, current: _employee));
    if (picked != null) setState(() => _employee = picked);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_employee == null) {
      // Opened from "كشف حساب موظف": start on the first employee.
      AppScope.of(context).staff.queries.employeesForPicker().then((l) {
        if (mounted && _employee == null && l.isNotEmpty) setState(() => _employee = l.first.$1.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    final id = _employee;
    return Scaffold(
      body: SafeArea(
        child: id == null
            ? const Padding(
                padding: EdgeInsetsDirectional.all(16),
                child: Column(children: [BackHeader(title: 'كشف حساب موظف'), SizedBox(height: 16), EmptyState(icon: Icons.badge_outlined, title: 'ما في موظفين', body: 'الموظفين بينضافوا من المزيد ← المستخدمون')]),
              )
            : StreamBuilder<EmployeeStatement?>(
                stream: _watch(context, id),
                builder: (context, snap) {
                  final s = snap.data;
                  return ListView(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
                    children: [
                      Row(children: [
                        Material(
                          color: t.card,
                          borderRadius: BorderRadius.circular(12),
                          child: Semantics(
                            button: true,
                            label: 'رجوع',
                            excludeSemantics: true,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.of(context).maybePop(),
                              child: const SizedBox.square(dimension: 44, child: Icon(Icons.arrow_back_rounded)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: _pickEmployee,
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Flexible(child: Text(s?.employee.name ?? '…', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700))),
                                const SizedBox(width: 6),
                                Text('▾ تغيير', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.primary)),
                              ]),
                              if (s != null) MoneyRichText(s.subtitle, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                            ]),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Panel(
                        radius: 12,
                        border: Border.all(color: t.border),
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 10),
                        onTap: () async {
                          final r = await staffSheet<_Range>(context, _RangePicker(current: _range));
                          if (r != null) setState(() => _range = r);
                        },
                        child: Row(children: [
                          Icon(Icons.calendar_month_outlined, size: 18, color: t.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_rangeLabel[_range]!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                          Text('تغيير', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.primary)),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      if (snap.hasError)
                        ErrorPanel(title: 'ما انفتح الكشف', body: '${snap.error}')
                      else if (s == null)
                        const SkeletonCards(count: 4)
                      else ...[
                        Row(children: [
                          _Total('انصرفله', MoneyText(s.paidTotal, color: t.money, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                          const SizedBox(width: 8),
                          _Total('سلف', MoneyText(s.advanceTotal, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                          const SizedBox(width: 8),
                          _Total(
                            'إله هالشهر',
                            s.thisMonth.paid
                                ? Text('انصرف ✓', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: t.money))
                                : MoneyText(s.thisMonth.net, sign: s.thisMonth.net.isNegative ? '−' : '', color: s.thisMonth.net.isNegative ? t.problem : t.info, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            strong: true,
                          ),
                        ]),
                        const SizedBox(height: 10),
                        if (s.employee.active)
                          Row(children: [
                            if (app.user.can('advance')) Expanded(child: AppButton('+ سلفة', height: 44, kind: AppButtonKind.outline, onPressed: () => showPayrollItemSheet(context, s.employee, 'advance'))),
                            if (app.user.can('dedBon')) ...[
                              const SizedBox(width: 6),
                              Expanded(child: AppButton('+ خصم', height: 44, kind: AppButtonKind.outline, onPressed: () => showPayrollItemSheet(context, s.employee, 'deduction'))),
                              const SizedBox(width: 6),
                              Expanded(child: AppButton('+ مكافأة', height: 44, kind: AppButtonKind.outline, onPressed: () => showPayrollItemSheet(context, s.employee, 'bonus'))),
                            ],
                          ]),
                        const SizedBox(height: 12),
                        if (s.months.every((m) => m.rows.isEmpty))
                          const EmptyState(icon: Icons.receipt_long_outlined, title: 'ما في حركات لهالموظف بهالفترة')
                        else
                          for (final m in s.months) _MonthBlock(m: m, employee: s.employee),
                      ],
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total(this.label, this.value, {this.strong = false});
  final String label;
  final Widget value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Expanded(
      child: Panel(
        radius: 12,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
        border: strong ? Border.all(color: t.primary, width: 2) : null,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
          FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: value),
        ]),
      ),
    );
  }
}

class _MonthBlock extends StatelessWidget {
  const _MonthBlock({required this.m, required this.employee});
  final StatementMonth m;
  final EmployeeRow employee;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final cur = m.month == currentMonth();
    final String state;
    final Color stateColor;
    if (m.payment != null) {
      state = 'انصرف ${Money(m.payment!.net).format()}';
      stateColor = t.money;
    } else if (cur) {
      state = 'الصافي لحد هلأ ${m.netSoFar.isNegative ? '−' : ''}${m.netSoFar.abs().format()}';
      stateColor = t.info;
    } else {
      state = 'لسا ما انصرف';
      stateColor = t.debt;
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 4, vertical: 6),
          child: Row(children: [
            Expanded(child: Text(monthLabel(m.month), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
            MoneyRichText(state, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: stateColor)),
          ]),
        ),
        if (m.rows.isEmpty)
          Panel(radius: 12, child: Text('ما في حركات لسا بهالشهر', style: TextStyle(fontSize: 13, color: t.textSecondary)))
        else
          Panel(
            radius: 14,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 4),
            child: Column(children: [
              for (final (i, r) in m.rows.indexed)
                Container(
                  decoration: BoxDecoration(border: i == 0 ? null : Border(top: BorderSide(color: t.divider))),
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _Tag(r.kind),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r.what, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text(r.when, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                        MoneyRichText(r.pending ? '${r.who} · لسا ما وصل السيرفر' : r.who, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                      ]),
                    ),
                    const SizedBox(width: 6),
                    MoneyText(r.amount, color: r.kind == 'pay' ? t.money : null, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ]),
                ),
            ]),
          ),
      ]),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.kind);
  final String kind;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (label, bg, fg) = switch (kind) {
      'advance' => ('سلفة', const Color(0xFFFFF4CC), const Color(0xFF4A3A00)),
      'deduction' => ('خصم', t.divider, t.text),
      'bonus' => ('مكافأة', t.tonalBg, t.info),
      _ => ('راتب', t.moneyBg, t.money),
    };
    return Pill(label, bg: bg, fg: fg);
  }
}

class _RangePicker extends StatelessWidget {
  const _RangePicker({required this.current});
  final _Range current;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('الفترة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (final r in _Range.values)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 8),
            child: ChoiceRow<_Range>(options: [r], selected: current, height: 48, label: (r) => _rangeLabel[r]!, onSelect: (r) => Navigator.of(context).pop(r)),
          ),
      ]),
    );
  }
}

class _EmployeePicker extends StatefulWidget {
  const _EmployeePicker({required this.list, required this.current});
  final List<(EmployeeRow, bool)> list;
  final String? current;

  @override
  State<_EmployeePicker> createState() => _EmployeePickerState();
}

class _EmployeePickerState extends State<_EmployeePicker> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final q = _q.text.trim();
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('كشف حساب مين؟', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: _q,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(hintText: 'اسم الموظف', prefixIcon: Icon(Icons.search_rounded, color: t.textSecondary)),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.5),
          child: ListView(shrinkWrap: true, children: [
            for (final (e, paid) in widget.list.where((x) => q.isEmpty || x.$1.name.contains(q)))
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 8),
                child: Panel(
                  radius: 12,
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
                  color: e.id == widget.current ? t.tonalBg : t.card,
                  border: Border.all(color: e.id == widget.current ? t.primary : t.border, width: e.id == widget.current ? 2 : 1),
                  onTap: () => Navigator.of(context).pop(e.id),
                  child: Row(children: [
                    InitialBox(e.name, size: 36),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        Text(e.role == 'instructor' ? 'مدرب' : 'موظف', style: TextStyle(fontSize: 12, color: t.textSecondary)),
                      ]),
                    ),
                    Text(
                      !e.active ? 'موقوف' : paid ? 'انصرف هالشهر ✓' : 'لسا هالشهر',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: !e.active ? t.textSecondary : paid ? t.money : t.debt),
                    ),
                  ]),
                ),
              ),
          ]),
        ),
        Text('الموظف الموقوف بيضل كشفه موجود · بيطلع باسم "موقوف"', style: TextStyle(fontSize: 12, color: t.textSecondary)),
      ]),
    );
  }
}
