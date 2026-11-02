import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/db/database.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/queries.dart';
import '../../data/staff_queries.dart';
import 'car_report_screen.dart';
import 'payroll_sheets.dart' show staffSheet;

/// Canvas Cars: each car with its instructors as toggle chips (on = from today, off = ends today).
class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  Stream<(List<CarView>, List<EmployeeRow>)>? _stream;
  final _busy = <String>{};

  Future<void> _toggle(CarView c, EmployeeRow e) async {
    final app = AppScope.of(context);
    final on = !c.instructorIds.contains(e.id);
    final key = '${c.car.id}|${e.id}';
    if (_busy.contains(key)) return;
    setState(() => _busy.add(key));
    try {
      await app.staff.toggleInstructor(carId: c.car.id, employeeId: e.id, on: on, today: todayStr());
      app.syncSoon();
      if (mounted) {
        showUndoSnack(context, on ? '${e.name} صار على ${c.car.name} من اليوم' : '${e.name} ما عاد على ${c.car.name} · الدروس القديمة محفوظة',
            onUndo: () => app.staff.toggleInstructor(carId: c.car.id, employeeId: e.id, on: !on, today: todayStr()).then((_) => app.syncSoon()));
      }
    } catch (err) {
      if (mounted) showErrorSnack(context, '$err');
    } finally {
      if (mounted) setState(() => _busy.remove(key));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    _stream ??= watchLoad(app.db, () async => (await app.staff.queries.cars(), await app.staff.queries.instructors()));
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<(List<CarView>, List<EmployeeRow>)>(
          stream: _stream,
          builder: (context, snap) {
            final d = snap.data;
            return ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
              children: [
                BackHeader(
                  title: 'السيارات والمدربون',
                  trailing: app.user.can('settings')
                      ? AppButton('سيارة', icon: Icons.add_rounded, height: 44, kind: AppButtonKind.accent, onPressed: () => staffSheet<void>(context, const _AddCarSheet()))
                      : null,
                ),
                const SizedBox(height: 12),
                Text('الطالب بينربط بسيارة وحدة، وأي مدرب على السيارة بيقدر يسجّل دروس طلابها.', style: TextStyle(fontSize: 13, color: t.textSecondary, height: 1.6)),
                const SizedBox(height: 12),
                if (snap.hasError)
                  ErrorPanel(title: 'ما انفتحت السيارات', body: '${snap.error}')
                else if (d == null)
                  const SkeletonCards(count: 3, height: 140)
                else if (d.$1.isEmpty)
                  const EmptyState(icon: Icons.directions_car_outlined, title: 'ما في سيارات لسا', body: 'أول سيارة بتنضاف من زر "سيارة" فوق')
                else
                  for (final c in d.$1)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 10),
                      child: Panel(
                        radius: 14,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          Row(children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(color: t.tonalBg, borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.directions_car_outlined, color: t.info),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(c.car.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                Text([?c.car.plate, c.gearLabel, '${c.students} طالب'].join(' · '), style: TextStyle(fontSize: 12, color: t.textSecondary)),
                              ]),
                            ),
                            if (app.user.can('reports'))
                              AppButton('التقرير', height: 40, kind: AppButtonKind.outline, onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CarReportScreen(carId: c.car.id)))),
                          ]),
                          const SizedBox(height: 10),
                          Text('المدربين على هالسيارة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textSecondary)),
                          const SizedBox(height: 6),
                          if (d.$2.isEmpty)
                            Text('ما في مدربين · بينضافوا من المزيد ← المستخدمون', style: TextStyle(fontSize: 12, color: t.textSecondary))
                          else
                            Wrap(spacing: 6, runSpacing: 6, children: [
                              for (final e in d.$2) _InstructorChip(
                                name: e.name,
                                on: c.instructorIds.contains(e.id),
                                busy: _busy.contains('${c.car.id}|${e.id}'),
                                onTap: app.user.can('settings') ? () => _toggle(c, e) : null,
                              ),
                            ]),
                          if (c.instructorIds.isEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFFFFF4CC), borderRadius: BorderRadius.circular(8)),
                              child: const Text('ما في مدرب على هالسيارة · طلابها ما حدا بيقدر يسجّلهم دروس',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4A3A00))),
                            ),
                          ],
                        ]),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InstructorChip extends StatelessWidget {
  const _InstructorChip({required this.name, required this.on, required this.busy, required this.onTap});
  final String name;
  final bool on;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      toggled: on,
      button: true,
      child: Material(
        color: on ? t.tonalBg : t.card,
        shape: StadiumBorder(side: BorderSide(color: on ? t.primary : t.muted, width: on ? 2 : 1)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: busy ? null : onTap,
          child: Container(
            height: 40,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
            alignment: Alignment.center,
            child: Text(on ? '$name ✓' : '+ $name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: on ? t.info : t.textSecondary)),
          ),
        ),
      ),
    );
  }
}

class _AddCarSheet extends StatefulWidget {
  const _AddCarSheet();

  @override
  State<_AddCarSheet> createState() => _AddCarSheetState();
}

class _AddCarSheetState extends State<_AddCarSheet> {
  final _name = TextEditingController();
  final _plate = TextEditingController();
  String _gear = 'manual';
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _plate.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final app = AppScope.of(context);
    setState(() => _busy = true);
    try {
      await app.staff.addCar(name: _name.text, plate: _plate.text, gearbox: _gear);
      app.syncSoon();
      if (!mounted) return;
      final nav = Navigator.of(context);
      nav.pop();
      if (nav.context.mounted) showUndoSnack(nav.context, 'انضافت ${_name.text.trim()} · المدربين بينحطّوا عليها من الشيبس تحتها');
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showErrorSnack(context, '$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('سيارة جديدة', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        TextField(controller: _name, autofocus: true, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'الاسم (مثلًا: سيارة 4)')),
        const SizedBox(height: 8),
        TextField(controller: _plate, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: 'رقم اللوحة (اختياري)')),
        const SizedBox(height: 10),
        const Text('الجير', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ChoiceRow<String>(options: const ['manual', 'auto'], selected: _gear, label: (g) => g == 'auto' ? 'أوتوماتيك' : 'عادي', onSelect: (g) => setState(() => _gear = g)),
        const SizedBox(height: 14),
        AppButton('حفظ السيارة', height: 56, expand: true, busy: _busy, onPressed: _name.text.trim().isEmpty ? null : _save),
      ]),
    );
  }
}
