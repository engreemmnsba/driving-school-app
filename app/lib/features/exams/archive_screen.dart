import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/db/database.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/queries.dart';
import '../home/home_screen.dart' show openStudent;

/// Canvas: Archive — graduates (final summary, kept forever) and withdrawn records; search by name or ID.
class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  bool _graduates = true;
  final _q = TextEditingController();
  Stream<(List<EnrollmentRow>, Map<String, String>, Map<String, String>, Map<String, StudentSummaryRow>)>? _stream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = AppScope.of(context);
    _stream ??= watchLoad(app.db, () async {
      final db = app.db;
      final rows = await (db.select(db.enrollments)..where((t) => t.stage.isIn(['graduated', 'withdrawn']))).get();
      final lts = {for (final l in await db.select(db.licenseTypes).get()) l.id: l.name};
      final ids = {for (final s in await db.select(db.students).get()) s.id: s.nationalId};
      final sums = {for (final s in await db.select(db.studentSummaries).get()) s.enrollmentId: s};
      return (rows, lts, ids, sums);
    });
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: _stream,
          builder: (context, snap) {
            final d = snap.data;
            final q = _q.text.trim();
            final rows = (d?.$1 ?? const <EnrollmentRow>[])
                .where((e) => (_graduates ? e.stage == 'graduated' : e.stage == 'withdrawn') && (q.isEmpty || e.studentName.contains(q) || (d!.$3[e.studentId] ?? '').contains(q)))
                .toList()
              ..sort((a, b) => (b.graduatedOn ?? b.registeredOn).compareTo(a.graduatedOn ?? a.registeredOn));
            return ListView(padding: const EdgeInsetsDirectional.all(16), children: [
              const BackHeader(title: 'الأرشيف'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsetsDirectional.all(4),
                decoration: BoxDecoration(color: t.card, borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  for (final (g, label) in [(true, 'الخرّيجون'), (false, 'المنسحبون')])
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => _graduates = g),
                        child: Container(
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: _graduates == g ? t.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                          child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _graduates == g ? t.onPrimary : t.text)),
                        ),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _q,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(hintText: 'بحث بالاسم أو الهوية', prefixIcon: Icon(Icons.search_rounded, color: t.textSecondary)),
              ),
              const SizedBox(height: 8),
              Text(_graduates ? 'ملخص نهائي لكل طالب خلّص رخصته · بيضل محفوظ دايمًا' : 'طلاب انسحبوا من رخصة · ملفاتهم وحركاتهم محفوظة',
                  style: TextStyle(fontSize: 13, color: t.textSecondary)),
              const SizedBox(height: 10),
              if (d == null)
                const SkeletonCards()
              else if (rows.isEmpty)
                EmptyState(icon: Icons.inventory_2_outlined, title: q.isEmpty ? (_graduates ? 'لسا ما في خرّيجين' : 'ما في منسحبين') : 'ما في نتيجة')
              else
                for (final e in rows) _ArchiveTile(e: e, license: d.$2[e.licenseTypeId] ?? '', summary: d.$4[e.id]),
              const SizedBox(height: 16),
              Panel(
                radius: 14,
                border: Border.all(color: t.problem.withValues(alpha: 0.4)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Text('حذف تفاصيل المؤرشفات', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('لسا مش متاح · رح يكون للأشهر المثبّتة بس (التثبيت من التقارير). الملخصات وتقارير الأشهر وسجل العمليات ما بتنحذف، وبتطلع نسخة Excel قبل الحذف.',
                      style: TextStyle(fontSize: 12, height: 1.6, color: t.textSecondary)),
                ]),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

class _ArchiveTile extends StatelessWidget {
  const _ArchiveTile({required this.e, required this.license, this.summary});
  final EnrollmentRow e;
  final String license;
  final StudentSummaryRow? summary;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final f = e.finalSummaryJson == null ? null : jsonDecode(e.finalSummaryJson!) as Map<String, dynamic>;
    int v(String k) => ((f?[k] ?? switch (k) {
              'paid' => summary?.paid,
              'discounts' => summary?.discounts,
              'theoryLessons' => summary?.theoryLessons,
              'practicalLessons' => summary?.practicalLessons,
              _ => 0,
            }) as num? ?? 0)
        .toInt();
    const strong = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);
    Widget cell(String label, Widget w) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)), w]));
    final graduated = e.stage == 'graduated';
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: Panel(
        onTap: () => openStudent(context, e.id),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.studentName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text(graduated ? '$license · خلّص ${friendlyDate(e.graduatedOn ?? '')}' : '$license · ${e.withdrawReason ?? ''}', style: TextStyle(fontSize: 12, color: t.textSecondary)),
              ]),
            ),
            Pill(graduated ? 'ناجح' : 'منسحب', bg: graduated ? t.moneyBg : t.divider, fg: graduated ? t.money : t.textSecondary),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            cell('دفع', MoneyText(Money(v('paid')), style: strong)),
            cell('خصم', MoneyText(Money(v('discounts')), style: strong)),
            cell('دروس', Text('${v('practicalLessons')}', style: strong)),
          ]),
        ]),
      ),
    );
  }
}
