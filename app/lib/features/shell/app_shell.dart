import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/ui/tokens.dart';
import '../home/home_screen.dart';
import '../money/money_screen.dart';
import '../more/more_screen.dart';
import '../oversight/reports_screen.dart';
import '../roles/instructor_home.dart';
import '../roles/student_home.dart';
import '../students/students_screen.dart';

/// Bottom navigation (canvas): الرئيسية · الطلاب · المال · التقارير · المزيد. Tabs keep their state.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.schoolName = 'مدرسة القيادة'});
  final String schoolName;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;
  String? _school;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // School name from Settings (falls back to the default until it syncs).
    AppScope.of(context).settings.queries.schoolName().then((n) {
      if (mounted && n != _school) setState(() => _school = n);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    // Other roles have their own homes (canvas InstructorHome / StudentHome).
    if (app.user.isInstructor) return const InstructorShell();
    if (app.user.isStudent) return const StudentHomeScreen();
    final tabs = <(String, IconData, IconData, Widget)>[
      ('الرئيسية', Icons.home_outlined, Icons.home_rounded, HomeScreen(schoolName: _school ?? widget.schoolName)),
      if (app.user.can('students')) ('الطلاب', Icons.groups_outlined, Icons.groups_rounded, const StudentsScreen()),
      if (app.user.can('seeMoney') || app.user.can('cashbook') || app.user.can('seeBal') || app.user.can('seeExp') || app.user.can('payroll'))
        ('المال', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, const MoneyScreen()),
      if (app.user.can('reports')) ('التقارير', Icons.bar_chart_outlined, Icons.bar_chart_rounded, const ReportsScreen()),
      ('المزيد', Icons.more_horiz_rounded, Icons.more_horiz_rounded, const MoreScreen()),
    ];
    final index = _tab.clamp(0, tabs.length - 1);
    return Scaffold(
      body: IndexedStack(index: index, children: [for (final tab in tabs) tab.$4]),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: t.card,
          indicatorColor: t.tonalBg,
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
                fontSize: 12,
                fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w400,
                color: s.contains(WidgetState.selected) ? t.primary : t.textSecondary,
              )),
          iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(color: s.contains(WidgetState.selected) ? t.primary : t.textSecondary)),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: t.border))),
          child: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: [for (final tab in tabs) NavigationDestination(icon: Icon(tab.$2), selectedIcon: Icon(tab.$3), label: tab.$1)],
          ),
        ),
      ),
    );
  }
}
