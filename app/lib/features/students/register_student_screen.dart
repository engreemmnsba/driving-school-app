import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_scope.dart';
import '../../core/auth/login_email.dart';
import '../../core/db/database.dart';
import '../../core/domain/money.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../money/receipt_screen.dart';
import 'student_actions.dart';
import 'student_profile_screen.dart';

/// Canvas: RegisterStudent — data → first payment → one WhatsApp message (login + receipt).
class RegisterStudentScreen extends StatefulWidget {
  const RegisterStudentScreen({super.key, this.schoolName = 'مدرسة القيادة'});
  final String schoolName;

  @override
  State<RegisterStudentScreen> createState() => _RegisterStudentScreenState();
}

class _RegisterStudentScreenState extends State<RegisterStudentScreen> {
  int _step = 1;
  final _name = TextEditingController();
  final _nid = TextEditingController();
  final _phone = TextEditingController();
  List<LicenseTypeRow> _licenses = const [];
  List<CarRow> _cars = const [];
  List<TreasuryAccountRow> _accounts = const [];
  String? _license;
  String? _car;
  LicensePriceRow? _price;
  StudentRow? _duplicate;
  bool _loaded = false;
  bool _busy = false;
  String? _error;

  // after step 1
  RegisteredStudent? _done;
  Money? _payAmount;
  String? _account;
  String? _paymentId;
  Money? _paid;

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
    final acc = await q.accounts();
    if (!mounted) return;
    setState(() {
      _licenses = lic;
      _cars = cars;
      _accounts = acc;
      _license = lic.isEmpty ? null : lic.first.id;
      _car = cars.isEmpty ? null : cars.first.id;
      _account = acc.isEmpty ? null : acc.first.id;
    });
    await _loadPrice();
  }

  Future<void> _loadPrice() async {
    if (_license == null) return;
    final p = await AppScope.of(context).queries.priceOn(_license!, todayStr());
    if (mounted) setState(() => _price = p);
  }

  Future<void> _checkId() async {
    final v = _nid.text.trim();
    StudentRow? dup;
    if (isValidNationalId(v)) {
      final db = AppScope.of(context).db;
      dup = await (db.select(db.students)..where((t) => t.nationalId.equals(v))).getSingleOrNull();
    }
    if (mounted) setState(() => _duplicate = dup);
  }

  @override
  void dispose() {
    _name.dispose();
    _nid.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _valid => _name.text.trim().length >= 2 && isValidNationalId(_nid.text) && _duplicate == null && _license != null && _car != null && _price != null;

  Future<void> _register() async {
    final app = AppScope.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final r = await app.registerStudent(
        name: _name.text.trim(),
        nationalId: _nid.text.trim(),
        phone: _phone.text.trim(),
        licenseTypeId: _license!,
        carId: _car!,
        businessDate: todayStr(),
      );
      app.syncSoon();
      final half = Money.shekels(((r.fee.agorot ~/ 100) * 0.6).round() ~/ 100 * 100);
      setState(() {
        _done = r;
        _step = 2;
        _payAmount = half.isPositive ? half : r.fee;
      });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pay() async {
    final app = AppScope.of(context);
    final r = _done!;
    setState(() => _busy = true);
    try {
      final id = await app.recordPayment(
        enrollmentId: r.enrollmentId,
        studentId: r.studentId,
        amount: _payAmount!,
        accountId: _account!,
        purpose: 'registration',
        businessDate: todayStr(),
      );
      app.syncSoon();
      setState(() {
        _paymentId = id;
        _paid = _payAmount;
        _step = 3;
      });
    } catch (e) {
      if (mounted) showErrorSnack(context, 'ما انحفظت الدفعة: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _whatsApp() async {
    final r = _done!;
    final app = AppScope.of(context);
    String? receipt;
    if (_paymentId != null) {
      final db = app.db;
      final p = await (db.select(db.ledgerEntries)..where((t) => t.id.equals(_paymentId!))).getSingle();
      receipt = 'وصل رقم ${p.receiptNo}: ${_paid!.format()} رسوم تسجيل · يبقى عليه ${(r.fee - _paid!).format()}';
    }
    final download = await app.db.kvGet('downloadUrl');
    final text = [
      'أهلًا ${_name.text.trim()} · ${widget.schoolName}',
      'الدخول على التطبيق:',
      'رقم الهوية: ${_nid.text.trim()}',
      'كلمة السر المؤقتة: ${r.password}',
      if (download != null && download.isNotEmpty) 'تنزيل التطبيق: $download',
      receipt ?? 'رسوم التسجيل ${r.fee.format()} (لسا ما انخصم منها)',
    ].join('\n');
    final phone = waPhone(_phone.text.trim());
    final uri = Uri.parse('https://wa.me/${phone ?? ''}?text=${Uri.encodeComponent(text)}');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) showErrorSnack(context, 'ما انفتح واتساب على هالجهاز');
  }

  void _restart() {
    setState(() {
      _step = 1;
      _done = null;
      _paymentId = null;
      _paid = null;
      _name.clear();
      _nid.clear();
      _phone.clear();
      _duplicate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    const steps = ['البيانات', 'أول دفعة', 'إرسال'];
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsetsDirectional.all(16),
              children: [
                const BackHeader(title: 'طالب جديد'),
                const SizedBox(height: 12),
                Row(children: [
                  for (final (i, s) in steps.indexed) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(height: 6, decoration: BoxDecoration(color: i < _step ? t.primary : t.border, borderRadius: BorderRadius.circular(999))),
                        const SizedBox(height: 4),
                        Text(s, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: i < _step ? t.info : t.textSecondary)),
                      ]),
                    ),
                  ],
                ]),
                const SizedBox(height: 12),
                if (_step == 1) ..._step1(t),
                if (_step == 2) ..._step2(t),
                if (_step == 3) ..._step3(t),
              ],
            ),
          ),
          Padding(padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16), child: _bottom()),
        ]),
      ),
    );
  }

  Widget _bottom() {
    switch (_step) {
      case 1:
        return AppButton('تسجيل ← أخذ دفعة', kind: AppButtonKind.accent, height: 56, expand: true, busy: _busy, onPressed: _valid ? _register : null);
      case 2:
        final left = _done!.fee - (_payAmount ?? const Money.zero());
        return Column(mainAxisSize: MainAxisSize.min, children: [
          AppButton('حفظ ${_payAmount?.format() ?? ''} · يبقى عليه ${left.format()}', height: 56, expand: true, busy: _busy, onPressed: _account == null ? null : _pay),
          TextButton(onPressed: () => setState(() => _step = 3), child: const Text('بدون دفعة الآن')),
        ]);
      default:
        return Column(mainAxisSize: MainAxisSize.min, children: [
          AppButton('إرسال على واتساب', kind: AppButtonKind.success, icon: Icons.send_rounded, height: 56, expand: true, onPressed: _whatsApp),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: AppButton('فتح ملفه', kind: AppButtonKind.outline, onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => StudentProfileScreen(enrollmentId: _done!.enrollmentId)));
              }),
            ),
            const SizedBox(width: 8),
            Expanded(child: AppButton('طالب جديد آخر', kind: AppButtonKind.outline, onPressed: _restart)),
          ]),
        ]);
    }
  }

  List<Widget> _step1(AppTokens t) {
    final nid = _nid.text.trim();
    final idHint = nid.isEmpty
        ? null
        : (!isValidNationalId(nid)
            ? ('لازم 9 أرقام', t.textSecondary)
            : (_duplicate != null ? ('مسجّل لـ${_duplicate!.name}', t.problem) : ('✓ رقم صحيح ومش مكرر', t.money)));
    const label = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);
    return [
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('الاسم', style: label),
          const SizedBox(height: 4),
          TextField(controller: _name, textInputAction: TextInputAction.next, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'الاسم الرباعي')),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('رقم الهوية', style: label),
                const SizedBox(height: 4),
                TextField(
                  controller: _nid,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
                  onChanged: (_) {
                    setState(() {});
                    _checkId();
                  },
                ),
                if (idHint != null) ...[const SizedBox(height: 4), Text(idHint.$1, style: TextStyle(fontSize: 12, color: idHint.$2))],
              ]),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('الجوال', style: label),
                const SizedBox(height: 4),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')), LengthLimitingTextInputFormatter(14)],
                ),
              ]),
            ),
          ]),
          if (_duplicate != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () async {
                  final db = AppScope.of(context).db;
                  final e = await (db.select(db.enrollments)..where((x) => x.studentId.equals(_duplicate!.id))).get();
                  if (!mounted || e.isEmpty) return;
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => StudentProfileScreen(enrollmentId: e.first.id)));
                },
                child: const Text('فتح ملفه · إضافة رخصة تانية بتيجي بدفعة الاختبارات'),
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Text('الرخصة', style: label),
          const SizedBox(height: 4),
          if (_licenses.isEmpty)
            Text('ما في رخص لسا · بتنضاف من إعدادات الرخص', style: TextStyle(color: t.problem, fontSize: 13))
          else
            ChoiceRow<String>(
              options: _licenses.map((l) => l.id).toList(),
              selected: _license,
              label: (id) => _licenses.firstWhere((l) => l.id == id).name,
              onSelect: (id) {
                setState(() => _license = id);
                _loadPrice();
              },
            ),
          const SizedBox(height: 10),
          const Text('السيارة', style: label),
          const SizedBox(height: 4),
          if (_cars.isEmpty)
            Text('ما في سيارات لسا', style: TextStyle(color: t.problem, fontSize: 13))
          else
            ChoiceRow<String>(
              options: _cars.map((c) => c.id).toList(),
              selected: _car,
              label: (id) => _cars.firstWhere((c) => c.id == id).name,
              onSelect: (id) => setState(() => _car = id),
            ),
          if (_price != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: t.tonalBg, borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('رسوم التسجيل ${Money(_price!.registrationFee).format()} · بتنحسب عليه الآن', style: TextStyle(color: t.info, fontWeight: FontWeight.w700, fontSize: 13)),
                Text('بتشمل كل دروس النظري وأول اختبار نظري · الدرس العملي ${Money(_price!.practicalLessonPrice).format()}', style: TextStyle(color: t.info, fontSize: 13)),
              ]),
            ),
          ],
          if (_error != null) ...[const SizedBox(height: 10), Text(_error!, style: TextStyle(color: t.problem, fontWeight: FontWeight.w600))],
        ]),
      ),
    ];
  }

  List<Widget> _step2(AppTokens t) {
    final r = _done!;
    final options = <Money>{Money.shekels(200), Money.shekels(300), r.fee}.where((m) => m <= r.fee).toList();
    return [
      Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: t.moneyBg, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Icon(Icons.check_rounded, color: t.money),
          const SizedBox(width: 10),
          Expanded(child: Text('انسجّل ${_name.text.trim().split(' ').first} · عليه ${r.fee.format()}', style: TextStyle(color: t.money, fontWeight: FontWeight.w600))),
        ]),
      ),
      const SizedBox(height: 12),
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('أول دفعة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ChoiceRow<Money>(
            options: options,
            selected: _payAmount,
            height: 46,
            label: (m) => m == r.fee ? 'كل الرسوم' : m.format(),
            onSelect: (m) => setState(() => _payAmount = m),
          ),
          const SizedBox(height: 10),
          const Text('الصندوق', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          ChoiceRow<String>(
            options: _accounts.map((a) => a.id).toList(),
            selected: _account,
            label: (id) => _accounts.firstWhere((a) => a.id == id).name,
            onSelect: (id) => setState(() => _account = id),
          ),
          const SizedBox(height: 8),
          Text('النوع: رسوم تسجيل · التاريخ: اليوم', style: TextStyle(fontSize: 12, color: t.textSecondary)),
        ]),
      ),
    ];
  }

  List<Widget> _step3(AppTokens t) {
    final r = _done!;
    final first = _name.text.trim().split(' ').first;
    final accName = _accounts.where((a) => a.id == _account).map((a) => a.name).firstOrNull ?? '';
    return [
      Panel(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 20),
        child: Column(children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: t.moneyBg, shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, color: t.money, size: 28),
          ),
          const SizedBox(height: 10),
          Text('$first جاهز', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            _paid == null ? 'عليه ${r.fee.format()} رسوم التسجيل' : 'دفع ${_paid!.format()} $accName · يبقى عليه ${(r.fee - _paid!).format()}',
            style: TextStyle(fontSize: 14, color: t.textSecondary),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('رسالة واتساب وحدة فيها:', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('• بيانات الدخول: الهوية + كلمة سر مؤقتة'),
          const Text('• رابط تنزيل التطبيق (لما ينحط بالإعدادات)'),
          Text(_paid == null ? '• بدون وصل (ما دفع)' : '• تفاصيل وصل الدفعة'),
          const SizedBox(height: 10),
          Row(children: [
            Text('كلمة السر المؤقتة: ', style: TextStyle(color: t.textSecondary, fontSize: 13)),
            SelectableText(r.password, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 1)),
          ]),
          Text('الطالب بيقدر يدخل بعد ما يوصل التسجيل للسيرفر', style: TextStyle(color: t.textSecondary, fontSize: 12)),
          if (_paymentId != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ReceiptScreen(paymentId: _paymentId!))),
                child: const Text('عرض الوصل'),
              ),
            ),
        ]),
      ),
    ];
  }
}
