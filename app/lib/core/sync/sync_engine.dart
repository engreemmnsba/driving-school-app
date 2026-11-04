import 'dart:async';

import 'package:flutter/foundation.dart';

import 'op.dart';
import 'puller.dart';
import 'pusher.dart';

enum SyncState { idle, syncing, synced, offline }

/// Push first (our changes), then pull (everyone's changes). Runs on demand and every [interval].
class SyncEngine {
  /// [online]: the device's connection (true = has a network). Losing it shows "بدون نت" at once,
  /// even with nothing waiting; getting it back syncs right away instead of on the next tick.
  SyncEngine(this.pusher, this.puller, {this.interval = const Duration(seconds: 20), this.online});

  final Pusher pusher;
  final Puller puller;
  final Duration interval;
  final Stream<bool>? online;
  StreamSubscription<bool>? _onlineSub;
  bool _offline = false;

  final state = ValueNotifier<SyncState>(SyncState.idle);
  final lastError = ValueNotifier<String?>(null);
  Timer? _timer;
  bool _running = false;

  void start() {
    _timer ??= Timer.periodic(interval, (_) => syncNow());
    _onlineSub ??= online?.listen((up) {
      _offline = !up;
      if (up) {
        unawaited(syncNow());
      } else if (!_running) {
        state.value = SyncState.offline;
      }
    });
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
      state.value = _offline ? SyncState.offline : SyncState.synced;
    } catch (e) {
      lastError.value = '$e';
      state.value = SyncState.offline;
    } finally {
      _running = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    _onlineSub?.cancel();
    state.dispose();
    lastError.dispose();
  }
}
