import type { Store } from './store.js';
import { Reject, type Doc, type Op, type OpResult, type UserDoc } from './types.js';
import type { AfterCommit, Ctx, Handler } from './context.js';
import { studentEdit, studentRegister } from '../handlers/students.js';
import { lessonArchive, lessonLog } from '../handlers/lessons.js';
import { discountGive, paymentRecord, paymentReverse } from '../handlers/money.js';
import { enrollmentAdd, enrollmentGraduate, enrollmentWithdraw, examBook, examPostpone, examResult } from '../handlers/exams.js';
import { dayClose, dayReopen, expenseAdd, expenseReverse, moneyMove } from '../handlers/treasury.js';
import { accountAdd, accountEdit, licensePriceSet, licenseTypeAdd, licenseTypeEdit, settingSet } from '../handlers/settings.js';
import { monthLock, monthUnlock } from '../handlers/reports.js';
import { carAdd, carInstructor, employeeSalary, payrollItem, salaryPay, userCreate, userPermissions, userStatus } from '../handlers/staff.js';

export const HANDLERS: Record<string, Handler> = {
  'student.register': studentRegister,
  'student.edit': studentEdit,
  'lesson.log': lessonLog,
  'lesson.archive': lessonArchive,
  'payment.record': paymentRecord,
  'payment.reverse': paymentReverse,
  'discount.give': discountGive,
  'licensePrice.set': licensePriceSet,
  'expense.add': expenseAdd,
  'expense.reverse': expenseReverse,
  'money.move': moneyMove,
  'day.close': dayClose,
  'day.reopen': dayReopen,
  'exam.book': examBook,
  'exam.postpone': examPostpone,
  'exam.result': examResult,
  'enrollment.graduate': enrollmentGraduate,
  'enrollment.withdraw': enrollmentWithdraw,
  'enrollment.add': enrollmentAdd,
  'payroll.item': payrollItem,
  'salary.pay': salaryPay,
  'employee.salary': employeeSalary,
  'car.add': carAdd,
  'car.instructor': carInstructor,
  'user.create': userCreate,
  'user.status': userStatus,
  'user.permissions': userPermissions,
  'month.lock': monthLock,
  'month.unlock': monthUnlock,
  'setting.set': settingSet,
  'licenseType.add': licenseTypeAdd,
  'licenseType.edit': licenseTypeEdit,
  'account.add': accountAdd,
  'account.edit': accountEdit,
};

export interface ApplyEnv {
  store: Store;
  /** server clock (injected for tests) */
  now: () => Date;
  timeZone?: string;
  /** an id generator for log docs */
  newId: () => string;
  /** runs side effects (e.g. creating a student login) after a fresh commit */
  afterCommit?: (a: AfterCommit) => Promise<void>;
}

function businessToday(d: Date, timeZone: string): string {
  // en-CA formats as YYYY-MM-DD
  return new Intl.DateTimeFormat('en-CA', { timeZone, year: 'numeric', month: '2-digit', day: '2-digit' }).format(d);
}

function daysBetween(a: string, b: string): number {
  return Math.round((Date.parse(b + 'T00:00:00Z') - Date.parse(a + 'T00:00:00Z')) / 86_400_000);
}

/**
 * Applies a batch of ops from one device, in deviceSeq order, one transaction each.
 * Idempotent: an op already applied (or rejected) returns its stored result.
 */
export async function applyOps(env: ApplyEnv, authUserId: string, ops: Op[]): Promise<OpResult[]> {
  const sorted = [...ops].sort((a, b) => a.deviceSeq - b.deviceSeq);
  const results: OpResult[] = [];
  for (const op of sorted) results.push(await applyOne(env, authUserId, op));
  return results;
}

async function applyOne(env: ApplyEnv, authUserId: string, op: Op): Promise<OpResult> {
  const after: AfterCommit[] = [];
  const result = await applyTx(env, authUserId, op, after);
  for (const a of after) {
    try {
      await env.afterCommit?.(a);
    } catch (e) {
      console.error('afterCommit failed', a.kind, e); // the record is saved; the login can be re-sent by the Admin
    }
  }
  return result;
}

async function applyTx(env: ApplyEnv, authUserId: string, op: Op, after: AfterCommit[]): Promise<OpResult> {
  const school = `schools/${op.schoolId}`;
  const opPath = `${school}/ops/${op.opId}`;
  const tz = env.timeZone ?? 'Asia/Hebron';
  const handler = HANDLERS[op.type];

  try {
    return await env.store.runTransaction(async (tx) => {
      // 1. Idempotency.
      const done = await tx.get(opPath);
      if (done) return done.result as OpResult;

      const now = env.now();
      const serverTime = now.toISOString();
      const today = businessToday(now, tz);
      const ctxBase = {
        path: (c: string, id: string) => `${school}/${c}/${id}`,
        col: (c: string) => `${school}/${c}`,
      };

      // 2. Auth & user.
      if (op.userId !== authUserId) throw new Reject('permission_denied', 'العملية مش باسم المستخدم الحالي');
      const user = (await tx.get(ctxBase.path('user', op.userId))) as unknown as UserDoc | undefined;
      if (!user) throw new Reject('permission_denied', 'المستخدم مش معروف');
      if (user.schoolId !== op.schoolId) throw new Reject('wrong_school', 'مدرسة غلط');
      // A stopped user's token can live up to an hour after the stop: refuse their writes right away.
      if ((user as unknown as { status?: string }).status !== undefined && (user as unknown as { status?: string }).status !== 'active') throw new Reject('permission_denied', 'الحساب موقوف');
      if (!handler) throw new Reject('unknown_op_type', `نوع عملية مش معروف: ${op.type}`);

      // 3. Date rules (locks, back-dating).
      const flags: string[] = [];
      const bd = op.payload.businessDate;
      let dayClose: Doc | undefined;
      if (typeof bd === 'string') {
        if (bd > today) throw new Reject('rule_violation', 'ما بيصير تاريخ بالمستقبل');
        const lock = await tx.get(ctxBase.path('month_lock', bd.substring(0, 7)));
        if (lock && lock.locked !== false) throw new Reject('month_locked', 'الشهر مثبّت · التصحيح بيصير بالشهر المفتوح');
        const back = daysBetween(bd, today);
        if (back > 0 && user.kind !== 'admin') {
          const allowed = user.permissions.tasks.backdate ? user.permissions.backdateDays ?? 0 : 0;
          if (allowed !== 'any_open_day' && back > allowed) throw new Reject('backdate_not_allowed', 'ما في صلاحية تسجيل بهالتاريخ القديم');
        }
        dayClose = await tx.get(ctxBase.path('day_close', bd));
        if (dayClose && dayClose.state === 'closed') flags.push('lateAfterClose');
      }

      // 4. Handler (reads only) → writes.
      const ctx: Ctx = { tx, op, user, serverTime, today, ...ctxBase };
      const out = await handler.run(ctx);
      after.length = 0; // transaction retries re-run the handler

      // 5. Account balances follow every treasury movement (read before any write).
      const deltas = new Map<string, number>();
      for (const w of out.writes) {
        if (w.mode !== 'set' || !w.path.includes('/treasury_movement/')) continue;
        const acc = w.data.accountId as string;
        const amt = (w.data.amount as number) * (w.data.direction === 'in' ? 1 : -1);
        deltas.set(acc, (deltas.get(acc) ?? 0) + amt);
      }
      const balanceWrites: { path: string; balance: number }[] = [];
      for (const [acc, delta] of deltas) {
        const path = ctxBase.path('account_balance', acc);
        const cur = await tx.get(path);
        let base = cur?.balance as number | undefined;
        if (base === undefined) {
          const account = await tx.get(ctxBase.path('treasury_account', acc));
          base = (account?.openingBalance as number) ?? 0;
        }
        balanceWrites.push({ path, balance: base + delta });
      }

      // 6. Stamp: serverSeq from the school head counter.
      const head = await tx.get(`${school}/meta/head`);
      const serverSeq = ((head?.serverSeq as number) ?? 0) + 1;
      const stamp = { schoolId: op.schoolId, serverSeq, serverTime, deviceTime: op.deviceTime, opId: op.opId };
      for (const w of out.writes) {
        const data = w.mode === 'set' ? { ...w.data, ...stamp, createdBy: op.userId, lateAfterClose: flags.includes('lateAfterClose') } : { ...w.data, ...stamp };
        if (w.mode === 'set') tx.set(w.path, data);
        else tx.merge(w.path, data);
      }
      for (const entry of out.log) {
        const id = env.newId();
        tx.set(ctxBase.path('activity_log', id), {
          id, ...entry, actorId: op.userId, actorName: user.name, deviceId: op.deviceId, ...stamp, lateAfterClose: flags.includes('lateAfterClose'),
        });
      }
      if (dayClose && flags.includes('lateAfterClose')) {
        tx.merge(ctxBase.path('day_close', bd as string), { lateEntries: ((dayClose.lateEntries as number) ?? 0) + 1, serverSeq, serverTime });
      }
      for (const b of balanceWrites) {
        tx.set(b.path, { id: b.path.substring(b.path.lastIndexOf('/') + 1), accountId: b.path.substring(b.path.lastIndexOf('/') + 1), balance: b.balance, schoolId: op.schoolId, serverSeq, serverTime });
      }
      tx.merge(`${school}/meta/head`, { serverSeq });

      const result: OpResult = { opId: op.opId, status: 'accepted', serverSeq, serverTime, assigned: out.assigned, flags: flags.length ? flags : undefined };
      tx.set(opPath, { result: JSON.parse(JSON.stringify(result)), userId: op.userId, deviceId: op.deviceId, type: op.type, serverTime });
      after.push(...(out.after ?? []));
      return result;
    });
  } catch (e) {
    if (!(e instanceof Reject)) throw e; // infrastructure error → client retries the same op later
    const result: OpResult = { opId: op.opId, status: 'rejected', reason: e.reason, message: e.message };
    // Remember the rejection (idempotent) and the ids this op would have created.
    await env.store.runTransaction(async (tx) => {
      const done = await tx.get(opPath);
      if (done) return;
      tx.set(opPath, { result, userId: op.userId, deviceId: op.deviceId, type: op.type, serverTime: env.now().toISOString() });
      for (const key of handler?.creates ?? []) {
        const id = op.payload[key];
        if (typeof id === 'string') tx.set(`${school}/rejected_ids/${id}`, { opId: op.opId, reason: e.reason });
      }
    });
    return result;
  }
}
