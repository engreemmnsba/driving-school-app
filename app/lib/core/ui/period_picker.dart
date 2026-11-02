import 'package:flutter/material.dart';

import '../util/dates.dart';
import '../util/period.dart';
import 'tokens.dart';
import 'widgets.dart';

/// The "📅 هذا الشهر · تغيير" button + its sheet (canvas: CashBook, Treasury, Expenses, ReconLog).
class PeriodButton extends StatelessWidget {
  const PeriodButton({super.key, required this.period, required this.onChanged});
  final Period period;
  final ValueChanged<Period> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Panel(
      radius: 12,
      border: Border.all(color: t.border),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 10),
      onTap: () async {
        final p = await showPeriodSheet(context, period);
        if (p != null) onChanged(p);
      },
      child: Row(children: [
        Icon(Icons.calendar_month_outlined, size: 18, color: t.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(period.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
        Text('تغيير', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.primary)),
      ]),
    );
  }
}

Future<Period?> showPeriodSheet(BuildContext context, Period current) {
  return showModalBottomSheet<Period>(
    context: context,
    showDragHandle: true,
    backgroundColor: context.tokens.card,
    builder: (sheet) => _PeriodSheet(current: current),
  );
}

class _PeriodSheet extends StatefulWidget {
  const _PeriodSheet({required this.current});
  final Period current;

  @override
  State<_PeriodSheet> createState() => _PeriodSheetState();
}

class _PeriodSheetState extends State<_PeriodSheet> {
  late PeriodKind _kind = widget.current.kind;
  late String _from = widget.current.from;
  late String _to = widget.current.to;

  Future<void> _pick(bool from) async {
    final initial = DateTime.tryParse(from ? _from : _to) ?? DateTime.now();
    final d = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2024), lastDate: DateTime.now());
    if (d == null) return;
    setState(() {
      if (from) {
        _from = businessDateOf(d);
      } else {
        _to = businessDateOf(d);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final kinds = PeriodKind.values;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('الفترة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final k in kinds)
              SizedBox(
                width: (MediaQuery.sizeOf(context).width - 40) / 2,
                child: ChoiceRow<PeriodKind>(
                  options: [k],
                  selected: _kind,
                  height: 48,
                  label: (k) => Period.labels[k]!,
                  onSelect: (k) {
                    if (k == PeriodKind.custom) {
                      setState(() => _kind = k);
                    } else {
                      Navigator.of(context).pop(Period.of(k));
                    }
                  },
                ),
              ),
          ]),
          if (_kind == PeriodKind.custom) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: AppButton('من $_from', kind: AppButtonKind.outline, onPressed: () => _pick(true))),
              const SizedBox(width: 8),
              Expanded(child: AppButton('إلى $_to', kind: AppButtonKind.outline, onPressed: () => _pick(false))),
            ]),
            const SizedBox(height: 10),
            AppButton('عرض هالفترة', height: 52, expand: true, onPressed: _from.compareTo(_to) > 0 ? null : () {
              Navigator.of(context).pop(Period.of(PeriodKind.custom, from: _from, to: _to));
            }),
            if (_from.compareTo(_to) > 0) Text('بداية الفترة بعد نهايتها', style: TextStyle(color: t.problem, fontSize: 12)),
          ],
        ]),
      ),
    );
  }
}
