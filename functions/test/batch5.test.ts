import { describe, expect, it } from 'vitest';
import { setup } from './helpers.js';

type T = ReturnType<typeof setup>;
const move = (t: T, id: string, day: string, amount = 1000, direction = 'in') =>
  t.put('treasury_movement', id, { accountId: 'cash', direction, amount, kind: direction === 'in' ? 'student_payment' : 'expense', refId: id, businessDate: day });
const lock = (t: T, month = '2026-09') => t.op('admin', 'month.lock', { month });

describe('month lock', () => {
  it('needs every day with money movement closed', async () => {
    const t = setup();
    move(t, 'm1', '2026-09-03');
    move(t, 'm2', '2026-09-04', 400, 'out');
    t.put('day_close', '2026-09-03', { businessDate: '2026-09-03', state: 'closed' });
    const [a] = await t.run('admin', [lock(t)]);
    expect(a).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
    expect(a?.status === 'rejected' && a.message).toContain('4/9');
    t.put('day_close', '2026-09-04', { businessDate: '2026-09-04', state: 'closed' });
    const [b] = await t.run('admin', [lock(t)]);
    expect(b).toMatchObject({ status: 'accepted', assigned: { moneyIn: 1000, moneyOut: 400, days: 2 } });
    expect(t.get('month_lock', '2026-09')).toMatchObject({ locked: true, lockedByName: 'المدير' });
  });

  it('a locked month refuses dated records until it is opened again with a reason', async () => {
    const t = setup();
    const [a] = await t.run('admin', [lock(t)]);
    expect(a?.status).toBe('accepted');
    const exp = (id: string) => t.op('admin', 'expense.add', { expenseId: id, movementId: `mv_${id}`, kind: 'other', item: 'كهرباء', amount: 100, accountId: 'cash', businessDate: '2026-09-20' });
    const [e1] = await t.run('admin', [exp('e1')]);
    expect(e1).toMatchObject({ status: 'rejected', reason: 'month_locked' });
    const [noReason] = await t.run('admin', [t.op('admin', 'month.unlock', { month: '2026-09', reason: '' })]);
    expect(noReason?.status).toBe('rejected');
    await t.run('admin', [t.op('admin', 'month.unlock', { month: '2026-09', reason: 'فاتورة متأخرة' })]);
    const [e2] = await t.run('admin', [exp('e2')]);
    expect(e2?.status).toBe('accepted');
  });

  it('the current month cannot be locked, and staff need the permission', async () => {
    const t = setup();
    const [cur] = await t.run('admin', [lock(t, '2026-10')]);
    expect(cur).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
    const [staff] = await t.run('salma', [t.op('salma', 'month.lock', { month: '2026-09' })]);
    expect(staff).toMatchObject({ status: 'rejected', reason: 'permission_denied' });
  });
});
