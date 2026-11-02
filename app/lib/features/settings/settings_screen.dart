import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_scope.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../data/queries.dart';
import '../../data/settings_queries.dart';
import '../staff/cars_screen.dart';
import '../staff/payroll_sheets.dart' show staffSheet;
import '../staff/users_screen.dart';
import 'accounts_screen.dart';
import 'license_settings_screen.dart';

class _Data {
  const _Data(this.school, this.licenses, this.general, this.accounts, this.cars, this.users);
  final SchoolInfo school;
  final List<LicenseOverview> licenses;
  final Map<String, Object?> general;
  final int accounts;
  final int cars;
  final int users;
}

/// Canvas Settings: school, license types & prices, general rules, links.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Stream<_Data>? _stream;

  Future<void> _save(String key, Object value, String done) async {
    final app = AppScope.of(context);
    try {
      await app.settings.setSetting(key, value);
      app.syncSoon();
      if (mounted) showUndoSnack(context, done);
    } catch (e) {
      if (mounted) showErrorSnack(context, '$e');
    }
  }

  Future<void> _editSchool(SchoolInfo s) async {
    final r = await staffSheet<Map<String, String>>(context, _SchoolSheet(info: s));
    if (r != null && mounted) await _save('school', r, 'انحفظت بيانات المدرسة');
  }

  Future<void> _editNumber(String key, String label, int current, {String? suffix, bool money = false, int min = 0, int max = 100000}) async {
    final v = await staffSheet<int>(context, _NumberSheet(label: label, current: money ? current ~/ 100 : current, suffix: suffix, money: money, min: min, max: max));
    if (v == null || !mounted) return;
    await _save(key, money ? v * 100 : v, 'انحفظ: $label');
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    final q = app.settings.queries;
    _stream ??= watchLoad(app.db, () async => _Data(
          await q.school(),
          await q.licenses(),
          await q.general(),
          (await q.accounts()).where((a) => a.account.active).length,
          (await app.queries.cars()).length,
          (await app.staff.queries.users()).length,
        ));
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<_Data>(
          stream: _stream,
          builder: (context, snap) {
            final d = snap.data;
            if (d == null) {
              return const Padding(padding: EdgeInsetsDirectional.all(16), child: Column(children: [BackHeader(title: 'الإعدادات'), SizedBox(height: 16), SkeletonCards(count: 4)]));
            }
            final g = d.general;
            int n(String k) => (g[k] as num?)?.toInt() ?? (settingDefaults[k] as int);
            final salaryDay = n('salaryDueDay');
            Widget rule(String label, String value, VoidCallback onTap) => InkWell(
                  onTap: onTap,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: t.divider))),
                    child: Row(children: [
                      Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
                      Container(
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: t.bg, borderRadius: BorderRadius.circular(10)),
                        child: MoneyRichText(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                  ),
                );
            Widget link(String label, String meta, Widget page) => InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page)),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: t.divider))),
                    child: Row(children: [
                      Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
                      Text(meta, style: TextStyle(fontSize: 13, color: t.textSecondary)),
                      Icon(Icons.chevron_left_rounded, color: t.muted),
                    ]),
                  ),
                );
            return ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
              children: [
                const BackHeader(title: 'الإعدادات'),
                const SizedBox(height: 14),
                Panel(
                  child: Row(children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: t.primary, borderRadius: BorderRadius.circular(16)),
                      child: Icon(Icons.directions_car_filled_rounded, color: t.onPrimary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(d.school.isSet ? d.school.name : 'اسم المدرسة مش محطوط', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        Text(
                          [d.school.phone, d.school.address].whereType<String>().where((x) => x.isNotEmpty).join(' · ').isEmpty
                              ? 'بيظهر بالتطبيق والتقارير والوصولات'
                              : [d.school.phone, d.school.address].whereType<String>().where((x) => x.isNotEmpty).join(' · '),
                          style: TextStyle(fontSize: 12, color: t.textSecondary),
                        ),
                      ]),
                    ),
                    AppButton('تغيير', height: 44, kind: AppButtonKind.outline, onPressed: () => _editSchool(d.school)),
                  ]),
                ),
                const SizedBox(height: 14),
                Panel(
                  radius: 14,
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 4),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Padding(padding: const EdgeInsetsDirectional.only(top: 10, bottom: 4), child: Text('أنواع الرخص والأسعار', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: t.info))),
                    for (final l in d.licenses)
                      InkWell(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LicenseSettingsScreen(licenseTypeId: l.type.id))),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 48),
                          decoration: BoxDecoration(border: Border(top: BorderSide(color: t.divider))),
                          child: Row(children: [
                            Expanded(child: Text(l.type.active ? l.type.name : '${l.type.name} · موقوفة', style: TextStyle(fontSize: 14, color: l.type.active ? t.text : t.textSecondary))),
                            if (l.price == null)
                              Text('ما في أسعار', style: TextStyle(fontSize: 13, color: t.problem, fontWeight: FontWeight.w600))
                            else ...[
                              MoneyRichText('تسجيل ${Money(l.price!.registrationFee).format()} · عملي ${Money(l.price!.practicalLessonPrice).format()}', style: TextStyle(fontSize: 12, color: t.textSecondary)),
                              const SizedBox(width: 8),
                              MoneyText(l.expectedTotal!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            ],
                            Icon(Icons.chevron_left_rounded, color: t.muted),
                          ]),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: 6, bottom: 10),
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const LicenseSettingsScreen())),
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(40), side: BorderSide(color: t.muted)),
                        child: const Text('+ نوع رخصة'),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 14),
                Panel(
                  radius: 14,
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 4),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Padding(padding: const EdgeInsetsDirectional.only(top: 10, bottom: 4), child: Text('إعدادات عامة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: t.info))),
                    rule('مدة الدرس', '${n('lessonDurationMin')} دقيقة', () => _editNumber('lessonDurationMin', 'مدة الدرس', n('lessonDurationMin'), suffix: 'دقيقة', min: 10, max: 180)),
                    rule('تسجيل الدروس النظري', g['theoryLessonsEnabled'] == false ? 'مطفي' : 'مفعّل', () => _save('theoryLessonsEnabled', g['theoryLessonsEnabled'] == false, g['theoryLessonsEnabled'] == false ? 'انفعل تسجيل الدروس النظري' : 'انطفى تسجيل الدروس النظري · النظري صار اختبار بس')),
                    rule('خيار درس بدون تشغيل', g['withoutDrivingEnabled'] != true ? 'مطفي' : 'مفعّل', () => _save('withoutDrivingEnabled', g['withoutDrivingEnabled'] != true, g['withoutDrivingEnabled'] != true ? 'انفعل خيار درس بدون تشغيل' : 'انطفى خيار درس بدون تشغيل')),
                    rule('زر إغلاق اليوم بيطلع من الساعة', '${n('closeReminderHour')}:00', () => _editNumber('closeReminderHour', 'زر إغلاق اليوم من الساعة', n('closeReminderHour'), min: 12, max: 23)),
                    rule('الدين المتأخر فوق', Money(n('overdueAmount')).format(), () => _editNumber('overdueAmount', 'الدين المتأخر فوق', n('overdueAmount'), money: true, max: 100000)),
                    rule('وبدون دفع من', '${n('overdueDays')} يوم', () => _editNumber('overdueDays', 'بدون دفع من', n('overdueDays'), suffix: 'يوم', min: 1, max: 365)),
                    rule('يوم صرف الرواتب', salaryDay == 0 ? 'آخر الشهر' : 'يوم $salaryDay', () => _editNumber('salaryDueDay', 'يوم صرف الرواتب (0 = آخر الشهر)', salaryDay, max: 28)),
                  ]),
                ),
                const SizedBox(height: 14),
                Panel(
                  radius: 14,
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 4),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    link('الصناديق وطرق الدفع', '${d.accounts} صناديق', const AccountsScreen()),
                    if (app.user.can('users')) link('المستخدمون والصلاحيات', '${d.users} مستخدمين', const UsersScreen()),
                    link('السيارات والمدربون', '${d.cars} سيارات', const CarsScreen()),
                    Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: t.divider))),
                      child: Row(children: [
                        const Expanded(child: Text('اللغة والمظهر', style: TextStyle(fontSize: 14))),
                        Text('العربية · حسب الجوال', style: TextStyle(fontSize: 13, color: t.textSecondary)),
                      ]),
                    ),
                  ]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SchoolSheet extends StatefulWidget {
  const _SchoolSheet({required this.info});
  final SchoolInfo info;

  @override
  State<_SchoolSheet> createState() => _SchoolSheetState();
}

class _SchoolSheetState extends State<_SchoolSheet> {
  late final _name = TextEditingController(text: widget.info.name);
  late final _phone = TextEditingController(text: widget.info.phone ?? '');
  late final _address = TextEditingController(text: widget.info.address ?? '');

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('بيانات المدرسة', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        TextField(controller: _name, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'اسم المدرسة')),
        const SizedBox(height: 8),
        TextField(controller: _phone, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: 'الهاتف (اختياري)')),
        const SizedBox(height: 8),
        TextField(controller: _address, decoration: const InputDecoration(labelText: 'العنوان (اختياري)')),
        const SizedBox(height: 6),
        Text('الشعار بينضاف مع النسخة الأخيرة (رفع الصور بيحتاج تفعيل التخزين بالسيرفر)', style: TextStyle(fontSize: 12, color: context.tokens.textSecondary)),
        const SizedBox(height: 12),
        AppButton('حفظ', height: 52, expand: true, onPressed: _name.text.trim().length < 2
            ? null
            : () => Navigator.of(context).pop({'name': _name.text.trim(), 'phone': _phone.text.trim(), 'address': _address.text.trim()})),
      ]),
    );
  }
}

class _NumberSheet extends StatefulWidget {
  const _NumberSheet({required this.label, required this.current, required this.money, required this.min, required this.max, this.suffix});
  final String label;
  final int current;
  final bool money;
  final int min;
  final int max;
  final String? suffix;

  @override
  State<_NumberSheet> createState() => _NumberSheetState();
}

class _NumberSheetState extends State<_NumberSheet> {
  late final _c = TextEditingController(text: '${widget.current}');

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = int.tryParse(_c.text);
    final ok = v != null && v >= widget.min && v <= widget.max;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(widget.label, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        TextField(
          controller: _c,
          autofocus: true,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          decoration: InputDecoration(prefixText: widget.money ? '₪ ' : null, suffixText: widget.suffix),
        ),
        if (!ok) ...[
          const SizedBox(height: 6),
          Text('رقم بين ${widget.min} و ${widget.max}', style: TextStyle(fontSize: 12, color: context.tokens.problem)),
        ],
        const SizedBox(height: 12),
        AppButton('حفظ', height: 52, expand: true, onPressed: ok ? () => Navigator.of(context).pop(v) : null),
      ]),
    );
  }
}
