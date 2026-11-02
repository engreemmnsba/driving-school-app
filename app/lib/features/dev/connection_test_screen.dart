import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../core/auth/auth_service.dart';
import '../../core/db/database.dart';
import '../../core/domain/money.dart';
import '../../core/firebase/firebase_setup.dart';
import '../../core/sync/op.dart';
import '../../core/sync/outbox.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../money/record_payment.dart';

/// Temporary screen for the first end-to-end test: pull students, record a payment, sync it.
/// Replaced by the real Home in the next phase.
class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({
    super.key,
    required this.user,
    required this.db,
    required this.session,
    required this.outbox,
    required this.engine,
    required this.onSignOut,
  });

  final AppUser user;
  final AppDatabase db;
  final SessionInfo session;
  final Outbox outbox;
  final SyncEngine engine;
  final Future<void> Function() onSignOut;

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _Row {
  const _Row(this.enrollment, this.remaining);
  final EnrollmentRow enrollment;
  final Money remaining;
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  late final RecordPayment _pay = RecordPayment(widget.db, widget.outbox, widget.session);
  StreamSubscription<void>? _sub;
  List<_Row> _rows = const [];
  List<RejectedOpRow> _rejected = const [];
  int _pending = 0;
  StreamSubscription<int>? _pendingSub;

  @override
  void initState() {
    super.initState();
    final db = widget.db;
    _sub = db
        .tableUpdates(TableUpdateQuery.onAllTables([db.enrollments, db.ledgerEntries, db.studentSummaries, db.rejectedOps]))
        .listen((_) => _reload());
    _pendingSub = widget.outbox.watchPendingCount().listen((n) {
      if (mounted) setState(() => _pending = n);
    });
    _reload();
  }

  Future<void> _reload() async {
    final db = widget.db;
    final enrollments = await (db.select(db.enrollments)..where((t) => t.archived.equals(false))).get();
    final rows = <_Row>[];
    for (final e in enrollments) {
      rows.add(_Row(e, (await localBalance(db, e.id)).remaining));
    }
    final rejected = await db.select(db.rejectedOps).get();
    if (mounted) {
      setState(() {
        _rows = rows;
        _rejected = rejected;
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _pendingSub?.cancel();
    super.dispose();
  }

  static String _today() {
    final d = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  Future<void> _payHundred(EnrollmentRow e) async {
    await _pay(
      enrollmentId: e.id,
      studentId: e.studentId,
      amount: Money.shekels(100),
      accountId: 'cash',
      purpose: 'lessons',
      businessDate: _today(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('انسجّلت دفعة ₪100 لـ${e.studentName}')));
    unawaited(widget.engine.syncNow());
  }

  Future<void> _signOut() async {
    if (_pending > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('في عمليات لسا ما وصلت للسيرفر · تسجيل الخروج بعد المزامنة')),
      );
      return;
    }
    await widget.onSignOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name.isEmpty ? 'تجربة الربط' : widget.user.name),
        actions: [
          IconButton(tooltip: 'تسجيل الخروج', icon: const Icon(Icons.logout), onPressed: _signOut),
        ],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(16),
        children: [
          if (useEmulator)
            Card(
              color: theme.colorScheme.tertiaryContainer,
              child: const ListTile(leading: Icon(Icons.science_outlined), title: Text('سيرفر محلي على الجهاز (تجريبي)')),
            ),
          _SyncCard(engine: widget.engine, pending: _pending),
          const SizedBox(height: 16),
          Text('الطلاب', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_rows.isEmpty)
            const Padding(
              padding: EdgeInsetsDirectional.symmetric(vertical: 24),
              child: Text('ما في طلاب لسا · بيوصلوا بعد المزامنة', textAlign: TextAlign.center),
            ),
          for (final r in _rows)
            Card(
              child: ListTile(
                title: Text(r.enrollment.studentName),
                subtitle: r.remaining.isPositive
                    ? Row(children: [
                        Text('المتبقي ', style: TextStyle(color: context.tokens.debt)),
                        MoneyText(r.remaining, color: context.tokens.debt, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ])
                    : Text('مسدّد', style: TextStyle(color: context.tokens.money)),
                trailing: FilledButton.tonal(
                  onPressed: () => _payHundred(r.enrollment),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [const Text('دفعة '), MoneyText(Money.shekels(100))]),
                ),
              ),
            ),
          if (_rejected.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('عمليات مرفوضة', style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFFB3261E))),
            for (final r in _rejected)
              ListTile(leading: const Icon(Icons.error_outline, color: Color(0xFFB3261E)), title: Text(r.message), subtitle: Text(r.reason)),
          ],
        ],
      ),
    );
  }
}

class _SyncCard extends StatelessWidget {
  const _SyncCard({required this.engine, required this.pending});
  final SyncEngine engine;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SyncState>(
      valueListenable: engine.state,
      builder: (context, s, _) {
        final (icon, text, color) = switch (s) {
          SyncState.syncing => (Icons.sync, 'جاري المزامنة…', null),
          SyncState.offline => (Icons.cloud_off_outlined, 'ما في اتصال بالسيرفر · العمليات محفوظة على الجهاز', const Color(0xFFB54708)),
          SyncState.synced when pending == 0 => (Icons.cloud_done_outlined, 'كل إشي متزامن', const Color(0xFF1E6B3E)),
          _ => (Icons.cloud_upload_outlined, 'في عمليات بانتظار المزامنة', null),
        };
        return Card(
          child: ListTile(
            leading: Icon(icon, color: color),
            title: Text(text),
            subtitle: Text(pending == 0 ? 'ما في عمليات معلّقة' : 'بانتظار المزامنة: $pending'),
            trailing: TextButton(onPressed: s == SyncState.syncing ? null : engine.syncNow, child: const Text('مزامنة الآن')),
          ),
        );
      },
    );
  }
}
