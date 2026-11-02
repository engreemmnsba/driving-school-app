import '../auth/auth_service.dart';
import '../db/database.dart';
import 'op.dart';
import 'outbox.dart';

/// Opens the signed-in user's own local database and builds the session (device id + code).
Future<(AppDatabase, SessionInfo)> openSession(AppUser user) async {
  final db = AppDatabase.open(name: 'ds_${user.uid}');
  var deviceId = await db.kvGet('deviceId');
  if (deviceId == null) {
    deviceId = newId();
    await db.kvSet('deviceId', deviceId);
  }
  // TEMPORARY (dev only): receipt prefix derived locally. Will be assigned by the server on
  // device registration so two phones can never share a prefix.
  var code = int.tryParse(await db.kvGet('deviceCode') ?? '');
  if (code == null) {
    code = 100 + deviceId.codeUnits.fold<int>(0, (a, b) => (a * 31 + b) % 900);
    await db.kvSet('deviceCode', '$code');
  }
  return (db, SessionInfo(schoolId: user.schoolId, userId: user.uid, deviceId: deviceId, deviceCode: code));
}
