import 'money.dart';

/// Kinds of student-ledger rows (docs/04-data-model.md). Direction is decided by kind.
enum LedgerKind { registrationFee, lessonCharge, examFee, retakeFee, payment, discount, reversal, chargeReversal }

/// Server/DB string → kind.
LedgerKind ledgerKindOf(String s) => switch (s) {
      'registration_fee' => LedgerKind.registrationFee,
      'lesson_charge' => LedgerKind.lessonCharge,
      'exam_fee' => LedgerKind.examFee,
      'retake_fee' => LedgerKind.retakeFee,
      'payment' => LedgerKind.payment,
      'discount' => LedgerKind.discount,
      'charge_reversal' => LedgerKind.chargeReversal,
      _ => LedgerKind.reversal,
    };

class LedgerRow {
  const LedgerRow({
    required this.id,
    required this.kind,
    required this.amount,
    this.reversesId,
    this.reversed = false,
  });

  final String id;
  final LedgerKind kind;

  /// Always positive; [kind] decides whether it adds or subtracts.
  final Money amount;

  /// For reversals: the payment being reversed.
  final String? reversesId;
  final bool reversed;

  bool get isCharge =>
      kind == LedgerKind.registrationFee ||
      kind == LedgerKind.lessonCharge ||
      kind == LedgerKind.examFee ||
      kind == LedgerKind.retakeFee;
}

/// Totals of one enrollment, computed from rows — never stored as an editable number.
class StudentBalance {
  const StudentBalance({required this.charged, required this.paid, required this.discounts});

  final Money charged;
  final Money paid;
  final Money discounts;

  /// remaining = charges − payments − discounts (negative = credit for the student).
  Money get remaining => charged - paid - discounts;

  static StudentBalance of(Iterable<LedgerRow> rows) {
    var charged = const Money.zero();
    var paid = const Money.zero();
    var discounts = const Money.zero();
    for (final r in rows) {
      if (r.isCharge) {
        charged += r.amount;
      } else if (r.kind == LedgerKind.payment) {
        paid += r.amount; // a reversed payment stays; its reversal row subtracts it
      } else if (r.kind == LedgerKind.discount) {
        discounts += r.amount;
      } else if (r.kind == LedgerKind.reversal) {
        paid -= r.amount;
      } else if (r.kind == LedgerKind.chargeReversal) {
        charged -= r.amount; // a cancelled lesson gives its charge back
      }
    }
    return StudentBalance(charged: charged, paid: paid, discounts: discounts);
  }

  /// Server summary + effect of local ops not yet synced (docs/05 §8).
  StudentBalance plus(Iterable<LedgerRow> pending) {
    final p = StudentBalance.of(pending);
    return StudentBalance(charged: charged + p.charged, paid: paid + p.paid, discounts: discounts + p.discounts);
  }
}
