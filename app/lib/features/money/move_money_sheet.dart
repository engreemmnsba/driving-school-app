import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_scope.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/money_queries.dart';

/// Canvas: MoveMoney — شحن (in from outside) · سحب (out, not an expense) · تحويل (between two accounts).
Future<void> showMoveMoney(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.tokens.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheet) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheet).bottom), child: const _MoveMoneySheet()),
    );

class _MoveMoneySheet extends StatefulWidget {
  const _MoveMoneySheet();

  @override
  State<_MoveMoneySheet> createState() => _MoveMoneySheetState();
}

class _MoveMoneySheetState extends State<_MoveMoneySheet> {
  String _kind = 'transfer';
  List<AccountView> _accounts = const [];
  String? _from;
  String? _to;
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _loaded = false;
  bool _busy = false;

  static const _labels = {'top_up': 'شحن', 'withdraw': 'سحب', 'transfer': 'تحويل'};
  static const _hints = {
    'top_up': 'فلوس دخلت الصندوق من برّا (مش من طالب)',
    'withdraw': 'فلوس طلعت من الصندوق (مش مصروف ولا راتب)',
    'transfer': 'نقل فلوس بين صندوقين · المجموع ما بيتغيّر',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    final app = AppScope.of(context);
    final acc = (await app.money.accounts()).where((a) => app.user.canUseAccount(a.id)).toList();
    if (!mounted) return;
    setState(() {
      _accounts = acc;
      _from = acc.isEmpty ? null : acc.first.id;
      _to = acc.length < 2 ? null : acc.last.id;
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Money get _value => Money.shekels(int.tryParse(_amount.text) ?? 0);
  AccountView? _acc(String? id) => _accounts.where((a) => a.id == id).firstOrNull;

  String get _saveLabel {
    final a = _acc(_from);
    final b = _acc(_to);
    final v = _value;
    if (a == null) return 'حفظ';
    return switch (_kind) {
      'top_up' => 'شحن ${v.format()} · يصير ${a.name} ${(a.balance + v).format()}',
      'withdraw' => 'سحب ${v.format()} · يبقى ب${a.name} ${(a.balance - v).format()}',
      _ => b == null ? 'تحويل' : 'تحويل ${v.format()} · ${a.name} ${(a.balance - v).format()} ← ${b.name} ${(b.balance + v).format()}',
    };
  }

  Future<void> _save() async {
    final app = AppScope.of(context);
    setState(() => _busy = true);
    try {
      await app.moveMoney(
        kind: _kind,
        fromAccountId: _kind == 'top_up' ? null : _from,
        toAccountId: _kind == 'top_up' ? _from : (_kind == 'transfer' ? _to : null),
        amount: _value,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        businessDate: todayStr(),
      );
      app.syncSoon();
      if (!mounted) return;
      final nav = Navigator.of(context);
      final msg = _saveLabel;
      nav.pop();
      if (nav.context.mounted) showUndoSnack(nav.context, 'انسجّل: $msg');
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showErrorSnack(context, '$e');
      }
    }
  }

  Widget _accountRow(String? selected, ValueChanged<String> onPick, {String? disabled}) {
    final t = context.tokens;
    return Row(children: [
      for (final (i, a) in _accounts.indexed) ...[
        if (i > 0) const SizedBox(width: 6),
        Expanded(
          child: Opacity(
            opacity: a.id == disabled ? 0.4 : 1,
            child: Panel(
              radius: 12,
              padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
              border: Border.all(color: selected == a.id ? t.primary : t.border, width: selected == a.id ? 2 : 1),
              color: selected == a.id ? t.tonalBg : t.card,
              onTap: a.id == disabled ? null : () => onPick(a.id),
              child: Column(children: [
                Text(a.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected == a.id ? t.info : t.text)),
                MoneyText(a.balance, color: t.textSecondary, style: const TextStyle(fontSize: 12)),
              ]),
            ),
          ),
        ),
      ],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final a = _acc(_from);
    final over = _kind != 'top_up' && a != null && _value > a.balance;
    final valid = _value.isPositive && _from != null && (_kind != 'transfer' || (_to != null && _to != _from));
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsetsDirectional.all(4),
            decoration: BoxDecoration(color: t.bg, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              for (final k in _labels.keys)
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(9),
                    onTap: () => setState(() => _kind = k),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: _kind == k ? t.primary : Colors.transparent, borderRadius: BorderRadius.circular(9)),
                      child: Text(_labels[k]!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kind == k ? t.onPrimary : t.text)),
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 8),
          Text(_hints[_kind]!, style: TextStyle(fontSize: 13, color: t.textSecondary)),
          const SizedBox(height: 10),
          Text(_kind == 'transfer' ? 'من' : 'الصندوق', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _accountRow(_from, (id) => setState(() {
                _from = id;
                if (_to == id) _to = _accounts.where((x) => x.id != id).map((x) => x.id).firstOrNull;
              })),
          if (_kind == 'transfer') ...[
            const SizedBox(height: 10),
            const Text('إلى', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _accountRow(_to, (id) => setState(() => _to = id), disabled: _from),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
            textDirection: TextDirection.ltr,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: '0',
              prefixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(start: 14, end: 6),
                child: Text('₪', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: t.textSecondary)),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: t.primary, width: 2)),
            ),
          ),
          const SizedBox(height: 8),
          TextField(controller: _note, decoration: const InputDecoration(hintText: 'ملاحظة (اختياري): إيداع الكاش بالبنك…')),
          if (over) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: t.problem.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Text('المبلغ أكبر من رصيد الصندوق', style: TextStyle(color: t.problem, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
          const SizedBox(height: 12),
          AppButton(_saveLabel, height: 56, expand: true, busy: _busy, onPressed: valid ? _save : null),
        ]),
      ),
    );
  }
}
