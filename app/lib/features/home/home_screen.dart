import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/domain/money.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/queries.dart';
import '../exams/exam_actions.dart' show examTypeLabel;
import '../exams/exam_sheets.dart';
import '../exams/exams_screen.dart';
import '../money/add_expense_sheet.dart';
import '../money/add_payment_sheet.dart';
import '../money/close_day_screen.dart';
import '../money/money_screen.dart' show CashBookScreen;
import '../oversight/activity_log_screen.dart';
import '../oversight/notifications_screen.dart';
import '../students/register_student_screen.dart';
import '../students/student_profile_screen.dart';

/// Canvas: Main — cars now · needs you · today's page · fixed quick actions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.schoolName});
  final String schoolName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream<HomeData>? _stream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = AppScope.of(context);
    _stream ??= watchLoad(app.db, () => app.queries.home(money: app.user.can('seeMoney')));
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<HomeData>(
                stream: _stream,
                builder: (context, snap) {
                  final d = snap.data;
                  return ListView(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 16),
                    children: [
                      _Header(schoolName: widget.schoolName),
                      const SizedBox(height: 14),
                      if (d == null) const SkeletonCards(count: 4, height: 64) else ...[
                        _CarsSection(d: d),
                        const SizedBox(height: 14),
                        _NeedsYou(d: d),
                        const SizedBox(height: 14),
                        if (app.user.can('seeMoney') || app.user.can('cashbook')) _TodayPage(d: d),
                      ],
                    ],
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 6),
              decoration: BoxDecoration(color: t.bg, border: Border(top: BorderSide(color: t.border))),
              child: Row(children: [
                if (app.user.can('addStudent'))
                  Expanded(
                    flex: 13,
                    child: AppButton('طالب جديد', kind: AppButtonKind.accent, icon: Icons.add_rounded, height: 44, expand: true, onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const RegisterStudentScreen()));
                    }),
                  ),
                if (app.user.can('addPay')) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 10,
                    child: AppButton('دفعة', kind: AppButtonKind.outline, icon: Icons.payments_outlined, height: 44, expand: true, onPressed: () => showAddPayment(context)),
                  ),
                ],
                if (app.user.can('addExp')) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 10,
                    child: AppButton('مصروف', kind: AppButtonKind.outline, icon: Icons.receipt_long_outlined, height: 44, expand: true, onPressed: () => showAddExpense(context)),
                  ),
                ],
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.schoolName});
  final String schoolName;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: t.primary, borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.directions_car_filled_rounded, color: t.onPrimary),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(schoolName, style: TextStyle(fontSize: 12, color: t.textSecondary)),
          Text(dayHeader(DateTime.now()), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        ]),
      ),
      const SyncPill(),
      const SizedBox(width: 4),
      const NotificationBell(),
    ]);
  }
}

/// Canvas Main header: bell with the unread count → Notifications.
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  Stream<int>? _unread;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    _unread ??= watchLoad(app.db, () async {
      final pending = await app.outbox.watchPendingCount().first;
      final list = await app.ops.queries.notices(
        closeDay: app.user.can('closeDay'),
        exams: app.user.can('exam'),
        payroll: app.user.can('payroll'),
        pendingOps: pending,
      );
      final read = await app.ops.queries.readNotices();
      return list.where((n) => !read.contains(n.id)).length;
    });
    return StreamBuilder<int>(
      stream: _unread,
      builder: (context, snap) {
        final n = snap.data ?? 0;
        return IconButton(
          tooltip: n == 0 ? 'الإشعارات' : 'الإشعارات · $n جديدة',
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()));
            if (mounted) setState(() => _unread = null);
          },
          icon: Badge(
            isLabelVisible: n > 0,
            label: Text('$n'),
            backgroundColor: t.warning,
            child: Icon(Icons.notifications_none_rounded, color: t.text),
          ),
        );
      },
    );
  }
}

/// "متزامن" / "N مستنية" / "بدون نت" — tap to sync now.
class SyncPill extends StatelessWidget {
  const SyncPill({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    return StreamBuilder<int>(
      stream: app.outbox.watchPendingCount(),
      builder: (context, pendingSnap) {
        final pending = pendingSnap.data ?? 0;
        return ValueListenableBuilder<SyncState>(
          valueListenable: app.engine.state,
          builder: (context, s, _) {
            final (text, icon, bg, fg) = switch (s) {
              SyncState.offline => (pending > 0 ? 'بدون نت · $pending' : 'بدون نت', Icons.cloud_off_outlined, t.divider, t.text),
              SyncState.syncing => ('بيزامن…', Icons.sync, t.divider, t.text),
              _ when pending > 0 => ('$pending مستنية', Icons.cloud_upload_outlined, t.divider, t.text),
              _ => ('متزامن', Icons.check_rounded, t.moneyBg, t.money),
            };
            return Semantics(
              button: true,
              label: '$text · مزامنة الآن',
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: app.engine.syncNow,
                child: Pill(text, bg: bg, fg: fg, icon: icon),
              ),
            );
          },
        );
      },
    );
  }
}

class _CarsSection extends StatelessWidget {
  const _CarsSection({required this.d});
  final HomeData d;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final running = d.cars.where((c) => c.running).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader('السيارات هلأ',
          trailing: Text('$running شغّالة من ${d.cars.length} · ${d.lessonsToday} درس اليوم', style: TextStyle(fontSize: 12, color: t.textSecondary))),
      const SizedBox(height: 6),
      if (d.cars.isEmpty)
        Panel(child: Text('ما في سيارات لسا · بتنضاف من السيارات والمدربين', style: TextStyle(color: t.textSecondary)))
      else
        Panel(
          padding: EdgeInsets.zero,
          radius: 14,
          child: Column(children: [
            for (final (i, c) in d.cars.indexed)
              InkWell(
                onTap: c.enrollmentId == null ? null : () => openStudent(context, c.enrollmentId!),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  decoration: BoxDecoration(border: i == d.cars.length - 1 ? null : Border(bottom: BorderSide(color: t.divider))),
                  child: Stack(children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 12),
                      child: Row(children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: c.running ? t.money : t.muted)),
                        const SizedBox(width: 10),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 52),
                          child: Text(c.car.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(c.line,
                              maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: c.running ? t.text : t.textSecondary)),
                        ),
                        const SizedBox(width: 8),
                        Pill(c.pill, bg: c.running ? t.moneyBg : t.divider, fg: c.running ? t.money : t.textSecondary),
                      ]),
                    ),
                    if (c.running)
                      PositionedDirectional(
                        start: 0,
                        bottom: 0,
                        child: LayoutBuilder(builder: (context, _) {
                          final w = MediaQuery.sizeOf(context).width - 32;
                          return Container(height: 3, width: w * c.progress.clamp(0, 1), color: t.money);
                        }),
                      ),
                  ]),
                ),
              ),
          ]),
        ),
    ]);
  }
}

class _NeedsYou extends StatelessWidget {
  const _NeedsYou({required this.d});
  final HomeData d;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final app = AppScope.of(context);
    final items = <Widget>[];
    for (final r in d.rejected.take(3)) {
      items.add(_TaskRow(
        late: true,
        title: 'تغيير مرفوض من السيرفر',
        meta: r.message,
        action: 'مراجعة',
        onTap: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (sheet) => Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('تغيير ما انقبل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(r.message, style: const TextStyle(fontSize: 15, height: 1.7)),
              const SizedBox(height: 4),
              Text('التغيير محفوظ بالسجل ومش محسوب بالأرقام · رمز للدعم: ${r.reason}', style: TextStyle(fontSize: 12, color: t.textSecondary)),
              const SizedBox(height: 16),
              AppButton('تمّت المراجعة', expand: true, onPressed: () async {
                await app.dismissRejected(r.opId);
                if (sheet.mounted) Navigator.of(sheet).pop();
              }),
            ]),
          ),
        ),
      ));
    }
    for (final x in d.dueExams.take(3)) {
      items.add(_TaskRow(
        late: true,
        title: 'نتيجة اختبار ${x.studentName}',
        meta: '${examTypeLabel[x.type]} · ${dateLabel(x.scheduledDate)}',
        action: 'تسجيل',
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ExamsScreen(initialTab: 1))),
      ));
    }
    if (d.readyNoBooking.isNotEmpty && app.user.can('exam')) {
      final ready = d.readyNoBooking;
      items.add(_TaskRow(
        late: false,
        title: ready.length == 1 ? '${ready.first.name} جاهز للاختبار بدون حجز' : '${ready.length} جاهزين للاختبار بدون حجز',
        meta: ready.take(3).map((s) => s.name).join(' · '),
        action: 'حجز',
        onTap: () => ready.length == 1
            ? showBookExam(context, ready.first)
            : Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ExamsScreen())),
      ));
    }
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: t.moneyBg, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(Icons.check_rounded, color: t.money, size: 18),
          const SizedBox(width: 8),
          Text('ما في إشي معلّق', style: TextStyle(color: t.money, fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SectionHeader('بدها منك'),
      const SizedBox(height: 6),
      Panel(padding: EdgeInsets.zero, radius: 14, child: Column(children: items)),
    ]);
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.late, required this.title, required this.meta, required this.action, required this.onTap});
  final bool late;
  final String title;
  final String meta;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.divider))),
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: late ? t.warning : t.muted)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            Text(meta, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: t.textSecondary)),
          ]),
        ),
        const SizedBox(width: 8),
        AppButton(action, kind: AppButtonKind.tonal, height: 44, onPressed: onTap),
      ]),
    );
  }
}

class _TodayPage extends StatelessWidget {
  const _TodayPage({required this.d});
  final HomeData d;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    Widget cell(String label, Money m, Color color, {bool strong = false, String sign = ''}) => Expanded(
          child: Column(children: [
            Text(label, style: TextStyle(fontSize: 12, color: strong ? t.info : t.textSecondary, fontWeight: strong ? FontWeight.w600 : FontWeight.w400)),
            const SizedBox(height: 2),
            MoneyText(m, sign: sign, color: color, style: TextStyle(fontSize: strong ? 20 : 18, fontWeight: FontWeight.w700)),
          ]),
        );
    final net = d.cashIn - d.cashOut;
    final app = AppScope.of(context);
    // DECISIONS A3: the close button shows after 16:00, or when an older day is still open.
    final showClose = app.user.can('closeDay') && !d.todayClosed && (DateTime.now().hour >= d.closeHour || d.olderOpenDay != null);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader('صفحة اليوم',
          trailing: showClose
              ? AppButton('إغلاق اليوم', kind: AppButtonKind.outline, icon: Icons.lock_outline, height: 44, onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CloseDayScreen(date: d.olderOpenDay ?? todayStr())));
                })
              : null),
      const SizedBox(height: 8),
      Panel(
        radius: 14,
        padding: const EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 4),
        border: Border.all(color: t.primary, width: 2),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CashBookScreen())),
        child: IntrinsicHeight(
          child: Row(children: [
            cell('وارد', d.cashIn, t.money),
            VerticalDivider(color: t.border, width: 1),
            cell('صادر', d.cashOut, t.text),
            VerticalDivider(color: t.border, width: 1),
            cell('صافي', net.abs(), t.info, strong: true, sign: net.isNegative ? '−' : ''),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      Panel(
        radius: 14,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 2),
        child: Column(children: [
          if (d.ops.isEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 14),
              child: Text('ما في حركات اليوم لسا', style: TextStyle(color: t.textSecondary, fontSize: 13)),
            ),
          for (final o in d.ops)
            InkWell(
              onTap: o.enrollmentId == null ? null : () => openStudent(context, o.enrollmentId!),
              child: Container(
                constraints: const BoxConstraints(minHeight: 46),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: t.divider))),
                child: Row(children: [
                  SizedBox(width: 44, child: Text(o.time, style: TextStyle(fontSize: 12, color: t.textSecondary))),
                  Expanded(child: Text(o.what, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  if (o.amount == null)
                    Text('درس', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.info))
                  else
                    MoneyText(o.amount!,
                        sign: o.kind == 'in' ? '+' : (o.kind == 'out' ? '−' : ''),
                        color: o.kind == 'in' ? t.money : (o.kind == 'info' ? t.info : t.text),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          if (d.opsCount > d.ops.length)
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ActivityLogScreen())),
              child: Text('كل عمليات اليوم (${d.opsCount})'),
            ),
        ]),
      ),
    ]);
  }
}

void openStudent(BuildContext context, String enrollmentId) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => StudentProfileScreen(enrollmentId: enrollmentId)));
}
