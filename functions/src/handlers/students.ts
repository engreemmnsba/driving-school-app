import { requireTask } from '../core/permissions.js';
import { Reject, type LogChange } from '../core/types.js';
import { date, mustGet, optStr, priceAt, readSummary, str, summaryPath, type AfterCommit, type Handler, type Write } from '../core/context.js';

const NATIONAL_ID = /^\d{9}$/;

/** Registers a new student with a first enrollment and charges the registration fee. */
export const studentRegister: Handler = {
  creates: ['studentId', 'enrollmentId', 'chargeId'],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'addStudent');
    const studentId = str(p, 'studentId');
    const enrollmentId = str(p, 'enrollmentId');
    const chargeId = str(p, 'chargeId');
    const name = str(p, 'name').trim();
    const nationalId = str(p, 'nationalId').trim();
    const phone = optStr(p, 'phone');
    const tempPassword = optStr(p, 'tempPassword');
    if (name.length < 2) throw new Reject('invalid_payload', 'الاسم مطلوب');
    if (!NATIONAL_ID.test(nationalId)) throw new Reject('invalid_payload', 'رقم الهوية لازم يكون 9 أرقام');
    const licenseTypeId = str(p, 'licenseTypeId');
    const carId = str(p, 'carId');
    const businessDate = date(p, 'businessDate');

    const dup = await ctx.tx.query(ctx.col('student'), { nationalId });
    if (dup.length > 0) throw new Reject('rule_violation', 'رقم الهوية مسجّل لطالب ثاني · لإضافة رخصة جديدة لنفس الطالب');
    // One login per national ID (A12): a staff/instructor login on this ID would block the student's login.
    if ((await ctx.tx.query(ctx.col('user'), { nationalId })).length > 0) throw new Reject('rule_violation', 'رقم الهوية مستعمل لحساب موظف');
    const lt = await mustGet(ctx, 'license_type', licenseTypeId);
    if (lt.active === false) throw new Reject('rule_violation', 'نوع الرخصة موقوف');
    await mustGet(ctx, 'car', carId);
    const price = await priceAt(ctx, licenseTypeId, businessDate);
    const fee = price.registrationFee as number;
    const summary = await readSummary(ctx, enrollmentId, studentId);

    const writes: Write[] = [];
    const after: AfterCommit[] = [];
    if (tempPassword) {
      // The student's own login (uid = studentId). Password never stored in Firestore.
      if (tempPassword.length < 6) throw new Reject('invalid_payload', 'كلمة السر المؤقتة قصيرة');
      writes.push({ path: ctx.path('user', studentId), mode: 'set', data: { id: studentId, name, nationalId, kind: 'student', status: 'active', studentId, permissions: { tasks: {} }, permVersion: 1 } });
      after.push({ kind: 'createLogin', uid: studentId, nationalId, password: tempPassword, name, claims: { schoolId: ctx.op.schoolId, kind: 'student', studentId, permVersion: 1 } });
    }

    return {
      after,
      writes: [
        ...writes,
        { path: ctx.path('student', studentId), mode: 'set', data: { id: studentId, name, nationalId, phone: phone ?? null, archived: false } },
        { path: ctx.path('enrollment', enrollmentId), mode: 'set', data: { id: enrollmentId, studentId, studentName: name, licenseTypeId, carId, stage: 'theory', registeredOn: businessDate, archived: false, plannedTheory: (price.plannedTheoryLessons as number) ?? null, plannedPractical: (price.plannedPracticalLessons as number) ?? null } },
        { path: ctx.path('student_ledger', chargeId), mode: 'set', data: { id: chargeId, enrollmentId, studentId, kind: 'registration_fee', amount: fee, priceVersionId: price.id, businessDate } },
        { path: summaryPath(ctx, enrollmentId), mode: 'set', data: { ...summary, charged: summary.charged + fee } },
      ],
      log: [{ opType: 'create', entity: 'student', recordId: studentId, recordLabel: name, changes: [] }],
      assigned: { registrationFee: fee },
    };
  },
};

/** Edits a student's name / national ID / phone. Every change is logged "from A to B". */
export const studentEdit: Handler = {
  creates: [],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'editStudent');
    const studentId = str(p, 'studentId');
    const reason = optStr(p, 'reason');
    const st = await mustGet(ctx, 'student', studentId);
    const next: Record<string, string | null> = {};
    const name = optStr(p, 'name')?.trim();
    const nationalId = optStr(p, 'nationalId')?.trim();
    const phone = p.phone === null ? null : optStr(p, 'phone')?.trim();
    if (name !== undefined && name !== st.name) {
      if (name.length < 2) throw new Reject('invalid_payload', 'الاسم مطلوب');
      next.name = name;
    }
    if (nationalId !== undefined && nationalId !== st.nationalId) {
      if (!NATIONAL_ID.test(nationalId)) throw new Reject('invalid_payload', 'رقم الهوية لازم يكون 9 أرقام');
      const dup = await ctx.tx.query(ctx.col('student'), { nationalId });
      if (dup.some((d) => d.id !== studentId)) throw new Reject('rule_violation', 'رقم الهوية مسجّل لطالب ثاني');
      next.nationalId = nationalId;
    }
    if (phone !== undefined && (phone || null) !== (st.phone ?? null)) next.phone = phone || null;
    if (Object.keys(next).length === 0) throw new Reject('invalid_payload', 'ما في تغيير');

    const labels: Record<string, string> = { name: 'الاسم', nationalId: 'رقم الهوية', phone: 'الجوال' };
    const changes: LogChange[] = Object.entries(next).map(([k, v]) => ({ field: labels[k] ?? k, old: (st[k] as string | null) ?? null, new: v }));
    const writes: Write[] = [{ path: ctx.path('student', studentId), mode: 'merge', data: next }];
    if (next.name) {
      const enrollments = await ctx.tx.query(ctx.col('enrollment'), { studentId });
      for (const e of enrollments) writes.push({ path: ctx.path('enrollment', e.id as string), mode: 'merge', data: { studentName: next.name } });
    }
    const login = await ctx.tx.get(ctx.path('user', studentId));
    const after: AfterCommit[] = [];
    if (login && (next.name || next.nationalId)) {
      writes.push({ path: ctx.path('user', studentId), mode: 'merge', data: { ...(next.name ? { name: next.name } : {}), ...(next.nationalId ? { nationalId: next.nationalId } : {}) } });
      after.push({ kind: 'updateLogin', uid: studentId, nationalId: next.nationalId ?? undefined, name: next.name ?? undefined });
    }
    return {
      writes,
      after,
      log: [{ opType: 'edit', entity: 'student', recordId: studentId, recordLabel: (next.name ?? st.name) as string, changes, reason }],
    };
  },
};
