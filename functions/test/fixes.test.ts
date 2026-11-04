import { describe, expect, it } from 'vitest';
import { register, setup } from './helpers.js';

// Regression tests for the fixes after QA round 1 (claude/QA-2026-11-03.md).

type T = ReturnType<typeof setup>;

const pay = (t: T, user: string, id: string, amount: number, businessDate: string, receiptNo = `R-${id}`) =>
  t.op(user, 'payment.record', { paymentId: id, movementId: `mv_${id}`, enrollmentId: 'en1', accountId: 'cash', amount, purpose: 'general', receiptNo, businessDate });
const lesson = (t: T, user: string, id: string, extra: Record<string, unknown> = {}) =>
  t.op(user, 'lesson.log', { lessonId: id, chargeId: `ch_${id}`, enrollmentId: 'en1', type: 'practical', employeeId: 'emp_mahmoud', startedAt: '2026-10-19T08:00:00Z', businessDate: '2026-10-19', ...extra });
/** An op made on the phone at [deviceTime] (offline) and sent later. */
const madeAt = <O extends { deviceTime: string }>(op: O, deviceTime: string): O => ({ ...op, deviceTime });

describe('offline entries keep the day they were made', () => {
  it('a payment made offline yesterday is accepted today and flagged lateSync', async () => {
    const t = setup('2026-10-19T08:00:00Z');
    await t.run('admin', [register(t, 'st1', 'en1', '401234567', '2026-10-19')]);
    t.setNow('2026-10-20T09:00:00Z');
    const [r] = await t.run('salma', [madeAt(pay(t, 'salma', 'p1', 20000, '2026-10-19'), '2026-10-19T17:00:00Z')]);
    expect(r).toMatchObject({ status: 'accepted', flags: ['lateSync'] });
    expect(t.get('student_ledger', 'p1')).toMatchObject({ lateSync: true });
  });

  it('a back-dated entry made today is still refused without the permission', async () => {
    const t = setup('2026-10-19T08:00:00Z');
    t.put('user', 'sec', { schoolId: 'sch1', name: 'سكرتيرة', kind: 'staff', status: 'active', permVersion: 1, permissions: { tasks: { students: true, seeMoney: true, addPay: true }, allowedAccounts: ['cash'] } });
    await t.run('admin', [register(t, 'st1', 'en1', '401234567', '2026-10-18')]);
    const [r] = await t.run('sec', [pay(t, 'sec', 'p1', 1000, '2026-10-18')]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'backdate_not_allowed' });
  });

  it('a device clock in the future does not open future dates', async () => {
    const t = setup('2026-10-19T08:00:00Z');
    await t.run('admin', [register(t)]);
    const [r] = await t.run('salma', [madeAt(pay(t, 'salma', 'p1', 1000, '2026-10-21'), '2026-10-21T08:00:00Z')]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
  });

  it("an instructor's lesson given offline yesterday syncs today", async () => {
    const t = setup('2026-10-19T08:00:00Z');
    await t.run('admin', [register(t)]);
    t.setNow('2026-10-20T07:00:00Z');
    const [r] = await t.run('mahmoud', [madeAt(lesson(t, 'mahmoud', 'l1'), '2026-10-19T08:00:00Z')]);
    expect(r).toMatchObject({ status: 'accepted', flags: ['lateSync'] });
  });

  it('own same-day undo made offline is accepted the next day', async () => {
    const t = setup('2026-10-19T08:00:00Z');
    await t.run('admin', [register(t)]);
    await t.run('salma', [pay(t, 'salma', 'p1', 1000, '2026-10-19')]);
    t.setNow('2026-10-20T09:00:00Z');
    const undo = madeAt(t.op('salma', 'payment.reverse', { paymentId: 'p1', reversalId: 'rv1', movementId: 'mv_rv1', businessDate: '2026-10-19' }), '2026-10-19T17:05:00Z');
    const [r] = await t.run('salma', [undo]);
    expect(r.status).toBe('accepted');
  });
});

describe('discount limits', () => {
  const disc = (t: T, user: string, id: string, amount: number, enrollmentId = 'en1') =>
    t.op(user, 'discount.give', { discountId: id, enrollmentId, amount, businessDate: '2026-10-19' });

  it('"no limit" (null) allows any discount', async () => {
    const t = setup();
    t.put('user', 'boss', { schoolId: 'sch1', name: 'نائب', kind: 'staff', status: 'active', permVersion: 1, permissions: { tasks: { students: true, discount: true }, discountMax: null } });
    await t.run('admin', [register(t)]);
    const [r] = await t.run('boss', [disc(t, 'boss', 'd1', 40000)]);
    expect(r.status).toBe('accepted');
  });

  it('the limit is per student across licenses', async () => {
    const t = setup();
    t.put('license_type', 'lt_moto', { name: 'دراجة', active: true });
    t.put('license_price', 'pm', { licenseTypeId: 'lt_moto', effectiveFrom: '2026-09-01', registrationFee: 30000, practicalLessonPrice: 8000, theoryRetakeFee: 8000, practicalExamFee: 8000 });
    await t.run('admin', [register(t), t.op('admin', 'enrollment.add', { enrollmentId: 'en2', chargeId: 'ch_en2', studentId: 'st1', licenseTypeId: 'lt_moto', carId: 'car1', businessDate: '2026-10-19' })]);
    const [a] = await t.run('salma', [disc(t, 'salma', 'd1', 5000)]);
    const [b] = await t.run('salma', [disc(t, 'salma', 'd2', 1000, 'en2')]);
    expect(a.status).toBe('accepted');
    expect(b).toMatchObject({ status: 'rejected', reason: 'discount_over_limit' });
  });
});

describe('lessons', () => {
  it('practical lesson in the theory stage is refused when the license says practical after theory', async () => {
    const t = setup();
    t.put('license_price', 'pr3', { licenseTypeId: 'lt_private', effectiveFrom: '2026-10-18', registrationFee: 50000, practicalLessonPrice: 12000, theoryRetakeFee: 8000, practicalExamFee: 10000, practicalAfterTheory: true });
    await t.run('admin', [register(t)]);
    const [r] = await t.run('admin', [lesson(t, 'admin', 'l1')]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
  });

  it('one running practical lesson per instructor (logged from his phone)', async () => {
    const t = setup();
    await t.run('admin', [register(t), register(t, 'st2', 'en2', '401234568')]);
    const [a] = await t.run('mahmoud', [lesson(t, 'mahmoud', 'l1')]);
    const [b] = await t.run('mahmoud', [lesson(t, 'mahmoud', 'l2', { enrollmentId: 'en2', startedAt: '2026-10-19T08:10:00Z' })]);
    const [c] = await t.run('mahmoud', [lesson(t, 'mahmoud', 'l3', { enrollmentId: 'en2', startedAt: '2026-10-19T08:50:00Z' })]);
    expect(a.status).toBe('accepted');
    expect(b).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
    expect(c.status).toBe('accepted');
  });

  it('staff entering several lessons later are not limited by the running-lesson rule', async () => {
    const t = setup();
    await t.run('admin', [register(t), register(t, 'st2', 'en2', '401234568')]);
    const r = await t.run('admin', [lesson(t, 'admin', 'l1'), lesson(t, 'admin', 'l2', { enrollmentId: 'en2' })]);
    expect(r.map((x) => x.status)).toEqual(['accepted', 'accepted']);
  });

  it('the same lesson id under a new opId is not charged twice', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    await t.run('admin', [lesson(t, 'admin', 'l1')]);
    const [r] = await t.run('admin', [lesson(t, 'admin', 'l1', { chargeId: 'ch_other' })]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
    expect(t.get('student_summary', 'en1')).toMatchObject({ practicalLessons: 1 });
  });

  it('a lesson given before the instructor was taken off the car (same day) is still accepted', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    t.store.data.set('schools/sch1/car_instructor/ci1', { id: 'ci1', carId: 'car1', employeeId: 'emp_mahmoud', from: '2026-10-01', to: '2026-10-19' });
    const [r] = await t.run('mahmoud', [lesson(t, 'mahmoud', 'l1')]);
    expect(r.status).toBe('accepted');
  });

  it('cannot cancel a lesson of a locked month by sending today', async () => {
    const t = setup('2026-10-19T08:00:00Z');
    await t.run('admin', [register(t), lesson(t, 'admin', 'l1')]);
    t.put('month_lock', '2026-10', { locked: true });
    t.setNow('2026-11-03T08:00:00Z');
    const [r] = await t.run('admin', [t.op('admin', 'lesson.archive', { lessonId: 'l1', reversalId: 'rv1', businessDate: '2026-11-03' })]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'month_locked' });
  });

  it('"without driving" is ignored while the setting is off', async () => {
    const t = setup();
    await t.run('admin', [register(t), lesson(t, 'admin', 'l1', { withoutDriving: true })]);
    expect(t.get('lesson', 'l1')).toMatchObject({ withoutDriving: false });
  });
});

describe('withdrawn / passed students', () => {
  it('a passed student cannot be withdrawn', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    t.store.data.set('schools/sch1/enrollment/en1', { ...t.get('enrollment', 'en1'), stage: 'passed' });
    const [r] = await t.run('admin', [t.op('admin', 'enrollment.withdraw', { enrollmentId: 'en1', reason: 'سفر' })]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
  });

  it('after withdrawal: no payment reversal, no discount, no lesson cancel; paying the debt still works', async () => {
    const t = setup();
    await t.run('admin', [register(t), pay(t, 'admin', 'p1', 10000, '2026-10-19'), lesson(t, 'admin', 'l1')]);
    await t.run('admin', [t.op('admin', 'enrollment.withdraw', { enrollmentId: 'en1', reason: 'سفر' })]);
    const r = await t.run('admin', [
      t.op('admin', 'payment.reverse', { paymentId: 'p1', reversalId: 'rv1', movementId: 'mv_rv1', businessDate: '2026-10-19' }),
      t.op('admin', 'discount.give', { discountId: 'd1', enrollmentId: 'en1', amount: 1000, businessDate: '2026-10-19' }),
      t.op('admin', 'lesson.archive', { lessonId: 'l1', reversalId: 'rv2', businessDate: '2026-10-19' }),
      pay(t, 'admin', 'p2', 5000, '2026-10-19'),
    ]);
    expect(r.map((x) => x.status)).toEqual(['rejected', 'rejected', 'rejected', 'accepted']);
  });
});

describe('records are never overwritten', () => {
  it('a booking that reuses an exam id is refused', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    const book = (id: string, charge: string) => t.op('admin', 'exam.book', { examId: id, enrollmentId: 'en1', scheduledDate: '2026-10-25', businessDate: '2026-10-19', chargeId: charge, expenseId: `x_${charge}`, movementId: `m_${charge}`, accountId: 'cash', override: true });
    await t.run('admin', [book('ex1', 'c1')]);
    await t.run('admin', [t.op('admin', 'exam.postpone', { examId: 'ex1', toDate: '2026-10-26', reason: 'ministry' })]);
    t.store.data.set('schools/sch1/exam/ex1', { ...t.get('exam', 'ex1'), result: 'fail' });
    const [r] = await t.run('admin', [book('ex1', 'c2')]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
    expect(t.get('exam', 'ex1')).toMatchObject({ result: 'fail' });
  });

  it('a receipt number is used once', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    const [a, b] = await t.run('admin', [pay(t, 'admin', 'p1', 1000, '2026-10-19', 'R-7'), pay(t, 'admin', 'p2', 1000, '2026-10-19', 'R-7')]);
    expect(a.status).toBe('accepted');
    expect(b).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
  });
});

describe('registration and settings', () => {
  it('a national ID used by a staff login is refused for a student', async () => {
    const t = setup();
    t.put('user', 'sami', { schoolId: 'sch1', name: 'سامي', kind: 'staff', status: 'active', nationalId: '401234567', permissions: { tasks: {} }, permVersion: 1 });
    const [r] = await t.run('admin', [register(t)]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
  });

  it('a stopped license type takes no new students', async () => {
    const t = setup();
    t.put('license_type', 'lt_private', { name: 'خصوصي', active: false });
    const [r] = await t.run('admin', [register(t)]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
  });

  it('a new price starts today or later; a same-day correction wins', async () => {
    const t = setup('2026-10-19T08:00:00Z');
    const price = (id: string, from: string, lessonPrice: number) => t.op('admin', 'licensePrice.set', {
      priceId: id, licenseTypeId: 'lt_private', effectiveFrom: from, registrationFee: 50000, practicalLessonPrice: lessonPrice, theoryRetakeFee: 8000, practicalExamFee: 10000,
      plannedTheoryLessons: 0, plannedPracticalLessons: 0, minTheoryBeforeExam: 0, minPracticalBeforeExam: 0, practicalAfterTheory: false,
    });
    const [old] = await t.run('admin', [price('zz_back', '2026-10-01', 9000)]);
    expect(old).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
    // typo first (id sorts last), then the fix (id sorts first) on the same day → the fix must win
    await t.run('admin', [price('zz_typo', '2026-10-19', 150000), price('aa_fix', '2026-10-19', 15000)]);
    await t.run('admin', [register(t), lesson(t, 'admin', 'l1')]);
    expect(t.get('student_ledger', 'ch_l1')).toMatchObject({ amount: 15000 });
  });

  it('a salary change inside a locked month is refused', async () => {
    const t = setup();
    t.put('month_lock', '2026-09', { locked: true });
    const [r] = await t.run('admin', [t.op('admin', 'employee.salary', { employeeId: 'emp_mahmoud', fromMonth: '2026-09', monthlyAmount: 200000 })]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'month_locked' });
  });

  it('the activity log does not carry salary amounts', async () => {
    const t = setup();
    await t.run('admin', [t.op('admin', 'employee.salary', { employeeId: 'emp_mahmoud', fromMonth: '2026-11', monthlyAmount: 200000 })]);
    const logs = [...t.store.data.entries()].filter(([k]) => k.includes('/activity_log/')).map(([, v]) => JSON.stringify(v));
    expect(logs.join(' ')).not.toMatch(/2[,.]?000/);
  });
});

describe('accounts and schools', () => {
  it('a disabled user gets user_disabled', async () => {
    const t = setup();
    t.put('user', 'salma', { ...t.get('user', 'salma'), status: 'disabled' });
    await t.run('admin', [register(t)]);
    const [r] = await t.run('salma', [pay(t, 'salma', 'p1', 1000, '2026-10-19')]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'user_disabled' });
  });

  it('an op for another school leaves nothing in that school', async () => {
    const t = setup();
    const before = t.store.data.size;
    const op = { ...pay(t, 'admin', 'p1', 1000, '2026-10-19'), schoolId: 'other' };
    const [r] = await t.run('admin', [op]);
    expect(r.status).toBe('rejected');
    expect(t.store.data.size).toBe(before);
  });
});

describe('round 2: logins and cars', () => {
  it('Admin resets a password: logged, login updated after commit, never stored', async () => {
    const t = setup();
    const after: unknown[] = [];
    t.env.afterCommit = async (a) => { after.push(a); };
    const [r] = await t.run('admin', [t.op('admin', 'user.resetPassword', { userId: 'salma', password: 'abc12345' })]);
    expect(r.status).toBe('accepted');
    expect(after).toEqual([{ kind: 'resetPassword', uid: 'salma', password: 'abc12345' }]);
    const stored = JSON.stringify([...t.store.data.values()]);
    expect(stored).not.toContain('abc12345');
  });

  it('staff without "users" cannot reset; only an Admin resets an Admin; short passwords refused', async () => {
    const t = setup();
    t.put('user', 'admin2', { schoolId: 'sch1', name: 'مدير ٢', kind: 'admin', status: 'active', permissions: { tasks: {} }, permVersion: 1 });
    t.put('user', 'mgr', { schoolId: 'sch1', name: 'مسؤول', kind: 'staff', status: 'active', permVersion: 1, permissions: { tasks: { users: true } } });
    const [a] = await t.run('salma', [t.op('salma', 'user.resetPassword', { userId: 'mahmoud', password: 'abc12345' })]);
    const [b] = await t.run('mgr', [t.op('mgr', 'user.resetPassword', { userId: 'admin2', password: 'abc12345' })]);
    const [c] = await t.run('admin', [t.op('admin', 'user.resetPassword', { userId: 'mahmoud', password: '123' })]);
    expect(a).toMatchObject({ status: 'rejected', reason: 'permission_denied' });
    expect(b).toMatchObject({ status: 'rejected', reason: 'permission_denied' });
    expect(c).toMatchObject({ status: 'rejected', reason: 'invalid_payload' });
  });

  it("a student's login can be stopped from the student file", async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    t.put('user', 'st1', { schoolId: 'sch1', name: 'أحمد خالد', nationalId: '401234567', kind: 'student', status: 'active', studentId: 'st1', permissions: { tasks: {} }, permVersion: 1 });
    const [r] = await t.run('admin', [t.op('admin', 'user.status', { userId: 'st1', active: false })]);
    expect(r.status).toBe('accepted');
    expect(t.get('user', 'st1')).toMatchObject({ status: 'disabled' });
  });

  it('stopping an instructor ends his car links today', async () => {
    const t = setup();
    t.put('user', 'mahmoud', { ...t.get('user', 'mahmoud'), employeeId: 'emp_mahmoud' });
    t.store.data.set('schools/sch1/car_instructor/ci1', { id: 'ci1', carId: 'car1', employeeId: 'emp_mahmoud', from: '2026-10-01', to: null });
    await t.run('admin', [t.op('admin', 'user.status', { userId: 'mahmoud', active: false })]);
    expect(t.get('car_instructor', 'ci1')).toMatchObject({ to: '2026-10-19' });
  });

  it('a car can be renamed, and stopped only when no active student is on it', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    const [ren] = await t.run('admin', [t.op('admin', 'car.edit', { carId: 'car1', name: 'سيارة ١ الجديدة', plate: '12-345-67' })]);
    const [busy] = await t.run('admin', [t.op('admin', 'car.edit', { carId: 'car1', active: false })]);
    const [free] = await t.run('admin', [t.op('admin', 'car.edit', { carId: 'car2', active: false })]);
    expect(ren.status).toBe('accepted');
    expect(t.get('car', 'car1')).toMatchObject({ name: 'سيارة ١ الجديدة', plate: '12-345-67' });
    expect(busy).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
    expect(free.status).toBe('accepted');
    expect(t.get('car', 'car2')).toMatchObject({ active: false });
  });
});

describe('device time zones', () => {
  it('an evening payment made offline (local time without a zone) keeps its day', async () => {
    const t = setup('2026-10-18T08:00:00Z');
    await t.run('admin', [register(t, 'st1', 'en1', '401234567', '2026-10-18')]);
    t.setNow('2026-10-19T09:00:00Z');
    const op = { ...t.op('salma', 'payment.record', { paymentId: 'p1', movementId: 'mv_p1', enrollmentId: 'en1', accountId: 'cash', amount: 1000, purpose: 'general', receiptNo: 'R-1', businessDate: '2026-10-18' }), deviceTime: '2026-10-18T23:30:00.000' };
    const [r] = await t.run('salma', [op]);
    expect(r).toMatchObject({ status: 'accepted', flags: ['lateSync'] });
  });

  it('the same evening in UTC ("Z") also keeps its school day', async () => {
    const t = setup('2026-10-18T08:00:00Z');
    await t.run('admin', [register(t, 'st1', 'en1', '401234567', '2026-10-18')]);
    t.setNow('2026-10-19T09:00:00Z');
    // 23:30 in Hebron (UTC+3 in October) = 20:30Z
    const op = { ...t.op('salma', 'payment.record', { paymentId: 'p1', movementId: 'mv_p1', enrollmentId: 'en1', accountId: 'cash', amount: 1000, purpose: 'general', receiptNo: 'R-1', businessDate: '2026-10-18' }), deviceTime: '2026-10-18T20:30:00.000Z' };
    const [r] = await t.run('salma', [op]);
    expect(r).toMatchObject({ status: 'accepted', flags: ['lateSync'] });
  });
});
