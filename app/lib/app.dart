import 'package:drift/drift.dart' hide Column, Table;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/auth/auth_service.dart';
import 'core/auth/saved_accounts.dart';
import 'core/config/flavor.dart';
import 'core/db/database.dart';
import 'core/sync/firebase_transport.dart';
import 'core/sync/firestore_change_source.dart';
import 'core/sync/op.dart';
import 'core/sync/outbox.dart';
import 'core/sync/puller.dart';
import 'core/sync/pusher.dart';
import 'core/sync/session_factory.dart';
import 'core/sync/sync_engine.dart';
import 'core/ui/theme.dart';
import 'features/auth/login_screen.dart';
import 'core/app_scope.dart';
import 'features/shell/app_shell.dart';

/// Root widget. Arabic RTL by default, light/dark from the phone. l10n (AR/EN) and routing come next.
class DrivingSchoolApp extends StatelessWidget {
  const DrivingSchoolApp({super.key, required this.config, required this.home});

  final AppConfig config;
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مدرسة القيادة',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system, // setting per device: System (default) · Light · Dark
      home: home,
    );
  }
}

/// Shows the login screen or the signed-in user's workspace.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.auth});
  final AuthService auth;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: widget.auth.authChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = snap.data;
        if (user == null) {
          return LoginScreen(onLogin: widget.auth.signIn, initialError: _error);
        }
        return _SignedIn(
          key: ValueKey(user.uid),
          firebaseUser: user,
          auth: widget.auth,
          onFailed: (msg) => setState(() => _error = msg),
        );
      },
    );
  }
}

class _SignedIn extends StatefulWidget {
  const _SignedIn({super.key, required this.firebaseUser, required this.auth, required this.onFailed});
  final User firebaseUser;
  final AuthService auth;
  final void Function(String message) onFailed;

  @override
  State<_SignedIn> createState() => _SignedInState();
}

class _SignedInState extends State<_SignedIn> {
  AppUser? _user;
  AppDatabase? _db;
  SessionInfo? _session;
  Outbox? _outbox;
  SyncEngine? _engine;

  @override
  void initState() {
    super.initState();
    _open();
  }

  /// First open of this account on this device without internet (nothing saved yet).
  bool _offline = false;

  Future<void> _open() async {
    if (_offline) setState(() => _offline = false);
    try {
      final user = await widget.auth.loadUser(widget.firebaseUser, onRevoked: (msg) {
        widget.onFailed(msg);
        // Forced sign-out (login stopped or changed): never lose changes that are still waiting to send.
        _signOut(keepUnsent: true);
      }, onChanged: () {
        // New cars or permissions arrived: reopen now with them (scoped data re-pulls, see below).
        if (mounted) _restart();
      });
      final nationalId = SavedAccounts.idFromEmail(widget.firebaseUser.email);
      if (nationalId != null) await SavedAccounts().remember(SavedAccount(nationalId: nationalId, name: user.name));
      final (db, session) = await openSession(user);
      // Scoped pulls (an instructor's cars, a student's own records) remember how far they got per
      // collection. When the scope changes, start those collections again so older records of a newly
      // added car reach the phone too.
      final scopeKey = '${user.kind}|${[...user.carIds]..sort()}|${user.studentId ?? ''}';
      if (await db.kvGet('pullScope') != scopeKey) {
        await (db.delete(db.syncCursors)..where((t) => t.collection.isIn(const ['enrollment', 'lesson', 'exam', 'student_ledger', 'student_summary', 'student']))).go();
        await db.kvSet('pullScope', scopeKey);
      }
      final outbox = Outbox(db, session);
      final engine = SyncEngine(
        online: Connectivity().onConnectivityChanged.map((r) => r.any((c) => c != ConnectivityResult.none)),
        Pusher(db, outbox, FirebaseOpsTransport()),
        Puller(
          db,
          FirestoreChangeSource(
            session.schoolId,
            scope: switch (user.kind) {
              'instructor' => {
                  'enrollment': ('carId', user.carIds),
                  'lesson': ('scopeCarId', user.carIds),
                  'exam': ('scopeCarId', user.carIds),
                },
              'student' => {
                  for (final c in ['enrollment', 'lesson', 'exam', 'student_ledger', 'student_summary']) c: ('studentId', [user.studentId ?? '-']),
                },
              _ => const {},
            },
            ownDocs: user.isStudent && user.studentId != null ? {'student': user.studentId!} : const {},
          ),
          collections: pullCollectionsFor(kind: user.kind, can: user.can, logAll: user.logScope == 'all'),
        ),
      )..start();
      if (!mounted) {
        engine.dispose();
        await db.close();
        return;
      }
      setState(() {
        _user = user;
        _db = db;
        _session = session;
        _outbox = outbox;
        _engine = engine;
      });
    } on OfflineFirstOpen {
      // Keep the login; open as soon as there is internet.
      if (mounted) setState(() => _offline = true);
    } on LoginException catch (e) {
      widget.onFailed(e.message);
      await widget.auth.signOut();
    } catch (e) {
      // Anything else (expired/invalid session, server unreachable on first open): never leave the
      // person on an endless spinner — back to Login with a plain message.
      widget.onFailed('ما انفتح الحساب · تسجيل الدخول مرة ثانية');
      try {
        await widget.auth.signOut();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _engine?.dispose();
    _db?.close();
    super.dispose();
  }

  /// Closes the open session and opens it again with the refreshed account.
  Future<void> _restart() async {
    final engine = _engine;
    final db = _db;
    setState(() {
      _engine = null;
      _db = null;
      _user = null;
      _session = null;
      _outbox = null;
      _services = null;
    });
    engine?.dispose();
    await db?.close();
    if (mounted) await _open();
  }

  /// Wipes this user's local data, then signs out (screens check there is nothing waiting to sync).
  /// [keepUnsent]: a forced sign-out keeps this user's database when ops are still waiting, so they
  /// are sent (and, if refused, shown to the Admin) the next time this person signs in on this device.
  Future<void> _signOut({bool keepUnsent = false}) async {
    try {
      final db = _db;
      if (db != null) {
        final waiting = keepUnsent && (await (db.select(db.outboxOps)..limit(1)).get()).isNotEmpty;
        if (!waiting) await db.wipeUserData();
      }
    } catch (_) {
      // Signing out must still work; the data stays in this user's own database file.
    }
    await widget.auth.signOut();
  }

  AppServices? _services;
  final _nav = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    if (_offline) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.wifi_off_rounded, size: 48),
              const SizedBox(height: 12),
              const Text('ما في إنترنت', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('أول فتح للحساب على هاد الجهاز بيحتاج إنترنت · بعدها بيشتغل بدونه', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _open, child: const Text('إعادة المحاولة')),
            ]),
          ),
        ),
      );
    }
    if (_engine == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    _services ??= AppServices(user: _user!, db: _db!, session: _session!, outbox: _outbox!, engine: _engine!, signOut: _signOut);
    // Screens of the signed-in user live in their own navigator under AppScope (sheets and pages see the services).
    return AppScope(
      services: _services!,
      child: NavigatorPopHandler(
        onPopWithResult: (_) => _nav.currentState?.maybePop(),
        child: Navigator(
          key: _nav,
          onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => const AppShell()),
        ),
      ),
    );
  }
}
