import type { UserPermissions } from './types.js';

/** Plain-language labels of the permission tasks (activity log lines, same words as the Permissions screen). */
export const TASK_LABEL: Record<string, string> = {
  students: 'رؤية الطلاب وملفاتهم',
  addStudent: 'تسجيل طالب جديد',
  editStudent: 'تعديل بيانات طالب',
  lesson: 'تسجيل درس',
  editLesson: 'تعديل درس أو أرشفته',
  exam: 'حجز اختبار وتأجيله وتسجيل النتيجة',
  seeMoney: 'رؤية حسابات الطلاب',
  addPay: 'تسجيل دفعة من طالب',
  editPay: 'تعديل دفعة أو إرجاعها',
  discount: 'إعطاء خصم',
  addExp: 'تسجيل مصروف',
  seeExp: 'رؤية كل المصاريف',
  editExp: 'تعديل مصروف أو أرشفته',
  closeDay: 'عدّ الصندوق وإغلاق اليوم',
  seeBal: 'رؤية أرصدة الصناديق',
  moveMoney: 'شحن وسحب وتحويل بين الصناديق',
  cashbook: 'رؤية الوارد والصادر',
  reopen: 'إعادة فتح يوم مسكّر',
  payroll: 'رؤية الرواتب',
  advance: 'تسجيل سلفة لموظف',
  dedBon: 'خصم أو مكافأة لموظف',
  paySalary: 'صرف الرواتب',
  reports: 'رؤية التقارير المالية',
  export: 'تصدير Excel و PDF',
  lockMonth: 'تثبيت الشهر',
  log: 'رؤية سجل العمليات',
  users: 'إدارة المستخدمين والصلاحيات',
  settings: 'تعديل الإعدادات والأسعار',
  archive: 'الأرشيف والاسترجاع',
  backdate: 'تسجيل بتاريخ قديم',
};

/** Ready-made jobs (canvas Permissions). Must match app/lib/core/domain/permissions.dart `jobTemplates`. */
export const JOB_TASKS: Record<string, string[]> = {
  accountant: ['students', 'seeMoney', 'addPay', 'addExp', 'closeDay', 'cashbook', 'log'],
  secretary: ['students', 'addStudent', 'editStudent', 'exam', 'seeMoney', 'addPay'],
  instructor: ['students', 'lesson'],
  manager: Object.keys(TASK_LABEL),
};

/**
 * Starting permissions for a new staff member. Accounts follow the permissions (Reem 2026-10-26):
 * a job starts on the cash account(s) only; the Admin widens it on the Permissions screen.
 */
export function jobPermissions(job: string, cashAccountIds: string[]): UserPermissions {
  const tasks = Object.fromEntries((JOB_TASKS[job] ?? []).map((k) => [k, true]));
  return {
    tasks,
    allowedAccounts: job === 'manager' ? 'all' : cashAccountIds,
    expenseCategories: job === 'manager' ? 'all' : ['cars', 'ministry', 'other'],
    discountMax: job === 'manager' ? null : 0,
    closeMode: job === 'manager' ? 'full' : 'blind',
    logScope: job === 'manager' ? 'all' : 'own',
    backdateDays: 0,
  };
}

/**
 * Custom claims read by firestore.rules (what a device may pull). Recomputed on every
 * user.create / user.permissions / car.instructor change; permVersion lets the app notice.
 */
export function claimsFor(
  schoolId: string,
  u: { kind: string; permissions: UserPermissions; permVersion: number; studentId?: string },
  carIds: string[],
): Record<string, unknown> {
  if (u.kind === 'admin') return { schoolId, kind: 'admin', permVersion: u.permVersion };
  if (u.kind === 'student') return { schoolId, kind: 'student', studentId: u.studentId, permVersion: u.permVersion };
  const t = u.permissions.tasks ?? {};
  const claims: Record<string, unknown> = {
    schoolId,
    kind: u.kind,
    permVersion: u.permVersion,
    money: t.seeMoney === true,
    balances: t.seeBal === true,
    payroll: t.payroll === true,
    exp: t.seeExp === true || t.addExp === true,
    close: t.closeDay === true,
    users: t.users === true,
    cashbook: t.cashbook === true ? 'all' : t.seeMoney === true || t.closeDay === true ? 'today' : 'none',
    log: t.log === true ? (u.permissions.logScope ?? 'own') : 'none',
  };
  if (u.kind === 'instructor') claims.carIds = carIds;
  return claims;
}
