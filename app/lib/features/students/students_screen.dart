import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/queries.dart';
import '../home/home_screen.dart' show openStudent;
import '../money/add_payment_sheet.dart';
import '../exams/exam_sheets.dart';
import '../exams/exams_screen.dart';
import 'lesson_flow.dart';
import 'register_student_screen.dart';

enum StudentFilter { all, theory, practical, ready, debt }

const _filterLabels = {
  StudentFilter.all: 'الكل',
  StudentFilter.theory: 'نظري',
  StudentFilter.practical: 'عملي',
  StudentFilter.ready: 'جاهز للتست',
  StudentFilter.debt: 'عليه دين',
};

/// Canvas: Students — search (name / national ID / phone), recent chips, filters, one-tap lesson & payment.
class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  Stream<(List<StudentCard>, List<String>)>? _stream;
  final _search = TextEditingController();
  StudentFilter _filter = StudentFilter.all;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = AppScope.of(context);
    _stream ??= watchLoad(app.db, () async => (await app.queries.studentCards(), await app.recentStudents()));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(StudentCard c, String q) {
    if (q.isEmpty) return true;
    final s = c.student;
    return c.name.contains(q) || (s?.nationalId.contains(q) ?? false) || (s?.phone?.contains(q) ?? false);
  }

  bool _inFilter(StudentCard c) => switch (_filter) {
        StudentFilter.all => true,
        StudentFilter.theory => c.stage == 'theory',
        StudentFilter.practical => c.stage == 'practical',
        StudentFilter.ready => c.readyForExam || c.pendingExam != null,
        StudentFilter.debt => c.remaining.isPositive,
      };

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<(List<StudentCard>, List<String>)>(
          stream: _stream,
          builder: (context, snap) {
            final all = snap.data?.$1;
            final recentIds = snap.data?.$2 ?? const <String>[];
            final q = _search.text.trim();
            final list = all?.where((c) => _matches(c, q) && _inFilter(c)).toList();
            final byId = {for (final c in all ?? const <StudentCard>[]) c.id: c};
            final recent = [for (final id in recentIds) if (byId[id] != null) byId[id]!].take(4).toList();
            return ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 24),
              children: [
                Row(children: [
                  const Expanded(child: Text('الطلاب', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
                  // Booked exams (and students ready to book) one tap away, without a sixth tab.
                  if (app.user.can('exam') || app.user.can('students')) ...[
                    Builder(builder: (context) {
                      final booked = (all ?? const <StudentCard>[]).where((c) => c.pendingExam != null).length;
                      // Small, so the title and "طالب جديد" still fit on a phone.
                      return IconButton.filledTonal(
                        tooltip: booked == 0 ? 'الاختبارات' : 'الاختبارات · $booked محجوزة',
                        style: IconButton.styleFrom(minimumSize: const Size(44, 44), backgroundColor: t.tonalBg),
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ExamsScreen())),
                        icon: Badge(
                          isLabelVisible: booked > 0,
                          label: Text('$booked'),
                          backgroundColor: t.primary,
                          child: Icon(Icons.event_note_rounded, color: t.info),
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                  ],
                  if (app.user.can('addStudent'))
                    AppButton('طالب جديد', kind: AppButtonKind.accent, icon: Icons.add_rounded, height: 44, onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const RegisterStudentScreen()));
                    }),
                ]),
                const SizedBox(height: 14),
                TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'بحث بالاسم أو رقم الهوية أو الجوال',
                    prefixIcon: Icon(Icons.search_rounded, color: t.textSecondary),
                    suffixIcon: q.isEmpty
                        ? null
                        : IconButton(tooltip: 'مسح البحث', icon: const Icon(Icons.close_rounded), onPressed: () => setState(_search.clear)),
                    contentPadding: const EdgeInsetsDirectional.symmetric(vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.border)),
                  ),
                ),
                if (recent.isNotEmpty && q.isEmpty) ...[
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      Text('آخر تعامل:', style: TextStyle(fontSize: 12, color: t.textSecondary)),
                      for (final r in recent) ...[
                        const SizedBox(width: 6),
                        ActionChip(
                          label: Text(r.name.split(' ').take(2).join(' ')),
                          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          backgroundColor: t.card,
                          side: BorderSide(color: t.border),
                          shape: const StadiumBorder(),
                          onPressed: () => openStudent(context, r.id),
                        ),
                      ],
                    ]),
                  ),
                ],
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (final f in StudentFilter.values) ...[
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ChoiceChip(
                          label: Text(_filterLabels[f]!),
                          selected: _filter == f,
                          showCheckmark: false,
                          labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _filter == f ? t.onPrimary : t.text),
                          selectedColor: t.primary,
                          backgroundColor: t.card,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: 6, vertical: 6),
                          onSelected: (_) => setState(() => _filter = f),
                        ),
                      ),
                    ],
                  ]),
                ),
                const SizedBox(height: 14),
                if (list == null)
                  const SkeletonCards()
                else ...[
                  Text(_countLine(list.length, q.isNotEmpty || _filter != StudentFilter.all), style: TextStyle(fontSize: 13, color: t.textSecondary)),
                  const SizedBox(height: 10),
                  if (all!.isEmpty)
                    EmptyState(
                      icon: Icons.groups_outlined,
                      title: 'لسا ما في طلاب',
                      body: 'أول طالب بيتسجّل بيطلع هون، ومعه دروسه وحسابه',
                      action: app.user.can('addStudent')
                          ? AppButton('تسجيل أول طالب', kind: AppButtonKind.accent, onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const RegisterStudentScreen()));
                            })
                          : null,
                    )
                  else if (list.isEmpty)
                    EmptyState(
                      icon: Icons.search_off_rounded,
                      title: q.isEmpty ? 'ما في طلاب بهالفلتر' : 'ما في طالب بهالبحث',
                      body: q.isEmpty ? null : 'البحث برقم الهوية أو الجوال ممكن كمان',
                    )
                  else
                    for (final c in list) Padding(padding: const EdgeInsetsDirectional.only(bottom: 10), child: StudentTile(card: c)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _countLine(int n, bool filtered) {
    final (word, active) = switch (n) {
      1 => ('طالب واحد', 'نشط'),
      2 => ('طالبين', 'نشطين'),
      >= 3 && <= 10 => ('$n طلاب', 'نشطين'),
      _ => ('$n طالبًا', 'نشطًا'),
    };
    if (n == 0) return filtered ? 'ما في نتائج' : 'ما في طلاب نشطين';
    return filtered ? '$word بالنتيجة' : '$word $active';
  }
}

/// One student card: name, license · car, stage progress, balance, next lesson + payment buttons.
class StudentTile extends StatelessWidget {
  const StudentTile({super.key, required this.card});
  final StudentCard card;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    final c = card;
    final pending = c.enrollment.syncState == 'pending';
    return Panel(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 12),
      child: Column(children: [
        InkWell(
          onTap: () => openStudent(context, c.id),
          child: Row(children: [
            InitialBox(c.name),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text(
                  '${c.licenseName} · ${c.carName} · ${stageLabel(c.stage)}${c.counter}${c.pendingExam == null ? '' : ' · اختبار ${dateShort(c.pendingExam!.scheduledDate)}'}${pending ? ' · مستني مزامنة' : ''}',
                  style: TextStyle(fontSize: 12, color: t.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
            if (app.user.can('seeMoney')) BalanceLabel(c.remaining, overdue: c.overdue),
          ]),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: ProgressLine(c.progress)),
          if (c.readyForExam && app.user.can('exam')) ...[
            const SizedBox(width: 8),
            AppButton('حجز اختبار', height: 44, onPressed: () => showBookExam(context, c)),
          ],
          if (c.passedPractical && app.user.can('exam')) ...[
            const SizedBox(width: 8),
            AppButton('تخريج', height: 44, onPressed: () => showGraduate(context, c)),
          ],
          if (c.canLesson && app.user.can('lesson')) ...[
            const SizedBox(width: 8),
            AppButton(c.nextLessonLabel, kind: AppButtonKind.accent, icon: Icons.check_rounded, height: 44, onPressed: () => logNextLesson(context, c)),
          ],
          if (app.user.can('addPay')) ...[
            const SizedBox(width: 8),
            AppButton('دفعة', kind: AppButtonKind.tonal, icon: Icons.add_rounded, height: 44, onPressed: () => showAddPayment(context, preselect: c)),
          ],
        ]),
      ]),
    );
  }
}

/// "₪440 عليه" (amber; red when overdue, A2) · "مسدّد" (green) · "₪50 رصيد إله" (teal).
class BalanceLabel extends StatelessWidget {
  const BalanceLabel(this.remaining, {super.key, this.size = 13, this.overdue = false});
  final Money remaining;
  final double size;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final m = remaining;
    final style = TextStyle(fontSize: size, fontWeight: FontWeight.w700);
    if (m.isPositive) {
      final c = overdue ? t.problem : t.debt;
      return Row(mainAxisSize: MainAxisSize.min, children: [MoneyText(m, color: c, style: style), Text(overdue ? ' عليه · متأخر' : ' عليه', style: style.copyWith(color: c))]);
    }
    if (m.isZero) return Text('مسدّد', style: style.copyWith(color: t.money));
    return Row(mainAxisSize: MainAxisSize.min, children: [MoneyText(m.abs(), color: t.info, style: style), Text(' رصيد إله', style: style.copyWith(color: t.info))]);
  }
}
