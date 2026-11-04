/// Permission task keys and their dependencies.
/// MUST stay identical to functions/src/core/permissions.ts (server is the real gate).
const Map<String, List<String>> taskNeeds = {
  'students': [],
  'addStudent': ['students'],
  'editStudent': ['students'],
  'lesson': ['students'],
  'editLesson': ['lesson'],
  'exam': ['students'],
  'seeMoney': ['students'],
  'addPay': ['students', 'seeMoney'],
  'editPay': ['addPay'],
  'discount': ['seeMoney'],
  'addExp': [],
  'seeExp': [],
  'editExp': ['seeExp'],
  'closeDay': [],
  'seeBal': [],
  'moveMoney': ['seeBal'],
  'cashbook': [],
  'reopen': ['closeDay'],
  'payroll': [],
  'advance': ['payroll'],
  'dedBon': ['payroll'],
  'paySalary': ['payroll'],
  'reports': [],
  'export': ['reports'],
  'lockMonth': ['reports'],
  'log': [],
  'users': [],
  'settings': [],
  'archive': [],
  'backdate': [],
};

/// Turning a task on also turns on everything it needs (transitively).
Map<String, bool> withDependencies(Map<String, bool> tasks) {
  final out = Map<String, bool>.of(tasks);
  var changed = true;
  while (changed) {
    changed = false;
    for (final entry in out.entries.toList()) {
      if (entry.value != true) continue;
      for (final need in taskNeeds[entry.key] ?? const <String>[]) {
        if (out[need] != true) {
          out[need] = true;
          changed = true;
        }
      }
    }
  }
  return out;
}

/// Turning a task off also turns off every task that depends on it (transitively).
Map<String, bool> withoutDependents(Map<String, bool> tasks, String off) {
  final out = Map<String, bool>.of(tasks)..[off] = false;
  var changed = true;
  while (changed) {
    changed = false;
    for (final entry in taskNeeds.entries) {
      if (out[entry.key] == true && entry.value.any((n) => out[n] != true)) {
        out[entry.key] = false;
        changed = true;
      }
    }
  }
  return out;
}

/// Tasks that were switched as a side effect, for the "also turned on/off" message.
List<String> sideEffects(Map<String, bool> before, Map<String, bool> after, String touched) {
  return after.keys
      .where((k) => k != touched && (before[k] ?? false) != (after[k] ?? false))
      .toList()
    ..sort();
}

/// One checkbox on the Permissions screen: the task in plain words + where it shows in the app.
class TaskDef {
  const TaskDef(this.key, this.label, this.where);
  final String key;
  final String label;
  final String where;
}

/// Canvas Permissions groups (+ A6 tasks). Labels match functions/src/core/claims.ts TASK_LABEL.
const List<(String, List<TaskDef>)> taskGroups = [
  ('الطلاب والدروس', [
    TaskDef('students', 'رؤية الطلاب وملفاتهم', 'تبويب "الطلاب" وملف كل طالب'),
    TaskDef('addStudent', 'تسجيل طالب جديد', 'زر "طالب جديد" بالرئيسية'),
    TaskDef('editStudent', 'تعديل بيانات طالب', 'زر "تعديل" بملف الطالب'),
    TaskDef('lesson', 'تسجيل درس', 'زر الدرس بقائمة الطلاب وملف الطالب'),
    TaskDef('editLesson', 'تعديل درس أو أرشفته', 'من دروس الطالب'),
    TaskDef('exam', 'حجز اختبار وتأجيله وتسجيل النتيجة', 'شاشة الاختبارات'),
    TaskDef('archive', 'الأرشيف والاسترجاع', 'المزيد ← الأرشيف والخرّيجون'),
  ]),
  ('الدفعات من الطلاب', [
    TaskDef('seeMoney', 'رؤية حسابات الطلاب (عليه، دفع)', 'المبالغ بملف الطالب وقائمة الطلاب'),
    TaskDef('addPay', 'تسجيل دفعة من طالب', 'زر "دفعة" بالرئيسية وملف الطالب'),
    TaskDef('editPay', 'تعديل دفعة أو إرجاعها', 'من تفاصيل الدفعة · بتنسجّل بالسجل'),
    TaskDef('discount', 'إعطاء خصم', 'من ملف الطالب'),
  ]),
  ('المصاريف', [
    TaskDef('addExp', 'تسجيل مصروف', 'زر "مصروف" بالرئيسية'),
    TaskDef('seeExp', 'رؤية كل المصاريف', 'شاشة المصروفات'),
    TaskDef('editExp', 'تعديل مصروف أو أرشفته', 'من تفاصيل المصروف'),
  ]),
  ('الصناديق وإغلاق اليوم', [
    TaskDef('closeDay', 'عدّ الصندوق وإغلاق اليوم', 'زر "إغلاق اليوم" بالرئيسية'),
    TaskDef('seeBal', 'رؤية أرصدة الصناديق', 'شاشة الصناديق، والأرصدة جنب أسماء الصناديق'),
    TaskDef('moveMoney', 'شحن وسحب وتحويل بين الصناديق', 'شاشة الصناديق'),
    TaskDef('cashbook', 'رؤية الوارد والصادر', 'تبويب "المال"'),
    TaskDef('reopen', 'إعادة فتح يوم مسكّر', 'سجلات المطابقة'),
    TaskDef('backdate', 'تسجيل بتاريخ قديم', 'التاريخ بشاشات الدفعة والمصروف'),
  ]),
  ('الرواتب', [
    TaskDef('payroll', 'رؤية الرواتب', 'تبويب الرواتب'),
    TaskDef('advance', 'تسجيل سلفة لموظف', 'الرواتب وكشف الموظف'),
    TaskDef('dedBon', 'خصم أو مكافأة لموظف', 'كشف الموظف'),
    TaskDef('paySalary', 'صرف الرواتب', 'زر "صرف" بالرواتب'),
  ]),
  ('التقارير والإدارة', [
    TaskDef('reports', 'رؤية التقارير المالية', 'تبويب "التقارير"'),
    TaskDef('export', 'تصدير Excel و PDF', 'أزرار التصدير'),
    TaskDef('lockMonth', 'تثبيت الشهر', 'التقارير'),
    TaskDef('log', 'رؤية سجل العمليات', 'المزيد ← سجل العمليات'),
    TaskDef('users', 'إدارة المستخدمين والصلاحيات', 'المزيد ← المستخدمون'),
    TaskDef('settings', 'تعديل الإعدادات والأسعار', 'المزيد ← الإعدادات'),
  ]),
];

String taskLabel(String key) {
  for (final (_, items) in taskGroups) {
    for (final d in items) {
      if (d.key == key) return d.label;
    }
  }
  return key;
}

/// Ready-made jobs (canvas Permissions). MUST match functions/src/core/claims.ts JOB_TASKS.
const Map<String, (String, List<String>)> jobTemplates = {
  'accountant': ('محاسب', ['students', 'seeMoney', 'addPay', 'addExp', 'closeDay', 'cashbook', 'log', 'backdate']), // A5: up to 2 days back
  'secretary': ('سكرتاريا', ['students', 'addStudent', 'editStudent', 'exam', 'seeMoney', 'addPay']),
  'instructor': ('مدرب', ['students', 'lesson']),
  'manager': ('مدير', []), // every task
};

Map<String, bool> jobTasks(String job) {
  if (job == 'manager') return {for (final k in taskNeeds.keys) k: true};
  final on = jobTemplates[job]?.$2 ?? const <String>[];
  return {for (final k in taskNeeds.keys) k: on.contains(k)};
}
