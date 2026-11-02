import { describe, expect, it } from 'vitest';
import { register, setup } from './helpers.js';

const pay = (t: ReturnType<typeof setup>, id: string, amount: number, accountId = 'cash') =>
  t.op('admin', 'payment.record', { paymentId: id, movementId: `mv_${id}`, enrollmentId: 'en1', accountId, amount, purpose: 'lessons', receiptNo: `1-${id}`, businessDate: '2026-10-19' });
const expense = (t: ReturnType<typeof setup>, user: string, id: string, amount: number, extra: Record<string, unknown> = {}) =>
  t.op(user, 'expense.add', { expenseId: id, movementId: `mv_${id}`, kind: 'cars', item: 'بنزين', carId: 'car1', amount, accountId: 'cash', businessDate: '2026-10-19', ...extra });

describe('account balances', () => {
  it('follow payments, expenses and transfers (opening balance included)', async () => {
    const t = setup();
    t.put('treasury_account', 'cash', { name: 'كاش', kind: 'cash', active: true, openingBalance: 100000 });
    await t.run('admin', [register(t), pay(t, 'p1', 50000), expense(t, 'admin', 'e1', 27000)]);
    expect(t.get('account_balance', 'cash')?.balance).toBe(100000 + 50000 - 27000);
    await t.run('admin', [t.op('admin', 'money.move', { kind: 'transfer', fromAccountId: 'cash', toAccountId: 'bank', amount: 30000, outId: 'o1', inId: 'i1', businessDate: '2026-10-19' })]);
    expect(t.get('account_balance', 'cash')?.balance).toBe(93000);
    expect(t.get('account_balance', 'bank')?.balance).toBe(30000);
    expect(t.get('treasury_movement', 'o1')).toMatchObject({ direction: 'out', kind: 'transfer_out', transferGroupId: 'o1' });
  });
});

describe('expenses', () => {
  it('records the car in the label and logs it', async () => {
    const t = setup();
    const [r] = await t.run('admin', [expense(t, 'admin', 'e1', 27000, { liters: 40 })]);
    expect(r?.status).toBe('accepted');
    expect(t.get('expense', 'e1')).toMatchObject({ label: 'بنزين سيارة 1', liters: 40, kind: 'cars' });
  });

  it('needs the addExp permission and an allowed account', async () => {
    const t = setup();
    t.put('user', 'acc', { schoolId: 'sch1', name: 'محاسب', kind: 'staff', status: 'active', permVersion: 1, permissions: { tasks: { addExp: true }, allowedAccounts: ['cash'] } });
    const [a] = await t.run('mahmoud', [expense(t, 'mahmoud', 'e1', 100)]);
    expect(a).toMatchObject({ status: 'rejected', reason: 'permission_denied' });
    const [b] = await t.run('acc', [expense(t, 'acc', 'e2', 100, { accountId: 'bank' })]);
    expect(b).toMatchObject({ status: 'rejected', reason: 'account_not_allowed' });
  });

  it('cancelling puts the money back', async () => {
    const t = setup();
    await t.run('admin', [expense(t, 'admin', 'e1', 5000)]);
    await t.run('admin', [t.op('admin', 'expense.reverse', { expenseId: 'e1', movementId: 'mv_rev', businessDate: '2026-10-19' })]);
    expect(t.get('account_balance', 'cash')?.balance).toBe(0);
    expect(t.get('expense', 'e1')?.reversed).toBe(true);
  });
});

describe('closing the day', () => {
  const close = (t: ReturnType<typeof setup>, user: string, counts: unknown[]) =>
    t.op(user, 'day.close', { businessDate: '2026-10-19', mode: 'full', counts });

  it('compares counted with the system, needs a reason for each difference', async () => {
    const t = setup();
    await t.run('admin', [register(t), pay(t, 'p1', 50000)]);
    const [bad] = await t.run('admin', [close(t, 'admin', [{ accountId: 'cash', counted: 45000 }])]);
    expect(bad).toMatchObject({ status: 'rejected', reason: 'invalid_payload' });
    const [ok] = await t.run('admin', [close(t, 'admin', [{ accountId: 'cash', counted: 45000, reason: 'فكة رجعت' }])]);
    expect(ok).toMatchObject({ status: 'accepted', assigned: { diffs: 1 } });
    expect(t.get('day_close_count', '2026-10-19_cash')).toMatchObject({ expected: 50000, counted: 45000, diff: -5000 });
    expect(t.get('day_close', '2026-10-19')).toMatchObject({ state: 'closed', diffs: 1 });
  });

  it('a payment after closing is flagged late, and reopening needs a reason', async () => {
    const t = setup();
    await t.run('admin', [register(t), close(t, 'admin', [{ accountId: 'cash', counted: 0 }])]);
    const [late] = await t.run('admin', [pay(t, 'p2', 1000)]);
    expect(late).toMatchObject({ status: 'accepted', flags: ['lateAfterClose'] });
    expect(t.get('day_close', '2026-10-19')?.lateEntries).toBe(1);
    const [noReason] = await t.run('admin', [t.op('admin', 'day.reopen', { day: '2026-10-19', reason: '' })]);
    expect(noReason?.status).toBe('rejected');
    const [re] = await t.run('admin', [t.op('admin', 'day.reopen', { day: '2026-10-19', reason: 'دفعة متأخرة' })]);
    expect(re?.status).toBe('accepted');
    expect(t.get('day_close', '2026-10-19')?.state).toBe('reopened');
  });

  it('a staff member closes in blind mode whatever the phone sends', async () => {
    const t = setup();
    t.put('user', 'acc', { schoolId: 'sch1', name: 'محاسب', kind: 'staff', status: 'active', permVersion: 1, permissions: { tasks: { closeDay: true }, closeMode: 'blind' } });
    await t.run('acc', [close(t, 'acc', [{ accountId: 'cash', counted: 0 }])]);
    expect(t.get('day_close', '2026-10-19')?.mode).toBe('blind');
  });
});
