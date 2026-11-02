import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_scope.dart';
import '../../core/auth/login_email.dart';
import '../../core/db/database.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../core/util/dates.dart';
import '../../data/queries.dart';
import '../exams/exam_sheets.dart';

/// Canvas: EditStudent — shows exactly what will be written to the activity log before saving.
class EditStudentScreen extends StatefulWidget {
  const EditStudentScreen({super.key, required this.studentId});
  final String studentId;

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  StudentRow? _orig;
  String _fixed = '';
  List<StudentCard> _active = const [];
  final _name = TextEditingController();
  final _nid = TextEditingController();
  final _phone = TextEditingController();
  final _reason = TextEditingController();
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_orig == null) _load();
  }

  Future<void> _load() async {
    final app = AppScope.of(context);
    final db = app.db;
    final s = await (db.select(db.students)..where((t) => t.id.equals(widget.studentId))).getSingle();
    final cards = await app.queries.enrollmentsOf(widget.studentId);
    if (!mounted) return;
    setState(() {
      _orig = s;
      _name.text = s.name;
      _nid.text = s.nationalId;
      _phone.text = s.phone ?? '';
      _fixed = cards.map((c) => 'السيارة: ${c.carName} · الرخصة: ${c.licenseName}').join('\n');
      _active = cards.where((c) => c.canLesson).toList();
    });
  }

  @override
  void dispose() {
    for (final c in [_name, _nid, _phone, _reason]) {
      c.dispose();
    }
    super.dispose();
  }

  List<(String, String, String)> get _changes {
    final o = _orig;
    if (o == null) return const [];
    return [
      if (_name.text.trim() != o.name) ('الاسم', o.name, _name.text.trim()),
      if (_nid.text.trim() != o.nationalId) ('رقم الهوية', o.nationalId, _nid.text.trim()),
      if (_phone.text.trim() != (o.phone ?? '')) ('الجوال', o.phone ?? '—', _phone.text.trim().isEmpty ? '—' : _phone.text.trim()),
    ];
  }

  bool get _valid => _name.text.trim().length >= 2 && isValidNationalId(_nid.text);

  Future<void> _save() async {
    final app = AppScope.of(context);
    setState(() => _busy = true);
    try {
      await app.editStudent(widget.studentId,
          name: _name.text.trim(), nationalId: _nid.text.trim(), phone: _phone.text.trim(), reason: _reason.text.trim());
      app.syncSoon();
      if (!mounted) return;
      final count = _changes.length;
      final nav = Navigator.of(context);
      nav.pop();
      showUndoSnack(nav.context, 'انحفظ $count تغيير · بيبين بسجل العمليات');
    } catch (e) {
      if (mounted) showErrorSnack(context, '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    final o = _orig;
    final changes = _changes;
    final now = hhmm(DateTime.now());
    Widget field(String label, TextEditingController c, String? was, {TextInputType? type, List<TextInputFormatter>? fmt}) {
      final changed = was != null;
      return Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            if (changed) Text('كان: $was', style: TextStyle(fontSize: 12, color: t.debt)),
          ]),
          const SizedBox(height: 4),
          TextField(
            controller: c,
            keyboardType: type,
            inputFormatters: fmt,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: changed ? t.accent : t.border, width: changed ? 2 : 1),
              ),
            ),
          ),
        ]),
      );
    }

    String? was(String label) => changes.where((c) => c.$1 == label).map((c) => c.$2).firstOrNull;
    return Scaffold(
      body: SafeArea(
        child: o == null
            ? const Padding(padding: EdgeInsetsDirectional.all(16), child: SkeletonCards(count: 3))
            : Column(children: [
                Expanded(
                  child: ListView(padding: const EdgeInsetsDirectional.all(16), children: [
                    BackHeader(title: 'تعديل بيانات ${o.name.split(' ').first}'),
                    const SizedBox(height: 12),
                    Panel(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        field('الاسم', _name, was('الاسم')),
                        field('رقم الهوية', _nid, was('رقم الهوية'),
                            type: TextInputType.number, fmt: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)]),
                        field('الجوال', _phone, was('الجوال'), type: TextInputType.phone),
                        Container(
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(color: t.bg, borderRadius: BorderRadius.circular(10)),
                          child: Row(children: [
                            Expanded(child: Text(_fixed, style: const TextStyle(fontSize: 13))),
                            Text('ثابتين لهالتسجيل', style: TextStyle(fontSize: 12, color: t.textSecondary)),
                          ]),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: changes.isEmpty ? t.card : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: t.textSecondary.withValues(alpha: 0.6)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('رح ينسجّل بسجل العمليات:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF14211F))),
                        const SizedBox(height: 4),
                        if (changes.isEmpty)
                          Text('ما في تغيير لسا', style: TextStyle(fontSize: 13, color: t.textSecondary))
                        else
                          for (final c in changes)
                            Text('تغيير ${c.$1} ل${o.name} من ${c.$2} إلى ${c.$3} · بواسطة ${app.user.name} · اليوم $now',
                                style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF14211F))),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    const Text('سبب التعديل (اختياري)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    TextField(controller: _reason, decoration: const InputDecoration(hintText: 'مثلًا: تغيّر رقم الجوال')),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                  child: AppButton(
                    changes.isEmpty ? 'ما في تغيير' : 'حفظ ${changes.length} تغيير',
                    height: 54,
                    expand: true,
                    busy: _busy,
                    onPressed: changes.isEmpty || !_valid ? null : _save,
                  ),
                ),
                for (final c in _active)
                  AppButton('انسحاب الطالب من ${c.licenseName}', kind: AppButtonKind.danger, height: 44, onPressed: () async {
                    final done = await showWithdraw(context, c);
                    if (done == true && context.mounted) Navigator.of(context).pop();
                  }),
                const SizedBox(height: 8),
              ]),
      ),
    );
  }
}
