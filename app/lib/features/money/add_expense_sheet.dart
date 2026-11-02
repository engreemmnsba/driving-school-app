import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_scope.dart';
import '../../core/db/database.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/money_queries.dart';
import '../../data/queries.dart';

/// Canvas: AddExpense — the kind changes the fields (cars → car + what; ministry → student; other → item).
Future<void> showAddExpense(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.tokens.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheet) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheet).bottom), child: const _AddExpenseSheet()),
    );

const _carItems = ['بنزين', 'صيانة', 'ترخيص وتأمين', 'غسيل'];
const _otherItems = ['إيجار', 'كهرباء', 'إنترنت', 'قرطاسية'];

class _AddExpenseSheet extends StatefulWidget {
  const _AddExpenseSheet();

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  String _kind = 'cars';
  List<CarRow> _cars = const [];
  List<AccountView> _accounts = const [];
  List<StudentCard> _students = const [];
  String? _car;
  String _carItem = 'بنزين';
  String _otherItem = 'إيجار';
  String? _student;
  String? _account;
  final _amount = TextEditingController();
  final _liters = TextEditingController();
  final _custom = TextEditingController();
  final _note = TextEditingController();
  final _q = TextEditingController();
  bool _loaded = false;
  bool _busy = false;
  bool _showNote = false;

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
    final cars = await app.queries.cars();
    final accounts = (await app.money.accounts()).where((a) => app.user.canUseAccount(a.id)).toList();
    final students = await app.queries.studentCards();
    if (!mounted) return;
    setState(() {
      _cars = cars;
      _accounts = accounts;
      _students = students;
      _car = cars.isEmpty ? null : cars.first.id;
      _account = accounts.isEmpty ? null : accounts.first.id;
    });
  }

  @override
  void dispose() {
    for (final c in [_amount, _liters, _custom, _note, _q]) {
      c.dispose();
    }
    super.dispose();
  }

  Money get _value => Money.shekels(int.tryParse(_amount.text) ?? 0);

  String get _item => switch (_kind) {
        'cars' => _carItem,
        'ministry' => 'رسوم اختبار',
        _ => _otherItem == '+' ? _custom.text.trim() : _otherItem,
      };

  String get _what => switch (_kind) {
        'cars' => '$_carItem ${_cars.where((c) => c.id == _car).map((c) => c.name).firstOrNull ?? ''}',
        'ministry' => 'رسوم ${_students.where((s) => s.enrollment.studentId == _student).map((s) => s.name).firstOrNull ?? ''}',
        _ => _item,
      };

  bool get _valid =>
      _value.isPositive &&
      _account != null &&
      _item.isNotEmpty &&
      (_kind != 'cars' || _car != null) &&
      (_kind != 'ministry' || _student != null);

  Future<void> _save() async {
    final app = AppScope.of(context);
    setState(() => _busy = true);
    try {
      await app.addExpense(
        kind: _kind,
        item: _item,
        label: _what,
        carId: _kind == 'cars' ? _car : null,
        liters: _kind == 'cars' && _carItem == 'بنزين' ? int.tryParse(_liters.text) : null,
        studentId: _kind == 'ministry' ? _student : null,
        amount: _value,
        accountId: _account!,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        businessDate: todayStr(),
      );
      app.syncSoon();
      if (!mounted) return;
      final nav = Navigator.of(context);
      nav.pop();
      if (nav.context.mounted) showUndoSnack(nav.context, 'انسجّل $_what ${_value.format()}');
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showErrorSnack(context, 'ما انحفظ المصروف: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    const label = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);
    final acc = _accounts.where((a) => a.id == _account).firstOrNull;
    final left = acc == null ? null : acc.balance - _value;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            const Expanded(child: Text('مصروف جديد', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
            IconButton(tooltip: 'إغلاق', icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
          ]),
          const Text('النوع', style: label),
          const SizedBox(height: 6),
          ChoiceRow<String>(
            options: const ['cars', 'salary', 'ministry', 'other'],
            selected: _kind,
            height: 46,
            label: (k) => const {'cars': 'سيارات', 'salary': 'رواتب', 'ministry': 'وزارة', 'other': 'أخرى'}[k]!,
            onSelect: (k) => setState(() => _kind = k),
          ),
          const SizedBox(height: 12),
          if (_kind == 'salary')
            Container(
              padding: const EdgeInsetsDirectional.all(14),
              decoration: BoxDecoration(color: t.tonalBg, borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('الرواتب والسلف إلهم شاشة لحالهم', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: t.info)),
                const SizedBox(height: 6),
                const Text('عشان السلف والخصومات تنخصم لحالها وما ينصرف راتب مرتين.', style: TextStyle(fontSize: 13, height: 1.6)),
                const SizedBox(height: 8),
                Text('من المال ← الرواتب، أو كشف الموظف للسلفة والخصم والمكافأة', style: TextStyle(fontSize: 12, color: t.textSecondary)),
              ]),
            )
          else ...[
            if (_kind == 'cars') ...[
              const Text('أي سيارة؟', style: label),
              const SizedBox(height: 6),
              ChoiceRow<String>(options: _cars.map((c) => c.id).toList(), selected: _car, label: (id) => _cars.firstWhere((c) => c.id == id).name, onSelect: (id) => setState(() => _car = id)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final i in _carItems)
                  ChoiceChip(
                    label: Text(i),
                    selected: _carItem == i,
                    showCheckmark: false,
                    selectedColor: t.tonalBg,
                    side: BorderSide.none,
                    backgroundColor: t.bg,
                    labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _carItem == i ? t.info : t.text),
                    onSelected: (_) => setState(() => _carItem = i),
                  ),
              ]),
              if (_carItem == 'بنزين') ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _liters,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  decoration: const InputDecoration(hintText: 'كم لتر؟ (اختياري)'),
                ),
              ],
            ],
            if (_kind == 'ministry') ...[
              const Text('رسوم اختبار مين؟', style: label),
              const SizedBox(height: 6),
              TextField(
                controller: _q,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(hintText: 'بحث بالاسم أو الهوية', prefixIcon: Icon(Icons.search_rounded, color: t.textSecondary)),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 196),
                child: ListView(shrinkWrap: true, children: [
                  for (final s in _students.where((s) => _q.text.trim().isEmpty || s.name.contains(_q.text.trim()) || (s.student?.nationalId.contains(_q.text.trim()) ?? false)))
                    Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 6),
                      child: Panel(
                        radius: 10,
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
                        border: Border.all(color: _student == s.enrollment.studentId ? t.primary : t.border, width: _student == s.enrollment.studentId ? 2 : 1),
                        color: _student == s.enrollment.studentId ? t.tonalBg : t.card,
                        onTap: () => setState(() => _student = s.enrollment.studentId),
                        child: Row(children: [
                          Expanded(child: Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                          Pill(stageLabel(s.stage), bg: s.readyForExam ? const Color(0xFFFFF4CC) : t.divider, fg: s.readyForExam ? const Color(0xFF4A3A00) : t.textSecondary),
                        ]),
                      ),
                    ),
                ]),
              ),
            ],
            if (_kind == 'other') ...[
              const Text('شو المصروف؟', style: label),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final i in [..._otherItems, '+'])
                  ChoiceChip(
                    label: Text(i == '+' ? '+ بند جديد' : i),
                    selected: _otherItem == i,
                    showCheckmark: false,
                    selectedColor: t.tonalBg,
                    side: BorderSide.none,
                    backgroundColor: t.bg,
                    labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _otherItem == i ? t.info : t.text),
                    onSelected: (_) => setState(() => _otherItem = i),
                  ),
              ]),
              if (_otherItem == '+') ...[
                const SizedBox(height: 8),
                TextField(controller: _custom, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'اسم البند')),
              ],
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
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
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: t.primary, width: 2)),
              ),
            ),
            const SizedBox(height: 10),
            const Text('الدفع من', style: label),
            const SizedBox(height: 6),
            Row(children: [
              for (final (i, a) in _accounts.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Panel(
                    radius: 12,
                    padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
                    border: Border.all(color: _account == a.id ? t.primary : t.border, width: _account == a.id ? 2 : 1),
                    color: _account == a.id ? t.tonalBg : t.card,
                    onTap: () => setState(() => _account = a.id),
                    child: Column(children: [
                      Text(a.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _account == a.id ? t.info : t.text)),
                      MoneyText(a.balance, color: t.textSecondary, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ],
            ]),
            if (left != null && left.isNegative) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: t.problem.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Text('المبلغ أكبر من رصيد هالصندوق', style: TextStyle(color: t.problem, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
            const SizedBox(height: 8),
            Row(children: [
              Text('اليوم ${dayHeader(DateTime.now()).split(' ').last}', style: TextStyle(fontSize: 13, color: t.textSecondary)),
              const SizedBox(width: 6),
              TextButton(onPressed: () => setState(() => _showNote = !_showNote), child: const Text('ملاحظة')),
            ]),
            if (_showNote) TextField(controller: _note, decoration: const InputDecoration(hintText: 'ملاحظة (اختياري)')),
            const SizedBox(height: 8),
            AppButton(
              left == null ? 'حفظ' : 'حفظ $_what ${_value.format()} · يبقى ب${acc!.name} ${left.isNegative ? '−' : ''}${left.abs().format()}',
              height: 56,
              expand: true,
              busy: _busy,
              onPressed: _valid ? _save : null,
            ),
          ],
        ]),
      ),
    );
  }
}
