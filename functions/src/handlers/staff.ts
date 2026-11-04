import { requireAccount, requireTask, withDependencies, TASK_NEEDS } from '../core/permissions.js';
import { claimsFor, jobPermissions, TASK_LABEL } from '../core/claims.js';
import { Reject, type Doc, type LogChange, type UserDoc, type UserPermissions } from '../core/types.js';
import { date, money, mustGet, optStr, shekel, str, type AfterCommit, type Ctx, type Handler, type Write } from '../core/context.js';

const NATIONAL_ID = /^\d{9}$/;
const MONTH = /^\d{4}-\d{2}$/;
const ITEM_KINDS = ['advance', 'deduction', 'bonus'];
const ITEM_LABEL: Record<string, string> = { advance: 'سلفة', deduction: 'خصم', bonus: 'مكافأة' };

export function monthOf(businessDate: string): string {
  return businessDate.substring(0, 7);
}

function lastDayOf(month: string): string {
  const y = Number(month.substring(0, 4));
  const m = Number(month.substring(5, 7));
  const d = new Date(Date.UTC(y, m, 0)).getUTCDate();
  return `${month}-${String(d).padStart(2, '0')}`;
}

function monthArg(p: Record<string, unknown>, k: string): string {
  const v = str(p, k);
  if (!MONTH.test(v)) throw new Reject('invalid_payload', `شهر غلط: ${k}`);
  return v;
}

async function monthUnlocked(ctx: Ctx, month: string): Promise<void> {
  const lock = await ctx.tx.get(ctx.path('month_lock', month));
  if (lock && lock.locked !== false) throw new Reject('month_locked', 'الشهر مثبّت · التصحيح بيصير بالشهر المفتوح');
}

/** Monthly salary in force for a payroll month (latest effectiveFrom <= month). */
export async function salaryAt(ctx: Ctx, employeeId: string, month: string): Promise<number> {
  const rates = await ctx.tx.query(ctx.col('salary_rate'), { employeeId });
  const r = rates
    .filter((x) => (x.effectiveFrom as string) <= month)
    .sort((a, b) => ((a.effectiveFrom as string) < (b.effectiveFrom as string) ? 1 : -1))[0];
  return (r?.monthlyAmount as number) ?? 0;
}

async function paidFor(ctx: Ctx, employeeId: string, month: string): Promise<Doc | undefined> {
  const rows = await ctx.tx.query(ctx.col('salary_payment'), { employeeId, payrollMonth: month });
  return rows[0];
}

async function activeAccount(ctx: Ctx, accountId: string): Promise<Doc> {
  const a = await mustGet(ctx, 'treasury_account', accountId);
  if (a.active === false) throw new Reject('rule_violation', 'الصندوق موقوف');
  return a;
}

/** Cars an instructor is on now (open links), optionally after this op's own link changes. */
async function currentCars(ctx: Ctx, employeeId: string, add: string[] = [], remove: string[] = []): Promise<string[]> {
  const links = await ctx.tx.query(ctx.col('car_instructor'), { employeeId });
  const cars = new Set(links.filter((l) => !l.to).map((l) => l.carId as string));
  for (const c of add) cars.add(c);
  for (const c of remove) cars.delete(c);
  return [...cars].sort();
}

// ---------------------------------------------------------------- payroll

/** Advance (money leaves an account now), deduction or bonus — always on one payroll month. */
export const payrollItem: Handler = {
  creates: ['itemId', 'movementId'],
  async run(ctx) {
    const p = ctx.op.payload;
    const kind = str(p, 'kind');
    if (!ITEM_KINDS.includes(kind)) throw new Reject('invalid_payload', 'نوع الحركة غلط');
    requireTask(ctx.user, kind === 'advance' ? 'advance' : 'dedBon');
    const itemId = str(p, 'itemId');
    const employeeId = str(p, 'employeeId');
    const month = monthArg(p, 'payrollMonth');
    const amount = money(p, 'amount');
    const businessDate = date(p, 'businessDate');
    const reason = optStr(p, 'reason')?.trim() || ITEM_LABEL[kind];
    const note = optStr(p, 'note')?.trim() || null;
    const emp = await mustGet(ctx, 'employee', employeeId);
    await monthUnlocked(ctx, month);
    if (await paidFor(ctx, employeeId, month)) {
      throw new Reject('rule_violation', 'راتب هالشهر انصرف · الحركة بتنحط على الشهر الجاي');
    }
    const writes: Write[] = [];
    let accountId: string | null = null;
    let label = `${ITEM_LABEL[kind]} لـ${emp.name as string} ${shekel(amount)}`;
    if (kind === 'advance') {
      accountId = str(p, 'accountId');
      requireAccount(ctx.user, accountId);
      const a = await activeAccount(ctx, accountId);
      const movementId = str(p, 'movementId');
      writes.push({ path: ctx.path('treasury_movement', movementId), mode: 'set', data: { id: movementId, accountId, direction: 'out', amount, kind: 'advance', refId: itemId, note: `سلفة ${emp.name as string}`, businessDate } });
      label += ` · من ${a.name as string}`;
    } else if (reason !== ITEM_LABEL[kind]) {
      label = `${ITEM_LABEL[kind]}: ${reason} · ${emp.name as string} ${shekel(amount)}`;
    }
    writes.push({
      path: ctx.path('payroll_item', itemId), mode: 'set',
      data: { id: itemId, employeeId, employeeName: emp.name, payrollMonth: month, kind, reason, note, amount, accountId, businessDate, recordedByName: ctx.user.name },
    });
    return { writes, log: [{ opType: 'create', entity: 'payroll_item', recordId: itemId, recordLabel: label, changes: [], reason: note ?? undefined }] };
  },
};

/** Pays one employee's month: salary (as it was that month) + bonuses − deductions − advances. */
export const salaryPay: Handler = {
  creates: ['paymentId', 'movementId'],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'paySalary');
    const paymentId = str(p, 'paymentId');
    const movementId = str(p, 'movementId');
    const employeeId = str(p, 'employeeId');
    const month = monthArg(p, 'payrollMonth');
    const accountId = str(p, 'accountId');
    const businessDate = date(p, 'businessDate');
    if (month > monthOf(businessDate)) throw new Reject('rule_violation', 'ما بيصير صرف راتب شهر لسا ما إجا');
    const emp = await mustGet(ctx, 'employee', employeeId);
    await monthUnlocked(ctx, month);
    requireAccount(ctx.user, accountId);
    const a = await activeAccount(ctx, accountId);
    if (await paidFor(ctx, employeeId, month)) throw new Reject('rule_violation', 'راتب هالشهر انصرف من قبل');
    const salary = await salaryAt(ctx, employeeId, month);
    const items = await ctx.tx.query(ctx.col('payroll_item'), { employeeId, payrollMonth: month });
    const sum = (k: string) => items.filter((i) => i.kind === k).reduce((s, i) => s + (i.amount as number), 0);
    const bonuses = sum('bonus');
    const deductions = sum('deduction');
    const advances = sum('advance');
    const net = salary + bonuses - deductions - advances;
    if (net < 0) throw new Reject('rule_violation', `السلف والخصومات أكثر من الراتب بـ ${shekel(-net)}`);
    const early = businessDate < lastDayOf(month);
    const writes: Write[] = [{
      path: ctx.path('salary_payment', paymentId), mode: 'set',
      data: { id: paymentId, employeeId, employeeName: emp.name, payrollMonth: month, salaryAtMonth: salary, bonuses, deductions, advances, net, accountId, businessDate, early, paidByName: ctx.user.name },
    }];
    if (net > 0) {
      writes.push({ path: ctx.path('treasury_movement', movementId), mode: 'set', data: { id: movementId, accountId, direction: 'out', amount: net, kind: 'salary', refId: paymentId, note: `راتب ${emp.name as string} ${month}`, businessDate } });
    }
    return {
      writes,
      log: [{ opType: 'create', entity: 'salary_payment', recordId: paymentId, recordLabel: `صرف راتب ${emp.name as string} (${month}) ${shekel(net)} من ${a.name as string}`, changes: [] }],
      assigned: { net, salaryAtMonth: salary, early },
    };
  },
};

/** New monthly salary from a payroll month; months already paid keep the old amount. */
export const employeeSalary: Handler = {
  creates: [],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'paySalary');
    const employeeId = str(p, 'employeeId');
    const fromMonth = monthArg(p, 'fromMonth');
    const amount = money(p, 'monthlyAmount');
    const emp = await mustGet(ctx, 'employee', employeeId);
    const lock = await ctx.tx.get(ctx.path('month_lock', fromMonth));
    if (lock && lock.locked !== false) throw new Reject('month_locked', 'الشهر مثبّت · الراتب الجديد بيبدأ من شهر مفتوح');
    const paid = await ctx.tx.query(ctx.col('salary_payment'), { employeeId });
    if (paid.some((x) => (x.payrollMonth as string) >= fromMonth)) {
      throw new Reject('rule_violation', 'راتب هالشهر انصرف · الراتب الجديد بيبدأ من الشهر الجاي');
    }
    const old = await salaryAt(ctx, employeeId, fromMonth);
    const id = `${employeeId}_${fromMonth}`;
    return {
      writes: [
        { path: ctx.path('salary_rate', id), mode: 'set', data: { id, employeeId, effectiveFrom: fromMonth, monthlyAmount: amount } },
      ],
      // A20: the amount stays in salary_rate (payroll permission); the shared log only says it changed.
      log: [{ opType: 'edit', entity: 'employee', recordId: employeeId, recordLabel: emp.name as string, changes: [{ field: `الراتب من ${fromMonth}`, old: old ? 'الراتب السابق' : 'بدون راتب', new: 'راتب جديد' }] }],
    };
  },
};

// ---------------------------------------------------------------- cars

export const carAdd: Handler = {
  creates: ['carId'],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'settings');
    const carId = str(p, 'carId');
    const name = str(p, 'name').trim();
    const plate = optStr(p, 'plate')?.trim() || null;
    const gearbox = p.gearbox === 'auto' ? 'auto' : 'manual';
    if (!name) throw new Reject('invalid_payload', 'اسم السيارة مطلوب');
    const same = await ctx.tx.query(ctx.col('car'), { name });
    if (same.some((c) => c.active !== false)) throw new Reject('rule_violation', 'في سيارة بنفس الاسم');
    return {
      writes: [{ path: ctx.path('car', carId), mode: 'set', data: { id: carId, name, plate, gearbox, active: true } }],
      log: [{ opType: 'create', entity: 'car', recordId: carId, recordLabel: plate ? `${name} · ${plate}` : name, changes: [] }],
    };
  },
};

/**
 * Renames a car / fixes its plate or gearbox, or stops / restarts it. A stopped car keeps its history;
 * its instructor links end today. A car with active students can't be stopped (they stay on it).
 */
export const carEdit: Handler = {
  creates: [],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'settings');
    const carId = str(p, 'carId');
    const car = await mustGet(ctx, 'car', carId);
    const next: Record<string, unknown> = {};
    const changes: LogChange[] = [];
    if (p.name !== undefined) {
      const name = str(p, 'name').trim();
      if (!name) throw new Reject('invalid_payload', 'اسم السيارة مطلوب');
      if (name !== car.name) {
        const same = await ctx.tx.query(ctx.col('car'), { name });
        if (same.some((c) => c.id !== carId && c.active !== false)) throw new Reject('rule_violation', 'في سيارة بنفس الاسم');
        next.name = name;
        changes.push({ field: 'الاسم', old: car.name, new: name });
      }
    }
    if (p.plate !== undefined) {
      const plate = optStr(p, 'plate')?.trim() || null;
      if (plate !== (car.plate ?? null)) {
        next.plate = plate;
        changes.push({ field: 'رقم اللوحة', old: car.plate ?? '—', new: plate ?? '—' });
      }
    }
    if (p.gearbox !== undefined) {
      const gearbox = p.gearbox === 'auto' ? 'auto' : 'manual';
      if (gearbox !== (car.gearbox ?? 'manual')) {
        next.gearbox = gearbox;
        changes.push({ field: 'الجير', old: car.gearbox === 'auto' ? 'أوتوماتيك' : 'عادي', new: gearbox === 'auto' ? 'أوتوماتيك' : 'عادي' });
      }
    }
    const writes: Write[] = [];
    if (typeof p.active === 'boolean' && p.active !== (car.active !== false)) {
      if (!p.active) {
        const enrolled = await ctx.tx.query(ctx.col('enrollment'), { carId });
        const busy = enrolled.filter((e) => !['graduated', 'withdrawn'].includes(e.stage as string)).length;
        if (busy) throw new Reject('rule_violation', `على هالسيارة ${busy} طلاب شغّالين · ما بتنوقف`);
        for (const l of await ctx.tx.query(ctx.col('car_instructor'), { carId })) {
          if (!l.to) writes.push({ path: ctx.path('car_instructor', l.id as string), mode: 'merge', data: { to: ctx.today } });
        }
      }
      next.active = p.active;
      changes.push({ field: 'الحالة', old: car.active !== false ? 'شغّالة' : 'موقوفة', new: p.active ? 'شغّالة' : 'موقوفة' });
    }
    if (!changes.length) throw new Reject('rule_violation', 'ما في تغيير');
    writes.push({ path: ctx.path('car', carId), mode: 'merge', data: next });
    return { writes, log: [{ opType: next.active === false ? 'archive' : 'edit', entity: 'car', recordId: carId, recordLabel: (next.name ?? car.name) as string, changes }] };
  },
};

/** Puts an instructor on a car from today, or takes them off today (history kept). */
export const carInstructor: Handler = {
  creates: [],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'settings');
    const carId = str(p, 'carId');
    const employeeId = str(p, 'employeeId');
    const on = p.on === true;
    const car = await mustGet(ctx, 'car', carId);
    const emp = await mustGet(ctx, 'employee', employeeId);
    if (emp.role !== 'instructor') throw new Reject('rule_violation', 'الموظف مش مدرب');
    const links = await ctx.tx.query(ctx.col('car_instructor'), { carId, employeeId });
    const open = links.find((l) => !l.to);
    const writes: Write[] = [];
    if (on) {
      if (emp.active === false) throw new Reject('rule_violation', 'المدرب موقوف');
      if (open) throw new Reject('rule_violation', 'المدرب على هالسيارة من قبل');
      const id = str(p, 'linkId');
      writes.push({ path: ctx.path('car_instructor', id), mode: 'set', data: { id, carId, employeeId, from: ctx.today, to: null } });
    } else {
      if (!open) throw new Reject('rule_violation', 'المدرب مش على هالسيارة');
      writes.push({ path: ctx.path('car_instructor', open.id as string), mode: 'merge', data: { to: ctx.today } });
    }
    const after: AfterCommit[] = [];
    const uid = emp.userId as string | undefined;
    if (uid) {
      const u = (await ctx.tx.get(ctx.path('user', uid))) as unknown as UserDoc | undefined;
      if (u) {
        const cars = await currentCars(ctx, employeeId, on ? [carId] : [], on ? [] : [carId]);
        after.push({ kind: 'setClaims', uid, claims: claimsFor(ctx.op.schoolId, u, cars) });
      }
    }
    return {
      writes,
      after,
      log: [{
        opType: 'edit', entity: 'car', recordId: carId, recordLabel: car.name as string,
        changes: [{ field: `المدرب ${emp.name as string}`, old: on ? 'مش عليها' : 'عليها', new: on ? 'عليها' : 'مش عليها' }],
      }],
    };
  },
};

// ---------------------------------------------------------------- users

function cleanPermissions(raw: unknown): UserPermissions {
  if (!raw || typeof raw !== 'object') throw new Reject('invalid_payload', 'الصلاحيات ناقصة');
  const r = raw as Record<string, unknown>;
  const tasksIn = (r.tasks ?? {}) as Record<string, unknown>;
  const tasks: Record<string, boolean> = {};
  for (const k of Object.keys(TASK_NEEDS)) if (tasksIn[k] === true) tasks[k] = true;
  const withNeeds = withDependencies(tasks);
  const list = (v: unknown): string[] | 'all' => (v === 'all' ? 'all' : Array.isArray(v) ? v.filter((x): x is string => typeof x === 'string') : []);
  const backdate = r.backdateDays === 'any_open_day' ? 'any_open_day' : typeof r.backdateDays === 'number' && r.backdateDays >= 0 ? Math.floor(r.backdateDays) : 0;
  return {
    tasks: Object.fromEntries(Object.entries(withNeeds).filter(([, v]) => v)),
    allowedAccounts: list(r.allowedAccounts),
    expenseCategories: list(r.expenseCategories),
    discountMax: r.discountMax === null ? null : typeof r.discountMax === 'number' && r.discountMax >= 0 ? Math.floor(r.discountMax) : 0,
    closeMode: r.closeMode === 'full' ? 'full' : 'blind',
    logScope: r.logScope === 'all' ? 'all' : 'own',
    backdateDays: backdate,
  };
}

async function cashAccounts(ctx: Ctx): Promise<string[]> {
  const rows = await ctx.tx.query(ctx.col('treasury_account'), { kind: 'cash' });
  return rows.filter((a) => a.active !== false).map((a) => a.id as string).sort();
}

/**
 * New staff / instructor / admin login. Instructors and staff get an employee file (payroll);
 * the temporary password only travels to Firebase Auth and the WhatsApp message.
 */
export const userCreate: Handler = {
  creates: ['userId', 'employeeId'],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'users');
    const userId = str(p, 'userId');
    const name = str(p, 'name').trim();
    const nationalId = str(p, 'nationalId').trim();
    const phone = optStr(p, 'phone')?.trim() || null;
    const role = str(p, 'role');
    const tempPassword = str(p, 'tempPassword');
    if (!['instructor', 'staff', 'admin'].includes(role)) throw new Reject('invalid_payload', 'الدور غلط');
    if (role === 'admin' && ctx.user.kind !== 'admin') throw new Reject('permission_denied', 'بس المدير بيضيف مدير');
    if (name.length < 2) throw new Reject('invalid_payload', 'الاسم مطلوب');
    if (!NATIONAL_ID.test(nationalId)) throw new Reject('invalid_payload', 'رقم الهوية لازم يكون 9 أرقام');
    if (tempPassword.length < 6) throw new Reject('invalid_payload', 'كلمة السر المؤقتة قصيرة');
    const dup = await ctx.tx.query(ctx.col('user'), { nationalId });
    if (dup.length > 0) throw new Reject('rule_violation', 'رقم الهوية إله حساب من قبل');

    const job = role === 'instructor' ? 'instructor' : role === 'admin' ? 'manager' : (optStr(p, 'job') ?? 'secretary');
    const permissions = role === 'admin' ? { tasks: {} } : jobPermissions(job, await cashAccounts(ctx));
    const user: UserDoc & Record<string, unknown> = {
      id: userId, schoolId: ctx.op.schoolId, name, nationalId, phone, kind: role as UserDoc['kind'], status: 'active',
      permissions, permVersion: 1, job,
    };
    const writes: Write[] = [];
    const carIds = Array.isArray(p.carIds) ? (p.carIds as unknown[]).filter((x): x is string => typeof x === 'string') : [];
    let employeeId: string | null = null;
    if (role !== 'admin') {
      employeeId = str(p, 'employeeId');
      user.employeeId = employeeId;
      const salary = typeof p.salary === 'number' && Number.isInteger(p.salary) && p.salary > 0 ? p.salary : 0;
      writes.push({ path: ctx.path('employee', employeeId), mode: 'set', data: { id: employeeId, name, phone, role, userId, active: true } });
      if (salary > 0) {
        const month = monthOf(ctx.today);
        writes.push({ path: ctx.path('salary_rate', `${employeeId}_${month}`), mode: 'set', data: { id: `${employeeId}_${month}`, employeeId, effectiveFrom: month, monthlyAmount: salary } });
      }
      if (role === 'instructor') {
        for (const carId of carIds) {
          await mustGet(ctx, 'car', carId);
          const id = `${carId}_${employeeId}_${ctx.today}`;
          writes.push({ path: ctx.path('car_instructor', id), mode: 'set', data: { id, carId, employeeId, from: ctx.today, to: null } });
        }
      }
    }
    writes.push({ path: ctx.path('user', userId), mode: 'set', data: user });
    const roleName = role === 'admin' ? 'مدير' : role === 'instructor' ? 'مدرب' : 'موظف';
    return {
      writes,
      after: [{ kind: 'createLogin', uid: userId, nationalId, password: tempPassword, name, claims: claimsFor(ctx.op.schoolId, user, role === 'instructor' ? [...carIds].sort() : []) }],
      log: [{ opType: 'create', entity: 'user', recordId: userId, recordLabel: `${name} · ${roleName}`, changes: [] }],
    };
  },
};

async function activeAdmins(ctx: Ctx): Promise<Doc[]> {
  const admins = await ctx.tx.query(ctx.col('user'), { kind: 'admin' });
  return admins.filter((a) => a.status === 'active');
}

/** Disable (signed out on every device) or enable again. The last active Admin can't be disabled. */
export const userStatus: Handler = {
  creates: [],
  async run(ctx) {
    const p = ctx.op.payload;
    const userId = str(p, 'userId');
    const active = p.active === true;
    const reason = optStr(p, 'reason')?.trim();
    const u = await mustGet(ctx, 'user', userId);
    // A student's login is stopped from the student's file (edit student); staff logins need "users".
    requireTask(ctx.user, u.kind === 'student' ? 'editStudent' : 'users');
    const was = u.status === 'active';
    if (was === active) throw new Reject('rule_violation', active ? 'الحساب شغّال من قبل' : 'الحساب موقوف من قبل');
    if (!active && u.kind === 'admin') {
      if (ctx.user.kind !== 'admin') throw new Reject('permission_denied', 'بس المدير بيوقف مدير');
      const admins = await activeAdmins(ctx);
      if (admins.length <= 1) throw new Reject('rule_violation', 'ما بينفع إيقاف آخر مدير');
    }
    const writes: Write[] = [{ path: ctx.path('user', userId), mode: 'merge', data: { status: active ? 'active' : 'disabled' } }];
    if (u.employeeId) writes.push({ path: ctx.path('employee', u.employeeId as string), mode: 'merge', data: { active } });
    // A stopped instructor leaves their cars today (history kept); re-enabling doesn't put them back.
    if (!active && u.kind === 'instructor' && u.employeeId) {
      for (const l of await ctx.tx.query(ctx.col('car_instructor'), { employeeId: u.employeeId })) {
        if (!l.to) writes.push({ path: ctx.path('car_instructor', l.id as string), mode: 'merge', data: { to: ctx.today } });
      }
    }
    return {
      writes,
      after: [{ kind: 'setDisabled', uid: userId, disabled: !active }],
      log: [{ opType: 'permission', entity: 'user', recordId: userId, recordLabel: u.name as string, changes: [{ field: 'الحساب', old: was ? 'شغّال' : 'موقوف', new: active ? 'شغّال' : 'موقوف' }], reason }],
    };
  },
};

/**
 * Admin-side password reset (A11, no SMS): the phone makes a temporary password, shows it once /
 * sends it on WhatsApp; the server sets it and signs the person out everywhere. Never stored.
 */
export const userResetPassword: Handler = {
  creates: [],
  async run(ctx) {
    const p = ctx.op.payload;
    const userId = str(p, 'userId');
    const password = str(p, 'password');
    if (password.length < 6) throw new Reject('invalid_payload', 'كلمة السر لازم تكون 6 خانات أو أكثر');
    const u = await mustGet(ctx, 'user', userId);
    requireTask(ctx.user, u.kind === 'student' ? 'editStudent' : 'users');
    if (u.kind === 'admin' && ctx.user.kind !== 'admin') throw new Reject('permission_denied', 'بس المدير بيغيّر كلمة سر مدير');
    if (userId === ctx.user.id) throw new Reject('rule_violation', 'كلمة سرك بتتغيّر من مدير ثاني');
    return {
      writes: [{ path: ctx.path('user', userId), mode: 'merge', data: { passwordResetAt: ctx.serverTime } }],
      after: [{ kind: 'resetPassword', uid: userId, password }],
      log: [{ opType: 'permission', entity: 'user', recordId: userId, recordLabel: u.name as string, changes: [{ field: 'كلمة السر', old: '—', new: 'كلمة سر مؤقتة جديدة' }] }],
    };
  },
};

const CLOSE_LABEL: Record<string, string> = { blind: 'بدون ما يشوف المفروض', full: 'بيشوف المفروض والفرق' };
const LOG_LABEL: Record<string, string> = { own: 'عملياته بس', all: 'عمليات الكل' };

function listLabel(v: string[] | 'all' | undefined): string {
  if (v === 'all' || v === undefined) return 'الكل';
  return v.length ? v.join('، ') : 'ولا إشي';
}

/** Saves the task checklist + options of a staff member / instructor; new claims right after. */
export const userPermissions: Handler = {
  creates: [],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'users');
    const userId = str(p, 'userId');
    const u = (await mustGet(ctx, 'user', userId)) as unknown as UserDoc & Record<string, unknown>;
    if (u.kind === 'admin') throw new Reject('rule_violation', 'المدير عنده كل الصلاحيات');
    if (u.kind === 'student') throw new Reject('rule_violation', 'صلاحيات الطالب ثابتة');
    if (userId === ctx.user.id) throw new Reject('rule_violation', 'ما بيصير تعديل صلاحياتك لحالك');
    const next = cleanPermissions(p.permissions);
    const job = optStr(p, 'job') ?? (u.job as string | undefined) ?? null;
    const prev = u.permissions ?? { tasks: {} };
    const changes: LogChange[] = [];
    for (const k of Object.keys(TASK_NEEDS)) {
      const a = prev.tasks?.[k] === true;
      const b = next.tasks[k] === true;
      if (a !== b) changes.push({ field: TASK_LABEL[k] ?? k, old: a ? 'مسموح' : 'لا', new: b ? 'مسموح' : 'لا' });
    }
    if (JSON.stringify(prev.allowedAccounts ?? 'all') !== JSON.stringify(next.allowedAccounts)) changes.push({ field: 'الصناديق', old: listLabel(prev.allowedAccounts), new: listLabel(next.allowedAccounts) });
    if (JSON.stringify(prev.expenseCategories ?? 'all') !== JSON.stringify(next.expenseCategories)) changes.push({ field: 'أنواع المصاريف', old: listLabel(prev.expenseCategories), new: listLabel(next.expenseCategories) });
    if ((prev.discountMax ?? 0) !== next.discountMax) changes.push({ field: 'حد الخصم', old: prev.discountMax == null ? 'بدون حد' : shekel(prev.discountMax), new: next.discountMax == null ? 'بدون حد' : shekel(next.discountMax) });
    if ((prev.closeMode ?? 'blind') !== next.closeMode) changes.push({ field: 'عدّ الصندوق', old: CLOSE_LABEL[prev.closeMode ?? 'blind'], new: CLOSE_LABEL[next.closeMode ?? 'blind'] });
    if ((prev.logScope ?? 'own') !== next.logScope) changes.push({ field: 'سجل العمليات', old: LOG_LABEL[prev.logScope ?? 'own'], new: LOG_LABEL[next.logScope ?? 'own'] });
    if ((prev.backdateDays ?? 0) !== next.backdateDays) changes.push({ field: 'التسجيل بتاريخ قديم', old: String(prev.backdateDays ?? 0), new: String(next.backdateDays) });
    if (changes.length === 0 && job === (u.job ?? null)) throw new Reject('invalid_payload', 'ما في تغيير');
    const permVersion = (u.permVersion ?? 1) + 1;
    const updated = { ...u, permissions: next, permVersion };
    const cars = u.kind === 'instructor' && u.employeeId ? await currentCars(ctx, u.employeeId as string) : [];
    return {
      writes: [{ path: ctx.path('user', userId), mode: 'merge', data: { permissions: next, permVersion, job } }],
      after: [{ kind: 'setClaims', uid: userId, claims: claimsFor(ctx.op.schoolId, updated, cars) }],
      log: [{ opType: 'permission', entity: 'user', recordId: userId, recordLabel: u.name, changes }],
      assigned: { permVersion },
    };
  },
};
