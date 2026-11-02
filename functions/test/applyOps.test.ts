import { describe, expect, it } from 'vitest';
import { register, setup } from './helpers.js';
import { withDependencies, withoutDependents } from '../src/core/permissions.js';
import { sentenceAr } from '../src/core/logSentence.js';

const lesson = (t: ReturnType<typeof setup>, user: string, id: string, businessDate = '2026-10-19', enrollmentId = 'en1') =>
  t.op(user, 'lesson.log', { lessonId: id, chargeId: `ch_${id}`, enrollmentId, type: 'practical', employeeId: 'emp_mahmoud', startedAt: `${businessDate}T08:00:00Z`, businessDate });

const pay = (t: ReturnType<typeof setup>, user: string, id: string, amount: number, extra: Record<string, unknown> = {}) =>
  t.op(user, 'payment.record', { paymentId: id, movementId: `mv_${id}`, enrollmentId: 'en1', accountId: 'cash', amount, purpose: 'lessons', receiptNo: `1-${id}`, businessDate: '2026-10-19', ...extra });

describe('registration and money', () => {
  it('registers a student and charges the registration fee from Settings', async () => {
    const t = setup();
    const [r] = await t.run('admin', [register(t)]);
    expect(r?.status).toBe('accepted');
    expect(t.get('student_ledger', 'ch_en1')?.amount).toBe(50000);
    expect(t.get('student_summary', 'en1')?.charged).toBe(50000);
  });

  it('rejects a duplicate national ID', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    const [r] = await t.run('admin', [register(t, 'st2', 'en2')]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
  });

  it('computes remaining = charges − payments − discounts, and reversal restores it', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    await t.run('mahmoud', [lesson(t, 'mahmoud', 'l1')]);
    const [p] = await t.run('admin', [pay(t, 'admin', 'p1', 30000)]);
    expect(p?.status === 'accepted' && p.assigned?.remaining).toBe(50000 + 12000 - 30000);
    await t.run('admin', [t.op('admin', 'discount.give', { discountId: 'd1', enrollmentId: 'en1', amount: 10000, businessDate: '2026-10-19' })]);
    let s = t.get('student_summary', 'en1')!;
    expect((s.charged as number) - (s.paid as number) - (s.discounts as number)).toBe(22000);
    const [rv] = await t.run('admin', [t.op('admin', 'payment.reverse', { reversalId: 'rv1', movementId: 'mv_rv1', paymentId: 'p1', reason: 'خطأ بالإدخال', businessDate: '2026-10-19' })]);
    expect(rv?.status).toBe('accepted');
    s = t.get('student_summary', 'en1')!;
    expect(s.paid).toBe(0);
    expect(t.get('student_ledger', 'p1')?.reversed).toBe(true); // never deleted
    const [again] = await t.run('admin', [t.op('admin', 'payment.reverse', { reversalId: 'rv2', movementId: 'mv_rv2', paymentId: 'p1', businessDate: '2026-10-19' })]);
    expect(again).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
  });
});

describe('lessons', () => {
  it('charges each practical lesson at the price effective on its business date', async () => {
    const t = setup();
    await t.run('admin', [register(t, 'st1', 'en1', '401234567', '2026-10-10')]);
    await t.run('admin', [lesson(t, 'admin', 'old', '2026-10-12'), lesson(t, 'admin', 'new', '2026-10-19')]);
    expect(t.get('student_ledger', 'ch_old')?.amount).toBe(10000);
    expect(t.get('student_ledger', 'ch_new')?.amount).toBe(12000);
  });

  it('numbers lessons on the server: two offline phones both saying "8" end up 1 and 2', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    const [a] = await t.run('mahmoud', [lesson(t, 'mahmoud', 'la')]);
    const [b] = await t.run('admin', [lesson(t, 'admin', 'lb')]);
    expect(a?.status === 'accepted' && a.assigned?.number).toBe(1);
    expect(b?.status === 'accepted' && b.assigned?.number).toBe(2);
  });

  it('stops an instructor from logging on a car that is not theirs', async () => {
    const t = setup();
    await t.run('admin', [register(t, 'st1', 'en1', '401234567', '2026-10-19', 'car2')]);
    const [r] = await t.run('mahmoud', [lesson(t, 'mahmoud', 'lx')]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'permission_denied' });
  });
});

describe('sync guarantees', () => {
  it('is idempotent: resending the same op does nothing twice', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    const o = pay(t, 'admin', 'p1', 50000);
    const [first] = await t.run('admin', [o]);
    const [second] = await t.run('admin', [o]);
    expect(second).toEqual(first);
    expect(t.get('student_summary', 'en1')?.paid).toBe(50000);
  });

  it('assigns a strictly increasing serverSeq', async () => {
    const t = setup();
    const rs = await t.run('admin', [register(t), lesson(t, 'admin', 'l1'), pay(t, 'admin', 'p1', 100)]);
    const seqs = rs.map((r) => (r.status === 'accepted' ? r.serverSeq : -1));
    expect(seqs).toEqual([1, 2, 3]);
  });

  it('rejects ops made after a permission was revoked (offline phone)', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    const user = t.get('user', 'salma')!;
    (user.permissions as { tasks: Record<string, boolean> }).tasks.addPay = false;
    const [r] = await t.run('salma', [pay(t, 'salma', 'p1', 1000)]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'permission_denied' });
  });

  it('rejects dependents of a rejected op with depends_on_rejected', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    const [p, rv] = await t.run('salma', [
      pay(t, 'salma', 'p1', 1000, { accountId: 'bank' }), // not allowed → rejected
      t.op('salma', 'payment.reverse', { reversalId: 'rv1', movementId: 'mv_rv1', paymentId: 'p1', businessDate: '2026-10-19' }),
    ]);
    expect(p).toMatchObject({ status: 'rejected', reason: 'account_not_allowed' });
    expect(rv).toMatchObject({ status: 'rejected', reason: 'depends_on_rejected' });
  });

  it('accepts entries for a closed day but flags them late, and rejects a locked month', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    t.put('day_close', '2026-10-19', { state: 'closed', lateEntries: 0 });
    const [late] = await t.run('admin', [pay(t, 'admin', 'p1', 1000)]);
    expect(late?.status === 'accepted' && late.flags).toEqual(['lateAfterClose']);
    expect(t.get('day_close', '2026-10-19')?.lateEntries).toBe(1);
    t.put('month_lock', '2026-09', { lockedBy: 'admin' });
    const [locked] = await t.run('admin', [pay(t, 'admin', 'p2', 1000, { businessDate: '2026-09-30' })]);
    expect(locked).toMatchObject({ status: 'rejected', reason: 'month_locked' });
  });

  it('enforces back-dating limits and refuses future dates', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    const [ok] = await t.run('salma', [pay(t, 'salma', 'p1', 1000, { businessDate: '2026-10-17' })]);
    const [tooOld] = await t.run('salma', [pay(t, 'salma', 'p2', 1000, { businessDate: '2026-10-16' })]);
    const [future] = await t.run('admin', [pay(t, 'admin', 'p3', 1000, { businessDate: '2026-10-20' })]);
    expect(ok?.status).toBe('accepted');
    expect(tooOld).toMatchObject({ status: 'rejected', reason: 'backdate_not_allowed' });
    expect(future).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
  });

  it('applies a whole op atomically: a rejected op leaves no partial writes', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    const before = t.store.data.size;
    await t.run('salma', [pay(t, 'salma', 'p1', 1000, { accountId: 'bank' })]);
    // only the op record + rejected id markers are added
    const added = [...t.store.data.keys()].filter((k) => k.includes('/ops/') || k.includes('/rejected_ids/')).length;
    expect(t.store.data.size - before).toBe(added - 1); // the register op record existed before
    expect(t.get('student_ledger', 'p1')).toBeUndefined();
  });
});

describe('limits & permissions', () => {
  it('limits discounts to the user maximum per student', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    const d = (id: string, amount: number) => t.op('salma', 'discount.give', { discountId: id, enrollmentId: 'en1', amount, businessDate: '2026-10-19' });
    const [a] = await t.run('salma', [d('d1', 3000)]);
    const [b] = await t.run('salma', [d('d2', 3000)]);
    expect(a?.status).toBe('accepted');
    expect(b).toMatchObject({ status: 'rejected', reason: 'discount_over_limit' });
  });

  it('resolves permission dependencies both ways', () => {
    expect(withDependencies({ editPay: true })).toMatchObject({ editPay: true, addPay: true, seeMoney: true, students: true });
    expect(withoutDependents({ students: true, seeMoney: true, addPay: true, editPay: true }, 'seeMoney')).toMatchObject({ seeMoney: false, addPay: false, editPay: false, students: true });
  });

  it('logs price changes as "from A to B" and renders a gender-neutral sentence', async () => {
    const t = setup();
    await t.run('admin', [t.op('admin', 'licensePrice.set', {
      priceId: 'pr3', licenseTypeId: 'lt_private', effectiveFrom: '2026-10-19',
      registrationFee: 50000, practicalLessonPrice: 13000, theoryRetakeFee: 8000, practicalExamFee: 10000,
      plannedTheoryLessons: 10, plannedPracticalLessons: 10, minTheoryBeforeExam: 10, minPracticalBeforeExam: 10,
    })]);
    const log = [...t.store.data.values()].find((d) => d.entity === 'license_price')!;
    const changes = log.changes as { field: string; old: unknown; new: unknown }[];
    expect(changes).toEqual([{ field: 'سعر الدرس العملي (خصوصي)', old: '₪120', new: '₪130' }]);
    expect(sentenceAr('سلمى', 'خصوصي', changes[0]!)).toBe('تغيير سعر الدرس العملي (خصوصي) لـخصوصي من ₪120 إلى ₪130 · بواسطة سلمى');
  });
});
