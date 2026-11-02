import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'login_email.dart';

/// The signed-in person, read from the token claims + own user doc.
class AppUser {
  const AppUser({
    required this.uid,
    required this.schoolId,
    required this.kind,
    required this.name,
    this.tasks = const {},
    this.closeMode = 'blind',
    this.allowedAccounts,
    this.logScope = 'own',
    this.carIds = const [],
    this.studentId,
    this.employeeId,
  });
  final String uid;
  final String schoolId;
  final String kind; // admin | staff | instructor | student
  final String name;

  /// Permission task keys (docs/02). The server checks again; this only hides what can't be used.
  final Map<String, bool> tasks;

  /// Day close: 'full' shows system amounts, 'blind' hides them until the count is submitted. Admin = full.
  final String closeMode;

  /// null = all accounts.
  final List<String>? allowedAccounts;

  /// Activity log: 'own' actions or 'all'.
  final String logScope;

  /// Instructors: the cars they drive now (token claims; their phone only pulls these students).
  final List<String> carIds;

  /// Students: their own student id.
  final String? studentId;

  /// Staff / instructors: their employee file (lessons are logged under it).
  final String? employeeId;

  bool get isInstructor => kind == 'instructor';
  bool get isStudent => kind == 'student';

  bool get isAdmin => kind == 'admin';
  bool get blindClose => !isAdmin && closeMode != 'full';
  bool canUseAccount(String id) => isAdmin || allowedAccounts == null || allowedAccounts!.contains(id);
  bool can(String task) => isAdmin || tasks[task] == true;

  /// Kept on the device so the account opens without internet (see [AuthService.loadUser]).
  Map<String, Object?> toJson() => {
        'uid': uid,
        'schoolId': schoolId,
        'kind': kind,
        'name': name,
        'tasks': tasks,
        'closeMode': closeMode,
        'allowedAccounts': allowedAccounts,
        'logScope': logScope,
        'carIds': carIds,
        'studentId': studentId,
        'employeeId': employeeId,
      };

  static AppUser? fromJson(Object? j) {
    if (j is! Map || j['uid'] is! String || j['schoolId'] is! String || j['kind'] is! String) return null;
    final tasks = j['tasks'];
    final accounts = j['allowedAccounts'];
    return AppUser(
      uid: j['uid'] as String,
      schoolId: j['schoolId'] as String,
      kind: j['kind'] as String,
      name: (j['name'] as String?) ?? '',
      tasks: {if (tasks is Map) for (final e in tasks.entries) '${e.key}': e.value == true},
      closeMode: (j['closeMode'] as String?) ?? 'blind',
      allowedAccounts: accounts is List ? [for (final a in accounts) '$a'] : null,
      logScope: j['logScope'] == 'all' ? 'all' : 'own',
      carIds: [for (final c in (j['carIds'] as List?) ?? const []) '$c'],
      studentId: j['studentId'] as String?,
      employeeId: j['employeeId'] as String?,
    );
  }
}

/// First open of an account on this device without internet: nothing saved yet to open from.
class OfflineFirstOpen implements Exception {
  const OfflineFirstOpen();
}

/// Login failure with a ready-to-show (gender-neutral) message.
class LoginException implements Exception {
  const LoginException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore, FlutterSecureStorage? storage})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance,
        _store = storage ?? const FlutterSecureStorage();

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final FlutterSecureStorage _store;

  static String _cacheKey(String uid) => 'appUser_$uid';

  static bool _isNetwork(FirebaseException e) =>
      const {'network-request-failed', 'unavailable', 'deadline-exceeded'}.contains(e.code);

  /// Login is no longer valid on the server (disabled, deleted, password changed by the Admin).
  static bool _isRevoked(FirebaseException e) =>
      const {'user-disabled', 'user-not-found', 'user-token-expired', 'invalid-user-token'}.contains(e.code);

  Future<AppUser?> _readCache(String uid) async {
    try {
      final raw = await _store.read(key: _cacheKey(uid));
      return raw == null ? null : AppUser.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(AppUser u) async {
    try {
      await _store.write(key: _cacheKey(u.uid), value: jsonEncode(u.toJson()));
    } catch (_) {}
  }

  Future<void> _clearCache(String uid) async {
    try {
      await _store.delete(key: _cacheKey(uid));
    } catch (_) {}
  }

  Stream<User?> authChanges() => _auth.authStateChanges();

  Future<void> signIn(String nationalId, String password) async {
    if (!isValidNationalId(nationalId)) throw const LoginException('رقم الهوية لازم يكون 9 أرقام');
    if (password.isEmpty) throw const LoginException('كلمة السر مطلوبة');
    try {
      await _auth.signInWithEmailAndPassword(email: loginEmail(nationalId), password: password);
    } on FirebaseAuthException catch (e) {
      throw LoginException(switch (e.code) {
        'invalid-credential' || 'wrong-password' || 'user-not-found' || 'invalid-email' => 'رقم الهوية أو كلمة السر غلط',
        'user-disabled' => 'الحساب موقوف · للتواصل مع الإدارة',
        'too-many-requests' => 'محاولات كثير · المحاولة بعد شوي',
        'network-request-failed' => 'ما في اتصال بالإنترنت · تسجيل الدخول أول مرة بيحتاج إنترنت',
        _ => 'صار خطأ بتسجيل الدخول (${e.code})',
      });
    }
  }

  /// Loads who the user is.
  ///
  /// Offline-first: if this account opened on this device before, it opens at once from the saved
  /// copy (no network wait, works without internet) and is refreshed quietly; the refreshed
  /// permissions apply from the next open. If the server says the login is no longer valid,
  /// [onRevoked] is called. First open without internet → [OfflineFirstOpen].
  /// Throws [LoginException] if the account is not set up for a school.
  Future<AppUser> loadUser(User user, {void Function(String message)? onRevoked}) async {
    final cached = await _readCache(user.uid);
    if (cached != null) {
      unawaited(_refresh(user, onRevoked));
      return cached;
    }
    try {
      return await _fetch(user);
    } on FirebaseException catch (e) {
      if (_isNetwork(e)) throw const OfflineFirstOpen();
      rethrow;
    }
  }

  Future<void> _refresh(User user, void Function(String message)? onRevoked) async {
    try {
      await _fetch(user);
    } on LoginException catch (e) {
      await _clearCache(user.uid);
      onRevoked?.call(e.message);
    } on FirebaseException catch (e) {
      if (_isRevoked(e)) {
        await _clearCache(user.uid);
        onRevoked?.call('الحساب اتغيّر أو انوقف · تسجيل الدخول مرة ثانية');
      }
      // Network problems: keep working from the saved copy.
    } catch (_) {}
  }

  /// Reads the account from the server (token claims + own user doc) and saves it on the device.
  Future<AppUser> _fetch(User user) async {
    final token = await user.getIdTokenResult(true);
    final claims = token.claims ?? const {};
    final schoolId = claims['schoolId'] as String?;
    final kind = claims['kind'] as String?;
    if (schoolId == null || kind == null) {
      await _auth.signOut();
      throw const LoginException('الحساب مش مربوط بمدرسة · للتواصل مع الإدارة');
    }
    var name = user.displayName ?? '';
    var tasks = <String, bool>{};
    var closeMode = 'blind';
    List<String>? accounts;
    var logScope = 'own';
    String? employeeId;
    var complete = true;
    try {
      final doc = await _db.doc('schools/$schoolId/user/${user.uid}').get();
      final data = doc.data();
      name = (data?['name'] as String?) ?? name;
      final permissions = data?['permissions'] as Map?;
      final perms = permissions?['tasks'] as Map?;
      tasks = {for (final e in (perms ?? const {}).entries) '${e.key}': e.value == true};
      closeMode = (permissions?['closeMode'] as String?) ?? 'blind';
      final allowed = permissions?['allowedAccounts'];
      accounts = allowed is List ? allowed.map((e) => '$e').toList() : null;
      logScope = permissions?['logScope'] == 'all' ? 'all' : 'own';
      employeeId = data?['employeeId'] as String?;
    } on FirebaseException {
      // Offline: keep the name from the auth profile; permissions come with the next sync.
      complete = false;
    }
    final appUser = AppUser(uid: user.uid, schoolId: schoolId, kind: kind, name: name, tasks: tasks, closeMode: closeMode, allowedAccounts: accounts,
        logScope: logScope,
        carIds: [for (final c in (claims['carIds'] as List?) ?? const []) '$c'],
        studentId: claims['studentId'] as String?,
        employeeId: employeeId);
    if (complete) await _writeCache(appUser);
    return appUser;
  }

  /// Signing out also forgets the saved copy of the account (A28: nothing of the user stays).
  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) await _clearCache(uid);
    await _auth.signOut();
  }
}
