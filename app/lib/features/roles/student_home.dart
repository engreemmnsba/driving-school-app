import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/domain/money.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/queries.dart';
import '../../data/role_queries.dart';
import '../money/receipt_screen.dart';

/// Canvas StudentHome: the student's own progress, money in full detail, exams, lessons and receipts. Read-only.
class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  Stream<(StudentHomeData?, String)>? _stream;

  static const _purpose = {'lessons': 'دروس', 'registration': 'تسجيل', 'exam': 'اختبار', 'general': 'عام'};

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    _stream ??= watchLoad(app.db, () async => (await RoleQueries(app.db).studentHome(app.user.studentId), await app.settings.queries.schoolName()));
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<(StudentHomeData?, String)>(
          stream: _stream,
          builder: (context, snap) {
            final d = snap.data?.$1;
            final school = snap.data?.$2 ?? '';
            return ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 24),
              children: [
                Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: t.primary, borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.directions_car_filled_rounded, color: t.onPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(d == null ? school : 'رخصة ${d.licenseName} · $school', style: TextStyle(fontSize: 13, color: t.textSecondary)),
                      Text(d?.enrollment.studentName ?? app.user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 14),
                if (snap.hasError)
                  ErrorPanel(title: 'ما انفتحت صفحتك', body: '${snap.error}')
                else if (snap.data == null)
                  const SkeletonCards(count: 4, height: 90)
                else if (d == null)
                  const EmptyState(icon: Icons.cloud_download_outlined, title: 'بياناتك لسا ما وصلت', body: 'أول ما يتصل الجوال بالإنترنت بتطلع هون')
                else ..._body(context, d),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => app.signOut(),
                    child: Text('تسجيل الخروج', style: TextStyle(color: t.textSecondary, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context, StudentHomeData d) {
    final t = context.tokens;
    final e = d.enrollment;
    final b = d.balance;
    final pending = d.pendingExam;
    final String banner;
    final String bannerSub;
    if (pending != null) {
      final kind = pending.type == 'practical' ? 'العملي' : 'النظري';
      banner = 'عندك اختبار $kind · ${dateShort(pending.scheduledDate)}';
      bannerSub = pending.scheduledDate == todayStr() ? 'الاختبار اليوم · بالتوفيق' : 'التاريخ ممكن يتأجّل من الوزارة · بيوصلك خبر';
    } else if (e.stage == 'graduated') {
      banner = 'مبروك · خلصت الرخصة ✓';
      bannerSub = 'صفحتك بتضل موجودة';
    } else if (e.stage == 'passed') {
      banner = 'نجحت بالعملي ✓';
      bannerSub = 'التخريج بيصير من المدرسة';
    } else if (d.theoryPassed) {
      banner = 'نجحت بالنظري ✓';
      final planned = e.plannedPractical;
      bannerSub = planned == null
          ? 'اختبار العملي بيتحجز بعد الدروس'
          : d.practicalDone >= planned
              ? 'الدروس المخططة خلصت · موعد اختبار العملي من المدرسة'
              : 'اختبار العملي بيتحجز بعد ${planned - d.practicalDone} دروس كمان';
    } else {
      banner = 'مرحلة النظري';
      bannerSub = 'اختبار النظري بيتحجز لما تخلص دروس النظري';
    }
    Widget tile(String label, String value, {double? progress}) => Expanded(
          child: Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 13, color: t.textSecondary)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              if (progress != null) ...[const SizedBox(height: 6), ProgressLine(progress)],
            ]),
          ),
        );
    String count(int done, int? planned) => planned == null ? '$done درس' : '$done من $planned';
    return [
      Container(
        padding: const EdgeInsetsDirectional.all(14),
        decoration: BoxDecoration(color: const Color(0xFFFFF4CC), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          const Icon(Icons.event_rounded, color: Color(0xFF4A3A00)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(banner, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF4A3A00))),
              Text(bannerSub, style: const TextStyle(fontSize: 12, color: Color(0xFF4A3A00))),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 10),
      Row(children: [
        tile('النظري', d.theoryPassed ? 'تم الاجتياز ✓' : count(d.theoryDone, e.plannedTheory),
            progress: d.theoryPassed || e.plannedTheory == null || e.plannedTheory == 0 ? null : d.theoryDone / e.plannedTheory!),
        const SizedBox(width: 10),
        tile('العملي', count(d.practicalDone, e.plannedPractical),
            progress: e.plannedPractical == null || e.plannedPractical == 0 ? null : d.practicalDone / e.plannedPractical!),
      ]),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsetsDirectional.all(16),
        decoration: BoxDecoration(color: t.primary, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Row(children: [
            Expanded(child: Text(b.remaining.isNegative ? 'رصيد إلك' : 'المتبقي', style: const TextStyle(fontSize: 14, color: Color(0xFFD5ECEB)))),
            MoneyText(b.remaining.abs(), color: Colors.white, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _money('المحسوب', b.charged),
            _money('المدفوع', b.paid),
            _money('خصم', b.discounts),
          ]),
        ]),
      ),
      const SizedBox(height: 14),
      const Text('آخر دروسي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      if (d.lessons.isEmpty) Text('لسا ما في دروس', style: TextStyle(fontSize: 13, color: t.textSecondary)),
      for (final l in d.lessons)
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 6),
          child: Panel(
            radius: 12,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 9),
            child: Row(children: [
              Expanded(child: Text('${l.type == 'theory' ? 'نظري' : 'عملي'} ${l.number}', style: const TextStyle(fontSize: 13))),
              Text(friendlyDate(l.businessDate), style: TextStyle(fontSize: 13, color: t.textSecondary)),
            ]),
          ),
        ),
      const SizedBox(height: 10),
      const Text('الدفعات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      if (d.payments.isEmpty) Text('لسا ما في دفعات', style: TextStyle(fontSize: 13, color: t.textSecondary)),
      for (final p in d.payments)
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 8),
          child: Panel(
            radius: 14,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  MoneyText(Money(p.amount), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(
                    [friendlyDate(p.businessDate), _purpose[p.purpose] ?? '', if (p.receiptNo != null) 'وصل ${p.receiptNo}', if (p.reversed) 'مرجّعة'].where((x) => x.isNotEmpty).join(' · '),
                    style: TextStyle(fontSize: 12, color: t.textSecondary),
                  ),
                ]),
              ),
              AppButton('الوصل', icon: Icons.download_rounded, height: 44, kind: AppButtonKind.outline, onPressed: () {
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ReceiptScreen(paymentId: p.id)));
              }),
            ]),
          ),
        ),
    ];
  }

  Widget _money(String label, Money m) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFFD5ECEB))),
          MoneyText(m, color: Colors.white, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
      );
}
