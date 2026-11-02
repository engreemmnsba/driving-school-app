import 'package:drift/drift.dart' hide Column, Table;
import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/db/database.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/queries.dart';
import 'exam_actions.dart';
import 'exam_sheets.dart';

/// Canvas: UpcomingExams — Upcoming / Awaiting result / Results, grouped by day.
class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsData {
  const _ExamsData(this.exams, this.cars, this.ready, this.stages);
  final List<ExamRow> exams;
  final Map<String, String> cars;
  final List<StudentCard> ready;
  final Map<String, String> stages;
}

class _ExamsScreenState extends State<ExamsScreen> {
  late int _tab = widget.initialTab;
  Stream<_ExamsData>? _stream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = AppScope.of(context);
    _stream ??= watchLoad(app.db, () async {
      final db = app.db;
      final exams = await (db.select(db.exams)..where((t) => t.syncState.equals('rejected').not())).get();
      final cars = {for (final c in await db.select(db.cars).get()) c.id: c.name};
      final cards = await app.queries.studentCards();
      final stages = {for (final e in await db.select(db.enrollments).get()) e.id: e.stage};
      return _ExamsData(exams, cars, cards.where((c) => c.readyForExam).toList(), stages);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final today = todayStr();
    const tabs = ['الجاية', 'بانتظار النتيجة', 'النتائج'];
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<_ExamsData>(
          stream: _stream,
          builder: (context, snap) {
            final d = snap.data;
            final rows = (d?.exams ?? const <ExamRow>[]).where((x) => switch (_tab) {
                  0 => x.result == 'pending' && x.scheduledDate.compareTo(today) > 0,
                  1 => x.result == 'pending' && x.scheduledDate.compareTo(today) <= 0,
                  _ => x.result != 'pending',
                }).toList()
              ..sort((a, b) => _tab == 2 ? b.scheduledDate.compareTo(a.scheduledDate) : a.scheduledDate.compareTo(b.scheduledDate));
            final days = <String>[];
            for (final r in rows) {
              if (!days.contains(r.scheduledDate)) days.add(r.scheduledDate);
            }
            return ListView(padding: const EdgeInsetsDirectional.all(16), children: [
              const BackHeader(title: 'الاختبارات'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsetsDirectional.all(4),
                decoration: BoxDecoration(color: t.card, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  for (final (i, label) in tabs.indexed)
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(9),
                        onTap: () => setState(() => _tab = i),
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: _tab == i ? t.primary : Colors.transparent, borderRadius: BorderRadius.circular(9)),
                          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _tab == i ? t.onPrimary : t.text)),
                        ),
                      ),
                    ),
                ]),
              ),
              if (_tab == 0 && (d?.ready.isNotEmpty ?? false)) ...[
                const SizedBox(height: 10),
                Panel(
                  radius: 12,
                  color: const Color(0xFFFFF4CC),
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 6),
                  child: Row(children: [
                    Expanded(
                      child: Text('${d!.ready.length} وصلوا الحد الأدنى ولسا ما انحجزلهم · ${d.ready.take(3).map((c) => c.name.split(' ').first).join('، ')}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4A3A00))),
                    ),
                    TextButton(onPressed: () => _pickReady(context, d.ready), child: const Text('حجز')),
                  ]),
                ),
              ],
              const SizedBox(height: 12),
              if (d == null)
                const SkeletonCards()
              else if (rows.isEmpty)
                EmptyState(icon: Icons.event_available_outlined, title: switch (_tab) { 0 => 'ما في اختبارات جاية', 1 => 'ما في نتائج مستنية', _ => 'لسا ما في نتائج' })
              else
                for (final day in days) ...[
                  Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 6, top: 4),
                    child: Text(dateLabel(day), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.textSecondary)),
                  ),
                  for (final x in rows.where((r) => r.scheduledDate == day)) _ExamTile(x: x, data: d),
                ],
            ]);
          },
        ),
      ),
    );
  }

  void _pickReady(BuildContext context, List<StudentCard> ready) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: ListView(shrinkWrap: true, padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20), children: [
          const Text('حجز اختبار لمين؟', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final c in ready)
            ListTile(
              title: Text(c.name),
              subtitle: Text('${stageLabel(c.stage)} ${c.done}/${c.planned} · ${c.carName}'),
              onTap: () {
                Navigator.of(sheet).pop();
                showBookExam(context, c);
              },
            ),
        ]),
      ),
    );
  }
}

class _ExamTile extends StatelessWidget {
  const _ExamTile({required this.x, required this.data});
  final ExamRow x;
  final _ExamsData data;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    final due = x.result == 'pending' && x.scheduledDate.compareTo(todayStr()) <= 0;
    final (status, bg, fg) = switch (x.result) {
      'passed' => ('نجح ✓', t.moneyBg, t.money),
      'failed' => ('رسب', t.problem.withValues(alpha: 0.12), t.problem),
      'absent' => ('ما حضر', t.divider, t.textSecondary),
      _ => due ? ('النتيجة؟', const Color(0xFFFFF4CC), const Color(0xFF4A3A00)) : ('محجوز', t.tonalBg, t.info),
    };
    final feeLine = x.fee > 0 ? 'رسوم مدفوعة ✓' : 'مشمول بالتسجيل';
    final car = x.carId == null ? '' : ' · ${data.cars[x.carId] ?? ''}';
    final history = postponeHistoryLine(x);
    final latestOfStudent = data.exams.where((e) => e.enrollmentId == x.enrollmentId).every((e) => e.at == null || x.at == null || e.at!.compareTo(x.at!) <= 0);
    final stage = data.stages[x.enrollmentId];
    final canRetake = (x.result == 'failed' || x.result == 'absent') && latestOfStudent && stage != 'withdrawn' && app.user.can('exam');
    final canGraduate = x.result == 'passed' && x.type == 'practical' && stage == 'passed' && app.user.can('exam');
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Panel(
        radius: 14,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(x.studentName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text('${examTypeLabel[x.type]} · محاولة ${x.attempt}$car · $feeLine${x.syncState == 'pending' ? ' · مستني مزامنة' : ''}',
                    style: TextStyle(fontSize: 12, color: t.textSecondary)),
                if (history.isNotEmpty) Text(history, style: TextStyle(fontSize: 12, color: t.warning)),
              ]),
            ),
            Pill(status, bg: bg, fg: fg),
          ]),
          if (x.result == 'pending' && app.user.can('exam')) ...[
            const SizedBox(height: 10),
            Row(children: [
              if (due) ...[
                Expanded(child: AppButton('نجح', kind: AppButtonKind.success, height: 44, onPressed: () => recordResult(context, x, 'passed'))),
                const SizedBox(width: 6),
                Expanded(child: AppButton('رسب', kind: AppButtonKind.outline, height: 44, onPressed: () => recordResult(context, x, 'failed'))),
                const SizedBox(width: 6),
                Expanded(child: AppButton('ما حضر', kind: AppButtonKind.outline, height: 44, onPressed: () => recordResult(context, x, 'absent'))),
                const SizedBox(width: 6),
              ],
              AppButton('تأجيل', kind: AppButtonKind.tonal, height: 44, onPressed: () => showPostponeExam(context, x)),
            ]),
          ],
          if (canRetake) ...[
            const SizedBox(height: 10),
            AppButton('حجز إعادة', kind: AppButtonKind.accent, height: 44, expand: true, onPressed: () async {
              final card = await app.queries.studentCard(x.enrollmentId);
              if (card != null && context.mounted) showBookExam(context, card);
            }),
          ],
          if (canGraduate) ...[
            const SizedBox(height: 10),
            AppButton('تخريج وأرشفة', height: 44, expand: true, onPressed: () async {
              final card = await app.queries.studentCard(x.enrollmentId);
              if (card != null && context.mounted) showGraduate(context, card);
            }),
          ],
        ]),
      ),
    );
  }
}

