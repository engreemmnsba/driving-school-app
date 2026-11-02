/// Amount in Arabic words for receipts: 500 → "خمسمئة شيكل". Whole shekels up to 999,999.
String shekelsInWords(int shekels) {
  if (shekels == 0) return 'صفر شيكل';
  final words = _number(shekels);
  return '$words شيكل';
}

const _ones = ['', 'واحد', 'اثنان', 'ثلاثة', 'أربعة', 'خمسة', 'ستة', 'سبعة', 'ثمانية', 'تسعة', 'عشرة', 'أحد عشر', 'اثنا عشر', 'ثلاثة عشر', 'أربعة عشر', 'خمسة عشر', 'ستة عشر', 'سبعة عشر', 'ثمانية عشر', 'تسعة عشر'];
const _tens = ['', '', 'عشرون', 'ثلاثون', 'أربعون', 'خمسون', 'ستون', 'سبعون', 'ثمانون', 'تسعون'];
const _hundreds = ['', 'مئة', 'مئتان', 'ثلاثمئة', 'أربعمئة', 'خمسمئة', 'ستمئة', 'سبعمئة', 'ثمانمئة', 'تسعمئة'];

String _below1000(int n) {
  final parts = <String>[];
  if (n >= 100) parts.add(_hundreds[n ~/ 100]);
  final r = n % 100;
  if (r > 0) {
    if (r < 20) {
      parts.add(_ones[r]);
    } else {
      final o = r % 10;
      parts.add(o == 0 ? _tens[r ~/ 10] : '${_ones[o]} و${_tens[r ~/ 10]}');
    }
  }
  return parts.join(' و');
}

String _number(int n) {
  if (n < 1000) return _below1000(n);
  final th = n ~/ 1000;
  final rest = n % 1000;
  final String thousands;
  if (th == 1) {
    thousands = 'ألف';
  } else if (th == 2) {
    thousands = 'ألفان';
  } else if (th <= 10) {
    thousands = '${_below1000(th)} آلاف';
  } else {
    thousands = '${_below1000(th)} ألف';
  }
  return rest == 0 ? thousands : '$thousands و${_below1000(rest)}';
}
