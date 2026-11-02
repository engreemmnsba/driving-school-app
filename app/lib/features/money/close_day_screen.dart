import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_scope.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/money_queries.dart';
import 'money_actions.dart';
import 'recon_log_screen.dart';

/// Canvas: CloseDay — count every account. Full mode (Admin) shows the system amount;
/// blind mode (e.g. accountant) hides it until the count is submitted, then the result is locked.
class CloseDayScreen extends StatefulWidget {
  const CloseDayScreen({super.key, required this.date});
  final String date;

  @override
  State<CloseDayScreen> createState() => _CloseDayScreenState();
}

class _CloseDayScreenState extends State<CloseDayScreen> {
  late String _date = widget.date;
  List<AccountView>? _accounts;
  DayView? _day;
  List<String> _otherOpen = const [];
  final Map<String, TextEditingController> _counted = {};
  final Map<String, TextEditingController> _reasons = {};
  bool _tried = false;
  bool _busy = false;
  bool _blindRevealed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_accounts == null) _load();
  }

  Future<void> _load() async {
    final app = AppScope.of(context);
    final acc = (await app.money.accounts()).where((a) => app.user.canUseAccount(a.id)).toList();
    final day = await app.money.day(_date);
    final open = (await app.money.openEarlierDays()).where((d) => d != _date).toList();
    if (!mounted) return;
    setState(() {
      _accounts = acc;
      _day = day;
      _otherOpen = open;
      for (final a in acc) {
        _counted.putIfAbsent(a.id, TextEditingController.new);
        _reasons.putIfAbsent(a.id, TextEditingController.new);
      }
    });
  }

  @override
  void dispose() {
    for (final c in [..._counted.values, ..._reasons.values]) {
      c.dispose();
    }
    super.dispose();
  }

  Money? _countOf(String id) {
    final v = _counted[id]?.text ?? '';
    return v.isEmpty ? null : Money.shekels(int.parse(v));
  }

  Future<void> _close() async {
    final app = AppScope.of(context);
    final blind = app.user.blindClose;
    final acc = _accounts!;
    final ready = acc.every((a) {
      final c = _countOf(a.id);
      if (c == null) return false;
      if (blind) return true; // reasons are asked after the reveal
      return (c - a.balance).isZero || _reasons[a.id]!.text.trim().isNotEmpty;
    });
    if (!ready) {
      setState(() => _tried = true);
      return;
    }
    if (blind && !_blindRevealed) {
      // First tap in blind mode: lock the counts and reveal the differences.
      setState(() {
        _blindRevealed = true;
        _tried = false;
      });
      final missing = acc.any((a) => !(_countOf(a.id)! - a.balance).isZero);
      if (missing) return; // reasons needed now
    }
    final needReason = acc.any((a) => !(_countOf(a.id)! - a.balance).isZero && _reasons[a.id]!.text.trim().isEmpty);
    if (needReason) {
      setState(() => _tried = true);
      return;
    }
    setState(() => _busy = true);
    try {
      await app.closeDay(
        businessDate: _date,
        mode: blind ? 'blind' : 'full',
        closedByName: app.user.name,
        counts: [
          for (final a in acc)
            CountInput(
              accountId: a.id,
              expected: a.balance,
              counted: _countOf(a.id)!,
              reason: _reasons[a.id]!.text.trim().isEmpty ? null : _reasons[a.id]!.text.trim(),
            ),
        ],
      );
      app.syncSoon();
      await _load();
    } catch (e) {
      if (mounted) showErrorSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reopen() async {
    final app = AppScope.of(context);
    final reason = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20 + MediaQuery.viewInsetsOf(sheet).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('إعادة فتح اليوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(controller: reason, autofocus: true, decoration: const InputDecoration(hintText: 'السبب (إجباري) · بيبين بالسجل')),
          const SizedBox(height: 12),
          AppButton('إعادة الفتح', expand: true, onPressed: () => Navigator.of(sheet).pop(reason.text.trim().isNotEmpty)),
        ]),
      ),
    );
    if (ok == true) {
      await app.reopenDay(_date, reason.text.trim());
      app.syncSoon();
      setState(() {
        _blindRevealed = false;
        for (final c in [..._counted.values, ..._reasons.values]) {
          c.clear();
        }
      });
      await _load();
    }
    reason.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    final acc = _accounts;
    final day = _day;
    final blind = app.user.blindClose;
    final showSystem = !blind || _blindRevealed;
    final parts = _date.split('-');
    final dateLabel = _date == todayStr() ? 'اليوم ${dayHeader(DateTime.now())}' : (parts.length == 3 ? '${parts[2]}/${parts[1]}/${parts[0]}' : _date);
    return Scaffold(
      body: SafeArea(
        child: acc == null || day == null
            ? const Padding(padding: EdgeInsetsDirectional.all(16), child: SkeletonCards(count: 4))
            : ListView(padding: const EdgeInsetsDirectional.all(16), children: [
                BackHeader(title: 'مطابقة وإغلاق اليوم', subtitle: dateLabel),
                if (_otherOpen.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Panel(
                    radius: 12,
                    color: const Color(0xFFFFF4CC),
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 6),
                    child: Row(children: [
                      Expanded(child: Text('في يوم ثاني مفتوح: ${friendlyDate(_otherOpen.last)}', style: const TextStyle(fontSize: 13, color: Color(0xFF4A3A00), fontWeight: FontWeight.w600))),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _date = _otherOpen.last;
                            _accounts = null;
                            _blindRevealed = false;
                          });
                          _load();
                        },
                        child: const Text('إغلاقه'),
                      ),
                    ]),
                  ),
                ],
                const SizedBox(height: 12),
                Row(children: [
                  for (final (label, m, c) in [('وارد اليوم', day.moneyIn, t.money), ('صادر اليوم', day.moneyOut, t.text), ('صافي اليوم', day.net, t.info)]) ...[
                    Expanded(
                      child: Panel(
                        radius: 12,
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 10),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                          MoneyText(m.abs(), sign: m.isNegative ? '−' : '', color: c, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                ]),
                const SizedBox(height: 12),
                if (day.isClosed) ..._closed(day, t) else ..._open(acc, showSystem, blind, t),
              ]),
      ),
    );
  }

  List<Widget> _open(List<AccountView> acc, bool showSystem, bool blind, AppTokens t) {
    final allCounted = acc.every((a) => _countOf(a.id) != null);
    final diffs = showSystem ? acc.where((a) => _countOf(a.id) != null && !(_countOf(a.id)! - a.balance).isZero).length : 0;
    final label = !allCounted
        ? 'مطلوب: مبلغ كل صندوق${showSystem ? ' وسبب كل فرق' : ''}'
        : (blind && !_blindRevealed ? 'تسليم العدّ' : (diffs > 0 ? 'إغلاق اليوم مع $diffs فرق موثّق' : 'إغلاق اليوم · كله مطابق'));
    return [
      Text(
        blind && !_blindRevealed
            ? 'المبلغ الفعلي بكل صندوق: الكاش بعد العدّ، والبنك والمحفظة من تطبيقاتهم · أرقام النظام بتبين بعد التسليم'
            : 'المبلغ الفعلي بكل صندوق: الكاش بعد العدّ، والبنك والمحفظة من تطبيقاتهم',
        style: TextStyle(fontSize: 13, color: t.textSecondary, height: 1.6),
      ),
      const SizedBox(height: 10),
      for (final a in acc) _accountCount(a, showSystem, blind, t),
      const SizedBox(height: 8),
      AppButton(label, kind: allCounted ? AppButtonKind.accent : AppButtonKind.outline, height: 56, expand: true, busy: _busy, onPressed: _close),
    ];
  }

  Widget _accountCount(AccountView a, bool showSystem, bool blind, AppTokens t) {
    final c = _countOf(a.id);
    final diff = c == null ? null : c - a.balance;
    final hasDiff = showSystem && diff != null && !diff.isZero;
    final locked = blind && _blindRevealed;
    final reasonMissing = _tried && hasDiff && _reasons[a.id]!.text.trim().isEmpty;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: Panel(
        border: Border.all(color: hasDiff ? t.problem : t.card, width: hasDiff ? 2 : 1),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Text(a.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
            if (showSystem) ...[
              Text('النظام: ', style: TextStyle(fontSize: 13, color: t.textSecondary)),
              MoneyText(a.balance, color: t.textSecondary, style: const TextStyle(fontSize: 13)),
            ],
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _counted[a.id],
                enabled: !locked,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
                textDirection: TextDirection.ltr,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: 'المبلغ الفعلي',
                  semanticCounterText: 'الموجود فعليًا في ${a.name}',
                  prefixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 14, end: 6),
                    child: Text('₪', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: t.textSecondary)),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
            ),
            if (!blind && a.account.kind != 'cash') ...[
              const SizedBox(width: 8),
              AppButton('مطابق', kind: AppButtonKind.tonal, height: 52, onPressed: () => setState(() => _counted[a.id]!.text = '${a.balance.agorot ~/ 100}')),
            ],
          ]),
          const SizedBox(height: 6),
          if (c == null)
            Text(_tried ? 'لسا ما انكتب' : 'لسا ما انكتب', style: TextStyle(fontSize: 13, color: _tried ? t.problem : t.textSecondary))
          else if (!showSystem)
            Text('انكتب · الفرق بيبين بعد التسليم', style: TextStyle(fontSize: 13, color: t.textSecondary))
          else if (diff!.isZero)
            Text('مطابق ✓', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.money))
          else
            MoneyRichText('${diff.isNegative ? 'نقص' : 'زيادة'} ${diff.abs().format()}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.problem)),
          if (hasDiff) ...[
            const SizedBox(height: 6),
            TextField(
              controller: _reasons[a.id],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'سبب الفرق (إجباري)',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: reasonMissing ? t.problem : t.border, width: reasonMissing ? 2 : 1),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  List<Widget> _closed(DayView day, AppTokens t) {
    final app = AppScope.of(context);
    final c = day.close!;
    final at = DateTime.tryParse(c.at ?? '');
    return [
      Panel(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 20),
        child: Column(children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: c.diffs > 0 ? const Color(0xFFFFF4CC) : t.moneyBg, shape: BoxShape.circle),
            child: Icon(c.diffs > 0 ? Icons.warning_amber_rounded : Icons.check_rounded, color: c.diffs > 0 ? const Color(0xFF4A3A00) : t.money, size: 28),
          ),
          const SizedBox(height: 10),
          Text('انغلق ${friendlyDate(day.date)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          MoneyRichText(
            'صافي ${day.net.isNegative ? '−' : ''}${day.net.abs().format()} · ${c.diffs > 0 ? '${c.diffs} فرق مع سببه ⚠' : 'كل الصناديق مطابقة ✓'}',
            style: TextStyle(fontSize: 14, color: t.textSecondary),
          ),
          const SizedBox(height: 4),
          Text('بواسطة ${c.closedByName ?? ''}${at == null ? '' : ' · ${hhmm(at)}'} · ما بيتعدّل إلا بإعادة فتحه${c.syncState == 'pending' ? ' · مستني مزامنة' : ''}',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: t.textSecondary)),
          if (c.lateEntries > 0) ...[
            const SizedBox(height: 6),
            Pill('${c.lateEntries} حركة وصلت بعد الإغلاق', bg: const Color(0xFFFFF4CC), fg: const Color(0xFF4A3A00)),
          ],
        ]),
      ),
      const SizedBox(height: 10),
      for (final cnt in day.counts)
        if (cnt.diff != 0)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 6),
            child: Panel(
              radius: 12,
              color: t.problem.withValues(alpha: 0.08),
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
              child: MoneyRichText(
                '${_accounts?.where((a) => a.id == cnt.accountId).map((a) => a.name).firstOrNull ?? cnt.accountId}: ${cnt.diff < 0 ? 'نقص' : 'زيادة'} ${Money(cnt.diff.abs()).format()} · "${cnt.reason ?? ''}"',
                style: TextStyle(fontSize: 13, color: t.problem, fontWeight: FontWeight.w600),
              ),
            ),
          ),
      const SizedBox(height: 6),
      AppButton('عرض سجلات المطابقة', kind: AppButtonKind.outline, expand: true, onPressed: () {
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ReconLogScreen()));
      }),
      if (app.user.can('reopen')) ...[
        const SizedBox(height: 6),
        AppButton('إعادة فتح اليوم', kind: AppButtonKind.danger, expand: true, onPressed: _reopen),
      ],
    ];
  }
}
