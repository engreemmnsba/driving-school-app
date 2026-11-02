import { Reject, type UserDoc } from './types.js';

/** Task keys and their dependencies — must match docs/02-permissions-matrix.md and the app. */
export const TASK_NEEDS: Record<string, string[]> = {
  students: [],
  addStudent: ['students'],
  editStudent: ['students'],
  lesson: ['students'],
  editLesson: ['lesson'],
  exam: ['students'],
  seeMoney: ['students'],
  addPay: ['students', 'seeMoney'],
  editPay: ['addPay'],
  discount: ['seeMoney'],
  addExp: [],
  seeExp: [],
  editExp: ['seeExp'],
  closeDay: [],
  seeBal: [],
  moveMoney: ['seeBal'],
  cashbook: [],
  reopen: ['closeDay'],
  payroll: [],
  advance: ['payroll'],
  dedBon: ['payroll'],
  paySalary: ['payroll'],
  reports: [],
  export: ['reports'],
  lockMonth: ['reports'],
  log: [],
  users: [],
  settings: [],
  archive: [],
  backdate: [],
};

/** Turning a task on also turns on everything it needs (transitively). */
export function withDependencies(tasks: Record<string, boolean>): Record<string, boolean> {
  const out = { ...tasks };
  let changed = true;
  while (changed) {
    changed = false;
    for (const [k, on] of Object.entries(out)) {
      if (!on) continue;
      for (const need of TASK_NEEDS[k] ?? []) {
        if (!out[need]) { out[need] = true; changed = true; }
      }
    }
  }
  return out;
}

/** Turning a task off also turns off every task that depends on it (transitively). */
export function withoutDependents(tasks: Record<string, boolean>, off: string): Record<string, boolean> {
  const out = { ...tasks, [off]: false };
  let changed = true;
  while (changed) {
    changed = false;
    for (const [k, needs] of Object.entries(TASK_NEEDS)) {
      if (out[k] && needs.some((n) => !out[n])) { out[k] = false; changed = true; }
    }
  }
  return out;
}

export function requireTask(user: UserDoc, task: string): void {
  if (user.status !== 'active') throw new Reject('user_disabled', 'المستخدم موقوف');
  if (user.kind === 'admin') return;
  if (!user.permissions.tasks[task]) throw new Reject('permission_denied', `ما في صلاحية: ${task}`);
}

export function requireAccount(user: UserDoc, accountId: string): void {
  if (user.kind === 'admin') return;
  const allowed = user.permissions.allowedAccounts ?? [];
  if (allowed !== 'all' && !allowed.includes(accountId)) {
    throw new Reject('account_not_allowed', 'هالصندوق مش مسموح لهالمستخدم');
  }
}
