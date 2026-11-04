import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_scope.dart';
import '../../core/db/database.dart';
import '../../core/domain/money.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/queries.dart';
import '../../data/staff_queries.dart';
import '../money/receipt_screen.dart' show waPhone;
import 'payroll_sheets.dart' show staffSheet;
import 'permissions_screen.dart';

/// Canvas Users: every login of the school (students' logins come from registration).
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _filter = 'all';
  Stream<List<UserView>>? _stream;
  final _busy = <String>{};

  Future<void> _toggle(UserView u, bool lastAdmin) async {
    if (lastAdmin) {
      showErrorSnack(context, 'ما بينفع إيقاف آخر مدير');
      return;
    }
    final app = AppScope.of(context);
    setState(() => _busy.add(u.user.id));
    try {
      await app.staff.setStatus(user: u.user, active: !u.active);
      app.syncSoon();
      if (mounted) {
        showUndoSnack(context, u.active ? 'انوقف حساب ${u.user.name} · بيطلع من كل الأجهزة' : 'رجع حساب ${u.user.name} شغّال');
      }
    } catch (e) {
      if (mounted) showErrorSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _busy.remove(u.user.id));
    }
  }

  /// New temporary password: confirm, queue it, then WhatsApp it (or show it once).
  Future<void> _resetPassword(UserView u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text('كلمة سر جديدة لـ${u.user.name}'),
        content: const Text('بتنعمل كلمة سر مؤقتة، والحساب بيطلع من كل الأجهزة لما توصل للسيرفر.', style: TextStyle(height: 1.6)),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.of(d).pop(true), child: const Text('كلمة سر جديدة')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final app = AppScope.of(context);
    try {
      final password = await app.staff.resetPassword(userId: u.user.id);
      app.syncSoon();
      final text = Uri.encodeComponent('أهلين ${u.user.name}، كلمة سرك الجديدة بتطبيق المدرسة:\nرقم الهوية: ${u.user.nationalId}\nكلمة السر المؤقتة: $password');
      final phone = waPhone(u.user.phone ?? '');
      final sent = await launchUrl(Uri.parse(phone == null ? 'https://wa.me/?text=$text' : 'https://wa.me/$phone?text=$text'), mode: LaunchMode.externalApplication);
      if (!mounted) return;
      if (sent) showUndoSnack(context, 'انعملت كلمة سر جديدة لـ${u.user.name} · بيطلع من كل الأجهزة لما توصل للسيرفر');
      if (!sent) {
        await showDialog<void>(
          context: context,
          builder: (d) => AlertDialog(
            title: Text('كلمة سر ${u.user.name}'),
            content: Text('واتساب ما انفتح · كلمة السر المؤقتة (بتنعرض هالمرة بس):\n\n$password', style: const TextStyle(height: 1.7)),
            actions: [TextButton(onPressed: () => Navigator.of(d).pop(), child: const Text('تمام'))],
          ),
        );
      }
    } catch (e) {
      if (mounted) showErrorSnack(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    _stream ??= watchLoad(app.db, app.staff.queries.users);
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<UserView>>(
          stream: _stream,
          builder: (context, snap) {
            final all = snap.data;
            final admins = all?.where((u) => u.user.kind == 'admin' && u.active).length ?? 0;
            final shown = all?.where((u) => _filter == 'all' || u.user.kind == _filter).toList();
            return ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
              children: [
                BackHeader(
                  title: 'المستخدمون',
                  trailing: AppButton('مستخدم', icon: Icons.add_rounded, height: 44, kind: AppButtonKind.accent, onPressed: () => staffSheet<void>(context, const _AddUserSheet())),
                ),
                const SizedBox(height: 12),
                ChoiceRow<String>(
                  options: const ['all', 'admin', 'instructor', 'staff'],
                  selected: _filter,
                  height: 40,
                  label: (k) => const {'all': 'الكل', 'admin': 'مدير', 'instructor': 'مدرب', 'staff': 'موظف'}[k]!,
                  onSelect: (k) => setState(() => _filter = k),
                ),
                const SizedBox(height: 12),
                if (snap.hasError)
                  ErrorPanel(title: 'ما انفتحت قائمة المستخدمين', body: '${snap.error}')
                else if (shown == null)
                  const SkeletonCards(count: 4, height: 64)
                else if (shown.isEmpty)
                  const EmptyState(icon: Icons.people_outline, title: 'ما في مستخدمين بهالتصنيف')
                else
                  for (final u in shown)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 8),
                      child: Opacity(
                        opacity: u.active ? 1 : 0.6,
                        child: Panel(
                          radius: 14,
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
                          child: Row(children: [
                            InitialBox(u.user.name),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(u.user.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                Text(u.meta, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                              ]),
                            ),
                            if (u.user.kind != 'admin' && u.user.id != app.user.uid) ...[
                              AppButton('الصلاحيات', height: 40, kind: AppButtonKind.outline, onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PermissionsScreen(userId: u.user.id)));
                              }),
                              const SizedBox(width: 6),
                            ],
                            if (u.user.id != app.user.uid && u.active && (u.user.kind != 'admin' || app.user.isAdmin)) ...[
                              IconButton(
                                tooltip: 'كلمة سر جديدة',
                                color: t.textSecondary,
                                icon: const Icon(Icons.key_rounded, size: 20),
                                onPressed: () => _resetPassword(u),
                              ),
                            ],
                            if (u.user.id != app.user.uid)
                              _StatusButton(
                                label: u.user.kind == 'admin' && u.active && admins <= 1 ? 'آخر مدير' : u.active ? 'إيقاف' : 'تفعيل',
                                color: u.user.kind == 'admin' && u.active && admins <= 1 ? t.textSecondary : u.active ? t.problem : t.money,
                                busy: _busy.contains(u.user.id),
                                onTap: () => _toggle(u, u.user.kind == 'admin' && u.active && admins <= 1),
                              ),
                          ]),
                        ),
                      ),
                    ),
                const SizedBox(height: 6),
                Text('حسابات الطلاب بتنعمل لحالها من تسجيل الطالب', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: t.textSecondary)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({required this.label, required this.color, required this.busy, required this.onTap});
  final String label;
  final Color color;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: busy ? null : onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.45)),
        minimumSize: const Size(64, 40),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }
}

class _AddUserSheet extends StatefulWidget {
  const _AddUserSheet();

  @override
  State<_AddUserSheet> createState() => _AddUserSheetState();
}

class _AddUserSheetState extends State<_AddUserSheet> {
  final _name = TextEditingController();
  final _nid = TextEditingController();
  final _phone = TextEditingController();
  final _salary = TextEditingController();
  String _role = 'instructor';
  String _job = 'secretary';
  final _cars = <String>{};
  List<CarRow> _allCars = const [];
  bool _busy = false;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    AppScope.of(context).queries.cars().then((c) {
      if (mounted) setState(() => _allCars = c);
    });
  }

  @override
  void dispose() {
    for (final c in [_name, _nid, _phone, _salary]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid => _name.text.trim().length >= 2 && RegExp(r'^\d{9}$').hasMatch(_nid.text.trim());

  Future<void> _save() async {
    final app = AppScope.of(context);
    setState(() => _busy = true);
    try {
      final created = await app.staff.createUser(
        name: _name.text,
        nationalId: _nid.text,
        phone: _phone.text,
        role: _role,
        job: _role == 'staff' ? _job : null,
        carIds: _role == 'instructor' ? _cars.toList() : const [],
        salary: _role == 'admin' ? const Money.zero() : Money.shekels(int.tryParse(_salary.text) ?? 0),
        businessDate: todayStr(),
      );
      app.syncSoon();
      final name = _name.text.trim();
      final text = Uri.encodeComponent(
        'أهلين $name، حسابك بتطبيق مدرسة القيادة جاهز.\nرقم الهوية: ${_nid.text.trim()}\nكلمة السر المؤقتة: ${created.password}\nالحساب بيشتغل أول ما يوصل للسيرفر.',
      );
      final phone = waPhone(_phone.text);
      final uri = Uri.parse(phone == null ? 'https://wa.me/?text=$text' : 'https://wa.me/$phone?text=$text');
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      final nav = Navigator.of(context);
      nav.pop();
      if (nav.context.mounted) {
        if (ok) {
          showUndoSnack(nav.context, 'انضاف $name · انبعتت بيانات الدخول');
        } else {
          // WhatsApp didn't open: show the password once so it can be passed on another way.
          await showDialog<void>(
            context: nav.context,
            builder: (d) => AlertDialog(
              title: Text('انضاف $name'),
              content: Text('واتساب ما انفتح · كلمة السر المؤقتة (بتنعرض هالمرة بس):\n\n${created.password}', style: const TextStyle(height: 1.7)),
              actions: [TextButton(onPressed: () => Navigator.of(d).pop(), child: const Text('تمام'))],
            ),
          );
        }
      }
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
    const label = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);
    final roles = [('instructor', 'مدرب'), ('staff', 'موظف'), if (app.user.isAdmin) ('admin', 'مدير')];
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('مستخدم جديد', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        TextField(controller: _name, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'الاسم')),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _nid,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'رقم الهوية'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(labelText: 'الجوال'),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        const Text('الدور (بيحدد الصلاحيات الأولية)', style: label),
        const SizedBox(height: 6),
        ChoiceRow<String>(options: [for (final r in roles) r.$1], selected: _role, label: (k) => roles.firstWhere((r) => r.$1 == k).$2, onSelect: (k) => setState(() => _role = k)),
        if (_role == 'staff') ...[
          const SizedBox(height: 10),
          const Text('شغلة جاهزة كبداية', style: label),
          const SizedBox(height: 6),
          ChoiceRow<String>(options: const ['secretary', 'accountant'], selected: _job, label: (k) => k == 'accountant' ? 'محاسب' : 'سكرتاريا', onSelect: (k) => setState(() => _job = k)),
          const SizedBox(height: 4),
          Text('بيبلّش على صندوق الكاش بس · الصلاحيات والصناديق بتتعدّل بعدين من "الصلاحيات"', style: TextStyle(fontSize: 12, color: t.textSecondary)),
        ],
        if (_role == 'instructor') ...[
          const SizedBox(height: 10),
          const Text('السيارات اللي بيسوقها', style: label),
          const SizedBox(height: 6),
          if (_allCars.isEmpty)
            Text('ما في سيارات لسا · بتنضاف من المزيد ← السيارات والمدربون', style: TextStyle(fontSize: 12, color: t.textSecondary))
          else
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final c in _allCars)
                FilterChip(
                  label: Text(_cars.contains(c.id) ? '${c.name} ✓' : c.name),
                  selected: _cars.contains(c.id),
                  showCheckmark: false,
                  selectedColor: t.tonalBg,
                  backgroundColor: t.card,
                  side: BorderSide(color: _cars.contains(c.id) ? t.primary : t.border, width: _cars.contains(c.id) ? 2 : 1),
                  labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _cars.contains(c.id) ? t.info : t.text),
                  onSelected: (on) => setState(() => on ? _cars.add(c.id) : _cars.remove(c.id)),
                ),
            ]),
        ],
        if (_role != 'admin') ...[
          const SizedBox(height: 10),
          TextField(
            controller: _salary,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
            decoration: const InputDecoration(labelText: 'الراتب الشهري (₪)'),
          ),
        ],
        const SizedBox(height: 14),
        AppButton('حفظ وإرسال بيانات الدخول على واتساب', height: 56, expand: true, busy: _busy, onPressed: _valid ? _save : null),
      ]),
    );
  }
}
