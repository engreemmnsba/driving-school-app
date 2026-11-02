import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:driving_school/core/db/database.dart';
import 'package:driving_school/core/domain/money.dart';
import 'package:driving_school/core/sync/outbox.dart';
import 'package:driving_school/core/sync/pusher.dart';
import 'package:driving_school/features/money/record_payment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_db.dart';

void main() {
  late AppDatabase db;
  late Outbox outbox;
  late FakeTransport server;
  late Pusher pusher;
  late RecordPayment pay;

  setUp(() {
    db = memoryDb();
    outbox = Outbox(db, testSession);
    server = FakeTransport();
    pusher = Pusher(db, outbox, server);
    pay = RecordPayment(db, outbox, testSession);
  });
  tearDown(() => db.close());

  Future<String> payShekels(int s) => pay(
        enrollmentId: 'en1',
        studentId: 'st1',
        amount: Money.shekels(s),
        accountId: 'cash',
        purpose: 'lessons',
        businessDate: '2026-10-19',
      );

  test('a payment writes ledger + movement + outbox together, with a device receipt number', () async {
    final id = await payShekels(500);
    final row = await (db.select(db.ledgerEntries)..where((t) => t.id.equals(id))).getSingle();
    expect(row.syncState, 'pending');
    expect(row.receiptNo, '1-0001');
    expect(await db.select(db.treasuryMovements).get(), hasLength(1));
    final ops = await db.select(db.outboxOps).get();
    expect(ops.single.type, 'payment.record');
    expect(ops.single.opId, row.opId);
  });

  test('balance = server summary + pending ops (offline numbers are right)', () async {
    await db.into(db.studentSummaries).insert(StudentSummariesCompanion.insert(
        enrollmentId: 'en1', studentId: 'st1', charged: const Value(134000), paid: const Value(30000), discounts: const Value(10000), serverSeq: const Value(5)));
    await payShekels(500);
    expect((await localBalance(db, 'en1')).remaining, Money.shekels(440));
  });

  test('accepted → rows synced with serverSeq, outbox empty; balance does not double count', () async {
    await payShekels(500);
    final report = await pusher.pushAll();
    expect(report.accepted, 1);
    expect(await db.select(db.outboxOps).get(), isEmpty);
    final row = (await db.select(db.ledgerEntries).get()).single;
    expect(row.syncState, 'synced');
    expect(row.serverSeq, 1);
    // Summary pulled later already includes the payment (serverSeq 1) → row no longer added on top.
    await db.into(db.studentSummaries).insert(StudentSummariesCompanion.insert(
        enrollmentId: 'en1', studentId: 'st1', charged: const Value(134000), paid: const Value(80000), discounts: const Value(10000), serverSeq: const Value(1)));
    expect((await localBalance(db, 'en1')).remaining, Money.shekels(440));
  });

  test('no internet → ops stay queued with the error, then go out in order when it returns', () async {
    await payShekels(100);
    await payShekels(200);
    server.failNext = 1;
    final first = await pusher.pushAll();
    expect(first.failed, isTrue);
    final queued = await (db.select(db.outboxOps)..orderBy([(t) => OrderingTerm.asc(t.deviceSeq)])).get();
    expect(queued, hasLength(2));
    expect(queued.first.attempts, 1);
    expect(queued.first.lastError, 'offline');
    final second = await pusher.pushAll();
    expect(second.accepted, 2);
    final sent = server.batches.single.map((o) => o['deviceSeq']).toList();
    expect(sent, [1, 2]);
  });

  test('rejected → kept in the rejected list with the reason, row excluded from the balance', () async {
    final id = await payShekels(500);
    final opId = (await db.select(db.outboxOps).get()).single.opId;
    server.rejectIds[opId] = 'account_not_allowed';
    final report = await pusher.pushAll();
    expect(report.rejected, 1);
    final rejected = (await db.select(db.rejectedOps).get()).single;
    expect(rejected.reason, 'account_not_allowed');
    final row = await (db.select(db.ledgerEntries)..where((t) => t.id.equals(id))).getSingle();
    expect(row.syncState, 'rejected');
    expect((await localBalance(db, 'en1')).paid, const Money.zero());
  });

  test('sends in batches of 50', () async {
    for (var i = 0; i < 120; i++) {
      await payShekels(1);
    }
    final report = await pusher.pushAll();
    expect(report.accepted, 120);
    expect(server.batches.map((b) => b.length).toList(), [50, 50, 20]);
  });

  test('resending after a lost answer is safe (server idempotency)', () async {
    await payShekels(500);
    final wire = outbox.toWire((await db.select(db.outboxOps).get()).single);
    final a = await server.send([wire]);
    final b = await server.send([wire]);
    expect(a.single.serverSeq, b.single.serverSeq);
  });

  test('the server-assigned lesson number replaces the provisional one', () async {
    final opId = newId();
    await db.transaction(() async {
      await db.into(db.lessons).insert(LessonsCompanion.insert(
          id: 'l1', enrollmentId: 'en1', studentId: 'st1', type: 'practical', number: 8, employeeId: 'emp1',
          startedAt: '2026-10-19T08:00:00Z', businessDate: '2026-10-19', opId: Value(opId)));
      await outbox.enqueue('lesson.log', {'lessonId': 'l1'}, opId: opId);
    });
    server.assign[opId] = {'number': 9};
    await pusher.pushAll();
    final lesson = (await db.select(db.lessons).get()).single;
    expect(lesson.number, 9);
    expect(lesson.syncState, 'synced');
  });
}
