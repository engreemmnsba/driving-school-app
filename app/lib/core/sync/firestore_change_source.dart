import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'op.dart';
import 'puller.dart';

/// Reads `schools/{schoolId}/{collection}` where serverSeq > cursor, oldest first.
/// What each user may read is enforced by firestore.rules; the queries must say the same thing, so
/// instructors filter by their cars and students by their own id ([scope]).
class FirestoreChangeSource implements ChangeSource {
  FirestoreChangeSource(this.schoolId, {FirebaseFirestore? firestore, this.scope = const {}, this.ownDocs = const {}})
      : _db = firestore ?? FirebaseFirestore.instance;

  final String schoolId;
  final FirebaseFirestore _db;

  /// collection → (field, allowed values): `where(field, whereIn: values)`.
  final Map<String, (String, List<String>)> scope;

  /// collection → one document id read directly (e.g. a student's own `student` doc).
  final Map<String, String> ownDocs;

  @override
  Future<List<RemoteDoc>> fetch(String collection, {required int afterSeq, required int limit}) async {
    try {
      final own = ownDocs[collection];
      if (own != null) {
        final d = await _db.doc('schools/$schoolId/$collection/$own').get(const GetOptions(source: Source.server));
        final data = d.data();
        final seq = (data?['serverSeq'] as num?)?.toInt() ?? 0;
        if (data == null || seq <= afterSeq) return const [];
        return [RemoteDoc(id: d.id, serverSeq: seq, data: _clean(data))];
      }
      Query<Map<String, dynamic>> q = _db.collection('schools/$schoolId/$collection');
      final s = scope[collection];
      if (s != null) {
        if (s.$2.isEmpty) return const []; // e.g. an instructor with no car yet
        q = q.where(s.$1, whereIn: s.$2.take(30).toList());
      }
      final snap = await q.where('serverSeq', isGreaterThan: afterSeq).orderBy('serverSeq').limit(limit).get(const GetOptions(source: Source.server));
      return [
        for (final d in snap.docs) RemoteDoc(id: d.id, serverSeq: (d.data()['serverSeq'] as num).toInt(), data: _clean(d.data())),
      ];
    } on FirebaseException catch (e) {
      throw TransportException('${e.code}: ${e.message ?? ''}');
    }
  }

  static Map<String, dynamic> _clean(Map<String, dynamic> data) => jsonDecode(jsonEncode(data, toEncodable: _plain)) as Map<String, dynamic>;

  static Object? _plain(Object? v) => v is Timestamp ? v.toDate().toUtc().toIso8601String() : v.toString();
}
