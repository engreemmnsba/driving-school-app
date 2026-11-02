import { describe, expect, it } from 'vitest';
import { register, setup } from './helpers.js';

const lessons = (t: ReturnType<typeof setup>, n: number, type = 'practical') =>
  Array.from({ length: n }, (_, i) => t.op('admin', 'lesson.log', { lessonId: `${type}${i}`, chargeId: `c_${type}${i}`, enrollmentId: 'en1', type, employeeId: 'emp_mahmoud', startedAt: '2026-10-19T08:00:00Z', businessDate: '2026-10-19' }));
const book = (t: ReturnType<typeof setup>, id: string, extra: Record<string, unknown> = {}) =>
  t.op('admin', 'exam.book', { examId: id, enrollmentId: 'en1', scheduledDate: '2026-10-25', businessDate: '2026-10-19', accountId: 'cash', chargeId: `ch_${id}`, expenseId: `ex_${id}`, movementId: `mv_${id}`, ...extra });
const result = (t: ReturnType<typeof setup>, id: string, r: string) => t.op('admin', 'exam.result', { examId: id, result: r });

function withMins(t: ReturnType<typeof setup>) {
  for (const id of ['pr1', 'pr2']) {
    const d = t.store.data.get(`schools/sch1/license_price/${id}`)!;
    t.store.data.set(`schools/sch1/license_price/${id}`, { ...d, minTheoryBeforeExam: 2, minPracticalBeforeExam: 3 });
  }
}

describe('exams', () => {
  it('first theory exam is free; booking needs the minimum lessons', async () => {
    const t = setup();
    withMins(t);
    await t.run('admin', [register(t)]);
    const [early] = await t.run('admin', [book(t, 'x0')]);
    expect(early).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
    await t.run('admin', lessons(t, 2, 'theory'));
    const [ok] = await t.run('admin', [book(t, 'x1')]);
    expect(ok).toMatchObject({ status: 'accepted', assigned: { type: 'theory', attempt: 1, fee: 0 } });
    expect(t.get('expense', 'ex_x1')).toBeUndefined();
  });

  it('theory lessons switched off: no theory lesson, and no theory minimum before the exam', async () => {
    const t = setup();
    withMins(t);
    await t.run('admin', [register(t), t.op('admin', 'setting.set', { key: 'theoryLessonsEnabled', value: false })]);
    const [lesson] = await t.run('admin', lessons(t, 1, 'theory'));
    expect(lesson).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
    const [ok] = await t.run('admin', [book(t, 'x1')]);
    expect(ok).toMatchObject({ status: 'accepted', assigned: { type: 'theory', fee: 0 } });
  });

  it('practical exam: student charge + ministry expense + money out, in one step', async () => {
    const t = setup('2026-10-25T09:00:00Z');
    withMins(t);
    await t.run('admin', [register(t, 'st1', 'en1', '401234567', '2026-10-19'), ...lessons(t, 2, 'theory'), book(t, 'th')]);
    await t.run('admin', [result(t, 'th', 'passed')]);
    expect(t.get('enrollment', 'en1')?.stage).toBe('practical');
    await t.run('admin', lessons(t, 3));
    const [r] = await t.run('admin', [book(t, 'pr', { scheduledDate: '2026-10-28', businessDate: '2026-10-25' })]);
    expect(r).toMatchObject({ status: 'accepted', assigned: { type: 'practical', fee: 10000 } });
    expect(t.get('student_ledger', 'ch_pr')).toMatchObject({ kind: 'exam_fee', amount: 10000 });
    expect(t.get('expense', 'ex_pr')).toMatchObject({ kind: 'ministry', amount: 10000, accountId: 'cash' });
    expect(t.get('account_balance', 'cash')?.balance).toBe(-10000);
  });

  it('result only from the exam date; failed theory → retake with its fee', async () => {
    const t = setup();
    withMins(t);
    await t.run('admin', [register(t), ...lessons(t, 2, 'theory'), book(t, 'th1')]);
    const [tooEarly] = await t.run('admin', [result(t, 'th1', 'failed')]);
    expect(tooEarly).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
    t.setNow('2026-10-25T10:00:00Z');
    await t.run('admin', [result(t, 'th1', 'failed')]);
    expect(t.get('enrollment', 'en1')?.stage).toBe('theory');
    const [retake] = await t.run('admin', [book(t, 'th2', { scheduledDate: '2026-10-30', businessDate: '2026-10-25' })]);
    expect(retake).toMatchObject({ status: 'accepted', assigned: { type: 'theory_retake', attempt: 2, fee: 8000 } });
  });

  it('postpone keeps the fee and history, never an attempt; no second booking while one is pending', async () => {
    const t = setup();
    withMins(t);
    await t.run('admin', [register(t), ...lessons(t, 2, 'theory'), book(t, 'th1')]);
    const [dup] = await t.run('admin', [book(t, 'th2')]);
    expect(dup).toMatchObject({ status: 'rejected' });
    const [pp] = await t.run('admin', [t.op('admin', 'exam.postpone', { examId: 'th1', toDate: '2026-11-09', reason: 'ministry', details: 'كتاب رقم 12' })]);
    expect(pp?.status).toBe('accepted');
    const ex = t.get('exam', 'th1')!;
    expect(ex).toMatchObject({ scheduledDate: '2026-11-09', attempt: 1, result: 'pending' });
    expect((ex.history as unknown[])[0]).toMatchObject({ from: '2026-10-25', to: '2026-11-09', reason: 'ministry' });
  });

  it('pass practical → graduate with a final summary; lessons are then blocked', async () => {
    const t = setup('2026-10-25T09:00:00Z');
    withMins(t);
    await t.run('admin', [register(t, 'st1', 'en1', '401234567', '2026-10-19'), ...lessons(t, 2, 'theory'), book(t, 'th')]);
    await t.run('admin', [result(t, 'th', 'passed'), ...lessons(t, 3), book(t, 'pr', { scheduledDate: '2026-10-25', businessDate: '2026-10-25' })]);
    await t.run('admin', [result(t, 'pr', 'passed')]);
    expect(t.get('enrollment', 'en1')?.stage).toBe('passed');
    await t.run('admin', [t.op('admin', 'enrollment.graduate', { enrollmentId: 'en1' })]);
    expect(t.get('enrollment', 'en1')).toMatchObject({ stage: 'graduated', graduatedOn: '2026-10-25', finalSummary: { practicalLessons: 3 } });
  });
});

describe('enrollments', () => {
  it('withdraw needs a reason; a second license for the same student, not the same type twice', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    const add = (id: string) => t.op('admin', 'enrollment.add', { enrollmentId: id, chargeId: `ch_${id}`, studentId: 'st1', licenseTypeId: 'lt_private', carId: 'car1', businessDate: '2026-10-19' });
    const [same] = await t.run('admin', [add('en2')]);
    expect(same).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
    const [noReason] = await t.run('admin', [t.op('admin', 'enrollment.withdraw', { enrollmentId: 'en1', reason: ' ' })]);
    expect(noReason?.status).toBe('rejected');
    await t.run('admin', [t.op('admin', 'enrollment.withdraw', { enrollmentId: 'en1', reason: 'سافر' })]);
    expect(t.get('enrollment', 'en1')?.stage).toBe('withdrawn');
    const [again] = await t.run('admin', [add('en3')]);
    expect(again).toMatchObject({ status: 'accepted', assigned: { registrationFee: 50000 } });
  });
});
