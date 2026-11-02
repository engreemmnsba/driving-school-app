/**
 * Security rules against the real Firestore emulator (needs it running on 127.0.0.1:8080:
 * `.\emulators.ps1` in another window), then `npm run test:rules`.
 *
 * Uses its own project id, so the demo data of the app is not touched.
 * For each person: every query the app makes when it pulls (same filters as FirestoreChangeSource)
 * is allowed, everything else is refused, single documents of other people are refused, and nobody
 * can write directly.
 */
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { afterAll, beforeAll, describe, it } from 'vitest';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { collection, doc, getDoc, getDocs, limit, orderBy, query, setDoc, where, type Firestore } from 'firebase/firestore';
import { claimsFor, jobPermissions } from '../src/core/claims.js';

const S = 'sch1';
const P = `schools/${S}`;
let env: RulesTestEnvironment;

/** Same list as app/lib/core/sync/puller.dart `pullCollectionsFor`. */
function pullCollectionsFor(kind: string, can: (t: string) => boolean, logAll: boolean): string[] {
  const admin = kind === 'admin';
  const staff = kind === 'staff';
  const instructor = kind === 'instructor';
  const student = kind === 'student';
  const allowed: Record<string, boolean> = {
    license_type: true,
    car: true,
    employee: !student,
    car_instructor: !student,
    treasury_account: admin || (staff && can('seeMoney')),
    student: (admin || staff || student) && !instructor,
    enrollment: true,
    lesson: true,
    student_ledger: admin || student || (staff && can('seeMoney')),
    treasury_movement: admin || (staff && can('cashbook')),
    license_price: admin || (staff && can('seeMoney')),
    student_summary: admin || student || (staff && can('seeMoney')),
    expense: admin || (staff && (can('seeExp') || can('addExp'))),
    account_balance: admin || (staff && can('seeBal')),
    day_close: admin || (staff && can('closeDay')),
    day_close_count: admin || (staff && can('closeDay')),
    exam: true,
    salary_rate: admin || (staff && can('payroll')),
    payroll_item: admin || (staff && can('payroll')),
    salary_payment: admin || (staff && can('payroll')),
    user: admin || (staff && can('users')),
    activity_log: admin || (staff && can('log') && logAll),
    month_lock: !student,
    setting: true,
  };
  return Object.keys(allowed).filter((c) => allowed[c]);
}
const ALL = pullCollectionsFor('admin', () => true, true);

type Person = {
  name: string;
  uid: string;
  claims: Record<string, unknown>;
  kind: string;
  tasks: Record<string, boolean>;
  logAll: boolean;
  scope: Record<string, [string, string[]]>;
  ownDocs: Record<string, string>;
};

function staffPerson(name: string, job: string): Person {
  const permissions = jobPermissions(job, ['cash']);
  return {
    name, uid: `u_${name}`, kind: 'staff', tasks: permissions.tasks as Record<string, boolean>,
    logAll: permissions.logScope === 'all', scope: {}, ownDocs: {},
    claims: claimsFor(S, { kind: 'staff', permissions, permVersion: 1 }, []),
  };
}
const admin: Person = { name: 'admin', uid: 'u_admin', kind: 'admin', tasks: {}, logAll: true, scope: {}, ownDocs: {}, claims: claimsFor(S, { kind: 'admin', permissions: { tasks: {} } as never, permVersion: 1 }, []) };
const accountant = staffPerson('accountant', 'accountant');
const secretary = staffPerson('secretary', 'secretary');
const instructorPerms = jobPermissions('instructor', ['cash']);
const instructor: Person = {
  name: 'instructor', uid: 'u_instr', kind: 'instructor', tasks: instructorPerms.tasks as Record<string, boolean>, logAll: false,
  scope: { enrollment: ['carId', ['car1']], lesson: ['scopeCarId', ['car1']], exam: ['scopeCarId', ['car1']] },
  ownDocs: {},
  claims: claimsFor(S, { kind: 'instructor', permissions: instructorPerms, permVersion: 1 }, ['car1']),
};
const studentScope = Object.fromEntries(['enrollment', 'lesson', 'exam', 'student_ledger', 'student_summary'].map((c) => [c, ['studentId', ['st1']] as [string, string[]]]));
const student: Person = {
  name: 'student', uid: 'u_st1', kind: 'student', tasks: {}, logAll: false, scope: studentScope, ownDocs: { student: 'st1' },
  claims: claimsFor(S, { kind: 'student', permissions: { tasks: {} } as never, permVersion: 1, studentId: 'st1' }, []),
};
const PEOPLE = [admin, accountant, secretary, instructor, student];

const db = (p: Person): Firestore => env.authenticatedContext(p.uid, p.claims).firestore() as unknown as Firestore;

/** Exactly what FirestoreChangeSource.fetch sends. */
function pull(fs: Firestore, p: Person, c: string): Promise<unknown> {
  const own = p.ownDocs[c];
  if (own) return getDoc(doc(fs, `${P}/${c}/${own}`));
  const s = p.scope[c];
  const base = collection(fs, `${P}/${c}`);
  const q = s
    ? query(base, where(s[0], 'in', s[1]), where('serverSeq', '>', 0), orderBy('serverSeq'), limit(500))
    : query(base, where('serverSeq', '>', 0), orderBy('serverSeq'), limit(500));
  return getDocs(q);
}

const today = new Date().toISOString().substring(0, 10);

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-rules-test',
    firestore: { host: '127.0.0.1', port: 8080, rules: readFileSync(resolve(dirname(fileURLToPath(import.meta.url)), '../../firebase/firestore.rules'), 'utf8') },
  });
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const fs = ctx.firestore() as unknown as Firestore;
    const put = (path: string, data: Record<string, unknown>) => setDoc(doc(fs, `${P}/${path}`), { schoolId: S, serverSeq: 1, serverTime: '2026-01-01T00:00:00.000Z', ...data });
    for (const c of ALL) await put(`${c}/x`, {});
    await put('student/st1', { name: 'Ahmad', nationalId: '401234567' });
    await put('student/st2', { name: 'Other', nationalId: '400000000' });
    await put('enrollment/e1', { studentId: 'st1', carId: 'car1' });
    await put('enrollment/e2', { studentId: 'st2', carId: 'car2' });
    await put('lesson/l1', { studentId: 'st1', scopeCarId: 'car1' });
    await put('lesson/l2', { studentId: 'st2', scopeCarId: 'car2' });
    await put('exam/x1', { studentId: 'st1', scopeCarId: 'car1' });
    await put('student_ledger/g1', { studentId: 'st1', amount: 100 });
    await put('student_ledger/g2', { studentId: 'st2', amount: 100 });
    await put('student_summary/st1', { studentId: 'st1' });
    await put('student_summary/st2', { studentId: 'st2' });
    await put('activity_log/a_own', { actorId: accountant.uid });
    await put('activity_log/a_other', { actorId: admin.uid });
    await put('treasury_movement/m_today', { businessDate: today, serverTime: new Date().toISOString() });
    await put('treasury_movement/m_old', { businessDate: '2026-01-01' });
    await put(`user/${secretary.uid}`, { name: 'secretary' });
    await put('ops/o1', {});
    await setDoc(doc(fs, `schools/other/student/z`), { schoolId: 'other', serverSeq: 1 });
  });
});

afterAll(async () => {
  await env?.cleanup();
});

describe('every pull the app makes is allowed; everything else is refused', () => {
  for (const p of PEOPLE) {
    const mine = pullCollectionsFor(p.kind, (t) => p.tasks[t] === true, p.logAll);
    it(`${p.name}: pulls ${mine.length} collections`, async () => {
      const fs = db(p);
      for (const c of mine) await assertSucceeds(pull(fs, p, c)).catch((e) => { throw new Error(`${p.name} can't pull ${c}: ${e}`); });
    });
    const notMine = ALL.filter((c) => !mine.includes(c));
    if (notMine.length) {
      it(`${p.name}: refused ${notMine.join(', ')}`, async () => {
        const fs = db(p);
        for (const c of notMine) {
          await assertFails(getDocs(query(collection(fs, `${P}/${c}`), limit(1)))).catch((e) => { throw new Error(`${p.name} CAN read ${c}: ${e}`); });
        }
      });
    }
  }
});

describe('single documents', () => {
  it('nobody signed out reads anything', async () => {
    const fs = env.unauthenticatedContext().firestore() as unknown as Firestore;
    await assertFails(getDoc(doc(fs, `${P}/car/x`)));
    await assertFails(getDoc(doc(fs, `${P}/student/st1`)));
  });

  it('another school is closed', async () => {
    await assertFails(getDoc(doc(db(admin), 'schools/other/student/z')));
  });

  it('nobody writes directly, not even the admin (only applyOps)', async () => {
    for (const p of PEOPLE) {
      await assertFails(setDoc(doc(db(p), `${P}/student_ledger/hack`), { studentId: 'st1', amount: -1000 }));
      await assertFails(setDoc(doc(db(p), `${P}/treasury_account/x`), { balance: 1 }));
    }
  });

  it('ops and rejected ids are server-only', async () => {
    await assertFails(getDoc(doc(db(admin), `${P}/ops/o1`)));
  });

  it("a student sees only their own things", async () => {
    const fs = db(student);
    await assertSucceeds(getDoc(doc(fs, `${P}/student/st1`)));
    await assertFails(getDoc(doc(fs, `${P}/student/st2`)));
    await assertFails(getDoc(doc(fs, `${P}/student_ledger/g2`)));
    await assertFails(getDoc(doc(fs, `${P}/enrollment/e2`)));
    await assertFails(getDocs(query(collection(fs, `${P}/student_ledger`), limit(5))));
  });

  it('an instructor sees their cars only, never money or national IDs', async () => {
    const fs = db(instructor);
    await assertSucceeds(getDoc(doc(fs, `${P}/enrollment/e1`)));
    await assertFails(getDoc(doc(fs, `${P}/enrollment/e2`)));
    await assertFails(getDoc(doc(fs, `${P}/lesson/l2`)));
    await assertFails(getDoc(doc(fs, `${P}/student/st1`)));
    await assertFails(getDoc(doc(fs, `${P}/student_ledger/g1`)));
    await assertFails(getDoc(doc(fs, `${P}/license_price/x`)));
    await assertFails(getDocs(query(collection(fs, `${P}/enrollment`), where('carId', 'in', ['car1', 'car2']))));
  });

  it("'own' activity log: own lines yes, others' no", async () => {
    const fs = db(accountant);
    await assertSucceeds(getDoc(doc(fs, `${P}/activity_log/a_own`)));
    await assertFails(getDoc(doc(fs, `${P}/activity_log/a_other`)));
  });

  it("cash book 'today': today's movement yes, an old one no", async () => {
    const fs = db(secretary); // seeMoney without cashbook → 'today'
    await assertSucceeds(getDoc(doc(fs, `${P}/treasury_movement/m_today`)));
    await assertFails(getDoc(doc(fs, `${P}/treasury_movement/m_old`)));
  });

  it('own user doc yes, someone else\'s no', async () => {
    await assertSucceeds(getDoc(doc(db(secretary), `${P}/user/${secretary.uid}`)));
    await assertFails(getDoc(doc(db(secretary), `${P}/user/${admin.uid}`)));
  });

  it('salaries: only admin / payroll permission', async () => {
    await assertSucceeds(getDoc(doc(db(admin), `${P}/salary_rate/x`)));
    for (const p of [accountant, secretary, instructor, student]) await assertFails(getDoc(doc(db(p), `${P}/salary_rate/x`)));
  });
});
