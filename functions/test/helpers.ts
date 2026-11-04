import { MemoryStore } from '../src/core/store.js';
import { applyOps, type ApplyEnv } from '../src/core/applyOps.js';
import type { Op, OpResult } from '../src/core/types.js';

// Base prices allow practical lessons in the theory stage so older scenarios stay simple;
// the "practical after theory" rule has its own tests (test/fixes.test.ts).
export const S = 'sch1';
export const P = (c: string, id: string) => `schools/${S}/${c}/${id}`;

export function setup(nowIso = '2026-10-19T09:00:00Z') {
  const store = new MemoryStore();
  let n = 0;
  let now = new Date(nowIso);
  const env: ApplyEnv = { store, now: () => now, newId: () => `log${++n}` };
  const put = (c: string, id: string, d: Record<string, unknown>) => store.data.set(P(c, id), { id, ...d });

  put('user', 'admin', { schoolId: S, name: 'المدير', kind: 'admin', status: 'active', permissions: { tasks: {} }, permVersion: 1 });
  put('user', 'salma', {
    schoolId: S, name: 'سلمى', kind: 'staff', status: 'active', permVersion: 1,
    permissions: { tasks: { students: true, seeMoney: true, addPay: true, discount: true, backdate: true }, allowedAccounts: ['cash'], discountMax: 5000, backdateDays: 2 },
  });
  put('user', 'mahmoud', { schoolId: S, name: 'محمود', kind: 'instructor', status: 'active', permVersion: 1, permissions: { tasks: { students: true, lesson: true } } });
  put('license_type', 'lt_private', { name: 'خصوصي', active: true });
  put('license_price', 'pr1', { licenseTypeId: 'lt_private', effectiveFrom: '2026-09-01', registrationFee: 50000, practicalLessonPrice: 10000, theoryRetakeFee: 8000, practicalExamFee: 10000, practicalAfterTheory: false });
  put('license_price', 'pr2', { licenseTypeId: 'lt_private', effectiveFrom: '2026-10-15', registrationFee: 50000, practicalLessonPrice: 12000, theoryRetakeFee: 8000, practicalExamFee: 10000, practicalAfterTheory: false });
  put('car', 'car1', { name: 'سيارة 1', active: true });
  put('car', 'car2', { name: 'سيارة 2', active: true });
  put('employee', 'emp_mahmoud', { name: 'محمود', role: 'instructor', userId: 'mahmoud', active: true });
  put('car_instructor', 'ci1', { carId: 'car1', employeeId: 'emp_mahmoud' });
  put('treasury_account', 'cash', { name: 'كاش', kind: 'cash', active: true });
  put('treasury_account', 'bank', { name: 'البنك', kind: 'bank', active: true });

  let seq = 0;
  const op = (userId: string, type: string, payload: Record<string, unknown>, opId?: string): Op => ({
    opId: opId ?? `op${++seq}`, schoolId: S, type, payload, deviceId: 'dev1', deviceSeq: seq, deviceTime: nowIso, userId,
  });
  const run = (userId: string, ops: Op[]): Promise<OpResult[]> => applyOps(env, userId, ops);
  const get = (c: string, id: string) => store.data.get(P(c, id));
  const setNow = (iso: string) => { now = new Date(iso); };
  return { store, env, put, op, run, get, setNow };
}

export function register(t: ReturnType<typeof setup>, sid = 'st1', eid = 'en1', nationalId = '401234567', businessDate = '2026-10-19', carId = 'car1') {
  return t.op('admin', 'student.register', {
    studentId: sid, enrollmentId: eid, chargeId: `ch_${eid}`, name: 'أحمد خالد', nationalId, phone: '0599123456',
    licenseTypeId: 'lt_private', carId, businessDate,
  });
}
