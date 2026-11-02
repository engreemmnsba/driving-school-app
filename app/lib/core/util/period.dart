import 'dates.dart';

enum PeriodKind { today, week, month, lastMonth, custom }

/// A date range of business days (inclusive). The week starts on Saturday.
class Period {
  const Period(this.kind, this.from, this.to);
  final PeriodKind kind;
  final String from;
  final String to;

  static const labels = {
    PeriodKind.today: 'اليوم',
    PeriodKind.week: 'هذا الأسبوع',
    PeriodKind.month: 'هذا الشهر',
    PeriodKind.lastMonth: 'الشهر الماضي',
    PeriodKind.custom: 'فترة مخصّصة',
  };

  factory Period.of(PeriodKind kind, {DateTime? now, String? from, String? to}) {
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    switch (kind) {
      case PeriodKind.today:
        final d = businessDateOf(today);
        return Period(kind, d, d);
      case PeriodKind.week:
        final back = (today.weekday - DateTime.saturday) % 7;
        return Period(kind, businessDateOf(today.subtract(Duration(days: back))), businessDateOf(today));
      case PeriodKind.month:
        return Period(kind, businessDateOf(DateTime(today.year, today.month, 1)), businessDateOf(today));
      case PeriodKind.lastMonth:
        final first = DateTime(today.year, today.month - 1, 1);
        final last = DateTime(today.year, today.month, 0);
        return Period(kind, businessDateOf(first), businessDateOf(last));
      case PeriodKind.custom:
        return Period(kind, from ?? businessDateOf(DateTime(today.year, today.month, 1)), to ?? businessDateOf(today));
    }
  }

  String get label => kind == PeriodKind.custom ? 'من $from إلى $to' : labels[kind]!;
  bool contains(String businessDate) => businessDate.compareTo(from) >= 0 && businessDate.compareTo(to) <= 0;
}
