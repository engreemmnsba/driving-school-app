import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../data/queries.dart';
import '../../data/staff_queries.dart';
import 'employee_statement_screen.dart';
import 'payroll_sheets.dart';

class _PayrollData {
  const _PayrollData(this.view, this.months, this.olderUnpaid);
  final PayrollMonthView view;
  final List<MonthState> months;
  final MonthState? olderUnpaid;
}

/// Canvas Payroll (المال ← الرواتب): one payroll month at a time, opens on the current month.
class PayrollView extends StatefulWidget {
  const PayrollView({super.key});

  @override
  State<PayrollView> createState() => _PayrollViewState();
}

class _PayrollViewState extends State<PayrollView> {
  String _month = currentMonth();
  Stream<_PayrollData>? _stream;
  String? _streamMonth;

  Stream<_PayrollData> _watch(BuildContext context) {
    if (_stream != null && _streamMonth == _month) return _stream!;
    final app = AppScope.of(context);
    final q = app.staff.queries;
    final month = _month;
    _streamMonth = month;
    return _stream = watchLoad(app.db, () async {
      final months = await q.payrollMonths();
      return _PayrollData(await q.payrollMonth(month), months, month == currentMonth() ? await q.olderUnpaid(month) : null);
    });
  }

  void _go(String m) => setState(() => _month = m);

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    return StreamBuilder<_PayrollData>(
      stream: _watch(context),
      builder: (context, snap) {
        if (snap.hasError) {
          return Padding(padding: const EdgeInsetsDirectional.all(16), child: ErrorPanel(title: 'ما انفتحت الرواتب', body: '${snap.error}'));
        }
        final d = snap.data;
        if (d == null) return const Padding(padding: EdgeInsetsDirectional.all(16), child: SkeletonCards(count: 4));
        final v = d.view;
        final months = d.months.map((m) => m.month).toList(); // newest first
        final idx = months.indexOf(_month);
        final hasOlder = idx >= 0 && idx < months.length - 1;
        final hasNewer = idx > 0;
        return ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
          children: [
            Panel(
              radius: 12,
              padding: const EdgeInsetsDirectional.all(6),
              child: Row(children: [
                _NavButton('السابق', onTap: hasOlder ? () => _go(months[idx + 1]) : null),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      final m = await showPayrollMonthPicker(context, d.months, _month);
                      if (m != null) _go(m);
                    },
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Flexible(child: Text('رواتب ${monthLabel(_month)}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
                          Icon(Icons.arrow_drop_down_rounded, color: t.primary),
                        ]),
                        Text(
                          v.lines.isEmpty ? 'ما في موظفين بهالشهر' : v.unpaid > 0 ? '${v.unpaid} موظف لسا ما انصرفلهم' : 'كل الرواتب انصرفت ✓',
                          style: TextStyle(fontSize: 12, color: v.unpaid > 0 ? t.debt : t.money),
                        ),
                      ]),
                    ),
                  ),
                ),
                _NavButton('التالي', onTap: hasNewer ? () => _go(months[idx - 1]) : null),
              ]),
            ),
            if (v.locked) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: t.divider, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(Icons.lock_outline_rounded, size: 16, color: t.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(child: Text('الشهر مثبّت · للقراءة بس · أي تصحيح بيصير بالشهر المفتوح', style: TextStyle(fontSize: 12, color: t.textSecondary))),
                ]),
              ),
            ],
            if (d.olderUnpaid != null) ...[
              const SizedBox(height: 10),
              Material(
                color: const Color(0xFFFFF4CC),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _go(d.olderUnpaid!.month),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 12),
                    child: Row(children: [
                      Expanded(
                        child: Text('رواتب ${monthLabel(d.olderUnpaid!.month)}: ${d.olderUnpaid!.unpaid} موظف لسا ما انصرفله',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4A3A00))),
                      ),
                      const Text('عرض', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4A3A00))),
                    ]),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(children: [
              _Tile('الرواتب', MoneyText(v.salaries, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
              const SizedBox(width: 8),
              _Tile('السلف', MoneyText(v.advances, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
              const SizedBox(width: 8),
              _Tile('باقي للصرف', MoneyText(v.left, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), strong: true),
            ]),
            const SizedBox(height: 10),
            if (v.lines.isEmpty)
              const EmptyState(icon: Icons.badge_outlined, title: 'ما في موظفين بهالشهر', body: 'الموظفين والمدربين بينضافوا من المزيد ← المستخدمون، والراتب بينكتب وقت الإضافة')
            else
              for (final l in v.lines)
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 10),
                  child: _EmployeeCard(line: l, month: _month, locked: v.locked, canAdvance: app.user.can('advance'), canPay: app.user.can('paySalary')),
                ),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const EmployeeStatementScreen())),
                child: const Text('كشف حساب موظف (خصم · مكافأة · سلف) ←', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton(this.label, {required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: t.bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: onTap == null ? t.muted : t.text)),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.label, this.value, {this.strong = false});
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
          Text(label, style: TextStyle(fontSize: 12, color: strong ? t.info : t.textSecondary, fontWeight: strong ? FontWeight.w600 : FontWeight.w400)),
          const SizedBox(height: 2),
          FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: value),
        ]),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({required this.line, required this.month, required this.locked, required this.canAdvance, required this.canPay});
  final PayrollLine line;
  final String month;
  final bool locked;
  final bool canAdvance;
  final bool canPay;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = line;
    final open = !l.paid && !locked;
    void statement() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => EmployeeStatementScreen(employeeId: l.employee.id)));
    return Panel(
      radius: 14,
      padding: const EdgeInsetsDirectional.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          InitialBox(l.employee.name),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.employee.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              MoneyRichText(l.line, style: TextStyle(fontSize: 12, color: t.textSecondary)),
              if (l.paidInfo != null) Text(l.pending ? '${l.paidInfo} · لسا ما وصل السيرفر' : l.paidInfo!, style: TextStyle(fontSize: 12, color: t.money)),
              if (!l.employee.active) Text('موقوف', style: TextStyle(fontSize: 12, color: t.textSecondary)),
            ]),
          ),
          const SizedBox(width: 6),
          MoneyText(l.net, sign: l.net.isNegative ? '−' : '', color: l.net.isNegative ? t.problem : null, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          l.paid ? Pill('انصرف ✓', bg: t.moneyBg, fg: t.money) : const Pill('لسا', bg: Color(0xFFFFF4CC), fg: Color(0xFF4A3A00)),
        ]),
        if (open) ...[
          const SizedBox(height: 8),
          Row(children: [
            if (canAdvance) ...[
              Expanded(child: AppButton('+ سلفة', height: 44, kind: AppButtonKind.outline, onPressed: () => showPayrollItemSheet(context, l.employee, 'advance'))),
              const SizedBox(width: 6),
            ],
            Expanded(child: AppButton('الكشف', height: 44, kind: AppButtonKind.outline, onPressed: statement)),
            if (canPay) ...[
              const SizedBox(width: 6),
              Expanded(child: AppButton('صرف', height: 44, onPressed: () => showPaySalarySheet(context, l, month))),
            ],
          ]),
        ] else
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(onPressed: statement, child: const Text('الكشف', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
          ),
      ]),
    );
  }
}
