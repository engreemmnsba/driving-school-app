import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_scope.dart';
import '../../core/db/database.dart';
import '../../core/domain/ledger.dart';
import '../../core/domain/money.dart';
import '../../core/pdf/pdf_export.dart';
import '../../core/ui/money_text.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/arabic_words.dart';
import '../../core/util/dates.dart';
import 'record_payment.dart';

class _ReceiptData {
  const _ReceiptData(this.pay, this.student, this.enrollment, this.licenseName, this.accountName, this.balance, this.school);
  final String school;
  final LedgerRowData pay;
  final StudentRow? student;
  final EnrollmentRow enrollment;
  final String licenseName;
  final String accountName;
  final StudentBalance balance;
}

/// Canvas: Receipt — preview, then send on WhatsApp, share as PDF or print.
class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key, required this.paymentId, this.schoolName = 'مدرسة القيادة'});
  final String paymentId;
  final String schoolName;

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  Future<_ReceiptData>? _data;

  static const _purpose = {'lessons': 'دروس', 'registration': 'تسجيل', 'exam': 'اختبار', 'general': 'عام'};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data ??= _load();
  }

  Future<_ReceiptData> _load() async {
    final app = AppScope.of(context);
    final db = app.db;
    final pay = await (db.select(db.ledgerEntries)..where((t) => t.id.equals(widget.paymentId))).getSingle();
    final enr = await (db.select(db.enrollments)..where((t) => t.id.equals(pay.enrollmentId))).getSingle();
    final st = await (db.select(db.students)..where((t) => t.id.equals(pay.studentId))).getSingleOrNull();
    final lt = await (db.select(db.licenseTypes)..where((t) => t.id.equals(enr.licenseTypeId))).getSingleOrNull();
    final acc = pay.accountId == null ? null : await (db.select(db.treasuryAccounts)..where((t) => t.id.equals(pay.accountId!))).getSingleOrNull();
    final school = await app.settings.queries.schoolName();
    return _ReceiptData(pay, st, enr, lt?.name ?? '', acc?.name ?? '', await localBalance(db, enr.id), school);
  }

  static String _mask(String v) => v.length < 4 ? v : '${v.substring(0, 2)}${'•' * (v.length - 4)}${v.substring(v.length - 2)}';

  String _when(LedgerRowData p) {
    final at = DateTime.tryParse(p.at ?? '');
    final parts = p.businessDate.split('-');
    final date = parts.length == 3 ? '${parts[2]}/${parts[1]}/${parts[0]}' : p.businessDate;
    return at == null ? date : '$date · ${hhmm(at)}';
  }

  String _message(_ReceiptData d) {
    final p = d.pay;
    final b = d.balance;
    return [
      '${d.school} · وصل رقم ${p.receiptNo ?? ''}',
      'الطالب: ${d.enrollment.studentName} · ${d.licenseName}',
      'المبلغ المستلم: ${Money(p.amount).format()} (${_purpose[p.purpose] ?? ''} · ${d.accountName})',
      'المحسوب لحد اليوم: ${b.charged.format()}',
      if (!b.discounts.isZero) 'الخصم: ${b.discounts.format()}',
      'المدفوع: ${b.paid.format()}',
      b.remaining.isNegative ? 'رصيد للطالب: ${b.remaining.abs().format()}' : 'المتبقي: ${b.remaining.format()}',
      'التاريخ: ${_when(p)}',
    ].join('\n');
  }

  Future<void> _sendWhatsApp(_ReceiptData d) async {
    final phone = waPhone(d.student?.phone);
    final text = Uri.encodeComponent(_message(d));
    final uri = Uri.parse(phone == null ? 'https://wa.me/?text=$text' : 'https://wa.me/$phone?text=$text');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) showErrorSnack(context, 'ما انفتح واتساب على هالجهاز');
  }

  bool _busy = false;

  /// Same content as the card, as an A5 PDF (always light).
  Future<void> _pdf(_ReceiptData d, {required bool print}) async {
    setState(() => _busy = true);
    try {
      final k = await PdfKit.load();
      final p = d.pay;
      final b = d.balance;
      final doc = k.document();
      doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a5,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(24),
        build: (_) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
          k.header(d.school, 'وصل دفع', 'وصل رقم ${p.receiptNo ?? '—'}'),
          k.row('الطالب', d.enrollment.studentName, isMoney: false),
          k.row('رقم الهوية', d.student == null ? '—' : _mask(d.student!.nationalId)),
          k.row('التاريخ', _when(p)),
          k.row('الرخصة', d.licenseName, isMoney: false),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: const pw.BoxDecoration(color: PdfKit.tonal, borderRadius: pw.BorderRadius.all(pw.Radius.circular(8))),
            child: pw.Column(children: [
              pw.Text('المبلغ المستلم', style: k.style(size: 10, color: PdfKit.primary)),
              k.money(Money(p.amount).format(), size: 24, strong: true, color: PdfKit.primary),
              pw.Text('${shekelsInWords(p.amount ~/ 100)} · ${_purpose[p.purpose] ?? ''} · ${d.accountName}', style: k.style(size: 10, color: PdfKit.primary)),
            ]),
          ),
          pw.SizedBox(height: 10),
          k.row('المحسوب لحد اليوم', b.charged.format()),
          if (!b.discounts.isZero) k.row('الخصم', b.discounts.format()),
          k.row('المدفوع لحد هالوصل', b.paid.format()),
          pw.Divider(color: PdfKit.line),
          k.row(b.remaining.isNegative ? 'رصيد للطالب' : 'المتبقي', b.remaining.abs().format(), strong: true),
          pw.Spacer(),
          pw.Text('بيتحقق منه بالرقم بالتطبيق', style: k.style(size: 9, color: PdfKit.muted)),
        ]),
      ));
      final bytes = await doc.save();
      final name = 'وصل ${p.receiptNo ?? p.id}.pdf';
      if (print) {
        await printPdf(bytes, name);
      } else {
        await sharePdf(bytes, name);
      }
    } catch (e) {
      if (mounted) showErrorSnack(context, 'ما انعمل الـ PDF: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF3A4442);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: FutureBuilder<_ReceiptData>(
          future: _data,
          builder: (context, snap) {
            final d = snap.data;
            return ListView(
              padding: const EdgeInsetsDirectional.all(16),
              children: [
                const BackHeader(title: 'الوصل قبل الإرسال', dark: true),
                const SizedBox(height: 12),
                if (d == null)
                  const SkeletonCards(count: 1, height: 420)
                else ...[
                  // The receipt is always light (DECISIONS D11: receipts/PDF/print stay light).
                  Theme(data: Theme.of(context).copyWith(brightness: Brightness.light), child: _ReceiptCard(d: d, school: d.school, when: _when(d.pay), mask: _mask, purpose: _purpose)),
                  const SizedBox(height: 20),
                  AppButton('إرسال على واتساب للطالب', kind: AppButtonKind.success, height: 54, expand: true, icon: Icons.send_rounded, onPressed: () => _sendWhatsApp(d)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _DarkButton('مشاركة PDF', busy: _busy, onTap: () => _pdf(d, print: false))),
                    const SizedBox(width: 8),
                    Expanded(child: _DarkButton('طباعة', busy: _busy, onTap: () => _pdf(d, print: true))),
                  ]),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 0599123456 → 970599123456 (Palestine). Already international numbers are kept.
String? waPhone(String? phone) {
  if (phone == null) return null;
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  if (digits.startsWith('970') || digits.startsWith('972')) return digits;
  if (digits.startsWith('0')) return '970${digits.substring(1)}';
  return digits;
}

class _DarkButton extends StatelessWidget {
  const _DarkButton(this.label, {required this.busy, required this.onTap});
  final String label;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: busy ? null : onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF6B7673)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ),
      );
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.d, required this.school, required this.when, required this.mask, required this.purpose});
  final _ReceiptData d;
  final String school;
  final String when;
  final String Function(String) mask;
  final Map<String, String> purpose;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF14211F);
    const grey = Color(0xFF55625F);
    const teal = Color(0xFF0A4246);
    const primary = Color(0xFF0E5A5F);
    final p = d.pay;
    final b = d.balance;
    Widget field(String label, String value, {bool ltr = false}) => Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 12, color: grey)),
            Text(value, textDirection: ltr ? TextDirection.ltr : null, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
          ]),
        );
    Widget line(String label, Money m, {bool strong = false}) => Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 3),
          child: Row(children: [
            Expanded(child: Text(label, style: TextStyle(fontSize: strong ? 15 : 13, fontWeight: strong ? FontWeight.w700 : FontWeight.w400, color: ink))),
            MoneyText(m, color: ink, style: TextStyle(fontSize: strong ? 15 : 13, fontWeight: strong ? FontWeight.w700 : FontWeight.w600)),
          ]),
        );
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 20, 18, 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: ink),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsetsDirectional.only(bottom: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: primary, width: 2))),
            child: Row(children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.directions_car_filled_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(school, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ink))),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('وصل رقم', style: TextStyle(fontSize: 12, color: grey)),
                Text(p.receiptNo ?? '—', textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [field('الطالب', d.enrollment.studentName), field('رقم الهوية', d.student == null ? '—' : mask(d.student!.nationalId), ltr: true)]),
          const SizedBox(height: 10),
          Row(children: [field('التاريخ', when), field('الرخصة', d.licenseName)]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsetsDirectional.all(14),
            decoration: BoxDecoration(color: const Color(0xFFE1EEED), borderRadius: BorderRadius.circular(10)),
            child: Column(children: [
              const Text('المبلغ المستلم', style: TextStyle(fontSize: 12, color: teal)),
              MoneyText(Money(p.amount), color: teal, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              Text('${shekelsInWords(p.amount ~/ 100)} · ${purpose[p.purpose] ?? ''} · ${d.accountName}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: teal)),
            ]),
          ),
          const SizedBox(height: 12),
          line('المحسوب لحد اليوم', b.charged),
          if (!b.discounts.isZero) line('الخصم', b.discounts),
          line('المدفوع لحد هالوصل', b.paid),
          const Divider(color: Color(0xFFDDE3E1)),
          line(b.remaining.isNegative ? 'رصيد للطالب' : 'المتبقي', b.remaining.abs(), strong: true),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsetsDirectional.only(top: 10),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFCBD3D1)))),
            child: Text(p.syncState == 'synced' ? 'بيتحقق منه بالرقم بالتطبيق' : 'لسا ما وصل للسيرفر · رقمه ثابت',
                style: const TextStyle(fontSize: 12, color: grey)),
          ),
        ]),
      ),
    );
  }
}
