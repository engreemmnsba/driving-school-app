import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// An account that signed in on this device (shown on Login, like "saved accounts").
/// Only the national ID and the name are kept — never the password.
class SavedAccount {
  const SavedAccount({required this.nationalId, required this.name});
  final String nationalId;
  final String name;

  Map<String, String> toJson() => {'id': nationalId, 'name': name};
  static SavedAccount? fromJson(Object? j) =>
      j is Map && j['id'] is String ? SavedAccount(nationalId: j['id'] as String, name: (j['name'] as String?) ?? '') : null;
}

/// Kept outside the app database (which is wiped on sign-out), in the device's secure storage.
class SavedAccounts {
  SavedAccounts([FlutterSecureStorage? storage]) : _s = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _s;
  static const _key = 'savedAccounts';
  static const max = 5;

  Future<List<SavedAccount>> list() async {
    try {
      final raw = await _s.read(key: _key);
      if (raw == null) return const [];
      return [for (final j in jsonDecode(raw) as List) ?SavedAccount.fromJson(j)];
    } catch (_) {
      return const []; // storage unavailable (tests, private window): just no saved accounts
    }
  }

  /// Newest first, one entry per national ID.
  Future<void> remember(SavedAccount a) async {
    try {
      final all = [a, ...(await list()).where((x) => x.nationalId != a.nationalId)].take(max).toList();
      await _s.write(key: _key, value: jsonEncode([for (final x in all) x.toJson()]));
    } catch (_) {}
  }

  Future<void> forget(String nationalId) async {
    try {
      final all = (await list()).where((x) => x.nationalId != nationalId).toList();
      await _s.write(key: _key, value: jsonEncode([for (final x in all) x.toJson()]));
    } catch (_) {}
  }

  /// The national ID behind a Firebase login email ("401234567@login…").
  static String? idFromEmail(String? email) {
    final id = email?.split('@').first;
    return id != null && RegExp(r'^\d{9}$').hasMatch(id) ? id : null;
  }
}
