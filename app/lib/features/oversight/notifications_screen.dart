import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../data/ops_queries.dart';
import '../../data/queries.dart';
import '../exams/exams_screen.dart';
import '../money/close_day_screen.dart';
import '../staff/payroll_view.dart';
import '../system/update_screen.dart';

/// Canvas Notifications: what needs attention, computed on this phone from the synced data.
/// (Push notifications to the phone come with the system batch.)
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _tab = 'all';
  Stream<(List<AppNotice>, Set<String>)>? _stream;

  static const _tabs = [('all', 'الكل'), ('money', 'المال'), ('exam', 'الاختبارات'), ('sync', 'المزامنة'), ('sys', 'النظام')];

  Future<void> _open(AppNotice n) async {
    final app = AppScope.of(context);
    await app.ops.queries.markRead([n.id]);
    if (!mounted) return;
    final nav = Navigator.of(context);
    switch (n.target) {
      case 'closeDay':
        await nav.push(MaterialPageRoute<void>(builder: (_) => CloseDayScreen(date: n.arg!)));
      case 'exams':
        await nav.push(MaterialPageRoute<void>(builder: (_) => const ExamsScreen(initialTab: 1)));
      case 'readyStudents':
        await nav.push(MaterialPageRoute<void>(builder: (_) => const ExamsScreen()));
      case 'payroll':
        await nav.push(MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: SafeArea(child: Column(children: [Padding(padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 10), child: BackHeader(title: 'الرواتب')), Expanded(child: PayrollView())]))),
        ));
      case 'rejected':
        final ok = await showDialog<bool>(
          context: context,
          builder: (d) => AlertDialog(
            title: const Text('تغيير مرفوض'),
            content: Text('${n.meta}\n\nالتغيير ما انحفظ. بعد المراجعة بينشال من هون، وبيضل بسجل السيرفر.', style: const TextStyle(height: 1.7)),
            actions: [
              TextButton(onPressed: () => Navigator.of(d).pop(false), child: const Text('بعدين')),
              TextButton(onPressed: () => Navigator.of(d).pop(true), child: const Text('راجعته · شيله')),
            ],
          ),
        );
        if (ok == true) await app.dismissRejected(n.arg!);
      case 'pending':
        app.syncSoon();
      case 'update':
        await nav.push(MaterialPageRoute<void>(builder: (_) => const UpdateScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    _stream ??= watchLoad(app.db, () async {
      final pending = await app.outbox.watchPendingCount().first;
      final list = await app.ops.queries.notices(
        closeDay: app.user.can('closeDay'),
        exams: app.user.can('exam'),
        payroll: app.user.can('payroll'),
        pendingOps: pending,
      );
      return (list, await app.ops.queries.readNotices());
    });
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<(List<AppNotice>, Set<String>)>(
          stream: _stream,
          builder: (context, snap) {
            final d = snap.data;
            final unread = d == null ? 0 : d.$1.where((n) => !d.$2.contains(n.id)).length;
            final shown = d?.$1.where((n) => _tab == 'all' || n.kind == _tab).toList();
            return ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
              children: [
                BackHeader(
                  title: 'الإشعارات',
                  trailing: unread == 0 ? null : AppButton('الكل مقروء', height: 40, kind: AppButtonKind.outline, onPressed: () => app.ops.queries.markRead(d!.$1.map((n) => n.id)).then((_) => setState(() => _stream = null))),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (final (k, label) in _tabs)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 6),
                        child: ChoiceChip(
                          label: Text(k == 'all' ? '$label ($unread)' : label),
                          selected: _tab == k,
                          showCheckmark: false,
                          selectedColor: t.tonalBg,
                          backgroundColor: t.card,
                          side: BorderSide(color: _tab == k ? t.primary : t.border, width: _tab == k ? 2 : 1),
                          shape: const StadiumBorder(),
                          labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _tab == k ? t.info : t.text),
                          onSelected: (_) => setState(() => _tab = k),
                        ),
                      ),
                  ]),
                ),
                const SizedBox(height: 10),
                if (snap.hasError)
                  ErrorPanel(title: 'ما انفتحت الإشعارات', body: '${snap.error}')
                else if (shown == null)
                  const SkeletonCards(count: 4, height: 60)
                else if (shown.isEmpty)
                  const EmptyState(icon: Icons.notifications_none_rounded, title: 'ما في إشي بيستنى', body: 'كل إشي ماشي تمام')
                else
                  for (final n in shown)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 8),
                      child: _NoticeTile(n: n, read: d!.$2.contains(n.id), onTap: () => _open(n).then((_) {
                            if (mounted) setState(() => _stream = null);
                          })),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({required this.n, required this.read, required this.onTap});
  final AppNotice n;
  final bool read;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Panel(
      radius: 12,
      color: read ? t.card : const Color(0xFFFFFBEB),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
      onTap: onTap,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsetsDirectional.only(top: 6),
          decoration: BoxDecoration(shape: BoxShape.circle, color: read ? Colors.transparent : (n.warn ? t.warning : t.primary)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            MoneyRichText(n.title, style: TextStyle(fontSize: 14, fontWeight: read ? FontWeight.w500 : FontWeight.w700, color: read ? t.text : const Color(0xFF14211F))),
            Text(n.meta, style: TextStyle(fontSize: 12, color: t.textSecondary)),
          ]),
        ),
        const SizedBox(width: 8),
        Text(n.time, style: TextStyle(fontSize: 12, color: t.textSecondary)),
      ]),
    );
  }
}
