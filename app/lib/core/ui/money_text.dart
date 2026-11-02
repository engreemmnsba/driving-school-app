import 'package:flutter/material.dart';

import '../domain/money.dart';

/// An amount, always laid out left-to-right so "₪300" never flips to "300₪" inside Arabic text.
/// [sign]: '+' for money in, '−' for money out, '' for neutral amounts.
class MoneyText extends StatelessWidget {
  const MoneyText(this.money, {super.key, this.sign = '', this.style, this.color});

  final Money money;
  final String sign;
  final TextStyle? style;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$sign${money.format()}',
      textDirection: TextDirection.ltr,
      style: (style ?? DefaultTextStyle.of(context).style).copyWith(
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

final _moneyRe = RegExp(r'[+−-]?₪[\d,]+(?:\.\d+)?');

/// A sentence that may contain amounts ("انسجّل عملي 8 · +₪120 عليه"): each amount is wrapped in a
/// left-to-right isolate (U+2066 … U+2069) so it never shows as "120₪+".
/// (Not WidgetSpans: with two amounts in one RTL line Flutter placed them in each other's slot,
/// e.g. "راتب ₪200 · سلف ₪1,500" for a salary of 1,500 and an advance of 200.)
class MoneyRichText extends StatelessWidget {
  const MoneyRichText(this.text, {super.key, this.style, this.maxLines, this.overflow});
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  /// The same text with every amount isolated left-to-right.
  static String isolate(String text) => text.replaceAllMapped(_moneyRe, (m) => '\u2066${m.group(0)}\u2069');

  @override
  Widget build(BuildContext context) {
    return Text(isolate(text), style: style, maxLines: maxLines, overflow: overflow);
  }
}
