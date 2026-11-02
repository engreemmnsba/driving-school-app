import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:driving_school/core/db/database.dart';
import 'package:driving_school/core/domain/money.dart';
import 'package:driving_school/core/sync/outbox.dart';
import 'package:driving_school/core/util/period.dart';
import 'package:driving_school/data/money_queries.dart';
import 'package:driving_school/features/money/money_actions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_db.dart';

void main() {
  test('periods: week starts on Saturday, last month is the whole month', () {
    final wed = DateTime(2026, 10, 21); // Wednesday
    expect(Period.of(PeriodKind.week, now: wed).from, '2026-10-17'); // Saturday
    final last = Period.of(PeriodKind.lastMonth, now: wed);
    expect((last.from, last.to), ('2026-09-01', '2026-09-30'));
    expect(Period.of(PeriodKind.today, now: wed).contains('2026-10-21'), isTrue);
  });

  group('account balance', () {
    late AppDatabase db;
    late Outbox outbox;
    setUp(() async {
      db = memoryDb();
      outbox = Outbox(db, testSession);
      await db.into(db.treasuryAccounts).insert(TreasuryAccountsCompanion.insert(id: 'cash', name: 'كاش', kind: 'cash', openingBalance: const Value(100000)));
      await db.into(db.treasuryAccounts).insert(TreasuryAccountsCompanion.insert(id: 'bank', name: 'البنك', kind: 'bank'));
    });
    tearDown(() => db.close());

    test('= server balance + movements newer than it (pending and later synced)', () async {
      await db.into(db.accountBalances).insert(AccountBalancesCompanion.insert(accountId: 'cash', balance: 200000, serverSeq: const Value(10)));
      // already inside the server balance:
      await db.into(db.treasuryMovements).insert(TreasuryMovementsCompanion.insert(
          id: 'old', accountId: 'cash', direction: 'in', amount: 50000, kind: 'student_payment', refId: 'x', businessDate: '2026-10-19',
          syncState: const Value('synced'), serverSeq: const Value(9)));
      await AddExpense(db, outbox)(kind: 'cars', item: 'بنزين', label: 'بنزين سيارة 1', carId: 'car1', amount: Money.shekels(270), accountId: 'cash', businessDate: '2026-10-19');
      final acc = await MoneyQueries(db).accounts();
      expect(acc.firstWhere((a) => a.id == 'cash').balance, Money.shekels(2000 - 270));
      expect(acc.firstWhere((a) => a.id == 'bank').balance, const Money.zero());
    });

    test('opening balance is used before the first server balance; a transfer keeps the total', () async {
      await MoveMoney(db, outbox)(kind: 'transfer', fromAccountId: 'cash', toAccountId: 'bank', amount: Money.shekels(300), businessDate: '2026-10-19');
      final acc = await MoneyQueries(db).accounts();
      expect(acc.firstWhere((a) => a.id == 'cash').balance, Money.shekels(700));
      expect(acc.firstWhere((a) => a.id == 'bank').balance, Money.shekels(300));
      final (i, o) = await MoneyQueries(db).totals('2026-10-19', '2026-10-19');
      expect((i, o), (const Money.zero(), const Money.zero())); // transfers are not income or spending
      expect((await db.select(db.outboxOps).get()).single.type, 'money.move');
    });
  });
}
