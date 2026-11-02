import { describe, expect, it } from 'vitest';
import { setup } from './helpers.js';

describe('settings', () => {
  it('validates and logs a general setting from A to B', async () => {
    const t = setup();
    const set = (key: string, value: unknown) => t.op('admin', 'setting.set', { key, value });
    const [bad, unknown] = await t.run('admin', [set('lessonDurationMin', 5), set('colour', 'red')]);
    expect(bad?.status).toBe('rejected');
    expect(unknown?.status).toBe('rejected');
    const [ok] = await t.run('admin', [set('lessonDurationMin', 40)]);
    expect(ok?.status).toBe('accepted');
    expect(t.get('setting', 'lessonDurationMin')?.value).toBe(40);
    const [same] = await t.run('admin', [set('lessonDurationMin', 40)]);
    expect(same?.status).toBe('rejected');
    await t.run('admin', [set('school', { name: '  مدرسة الأمل  ', phone: '082000000' })]);
    expect(t.get('setting', 'school')?.value).toEqual({ name: 'مدرسة الأمل', phone: '082000000', address: null });
    const [staff] = await t.run('salma', [t.op('salma', 'setting.set', { key: 'overdueDays', value: 20 })]);
    expect(staff).toMatchObject({ status: 'rejected', reason: 'permission_denied' });
  });

  it('adds a license type, then its prices', async () => {
    const t = setup();
    const [a] = await t.run('admin', [t.op('admin', 'licenseType.add', { licenseTypeId: 'lt_truck', name: 'شحن' })]);
    expect(a?.status).toBe('accepted');
    const [p] = await t.run('admin', [t.op('admin', 'licensePrice.set', {
      priceId: 'pr_truck', licenseTypeId: 'lt_truck', effectiveFrom: '2026-10-19', registrationFee: 70000, practicalLessonPrice: 15000, theoryRetakeFee: 8000, practicalExamFee: 12000,
      plannedTheoryLessons: 8, plannedPracticalLessons: 14, minTheoryBeforeExam: 8, minPracticalBeforeExam: 12,
    })]);
    expect(p?.status).toBe('accepted');
    const [dup] = await t.run('admin', [t.op('admin', 'licenseType.add', { licenseTypeId: 'x', name: 'شحن' })]);
    expect(dup?.status).toBe('rejected');
  });

  it('accounts: opening balance counts; stopping needs a zero balance', async () => {
    const t = setup();
    await t.run('admin', [t.op('admin', 'account.add', { accountId: 'jawwal', name: 'جوال باي', kind: 'wallet', openingBalance: 5000 })]);
    expect(t.get('treasury_account', 'jawwal')).toMatchObject({ kind: 'wallet', openingBalance: 5000, active: true });
    const [stop] = await t.run('admin', [t.op('admin', 'account.edit', { accountId: 'jawwal', active: false })]);
    expect(stop).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
    await t.run('admin', [t.op('admin', 'money.move', { kind: 'withdraw', fromAccountId: 'jawwal', amount: 5000, outId: 'o1', inId: 'i1', businessDate: '2026-10-19' })]);
    const [ok] = await t.run('admin', [t.op('admin', 'account.edit', { accountId: 'jawwal', active: false })]);
    expect(ok?.status).toBe('accepted');
  });

  it('only the Admin publishes an app version, with an https link', async () => {
    const t = setup();
    const v = { version: '1.1.0', build: 2, apkUrl: 'https://your-firebase-project.web.app/app.apk', notes: ['الرواتب'] };
    t.put('user', 'boss2', { schoolId: 'sch1', name: 'مدير2', kind: 'staff', status: 'active', permVersion: 1, permissions: { tasks: { settings: true } } });
    const [staff] = await t.run('boss2', [t.op('boss2', 'setting.set', { key: 'appVersion', value: v })]);
    expect(staff).toMatchObject({ status: 'rejected', reason: 'permission_denied' });
    const [bad] = await t.run('admin', [t.op('admin', 'setting.set', { key: 'appVersion', value: { ...v, apkUrl: 'http://x' } })]);
    expect(bad?.status).toBe('rejected');
    const [ok] = await t.run('admin', [t.op('admin', 'setting.set', { key: 'appVersion', value: v })]);
    expect(ok?.status).toBe('accepted');
  });
});
