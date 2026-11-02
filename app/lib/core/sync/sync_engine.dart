import 'dart:async';

import 'package:flutter/foundation.dart';

import 'op.dart';
import 'puller.dart';
import 'pusher.dart';

enum SyncState { idle, syncing, synced, offline }

/// Push first (our changes), then pull (everyone's changes). Runs on demand and every [interval].
class SyncEngine {
  SyncEngine(this.pusher, this.puller, {this.interval = const Duration(seconds: 20)});

  final Pusher pusher;
  final Puller puller;
  final Duration interval;

  final state = ValueNotifier<SyncState>(SyncState.idle);
  final lastError = ValueNotifier<String?>(null);
  Timer? _timer;
  bool _running = false;

  void start() {
    _timer ??= Timer.periodic(interval, (_) => syncNow());
    unawaited(syncNow());
  }

  Future<void> syncNow() async {
    if (_running) return;
    _running = true;
    state.value = SyncState.syncing;
    try {
      final push = await pusher.pushAll();
      if (push.failed) throw TransportException('push failed');
      await puller.pullAll();
      lastError.value = null;
      state.value = SyncState.synced;
    } catch (e) {
      lastError.value = '$e';
      state.value = SyncState.offline;
    } finally {
      _running = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    state.dispose();
    lastError.dispose();
  }
}
