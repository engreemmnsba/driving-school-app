import { describe, expect, it } from 'vitest';
import { register, setup } from './helpers.js';
import type { AfterCommit } from '../src/core/context.js';

const lesson = (t: ReturnType<typeof setup>, user: string, id: string, type = 'practical') =>
  t.op(user, 'lesson.log', { lessonId: id, chargeId: `ch_${id}`, enrollmentId: 'en1', type, employeeId: 'emp_mahmoud', startedAt: '2026-10-19T08:00:00Z', businessDate: '2026-10-19' });
const undo = (t: ReturnType<typeof setup>, user: string, id: string) =>
  t.op(user, 'lesson.archive', { lessonId: id, reversalId: `rv_${id}`, businessDate: '2026-10-19' });

describe('student login on registration', () => {
  it('creates the login after commit, once, and never stores the password', async () => {
    const t = setup();
    const calls: AfterCommit[] = [];
    t.env.afterCommit = async (a) => { calls.push(a); };
    const op = t.op('admin', 'student.register', {
      studentId: 'st1', enrollmentId: 'en1', chargeId: 'ch_en1', name: 'أحمد خالد', nationalId: '401234567',
      licenseTypeId: 'lt_private', carId: 'car1', businessDate: '2026-10-19', tempPassword: 'abc12345',
    });
    await t.run('admin', [op]);
    await t.run('admin', [op]); // replay
    expect(calls).toHaveLength(1);
    expect(calls[0]).toMatchObject({ kind: 'createLogin', uid: 'st1', nationalId: '401234567', claims: { kind: 'student', studentId: 'st1' } });
    expect(t.get('user', 'st1')).toMatchObject({ kind: 'student', status: 'active' });
    expect(JSON.stringify([...t.store.data.values()])).not.toContain('abc12345');
  });

  it('rejects a bad national ID', async () => {
    const t = setup();
    const [r] = await t.run('admin', [register(t, 'st1', 'en1', '123')]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'invalid_payload' });
  });
});

describe('edit student', () => {
  it('logs each change from A to B and renames the enrollment', async () => {
    const t = setup();
    await t.run('admin', [register(t)]);
    const [r] = await t.run('admin', [t.op('admin', 'student.edit', { studentId: 'st1', phone: '0597654321', name: 'أحمد خالد سعيد', reason: 'غيّر رقمه' })]);
    expect(r?.status).toBe('accepted');
    expect(t.get('student', 'st1')).toMatchObject({ phone: '0597654321', name: 'أحمد خالد سعيد' });
    expect(t.get('enrollment', 'en1')?.studentName).toBe('أحمد خالد سعيد');
    const log = [...t.store.data.values()].find((d) => d.entity === 'student' && d.opType === 'edit')!;
    expect(log.changes).toEqual([
      { field: 'الاسم', old: 'أحمد خالد', new: 'أحمد خالد سعيد' },
      { field: 'الجوال', old: '0599123456', new: '0597654321' },
    ]);
  });

  it('refuses a national ID that belongs to another student', async () => {
    const t = setup();
    await t.run('admin', [register(t), register(t, 'st2', 'en2', '401234568')]);
    const [r] = await t.run('admin', [t.op('admin', 'student.edit', { studentId: 'st2', nationalId: '401234567' })]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
  });
});

describe('undo a lesson', () => {
  it('archives the latest practical lesson and gives the charge back', async () => {
    const t = setup();
    await t.run('admin', [register(t), lesson(t, 'admin', 'l1'), lesson(t, 'admin', 'l2')]);
    expect(t.get('student_summary', 'en1')).toMatchObject({ charged: 50000 + 2 * 12000, practicalLessons: 2 });
    const [r] = await t.run('admin', [undo(t, 'admin', 'l2')]);
    expect(r?.status).toBe('accepted');
    expect(t.get('lesson', 'l2')?.archived).toBe(true);
    expect(t.get('student_ledger', 'rv_l2')).toMatchObject({ kind: 'charge_reversal', amount: 12000, reversesId: 'ch_l2' });
    expect(t.get('student_summary', 'en1')).toMatchObject({ charged: 50000 + 12000, practicalLessons: 1 });
    // next lesson takes number 2 again
    const [n] = await t.run('admin', [lesson(t, 'admin', 'l3')]);
    expect(n).toMatchObject({ status: 'accepted', assigned: { number: 2 } });
  });

  it('only the latest lesson can be cancelled', async () => {
    const t = setup();
    await t.run('admin', [register(t), lesson(t, 'admin', 'l1'), lesson(t, 'admin', 'l2')]);
    const [r] = await t.run('admin', [undo(t, 'admin', 'l1')]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'rule_violation' });
  });

  it('staff without "edit lesson" cannot cancel someone else\'s lesson', async () => {
    const t = setup();
    t.put('user', 'salma', { schoolId: 'sch1', name: 'سلمى', kind: 'staff', status: 'active', permVersion: 1, permissions: { tasks: { students: true, lesson: true } } });
    await t.run('admin', [register(t), lesson(t, 'admin', 'l1')]);
    const [r] = await t.run('salma', [undo(t, 'salma', 'l1')]);
    expect(r).toMatchObject({ status: 'rejected', reason: 'permission_denied' });
  });
});
