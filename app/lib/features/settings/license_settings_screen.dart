import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_scope.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/settings_queries.dart';
import 'settings_actions.dart';

/// Canvas LicenseSettings: one tab per license type (+ new). Prices apply from today; old charges keep theirs.
class LicenseSettingsScreen extends StatefulWidget {
  const LicenseSettingsScreen({super.key, this.licenseTypeId});

  /// null = start on "new license".
  final String? licenseTypeId;

  @override
  State<LicenseSettingsScreen> createState() => _LicenseSettingsScreenState();
}

class _LicenseSettingsScreenState extends State<LicenseSettingsScreen> {
  List<LicenseOverview> _list = const [];
  String? _sel; // null = new
  LicenseForm _f = LicenseForm.empty();
  bool _tried = false;
  bool _busy = false;
  bool _loaded = false;
  final _ctl = <String, TextEditingController>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _load(select: widget.licenseTypeId);
  }

  @override
  void dispose() {
    for (final c in _ctl.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load({String? select}) async {
    final list = await AppScope.of(context).settings.queries.licenses();
    if (!mounted) return;
    setState(() => _list = list);
    _pick(select);
  }

  LicenseOverview? get _current => _list.where((l) => l.type.id == _sel).firstOrNull;

  void _pick(String? id) {
    final cur = _list.where((l) => l.type.id == id).firstOrNull;
    final f = cur == null ? LicenseForm.empty() : LicenseForm.of(cur.type, cur.price);
    setState(() {
      _sel = cur?.type.id;
      _f = f;
      _tried = false;
    });
    String shekels(int a) => a == 0 ? '' : '${a ~/ 100}';
    _text('name').text = f.name;
    _text('reg').text = shekels(f.registrationFee);
    _text('retake').text = shekels(f.theoryRetakeFee);
    _text('lesson').text = shekels(f.practicalLessonPrice);
    _text('exam').text = shekels(f.practicalExamFee);
  }

  TextEditingController _text(String k) => _ctl.putIfAbsent(k, TextEditingController.new);

  int _ag(String k) => (int.tryParse(_text(k).text) ?? 0) * 100;

  void _sync() => setState(() {
        _f
          ..name = _text('name').text
          ..registrationFee = _ag('reg')
          ..theoryRetakeFee = _ag('retake')
          ..practicalLessonPrice = _ag('lesson')
          ..practicalExamFee = _ag('exam');
      });

  Future<void> _save() async {
    _sync();
    if (!_f.valid) {
      setState(() => _tried = true);
      showErrorSnack(context, 'في حقول ناقصة أو غلط بالأحمر');
      return;
    }
    final app = AppScope.of(context);
    setState(() => _busy = true);
    try {
      final cur = _current;
      await app.settings.saveLicense(type: cur?.type, current: cur?.price, f: _f, effectiveFrom: todayStr());
      app.syncSoon();
      if (!mounted) return;
      showUndoSnack(context, 'انحفظت رخصة ${_f.name.trim()} · الأسعار الجديدة من اليوم');
      final name = _f.name.trim();
      final list = await app.settings.queries.licenses();
      if (!mounted) return;
      setState(() {
        _list = list;
        _busy = false;
      });
      _pick(list.where((l) => l.type.name == name).firstOrNull?.type.id);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showErrorSnack(context, '$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    final f = _f;
    final cur = _current;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
          children: [
            BackHeader(title: 'أنواع الرخص والأسعار', trailing: AppButton('حفظ', height: 44, busy: _busy, onPressed: _save)),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final l in _list) _tab(context, l.type.active ? l.type.name : '${l.type.name} (موقوفة)', _sel == l.type.id, () => _pick(l.type.id)),
              _tab(context, '+ رخصة جديدة', _sel == null, () => _pick(null), dashed: true),
            ]),
            const SizedBox(height: 10),
            Panel(
              radius: 14,
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 6),
              child: Column(children: [
                _field(context, 'اسم الرخصة', 'name', hint: 'مثلًا: شحن', width: 160, error: _tried && f.nameError != null, numeric: false),
                Divider(color: t.divider, height: 1),
                _field(context, 'رسوم التسجيل (₪)', 'reg', sub: 'بتشمل كل دروس النظري وأول اختبار نظري', error: _tried && f.registrationError != null),
              ]),
            ),
            const SizedBox(height: 10),
            _part(context, title: 'النظري (بدون سعر للدرس)', price: null, count: f.plannedTheory, min: f.minTheory,
                onCount: (v) => setState(() => f.plannedTheory = v), onMin: (v) => setState(() => f.minTheory = v),
                feeLabel: 'رسوم إعادة النظري بعد الرسوب (₪)', feeKey: 'retake', error: f.minTheory > f.plannedTheory || _tried ? f.theoryError : null),
            const SizedBox(height: 10),
            _part(context, title: 'العملي', price: 'lesson', count: f.plannedPractical, min: f.minPractical,
                onCount: (v) => setState(() => f.plannedPractical = v), onMin: (v) => setState(() => f.minPractical = v),
                feeLabel: 'رسوم الاختبار العملي (₪)', feeKey: 'exam', error: f.minPractical > f.plannedPractical || _tried ? f.practicalError : null),
            const SizedBox(height: 10),
            Panel(
              radius: 14,
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 4, vertical: 2),
              child: CheckboxListTile(
                value: f.practicalAfterTheory,
                onChanged: (v) => setState(() => f.practicalAfterTheory = v ?? true),
                title: const Text('العملي بيبدأ بعد اجتياز النظري', style: TextStyle(fontSize: 14)),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: t.primary,
              ),
            ),
            const SizedBox(height: 10),
            Panel(
              radius: 14,
              border: Border.all(color: t.primary, width: 2),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Expanded(child: Text('السعر الكامل المتوقع', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.info))),
                  MoneyText(f.expectedTotal, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                ]),
                MoneyRichText(
                  'تسجيل ${Money(f.registrationFee).format()} + ${f.plannedPractical} عملي × ${Money(f.practicalLessonPrice).format()} + اختبار عملي ${Money(f.practicalExamFee).format()}',
                  style: TextStyle(fontSize: 12, color: t.textSecondary),
                ),
                const SizedBox(height: 2),
                Text('الأسعار الجديدة بتنطبق على الدروس والرسوم اللي بتنسجّل من اليوم', style: TextStyle(fontSize: 12, color: t.textSecondary)),
              ]),
            ),
            if (cur != null) ...[
              const SizedBox(height: 10),
              AppButton(
                cur.type.active ? 'إيقاف هالرخصة للتسجيل الجديد' : 'رجّعها متاحة للتسجيل',
                kind: cur.type.active ? AppButtonKind.danger : AppButtonKind.outline,
                height: 48,
                expand: true,
                onPressed: () async {
                  await app.settings.setLicenseActive(cur.type, !cur.type.active);
                  app.syncSoon();
                  if (mounted) _load(select: cur.type.id);
                },
              ),
              Text('الطلاب المسجلين عليها بيضلوا عليها', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: t.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tab(BuildContext context, String label, bool on, VoidCallback onTap, {bool dashed = false}) {
    final t = context.tokens;
    return ChoiceChip(
      label: Text(label),
      selected: on,
      showCheckmark: false,
      selectedColor: t.tonalBg,
      backgroundColor: t.card,
      side: BorderSide(color: on ? t.primary : (dashed ? t.muted : t.border), width: on ? 2 : 1),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: on ? t.info : t.text),
      onSelected: (_) => onTap(),
    );
  }

  Widget _field(BuildContext context, String label, String key, {String? sub, String? hint, double width = 100, bool error = false, bool numeric = true}) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            if (sub != null) Text(sub, style: TextStyle(fontSize: 12, color: t.textSecondary)),
          ]),
        ),
        SizedBox(
          width: width,
          height: 42,
          child: TextField(
            controller: _text(key),
            keyboardType: numeric ? TextInputType.number : TextInputType.text,
            inputFormatters: numeric ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)] : null,
            textAlign: TextAlign.center,
            textDirection: numeric ? TextDirection.ltr : null,
            onChanged: (_) => _sync(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: hint ?? '0',
              contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: error ? t.problem : t.border, width: error ? 2 : 1)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _stepper(BuildContext context, String label, int value, ValueChanged<int> onChanged, {int min = 0, bool bad = false}) {
    final t = context.tokens;
    Widget btn(String s, VoidCallback? onTap, String semantic) => SizedBox.square(
          dimension: 44,
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, side: BorderSide(color: t.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(s, semanticsLabel: semantic, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        );
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        btn('−', value > min ? () => onChanged(value - 1) : null, 'إنقاص'),
        SizedBox(width: 36, child: Text('$value', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: bad ? t.problem : null))),
        btn('+', value < 60 ? () => onChanged(value + 1) : null, 'زيادة'),
      ]),
    );
  }

  Widget _part(BuildContext context,
      {required String title,
      required String? price,
      required int count,
      required int min,
      required ValueChanged<int> onCount,
      required ValueChanged<int> onMin,
      required String feeLabel,
      required String feeKey,
      required String? error}) {
    final t = context.tokens;
    return Panel(
      radius: 14,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(padding: const EdgeInsetsDirectional.symmetric(vertical: 4), child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: t.info))),
        if (price != null) _field(context, 'سعر الدرس الواحد (₪)', price, error: _tried && _ag(price) <= 0),
        _stepper(context, 'عدد الدروس المخطط', count, onCount, min: 1),
        _stepper(context, 'حد أدنى قبل الاختبار', min, onMin, bad: min > count),
        _field(context, feeLabel, feeKey, error: _tried && _ag(feeKey) <= 0),
        if (error != null)
          Container(
            margin: const EdgeInsetsDirectional.only(bottom: 6),
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: t.problem.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(error, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.problem)),
          ),
      ]),
    );
  }
}
