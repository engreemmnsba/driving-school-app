import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/period_picker.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../core/util/period.dart';
import '../../data/ops_queries.dart';
import '../../data/queries.dart';
import '../home/home_screen.dart' show openStudent;
import '../staff/employee_statement_screen.dart';

(Color, Color) _tagColors(BuildContext context, String tag) {
  final t = context.tokens;
  return switch (tag) {
    'دفعة' => (t.moneyBg, t.money),
    'درس' => (t.tonalBg, t.info),
    'مصروف' || 'تعديل' || 'رواتب' => (const Color(0xFFFFF4CC), const Color(0xFF4A3A00)),
    'أرشفة' => (const Color(0xFFFBE4E2), const Color(0xFF8C1D17)),
    _ => (t.divider, t.textSecondary),
  };
}

/// Canvas ActivityLog: every operation, who did it and when; edits show "from A to B".
class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  Period _period = Period.of(PeriodKind.today);
  String? _actor;
  String? _tag;
  final _q = TextEditingController();
  Stream<(List<LogEntry>, List<(String, String)>)>? _stream;
  String? _key;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Stream<(List<LogEntry>, List<(String, String)>)> _watch(BuildContext context) {
    final key = '${_period.from}|${_period.to}|$_actor|$_tag|${_q.text}';
    if (_stream != null && key == _key) return _stream!;
    final app = AppScope.of(context);
    final p = _period;
    final actor = _actor;
    final tag = _tag;
    final q = _q.text;
    _key = key;
    return _stream = watchLoad(app.db, () async => (await app.ops.queries.log(p, actorId: actor, tag: tag, q: q), await app.ops.queries.logActors()));
  }

  Widget _chip(BuildContext context, String label, bool selected, VoidCallback onTap) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: t.tonalBg,
        backgroundColor: t.card,
        side: BorderSide(color: selected ? t.primary : t.border, width: selected ? 2 : 1),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? t.info : t.text),
        onSelected: (_) => onTap(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<(List<LogEntry>, List<(String, String)>)>(
          stream: _watch(context),
          builder: (context, snap) {
            final d = snap.data;
            final entries = d?.$1;
            return ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
              children: [
                const BackHeader(title: 'سجل العمليات'),
                const SizedBox(height: 12),
                TextField(
                  controller: _q,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(hintText: 'بحث باسم طالب أو تفصيلة', prefixIcon: Icon(Icons.search_rounded, color: t.textSecondary)),
                ),
                const SizedBox(height: 8),
                PeriodButton(period: _period, onChanged: (p) => setState(() => _period = p)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _chip(context, 'كل المستخدمين', _actor == null, () => setState(() => _actor = null)),
                    for (final (id, name) in d?.$2 ?? const <(String, String)>[]) _chip(context, name, _actor == id, () => setState(() => _actor = _actor == id ? null : id)),
                  ]),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _chip(context, 'كل الأنواع', _tag == null, () => setState(() => _tag = null)),
                    for (final tag in logTags) _chip(context, tag, _tag == tag, () => setState(() => _tag = _tag == tag ? null : tag)),
                  ]),
                ),
                const SizedBox(height: 10),
                if (snap.hasError)
                  ErrorPanel(title: 'ما انفتح السجل', body: '${snap.error}')
                else if (entries == null)
                  const SkeletonCards(count: 5, height: 64)
                else ...[
                  Text(
                    [
                      switch (entries.length) { 1 => 'عملية وحدة', 2 => 'عمليتين', final n when n <= 10 => '$n عمليات', final n => '$n عملية' },
                      _period.label,
                      ?d?.$2.where((a) => a.$1 == _actor).map((a) => a.$2).firstOrNull,
                      ?_tag,
                    ].join(' · '),
                    style: TextStyle(fontSize: 13, color: t.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  if (entries.isEmpty)
                    const EmptyState(icon: Icons.history_rounded, title: 'ما في عمليات بهالفلاتر', body: 'السجل بيوصل من السيرفر مع المزامنة')
                  else
                    for (final e in entries) _LogTile(e: e),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.e});
  final LogEntry e;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (bg, fg) = _tagColors(context, e.tag);
    final change = e.changeLine;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Panel(
        radius: 12,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ActivityDetailScreen(entry: e))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 56,
            child: Column(children: [
              Text(e.time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Pill(e.tag, bg: bg, fg: fg),
            ]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              MoneyRichText('${verbOf(e.row)}: ${e.row.recordLabel}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text([e.row.actorName, if (e.row.lateAfterClose) 'بعد إغلاق اليوم'].join(' · '), style: TextStyle(fontSize: 12, color: t.textSecondary)),
              if (change != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFFF4CC), borderRadius: BorderRadius.circular(8)),
                  child: MoneyRichText(change, style: const TextStyle(fontSize: 12, height: 1.6, color: Color(0xFF4A3A00))),
                ),
              ],
            ]),
          ),
          Icon(Icons.chevron_left_rounded, color: t.muted),
        ]),
      ),
    );
  }
}

/// Canvas ActivityDetail: the full sentence, who/when/device/reason, and a before/after table.
class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({super.key, required this.entry});
  final LogEntry entry;

  Future<void> _openRecord(BuildContext context) async {
    final app = AppScope.of(context);
    final r = entry.row;
    if (r.entity == 'payroll_item' || r.entity == 'salary_payment' || r.entity == 'employee') {
      String? employeeId = r.entity == 'employee' ? r.recordId : null;
      if (r.entity == 'payroll_item') {
        employeeId = (await (app.db.select(app.db.payrollItems)..where((t) => t.id.equals(r.recordId))).getSingleOrNull())?.employeeId;
      } else if (r.entity == 'salary_payment') {
        employeeId = (await (app.db.select(app.db.salaryPayments)..where((t) => t.id.equals(r.recordId))).getSingleOrNull())?.employeeId;
      }
      if (employeeId != null && context.mounted) {
        await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => EmployeeStatementScreen(employeeId: employeeId)));
      }
      return;
    }
    final enrollment = await app.ops.queries.enrollmentOf(r);
    if (!context.mounted) return;
    if (enrollment == null) {
      showErrorSnack(context, 'هالسجل ما إله صفحة على هالجهاز');
      return;
    }
    openStudent(context, enrollment);
  }

  bool get _hasRecord => const {'student', 'enrollment', 'lesson', 'payment', 'discount', 'exam', 'payroll_item', 'salary_payment', 'employee'}.contains(entry.row.entity);

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final app = AppScope.of(context);
    final r = entry.row;
    final (bg, fg) = _tagColors(context, entry.tag);
    final when = entry.local == null ? '' : '${dayHeader(entry.local!)}/${entry.local!.year} · ${hhmm(entry.local!)}';
    final device = r.deviceId == null ? '—' : r.deviceId == app.session.deviceId ? 'هالجهاز' : 'جهاز ثاني';
    final sentence = [
      '${r.actorName} · ${verbOf(r)}: ${r.recordLabel}',
      for (final c in entry.changes) '${c.field}: من ${c.before} إلى ${c.after}',
    ].join('\n');
    Widget cell(String label, String value) => Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
            MoneyRichText(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ]),
        );
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
          children: [
            const BackHeader(title: 'تفاصيل العملية'),
            const SizedBox(height: 12),
            Panel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Pill(entry.tag, bg: bg, fg: fg),
                  const SizedBox(width: 8),
                  Expanded(child: MoneyRichText(r.recordLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                ]),
                const SizedBox(height: 10),
                MoneyRichText(sentence, style: const TextStyle(fontSize: 15, height: 1.7)),
                const SizedBox(height: 12),
                Row(children: [cell('مين', r.actorName), cell('متى', when)]),
                const SizedBox(height: 10),
                Row(children: [cell('من أي جهاز', device), cell('السبب', r.reason ?? '—')]),
                if (r.lateAfterClose) ...[
                  const SizedBox(height: 10),
                  Text('انسجّلت بعد إغلاق اليوم', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: t.warning)),
                ],
              ]),
            ),
            if (entry.changes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Panel(
                padding: EdgeInsetsDirectional.zero,
                child: Column(children: [
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 10),
                    color: t.divider,
                    child: const Row(children: [
                      Expanded(flex: 11, child: Text('الحقل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                      Expanded(flex: 10, child: Text('قبل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                      Expanded(flex: 10, child: Text('بعد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                    ]),
                  ),
                  for (final c in entry.changes)
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: t.divider))),
                      child: Row(children: [
                        Expanded(flex: 11, child: Text(c.field, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                        Expanded(flex: 10, child: MoneyRichText(c.before, style: const TextStyle(fontSize: 13, color: Color(0xFF8C1D17), decoration: TextDecoration.lineThrough))),
                        Expanded(flex: 10, child: MoneyRichText(c.after, style: TextStyle(fontSize: 13, color: t.money, fontWeight: FontWeight.w700))),
                      ]),
                    ),
                ]),
              ),
            ],
            const SizedBox(height: 16),
            if (_hasRecord) AppButton('فتح السجل', kind: AppButtonKind.outline, height: 50, expand: true, onPressed: () => _openRecord(context)),
            const SizedBox(height: 10),
            Text('السجل ما بينحذف ولا بيتعدّل · أي تصحيح بيضيف عملية جديدة', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: t.textSecondary)),
          ],
        ),
      ),
    );
  }
}
