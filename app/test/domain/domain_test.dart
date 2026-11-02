import 'package:driving_school/core/domain/ledger.dart';
import 'package:driving_school/core/domain/money.dart';
import 'package:driving_school/core/domain/permissions.dart';
import 'package:driving_school/core/domain/pricing.dart';
import 'package:flutter_test/flutter_test.dart';

LicensePrice _price(String id, String from, int lesson) => LicensePrice(
      id: id,
      licenseTypeId: 'lt_private',
      effectiveFrom: from,
      registrationFee: Money.shekels(500),
      practicalLessonPrice: Money.shekels(lesson),
      theoryRetakeFee: Money.shekels(80),
      practicalExamFee: Money.shekels(100),
    );

void main() {
  group('Money', () {
    test('formats like the mockups', () {
      expect(Money.shekels(1250).format(), '₪1,250');
      expect(Money.shekels(1250000).format(), '₪1,250,000');
      expect(const Money(1250).format(), '₪12.50');
      expect(const Money(-44000).format(), '₪440');
    });

    test('is exact (no floating point)', () {
      var total = const Money.zero();
      for (var i = 0; i < 10; i++) {
        total += const Money(10); // 10 × 0.10 shekel
      }
      expect(total, Money.shekels(1));
    });
  });

  group('StudentBalance (same numbers as the canonical sample: Ahmed)', () {
    test('remaining = charges − payments − discounts', () {
      final rows = [
        LedgerRow(id: 'reg', kind: LedgerKind.registrationFee, amount: Money.shekels(500)),
        for (var i = 1; i <= 7; i++) LedgerRow(id: 'l$i', kind: LedgerKind.lessonCharge, amount: Money.shekels(120)),
        LedgerRow(id: 'd', kind: LedgerKind.discount, amount: Money.shekels(100)),
        LedgerRow(id: 'p1', kind: LedgerKind.payment, amount: Money.shekels(300)),
        LedgerRow(id: 'p2', kind: LedgerKind.payment, amount: Money.shekels(500)),
      ];
      final b = StudentBalance.of(rows);
      expect(b.charged, Money.shekels(1340));
      expect(b.paid, Money.shekels(800));
      expect(b.remaining, Money.shekels(440));
    });

    test('a reversal cancels its payment without deleting it', () {
      final rows = [
        LedgerRow(id: 'reg', kind: LedgerKind.registrationFee, amount: Money.shekels(500)),
        LedgerRow(id: 'p1', kind: LedgerKind.payment, amount: Money.shekels(500), reversed: true),
        LedgerRow(id: 'r1', kind: LedgerKind.reversal, amount: Money.shekels(500), reversesId: 'p1'),
      ];
      expect(StudentBalance.of(rows).remaining, Money.shekels(500));
    });

    test('summary + pending local ops', () {
      final server = StudentBalance(charged: Money.shekels(1340), paid: Money.shekels(300), discounts: Money.shekels(100));
      final pending = [LedgerRow(id: 'p2', kind: LedgerKind.payment, amount: Money.shekels(500))];
      expect(server.plus(pending).remaining, Money.shekels(440));
    });
  });

  group('priceAt (same rule as the server)', () {
    final versions = [_price('pr1', '2026-09-01', 100), _price('pr2', '2026-10-15', 120)];
    test('uses the price effective on the business date', () {
      expect(priceAt(versions, 'lt_private', '2026-10-12')!.id, 'pr1');
      expect(priceAt(versions, 'lt_private', '2026-10-15')!.id, 'pr2');
      expect(priceAt(versions, 'lt_private', '2026-10-19')!.id, 'pr2');
    });
    test('returns null before any price exists or for another license', () {
      expect(priceAt(versions, 'lt_private', '2026-08-31'), isNull);
      expect(priceAt(versions, 'lt_moto', '2026-10-19'), isNull);
    });
  });

  group('permission dependencies (same as the server)', () {
    test('checking a task checks what it needs', () {
      final r = withDependencies({'editPay': true});
      expect(r['addPay'], isTrue);
      expect(r['seeMoney'], isTrue);
      expect(r['students'], isTrue);
    });
    test('unchecking removes dependents, and reports side effects', () {
      final before = {'students': true, 'seeMoney': true, 'addPay': true, 'editPay': true};
      final after = withoutDependents(before, 'seeMoney');
      expect(after['addPay'], isFalse);
      expect(after['editPay'], isFalse);
      expect(after['students'], isTrue);
      expect(sideEffects(before, after, 'seeMoney'), ['addPay', 'editPay']);
    });
  });
}
