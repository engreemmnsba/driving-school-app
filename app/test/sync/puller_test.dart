import 'package:driving_school/core/db/database.dart';
import 'package:driving_school/core/domain/money.dart';
import 'package:driving_school/core/sync/outbox.dart';
import 'package:driving_school/core/sync/puller.dart';
import 'package:driving_school/core/sync/pusher.dart';
import 'package:driving_school/features/money/record_payment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_db.dart';

/// In-memory server change feed: collection → docs (each with serverSeq).
class FakeChangeSource implements ChangeSource {
  final Map<String, List<RemoteDoc>> docs = {};
  final List<String> calls = [];
  int _seq = 0;

  void add(String collection, String id, Map<String, dynamic> data) {
    (docs[collection] ??= []).add(RemoteDoc(id: id, serverSeq: ++_seq, data: data));
  }

  @override
  Future<List<RemoteDoc>> fetch(String collection, {required int afterSeq, required int limit}) async {
    calls.add('$collection>$afterSeq');
    final list = (docs[collection] ?? []).where((d) => d.serverSeq > afterSeq).toList()
      ..sort((a, b) => a.serverSeq.compareTo(b.serverSeq));
    return list.take(limit).toList();
  }
}

Map<String, dynamic> _payment(String opId, int amount) => {
      'enrollmentId': 'en1', 'studentId': 'st1', 'kind': 'payment', 'amount': amount,
      'accountId': 'cash', 'purpose': 'lessons', 'receiptNo': '2-0001', 'businessDate': '2026-10-19', 'opId': opId,
    };

void main() {
  late AppDatabase db;
  late FakeChangeSource server;

  setUp(() {
    db = memoryDb();
    server = FakeChangeSource();
  });
  tearDown(() => db.close());

  test('pulls changes made on other phones and only new ones next time', () async {
    server.add('student_ledger', 'p1', _payment('opA', 30000));
    final puller = Puller(db, server, collections: ['student_ledger']);
    expect((await puller.pullAll()).total, 1);
    server.add('student_ledger', 'p2', _payment('opB', 50000));
    expect((await puller.pullAll()).total, 1);
    expect(server.calls.last, 'student_ledger>1'); // asked only for changes after the cursor
    final rows = await db.select(db.ledgerEntries).get();
    expect(rows.map((r) => r.syncState).toSet(), {'synced'});
    expect(rows, hasLength(2));
  });

  test('pages through a long offline period (1,200 docs in pages of 500)', () async {
    for (var i = 0; i < 1200; i++) {
      server.add('treasury_movement', 'm$i', {
        'accountId': 'cash', 'direction': 'in', 'amount': 100, 'kind': 'student_payment', 'refId': 'p$i', 'businessDate': '2026-10-19',
      });
    }
    final report = await Puller(db, server, collections: ['treasury_movement']).pullAll();
    expect(report.total, 1200);
    expect(server.calls, ['treasury_movement>0', 'treasury_movement>500', 'treasury_movement>1000']);
  });

  test('own payment: push, then pull the server copy + summary → balance counted once', () async {
    final outbox = Outbox(db, testSession);
    final pay = RecordPayment(db, outbox, testSession);
    final transport = FakeTransport();
    await pay(enrollmentId: 'en1', studentId: 'st1', amount: Money.shekels(500), accountId: 'cash', purpose: 'lessons', businessDate: '2026-10-19');
    final local = (await db.select(db.ledgerEntries).get()).single;
    await Pusher(db, outbox, transport).pushAll();

    // Server feed now has the same payment (same id) and an updated summary that includes it.
    server.add('student_ledger', local.id, _payment(local.opId!, 50000));
    server.add('student_summary', 'en1', {'studentId': 'st1', 'charged': 134000, 'paid': 80000, 'discounts': 10000});
    await Puller(db, server, collections: ['student_ledger', 'student_summary']).pullAll();

    expect(await db.select(db.ledgerEntries).get(), hasLength(1));
    expect((await localBalance(db, 'en1')).remaining, Money.shekels(440));
  });

  test('a page and its cursor are saved together', () async {
    server.add('lesson', 'l1', {
      'enrollmentId': 'en1', 'studentId': 'st1', 'type': 'practical', 'number': 3, 'employeeId': 'emp1',
      'carId': 'car1', 'startedAt': '2026-10-19T08:00:00Z', 'businessDate': '2026-10-19',
    });
    await Puller(db, server, collections: ['lesson']).pullAll();
    final cursor = await db.select(db.syncCursors).getSingle();
    expect(cursor.collection, 'lesson');
    expect(cursor.lastSeq, 1);
    expect((await db.select(db.lessons).getSingle()).number, 3);
  });
}
