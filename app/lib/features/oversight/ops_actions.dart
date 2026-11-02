import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/sync/outbox.dart';
import '../../data/ops_queries.dart';
import '../students/student_actions.dart' show ActionError;

/// Locks a finished month (all its days must be closed). The server checks again and is the referee.
class LockMonth {
  LockMonth(this.db, this.outbox, this.userName);
  final AppDatabase db;
  final Outbox outbox;
  final String userName;

  Future<void> call(String month) async {
    final st = await OpsQueries(db).monthLock(month);
    if (st.locked) throw const ActionError('الشهر مثبّت من قبل');
    if (st.openDays.isNotEmpty) throw ActionError('في ${st.openDays.length} أيام مش مسكّرة بهالشهر · لازم تنسكّر أول');
    await db.transaction(() async {
      await db.into(db.monthLocks).insertOnConflictUpdate(MonthLocksCompanion.insert(id: month, locked: const Value(true), lockedByName: Value(userName)));
      await outbox.enqueue('month.lock', {'month': month});
    });
  }
}

class UnlockMonth {
  UnlockMonth(this.db, this.outbox);
  final AppDatabase db;
  final Outbox outbox;

  Future<void> call(String month, String reason) async {
    if (reason.trim().isEmpty) throw const ActionError('سبب فتح الشهر مطلوب');
    await db.transaction(() async {
      await db.into(db.monthLocks).insertOnConflictUpdate(MonthLocksCompanion.insert(id: month, locked: const Value(false), unlockReason: Value(reason.trim())));
      await outbox.enqueue('month.unlock', {'month': month, 'reason': reason.trim()});
    });
  }
}

class OpsActions {
  OpsActions(AppDatabase db, Outbox outbox, String userName)
      : queries = OpsQueries(db),
        lockMonth = LockMonth(db, outbox, userName),
        unlockMonth = UnlockMonth(db, outbox);
  final OpsQueries queries;
  final LockMonth lockMonth;
  final UnlockMonth unlockMonth;
}
