import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../data/queries.dart';
import '../../data/settings_queries.dart';
import '../staff/cars_screen.dart';
import '../staff/users_screen.dart';
import 'accounts_screen.dart';
import 'license_settings_screen.dart';
import 'settings_screen.dart';

/// Canvas Setup: the first-run checklist. Each step is "done" when its data exists (nothing to tick by hand).
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  Stream<List<SetupStep>>? _stream;

  Widget _page(String key) => switch (key) {
        'school' => const SettingsScreen(),
        'licenses' => const LicenseSettingsScreen(),
        'accounts' => const AccountsScreen(),
        'cars' => const CarsScreen(),
        _ => const UsersScreen(),
      };

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    _stream ??= watchLoad(app.db, app.settings.queries.setup);
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<SetupStep>>(
          stream: _stream,
          builder: (context, snap) {
            final steps = snap.data;
            if (steps == null) return const Padding(padding: EdgeInsetsDirectional.all(16), child: SkeletonCards(count: 5, height: 64));
            final done = steps.where((s) => s.done).length;
            final missing = steps.where((s) => s.required && !s.done).length;
            final next = steps.indexWhere((s) => !s.done);
            return ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
              children: [
                const BackHeader(title: 'تجهيز المدرسة'),
                const SizedBox(height: 10),
                Text(missing == 0 ? 'كل الأساسيات جاهزة · صار ممكن تسجيل الطلاب' : missing == 1 ? 'قبل تسجيل أول طالب، في خطوة أساسية وحدة' : 'قبل تسجيل أول طالب، في $missing خطوات أساسية',
                    style: TextStyle(fontSize: 14, color: t.textSecondary, height: 1.6)),
                const SizedBox(height: 10),
                ProgressLine(done / steps.length, height: 10),
                const SizedBox(height: 14),
                for (final (i, s) in steps.indexed)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 10),
                    child: Panel(
                      radius: 14,
                      border: Border.all(color: i == next ? t.primary : t.card, width: 2),
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 12),
                      child: Row(children: [
                        Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: s.done ? t.moneyBg : i == next ? t.primary : t.divider),
                          child: Text(s.done ? '✓' : '${i + 1}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: s.done ? t.money : i == next ? t.onPrimary : t.textSecondary)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(s.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            Text(s.note, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                          ]),
                        ),
                        AppButton(
                          s.done ? 'تعديل' : i == next ? 'بدء' : (s.required ? 'فتح' : 'لاحقًا'),
                          height: 44,
                          kind: i == next ? AppButtonKind.accent : AppButtonKind.outline,
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _page(s.key))),
                        ),
                      ]),
                    ),
                  ),
                const SizedBox(height: 6),
                Text('كل هالإشي بيتعدّل بعدين من الإعدادات', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: t.textSecondary)),
              ],
            );
          },
        ),
      ),
    );
  }
}
