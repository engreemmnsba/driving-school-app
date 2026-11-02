import 'dart:convert';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// One table for Excel: UTF-8 with BOM so Arabic opens correctly; cells quoted when needed.
class CsvTable {
  CsvTable(this.fileName, this.header, this.rows);
  final String fileName;
  final List<String> header;
  final List<List<Object?>> rows;

  static String _cell(Object? v) {
    final s = v == null ? '' : '$v';
    return s.contains(RegExp(r'[",\n\r]')) ? '"${s.replaceAll('"', '""')}"' : s;
  }

  Uint8List bytes() {
    final b = StringBuffer('﻿');
    b.writeln(header.map(_cell).join(','));
    for (final r in rows) {
      b.writeln(r.map(_cell).join(','));
    }
    return Uint8List.fromList(utf8.encode(b.toString()));
  }
}

/// Amounts in shekels with 2 decimals (Excel sums them as numbers).
String shekels(int agorot) => (agorot / 100).toStringAsFixed(2);

/// Opens the share sheet with one or more CSV files (on the web they download).
Future<void> shareCsv(List<CsvTable> tables, {String? text}) => SharePlus.instance.share(ShareParams(
      files: [for (final t in tables) XFile.fromData(t.bytes(), name: t.fileName, mimeType: 'text/csv')],
      text: text,
      fileNameOverrides: [for (final t in tables) t.fileName],
    ));
