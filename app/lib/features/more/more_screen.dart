import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../exams/archive_screen.dart';
import '../exams/exams_screen.dart';
import '../money/recon_log_screen.dart';
import '../oversight/activity_log_screen.dart';
import '../oversight/notifications_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/setup_screen.dart';
import '../staff/car_report_screen.dart';
import '../system/backup_screen.dart';
import '../system/update_screen.dart';
import '../staff/cars_screen.dart';
import '../staff/instructor_screen.dart';
import '../staff/users_screen.dart';

class _Item {
  const _Item(this.label, this.batch, {this.task});
  final String label;
  final String batch;
  final String? task;
}

/// Canvas: More — every other screen, grouped. Items appear only with the matching permission.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _built = {'سجلات المطابقة', 'الاختبارات', 'الأرشيف والخرّيجون', 'تقرير السيارات', 'السيارات والمدربون', 'أداء المدربين', 'المستخدمون والصلاحيات', 'الإشعارات', 'سجل العمليات', 'تجهيز المدرسة', 'الإعدادات والرخص', 'النسخ الاحتياطي', 'تحديث التطبيق'};

  static const _groups = [
    ('المتابعة', [
      _Item('سجلات المطابقة', 'الدفعة 2 (المال)', task: 'closeDay'),
      _Item('الإشعارات', 'الدفعة 5 (المتابعة)'),
      _Item('الاختبارات', 'الدفعة 3 (الاختبارات)', task: 'exam'),
      _Item('سجل العمليات', 'الدفعة 5 (المتابعة)', task: 'log'),
      _Item('تقرير السيارات', 'الدفعة 4 (الموظفين)', task: 'reports'),
      _Item('السيارات والمدربون', 'الدفعة 4 (الموظفين)', task: 'settings'),
      _Item('أداء المدربين', 'الدفعة 4 (الموظفين)', task: 'reports'),
    ]),
    ('الطلاب القدام', [_Item('الأرشيف والخرّيجون', 'الدفعة 3 (الاختبارات)', task: 'archive')]),
    ('الإدارة', [
      _Item('تجهيز المدرسة', 'الدفعة 6 (الإعدادات)', task: 'settings'),
      _Item('الإعدادات والرخص', 'الدفعة 6 (الإعدادات)', task: 'settings'),
      _Item('المستخدمون والصلاحيات', 'الدفعة 4 (الموظفين)', task: 'users'),
      _Item('النسخ الاحتياطي', 'الدفعة 8 (النظام)', task: 'export'),
      _Item('تحديث التطبيق', 'الدفعة 8 (النظام)'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 16),
          children: [
            const Text('المزيد', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            for (final (title, items) in _groups)
              if (items.any((i) => i.task == null || app.user.can(i.task!)))
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 14),
                  child: Panel(
                    radius: 14,
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 4),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(top: 10, bottom: 4),
                        child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.textSecondary)),
                      ),
                      for (final i in items.where((i) => i.task == null || app.user.can(i.task!)))
                        InkWell(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                              builder: (_) => switch (i.label) {
                                    'سجلات المطابقة' => const ReconLogScreen(),
                                    'الاختبارات' => const ExamsScreen(),
                                    'الأرشيف والخرّيجون' => const ArchiveScreen(),
                                    'تقرير السيارات' => const CarReportScreen(),
                                    'الإشعارات' => const NotificationsScreen(),
                                    'تجهيز المدرسة' => const SetupScreen(),
                                    'النسخ الاحتياطي' => const BackupScreen(),
                                    'تحديث التطبيق' => const UpdateScreen(),
                                    'الإعدادات والرخص' => const SettingsScreen(),
                                    'سجل العمليات' => const ActivityLogScreen(),
                                    'السيارات والمدربون' => const CarsScreen(),
                                    'أداء المدربين' => const InstructorScreen(),
                                    'المستخدمون والصلاحيات' => const UsersScreen(),
                                    _ => ComingSoonScreen(title: i.label, batch: i.batch),
                                  })),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 52),
                            decoration: BoxDecoration(border: Border(top: BorderSide(color: t.divider))),
                            child: Row(children: [
                              Expanded(child: Text(i.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                              if (!_built.contains(i.label)) Pill('قريبًا', bg: t.divider, fg: t.textSecondary),
                              const SizedBox(width: 6),
                              Icon(Icons.chevron_right_rounded, color: t.textSecondary),
                            ]),
                          ),
                        ),
                    ]),
                  ),
                ),
            Panel(
              radius: 14,
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 4),
              child: InkWell(
                onTap: () async {
                  final pending = await app.outbox.watchPendingCount().first;
                  if (!context.mounted) return;
                  if (pending > 0) {
                    showErrorSnack(context, 'في $pending عمليات لسا ما وصلت للسيرفر · تسجيل الخروج بعد المزامنة');
                    app.syncSoon();
                    return;
                  }
                  await app.signOut();
                },
                child: SizedBox(
                  height: 52,
                  child: Row(children: [
                    Icon(Icons.logout_rounded, color: t.problem),
                    const SizedBox(width: 10),
                    Expanded(child: Text('تسجيل الخروج · ${app.user.name}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t.problem))),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
