import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_scope.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../data/money_queries.dart';
import '../../data/queries.dart';
import '../staff/payroll_sheets.dart' show staffSheet;

const _kinds = {'cash': 'كاش', 'wallet': 'محفظة', 'bank': 'بنك'};

/// Treasury accounts (Settings → الصناديق وطرق الدفع): add with an opening balance, rename, stop when empty.
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  Stream<List<AccountView>>? _stream;

  Future<void> _rename(AccountView a) async {
    final c = TextEditingController(text: a.name);
    final name = await showDialog<String>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('اسم الصندوق'),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.of(d).pop(c.text.trim()), child: const Text('حفظ')),
        ],
      ),
    );
    c.dispose();
    if (name == null || name.isEmpty || name == a.name || !mounted) return;
    await _edit(a, name: name, done: 'صار اسمه $name');
  }

  Future<void> _edit(AccountView a, {String? name, bool? active, required String done}) async {
    final app = AppScope.of(context);
    try {
      await app.settings.editAccount(a.account, name: name, active: active, balance: a.balance);
      app.syncSoon();
      if (mounted) showUndoSnack(context, done);
    } catch (e) {
      if (mounted) showErrorSnack(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    final showBalance = app.user.can('seeBal');
    _stream ??= watchLoad(app.db, app.settings.queries.accounts);
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<AccountView>>(
          stream: _stream,
          builder: (context, snap) {
            final list = snap.data;
            return ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
              children: [
                BackHeader(
                  title: 'الصناديق وطرق الدفع',
                  trailing: AppButton('صندوق', icon: Icons.add_rounded, height: 44, kind: AppButtonKind.accent, onPressed: () => staffSheet<void>(context, const _AddAccountSheet())),
                ),
                const SizedBox(height: 12),
                Text('كل دفعة ومصروف بيطلع من صندوق أو بيدخله. الصندوق الموقوف ما بيطلع بالاختيارات، وتاريخه بيضل.', style: TextStyle(fontSize: 13, color: t.textSecondary, height: 1.6)),
                const SizedBox(height: 12),
                if (list == null)
                  const SkeletonCards(count: 3, height: 64)
                else if (list.isEmpty)
                  const EmptyState(icon: Icons.account_balance_wallet_outlined, title: 'ما في صناديق لسا', body: 'أول صندوق عادة "كاش" برصيد اللي بالدرج هلأ')
                else
                  for (final a in list)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 8),
                      child: Opacity(
                        opacity: a.account.active ? 1 : 0.6,
                        child: Panel(
                          radius: 14,
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
                          child: Row(children: [
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(a.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                MoneyRichText(
                                  [_kinds[a.account.kind] ?? a.account.kind, 'رصيد البداية ${Money(a.account.openingBalance).format()}', if (!a.account.active) 'موقوف'].join(' · '),
                                  style: TextStyle(fontSize: 12, color: t.textSecondary),
                                ),
                              ]),
                            ),
                            if (showBalance) MoneyText(a.balance, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            PopupMenuButton<String>(
                              tooltip: 'خيارات',
                              onSelected: (v) => v == 'rename'
                                  ? _rename(a)
                                  : _edit(a, active: !a.account.active, done: a.account.active ? 'انوقف ${a.name}' : 'رجع ${a.name} شغّال'),
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'rename', child: Text('تغيير الاسم')),
                                PopupMenuItem(value: 'active', child: Text(a.account.active ? 'إيقاف الصندوق' : 'تشغيل الصندوق')),
                              ],
                            ),
                          ]),
                        ),
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

class _AddAccountSheet extends StatefulWidget {
  const _AddAccountSheet();

  @override
  State<_AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends State<_AddAccountSheet> {
  final _name = TextEditingController();
  final _opening = TextEditingController();
  String _kind = 'cash';
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _opening.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final app = AppScope.of(context);
    setState(() => _busy = true);
    try {
      await app.settings.addAccount(name: _name.text, kind: _kind, opening: Money.shekels(int.tryParse(_opening.text) ?? 0));
      app.syncSoon();
      if (!mounted) return;
      final nav = Navigator.of(context);
      nav.pop();
      if (nav.context.mounted) showUndoSnack(nav.context, 'انضاف صندوق ${_name.text.trim()}');
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
        const Text('صندوق جديد', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        ChoiceRow<String>(options: const ['cash', 'wallet', 'bank'], selected: _kind, label: (k) => _kinds[k]!, onSelect: (k) => setState(() => _kind = k)),
        const SizedBox(height: 8),
        TextField(controller: _name, autofocus: true, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'الاسم (مثلًا: جوال باي، بنك فلسطين)')),
        const SizedBox(height: 8),
        TextField(
          controller: _opening,
          keyboardType: TextInputType.number,
          textDirection: TextDirection.ltr,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
          decoration: const InputDecoration(labelText: 'رصيد البداية (₪) · اللي فيه هلأ'),
        ),
        const SizedBox(height: 14),
        AppButton('حفظ الصندوق', height: 52, expand: true, busy: _busy, onPressed: _name.text.trim().isEmpty ? null : _save),
      ]),
    );
  }
}
