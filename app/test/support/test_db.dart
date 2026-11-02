import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:driving_school/core/db/database.dart';
import 'package:driving_school/core/sync/op.dart';
import 'package:sqlite3/open.dart';

/// Host tests need a native SQLite. Windows 10+ ships one as winsqlite3.dll;
/// if a sqlite3.dll is placed in app/tool/, it is preferred.
void useHostSqlite() {
  if (!Platform.isWindows) return;
  open.overrideFor(OperatingSystem.windows, () {
    final local = File('tool/sqlite3.dll');
    if (local.existsSync()) return DynamicLibrary.open(local.absolute.path);
    return DynamicLibrary.open('winsqlite3.dll');
  });
}

AppDatabase memoryDb() {
  useHostSqlite();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

const testSession = SessionInfo(schoolId: 'sch1', userId: 'admin', deviceId: 'dev1', deviceCode: 1);

/// Programmable fake server for sync tests.
class FakeTransport implements OpsTransport {
  final List<List<Map<String, dynamic>>> batches = [];
  int _seq = 0;

  /// Next N calls throw (simulates no internet / dropped connection).
  int failNext = 0;

  /// opId → rejection reason.
  final Map<String, String> rejectIds = {};

  /// opId → assigned fields (e.g. {'number': 9}).
  final Map<String, Map<String, dynamic>> assign = {};

  /// Server already applied these (idempotency): returns the same result again.
  final Map<String, OpResult> _seen = {};

  @override
  Future<List<OpResult>> send(List<Map<String, dynamic>> ops) async {
    if (failNext > 0) {
      failNext--;
      throw TransportException('offline');
    }
    batches.add(ops);
    return [
      for (final op in ops)
        _seen.putIfAbsent(op['opId'] as String, () {
          final id = op['opId'] as String;
          final reason = rejectIds[id];
          if (reason != null) return OpResult.rejected(id, reason, 'مرفوضة');
          return OpResult.accepted(id, ++_seq, assign[id] ?? const {});
        }),
    ];
  }
}
