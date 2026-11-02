import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Arabic PDFs (reports, receipts): the app font embedded, right-to-left pages, always light.
class PdfKit {
  PdfKit._(this.regular, this.bold);
  final pw.Font regular;
  final pw.Font bold;

  static PdfKit? _cached;

  static Future<PdfKit> load() async {
    final c = _cached;
    if (c != null) return c;
    final r = pw.Font.ttf(await rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf'));
    final b = pw.Font.ttf(await rootBundle.load('assets/fonts/IBMPlexSansArabic-Bold.ttf'));
    return _cached = PdfKit._(r, b);
  }

  static const ink = PdfColor.fromInt(0xFF14211F);
  static const muted = PdfColor.fromInt(0xFF55625F);
  static const primary = PdfColor.fromInt(0xFF0E5A5F);
  static const tonal = PdfColor.fromInt(0xFFE1EEED);
  static const line = PdfColor.fromInt(0xFFDDE3E1);
  static const green = PdfColor.fromInt(0xFF1E6B3E);
  static const amber = PdfColor.fromInt(0xFFB54708);

  pw.Document document() => pw.Document(theme: pw.ThemeData.withFont(base: regular, bold: bold));

  pw.TextStyle style({double size = 11, bool strong = false, PdfColor color = ink}) =>
      pw.TextStyle(fontSize: size, fontWeight: strong ? pw.FontWeight.bold : pw.FontWeight.normal, color: color);

  /// Amounts are laid out left-to-right so "₪300" never flips.
  pw.Widget money(String text, {double size = 11, bool strong = false, PdfColor color = ink}) =>
      pw.Text(text, textDirection: pw.TextDirection.ltr, style: style(size: size, strong: strong, color: color));

  pw.Widget header(String school, String title, String subtitle) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 10),
        margin: const pw.EdgeInsets.only(bottom: 14),
        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: primary, width: 2))),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(school, style: style(size: 16, strong: true)),
              pw.Text(title, style: style(size: 13, strong: true, color: primary)),
            ]),
          ),
          pw.Text(subtitle, style: style(size: 10, color: muted)),
        ]),
      );

  /// A two-column "label ……… value" row.
  pw.Widget row(String label, String value, {bool strong = false, PdfColor color = ink, bool isMoney = true}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(children: [
          pw.Expanded(child: pw.Text(label, style: style(strong: strong))),
          isMoney ? money(value, strong: strong, color: color) : pw.Text(value, style: style(strong: strong, color: color)),
        ]),
      );

  pw.Widget section(String title, List<pw.Widget> children) => pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 12),
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(border: pw.Border.all(color: line), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
          pw.Text(title, style: style(size: 12, strong: true)),
          pw.SizedBox(height: 6),
          ...children,
        ]),
      );

  pw.Page page(List<pw.Widget> Function(pw.Context) build, {PdfPageFormat format = PdfPageFormat.a4}) => pw.MultiPage(
        pageFormat: format,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(28),
        build: build,
        footer: (c) => pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text('${c.pageNumber} / ${c.pagesCount}', style: style(size: 9, color: muted)),
        ),
      );
}

/// Opens the phone's share sheet (WhatsApp, Drive, email…) with the PDF.
Future<void> sharePdf(Uint8List bytes, String filename) => Printing.sharePdf(bytes: bytes, filename: filename);

/// Opens the print dialog (or "save as PDF" where there is no printer).
Future<void> printPdf(Uint8List bytes, String name) => Printing.layoutPdf(onLayout: (_) async => bytes, name: name);
