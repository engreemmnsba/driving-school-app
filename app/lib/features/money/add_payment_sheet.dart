import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_scope.dart';
import '../../core/db/database.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/queries.dart';
import 'receipt_screen.dart';

/// Canvas: AddPayment — pick student → amount → account → save. Purpose / date / WhatsApp under "تغيير".
Future<void> showAddPayment(BuildContext context, {StudentCard? preselect}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.tokens.card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheet) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheet).bottom),
      child: _AddPaymentSheet(preselect: preselect),
    ),
  );
}

const _purposes = ['lessons', 'registration', 'exam', 'general'];
const _purposeLabels = {'lessons': 'دروس', 'registration': 'تسجيل', 'exam': 'اختبار', 'general': 'عام'};

class _AddPaymentSheet extends StatefulWidget {
  const _AddPaymentSheet({this.preselect});
  final StudentCard? preselect;

  @override
  State<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<_AddPaymentSheet> {
  late StudentCard? _student = widget.preselect;
  List<StudentCard>? _all;
  List<TreasuryAccountRow> _accounts = const [];
  String? _account;
  late String _purpose = _defaultPurpose(widget.preselect);
  final _q = TextEditingController();
  final _amount = TextEditingController();
  bool _more = false;
  bool _whatsapp = true;
  bool _saving = false;

  static String _defaultPurpose(StudentCard? c) => c == null ? 'lessons' : (c.stage == 'theory' ? 'registration' : (c.stage == 'ready_practical' ? 'exam' : 'lessons'));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_all == null) _load();
  }

  Future<void> _load() async {
    final app = AppScope.of(context);
    final all = await app.queries.studentCards();
    // Only the accounts this person may use (A17) — the server refuses the others.
    final accounts = (await app.queries.accounts()).where((a) => app.user.canUseAccount(a.id)).toList();
    if (!mounted) return;
    setState(() {
      _all = all;
      _accounts = accounts;
      _account ??= accounts.isEmpty ? null : accounts.first.id;
    });
    if (_student != null) _pick(_student!);
  }

  void _pick(StudentCard c) {
    final owe = c.remaining.isPositive ? c.remaining.agorot ~/ 100 : 0;
    setState(() {
      _student = c;
      _purpose = _defaultPurpose(c);
      _amount.text = '${owe == 0 ? 100 : (owe < 500 ? owe : 500)}';
    });
  }

  @override
  void dispose() {
    _q.dispose();
    _amount.dispose();
    super.dispose();
  }

  Money get _value => Money.shekels(int.tryParse(_amount.text) ?? 0);

  Future<void> _save() async {
    final app = AppScope.of(context);
    final s = _student!;
    if (!_value.isPositive || _account == null) return;
    setState(() => _saving = true);
    try {
      final id = await app.recordPayment(
        enrollmentId: s.id,
        studentId: s.enrollment.studentId,
        amount: _value,
        accountId: _account!,
        purpose: _purpose,
        businessDate: todayStr(),
      );
      app.syncSoon();
      if (!mounted) return;
      final nav = Navigator.of(context);
      final messengerContext = nav.context;
      nav.pop();
      if (_whatsapp) {
        nav.push(MaterialPageRoute<void>(builder: (_) => ReceiptScreen(paymentId: id)));
      }
      final first = s.name.split(' ').first;
      if (!messengerContext.mounted) return;
      showUndoSnack(messengerContext, 'انسجّلت دفعة ${_value.format()} ل$first', onUndo: () async {
        await app.reversePayment(id, reason: 'تراجع مباشرة بعد التسجيل', businessDate: todayStr());
        app.syncSoon();
      });
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showErrorSnack(context, 'ما انحفظت الدفعة: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            const Expanded(child: Text('دفعة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
            IconButton(tooltip: 'إغلاق', icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
          ]),
          const SizedBox(height: 8),
          if (_student == null) ..._picker(t) else ..._form(t),
        ]),
      ),
    );
  }

  List<Widget> _picker(AppTokens t) {
    final q = _q.text.trim();
    final res = (_all ?? const <StudentCard>[])
        .where((c) => q.isEmpty || c.name.contains(q) || (c.student?.nationalId.contains(q) ?? false))
        .take(q.isEmpty ? 6 : 20)
        .toList();
    return [
      TextField(
        controller: _q,
        autofocus: true,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(hintText: 'اسم الطالب أو رقم الهوية', prefixIcon: Icon(Icons.search_rounded, color: t.textSecondary)),
      ),
      const SizedBox(height: 10),
      Text(q.isEmpty ? 'آخر الطلاب' : '${res.length} نتيجة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textSecondary)),
      const SizedBox(height: 6),
      if (_all == null) const SkeletonCards(count: 3, height: 52),
      for (final c in res)
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 6),
          child: Panel(
            radius: 12,
            border: Border.all(color: t.border),
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
            onTap: () => _pick(c),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  Text('${c.licenseName} · ${stageLabel(c.stage)} ${c.done}/${c.planned}', style: TextStyle(fontSize: 12, color: t.textSecondary)),
                ]),
              ),
              if (c.remaining.isPositive)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('عليه ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.debt)),
                  MoneyText(c.remaining, color: t.debt, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ])
              else
                Text('مسدّد', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.money)),
            ]),
          ),
        ),
    ];
  }

  List<Widget> _form(AppTokens t) {
    final s = _student!;
    final owe = s.remaining;
    final left = owe - _value;
    final quick = <Money>{Money.shekels(100), Money.shekels(200), Money.shekels(500), if (owe.isPositive) owe}.toList();
    final saveLabel = left.isPositive
        ? 'حفظ ${_value.format()} · يبقى عليه ${left.format()}'
        : (left.isNegative ? 'حفظ ${_value.format()} · زيادة ${left.abs().format()} رصيد إله' : 'حفظ ${_value.format()} · خلص الدين');
    final accountName = {for (final a in _accounts) a.id: a.name};
    return [
      Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: t.bg, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              if (owe.isPositive)
                Row(children: [
                  Text('عليه الآن ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.debt)),
                  MoneyText(owe, color: t.debt, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ])
              else
                Text('مسدّد', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.money)),
            ]),
          ),
          if (widget.preselect == null) AppButton('طالب ثاني', kind: AppButtonKind.outline, height: 40, onPressed: () => setState(() => _student = null)),
        ]),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _amount,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
        textDirection: TextDirection.ltr,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
            child: Text('₪', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: t.textSecondary)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: t.primary, width: 2)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: t.primary, width: 2)),
          semanticCounterText: 'المبلغ',
        ),
      ),
      const SizedBox(height: 8),
      ChoiceRow<Money>(
        options: quick,
        selected: _value,
        label: (m) => m == owe && owe.isPositive && !{100, 200, 500}.contains(m.agorot ~/ 100) ? 'كل الباقي' : m.format(),
        onSelect: (m) => setState(() => _amount.text = '${m.agorot ~/ 100}'),
      ),
      const SizedBox(height: 8),
      if (_accounts.isEmpty)
        Text('ما في صناديق لسا · بتنضاف من الإعدادات', style: TextStyle(color: t.problem))
      else
        ChoiceRow<String>(
          options: _accounts.map((a) => a.id).toList(),
          selected: _account,
          label: (id) => accountName[id] ?? id,
          height: 46,
          onSelect: (id) => setState(() => _account = id),
        ),
      const SizedBox(height: 4),
      InkWell(
        onTap: () => setState(() => _more = !_more),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
          child: Row(children: [
            Expanded(child: Text('ل${_purposeLabels[_purpose]} · اليوم${_whatsapp ? ' · الوصل على واتساب' : ''}', style: TextStyle(fontSize: 13, color: t.textSecondary))),
            Text(_more ? 'إخفاء' : 'تغيير', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.primary)),
          ]),
        ),
      ),
      if (_more) ...[
        ChoiceRow<String>(options: _purposes, selected: _purpose, label: (p) => _purposeLabels[p]!, onSelect: (p) => setState(() => _purpose = p)),
        const SizedBox(height: 6),
        CheckboxListTile(
          value: _whatsapp,
          onChanged: (v) => setState(() => _whatsapp = v ?? false),
          title: const Text('الوصل على واتساب', style: TextStyle(fontSize: 14)),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        Text('التسجيل بتاريخ قديم بيجي مع صلاحية "تسجيل بتاريخ قديم"', style: TextStyle(fontSize: 12, color: t.textSecondary)),
        const SizedBox(height: 8),
      ],
      const SizedBox(height: 4),
      AppButton(saveLabel, height: 56, expand: true, busy: _saving, onPressed: _value.isPositive && _account != null ? _save : null),
    ];
  }
}
