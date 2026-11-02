/// Who/where the app is running as. Comes from the login session.
class SessionInfo {
  const SessionInfo({required this.schoolId, required this.userId, required this.deviceId, required this.deviceCode});

  final String schoolId;
  final String userId;
  final String deviceId;

  /// Short number used in receipt numbers ("1-0142").
  final int deviceCode;
}

/// Result of one op from applyOps (mirrors functions/src/core/types.ts OpResult).
class OpResult {
  const OpResult._({
    required this.opId,
    required this.accepted,
    this.serverSeq,
    this.assigned = const {},
    this.reason,
    this.message,
  });

  factory OpResult.accepted(String opId, int serverSeq, [Map<String, dynamic> assigned = const {}]) =>
      OpResult._(opId: opId, accepted: true, serverSeq: serverSeq, assigned: assigned);

  factory OpResult.rejected(String opId, String reason, String message) =>
      OpResult._(opId: opId, accepted: false, reason: reason, message: message);

  factory OpResult.fromJson(Map<String, dynamic> j) => j['status'] == 'accepted'
      ? OpResult.accepted(j['opId'] as String, (j['serverSeq'] as num).toInt(), Map<String, dynamic>.from((j['assigned'] as Map?) ?? const {}))
      : OpResult.rejected(j['opId'] as String, j['reason'] as String, (j['message'] as String?) ?? '');

  final String opId;
  final bool accepted;
  final int? serverSeq;
  final Map<String, dynamic> assigned;
  final String? reason;
  final String? message;
}

/// Network/server unavailable — the op stays queued and is retried later.
class TransportException implements Exception {
  TransportException(this.message);
  final String message;
  @override
  String toString() => 'TransportException: $message';
}

/// Sends ops to the server (Firebase callable `applyOpsFn` in production; a fake in tests).
abstract class OpsTransport {
  /// Returns one result per op, or throws [TransportException].
  Future<List<OpResult>> send(List<Map<String, dynamic>> ops);
}
