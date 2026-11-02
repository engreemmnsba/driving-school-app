// Seeds the LOCAL emulator with a demo school so the app can be tried end to end.
// Usage (emulators running in another window):  cd functions ; npm run seed
//   Empty school (Admin only):                   npm run seed -- --empty
// Refuses to touch anything but the local emulator. Running it again starts the demo school over:
// everything under schools/main is wiped first (except meta/head, so serverSeq keeps growing),
// otherwise old test entries stay next to fresh balances and the numbers stop adding up.
// After a re-seed: sign out and in on each phone/browser (local data is wiped on sign-out).
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

process.env.FIRESTORE_EMULATOR_HOST ??= '127.0.0.1:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST ??= '127.0.0.1:9099';
for (const v of ['FIRESTORE_EMULATOR_HOST', 'FIREBASE_AUTH_EMULATOR_HOST']) {
  if (!/^(127\.0\.0\.1|localhost):\d+$/.test(process.env[v])) throw new Error(`${v} must point to the local emulator`);
}

// Must match app/lib/core/auth/login_email.dart and functions/src/core/loginEmail.ts
const loginEmail = (nationalId) => `${nationalId}@login.your-firebase-project.web.app`;

// Demo accounts (emulator only — never used in production).
const SCHOOL = 'main';
const DEV_PASSWORD = 'Test#2026';
const ADMIN = { nationalId: '900000001', name: 'المدير (تجريبي)' };

initializeApp({ projectId: 'your-firebase-project' });
const auth = getAuth();
const db = getFirestore();
const p = (c, id) => `schools/${SCHOOL}/${c}/${id}`;

async function upsertAuthUser(uid, nationalId, name, claims) {
  const email = loginEmail(nationalId);
  try {
    const u = await auth.getUserByEmail(email);
    await auth.updateUser(u.uid, { password: DEV_PASSWORD, displayName: name, disabled: false });
    uid = u.uid;
  } catch {
    await auth.createUser({ uid, email, password: DEV_PASSWORD, displayName: name });
  }
  await auth.setCustomUserClaims(uid, { schoolId: SCHOOL, ...claims, permVersion: 1 });
  return uid;
}

const tz = 'Asia/Hebron';
const dayStr = (d) => new Intl.DateTimeFormat('en-CA', { timeZone: tz }).format(d);
const now = new Date();
const today = dayStr(now);
const daysAgo = (n) => dayStr(new Date(now.getTime() - n * 86400000));
const head = (await db.doc(`schools/${SCHOOL}/meta/head`).get()).data();
for (const col of await db.doc(`schools/${SCHOOL}`).listCollections()) {
  if (col.id !== 'meta') await db.recursiveDelete(col);
}
let seq = head?.serverSeq ?? 0;
const docs = [];
const put = (c, id, data) => {
  seq += 1;
  docs.push([p(c, id), { id, ...data, schoolId: SCHOOL, serverSeq: seq, serverTime: now.toISOString(), opId: `seed_${c}_${id}`, createdBy: 'seed' }]);
};

// ---------- people ----------
const adminUid = await upsertAuthUser('admin_demo', ADMIN.nationalId, ADMIN.name, { kind: 'admin' });
put('user', adminUid, { name: ADMIN.name, nationalId: ADMIN.nationalId, kind: 'admin', status: 'active', permissions: { tasks: {} }, permVersion: 1 });

// `npm run seed -- --empty`: a brand-new school with only the Admin login (to try setup from zero).
if (process.argv.some((a) => a.startsWith('--empty'))) {
  // Other demo logins would point at a school without their records: remove them.
  const { users } = await auth.listUsers(1000);
  for (const u of users) if (u.uid !== adminUid) await auth.deleteUser(u.uid);
  const batch = db.batch();
  for (const [path, data] of docs) batch.set(db.doc(path), data);
  batch.set(db.doc(`schools/${SCHOOL}/meta/head`), { serverSeq: seq });
  await batch.commit();
  console.log('Empty school ready (no licenses, accounts, cars, staff or students).');
  console.log(`  login: national ID ${ADMIN.nationalId} · password ${DEV_PASSWORD}`);
  console.log('  Sign out and in again in the app. For the demo data again: npm run seed');
  process.exit(0);
}
put('employee', 'emp_mahmoud', { name: 'محمود', role: 'instructor', active: true, userId: 'instructor_demo' });
put('employee', 'emp_sami', { name: 'سامي', role: 'instructor', active: true });
put('employee', 'emp_hiba', { name: 'هبة', role: 'staff', active: true });
for (const [e, amount] of [['emp_mahmoud', 150000], ['emp_sami', 150000], ['emp_hiba', 100000]]) {
  put('salary_rate', `${e}_2026-01`, { employeeId: e, effectiveFrom: '2026-01', monthlyAmount: amount });
}

// Demo instructor (Mahmoud, cars 1 and 3) and demo student (Ahmad) logins — same password.
const INSTRUCTOR = { nationalId: '900000002', name: 'محمود' };
const instructorUid = await upsertAuthUser('instructor_demo', INSTRUCTOR.nationalId, INSTRUCTOR.name, { kind: 'instructor', carIds: ['car1', 'car3'] });
put('user', instructorUid, { name: INSTRUCTOR.name, nationalId: INSTRUCTOR.nationalId, kind: 'instructor', status: 'active', employeeId: 'emp_mahmoud', job: 'instructor', permissions: { tasks: { students: true, lesson: true } }, permVersion: 1 });
const studentUid = await upsertAuthUser('ahmad', '401234567', 'أحمد خالد', { kind: 'student', studentId: 'ahmad' });
put('user', studentUid, { name: 'أحمد خالد', nationalId: '401234567', kind: 'student', status: 'active', studentId: 'ahmad', permissions: { tasks: {} }, permVersion: 1 });

// ---------- catalog ----------
const LT = [
  { id: 'lt_private', name: 'خصوصي', fee: 50000, lesson: 12000, exam: 10000, retake: 8000, planned: 10, sort: 1 },
  { id: 'lt_public', name: 'عمومي', fee: 60000, lesson: 14000, exam: 12000, retake: 8000, planned: 12, sort: 2 },
  { id: 'lt_moto', name: 'دراجة نارية', fee: 40000, lesson: 9000, exam: 8000, retake: 6000, planned: 8, sort: 3 },
];
for (const l of LT) {
  put('license_type', l.id, { name: l.name, active: true, sortOrder: l.sort });
  put('license_price', `pr_${l.id}`, {
    licenseTypeId: l.id, effectiveFrom: '2026-01-01', registrationFee: l.fee, practicalLessonPrice: l.lesson,
    theoryRetakeFee: l.retake, practicalExamFee: l.exam, plannedTheoryLessons: 8, plannedPracticalLessons: l.planned,
    minTheoryBeforeExam: 8, minPracticalBeforeExam: l.planned, practicalAfterTheory: true,
  });
}
put('car', 'car1', { name: 'سيارة 1', plate: '1-2345-90', gearbox: 'manual', active: true });
put('car', 'car2', { name: 'سيارة 2', plate: '1-6789-90', gearbox: 'auto', active: true });
put('car', 'car3', { name: 'سيارة 3', plate: '9-1111-90', gearbox: 'manual', active: true });
put('car_instructor', 'ci1', { carId: 'car1', employeeId: 'emp_mahmoud', from: '2026-01-01', to: null });
put('car_instructor', 'ci2', { carId: 'car2', employeeId: 'emp_sami', from: '2026-01-01', to: null });
put('car_instructor', 'ci3', { carId: 'car3', employeeId: 'emp_mahmoud', from: '2026-01-01', to: null });
const OPENING = { cash: 500000, wallet: 200000, bank: 1000000 };
const balance = { ...OPENING };
put('treasury_account', 'cash', { name: 'كاش', kind: 'cash', active: true, openingBalance: OPENING.cash, openingDate: '2026-01-01' });
put('treasury_account', 'wallet', { name: 'المحفظة', kind: 'wallet', active: true, openingBalance: OPENING.wallet, openingDate: '2026-01-01' });
put('treasury_account', 'bank', { name: 'البنك', kind: 'bank', active: true, openingBalance: OPENING.bank, openingDate: '2026-01-01' });

// ---------- students (consistent ledger + summary) ----------
const S = [
  { id: 'ahmad', name: 'أحمد خالد', nid: '401234567', phone: '0599123456', lt: 0, car: 'car1', stage: 'practical', theory: 8, practical: 7, pays: [[30000, 30, 'registration'], [50000, 0, 'lessons']], discount: 10000, runningMin: 33 },
  { id: 'sara', name: 'سارة يوسف', nid: '401234568', phone: '0599123457', lt: 0, car: 'car2', stage: 'practical', theory: 8, practical: 7, pays: [[50000, 40, 'registration'], [84000, 1, 'lessons']], runningMin: 14 },
  { id: 'rami', name: 'رامي عادل', nid: '401234569', phone: '0599123458', lt: 2, car: 'car3', stage: 'theory', theory: 8, practical: 0, pays: [[30000, 0, 'registration']] },
  { id: 'layan', name: 'ليان سمير', nid: '401234570', phone: '0599123459', lt: 0, car: 'car1', stage: 'practical', theory: 8, practical: 10, pays: [[50000, 60, 'registration'], [105000, 3, 'lessons']] },
  { id: 'mohammad', name: 'محمد نبيل', nid: '401234571', phone: '0599123460', lt: 1, car: 'car2', stage: 'practical', theory: 8, practical: 3, pays: [[60000, 20, 'registration'], [42000, 2, 'lessons']] },
];
const instructorOf = { car1: 'emp_mahmoud', car2: 'emp_sami', car3: 'emp_mahmoud' };
let receipt = 0;
for (const s of S) {
  const l = LT[s.lt];
  const en = `en_${s.id}`;
  let charged = l.fee, paid = 0, discounts = 0;
  put('student', s.id, { name: s.name, nationalId: s.nid, phone: s.phone, archived: false });
  put('enrollment', en, { studentId: s.id, studentName: s.name, licenseTypeId: l.id, carId: s.car, stage: s.stage, registeredOn: daysAgo(60), archived: false, plannedTheory: 8, plannedPractical: l.planned });
  put('student_ledger', `reg_${s.id}`, { enrollmentId: en, studentId: s.id, kind: 'registration_fee', amount: l.fee, priceVersionId: `pr_${l.id}`, businessDate: daysAgo(60), reversed: false });
  for (let i = 1; i <= s.theory; i++) {
    put('lesson', `${s.id}_t${i}`, { enrollmentId: en, studentId: s.id, type: 'theory', number: i, withoutDriving: false, employeeId: instructorOf[s.car], carId: null, scopeCarId: s.car, startedAt: `${daysAgo(58 - i)}T09:00:00Z`, businessDate: daysAgo(58 - i), archived: false });
  }
  for (let i = 1; i <= s.practical; i++) {
    const last = i === s.practical && s.runningMin;
    const started = last ? new Date(now.getTime() - s.runningMin * 60000) : new Date(`${daysAgo(2 * (s.practical - i) + 1)}T08:00:00Z`);
    const bd = dayStr(started);
    put('lesson', `${s.id}_p${i}`, { enrollmentId: en, studentId: s.id, type: 'practical', number: i, withoutDriving: false, employeeId: instructorOf[s.car], carId: s.car, scopeCarId: s.car, startedAt: started.toISOString(), businessDate: bd, archived: false });
    put('student_ledger', `ch_${s.id}_p${i}`, { enrollmentId: en, studentId: s.id, kind: 'lesson_charge', amount: l.lesson, lessonId: `${s.id}_p${i}`, priceVersionId: `pr_${l.id}`, businessDate: bd, reversed: false });
    charged += l.lesson;
  }
  for (const [amount, ago, purpose] of s.pays) {
    receipt += 1;
    const pid = `pay_${s.id}_${receipt}`;
    const bd = daysAgo(ago);
    put('student_ledger', pid, { enrollmentId: en, studentId: s.id, kind: 'payment', amount, accountId: 'cash', purpose, receiptNo: `0-${String(receipt).padStart(4, '0')}`, businessDate: bd, reversed: false });
    put('treasury_movement', `mv_${pid}`, { accountId: 'cash', direction: 'in', amount, kind: 'student_payment', refId: pid, businessDate: bd });
    balance.cash += amount;
    paid += amount;
  }
  if (s.discount) {
    put('student_ledger', `disc_${s.id}`, { enrollmentId: en, studentId: s.id, kind: 'discount', amount: s.discount, reason: 'خصم تجريبي', businessDate: daysAgo(10) });
    discounts += s.discount;
  }
  put('student_summary', en, { enrollmentId: en, studentId: s.id, charged, paid, discounts, theoryLessons: s.theory, practicalLessons: s.practical });
}

// ---------- exams: Layan's practical exam is today (needs a result); Yousef graduated ----------
put('exam', 'ex_layan_th', { enrollmentId: 'en_layan', studentId: 'layan', studentName: 'ليان سمير', carId: null, scopeCarId: 'car1', type: 'theory', attempt: 1, scheduledDate: daysAgo(30), result: 'passed', fee: 0, history: [] });
put('exam', 'ex_layan_pr', { enrollmentId: 'en_layan', studentId: 'layan', studentName: 'ليان سمير', carId: 'car1', scopeCarId: 'car1', type: 'practical', attempt: 1, scheduledDate: today, result: 'pending', fee: 10000,
  history: [{ from: daysAgo(3), to: today, reason: 'ministry', details: null, at: now.toISOString(), by: ADMIN.name }] });
put('student_ledger', 'ch_ex_layan_pr', { enrollmentId: 'en_layan', studentId: 'layan', kind: 'exam_fee', amount: 10000, examId: 'ex_layan_pr', businessDate: daysAgo(6) });
put('expense', 'ex_min_layan', { kind: 'ministry', item: 'رسوم اختبار', label: 'رسوم اختبار عملي — ليان سمير', carId: null, liters: null, studentId: 'layan', amount: 10000, accountId: 'cash', note: null, businessDate: daysAgo(6), reversed: false });
put('treasury_movement', 'mv_ex_min_layan', { accountId: 'cash', direction: 'out', amount: 10000, kind: 'expense', refId: 'ex_min_layan', businessDate: daysAgo(6) });
balance.cash -= 10000;
put('student_summary', 'en_layan', { enrollmentId: 'en_layan', studentId: 'layan', charged: 50000 + 10 * 12000 + 10000, paid: 155000, discounts: 0, theoryLessons: 8, practicalLessons: 10 });
put('student', 'yousef', { name: 'يوسف ماهر', nationalId: '401234590', phone: '0599123490', archived: false });
put('enrollment', 'en_yousef', { studentId: 'yousef', studentName: 'يوسف ماهر', licenseTypeId: 'lt_private', carId: 'car2', stage: 'graduated', registeredOn: daysAgo(120), graduatedOn: daysAgo(27), archived: false,
  finalSummary: { charged: 204000, paid: 196000, discounts: 8000, theoryLessons: 8, practicalLessons: 12 } });
put('student_summary', 'en_yousef', { enrollmentId: 'en_yousef', studentId: 'yousef', charged: 204000, paid: 196000, discounts: 8000, theoryLessons: 8, practicalLessons: 12 });

// ---------- expenses, a transfer, yesterday closed ----------
const EXP = [
  ['e_fuel_today', 'cars', 'بنزين', 'car2', 27000, 'cash', 0, 40],
  ['e_service', 'cars', 'صيانة', 'car2', 35000, 'cash', 4, null],
  ['e_power', 'other', 'كهرباء', null, 18000, 'wallet', 5, null],
  ['e_rent', 'other', 'إيجار', null, 60000, 'bank', 20, null],
  ['e_fuel_old', 'cars', 'بنزين', 'car1', 22000, 'wallet', 7, 35],
];
const carName = { car1: 'سيارة 1', car2: 'سيارة 2', car3: 'سيارة 3' };
for (const [id, kind, item, carId, amount, acc, ago, liters] of EXP) {
  const bd = daysAgo(ago);
  put('expense', id, { kind, item, label: carId ? `${item} ${carName[carId]}` : item, carId, liters, studentId: null, amount, accountId: acc, note: null, businessDate: bd, reversed: false });
  put('treasury_movement', `mv_${id}`, { accountId: acc, direction: 'out', amount, kind: 'expense', refId: id, businessDate: bd });
  balance[acc] -= amount;
}
put('treasury_movement', 'tr_out', { accountId: 'cash', direction: 'out', amount: 300000, kind: 'transfer_out', refId: 'tr_in', transferGroupId: 'tr_out', note: 'إيداع الكاش بالبنك', businessDate: daysAgo(3) });
put('treasury_movement', 'tr_in', { accountId: 'bank', direction: 'in', amount: 300000, kind: 'transfer_in', refId: 'tr_out', transferGroupId: 'tr_out', note: 'إيداع الكاش بالبنك', businessDate: daysAgo(3) });
balance.cash -= 300000;
balance.bank += 300000;
// ---------- payroll: last month paid for Mahmoud and Hiba; an advance this month for Sami ----------
const thisMonth = today.substring(0, 7);
const prevDate = new Date(now.getFullYear(), now.getMonth() - 1, 15);
const prevMonth = `${prevDate.getFullYear()}-${String(prevDate.getMonth() + 1).padStart(2, '0')}`;
const firstOfThis = `${thisMonth}-01`;
for (const [e, name, amount] of [['emp_mahmoud', 'محمود', 150000], ['emp_hiba', 'هبة', 100000]]) {
  const id = `sp_${e}_${prevMonth}`;
  put('salary_payment', id, { employeeId: e, employeeName: name, payrollMonth: prevMonth, salaryAtMonth: amount, bonuses: 0, deductions: 0, advances: 0, net: amount, accountId: 'bank', businessDate: firstOfThis, early: false, paidByName: ADMIN.name });
  put('treasury_movement', `mv_${id}`, { accountId: 'bank', direction: 'out', amount, kind: 'salary', refId: id, note: `راتب ${name} ${prevMonth}`, businessDate: firstOfThis });
  balance.bank -= amount;
}
put('payroll_item', 'pi_sami_adv', { employeeId: 'emp_sami', employeeName: 'سامي', payrollMonth: thisMonth, kind: 'advance', reason: 'سلفة', note: null, amount: 20000, accountId: 'cash', businessDate: daysAgo(2), recordedByName: ADMIN.name });
put('treasury_movement', 'mv_pi_sami_adv', { accountId: 'cash', direction: 'out', amount: 20000, kind: 'advance', refId: 'pi_sami_adv', note: 'سلفة سامي', businessDate: daysAgo(2) });
balance.cash -= 20000;
put('payroll_item', 'pi_mahmoud_bon', { employeeId: 'emp_mahmoud', employeeName: 'محمود', payrollMonth: thisMonth, kind: 'bonus', reason: 'إضافي', note: 'دوام يوم السبت', amount: 10000, accountId: null, businessDate: daysAgo(4), recordedByName: ADMIN.name });
for (const [acc, b] of Object.entries(balance)) put('account_balance', acc, { accountId: acc, balance: b });
// Earlier days are closed (one with a documented difference); 2 days ago is left open on purpose.
for (const ago of [1, 3, 4, 5, 7, 20, 30, 40, 60]) {
  const day = daysAgo(ago);
  const diff = ago === 4 ? -5000 : 0;
  put('day_close', day, { businessDate: day, state: 'closed', mode: 'full', closedBy: adminUid, closedByName: ADMIN.name, diffs: diff ? 1 : 0, lateEntries: 0 });
  put('day_close_count', `${day}_cash`, { dayCloseId: day, businessDate: day, accountId: 'cash', expected: 0, counted: diff, diff, reason: diff ? 'فكة رجعت لطالب وما انسجّلت' : null });
}

const batch = db.batch();
for (const [path, data] of docs) batch.set(db.doc(path), data);
batch.set(db.doc(`schools/${SCHOOL}/meta/head`), { serverSeq: seq });
await batch.commit();

console.log('Seeded the local emulator.');
console.log(`  login: national ID ${ADMIN.nationalId} · password ${DEV_PASSWORD}`);
console.log(`  instructor: ${INSTRUCTOR.nationalId} · student: 401234567 · same password`);
console.log('  Old demo data was wiped: sign out and in again in the app.');
console.log(`  school "${SCHOOL}" · ${docs.length} docs · ${S.length} students · 3 cars`);
process.exit(0);
