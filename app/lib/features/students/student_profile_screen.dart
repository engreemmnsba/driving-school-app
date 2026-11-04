import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/db/database.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/queries.dart';
import '../money/add_payment_sheet.dart';
import '../money/receipt_screen.dart';
import '../exams/exam_actions.dart' show examTypeLabel;
import '../exams/exam_sheets.dart';
import 'edit_student_screen.dart';
import 'lesson_flow.dart';

class _ProfileData {
  const _ProfileData(this.card, this.others, this.ledger, this.lessons, this.accounts);
  final StudentCard card;
  final List<StudentCard> others;
  final List<LedgerRowData> ledger;
  final Map<String, LessonRow> lessons;
  final Map<String, String> accounts;
}

/// Canvas: StudentProfile — progress, balance, one-tap actions, every movement (newest first).
class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key, required this.enrollmentId});
  final String enrollmentId;

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  Stream<_ProfileData?>? _stream;
  late String _enrollmentId = widget.enrollmentId;
  bool _reveal = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stream == null) {
      AppScope.of(context).touchStudent(_enrollmentId);
      _listen();
    }
  }

  void _listen() {
    final app = AppScope.of(context);
    final id = _enrollmentId;
    _stream = watchLoad(app.db, () async {
      final card = await app.queries.studentCard(id);
      if (card == null) return null;
      final others = await app.queries.enrollmentsOf(card.enrollment.studentId);
      final lessons = {for (final l in await app.queries.lessons(id)) l.id: l};
      final accounts = {for (final a in await app.queries.accounts()) a.id: a.name};
      return _ProfileData(card, others, await app.queries.ledger(id), lessons, accounts);
    });
  }

  static String _mask(String v, int head, int tail) =>
      v.length <= head + tail ? v : '${v.substring(0, head)}${'•' * (v.length - head - tail)}${v.substring(v.length - tail)}';

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<_ProfileData?>(
          stream: _stream,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Padding(padding: EdgeInsetsDirectional.all(16), child: SkeletonCards(count: 4, height: 90));
            }
            final d = snap.data;
            if (d == null) {
              return Padding(
                padding: const EdgeInsetsDirectional.all(16),
                child: Column(children: [const BackHeader(title: 'الطالب'), const SizedBox(height: 24), const EmptyState(icon: Icons.person_off_outlined, title: 'الطالب مش موجود على هالجوال')]),
              );
            }
            final c = d.card;
            final s = c.student;
            final idLine = s == null
                ? c.licenseName
                : 'هوية ${_reveal ? s.nationalId : _mask(s.nationalId, 2, 1)}${s.phone == null ? '' : ' · ${_reveal ? s.phone : _mask(s.phone!, 3, 2)}'}';
            return ListView(
              padding: const EdgeInsetsDirectional.all(16),
              children: [
                GestureDetector(
                  onLongPress: () => setState(() => _reveal = !_reveal),
                  child: BackHeader(
                    title: c.name,
                    subtitle: idLine,
                    trailing: (s != null && app.user.can('editStudent'))
                        ? AppButton('تعديل', kind: AppButtonKind.outline, height: 44, onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => EditStudentScreen(studentId: s.id)));
                          })
                        : null,
                  ),
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (final o in d.others)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ChoiceChip(
                          label: Text('${o.licenseName} · ${o.stage == 'graduated' ? 'مكتمل' : (o.stage == 'withdrawn' ? 'منسحب' : 'نشط')}'),
                          selected: o.id == c.id,
                          showCheckmark: false,
                          selectedColor: t.primary,
                          backgroundColor: t.card,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                          labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: o.id == c.id ? t.onPrimary : t.text),
                          onSelected: (_) => setState(() {
                            _enrollmentId = o.id;
                            _listen();
                          }),
                        ),
                      ),
                    if (s != null && app.user.can('addStudent'))
                      ActionChip(
                        label: const Text('+ رخصة'),
                        backgroundColor: t.bg,
                        side: BorderSide(color: t.textSecondary),
                        shape: const StadiumBorder(),
                        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        onPressed: () => showAddLicense(context, s.id),
                      ),
                  ]),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _ProgressCard(title: 'نظري', done: c.theoryDone, planned: c.theoryLessons ? c.plannedTheory : c.theoryDone, note: c.stage != 'theory' ? 'خلص النظري' : c.theoryLessons ? null : 'اختبار بس، بدون دروس')),
                  const SizedBox(width: 10),
                  Expanded(child: _ProgressCard(title: 'عملي · ${c.carName}', done: c.practicalDone, planned: c.plannedPractical)),
                ]),
                if (app.user.can('seeMoney')) ...[
                  const SizedBox(height: 14),
                  _BalanceCard(card: c),
                ],
                if (c.pendingExam != null) ...[
                  const SizedBox(height: 14),
                  _PendingExam(card: c),
                ],
                if (c.passedPractical && app.user.can('exam')) ...[
                  const SizedBox(height: 14),
                  AppButton('نجح بالعملي · تخريج وأرشفة', height: 54, expand: true, onPressed: () => showGraduate(context, c)),
                ],
                if (c.stage == 'graduated' || c.stage == 'withdrawn') ...[
                  const SizedBox(height: 14),
                  Pill(c.stage == 'graduated' ? 'خرّيج · ${c.enrollment.graduatedOn ?? ''}' : 'منسحب · ${c.enrollment.withdrawReason ?? ''}',
                      bg: c.stage == 'graduated' ? t.moneyBg : t.divider, fg: c.stage == 'graduated' ? t.money : t.textSecondary),
                ],
                const SizedBox(height: 14),
                _Actions(card: c),
                const SizedBox(height: 14),
                SectionHeader('الحركات', trailing: Text('الأحدث أولًا', style: TextStyle(fontSize: 13, color: t.textSecondary))),
                const SizedBox(height: 8),
                if (!app.user.can('seeMoney'))
                  Text('الحركات المالية بتبين لمين عنده صلاحية المال', style: TextStyle(color: t.textSecondary, fontSize: 13))
                else if (d.ledger.isEmpty)
                  Text('ما في حركات لسا', style: TextStyle(color: t.textSecondary, fontSize: 13))
                else
                  for (final r in d.ledger) _LedgerTile(row: r, lessons: d.lessons, accounts: d.accounts, card: c),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.title, required this.done, required this.planned, this.note});
  final String title;
  final int done;
  final int planned;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 13, color: t.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Text('$done/$planned', textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (note != null) Pill(note!, bg: t.moneyBg, fg: t.money) else ProgressLine(planned == 0 ? 0 : done / planned),
      ]),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.card});
  final StudentCard card;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final b = card.balance;
    const soft = Color(0xFFD5ECEB);
    final onCard = t.onPrimary;
    Widget part(String label, Money m) => Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 12, color: soft)),
            MoneyText(m, color: onCard, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ]),
        );
    final p = card.price;
    final expected = p == null ? null : Money(p.registrationFee + p.plannedPracticalLessons * p.practicalLessonPrice + p.practicalExamFee);
    final remaining = b.remaining;
    return Panel(
      color: t.primary,
      padding: const EdgeInsetsDirectional.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Text(remaining.isNegative ? 'رصيد للطالب' : 'المتبقي على الطالب', style: const TextStyle(fontSize: 14, color: soft))),
          MoneyText(remaining.abs(), color: onCard, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        Row(children: [part('المحسوب', b.charged), part('المدفوع', b.paid), part('الخصم', b.discounts)]),
        if (expected != null && p != null) ...[
          const SizedBox(height: 10),
          Text(
            'السعر الكامل المتوقع ${expected.format()} · تسجيل ${Money(p.registrationFee).format()} + ${p.plannedPracticalLessons} عملي × ${Money(p.practicalLessonPrice).format()} + اختبار ${Money(p.practicalExamFee).format()}',
            style: const TextStyle(fontSize: 12, color: soft, height: 1.5),
          ),
        ],
      ]),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.card});
  final StudentCard card;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    final c = card;
    final minForExam = c.minForExam;
    final examReady = c.readyForExam;
    // The lesson button gets its own full-width row: "تسجيل نظري 1" doesn't fit a third of a phone.
    final lesson = c.canLesson && app.user.can('lesson')
        ? AppButton('تسجيل ${c.nextLessonLabel}', kind: AppButtonKind.accent, icon: Icons.check_rounded, height: 64, expand: true, onPressed: () => logNextLesson(context, c))
        : null;
    final buttons = <Widget>[
      if (app.user.can('addPay')) AppButton('دفعة', kind: AppButtonKind.tonal, icon: Icons.add_rounded, height: 64, onPressed: () => showAddPayment(context, preselect: c)),
      if (app.user.can('exam') && c.canLesson && c.pendingExam == null)
        AppButton('حجز تست', kind: examReady ? AppButtonKind.primary : AppButtonKind.outline, height: 64, onPressed: examReady || app.user.isAdmin ? () => showBookExam(context, c) : null),
    ];
    if (buttons.isEmpty && lesson == null) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (lesson != null) lesson,
      if (lesson != null && buttons.isNotEmpty) const SizedBox(height: 8),
      if (buttons.isNotEmpty)
        Row(children: [
          for (final (i, b) in buttons.indexed) ...[if (i > 0) const SizedBox(width: 8), Expanded(child: b)],
        ]),
      if (app.user.can('exam') && !examReady && c.canLesson && c.pendingExam == null && minForExam > c.done) ...[
        const SizedBox(height: 6),
        Text('زر حجز الاختبار ${c.inTheory ? 'النظري' : 'العملي'} بيتفعّل بعد ${minForExam - c.done} دروس (الحد الأدنى $minForExam)',
            style: TextStyle(fontSize: 12, color: t.textSecondary)),
      ],
      if (app.user.can('discount') && c.canLesson) ...[
        const SizedBox(height: 6),
        Align(alignment: AlignmentDirectional.centerStart, child: TextButton.icon(onPressed: () => showDiscount(context, c), icon: const Icon(Icons.percent_rounded, size: 18), label: const Text('خصم'))),
      ],
    ]);
  }
}

class _LedgerTile extends StatelessWidget {
  const _LedgerTile({required this.row, required this.lessons, required this.accounts, required this.card});
  final LedgerRowData row;
  final Map<String, LessonRow> lessons;
  final Map<String, String> accounts;
  final StudentCard card;

  static const _purpose = {'lessons': 'دروس', 'registration': 'تسجيل', 'exam': 'اختبار', 'general': 'عام'};

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final r = row;
    final when = friendlyDate(r.businessDate, atIso: r.at);
    final lesson = r.lessonId == null ? null : lessons[r.lessonId];
    final (label, meta, word, color) = switch (r.kind) {
      'payment' => (
          'دفعة · ${_purpose[r.purpose] ?? ''}${r.receiptNo == null ? '' : ' · وصل ${r.receiptNo}'}',
          '$when · ${accounts[r.accountId] ?? ''}${r.reversed ? ' · مرجّعة' : ''}',
          'دفع',
          r.reversed ? t.textSecondary : t.money
        ),
      'lesson_charge' => ('درس عملي ${lesson?.number ?? ''}', '$when${r.reversed ? ' · ملغي' : ''}', 'عليه', r.reversed ? t.textSecondary : t.text),
      'registration_fee' => ('رسوم التسجيل · ${card.licenseName}', '$when · تشمل دروس النظري', 'عليه', t.text),
      'exam_fee' => ('رسوم اختبار', when, 'عليه', t.text),
      'retake_fee' => ('رسوم إعادة', when, 'عليه', t.text),
      'discount' => ('خصم', when, 'خصم', t.info),
      'reversal' => ('إرجاع دفعة', when, 'رجع', t.text),
      'charge_reversal' => ('إلغاء درس عملي ${lesson?.number ?? ''}', when, 'نزل', t.info),
      _ => (r.kind, when, '', t.text),
    };
    final pending = r.syncState == 'pending';
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Panel(
        radius: 14,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 11),
        onTap: r.kind == 'payment'
            ? () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ReceiptScreen(paymentId: r.id)))
            : null,
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text(pending ? '$meta · مستني مزامنة' : meta, style: TextStyle(fontSize: 12, color: t.textSecondary)),
            ]),
          ),
          Text('$word ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          MoneyText(Money(r.amount), color: color, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, decoration: r.reversed ? TextDecoration.lineThrough : null)),
        ]),
      ),
    );
  }
}

class _PendingExam extends StatelessWidget {
  const _PendingExam({required this.card});
  final StudentCard card;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    final x = card.pendingExam!;
    final due = x.scheduledDate.compareTo(todayStr()) <= 0;
    final history = postponeHistoryLine(x);
    return Panel(
      border: Border.all(color: due ? t.warning : t.primary, width: 2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Icon(Icons.event_outlined, color: due ? t.warning : t.primary),
          const SizedBox(width: 8),
          Expanded(child: Text('اختبار ${examTypeLabel[x.type]} · محاولة ${x.attempt} · ${dateLabel(x.scheduledDate)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
        ]),
        if (history.isNotEmpty) Padding(padding: const EdgeInsetsDirectional.only(top: 4), child: Text(history, style: TextStyle(fontSize: 12, color: t.warning))),
        if (app.user.can('exam')) ...[
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
          if (!due) Padding(padding: const EdgeInsetsDirectional.only(top: 6), child: Text('النتيجة بتنسجّل من يوم الاختبار', style: TextStyle(fontSize: 12, color: t.textSecondary))),
        ],
      ]),
    );
  }
}
