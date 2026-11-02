import { describe, expect, it } from 'vitest';
import { setup } from './helpers.js';
import type { AfterCommit } from '../src/core/context.js';

type T = ReturnType<typeof setup>;

function staff(t: T) {
  t.put('employee', 'emp_mahmoud', { name: 'محمود', role: 'instructor', userId: 'mahmoud', active: true });
  t.put('salary_rate', 'emp_mahmoud_2026-01', { employeeId: 'emp_mahmoud', effectiveFrom: '2026-01', monthlyAmount: 150000 });
  t.put('treasury_account', 'cash', { name: 'كاش', kind: 'cash', active: true, openingBalance: 500000 });
}
const item = (t: T, id: string, kind: string, amount: number, month = '2026-10', extra: Record<string, unknown> = {}) =>
  t.op('admin', 'payroll.item', { itemId: id, movementId: `mv_${id}`, employeeId: 'emp_mahmoud', payrollMonth: month, kind, amount, accountId: 'cash', businessDate: '2026-10-19', ...extra });
const pay = (t: T, id: string, month = '2026-10', businessDate = '2026-10-19') =>
  t.op('admin', 'salary.pay', { paymentId: id, movementId: `mv_${id}`, employeeId: 'emp_mahmoud', payrollMonth: month, accountId: 'cash', businessDate });

describe('payroll', () => {
  it('advance leaves the account now; deduction and bonus only change the net', async () => {
    const t = setup();
    staff(t);
    const r = await t.run('admin', [item(t, 'a1', 'advance', 20000), item(t, 'd1', 'deduction', 5000, '2026-10', { reason: 'غياب يوم' }), item(t, 'b1', 'bonus', 10000)]);
    expect(r.map((x) => x.status)).toEqual(['accepted', 'accepted', 'accepted']);
    expect(t.get('account_balance', 'cash')?.balance).toBe(500000 - 20000);
    expect(t.get('treasury_movement', 'mv_d1')).toBeUndefined();
    expect(t.get('payroll_item', 'd1')).toMatchObject({ kind: 'deduction', reason: 'غياب يوم', payrollMonth: '2026-10', accountId: null });
  });

  it('pays salary + bonuses − deductions − advances with the salary of that month', async () => {
    const t = setup();
    staff(t);
    t.put('salary_rate', 'emp_mahmoud_2026-11', { employeeId: 'emp_mahmoud', effectiveFrom: '2026-11', monthlyAmount: 180000 });
    await t.run('admin', [item(t, 'a1', 'advance', 20000), item(t, 'b1', 'bonus', 10000), item(t, 'd1', 'deduction', 5000)]);
    const [r] = await t.run('admin', [pay(t, 'p1')]);
    expect(r).toMatchObject({ status: 'accepted', assigned: { net: 135000, salaryAtMonth: 150000, early: true } });
    expect(t.get('salary_payment', 'p1')).toMatchObject({ salaryAtMonth: 150000, bonuses: 10000, deductions: 5000, advances: 20000, net: 135000, early: true });
    expect(t.get('account_balance', 'cash')?.balance).toBe(500000 - 20000 - 135000);
  });

  it('a paid month takes no more items and cannot be paid twice', async () => {
    const t = setup();
    staff(t);
    await t.run('admin', [pay(t, 'p1')]);
    const [a, b] = await t.run('admin', [item(t, 'a2', 'advance', 1000), pay(t, 'p2')]);
    expect(a).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
    expect(b).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
    const [c] = await t.run('admin', [item(t, 'a3', 'advance', 1000, '2026-11')]);
    expect(c?.status).toBe('accepted');
  });

  it('blocks paying a negative net, a future month and a locked month', async () => {
    const t = setup();
    staff(t);
    await t.run('admin', [item(t, 'a1', 'advance', 160000)]);
    const [neg] = await t.run('admin', [pay(t, 'p1')]);
    expect(neg).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
    const [future] = await t.run('admin', [pay(t, 'p2', '2026-11')]);
    expect(future).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
    t.put('month_lock', '2026-09', { month: '2026-09' });
    const [locked] = await t.run('admin', [pay(t, 'p3', '2026-09')]);
    expect(locked).toMatchObject({ status: 'rejected', reason: 'month_locked' });
  });

  it('needs the matching permission', async () => {
    const t = setup();
    staff(t);
    t.put('user', 'acc', { schoolId: 'sch1', name: 'محاسب', kind: 'staff', status: 'active', permVersion: 1, permissions: { tasks: { payroll: true, advance: true }, allowedAccounts: ['cash'] } });
    const op = (type: string, p: Record<string, unknown>) => t.op('acc', type, p);
    const [adv, bon, sal] = await t.run('acc', [
      op('payroll.item', { itemId: 'a1', movementId: 'm1', employeeId: 'emp_mahmoud', payrollMonth: '2026-10', kind: 'advance', amount: 100, accountId: 'cash', businessDate: '2026-10-19' }),
      op('payroll.item', { itemId: 'b1', employeeId: 'emp_mahmoud', payrollMonth: '2026-10', kind: 'bonus', amount: 100, businessDate: '2026-10-19' }),
      op('salary.pay', { paymentId: 'p1', movementId: 'm2', employeeId: 'emp_mahmoud', payrollMonth: '2026-10', accountId: 'cash', businessDate: '2026-10-19' }),
    ]);
    expect(adv?.status).toBe('accepted');
    expect(bon).toMatchObject({ status: 'rejected', reason: 'permission_denied' });
    expect(sal).toMatchObject({ status: 'rejected', reason: 'permission_denied' });
  });

  it('a salary change starts from an unpaid month', async () => {
    const t = setup();
    staff(t);
    await t.run('admin', [pay(t, 'p1')]);
    const [a] = await t.run('admin', [t.op('admin', 'employee.salary', { employeeId: 'emp_mahmoud', fromMonth: '2026-10', monthlyAmount: 170000 })]);
    expect(a).toMatchObject({ status: 'rejected' });
    const [b] = await t.run('admin', [t.op('admin', 'employee.salary', { employeeId: 'emp_mahmoud', fromMonth: '2026-11', monthlyAmount: 170000 })]);
    expect(b?.status).toBe('accepted');
    expect(t.get('salary_payment', 'p1')?.salaryAtMonth).toBe(150000);
    expect(t.get('salary_rate', 'emp_mahmoud_2026-11')?.monthlyAmount).toBe(170000);
  });
});

describe('cars and instructors', () => {
  it('adds a car and links / unlinks an instructor (history kept, claims refreshed)', async () => {
    const t = setup();
    staff(t);
    const after: AfterCommit[] = [];
    t.env.afterCommit = async (a) => { after.push(a); };
    const [c] = await t.run('admin', [t.op('admin', 'car.add', { carId: 'car9', name: 'سيارة 9', plate: '5-1', gearbox: 'auto' })]);
    expect(c?.status).toBe('accepted');
    await t.run('admin', [t.op('admin', 'car.instructor', { carId: 'car9', employeeId: 'emp_mahmoud', on: true, linkId: 'l9' })]);
    expect(t.get('car_instructor', 'l9')).toMatchObject({ carId: 'car9', from: '2026-10-19', to: null });
    expect(after.at(-1)).toMatchObject({ kind: 'setClaims', uid: 'mahmoud', claims: { carIds: ['car1', 'car9'] } });
    await t.run('admin', [t.op('admin', 'car.instructor', { carId: 'car9', employeeId: 'emp_mahmoud', on: false })]);
    expect(t.get('car_instructor', 'l9')?.to).toBe('2026-10-19');
    expect(after.at(-1)).toMatchObject({ kind: 'setClaims', claims: { carIds: ['car1'] } });
  });

  it('only with the settings permission', async () => {
    const t = setup();
    const [r] = await t.run('salma', [t.op('salma', 'car.add', { carId: 'car9', name: 'سيارة 9' })]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'permission_denied' });
  });
});

describe('users and permissions', () => {
  it('creates an accountant on cash only, with an employee file and a login', async () => {
    const t = setup();
    const after: AfterCommit[] = [];
    t.env.afterCommit = async (a) => { after.push(a); };
    const [r] = await t.run('admin', [t.op('admin', 'user.create', {
      userId: 'u_hala', employeeId: 'emp_hala', name: 'هالة', nationalId: '402345678', phone: '0598765432', role: 'staff', job: 'accountant', salary: 100000, tempPassword: 'abc12345', businessDate: '2026-10-19',
    })]);
    expect(r?.status).toBe('accepted');
    expect(t.get('user', 'u_hala')).toMatchObject({ kind: 'staff', employeeId: 'emp_hala', permissions: { allowedAccounts: ['cash'], closeMode: 'blind', logScope: 'own' } });
    expect(JSON.stringify(t.get('user', 'u_hala'))).not.toContain('abc12345');
    expect(t.get('employee', 'emp_hala')).toMatchObject({ role: 'staff', userId: 'u_hala' });
    expect(t.get('employee', 'emp_hala')?.salary).toBeUndefined(); // salaries live in salary_rate (payroll-only)
    expect(t.get('salary_rate', 'emp_hala_2026-10')?.monthlyAmount).toBe(100000);
    expect(after[0]).toMatchObject({ kind: 'createLogin', uid: 'u_hala', claims: { kind: 'staff', money: true, close: true, cashbook: 'all', log: 'own', balances: false } });
  });

  it('an instructor starts on the chosen cars', async () => {
    const t = setup();
    const after: AfterCommit[] = [];
    t.env.afterCommit = async (a) => { after.push(a); };
    await t.run('admin', [t.op('admin', 'user.create', {
      userId: 'u_iyad', employeeId: 'emp_iyad', name: 'إياد', nationalId: '402345679', role: 'instructor', carIds: ['car2'], salary: 150000, tempPassword: 'abc12345', businessDate: '2026-10-19',
    })]);
    expect(t.get('car_instructor', 'car2_emp_iyad_2026-10-19')).toMatchObject({ employeeId: 'emp_iyad', to: null });
    expect(after[0]).toMatchObject({ claims: { kind: 'instructor', carIds: ['car2'], money: false } });
    const [dup] = await t.run('admin', [t.op('admin', 'user.create', { userId: 'u2', employeeId: 'e2', name: 'ثاني', nationalId: '402345679', role: 'staff', tempPassword: 'abc12345' })]);
    expect(dup).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
  });

  it('permissions: dependencies added, logged from A to B, permVersion bumped, claims refreshed', async () => {
    const t = setup();
    const after: AfterCommit[] = [];
    t.env.afterCommit = async (a) => { after.push(a); };
    const [r] = await t.run('admin', [t.op('admin', 'user.permissions', {
      userId: 'salma', job: 'accountant', permissions: { tasks: { moveMoney: true, students: true }, allowedAccounts: ['cash', 'bank'], closeMode: 'full', logScope: 'own' },
    })]);
    expect(r).toMatchObject({ status: 'accepted', assigned: { permVersion: 2 } });
    const u = t.get('user', 'salma') as { permissions: { tasks: Record<string, boolean>; allowedAccounts: string[] } };
    expect(u.permissions.tasks).toEqual({ moveMoney: true, seeBal: true, students: true });
    expect(u.permissions.allowedAccounts).toEqual(['cash', 'bank']);
    expect(after[0]).toMatchObject({ kind: 'setClaims', uid: 'salma', claims: { balances: true, money: false, permVersion: 2 } });
    const log = [...t.store.data.values()].find((d) => d.entity === 'user' && d.opType === 'permission');
    expect(JSON.stringify(log)).toContain('رؤية أرصدة الصناديق');
  });

  it('the last active Admin cannot be disabled; others are signed out', async () => {
    const t = setup();
    const after: AfterCommit[] = [];
    t.env.afterCommit = async (a) => { after.push(a); };
    const [last] = await t.run('admin', [t.op('admin', 'user.status', { userId: 'admin', active: false })]);
    expect(last).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
    const [off] = await t.run('admin', [t.op('admin', 'user.status', { userId: 'salma', active: false })]);
    expect(off?.status).toBe('accepted');
    expect(t.get('user', 'salma')?.status).toBe('disabled');
    expect(after.at(-1)).toEqual({ kind: 'setDisabled', uid: 'salma', disabled: true });
    // Her token may still be valid for a while: her writes are refused at once.
    const [late] = await t.run('salma', [t.op('salma', 'user.status', { userId: 'mahmoud', active: false })]);
    expect(late).toMatchObject({ status: 'rejected', reason: 'permission_denied', message: 'الحساب موقوف' });
    const [noAdminPerms] = await t.run('admin', [t.op('admin', 'user.permissions', { userId: 'admin', permissions: { tasks: {} } })]);
    expect(noAdminPerms).toMatchObject({ status: 'rejected' });
  });

  it('needs the users permission', async () => {
    const t = setup();
    const [r] = await t.run('salma', [t.op('salma', 'user.status', { userId: 'mahmoud', active: false })]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'permission_denied' });
  });
});
