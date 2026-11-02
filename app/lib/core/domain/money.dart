/// Money in integer agorot (₪1 = 100). Never use double for money (DECISIONS / master prompt).
class Money implements Comparable<Money> {
  const Money(this.agorot);

  const Money.zero() : agorot = 0;

  factory Money.shekels(int shekels) => Money(shekels * 100);

  final int agorot;

  Money operator +(Money other) => Money(agorot + other.agorot);
  Money operator -(Money other) => Money(agorot - other.agorot);
  Money operator *(int times) => Money(agorot * times);
  Money operator -() => Money(-agorot);

  bool get isZero => agorot == 0;
  bool get isNegative => agorot < 0;
  bool get isPositive => agorot > 0;
  Money abs() => Money(agorot.abs());

  @override
  int compareTo(Money other) => agorot.compareTo(other.agorot);
  bool operator >(Money other) => agorot > other.agorot;
  bool operator <(Money other) => agorot < other.agorot;
  bool operator >=(Money other) => agorot >= other.agorot;
  bool operator <=(Money other) => agorot <= other.agorot;

  @override
  bool operator ==(Object other) => other is Money && other.agorot == agorot;

  @override
  int get hashCode => agorot.hashCode;

  /// "₪1,250" or "₪12.50" — sign NOT included; callers add words/signs per screen rules.
  String format() {
    final abs = agorot.abs();
    final whole = abs ~/ 100;
    final cents = abs % 100;
    final digits = whole.toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    if (cents != 0) buf.write('.${cents.toString().padLeft(2, '0')}');
    return '₪$buf';
  }

  @override
  String toString() => format();
}
