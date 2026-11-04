import { requireAccount, requireTask } from '../core/permissions.js';
import { Reject, type LogChange } from '../core/types.js';
import { date, money, mustGet, optStr, shekel, str, type Handler, type Write } from '../core/context.js';

const EXPENSE_KINDS = ['cars', 'ministry', 'other'];
const KIND_LABEL: Record<string, string> = { cars: 'سيارات', ministry: 'وزارة', other: 'أخرى' };

async function activeAccount(ctx: Parameters<Handler['run']>[0], accountId: string) {
  const a = await mustGet(ctx, 'treasury_account', accountId);
  if (a.active === false) throw new Reject('rule_violation', 'الصندوق موقوف');
  return a;
}

/** An expense paid from an allowed account: expense doc + money out. Salaries/advances live in Payroll. */
export const expenseAdd: Handler = {
  creates: ['expenseId', 'movementId'],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'addExp');
    const expenseId = str(p, 'expenseId');
    const movementId = str(p, 'movementId');
    const kind = str(p, 'kind');
    if (!EXPENSE_KINDS.includes(kind)) throw new Reject('invalid_payload', 'نوع المصروف غلط');
    const item = str(p, 'item').trim();
    if (!item) throw new Reject('invalid_payload', 'شو المصروف؟');
    const amount = money(p, 'amount');
    const accountId = str(p, 'accountId');
    const businessDate = date(p, 'businessDate');
    const carId = optStr(p, 'carId') ?? null;
    const studentId = optStr(p, 'studentId') ?? null;
    const note = optStr(p, 'note') ?? null;
    const liters = typeof p.liters === 'number' ? p.liters : null;
    if (kind === 'cars' && !carId) throw new Reject('invalid_payload', 'أي سيارة؟');
    if (kind === 'ministry' && !studentId) throw new Reject('invalid_payload', 'رسوم اختبار مين؟');
    requireAccount(ctx.user, accountId);
    await activeAccount(ctx, accountId);
    let label = item;
    if (carId) label = `${item} ${(await mustGet(ctx, 'car', carId)).name as string}`;
    if (studentId) label = `${item} — ${(await mustGet(ctx, 'student', studentId)).name as string}`;
    return {
      writes: [
        { path: ctx.path('expense', expenseId), mode: 'set', data: { id: expenseId, kind, item, label, carId, liters, studentId, amount, accountId, note, businessDate, reversed: false } },
        { path: ctx.path('treasury_movement', movementId), mode: 'set', data: { id: movementId, accountId, direction: 'out', amount, kind: 'expense', refId: expenseId, businessDate } },
      ],
      log: [{ opType: 'create', entity: 'expense', recordId: expenseId, recordLabel: `${KIND_LABEL[kind]}: ${label} ${shekel(amount)}`, changes: [] }],
    };
  },
};

/** Cancels an expense (the money goes back into its account). */
export const expenseReverse: Handler = {
  creates: ['movementId'],
  async run(ctx) {
    const p = ctx.op.payload;
    const expenseId = str(p, 'expenseId');
    const movementId = str(p, 'movementId');
    const reason = optStr(p, 'reason');
    date(p, 'businessDate');
    const e = await mustGet(ctx, 'expense', expenseId);
    const own = e.createdBy === ctx.user.id && e.businessDate === ctx.deviceDay;
    requireTask(ctx.user, own ? 'addExp' : 'editExp');
    if (e.reversed === true) throw new Reject('rule_violation', 'المصروف ملغي من قبل');
    // The money goes back on the expense's own day: that month must still be open.
    const lock = await ctx.tx.get(ctx.path('month_lock', (e.businessDate as string).substring(0, 7)));
    if (lock && lock.locked !== false) throw new Reject('month_locked', 'الشهر مثبّت · التصحيح بيصير بالشهر المفتوح');
    return {
      writes: [
        { path: ctx.path('expense', expenseId), mode: 'merge', data: { reversed: true } },
        { path: ctx.path('treasury_movement', movementId), mode: 'set', data: { id: movementId, accountId: e.accountId, direction: 'in', amount: e.amount, kind: 'expense_reversal', refId: expenseId, businessDate: e.businessDate } },
      ],
      log: [{ opType: 'archive', entity: 'expense', recordId: expenseId, recordLabel: `${e.label as string} ${shekel(e.amount as number)}`, changes: [{ field: 'الحالة', old: 'مسجّل', new: 'ملغي' }], reason }],
    };
  },
};

/** Top-up (money in from outside), withdraw (money out, not an expense), or transfer between two accounts. */
export const moneyMove: Handler = {
  creates: ['outId', 'inId'],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'moveMoney');
    const kind = str(p, 'kind');
    const amount = money(p, 'amount');
    const businessDate = date(p, 'businessDate');
    const note = optStr(p, 'note') ?? null;
    const writes: Write[] = [];
    let label = '';
    if (kind === 'top_up') {
      const to = str(p, 'toAccountId');
      requireAccount(ctx.user, to);
      const a = await activeAccount(ctx, to);
      const inId = str(p, 'inId');
      writes.push({ path: ctx.path('treasury_movement', inId), mode: 'set', data: { id: inId, accountId: to, direction: 'in', amount, kind: 'top_up', refId: inId, note, businessDate } });
      label = `شحن ${a.name as string} ${shekel(amount)}`;
    } else if (kind === 'withdraw') {
      const from = str(p, 'fromAccountId');
      requireAccount(ctx.user, from);
      const a = await activeAccount(ctx, from);
      const outId = str(p, 'outId');
      writes.push({ path: ctx.path('treasury_movement', outId), mode: 'set', data: { id: outId, accountId: from, direction: 'out', amount, kind: 'withdraw', refId: outId, note, businessDate } });
      label = `سحب من ${a.name as string} ${shekel(amount)}`;
    } else if (kind === 'transfer') {
      const from = str(p, 'fromAccountId');
      const to = str(p, 'toAccountId');
      if (from === to) throw new Reject('invalid_payload', 'نفس الصندوق');
      requireAccount(ctx.user, from);
      requireAccount(ctx.user, to);
      const a = await activeAccount(ctx, from);
      const b = await activeAccount(ctx, to);
      const outId = str(p, 'outId');
      const inId = str(p, 'inId');
      writes.push({ path: ctx.path('treasury_movement', outId), mode: 'set', data: { id: outId, accountId: from, direction: 'out', amount, kind: 'transfer_out', refId: inId, transferGroupId: outId, note, businessDate } });
      writes.push({ path: ctx.path('treasury_movement', inId), mode: 'set', data: { id: inId, accountId: to, direction: 'in', amount, kind: 'transfer_in', refId: outId, transferGroupId: outId, note, businessDate } });
      label = `تحويل ${shekel(amount)} من ${a.name as string} إلى ${b.name as string}`;
    } else {
      throw new Reject('invalid_payload', 'نوع الحركة غلط');
    }
    return { writes, log: [{ opType: 'create', entity: 'treasury_movement', recordId: (p.outId ?? p.inId) as string, recordLabel: label, changes: [], reason: note ?? undefined }] };
  },
};

interface Count { accountId: string; counted: number; reason?: string }

/**
 * Closes a business day with the counted amount of every account. Expected = the account balance now
 * (blind mode: the person never saw it). Every difference needs a reason. Late entries are flagged by applyOps.
 */
export const dayClose: Handler = {
  creates: [],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'closeDay');
    const businessDate = date(p, 'businessDate');
    const mode = ctx.user.kind === 'admin' ? (p.mode === 'blind' ? 'blind' : 'full') : (ctx.user.permissions.closeMode ?? 'blind');
    const counts = p.counts as Count[] | undefined;
    if (!Array.isArray(counts) || counts.length === 0) throw new Reject('invalid_payload', 'مطلوب مبلغ كل صندوق');
    const existing = await ctx.tx.get(ctx.path('day_close', businessDate));
    if (existing && existing.state === 'closed') throw new Reject('rule_violation', 'اليوم مغلق من قبل');

    const writes: Write[] = [];
    const changes: LogChange[] = [];
    let diffs = 0;
    const rows: Record<string, unknown>[] = [];
    for (const c of counts) {
      if (typeof c.counted !== 'number' || !Number.isInteger(c.counted) || c.counted < 0) throw new Reject('invalid_payload', 'المبلغ لازم يكون رقم');
      const acc = await mustGet(ctx, 'treasury_account', c.accountId);
      const bal = await ctx.tx.get(ctx.path('account_balance', c.accountId));
      const expected = (bal?.balance as number) ?? (acc.openingBalance as number) ?? 0;
      const diff = c.counted - expected;
      if (diff !== 0 && !(c.reason ?? '').trim()) throw new Reject('invalid_payload', `سبب الفرق مطلوب (${acc.name as string})`);
      if (diff !== 0) diffs += 1;
      rows.push({ accountId: c.accountId, expected, counted: c.counted, diff, reason: c.reason?.trim() || null });
      if (diff !== 0) changes.push({ field: acc.name as string, old: shekel(expected), new: `${shekel(c.counted)} · ${diff > 0 ? 'زيادة' : 'نقص'} ${shekel(Math.abs(diff))}` });
    }
    for (const r of rows) {
      const id = `${businessDate}_${r.accountId as string}`;
      writes.push({ path: ctx.path('day_close_count', id), mode: 'set', data: { id, dayCloseId: businessDate, businessDate, ...r } });
    }
    writes.push({
      path: ctx.path('day_close', businessDate), mode: 'set',
      data: { id: businessDate, businessDate, state: 'closed', mode, closedBy: ctx.user.id, closedByName: ctx.user.name, diffs, lateEntries: (existing?.lateEntries as number) ?? 0 },
    });
    return {
      writes,
      log: [{ opType: 'close', entity: 'day', recordId: businessDate, recordLabel: `إغلاق يوم ${businessDate}`, changes }],
      assigned: { diffs, counts: rows },
    };
  },
};

export const dayReopen: Handler = {
  creates: [],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'reopen');
    const businessDate = str(p, 'day');
    const reason = str(p, 'reason').trim();
    if (!reason) throw new Reject('invalid_payload', 'سبب إعادة الفتح مطلوب');
    const d = await mustGet(ctx, 'day_close', businessDate);
    if (d.state !== 'closed') throw new Reject('rule_violation', 'اليوم مش مغلق');
    const lock = await ctx.tx.get(ctx.path('month_lock', businessDate.substring(0, 7)));
    if (lock && lock.locked !== false) throw new Reject('month_locked', 'الشهر مثبّت');
    return {
      writes: [{ path: ctx.path('day_close', businessDate), mode: 'merge', data: { state: 'reopened', reopenReason: reason } }],
      log: [{ opType: 'reopen', entity: 'day', recordId: businessDate, recordLabel: `إعادة فتح يوم ${businessDate}`, changes: [{ field: 'الحالة', old: 'مغلق', new: 'مفتوح' }], reason }],
    };
  },
};
