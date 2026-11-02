import { requireTask } from '../core/permissions.js';
import { Reject } from '../core/types.js';
import { shekel, str, type Handler } from '../core/context.js';

const MONTH = /^\d{4}-\d{2}$/;

function monthArg(p: Record<string, unknown>): string {
  const m = str(p, 'month');
  if (!MONTH.test(m)) throw new Reject('invalid_payload', 'شهر غلط');
  return m;
}

/**
 * Locks a finished month (D8): every day with money movement must be closed first.
 * After locking, nothing can be recorded or changed with a date in that month; corrections go in the open month.
 */
export const monthLock: Handler = {
  creates: [],
  async run(ctx) {
    requireTask(ctx.user, 'lockMonth');
    const month = monthArg(ctx.op.payload);
    if (month >= ctx.today.substring(0, 7)) throw new Reject('rule_violation', 'الشهر لسا ما خلص');
    const cur = await ctx.tx.get(ctx.path('month_lock', month));
    if (cur && cur.locked !== false) throw new Reject('rule_violation', 'الشهر مثبّت من قبل');
    const from = `${month}-01`;
    const to = `${month}-31`;
    const moves = await ctx.tx.queryRange(ctx.col('treasury_movement'), 'businessDate', from, to);
    const closes = await ctx.tx.queryRange(ctx.col('day_close'), 'businessDate', from, to);
    const closed = new Set(closes.filter((c) => c.state === 'closed').map((c) => c.businessDate as string));
    const open = [...new Set(moves.map((m) => m.businessDate as string))].filter((d) => !closed.has(d)).sort();
    if (open.length > 0) {
      const list = open.slice(0, 5).map((d) => `${Number(d.substring(8))}/${Number(d.substring(5, 7))}`).join('، ');
      throw new Reject('rule_violation', `في ${open.length} ${open.length === 1 ? 'يوم' : 'أيام'} مش مسكّرة: ${list}${open.length > 5 ? '…' : ''}`);
    }
    let moneyIn = 0;
    let moneyOut = 0;
    for (const m of moves) {
      if (m.kind === 'transfer_in' || m.kind === 'transfer_out') continue;
      if (m.direction === 'in') moneyIn += m.amount as number;
      else moneyOut += m.amount as number;
    }
    const snapshot = { moneyIn, moneyOut, days: closed.size };
    return {
      writes: [{ path: ctx.path('month_lock', month), mode: 'set', data: { id: month, month, locked: true, lockedBy: ctx.user.id, lockedByName: ctx.user.name, snapshot, unlockReason: null } }],
      log: [{ opType: 'close', entity: 'month', recordId: month, recordLabel: `تثبيت شهر ${month}`, changes: [{ field: 'الشهر', old: 'مفتوح', new: `مثبّت · وارد ${shekel(moneyIn)} · صادر ${shekel(moneyOut)}` }] }],
      assigned: snapshot,
    };
  },
};

/** Opens a locked month again (Admin, with a reason). */
export const monthUnlock: Handler = {
  creates: [],
  async run(ctx) {
    requireTask(ctx.user, 'lockMonth');
    if (ctx.user.kind !== 'admin') throw new Reject('permission_denied', 'بس المدير بيفتح شهر مثبّت');
    const month = monthArg(ctx.op.payload);
    const reason = str(ctx.op.payload, 'reason').trim();
    if (!reason) throw new Reject('invalid_payload', 'سبب فتح الشهر مطلوب');
    const cur = await ctx.tx.get(ctx.path('month_lock', month));
    if (!cur || cur.locked === false) throw new Reject('rule_violation', 'الشهر مش مثبّت');
    return {
      writes: [{ path: ctx.path('month_lock', month), mode: 'merge', data: { locked: false, unlockReason: reason } }],
      log: [{ opType: 'reopen', entity: 'month', recordId: month, recordLabel: `فتح شهر ${month}`, changes: [{ field: 'الشهر', old: 'مثبّت', new: 'مفتوح' }], reason }],
    };
  },
};
