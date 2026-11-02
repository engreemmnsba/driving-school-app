import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_scope.dart';
import '../../core/db/database.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/money_queries.dart';
import '../../data/queries.dart';
import '../money/receipt_screen.dart' show waPhone;
import 'exam_actions.dart';

Future<T?> _sheet<T>(BuildContext context, Widget child) => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.tokens.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheet) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheet).bottom), child: SafeArea(top: false, child: child)),
    );

String dateLabel(String d) {
  final p = d.split('-');
  if (p.length != 3) return d;
  final dt = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  return d == todayStr() ? 'اليوم · ${dayHeader(dt)}' : dayHeader(dt);
}

Future<String?> _pickDate(BuildContext context, String initial, {String? after}) async {
  final first = DateTime.parse(after ?? todayStr());
  final init = DateTime.parse(initial).isBefore(first) ? first : DateTime.parse(initial);
  final d = await showDatePicker(context: context, initialDate: init, firstDate: first, lastDate: DateTime.now().add(const Duration(days: 365)));
  return d == null ? null : businessDateOf(d);
}

// ---------------------------------------------------------------- book

/// Canvas: BookExam — one tap: exam + student fee + ministry expense (+ the student is told). Ends with a confirmation; no result buttons here.
Future<void> showBookExam(BuildContext context, StudentCard card) => _sheet<void>(context, _BookExam(card: card));

class _BookExam extends StatefulWidget {
  const _BookExam({required this.card});
  final StudentCard card;

  @override
  State<_BookExam> createState() => _BookExamState();
}

class _BookExamState extends State<_BookExam> {
  ExamPlan? _plan;
  List<AccountView> _accounts = const [];
  String? _account;
  late String _date = businessDateOf(DateTime.now().add(const Duration(days: 7)));
  bool _override = false;
  bool _busy = false;
  bool _done = false;
  bool _loaded = false;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    final app = AppScope.of(context);
    final plan = await examPlan(app.db, widget.card.id, todayStr());
    final acc = (await app.money.accounts()).where((a) => app.user.canUseAccount(a.id)).toList();
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _accounts = acc;
      _account = acc.isEmpty ? null : acc.first.id;
      _ready = true;
    });
  }

  Future<void> _book() async {
    final app = AppScope.of(context);
    setState(() => _busy = true);
    try {
      await app.exams.book(enrollmentId: widget.card.id, scheduledDate: _date, accountId: _plan!.fee.isPositive ? _account : null, businessDate: todayStr(), override: _override);
      app.syncSoon();
      setState(() => _done = true);
    } catch (e) {
      if (mounted) showErrorSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendDate() async {
    final p = _plan!;
    final text = 'موعد اختبار ${p.label} لـ${widget.card.name}: ${dateLabel(_date)}';
    final phone = waPhone(widget.card.student?.phone);
    await launchUrl(Uri.parse('https://wa.me/${phone ?? ''}?text=${Uri.encodeComponent(text)}'), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    final p = _plan;
    final c = widget.card;
    if (!_ready) return const Padding(padding: EdgeInsetsDirectional.all(16), child: SkeletonCards(count: 2));
    if (p == null) {
      return const Padding(padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20), child: EmptyState(icon: Icons.block, title: 'الطالب مش بمرحلة اختبار'));
    }
    final first = c.name.split(' ').first;
    final accName = _accounts.where((a) => a.id == _account).map((a) => a.name).firstOrNull ?? '';
    Widget step(String n, Widget body) => Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: t.tonalBg, shape: BoxShape.circle),
              child: Text(n, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: t.info)),
            ),
            const SizedBox(width: 8),
            Expanded(child: body),
          ]),
        );
    if (_done) {
      return SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsetsDirectional.all(12),
            decoration: BoxDecoration(color: t.moneyBg, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Icon(Icons.check_rounded, color: t.money),
              const SizedBox(width: 8),
              Expanded(child: Text('انحجز اختبار ${p.label} لـ$first · ${dateLabel(_date)}', style: TextStyle(color: t.money, fontWeight: FontWeight.w700))),
            ]),
          ),
          const SizedBox(height: 12),
          if (p.fee.isPositive) ...[
            MoneyRichText('• على $first رسوم ${p.label} +${p.fee.format()}'),
            MoneyRichText('• انصرف للوزارة ${p.fee.format()} من $accName'),
          ] else
            const Text('• أول اختبار نظري مشمول برسوم التسجيل · بدون أي مبلغ'),
          const SizedBox(height: 6),
          Text('النتيجة بتنسجّل يوم الاختبار من «بدها منك» أو من شاشة الاختبارات', style: TextStyle(fontSize: 13, color: t.textSecondary, height: 1.6)),
          const SizedBox(height: 14),
          AppButton('إرسال الموعد على واتساب', kind: AppButtonKind.success, icon: Icons.send_rounded, height: 52, expand: true, onPressed: _sendDate),
          const SizedBox(height: 8),
          AppButton('تمام', kind: AppButtonKind.outline, expand: true, onPressed: () => Navigator.of(context).pop()),
        ]),
      );
    }
    final blocked = p.pending != null || (!p.reachedMinimum && !_override);
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('حجز اختبار', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        Text('${c.name} · ${stageLabel(c.stage)} ${c.done}/${c.planned}', style: TextStyle(fontSize: 13, color: t.textSecondary)),
        const SizedBox(height: 10),
        Row(children: [
          Pill('${p.label} · محاولة ${p.attempt}', bg: t.tonalBg, fg: t.info),
          const Spacer(),
        ]),
        const SizedBox(height: 10),
        Panel(
          radius: 12,
          border: Border.all(color: t.border),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 4),
          child: Row(children: [
            Expanded(child: Text('موعد الاختبار: ${dateLabel(_date)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
            TextButton(
              onPressed: () async {
                final d = await _pickDate(context, _date);
                if (d != null) setState(() => _date = d);
              },
              child: const Text('تغيير'),
            ),
          ]),
        ),
        if (p.pending != null) ...[
          const SizedBox(height: 10),
          Text('في اختبار محجوز ${dateLabel(p.pending!.scheduledDate)} لسا ما إله نتيجة', style: TextStyle(color: t.problem, fontWeight: FontWeight.w600)),
        ] else if (!p.reachedMinimum) ...[
          const SizedBox(height: 10),
          Text('لسا ${p.minLessons - p.lessonsDone} دروس للحد الأدنى (${p.minLessons})', style: TextStyle(color: t.debt, fontWeight: FontWeight.w600)),
          if (app.user.isAdmin)
            CheckboxListTile(
              value: _override,
              onChanged: (v) => setState(() => _override = v ?? false),
              title: const Text('حجز قبل الحد الأدنى (استثناء من المدير · بينسجّل بالسجل)', style: TextStyle(fontSize: 13)),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
        ],
        const SizedBox(height: 12),
        Panel(
          color: t.bg,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('رح يصير بكبسة وحدة:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (p.fee.isPositive) ...[
              step('1', Row(children: [
                Expanded(child: Text('على $first رسوم اختبار ${p.label}')),
                MoneyText(p.fee, sign: '+', style: const TextStyle(fontWeight: FontWeight.w700)),
              ])),
              step('2', Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  const Expanded(child: Text('دفع للوزارة عنه من')),
                  MoneyText(p.fee, style: const TextStyle(fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 6),
                ChoiceRow<String>(
                  options: _accounts.map((a) => a.id).toList(),
                  selected: _account,
                  label: (id) => _accounts.firstWhere((a) => a.id == id).name,
                  onSelect: (id) => setState(() => _account = id),
                ),
              ])),
            ] else
              const Padding(
                padding: EdgeInsetsDirectional.only(bottom: 8),
                child: Text('أول اختبار نظري مشمول برسوم التسجيل · بدون أي مبلغ'),
              ),
            step(p.fee.isPositive ? '3' : '1', const Text('رسالة للطالب بالموعد (واتساب بعد الحجز)')),
          ]),
        ),
        const SizedBox(height: 12),
        AppButton('حجز الاختبار', height: 56, expand: true, busy: _busy, onPressed: blocked || (p.fee.isPositive && _account == null) ? null : _book),
      ]),
    );
  }
}

// ---------------------------------------------------------------- postpone

/// No cancellation — postponement only: new date + reason chips + optional details; the fee stays.
Future<void> showPostponeExam(BuildContext context, ExamRow exam) => _sheet<void>(context, _Postpone(exam: exam));

class _Postpone extends StatefulWidget {
  const _Postpone({required this.exam});
  final ExamRow exam;

  @override
  State<_Postpone> createState() => _PostponeState();
}

class _PostponeState extends State<_Postpone> {
  late String _date = businessDateOf(DateTime.parse(widget.exam.scheduledDate).add(const Duration(days: 7)));
  String _reason = 'ministry';
  final _details = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final app = AppScope.of(context);
    setState(() => _busy = true);
    try {
      await app.exams.postpone(widget.exam.id, toDate: _date, reason: _reason, details: _details.text.trim().isEmpty ? null : _details.text.trim(), byName: app.user.name);
      app.syncSoon();
      if (!mounted) return;
      final nav = Navigator.of(context);
      nav.pop();
      if (nav.context.mounted) showUndoSnack(nav.context, 'تأجّل اختبار ${widget.exam.studentName} إلى ${dateLabel(_date)}');
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
    final x = widget.exam;
    final valid = _date.compareTo(x.scheduledDate) > 0;
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('تأجيل الاختبار', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        Text('${x.studentName} · ${examTypeLabel[x.type]} · كان ${dateLabel(x.scheduledDate)}', style: TextStyle(fontSize: 13, color: t.textSecondary)),
        const SizedBox(height: 12),
        Panel(
          radius: 12,
          border: Border.all(color: t.border),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 4),
          child: Row(children: [
            Expanded(child: Text('الموعد الجديد: ${dateLabel(_date)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
            TextButton(
              onPressed: () async {
                final d = await _pickDate(context, _date, after: businessDateOf(DateTime.parse(x.scheduledDate).add(const Duration(days: 1))));
                if (d != null) setState(() => _date = d);
              },
              child: const Text('تغيير'),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        const Text('السبب', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final e in postponeReasons.entries)
            ChoiceChip(
              label: Text(e.value),
              selected: _reason == e.key,
              showCheckmark: false,
              selectedColor: t.tonalBg,
              backgroundColor: t.bg,
              side: BorderSide.none,
              labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _reason == e.key ? t.info : t.text),
              onSelected: (_) => setState(() => _reason = e.key),
            ),
        ]),
        const SizedBox(height: 8),
        TextField(controller: _details, decoration: const InputDecoration(hintText: 'تفاصيل (اختياري): رقم كتاب الوزارة…')),
        const SizedBox(height: 8),
        Text('الرسوم المدفوعة بتضل على نفس الحجز · التأجيل مش محاولة', style: TextStyle(fontSize: 12, color: t.textSecondary)),
        const SizedBox(height: 12),
        AppButton('تأجيل إلى ${dateLabel(_date)}', height: 54, expand: true, busy: _busy, onPressed: valid ? _save : null),
      ]),
    );
  }
}

String postponeHistoryLine(ExamRow x) {
  final h = (jsonDecode(x.historyJson) as List).cast<Map<String, dynamic>>();
  if (h.isEmpty) return '';
  final last = h.last;
  final from = '${last['from']}'.split('-');
  final was = from.length == 3 ? '${int.parse(from[2])}/${int.parse(from[1])}' : '${last['from']}';
  return 'تأجّل${h.length > 1 ? ' ${h.length} مرات' : ''} · كان $was · ${postponeReasons[last['reason']] ?? ''}${last['details'] == null ? '' : ' · ${last['details']}'}';
}

// ---------------------------------------------------------------- result / graduate

Future<void> recordResult(BuildContext context, ExamRow x, String result) async {
  final app = AppScope.of(context);
  try {
    await app.exams.result(x.id, result);
    app.syncSoon();
    if (!context.mounted) return;
    final word = const {'passed': 'نجح', 'failed': 'رسب', 'absent': 'ما حضر'}[result];
    showUndoSnack(context, 'انسجّلت النتيجة: ${x.studentName} $word');
  } catch (e) {
    if (context.mounted) showErrorSnack(context, '$e');
  }
}

/// Practical passed → final summary → graduate & archive (per enrollment).
Future<void> showGraduate(BuildContext context, StudentCard card) => _sheet<void>(context, _Graduate(card: card));

class _Graduate extends StatelessWidget {
  const _Graduate({required this.card});
  final StudentCard card;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    final b = card.balance;
    Widget cell(String label, Widget v) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)), v]));
    const strong = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('مبروك · ${card.name.split(' ').first} أخذ الرخصة', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('ملخص نهائي بيضل محفوظ بالأرشيف', style: TextStyle(fontSize: 13, color: t.textSecondary)),
        const SizedBox(height: 12),
        Panel(
          color: t.bg,
          child: Row(children: [
            cell('المحسوب', MoneyText(b.charged, style: strong)),
            cell('دفع', MoneyText(b.paid, style: strong)),
            cell('خصم', MoneyText(b.discounts, style: strong)),
            cell('دروس', Text('${card.theoryDone} نظري · ${card.practicalDone} عملي', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
          ]),
        ),
        if (b.remaining.isPositive) ...[
          const SizedBox(height: 8),
          MoneyRichText('لسا عليه ${b.remaining.format()} · الدين بيضل بملفه بعد التخريج', style: TextStyle(color: t.debt, fontWeight: FontWeight.w600)),
        ],
        const SizedBox(height: 14),
        AppButton('تخريج وأرشفة', height: 54, expand: true, onPressed: () async {
          await app.exams.graduate(card.id, today: todayStr());
          app.syncSoon();
          if (context.mounted) Navigator.of(context).pop();
        }),
      ]),
    );
  }
}

// ---------------------------------------------------------------- discount / new license / withdraw

Future<void> showDiscount(BuildContext context, StudentCard card) => _sheet<void>(context, _Discount(card: card));

class _Discount extends StatefulWidget {
  const _Discount({required this.card});
  final StudentCard card;

  @override
  State<_Discount> createState() => _DiscountState();
}

class _DiscountState extends State<_Discount> {
  final _amount = TextEditingController();
  final _reason = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  Money get _value => Money.shekels(int.tryParse(_amount.text) ?? 0);

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    final left = widget.card.remaining - _value;
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('خصم', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        Text('${widget.card.name} · ${widget.card.licenseName}', style: TextStyle(fontSize: 13, color: t.textSecondary)),
        const SizedBox(height: 12),
        TextField(
          controller: _amount,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
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
          ),
        ),
        const SizedBox(height: 8),
        TextField(controller: _reason, decoration: const InputDecoration(hintText: 'السبب (بيبين بالسجل)')),
        const SizedBox(height: 8),
        Text('الحد الأعلى للخصم حسب صلاحية كل مستخدم · السيرفر بيتأكد', style: TextStyle(fontSize: 12, color: t.textSecondary)),
        const SizedBox(height: 12),
        AppButton(
          'خصم ${_value.format()} · ${left.isNegative ? 'رصيد إله ${left.abs().format()}' : 'يبقى عليه ${left.format()}'}',
          kind: AppButtonKind.primary,
          height: 54,
          expand: true,
          busy: _busy,
          onPressed: !_value.isPositive
              ? null
              : () async {
                  setState(() => _busy = true);
                  await app.exams.discount(enrollmentId: widget.card.id, amount: _value, reason: _reason.text.trim().isEmpty ? null : _reason.text.trim(), businessDate: todayStr());
                  app.syncSoon();
                  if (context.mounted) Navigator.of(context).pop();
                },
        ),
      ]),
    );
  }
}

Future<void> showAddLicense(BuildContext context, String studentId) => _sheet<void>(context, _AddLicense(studentId: studentId));

class _AddLicense extends StatefulWidget {
  const _AddLicense({required this.studentId});
  final String studentId;

  @override
  State<_AddLicense> createState() => _AddLicenseState();
}

class _AddLicenseState extends State<_AddLicense> {
  List<LicenseTypeRow> _lic = const [];
  List<CarRow> _cars = const [];
  String? _license;
  String? _car;
  LicensePriceRow? _price;
  bool _loaded = false;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    final q = AppScope.of(context).queries;
    final lic = await q.licenseTypes();
    final cars = await q.cars();
    if (!mounted) return;
    setState(() {
      _lic = lic;
      _cars = cars;
      _license = lic.isEmpty ? null : lic.first.id;
      _car = cars.isEmpty ? null : cars.first.id;
    });
    await _loadPrice();
  }

  Future<void> _loadPrice() async {
    if (_license == null) return;
    final p = await AppScope.of(context).queries.priceOn(_license!, todayStr());
    if (mounted) setState(() => _price = p);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('رخصة جديدة لنفس الطالب', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        const Text('الرخصة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ChoiceRow<String>(
          options: _lic.map((l) => l.id).toList(),
          selected: _license,
          label: (id) => _lic.firstWhere((l) => l.id == id).name,
          onSelect: (id) {
            setState(() => _license = id);
            _loadPrice();
          },
        ),
        const SizedBox(height: 10),
        const Text('السيارة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ChoiceRow<String>(options: _cars.map((c) => c.id).toList(), selected: _car, label: (id) => _cars.firstWhere((c) => c.id == id).name, onSelect: (id) => setState(() => _car = id)),
        if (_price != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsetsDirectional.all(12),
            decoration: BoxDecoration(color: t.tonalBg, borderRadius: BorderRadius.circular(12)),
            child: MoneyRichText('رسوم التسجيل ${Money(_price!.registrationFee).format()} · بتنحسب عليه الآن', style: TextStyle(color: t.info, fontWeight: FontWeight.w700)),
          ),
        ],
        const SizedBox(height: 12),
        AppButton('إضافة الرخصة', height: 54, expand: true, busy: _busy, onPressed: _license == null || _car == null || _price == null
            ? null
            : () async {
                setState(() => _busy = true);
                try {
                  await app.exams.addEnrollment(studentId: widget.studentId, licenseTypeId: _license!, carId: _car!, businessDate: todayStr());
                  app.syncSoon();
                  if (context.mounted) Navigator.of(context).pop();
                } catch (e) {
                  if (context.mounted) {
                    setState(() => _busy = false);
                    showErrorSnack(context, '$e');
                  }
                }
              }),
      ]),
    );
  }
}

Future<bool?> showWithdraw(BuildContext context, StudentCard card) => _sheet<bool>(context, _Withdraw(card: card));

class _Withdraw extends StatefulWidget {
  const _Withdraw({required this.card});
  final StudentCard card;

  @override
  State<_Withdraw> createState() => _WithdrawState();
}

class _WithdrawState extends State<_Withdraw> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('انسحاب ${widget.card.name} من ${widget.card.licenseName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text('بدون استرجاع مبالغ · الملف والحركات بيضلّوا محفوظين بالأرشيف', style: TextStyle(fontSize: 13, color: t.textSecondary)),
        const SizedBox(height: 10),
        TextField(controller: _reason, autofocus: true, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'السبب (إجباري)')),
        const SizedBox(height: 12),
        AppButton('تأكيد الانسحاب', kind: AppButtonKind.danger, expand: true, onPressed: _reason.text.trim().isEmpty
            ? null
            : () async {
                try {
                  await app.exams.withdraw(widget.card.id, _reason.text.trim());
                  app.syncSoon();
                  if (context.mounted) Navigator.of(context).pop(true);
                } catch (e) {
                  if (context.mounted) showErrorSnack(context, '$e');
                }
              }),
      ]),
    );
  }
}
