import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/db/database.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/period_picker.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../core/util/period.dart';
import '../../data/queries.dart';
import '../../data/staff_queries.dart';
import '../home/home_screen.dart' show openStudent;
import 'payroll_sheets.dart' show staffSheet;
import 'permissions_screen.dart';

enum _Tab { students, lessons, salaries, log }

/// Canvas InstructorDetails (أداء المدربين): lessons, students, pass rate, salaries of one instructor.
class InstructorScreen extends StatefulWidget {
  const InstructorScreen({super.key, this.employeeId});
  final String? employeeId;

  @override
  State<InstructorScreen> createState() => _InstructorScreenState();
}

class _InstructorScreenState extends State<InstructorScreen> {
  late String? _id = widget.employeeId;
  Period _period = Period.of(PeriodKind.month);
  _Tab _tab = _Tab.students;
  Stream<InstructorView?>? _stream;
  String? _key;
  bool _started = false;

  Stream<InstructorView?> _watch(BuildContext context, String id) {
    final key = '$id|${_period.from}|${_period.to}';
    if (_stream != null && _key == key) return _stream!;
    final app = AppScope.of(context);
    final p = _period;
    _key = key;
    return _stream = watchLoad(app.db, () => app.staff.queries.instructor(id, p));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (_id == null) {
      AppScope.of(context).staff.queries.instructors().then((l) {
        if (mounted && _id == null && l.isNotEmpty) setState(() => _id = l.first.id);
      });
    }
  }

  Future<void> _pick() async {
    final list = await AppScope.of(context).staff.queries.instructors();
    if (!mounted) return;
    final id = await staffSheet<String>(
      context,
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('أي مدرب؟', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          for (final e in list)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 8),
              child: ChoiceRow<String>(options: [e.id], selected: _id, height: 48, label: (_) => e.name, onSelect: (id) => Navigator.of(context).pop(id)),
            ),
        ]),
      ),
    );
    if (id != null) setState(() => _id = id);
  }

  Future<void> _openPermissions(String employeeId) async {
    final app = AppScope.of(context);
    final user = (await app.staff.queries.users()).where((u) => u.user.employeeId == employeeId).firstOrNull;
    if (!mounted) return;
    if (user == null) {
      showErrorSnack(context, 'هالمدرب ما إله حساب دخول');
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PermissionsScreen(userId: user.user.id)));
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    final id = _id;
    if (id == null) {
      return const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsetsDirectional.all(16),
            child: Column(children: [
              BackHeader(title: 'أداء المدربين'),
              SizedBox(height: 16),
              EmptyState(icon: Icons.person_outline, title: 'ما في مدربين', body: 'المدربين بينضافوا من المزيد ← المستخدمون'),
            ]),
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<InstructorView?>(
          stream: _watch(context, id),
          builder: (context, snap) {
            final v = snap.data;
            return ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
              children: [
                Row(children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pick,
                      borderRadius: BorderRadius.circular(12),
                      child: BackHeader(
                        title: v == null ? 'المدرب' : 'المدرب ${v.employee.name} ▾',
                        subtitle: v == null ? null : [if (v.carNames.isEmpty) 'بدون سيارة' else v.carNames.join(' · '), ?_masked(v.employee.phone)].join(' · '),
                      ),
                    ),
                  ),
                  if (v != null && app.user.can('users'))
                    AppButton('الصلاحيات', height: 44, kind: AppButtonKind.outline, onPressed: () => _openPermissions(v.employee.id)),
                ]),
                const SizedBox(height: 12),
                PeriodButton(period: _period, onChanged: (p) => setState(() => _period = p)),
                const SizedBox(height: 12),
                if (snap.hasError)
                  ErrorPanel(title: 'ما انفتحت صفحة المدرب', body: '${snap.error}')
                else if (v == null)
                  const SkeletonCards(count: 4)
                else ...[
                  Row(children: [
                    _Stat('دروس', '${v.lessons}', strong: true),
                    const SizedBox(width: 8),
                    _Stat('طلابه', '${v.students.length}'),
                    const SizedBox(width: 8),
                    _Stat('نسبة النجاح', v.passRate == null ? '—' : '${v.passRate}%', hint: v.passRate == null ? 'ما في نتائج عملي' : '${v.examsCounted} اختبار'),
                  ]),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      for (final (k, label) in [(_Tab.students, 'الطلاب'), (_Tab.lessons, 'الدروس'), if (app.user.can('payroll')) (_Tab.salaries, 'الرواتب'), (_Tab.log, 'عملياته')])
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: _tab == k,
                            showCheckmark: false,
                            selectedColor: t.primary,
                            backgroundColor: t.card,
                            side: BorderSide.none,
                            shape: const StadiumBorder(),
                            labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _tab == k ? t.onPrimary : t.text),
                            onSelected: (_) => setState(() => _tab = k),
                          ),
                        ),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  ...switch (_tab) {
                    _Tab.students => _students(context, v),
                    _Tab.lessons => _lessons(context, v),
                    _Tab.salaries => _salaries(context, v),
                    _Tab.log => [const EmptyState(icon: Icons.history_rounded, title: 'سجل العمليات جاي', body: 'عمليات المدرب بتطلع هون مع سجل العمليات (الدفعة 5)')],
                  },
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String? _masked(String? phone) {
    if (phone == null || phone.length < 6) return phone;
    return '${phone.substring(0, 3)}•••••${phone.substring(phone.length - 2)}';
  }

  List<Widget> _students(BuildContext context, InstructorView v) {
    final t = context.tokens;
    if (v.students.isEmpty) return [const EmptyState(icon: Icons.groups_outlined, title: 'ما في طلاب على سياراته')];
    return [
      for (final s in v.students)
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 10),
          child: Panel(
            radius: 14,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 12),
            onTap: () => openStudent(context, s.enrollment.id),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.enrollment.studentName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(s.meta, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${s.lessonsWith}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text('دروس معه', style: TextStyle(fontSize: 12, color: t.textSecondary)),
              ]),
            ]),
          ),
        ),
    ];
  }

  List<Widget> _lessons(BuildContext context, InstructorView v) {
    final t = context.tokens;
    if (v.lessonRows.isEmpty) return [const EmptyState(icon: Icons.event_note_outlined, title: 'ما في دروس بهالفترة')];
    return [
      Panel(
        radius: 14,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 4),
        child: Column(children: [
          for (final (i, (l, name)) in v.lessonRows.indexed)
            Container(
              decoration: BoxDecoration(border: i == 0 ? null : Border(top: BorderSide(color: t.divider))),
              padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
              child: Row(children: [
                Expanded(child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                Text('${l.type == 'theory' ? 'نظري' : 'عملي'} ${l.number}${l.withoutDriving ? ' · بدون سواقة' : ''}', style: TextStyle(fontSize: 12, color: t.textSecondary)),
                const SizedBox(width: 10),
                Text(friendlyDate(l.businessDate, atIso: l.startedAt), style: TextStyle(fontSize: 12, color: t.textSecondary)),
              ]),
            ),
        ]),
      ),
    ];
  }

  List<Widget> _salaries(BuildContext context, InstructorView v) {
    final t = context.tokens;
    if (v.payments.isEmpty) return [const EmptyState(icon: Icons.payments_outlined, title: 'ما انصرفله راتب لسا')];
    return [
      Panel(
        radius: 14,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 4),
        child: Column(children: [
          for (final (i, SalaryPaymentRow p) in v.payments.indexed)
            Container(
              decoration: BoxDecoration(border: i == 0 ? null : Border(top: BorderSide(color: t.divider))),
              padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
              child: Row(children: [
                Expanded(child: Text('راتب ${monthLabel(p.payrollMonth)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                Text('${dateShort(p.businessDate)}${p.early ? ' · قبل الموعد' : ''}', style: TextStyle(fontSize: 12, color: t.textSecondary)),
                const SizedBox(width: 10),
                MoneyText(Money(p.net), color: t.money, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ]),
            ),
        ]),
      ),
    ];
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, {this.strong = false, this.hint});
  final String label;
  final String value;
  final bool strong;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Expanded(
      child: Panel(
        radius: 14,
        color: strong ? t.primary : null,
        padding: const EdgeInsetsDirectional.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 12, color: strong ? t.onPrimary.withValues(alpha: 0.8) : t.textSecondary)),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: strong ? t.onPrimary : null)),
          if (hint != null) Text(hint!, style: TextStyle(fontSize: 11, color: t.textSecondary)),
        ]),
      ),
    );
  }
}
