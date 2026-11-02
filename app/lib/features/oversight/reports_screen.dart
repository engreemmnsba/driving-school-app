import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/app_scope.dart';
import '../../core/db/database.dart';
import '../../core/pdf/pdf_export.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/period_picker.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../core/util/period.dart';
import '../../data/ops_queries.dart';
import '../../data/queries.dart';
import '../../data/staff_queries.dart' show monthLabel;
import '../staff/payroll_sheets.dart' show staffSheet;
import '../system/backup_screen.dart' show exportTables;
import '../../core/export/csv_export.dart';

const _kindLabel = {'cash': 'كاش', 'wallet': 'محافظ', 'bank': 'بنوك'};

/// Canvas Reports (tab): money and lessons for a period, with filters, PDF and month lock.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Period _period = Period.of(PeriodKind.month);
  String? _employee;
  String? _car;
  String? _license;
  Stream<_Data>? _stream;
  String? _key;
  bool _busy = false;

  String? get _fullMonth => switch (_period.kind) {
        PeriodKind.month || PeriodKind.lastMonth => _period.from.substring(0, 7),
        _ => null,
      };

  Stream<_Data> _watch(BuildContext context) {
    final key = '${_period.from}|${_period.to}|$_employee|$_car|$_license';
    if (_stream != null && key == _key) return _stream!;
    final app = AppScope.of(context);
    final p = _period;
    final (e, c, l) = (_employee, _car, _license);
    final month = _fullMonth;
    _key = key;
    return _stream = watchLoad(app.db, () async {
      final q = app.queries;
      return _Data(
        await app.ops.queries.report(p, employeeId: e, carId: c, licenseTypeId: l),
        await app.staff.queries.instructors(),
        await q.cars(),
        await q.licenseTypes(),
        month == null ? null : await app.ops.queries.monthLock(month),
      );
    });
  }

  Future<String?> _pick(String title, List<(String, String)> options, String? current) => staffSheet<String>(
        context,
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            for (final (id, label) in [('', 'الكل'), ...options])
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 8),
                child: ChoiceRow<String>(options: [id], selected: current ?? '', height: 48, label: (_) => label, onSelect: (v) => Navigator.of(context).pop(v)),
              ),
          ]),
        ),
      );

  Future<void> _lock(MonthLockState st) async {
    final app = AppScope.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text('تثبيت ${monthLabel(st.month)}؟'),
        content: const Text('بعد التثبيت ما بينفع تسجيل أو تعديل أي إشي بتاريخ بهالشهر. أي تصحيح بيصير بالشهر المفتوح وبينسجّل.', style: TextStyle(height: 1.7)),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(false), child: const Text('لا')),
          TextButton(onPressed: () => Navigator.of(d).pop(true), child: const Text('تثبيت')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await app.ops.lockMonth(st.month);
      app.syncSoon();
      if (mounted) showUndoSnack(context, 'انثبّت ${monthLabel(st.month)} · بيوصل للسيرفر مع المزامنة');
    } catch (e) {
      if (mounted) showErrorSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _unlock(MonthLockState st) async {
    final app = AppScope.of(context);
    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text('فتح ${monthLabel(st.month)}؟'),
        content: TextField(controller: reason, autofocus: true, decoration: const InputDecoration(hintText: 'السبب (مطلوب)')),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(false), child: const Text('لا')),
          TextButton(onPressed: () => Navigator.of(d).pop(true), child: const Text('فتح الشهر')),
        ],
      ),
    );
    final text = reason.text;
    reason.dispose();
    if (ok != true || !mounted) return;
    try {
      await app.ops.unlockMonth(st.month, text);
      app.syncSoon();
      if (mounted) showUndoSnack(context, 'انفتح ${monthLabel(st.month)}');
    } catch (e) {
      if (mounted) showErrorSnack(context, '$e');
    }
  }

  Future<void> _excel() async {
    final app = AppScope.of(context);
    setState(() => _busy = true);
    try {
      final tables = await exportTables(app.db, p: _period, only: const {'payments', 'expenses', 'movements', 'lessons', 'payroll'});
      await shareCsv(tables, text: 'تقرير ${_period.label}');
    } catch (e) {
      if (mounted) showErrorSnack(context, 'ما انعمل الملف: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pdf(_Data d, {required bool print}) async {
    setState(() => _busy = true);
    try {
      final k = await PdfKit.load();
      final r = d.report;
      final doc = k.document();
      final filters = [
        if (_employee != null) 'المدرب: ${d.instructors.where((e) => e.id == _employee).map((e) => e.name).firstOrNull ?? ''}',
        if (_car != null) d.cars.where((c) => c.id == _car).map((c) => c.name).firstOrNull ?? '',
        if (_license != null) 'الرخصة: ${d.licenses.where((l) => l.id == _license).map((l) => l.name).firstOrNull ?? ''}',
      ];
      doc.addPage(k.page((_) => [
            k.header('مدرسة القيادة', 'تقرير ${_period.label}', '${_period.from} ← ${_period.to}'),
            if (filters.isNotEmpty) pw.Text(filters.join(' · '), style: k.style(color: PdfKit.muted)),
            k.section('المال', [
              k.row('الإيرادات (دفعات الطلاب)', r.revenue.format(), color: PdfKit.green),
              for (final e in r.byKind.entries) k.row('   ${_kindLabel[e.key] ?? e.key}', e.value.format()),
              k.row('المصروفات', r.expenses.format()),
              k.row('الرواتب (راتب + مكافآت − خصومات)', r.salaries.format()),
              k.row('الصافي', '${r.net.isNegative ? '−' : ''}${r.net.abs().format()}', strong: true),
              k.row('ديون على الطلاب هلأ', r.debts.format(), color: PdfKit.amber),
            ]),
            k.section('الدروس والنتائج', [
              for (final (name, n) in r.lessonsByInstructor) k.row(name, '$n درس', isMoney: false),
              k.row('دروس نظري', '${r.theoryLessons}', isMoney: false),
              k.row('دروس عملي', '${r.practicalLessons}', isMoney: false),
              k.row('اجتازوا النظري', '${r.passedTheory}', isMoney: false),
              k.row('اجتازوا العملي', '${r.passedPractical}', isMoney: false),
              k.row('محاولات الاختبار · نسبة النجاح', '${r.examAttempts} · ${r.passRate}%', isMoney: false),
            ]),
            k.section('الطلاب حسب المرحلة', [for (final e in r.studentsByStage.entries) k.row(e.key, '${e.value}', isMoney: false)]),
          ]));
      final bytes = await doc.save();
      final name = 'تقرير ${_period.from}_${_period.to}.pdf';
      if (print) {
        await printPdf(bytes, name);
      } else {
        await sharePdf(bytes, name);
      }
    } catch (e) {
      if (mounted) showErrorSnack(context, 'ما انعمل الـ PDF: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<_Data>(
          stream: _watch(context),
          builder: (context, snap) {
            final d = snap.data;
            final r = d?.report;
            return ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 24),
              children: [
                Row(children: [
                  const Expanded(child: Text('التقارير', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
                  if (app.user.can('export') && d != null) ...[
                    AppButton('Excel', height: 44, kind: AppButtonKind.outline, onPressed: _busy ? null : _excel),
                    const SizedBox(width: 6),
                    AppButton('PDF', height: 44, kind: AppButtonKind.outline, busy: _busy, onPressed: () => _pdf(d, print: false)),
                    const SizedBox(width: 6),
                    AppButton('طباعة', height: 44, kind: AppButtonKind.outline, onPressed: _busy ? null : () => _pdf(d, print: true)),
                  ],
                ]),
                const SizedBox(height: 12),
                PeriodButton(period: _period, onChanged: (p) => setState(() => _period = p)),
                const SizedBox(height: 8),
                if (d != null)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _FilterChip(
                        label: _employee == null ? 'كل المدربين' : d.instructors.where((e) => e.id == _employee).map((e) => e.name).firstOrNull ?? 'مدرب',
                        active: _employee != null,
                        onTap: () async {
                          final v = await _pick('المدرب', [for (final e in d.instructors) (e.id, e.name)], _employee);
                          if (v != null) setState(() => _employee = v.isEmpty ? null : v);
                        },
                      ),
                      _FilterChip(
                        label: _car == null ? 'كل السيارات' : d.cars.where((c) => c.id == _car).map((c) => c.name).firstOrNull ?? 'سيارة',
                        active: _car != null,
                        onTap: () async {
                          final v = await _pick('السيارة', [for (final c in d.cars) (c.id, c.name)], _car);
                          if (v != null) setState(() => _car = v.isEmpty ? null : v);
                        },
                      ),
                      _FilterChip(
                        label: _license == null ? 'الرخصة' : d.licenses.where((l) => l.id == _license).map((l) => l.name).firstOrNull ?? 'رخصة',
                        active: _license != null,
                        onTap: () async {
                          final v = await _pick('الرخصة', [for (final l in d.licenses) (l.id, l.name)], _license);
                          if (v != null) setState(() => _license = v.isEmpty ? null : v);
                        },
                      ),
                    ]),
                  ),
                const SizedBox(height: 12),
                if (snap.hasError)
                  ErrorPanel(title: 'ما انفتحت التقارير', body: '${snap.error}')
                else if (r == null)
                  const SkeletonCards(count: 4, height: 90)
                else ...[
                  Row(children: [
                    _Tile('الإيرادات', MoneyText(r.revenue, color: t.money, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
                    const SizedBox(width: 10),
                    _Tile('المصروفات والرواتب', MoneyText(r.spending, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    _Tile('الصافي', MoneyText(r.net, sign: r.net.isNegative ? '−' : '', color: t.onPrimary, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)), strong: true),
                    const SizedBox(width: 10),
                    _Tile('ديون على الطلاب هلأ', MoneyText(r.debts, color: t.debt, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
                  ]),
                  const SizedBox(height: 12),
                  Panel(
                    radius: 14,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      const Text('الإيرادات حسب طريقة الدفع', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      for (final e in r.byKind.entries)
                        Padding(
                          padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
                          child: Row(children: [
                            SizedBox(width: 56, child: Text(_kindLabel[e.key] ?? e.key, style: const TextStyle(fontSize: 13))),
                            Expanded(child: ProgressLine(r.revenue.agorot <= 0 ? 0 : e.value.agorot / r.revenue.agorot, height: 10)),
                            const SizedBox(width: 8),
                            SizedBox(width: 76, child: Align(alignment: AlignmentDirectional.centerEnd, child: MoneyText(e.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)))),
                          ]),
                        ),
                      const SizedBox(height: 6),
                      Text('المصروفات ${r.expenses.format()} · الرواتب ${r.salaries.format()} (السلف ما بتنحسب مرتين)', style: TextStyle(fontSize: 12, color: t.textSecondary)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Panel(
                    radius: 14,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      const Text('الدروس والنتائج', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (r.lessonsByInstructor.isEmpty) Text('ما في دروس بهالفترة', style: TextStyle(fontSize: 13, color: t.textSecondary)),
                      for (final (name, n) in r.lessonsByInstructor) _line('المدرب $name', '$n درس'),
                      Divider(color: t.border),
                      _line('دروس نظري · عملي', '${r.theoryLessons} · ${r.practicalLessons}'),
                      _line('اجتازوا النظري', '${r.passedTheory}'),
                      _line('اجتازوا العملي', '${r.passedPractical}'),
                      _line('محاولات الاختبار', r.examAttempts == 0 ? '0' : '${r.examAttempts} · نجاح ${r.passRate}%'),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Panel(
                    radius: 14,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      const Text('الطلاب حسب المرحلة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (r.studentsByStage.isEmpty) Text('ما في طلاب', style: TextStyle(fontSize: 13, color: t.textSecondary)),
                      for (final e in r.studentsByStage.entries) _line(e.key, '${e.value}'),
                    ]),
                  ),
                  if (d!.month != null && app.user.can('lockMonth')) ...[
                    const SizedBox(height: 12),
                    _MonthLockPanel(st: d.month!, busy: _busy, onLock: () => _lock(d.month!), onUnlock: app.user.isAdmin ? () => _unlock(d.month!) : null),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _line(String label, String value) => Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 3),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      );
}

class _Data {
  const _Data(this.report, this.instructors, this.cars, this.licenses, this.month);
  final ReportData report;
  final List<EmployeeRow> instructors;
  final List<CarRow> cars;
  final List<LicenseTypeRow> licenses;
  final MonthLockState? month;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Material(
        color: active ? t.tonalBg : t.card,
        shape: StadiumBorder(side: BorderSide(color: active ? t.primary : Colors.transparent, width: 2)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
            child: Text('$label ▾', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? t.info : t.text)),
          ),
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
        radius: 14,
        color: strong ? t.primary : null,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 12, color: strong ? t.onPrimary.withValues(alpha: 0.8) : t.textSecondary)),
          const SizedBox(height: 4),
          FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: value),
        ]),
      ),
    );
  }
}

class _MonthLockPanel extends StatelessWidget {
  const _MonthLockPanel({required this.st, required this.busy, required this.onLock, required this.onUnlock});
  final MonthLockState st;
  final bool busy;
  final VoidCallback onLock;
  final VoidCallback? onUnlock;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isCurrent = st.month == todayStr().substring(0, 7);
    if (st.locked) {
      return Panel(
        radius: 14,
        color: t.divider,
        child: Row(children: [
          Icon(Icons.lock_rounded, color: t.textSecondary),
          const SizedBox(width: 8),
          Expanded(child: Text('${monthLabel(st.month)} مثبّت${st.lock?.lockedByName == null ? '' : ' · ${st.lock!.lockedByName}'}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
          if (onUnlock != null) TextButton(onPressed: onUnlock, child: const Text('فتح الشهر')),
        ]),
      );
    }
    if (isCurrent) {
      return Text('تثبيت ${monthLabel(st.month)} بيصير بعد ما يخلص الشهر وتنسكّر كل أيامه', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: t.textSecondary));
    }
    if (st.openDays.isNotEmpty) {
      return Panel(
        radius: 14,
        color: const Color(0xFFFFF4CC),
        child: Text(
          'قبل تثبيت ${monthLabel(st.month)}: في ${st.openDays.length} ${st.openDays.length == 1 ? 'يوم' : 'أيام'} مش مسكّرة (${st.openDays.take(4).map(dateShort).join('، ')}${st.openDays.length > 4 ? '…' : ''})',
          style: const TextStyle(fontSize: 13, color: Color(0xFF4A3A00), height: 1.6),
        ),
      );
    }
    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        onPressed: busy ? null : onLock,
        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF14211F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        icon: const Icon(Icons.lock_outline_rounded),
        label: Text('تثبيت تقرير ${monthLabel(st.month)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
