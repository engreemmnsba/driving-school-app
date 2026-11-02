import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/period_picker.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/period.dart';
import '../../data/queries.dart';
import '../../data/staff_queries.dart';

/// Canvas CarReport: lessons, fuel, liters, maintenance and cost per lesson for each car, compared.
/// Fuel per lesson counts practical lessons with driving only.
class CarReportScreen extends StatefulWidget {
  const CarReportScreen({super.key, this.carId});
  final String? carId;

  @override
  State<CarReportScreen> createState() => _CarReportScreenState();
}

class _CarReportScreenState extends State<CarReportScreen> {
  Period _period = Period.of(PeriodKind.month);
  late String? _car = widget.carId;
  Stream<List<CarReportRow>>? _stream;
  Period? _streamPeriod;

  Stream<List<CarReportRow>> _watch(BuildContext context) {
    if (_stream != null && identical(_streamPeriod, _period)) return _stream!;
    final app = AppScope.of(context);
    final p = _period;
    _streamPeriod = p;
    return _stream = watchLoad(app.db, () => app.staff.queries.carReport(p));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<CarReportRow>>(
          stream: _watch(context),
          builder: (context, snap) {
            final rows = snap.data;
            return ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
              children: [
                const BackHeader(title: 'تقرير السيارات'),
                const SizedBox(height: 12),
                PeriodButton(period: _period, onChanged: (p) => setState(() => _period = p)),
                const SizedBox(height: 10),
                if (snap.hasError)
                  ErrorPanel(title: 'ما انفتح التقرير', body: '${snap.error}')
                else if (rows == null)
                  const SkeletonCards(count: 3, height: 120)
                else if (rows.isEmpty)
                  const EmptyState(icon: Icons.directions_car_outlined, title: 'ما في سيارات')
                else ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      for (final (id, label) in <(String?, String)>[(null, 'كل السيارات'), for (final r in rows) (r.car.id, r.car.name)])
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 6),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: _car == id,
                            showCheckmark: false,
                            selectedColor: t.tonalBg,
                            backgroundColor: t.card,
                            side: BorderSide(color: _car == id ? t.primary : t.border, width: _car == id ? 2 : 1),
                            labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _car == id ? t.info : t.text),
                            onSelected: (_) => setState(() => _car = id),
                          ),
                        ),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  _Compare(rows: rows, selected: _car, periodLabel: _period.label, onPick: (id) => setState(() => _car = _car == id ? null : id)),
                  const SizedBox(height: 10),
                  for (final r in rows.where((r) => _car == null || r.car.id == _car)) _CarCard(r: r),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Compare extends StatelessWidget {
  const _Compare({required this.rows, required this.selected, required this.periodLabel, required this.onPick});
  final List<CarReportRow> rows;
  final String? selected;
  final String periodLabel;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final withLessons = rows.where((r) => r.fuelPerLesson != null).toList();
    final maxPer = withLessons.isEmpty ? 0 : withLessons.map((r) => r.fuelPerLesson!.agorot).reduce((a, b) => a > b ? a : b);
    final minPer = withLessons.isEmpty ? 0 : withLessons.map((r) => r.fuelPerLesson!.agorot).reduce((a, b) => a < b ? a : b);
    String? insight;
    if (withLessons.length >= 2 && minPer > 0 && maxPer > minPer) {
      final worst = withLessons.firstWhere((r) => r.fuelPerLesson!.agorot == maxPer);
      insight = '${worst.car.name} بتصرف أكثر بـ ${((maxPer / minPer - 1) * 100).round()}% للدرس من أوفر سيارة';
    }
    return Panel(
      radius: 14,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('تكلفة البنزين للدرس · $periodLabel', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (final r in rows)
          Opacity(
            opacity: selected == null || selected == r.car.id ? 1 : 0.4,
            child: InkWell(
              onTap: () => onPick(r.car.id),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
                child: Row(children: [
                  SizedBox(width: 64, child: Text(r.car.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: maxPer == 0 || r.fuelPerLesson == null ? 0 : r.fuelPerLesson!.agorot / maxPer * 0.9,
                        minHeight: 12,
                        backgroundColor: t.divider,
                        color: r.fuelPerLesson != null && r.fuelPerLesson!.agorot == maxPer && withLessons.length >= 2 ? t.warning : t.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 64,
                    child: r.fuelPerLesson == null
                        ? Text('ما في دروس', textAlign: TextAlign.end, style: TextStyle(fontSize: 11, color: t.textSecondary))
                        : Align(alignment: AlignmentDirectional.centerEnd, child: MoneyText(r.fuelPerLesson!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
                  ),
                ]),
              ),
            ),
          ),
        if (insight != null) ...[
          const SizedBox(height: 4),
          Text(insight, style: const TextStyle(fontSize: 12, color: Color(0xFF6B4E00))),
        ],
      ]),
    );
  }
}

class _CarCard extends StatelessWidget {
  const _CarCard({required this.r});
  final CarReportRow r;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    Widget cell(String label, Widget v) => Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
            FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: v),
          ]),
        );
    const big = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: Panel(
        radius: 14,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Text(r.car.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
            Flexible(child: Text(r.instructors.isEmpty ? 'بدون مدرب' : r.instructors, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: t.textSecondary))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            cell('دروس', Text('${r.lessons}', style: big)),
            cell('بنزين', MoneyText(r.fuel, style: big)),
            cell('لترات', Text('${r.liters}', style: big)),
            cell('صيانة وغيرها', MoneyText(r.other, style: big)),
          ]),
          Divider(color: t.divider, height: 18),
          Row(children: [
            const Expanded(child: Text('كل التكاليف للدرس', style: TextStyle(fontSize: 13))),
            r.allPerLesson == null
                ? Text('—', style: TextStyle(color: t.textSecondary))
                : MoneyText(r.allPerLesson ?? const Money.zero(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ]),
        ]),
      ),
    );
  }
}
