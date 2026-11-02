import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/period_picker.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../core/util/period.dart';
import '../../data/money_queries.dart';
import '../../data/queries.dart';
import 'close_day_screen.dart';

/// Canvas: ReconLog — every day: matched ✓ / difference ⚠ / still open, with the reason of each difference.
class ReconLogScreen extends StatefulWidget {
  const ReconLogScreen({super.key});

  @override
  State<ReconLogScreen> createState() => _ReconLogScreenState();
}

class _ReconLogScreenState extends State<ReconLogScreen> {
  Period _period = Period.of(PeriodKind.month);
  String _filter = 'all';
  Stream<(List<DayView>, Money, Money, Map<String, String>)>? _stream;

  void _listen() {
    final app = AppScope.of(context);
    final p = _period;
    _stream = watchLoad(app.db, () async {
      final days = await app.money.days(p);
      final week = Period.of(PeriodKind.week);
      final month = Period.of(PeriodKind.month);
      final (wi, wo) = await app.money.totals(week.from, week.to);
      final (mi, mo) = await app.money.totals(month.from, month.to);
      final names = {for (final a in await app.db.select(app.db.treasuryAccounts).get()) a.id: a.name};
      return (days, wi - wo, mi - mo, names);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stream == null) _listen();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<(List<DayView>, Money, Money, Map<String, String>)>(
          stream: _stream,
          builder: (context, snap) {
            final d = snap.data;
            final days = d?.$1 ?? const <DayView>[];
            final diffTotal = days.fold<Money>(const Money.zero(), (s, x) => s + x.diffTotal);
            final shown = days.where((x) => switch (_filter) {
                  'ok' => x.isClosed && x.close!.diffs == 0,
                  'diff' => x.isClosed && x.close!.diffs > 0,
                  'open' => !x.isClosed,
                  _ => true,
                });
            Widget stat(String label, Money m, {Color? color}) => Expanded(
                  child: Panel(
                    radius: 12,
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                      MoneyText(m.abs(), sign: m.isNegative ? '−' : '', color: color, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                );
            return ListView(padding: const EdgeInsetsDirectional.all(16), children: [
              const BackHeader(title: 'سجلات المطابقة'),
              const SizedBox(height: 12),
              PeriodButton(period: _period, onChanged: (p) => setState(() {
                    _period = p;
                    _listen();
                  })),
              const SizedBox(height: 12),
              if (d == null)
                const SkeletonCards()
              else ...[
                Row(children: [
                  stat('صافي الأسبوع', d.$2),
                  const SizedBox(width: 8),
                  stat('صافي الشهر', d.$3),
                  const SizedBox(width: 8),
                  stat('مجموع الفروقات', diffTotal, color: diffTotal.isZero ? null : t.problem),
                ]),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (final (k, label) in [('all', 'الكل'), ('ok', 'مطابق ✓'), ('diff', 'فيه فرق ⚠'), ('open', 'مفتوح')])
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 6),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: _filter == k,
                          showCheckmark: false,
                          selectedColor: t.primary,
                          backgroundColor: t.card,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                          labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _filter == k ? t.onPrimary : t.text),
                          onSelected: (_) => setState(() => _filter = k),
                        ),
                      ),
                  ]),
                ),
                const SizedBox(height: 10),
                if (shown.isEmpty) const EmptyState(icon: Icons.fact_check_outlined, title: 'ما في أيام بهالفلتر'),
                for (final x in shown) _DayTile(day: x, names: d.$4),
              ],
            ]);
          },
        ),
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.day, required this.names});
  final DayView day;
  final Map<String, String> names;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = day.close;
    final (tag, bg, fg) = !day.isClosed
        ? ('مفتوح', t.divider, t.textSecondary)
        : (c!.diffs > 0 ? ('فرق ⚠', const Color(0xFFFFF4CC), const Color(0xFF4A3A00)) : ('مطابق ✓', t.moneyBg, t.money));
    final at = DateTime.tryParse(c?.at ?? '');
    final meta = !day.isClosed
        ? (day.date == todayStr() ? 'اليوم · لسا ما انغلق' : (c?.state == 'reopened' ? 'انفتح من جديد · ${c?.reopenReason ?? ''}' : 'لسا ما انغلق'))
        : '${c!.closedByName ?? ''}${at == null ? '' : ' · ${hhmm(at)}'}${c.lateEntries > 0 ? ' · وصلت ${c.lateEntries} حركة بعد الإغلاق' : ''}';
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Panel(
        radius: 12,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CloseDayScreen(date: day.date))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            ConstrainedBox(constraints: const BoxConstraints(minWidth: 56), child: Pill(tag, bg: bg, fg: fg)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(friendlyDate(day.date), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text(meta, style: TextStyle(fontSize: 12, color: t.textSecondary)),
              ]),
            ),
            MoneyText(day.net.abs(), sign: day.net.isNegative ? '−' : '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ]),
          if (!day.isClosed && day.date != todayStr()) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(8)),
              child: Text('إغلاق اليوم ←', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.onAccent)),
            ),
          ],
          for (final cnt in day.counts.where((x) => x.diff != 0)) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: t.problem.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: MoneyRichText(
                '${names[cnt.accountId] ?? ''}: ${cnt.diff < 0 ? 'نقص' : 'زيادة'} ${Money(cnt.diff.abs()).format()} · "${cnt.reason ?? ''}"',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.problem),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
