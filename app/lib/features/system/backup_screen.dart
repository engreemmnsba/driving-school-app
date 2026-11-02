import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/db/database.dart';
import '../../core/export/csv_export.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/period.dart';
import '../../data/queries.dart';

const _kindAr = {'cars': 'سيارات', 'ministry': 'وزارة', 'other': 'أخرى'};
const _purposeAr = {'lessons': 'دروس', 'registration': 'تسجيل', 'exam': 'اختبار', 'general': 'عام'};
const _moveAr = {
  'student_payment': 'دفعة طالب',
  'expense': 'مصروف',
  'expense_reversal': 'إلغاء مصروف',
  'advance': 'سلفة',
  'salary': 'راتب',
  'top_up': 'شحن',
  'withdraw': 'سحب',
  'transfer_in': 'تحويل داخل',
  'transfer_out': 'تحويل خارج',
};

/// Builds the Excel (CSV) tables from this phone's data. [p] = only that period (null = everything on the phone).
Future<List<CsvTable>> exportTables(AppDatabase db, {Period? p, Set<String> only = const {}}) async {
  bool inP(String d) => p == null || p.contains(d);
  bool want(String k) => only.isEmpty || only.contains(k);
  final suffix = p == null ? 'كامل' : '${p.from}_${p.to}';
  final accounts = {for (final a in await db.select(db.treasuryAccounts).get()) a.id: a.name};
  final cars = {for (final c in await db.select(db.cars).get()) c.id: c.name};
  final emps = {for (final e in await db.select(db.employees).get()) e.id: e.name};
  final lts = {for (final l in await db.select(db.licenseTypes).get()) l.id: l.name};
  final enrollments = await db.select(db.enrollments).get();
  final enrById = {for (final e in enrollments) e.id: e};
  final out = <CsvTable>[];

  if (want('students')) {
    final cards = await Queries(db).studentCards();
    out.add(CsvTable('الطلاب_$suffix.csv', ['الاسم', 'رقم الهوية', 'الجوال', 'الرخصة', 'السيارة', 'المرحلة', 'التسجيل', 'المحسوب', 'المدفوع', 'الخصم', 'المتبقي'], [
      for (final c in cards)
        [c.name, c.student?.nationalId, c.student?.phone, c.licenseName, c.carName, stageLabel(c.stage), c.enrollment.registeredOn, shekels(c.balance.charged.agorot), shekels(c.balance.paid.agorot), shekels(c.balance.discounts.agorot), shekels(c.remaining.agorot)],
    ]));
  }
  if (want('payments')) {
    final rows = await (db.select(db.ledgerEntries)..where((t) => t.kind.isIn(['payment', 'reversal', 'discount']))).get();
    out.add(CsvTable('الدفعات_$suffix.csv', ['التاريخ', 'الطالب', 'النوع', 'المبلغ', 'الغرض', 'الصندوق', 'الوصل', 'مرجّعة', 'الحالة'], [
      for (final r in rows.where((r) => inP(r.businessDate)))
        [
          r.businessDate,
          enrById[r.enrollmentId]?.studentName,
          switch (r.kind) { 'payment' => 'دفعة', 'reversal' => 'إرجاع دفعة', _ => 'خصم' },
          shekels(r.amount),
          _purposeAr[r.purpose] ?? '',
          accounts[r.accountId] ?? '',
          r.receiptNo,
          r.reversed ? 'نعم' : '',
          r.syncState == 'synced' ? 'بالسيرفر' : r.syncState == 'pending' ? 'لسا' : 'مرفوضة',
        ],
    ]));
  }
  if (want('expenses')) {
    final rows = await db.select(db.expenses).get();
    out.add(CsvTable('المصروفات_$suffix.csv', ['التاريخ', 'النوع', 'البند', 'المبلغ', 'الصندوق', 'السيارة', 'لترات', 'ملغي', 'ملاحظة'], [
      for (final e in rows.where((e) => inP(e.businessDate)))
        [e.businessDate, _kindAr[e.kind] ?? e.kind, e.label, shekels(e.amount), accounts[e.accountId] ?? '', cars[e.carId] ?? '', e.liters, e.reversed ? 'نعم' : '', e.note],
    ]));
  }
  if (want('movements')) {
    final rows = await db.select(db.treasuryMovements).get();
    rows.sort((a, b) => a.businessDate.compareTo(b.businessDate));
    out.add(CsvTable('حركات_الصناديق_$suffix.csv', ['التاريخ', 'الصندوق', 'داخل', 'طالع', 'النوع', 'ملاحظة'], [
      for (final m in rows.where((m) => inP(m.businessDate) && m.syncState != 'rejected'))
        [m.businessDate, accounts[m.accountId] ?? m.accountId, m.direction == 'in' ? shekels(m.amount) : '', m.direction == 'out' ? shekels(m.amount) : '', _moveAr[m.kind] ?? m.kind, m.note],
    ]));
  }
  if (want('lessons')) {
    final rows = await db.select(db.lessons).get();
    out.add(CsvTable('الدروس_$suffix.csv', ['التاريخ', 'الطالب', 'النوع', 'الرقم', 'المدرب', 'السيارة', 'بدون تشغيل', 'ملغي'], [
      for (final l in rows.where((l) => inP(l.businessDate)))
        [l.businessDate, enrById[l.enrollmentId]?.studentName, l.type == 'theory' ? 'نظري' : 'عملي', l.number, emps[l.employeeId] ?? '', cars[l.carId] ?? '', l.withoutDriving ? 'نعم' : '', l.archived ? 'نعم' : ''],
    ]));
  }
  if (want('payroll')) {
    final pays = await db.select(db.salaryPayments).get();
    final items = await db.select(db.payrollItems).get();
    out.add(CsvTable('الرواتب_$suffix.csv', ['تاريخ الحركة', 'الموظف', 'شهر الراتب', 'النوع', 'المبلغ', 'الراتب', 'مكافآت', 'خصومات', 'سلف', 'الصندوق', 'السبب'], [
      for (final x in pays.where((x) => inP(x.businessDate)))
        [x.businessDate, x.employeeName, x.payrollMonth, 'صرف راتب', shekels(x.net), shekels(x.salaryAtMonth), shekels(x.bonuses), shekels(x.deductions), shekels(x.advances), accounts[x.accountId] ?? '', x.early ? 'قبل الموعد' : ''],
      for (final i in items.where((i) => inP(i.businessDate)))
        [i.businessDate, i.employeeName, i.payrollMonth, switch (i.kind) { 'advance' => 'سلفة', 'deduction' => 'خصم', _ => 'مكافأة' }, shekels(i.amount), '', '', '', '', accounts[i.accountId] ?? '', i.reason],
    ]));
  }
  if (want('licenses')) {
    final prices = await db.select(db.licensePrices).get();
    out.add(CsvTable('الأسعار_$suffix.csv', ['الرخصة', 'من تاريخ', 'التسجيل', 'الدرس العملي', 'إعادة النظري', 'الاختبار العملي', 'نظري مخطط', 'عملي مخطط'], [
      for (final p in prices)
        [lts[p.licenseTypeId] ?? '', p.effectiveFrom, shekels(p.registrationFee), shekels(p.practicalLessonPrice), shekels(p.theoryRetakeFee), shekels(p.practicalExamFee), p.plannedTheoryLessons, p.plannedPracticalLessons],
    ]));
  }
  return out;
}

/// "النسخ الاحتياطي": export everything on this phone to Excel files now. Automatic daily backups run on the
/// server once the project is on Blaze (A10).
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _busy = false;

  Future<void> _export() async {
    final app = AppScope.of(context);
    setState(() => _busy = true);
    try {
      final tables = await exportTables(app.db);
      await shareCsv(tables, text: 'نسخة من بيانات مدرسة القيادة');
    } catch (e) {
      if (mounted) showErrorSnack(context, 'ما انعملت النسخة: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
          children: [
            const BackHeader(title: 'النسخ الاحتياطي'),
            const SizedBox(height: 14),
            Panel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('نسخة Excel هلأ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('ملفات للطلاب، الدفعات، المصروفات، حركات الصناديق، الدروس، الرواتب والأسعار. بتنحفظ على Drive أو بتنبعت على الإيميل أو واتساب.',
                    style: TextStyle(fontSize: 13, color: t.textSecondary, height: 1.6)),
                const SizedBox(height: 12),
                AppButton('تصدير كل البيانات', icon: Icons.ios_share_rounded, height: 52, expand: true, busy: _busy, onPressed: _export),
              ]),
            ),
            const SizedBox(height: 12),
            Panel(
              color: t.tonalBg,
              child: Text(
                'النسخة اليومية التلقائية (من السيرفر لـ Drive والإيميل) بتشتغل لما يتفعّل الدفع بمشروع Firebase. لحد هداك الوقت، البيانات محفوظة على السيرفر وعلى الجوالات، والتصدير من هون بأي وقت.',
                style: TextStyle(fontSize: 13, color: t.info, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
