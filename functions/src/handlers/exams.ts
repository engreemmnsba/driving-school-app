import { requireAccount, requireTask } from '../core/permissions.js';
import { Reject } from '../core/types.js';
import { boolSetting, date, mustGet, optStr, priceAt, readSummary, shekel, str, summaryPath, type Handler, type Write } from '../core/context.js';

const TYPE_LABEL: Record<string, string> = { theory: 'نظري', theory_retake: 'إعادة نظري', practical: 'عملي' };
const REASONS: Record<string, string> = { ministry: 'الوزارة أجّلت', student: 'الطالب طلب', car: 'السيارة مش جاهزة', other: 'سبب ثاني' };

/**
 * Books an exam. One step: exam (pending) + student fee charge + ministry expense from an account (when the exam costs money).
 * First theory exam is covered by the registration fee. Minimum lessons are checked (Admin may override).
 */
export const examBook: Handler = {
  creates: ['examId', 'chargeId', 'expenseId', 'movementId'],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'exam');
    const examId = str(p, 'examId');
    const enrollmentId = str(p, 'enrollmentId');
    const scheduledDate = date(p, 'scheduledDate');
    const businessDate = date(p, 'businessDate');
    if (scheduledDate < ctx.today) throw new Reject('rule_violation', 'موعد الاختبار لازم يكون اليوم أو بعده');
    const enr = await mustGet(ctx, 'enrollment', enrollmentId);
    const stage = enr.stage as string;
    if (stage !== 'theory' && stage !== 'practical' && stage !== 'ready_practical') throw new Reject('rule_violation', 'الطالب مش بمرحلة اختبار');
    const exams = await ctx.tx.query(ctx.col('exam'), { enrollmentId });
    if (exams.some((e) => e.result === 'pending')) throw new Reject('rule_violation', 'في اختبار محجوز لسا ما إله نتيجة');
    const family = stage === 'theory' ? 'theory' : 'practical';
    const prior = exams.filter((e) => (family === 'theory' ? String(e.type).startsWith('theory') : e.type === 'practical'));
    const type = family === 'practical' ? 'practical' : prior.length === 0 ? 'theory' : 'theory_retake';
    const attempt = prior.length + 1;

    const price = await priceAt(ctx, enr.licenseTypeId as string, businessDate);
    const lessons = (await ctx.tx.query(ctx.col('lesson'), { enrollmentId, type: family })).filter((l) => !l.archived).length;
    // With theory lessons switched off (Settings), there is no theory minimum.
    const theoryOn = family === 'theory' ? await boolSetting(ctx, 'theoryLessonsEnabled', true) : true;
    const min = (family === 'theory' ? (theoryOn ? price.minTheoryBeforeExam : 0) : price.minPracticalBeforeExam) as number | undefined;
    const overridden = !!min && lessons < min;
    if (overridden && !(ctx.user.kind === 'admin' && p.override === true)) {
      throw new Reject('rule_violation', `لسا ${min - lessons} دروس للحد الأدنى (${min})`);
    }
    const fee = type === 'theory' ? 0 : ((type === 'practical' ? price.practicalExamFee : price.theoryRetakeFee) as number);
    const studentId = enr.studentId as string;
    const writes: Write[] = [];
    let summary;
    if (fee > 0) {
      const accountId = str(p, 'accountId');
      requireAccount(ctx.user, accountId);
      const acc = await mustGet(ctx, 'treasury_account', accountId);
      if (acc.active === false) throw new Reject('rule_violation', 'الصندوق موقوف');
      summary = await readSummary(ctx, enrollmentId, studentId);
      const chargeId = str(p, 'chargeId');
      const expenseId = str(p, 'expenseId');
      const movementId = str(p, 'movementId');
      const label = `رسوم اختبار ${TYPE_LABEL[type]} — ${enr.studentName as string}`;
      writes.push(
        { path: ctx.path('student_ledger', chargeId), mode: 'set', data: { id: chargeId, enrollmentId, studentId, kind: type === 'practical' ? 'exam_fee' : 'retake_fee', amount: fee, examId, priceVersionId: price.id, businessDate } },
        { path: ctx.path('expense', expenseId), mode: 'set', data: { id: expenseId, kind: 'ministry', item: 'رسوم اختبار', label, carId: null, liters: null, studentId, examId, amount: fee, accountId, note: null, businessDate, reversed: false } },
        { path: ctx.path('treasury_movement', movementId), mode: 'set', data: { id: movementId, accountId, direction: 'out', amount: fee, kind: 'expense', refId: expenseId, businessDate } },
        { path: summaryPath(ctx, enrollmentId), mode: 'set', data: { ...summary, charged: summary.charged + fee } },
      );
    }
    writes.push({
      path: ctx.path('exam', examId), mode: 'set',
      data: { id: examId, enrollmentId, studentId, studentName: enr.studentName, carId: family === 'practical' ? enr.carId : null, scopeCarId: enr.carId, type, attempt, scheduledDate, result: 'pending', fee, history: [] },
    });
    return {
      writes,
      log: [{
        opType: 'create', entity: 'exam', recordId: examId, recordLabel: `حجز اختبار ${TYPE_LABEL[type]} لـ${enr.studentName as string} · ${scheduledDate}${fee ? ` · ${shekel(fee)}` : ''}`,
        // A15: booking below the minimum lessons is an Admin override and is logged as such.
        changes: overridden ? [{ field: 'الحد الأدنى للدروس', old: `${lessons} من ${min}`, new: 'تجاوز من المدير' }] : [],
      }],
      assigned: { type, attempt, fee },
    };
  },
};

/** No cancellation — only postponement: new date + reason; the paid fee stays; not an attempt. */
export const examPostpone: Handler = {
  creates: [],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'exam');
    const examId = str(p, 'examId');
    const toDate = date(p, 'toDate');
    const reason = str(p, 'reason');
    if (!REASONS[reason]) throw new Reject('invalid_payload', 'سبب التأجيل غلط');
    const details = optStr(p, 'details')?.trim() || null;
    const exam = await mustGet(ctx, 'exam', examId);
    if (exam.result !== 'pending') throw new Reject('rule_violation', 'الاختبار إله نتيجة');
    if (toDate <= (exam.scheduledDate as string) || toDate < ctx.today) throw new Reject('rule_violation', 'الموعد الجديد لازم يكون بعد القديم');
    const history = [...((exam.history as unknown[]) ?? []), { from: exam.scheduledDate, to: toDate, reason, details, at: ctx.serverTime, by: ctx.user.name }];
    return {
      writes: [{ path: ctx.path('exam', examId), mode: 'merge', data: { scheduledDate: toDate, history } }],
      log: [{
        opType: 'postpone', entity: 'exam', recordId: examId,
        recordLabel: `اختبار ${exam.studentName as string} (${TYPE_LABEL[exam.type as string]})`,
        changes: [{ field: 'الموعد', old: exam.scheduledDate, new: toDate }],
        reason: `${REASONS[reason]}${details ? ` · ${details}` : ''}`,
      }],
    };
  },
};

/** Result only from the exam date. Theory passed → practical stage; practical passed → ready to graduate. */
export const examResult: Handler = {
  creates: [],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'exam');
    const examId = str(p, 'examId');
    const result = str(p, 'result');
    if (!['passed', 'failed', 'absent'].includes(result)) throw new Reject('invalid_payload', 'النتيجة غلط');
    const exam = await mustGet(ctx, 'exam', examId);
    if (exam.result !== 'pending') throw new Reject('rule_violation', 'النتيجة مسجّلة من قبل');
    if ((exam.scheduledDate as string) > ctx.today) throw new Reject('rule_violation', 'النتيجة بتنسجّل من يوم الاختبار');
    const writes: Write[] = [{ path: ctx.path('exam', examId), mode: 'merge', data: { result, resultBy: ctx.user.id, resultOn: ctx.today } }];
    if (result === 'passed') {
      const stage = exam.type === 'practical' ? 'passed' : 'practical';
      writes.push({ path: ctx.path('enrollment', exam.enrollmentId as string), mode: 'merge', data: { stage } });
    }
    const words: Record<string, string> = { passed: 'نجح', failed: 'رسب', absent: 'ما حضر' };
    return {
      writes,
      log: [{ opType: 'edit', entity: 'exam', recordId: examId, recordLabel: `اختبار ${exam.studentName as string} (${TYPE_LABEL[exam.type as string]})`, changes: [{ field: 'النتيجة', old: 'بانتظار', new: words[result] }] }],
    };
  },
};

/** After passing the practical exam: final summary and archive (per enrollment). */
export const enrollmentGraduate: Handler = {
  creates: [],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'exam');
    const enrollmentId = str(p, 'enrollmentId');
    const enr = await mustGet(ctx, 'enrollment', enrollmentId);
    if (enr.stage !== 'passed') throw new Reject('rule_violation', 'التخريج بعد النجاح بالعملي');
    const s = await readSummary(ctx, enrollmentId, enr.studentId as string);
    const finalSummary = { charged: s.charged, paid: s.paid, discounts: s.discounts, theoryLessons: s.theoryLessons, practicalLessons: s.practicalLessons };
    return {
      writes: [{ path: ctx.path('enrollment', enrollmentId), mode: 'merge', data: { stage: 'graduated', graduatedOn: ctx.today, finalSummary } }],
      log: [{ opType: 'archive', entity: 'enrollment', recordId: enrollmentId, recordLabel: `تخريج ${enr.studentName as string}`, changes: [{ field: 'المرحلة', old: 'نجح بالعملي', new: 'خرّيج' }] }],
    };
  },
};

/** Withdraw from a license (no refunds). */
export const enrollmentWithdraw: Handler = {
  creates: [],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'editStudent');
    const enrollmentId = str(p, 'enrollmentId');
    const reason = str(p, 'reason').trim();
    if (!reason) throw new Reject('invalid_payload', 'سبب الانسحاب مطلوب');
    const enr = await mustGet(ctx, 'enrollment', enrollmentId);
    if (enr.stage === 'graduated' || enr.stage === 'withdrawn') throw new Reject('rule_violation', 'الرخصة خالصة من قبل');
    // Only from theory/practical (docs/03): a student who passed is graduated, not withdrawn.
    if (enr.stage === 'passed') throw new Reject('rule_violation', 'الطالب ناجح · بيتخرّج مش بينسحب');
    const exams = await ctx.tx.query(ctx.col('exam'), { enrollmentId });
    if (exams.some((e) => e.result === 'pending')) throw new Reject('rule_violation', 'في اختبار محجوز · لازمه نتيجة أول');
    return {
      writes: [{ path: ctx.path('enrollment', enrollmentId), mode: 'merge', data: { stage: 'withdrawn', withdrawnOn: ctx.today, withdrawReason: reason } }],
      log: [{ opType: 'archive', entity: 'enrollment', recordId: enrollmentId, recordLabel: `انسحاب ${enr.studentName as string}`, changes: [{ field: 'المرحلة', old: enr.stage, new: 'منسحب' }], reason }],
    };
  },
};

/** A new license for an existing student (one active enrollment per license type). */
export const enrollmentAdd: Handler = {
  creates: ['enrollmentId', 'chargeId'],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'addStudent');
    const enrollmentId = str(p, 'enrollmentId');
    const chargeId = str(p, 'chargeId');
    const studentId = str(p, 'studentId');
    const licenseTypeId = str(p, 'licenseTypeId');
    const carId = str(p, 'carId');
    const businessDate = date(p, 'businessDate');
    const st = await mustGet(ctx, 'student', studentId);
    const lt = await mustGet(ctx, 'license_type', licenseTypeId);
    if (lt.active === false) throw new Reject('rule_violation', 'نوع الرخصة موقوف');
    await mustGet(ctx, 'car', carId);
    const existing = await ctx.tx.query(ctx.col('enrollment'), { studentId, licenseTypeId });
    if (existing.some((e) => e.stage !== 'graduated' && e.stage !== 'withdrawn')) throw new Reject('rule_violation', 'عنده هالرخصة شغّالة');
    const price = await priceAt(ctx, licenseTypeId, businessDate);
    const fee = price.registrationFee as number;
    const summary = await readSummary(ctx, enrollmentId, studentId);
    return {
      writes: [
        { path: ctx.path('enrollment', enrollmentId), mode: 'set', data: { id: enrollmentId, studentId, studentName: st.name, licenseTypeId, carId, stage: 'theory', registeredOn: businessDate, archived: false, plannedTheory: (price.plannedTheoryLessons as number) ?? null, plannedPractical: (price.plannedPracticalLessons as number) ?? null } },
        { path: ctx.path('student_ledger', chargeId), mode: 'set', data: { id: chargeId, enrollmentId, studentId, kind: 'registration_fee', amount: fee, priceVersionId: price.id, businessDate } },
        { path: summaryPath(ctx, enrollmentId), mode: 'set', data: { ...summary, charged: summary.charged + fee } },
      ],
      log: [{ opType: 'create', entity: 'enrollment', recordId: enrollmentId, recordLabel: `رخصة جديدة لـ${st.name as string}`, changes: [] }],
      assigned: { registrationFee: fee },
    };
  },
};

