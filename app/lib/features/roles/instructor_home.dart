import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/db/database.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/queries.dart';
import '../../data/role_queries.dart';
import '../students/student_actions.dart' show ActionError;

/// Canvas InstructorHome: "طلابي" · "دروسي اليوم" · "حسابي". No money anywhere on these screens.
class InstructorShell extends StatefulWidget {
  const InstructorShell({super.key});

  @override
  State<InstructorShell> createState() => _InstructorShellState();
}

class _InstructorShellState extends State<InstructorShell> {
  int _tab = 0;
  Stream<InstructorHomeData>? _stream;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // The running lesson counts down every second.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    final q = RoleQueries(app.db);
    _stream ??= watchLoad(app.db, () => q.instructorHome(employeeId: app.user.employeeId, carIds: app.user.carIds));
    return StreamBuilder<InstructorHomeData>(
      stream: _stream,
      builder: (context, snap) {
        final d = snap.data;
        final pages = [
          _StudentsTab(data: d, error: snap.error),
          _TodayTab(data: d),
          const _AccountTab(),
        ];
        return Scaffold(
          body: IndexedStack(index: _tab, children: pages),
          bottomNavigationBar: NavigationBar(
            backgroundColor: t.card,
            indicatorColor: t.tonalBg,
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups_rounded), label: 'طلابي'),
              NavigationDestination(icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer_rounded), label: 'دروسي اليوم'),
              NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'حسابي'),
            ],
          ),
        );
      },
    );
  }
}

class _StudentsTab extends StatefulWidget {
  const _StudentsTab({required this.data, required this.error});
  final InstructorHomeData? data;
  final Object? error;

  @override
  State<_StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<_StudentsTab> {
  final _q = TextEditingController();
  final _busy = <String>{};

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _log(InstructorCard c, {bool withoutDriving = false}) async {
    final app = AppScope.of(context);
    setState(() => _busy.add(c.enrollment.id));
    try {
      final r = await app.logLesson(c.enrollment.id, businessDate: todayStr(), employeeId: app.user.employeeId, withMoney: false, withoutDriving: withoutDriving);
      app.syncSoon();
      if (mounted) {
        showUndoSnack(
          context,
          'انسجّل ${r.type == 'theory' ? 'نظري' : 'عملي'} ${r.number} لـ${c.name}${withoutDriving ? ' · بدون تشغيل' : ''}',
          onUndo: () => app.undoLesson(r.lessonId, reason: 'تراجع فوري').then((_) => app.syncSoon()),
        );
      }
    } on ActionError catch (e) {
      if (mounted) showErrorSnack(context, e.message);
    } catch (e) {
      if (mounted) showErrorSnack(context, 'ما انسجّل الدرس: $e');
    } finally {
      if (mounted) setState(() => _busy.remove(c.enrollment.id));
    }
  }

  Future<void> _cancel(InstructorCard c) async {
    final app = AppScope.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('إلغاء الدرس؟'),
        content: Text('${c.kindLabel} ${c.done} لـ${c.name} بيتلغى وبينسجّل بالسجل.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(false), child: const Text('لا')),
          TextButton(onPressed: () => Navigator.of(d).pop(true), child: const Text('إلغاء الدرس')),
        ],
      ),
    );
    if (ok != true) return;
    await app.undoLesson(c.running!.id, reason: 'انسجّل بالغلط');
    app.syncSoon();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    final d = widget.data;
    final q = _q.text.trim();
    final cards = d?.cards.where((c) => q.isEmpty || c.name.contains(q)).toList();
    return Column(children: [
      Container(
        color: t.info,
        padding: EdgeInsetsDirectional.fromSTEB(16, MediaQuery.paddingOf(context).top + 18, 16, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('المدرب ${app.user.name}', style: const TextStyle(fontSize: 13, color: Color(0xFFBFDAD8))),
                const Text('طلابي', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              ValueListenableBuilder<SyncState>(
                valueListenable: app.engine.state,
                builder: (context, s, _) => Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF13575C), borderRadius: BorderRadius.circular(999)),
                  child: Text(s == SyncState.offline ? 'بدون نت · محفوظ على الجوال' : s == SyncState.syncing ? 'بيزامن…' : 'متزامن ✓',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFFF4CC))),
                ),
              ),
              const SizedBox(height: 6),
              Text('دروس اليوم: ${d?.lessonsToday ?? 0}', style: const TextStyle(fontSize: 13, color: Color(0xFFD5ECEB))),
            ]),
          ]),
          const SizedBox(height: 14),
          TextField(
            controller: _q,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'بحث عن طالب',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.search_rounded, color: t.textSecondary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ]),
      ),
      Expanded(
        child: widget.error != null
            ? Padding(padding: const EdgeInsetsDirectional.all(16), child: ErrorPanel(title: 'ما انفتحت القائمة', body: '${widget.error}'))
            : cards == null
                ? const Padding(padding: EdgeInsetsDirectional.all(16), child: SkeletonCards(count: 4, height: 150))
                : app.user.carIds.isEmpty
                    ? const Padding(padding: EdgeInsetsDirectional.all(16), child: EmptyState(icon: Icons.directions_car_outlined, title: 'ما في سيارة مربوطة فيك', body: 'المدير بيربطك بسيارة من "السيارات والمدربون"، وبعدها بيطلعوا طلابها هون'))
                    : cards.isEmpty
                        ? const Padding(padding: EdgeInsetsDirectional.all(16), child: EmptyState(icon: Icons.groups_outlined, title: 'ما في طلاب', body: 'طلاب سياراتك بيطلعوا هون'))
                        : ListView(
                            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 24),
                            children: [
                              for (final c in cards)
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(bottom: 10),
                                  child: _Card(
                                    c: c,
                                    data: d!,
                                    busy: _busy.contains(c.enrollment.id),
                                    onLog: () => _log(c),
                                    onLogWithout: () => _log(c, withoutDriving: true),
                                    onEnd: () => RoleQueries(app.db).endLesson(c.running!.id),
                                    onCancel: () => _cancel(c),
                                  ),
                                ),
                            ],
                          ),
      ),
    ]);
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.c, required this.data, required this.busy, required this.onLog, required this.onLogWithout, required this.onEnd, required this.onCancel});
  final InstructorCard c;
  final InstructorHomeData data;
  final bool busy;
  final VoidCallback onLog;
  final VoidCallback onLogWithout;
  final VoidCallback onEnd;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final running = c.running;
    final blockedBy = data.myRunning != null && running == null ? data.myRunningStudent : null;
    return Panel(
      border: Border.all(color: running != null ? t.accent : t.border, width: running != null ? 2 : 1),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          InitialBox(c.name),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text('${c.meta} · ${c.kindLabel}', style: TextStyle(fontSize: 12, color: t.textSecondary)),
            ]),
          ),
          Text(c.counter, textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        if (running != null) _Running(lesson: running, minutes: data.lessonMinutes, label: '${c.kindLabel} ${c.done} جارٍ', onEnd: onEnd, onCancel: onCancel) else ...[
          Semantics(
            label: '${c.kindLabel}: خلص ${c.done}${c.planned == null ? '' : ' من ${c.planned}'}',
            child: Wrap(spacing: 4, runSpacing: 4, children: [
              for (var i = 1; i <= (c.planned ?? c.done + 1); i++)
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: i <= c.done ? t.primary : (i == c.done + 1 ? t.accent : t.border),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              for (var i = (c.planned ?? 0) + 1; c.planned != null && i <= c.done; i++)
                Container(width: 11, height: 11, decoration: BoxDecoration(color: t.warning, borderRadius: BorderRadius.circular(3))),
            ]),
          ),
          const SizedBox(height: 6),
          Text(
            c.beyondPlan
                ? 'خلص الـ ${c.planned} المخططين · الدرس الجاي زيادة عن الخطة'
                : c.planned == null
                    ? 'التالي: درس ${c.kindLabel} ${c.next}'
                    : 'التالي: درس ${c.kindLabel} ${c.next} · باقي ${c.planned! - c.next} بعده',
            style: TextStyle(fontSize: 13, color: t.textSecondary),
          ),
          const SizedBox(height: 8),
          AppButton(
            blockedBy != null ? 'بعد ما يخلص درس $blockedBy · ${c.kindLabel} ${c.next}' : 'تسجيل ${c.kindLabel} ${c.next}${c.beyondPlan ? ' · زيادة' : ''}',
            icon: Icons.check_rounded,
            height: 52,
            expand: true,
            busy: busy,
            kind: blockedBy != null ? AppButtonKind.outline : AppButtonKind.accent,
            onPressed: blockedBy != null ? null : onLog,
          ),
          if (!c.inTheory && data.withoutDriving && blockedBy == null)
            Center(child: TextButton(onPressed: busy ? null : onLogWithout, child: const Text('تسجيل بدون تشغيل السيارة', style: TextStyle(decoration: TextDecoration.underline)))),
        ],
      ]),
    );
  }
}

class _Running extends StatelessWidget {
  const _Running({required this.lesson, required this.minutes, required this.label, required this.onEnd, required this.onCancel});
  final LessonRow lesson;
  final int minutes;
  final String label;
  final VoidCallback onEnd;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final start = DateTime.tryParse(lesson.startedAt) ?? DateTime.now();
    final total = Duration(minutes: minutes);
    final left = total - DateTime.now().difference(start);
    final safe = left.isNegative ? Duration.zero : left;
    String two(int n) => n.toString().padLeft(2, '0');
    final progress = 1 - safe.inSeconds / total.inSeconds;
    return Container(
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(color: t.info, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Text('${two(safe.inMinutes)}:${two(safe.inSeconds % 60)}', textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('متبقٍ من $minutes:00', style: const TextStyle(fontSize: 12, color: Color(0xFFBFDAD8))),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(value: progress.clamp(0, 1).toDouble(), minHeight: 8, backgroundColor: const Color(0xFF13575C), color: t.accent),
        ),
        const SizedBox(height: 10),
        AppButton('إنهاء الدرس الآن', kind: AppButtonKind.accent, height: 48, expand: true, onPressed: onEnd),
        Center(
          child: TextButton(
            onPressed: onCancel,
            child: const Text('انسجّل بالغلط؟ إلغاء الدرس', style: TextStyle(color: Color(0xFFBFDAD8), decoration: TextDecoration.underline)),
          ),
        ),
      ]),
    );
  }
}

class _TodayTab extends StatelessWidget {
  const _TodayTab({required this.data});
  final InstructorHomeData? data;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final rows = data?.todayRows;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 24),
        children: [
          Text('دروسي اليوم · ${rows?.length ?? 0}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (rows == null)
            const SkeletonCards(count: 3, height: 56)
          else if (rows.isEmpty)
            const EmptyState(icon: Icons.timer_outlined, title: 'ما في دروس اليوم لسا')
          else
            Panel(
              radius: 14,
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 4),
              child: Column(children: [
                for (final (i, (l, name)) in rows.indexed)
                  Container(
                    decoration: BoxDecoration(border: i == 0 ? null : Border(top: BorderSide(color: t.divider))),
                    padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
                    child: Row(children: [
                      Expanded(child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                      Text('${l.type == 'theory' ? 'نظري' : 'عملي'} ${l.number}${l.withoutDriving ? ' · بدون تشغيل' : ''}', style: TextStyle(fontSize: 12, color: t.textSecondary)),
                      const SizedBox(width: 10),
                      Text(hhmm(DateTime.tryParse(l.startedAt) ?? DateTime.now()), style: TextStyle(fontSize: 12, color: t.textSecondary)),
                      if (l.syncState == 'pending') ...[const SizedBox(width: 6), Icon(Icons.cloud_upload_outlined, size: 16, color: t.textSecondary)],
                    ]),
                  ),
              ]),
            ),
        ],
      ),
    );
  }
}

class _AccountTab extends StatelessWidget {
  const _AccountTab();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 24),
        children: [
          const Text('حسابي', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Panel(
            child: Row(children: [
              InitialBox(app.user.name, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(app.user.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  Text('مدرب · ${app.user.carIds.length} سيارات', style: TextStyle(fontSize: 12, color: t.textSecondary)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          StreamBuilder<int>(
            stream: app.outbox.watchPendingCount(),
            builder: (context, snap) => Panel(
              child: Row(children: [
                Icon(Icons.sync_rounded, color: t.primary),
                const SizedBox(width: 10),
                Expanded(child: Text((snap.data ?? 0) == 0 ? 'كل الدروس وصلت للسيرفر ✓' : '${snap.data} عمليات لسا ما وصلت · بتنبعت لحالها')),
                TextButton(onPressed: app.syncSoon, child: const Text('مزامنة')),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            'تسجيل الخروج',
            kind: AppButtonKind.danger,
            height: 48,
            expand: true,
            onPressed: () async {
              final pending = await app.outbox.watchPendingCount().first;
              if (!context.mounted) return;
              if (pending > 0) {
                showErrorSnack(context, 'في $pending عمليات لسا ما وصلت للسيرفر · تسجيل الخروج بعد المزامنة');
                app.syncSoon();
                return;
              }
              await app.signOut();
            },
          ),
        ],
      ),
    );
  }
}
