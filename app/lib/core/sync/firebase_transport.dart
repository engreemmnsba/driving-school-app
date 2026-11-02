import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';

import '../firebase/firebase_setup.dart';
import 'op.dart';

/// Sends ops to the `applyOpsFn` callable. Any failure keeps the ops queued (TransportException).
class FirebaseOpsTransport implements OpsTransport {
  FirebaseOpsTransport({FirebaseFunctions? functions})
      : _fn = (functions ?? FirebaseFunctions.instanceFor(region: functionsRegion))
            .httpsCallable('applyOpsFn', options: HttpsCallableOptions(timeout: const Duration(seconds: 60)));

  final HttpsCallable _fn;

  @override
  Future<List<OpResult>> send(List<Map<String, dynamic>> ops) async {
    try {
      final res = await _fn.call<dynamic>({'ops': ops});
      // Normalise platform maps (web returns JS-converted maps) into plain JSON.
      final data = jsonDecode(jsonEncode(res.data)) as Map<String, dynamic>;
      final results = (data['results'] as List).cast<Map<String, dynamic>>();
      return results.map(OpResult.fromJson).toList();
    } on FirebaseFunctionsException catch (e) {
      throw TransportException('${e.code}: ${e.message ?? ''}');
    } catch (e) {
      throw TransportException('offline: $e');
    }
  }
}
