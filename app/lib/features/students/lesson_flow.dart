import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/queries.dart';

/// One tap → lesson logged, with "Undo" (canvas SaveFlow). Used on Students and the student profile.
Future<void> logNextLesson(BuildContext context, StudentCard card) async {
  final app = AppScope.of(context);
  try {
    final l = await app.logLesson(card.id, businessDate: todayStr());
    app.syncSoon();
    if (!context.mounted) return;
    final first = card.name.split(' ').first;
    final money = l.charge.isPositive ? ' · +${l.charge.format()} عليه' : '';
    showUndoSnack(context, 'انسجّل ${l.label} ل$first$money', onUndo: () async {
      await app.undoLesson(l.lessonId);
      app.syncSoon();
    });
  } catch (e) {
    if (context.mounted) showErrorSnack(context, '$e');
  }
}
