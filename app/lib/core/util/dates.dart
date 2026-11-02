/// Business dates are YYYY-MM-DD in the school's day (Asia/Hebron; the phone's local day).
String businessDateOf(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final l = d.toLocal();
  return '${l.year}-${two(l.month)}-${two(l.day)}';
}

String todayStr() => businessDateOf(DateTime.now());

const _weekdays = ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
const _months = ['كانون الثاني', 'شباط', 'آذار', 'نيسان', 'أيار', 'حزيران', 'تموز', 'آب', 'أيلول', 'تشرين الأول', 'تشرين الثاني', 'كانون الأول'];

/// "الإثنين 19/10"
String dayHeader(DateTime d) => '${_weekdays[d.weekday - 1]} ${d.day}/${d.month}';

/// "11:42"
String hhmm(DateTime d) {
  final l = d.toLocal();
  return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
}

/// "اليوم 11:42" · "مبارح" · "15 تشرين الأول"
String friendlyDate(String businessDate, {String? atIso}) {
  final today = todayStr();
  final t = atIso == null ? null : DateTime.tryParse(atIso);
  if (businessDate == today) return t == null ? 'اليوم' : 'اليوم ${hhmm(t)}';
  final y = businessDateOf(DateTime.now().subtract(const Duration(days: 1)));
  if (businessDate == y) return t == null ? 'مبارح' : 'مبارح ${hhmm(t)}';
  final parts = businessDate.split('-');
  if (parts.length != 3) return businessDate;
  return '${int.parse(parts[2])} ${_months[int.parse(parts[1]) - 1]}';
}

/// "2/11" from "2026-11-02".
String dateShort(String businessDate) {
  final p = businessDate.split('-');
  return p.length == 3 ? '${int.parse(p[2])}/${int.parse(p[1])}' : businessDate;
}
