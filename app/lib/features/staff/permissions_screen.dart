import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/db/database.dart';
import '../../core/domain/permissions.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../data/staff_queries.dart';
import 'staff_actions.dart';

/// Canvas Permissions: a plain checklist of tasks, ready-made jobs on top, dependencies automatic.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key, required this.userId});
  final String userId;

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  UserView? _user;
  List<TreasuryAccountRow> _accounts = const [];
  String? _job;
  Map<String, bool> _tasks = const {};
  Map<String, bool> _saved = const {};
  PermissionOptions _opt = const PermissionOptions();
  PermissionOptions _savedOpt = const PermissionOptions();
  String? _savedJob;
  final _open = <String>{'الدفعات من الطلاب', 'الصناديق وإغلاق اليوم'};
  String? _note;
  bool _busy = false;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _load();
  }

  Future<void> _load() async {
    final app = AppScope.of(context);
    final u = await app.staff.queries.user(widget.userId);
    final accounts = await app.queries.accounts();
    if (!mounted || u == null) return;
    final tasksJson = (u.permissions['tasks'] as Map?) ?? const {};
    final tasks = {for (final k in taskNeeds.keys) k: tasksJson[k] == true};
    final opt = PermissionOptions.fromJson(u.permissions);
    setState(() {
      _user = u;
      _accounts = accounts;
      _job = u.user.job;
      _savedJob = u.user.job;
      _tasks = tasks;
      _saved = Map.of(tasks);
      _opt = opt;
      _savedOpt = opt;
    });
  }

  void _toggle(String key) {
    final before = _tasks;
    final after = before[key] == true ? withoutDependents(before, key) : withDependencies({...before, key: true});
    final side = sideEffects(before, after, key);
    String? note;
    if (side.isNotEmpty) {
      final names = side.map((k) => '«${taskLabel(k)}»').join(' و');
      note = after[key] == true ? 'انفعل كمان: $names · لأنها لازمة' : 'انطفى كمان: $names';
    }
    setState(() {
      _tasks = after;
      _note = note;
    });
    if (note != null) {
      Future<void>.delayed(const Duration(seconds: 4), () {
        if (mounted && _note == note) setState(() => _note = null);
      });
    }
  }

  void _pickJob(String job) => setState(() {
        _job = job;
        _tasks = jobTasks(job);
        _note = null;
        if (job == 'manager') {
          _opt = _opt.copyWith(allowedAccounts: () => null, expenseCategories: () => null, discountMax: () => null, closeMode: 'full', logScope: 'all');
        }
      });

  bool get _sameAsJob {
    final j = _job;
    if (j == null) return false;
    final base = jobTasks(j);
    return taskNeeds.keys.every((k) => (base[k] ?? false) == (_tasks[k] ?? false));
  }

  bool get _changed =>
      _job != _savedJob ||
      taskNeeds.keys.any((k) => (_saved[k] ?? false) != (_tasks[k] ?? false)) ||
      _optKey(_opt) != _optKey(_savedOpt);

  String _optKey(PermissionOptions o) => '${o.allowedAccounts}|${o.expenseCategories}|${o.discountMax}|${o.closeMode}|${o.logScope}|${o.backdateDays}';

  Future<void> _save() async {
    final app = AppScope.of(context);
    setState(() => _busy = true);
    try {
      await app.staff.savePermissions(user: _user!.user, job: _sameAsJob ? _job : null, tasks: _tasks, options: _opt);
      app.syncSoon();
      if (!mounted) return;
      final nav = Navigator.of(context);
      nav.pop();
      if (nav.context.mounted) showUndoSnack(nav.context, 'انحفظت صلاحيات ${_user!.user.name} · بتشتغل عنده أول ما يتصل بالإنترنت');
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showErrorSnack(context, '$e');
      }
    }
  }

  // ---------- options under a checked task ----------

  List<(String, List<(String, bool, VoidCallback)>)> _options(String key) {
    final o = _opt;
    switch (key) {
      case 'addPay':
        return [('الصناديق المسموحة:', _accountChoices())];
      case 'addExp':
        return [
          if (_tasks['addPay'] != true) ('الصناديق المسموحة:', _accountChoices()),
          ('الأنواع:', [
            ('سيارات · وزارة · أخرى', o.expenseCategories != null, () => setState(() => _opt = o.copyWith(expenseCategories: () => ['cars', 'ministry', 'other']))),
            ('كل الأنواع', o.expenseCategories == null, () => setState(() => _opt = o.copyWith(expenseCategories: () => null))),
          ]),
        ];
      case 'discount':
        return [
          ('لحد:', [
            for (final (label, v) in <(String, int?)>[('₪50', 5000), ('₪100', 10000), ('بدون حد', null)])
              (label, o.discountMax == v, () => setState(() => _opt = o.copyWith(discountMax: () => v))),
          ]),
        ];
      case 'closeDay':
        return [
          ('وقت العدّ:', [
            ('بدون ما يشوف المفروض', o.closeMode == 'blind', () => setState(() => _opt = o.copyWith(closeMode: 'blind'))),
            ('بيشوف المفروض والفرق', o.closeMode == 'full', () => setState(() => _opt = o.copyWith(closeMode: 'full'))),
          ]),
        ];
      case 'log':
        return [
          ('بيشوف:', [
            ('عملياته بس', o.logScope == 'own', () => setState(() => _opt = o.copyWith(logScope: 'own'))),
            ('عمليات الكل', o.logScope == 'all', () => setState(() => _opt = o.copyWith(logScope: 'all'))),
          ]),
        ];
      case 'backdate':
        return [
          ('لورا لحد:', [
            for (final d in [1, 2, 7]) (d == 1 ? 'مبارح' : '$d أيام', o.backdateDays == d, () => setState(() => _opt = o.copyWith(backdateDays: d))),
          ]),
        ];
    }
    return const [];
  }

  List<(String, bool, VoidCallback)> _accountChoices() {
    final o = _opt;
    final cash = [for (final a in _accounts) if (a.kind == 'cash') a.id];
    final cashWallet = [for (final a in _accounts) if (a.kind == 'cash' || a.kind == 'wallet') a.id];
    final wallet = _accounts.where((a) => a.kind == 'wallet').map((a) => a.name).firstOrNull;
    bool same(List<String> x) => o.allowedAccounts != null && o.allowedAccounts!.toSet().containsAll(x) && x.toSet().containsAll(o.allowedAccounts!);
    return [
      if (cash.isNotEmpty) ('الكاش', same(cash), () => setState(() => _opt = o.copyWith(allowedAccounts: () => cash))),
      if (wallet != null && cashWallet.length > cash.length) ('الكاش و$wallet', same(cashWallet), () => setState(() => _opt = o.copyWith(allowedAccounts: () => cashWallet))),
      ('كل الصناديق', o.allowedAccounts == null, () => setState(() => _opt = o.copyWith(allowedAccounts: () => null))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final u = _user;
    if (u == null) {
      return const Scaffold(body: SafeArea(child: Padding(padding: EdgeInsetsDirectional.all(16), child: Column(children: [BackHeader(title: 'الصلاحيات'), SizedBox(height: 16), SkeletonCards(count: 4)]))));
    }
    final total = _tasks.values.where((v) => v).length;
    final jobName = jobTemplates[_job]?.$1 ?? 'صلاحيات خاصة';
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
              children: [
                BackHeader(title: 'شو صلاحيات ${u.user.name}؟', subtitle: '$jobName${_job != null && !_sameAsJob ? ' (معدّلة)' : ''} · $total صلاحية'),
                const SizedBox(height: 12),
                Text('شغلة جاهزة كبداية:', style: TextStyle(fontSize: 13, color: t.textSecondary)),
                const SizedBox(height: 6),
                ChoiceRow<String>(
                  options: const ['accountant', 'secretary', 'instructor', 'manager'],
                  selected: _job != null && _sameAsJob ? _job : null,
                  label: (k) => jobTemplates[k]!.$1,
                  onSelect: _pickJob,
                ),
                const SizedBox(height: 12),
                for (final (title, items) in taskGroups) _group(context, title, items),
              ],
            ),
          ),
          if (_note != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFF14211F), borderRadius: BorderRadius.circular(12)),
              child: Text(_note!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          Container(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 12),
            decoration: BoxDecoration(color: t.card, border: Border(top: BorderSide(color: t.border))),
            child: AppButton(_changed ? 'حفظ التعديلات' : 'ما في تعديلات', height: 52, expand: true, busy: _busy, onPressed: _changed ? _save : null),
          ),
        ]),
      ),
    );
  }

  Widget _group(BuildContext context, String title, List<TaskDef> items) {
    final t = context.tokens;
    final on = items.where((d) => _tasks[d.key] == true).length;
    final open = _open.contains(title);
    final count = on == 0 ? 'ولا إشي' : on == items.length ? 'الكل' : '$on من ${items.length}';
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: Panel(
        radius: 14,
        padding: EdgeInsetsDirectional.zero,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => open ? _open.remove(title) : _open.add(title)),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 14),
              child: Row(children: [
                Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
                Pill(count, bg: on > 0 ? t.tonalBg : t.divider, fg: on > 0 ? t.info : t.textSecondary),
                const SizedBox(width: 6),
                Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: t.textSecondary),
              ]),
            ),
          ),
          if (open)
            for (final d in items) _task(context, d),
        ]),
      ),
    );
  }

  Widget _task(BuildContext context, TaskDef d) {
    final t = context.tokens;
    final on = _tasks[d.key] == true;
    final opts = on ? _options(d.key) : const <(String, List<(String, bool, VoidCallback)>)>[];
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: t.divider))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Semantics(
          checked: on,
          child: InkWell(
            onTap: () => _toggle(d.key),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsetsDirectional.only(top: 2),
                  decoration: BoxDecoration(
                    color: on ? t.primary : t.card,
                    borderRadius: BorderRadius.circular(6),
                    border: on ? null : Border.all(color: t.muted, width: 2),
                  ),
                  child: on ? Icon(Icons.check_rounded, size: 18, color: t.onPrimary) : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('وين: ${d.where}', style: TextStyle(fontSize: 12, color: t.textSecondary)),
                  ]),
                ),
              ]),
            ),
          ),
        ),
        for (final (label, choices) in opts)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(48, 0, 14, 10),
            child: Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
              for (final (text, selected, pick) in choices)
                ChoiceChip(
                  label: Text(text),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: t.tonalBg,
                  backgroundColor: t.card,
                  side: BorderSide(color: selected ? t.primary : t.border, width: selected ? 2 : 1),
                  labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? t.info : t.text),
                  onSelected: (_) => pick(),
                ),
            ]),
          ),
      ]),
    );
  }
}
