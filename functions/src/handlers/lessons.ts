import { requireTask } from '../core/permissions.js';
import { Reject } from '../core/types.js';
import { bool, boolSetting, date, numSetting, mustGet, optStr, priceAt, readSummary, shekel, str, summaryPath, type Handler, type Write } from '../core/context.js';

/** Logs a lesson. The server assigns the final number; practical lessons are charged at the price effective on businessDate. */
export const lessonLog: Handler = {
  creates: ['lessonId', 'chargeId'],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'lesson');
    const lessonId = str(p, 'lessonId');
    const enrollmentId = str(p, 'enrollmentId');
    const type = str(p, 'type');
    if (type !== 'theory' && type !== 'practical') throw new Reject('invalid_payload', 'نوع الدرس غلط');
    if (type === 'theory' && !(await boolSetting(ctx, 'theoryLessonsEnabled', true))) throw new Reject('rule_violation', 'تسجيل الدروس النظري مطفي من الإعدادات');
    const employeeId = str(p, 'employeeId');
    const startedAt = str(p, 'startedAt');
    const businessDate = date(p, 'businessDate');
    // "Without driving" only exists when the school turned it on (A25, default off).
    const withoutDriving = type === 'practical' && bool(p, 'withoutDriving') && (await boolSetting(ctx, 'withoutDrivingEnabled', false));

    const enr = await mustGet(ctx, 'enrollment', enrollmentId);
    if (['graduated', 'withdrawn', 'passed'].includes(enr.stage as string)) throw new Reject('rule_violation', 'الطالب خلص أو انسحب من هالرخصة');
    const carId = enr.carId as string;

    // Practical lessons start after the theory exam when the license says so (on by default).
    // With theory lessons switched off the theory part is the exam only, so the same rule applies.
    if (type === 'practical' && enr.stage === 'theory') {
      const price = await priceAt(ctx, enr.licenseTypeId as string, businessDate);
      if (price.practicalAfterTheory !== false) throw new Reject('rule_violation', 'الطالب لسا بمرحلة النظري · الدروس العملي بتبلّش بعد ما ينجح بالنظري');
    }

    // Instructors may only log under their own name, on a car they were on that day.
    if (ctx.user.kind === 'instructor') {
      let own = (ctx.user as unknown as { employeeId?: string }).employeeId;
      if (!own) own = (await ctx.tx.query(ctx.col('employee'), { userId: ctx.user.id }))[0]?.id as string | undefined;
      if (own !== employeeId) throw new Reject('permission_denied', 'الدرس بيتسجّل باسمك بس');
      const links = await ctx.tx.query(ctx.col('car_instructor'), { carId, employeeId });
      // A link that ended today still covers a lesson given today before the change (offline phones).
      const onCar = links.some((l) => (l.from === undefined || (l.from as string) <= businessDate) && (!l.to || (l.to as string) >= businessDate));
      if (!onCar) throw new Reject('permission_denied', 'هالسيارة مش إلك');
    }
    const emp = await mustGet(ctx, 'employee', employeeId);
    if (emp.role !== undefined && emp.role !== 'instructor') throw new Reject('rule_violation', 'الدرس لازم يكون باسم مدرب');

    // One running practical lesson per instructor when the instructor logs it live from the phone
    // (theory classes can be held together; staff entering several lessons later are not limited).
    if (type === 'practical' && ctx.user.kind === 'instructor') {
      const minutes = await numSetting(ctx, 'lessonDurationMin', 45);
      const start = Date.parse(startedAt);
      if (!Number.isFinite(start)) throw new Reject('invalid_payload', 'وقت بداية الدرس غلط');
      const sameDay = await ctx.tx.query(ctx.col('lesson'), { employeeId, businessDate });
      const clash = sameDay.find((l) => l.id !== lessonId && l.type === 'practical' && !l.archived && Math.abs(Date.parse(l.startedAt as string) - start) < minutes * 60_000);
      if (clash) throw new Reject('rule_violation', 'في درس عملي شغّال لهالمدرب بنفس الوقت');
    }

    const existing = await ctx.tx.query(ctx.col('lesson'), { enrollmentId, type });
    const number = existing.filter((l) => !l.archived).length + 1;
    const studentId = enr.studentId as string;
    const summary = await readSummary(ctx, enrollmentId, studentId);

    const writes: Write[] = [
      {
        path: ctx.path('lesson', lessonId), mode: 'set',
        data: { id: lessonId, enrollmentId, studentId, type, number, withoutDriving, employeeId, carId: type === 'practical' ? carId : null, scopeCarId: carId, startedAt, businessDate, archived: false },
      },
    ];
    let charge = 0;
    if (type === 'practical') {
      const chargeId = str(p, 'chargeId');
      const price = await priceAt(ctx, enr.licenseTypeId as string, businessDate);
      charge = price.practicalLessonPrice as number;
      writes.push({ path: ctx.path('student_ledger', chargeId), mode: 'set', data: { id: chargeId, enrollmentId, studentId, kind: 'lesson_charge', amount: charge, lessonId, priceVersionId: price.id, businessDate } });
    }
    writes.push({
      path: summaryPath(ctx, enrollmentId), mode: 'set',
      data: {
        ...summary,
        charged: summary.charged + charge,
        theoryLessons: summary.theoryLessons + (type === 'theory' ? 1 : 0),
        practicalLessons: summary.practicalLessons + (type === 'practical' ? 1 : 0),
      },
    });
    const label = (type === 'practical' ? 'درس عملي ' : 'درس نظري ') + number;
    return {
      writes,
      log: [{ opType: 'create', entity: 'lesson', recordId: lessonId, recordLabel: label, changes: [] }],
      assigned: { number, charge },
    };
  },
};

/**
 * Cancels the latest lesson of its type (the "Undo" after logging, or a correction).
 * Never deletes: the lesson is archived and its charge gets a charge_reversal row.
 */
export const lessonArchive: Handler = {
  creates: ['reversalId'],
  async run(ctx) {
    const p = ctx.op.payload;
    const lessonId = str(p, 'lessonId');
    const reason = optStr(p, 'reason');
    date(p, 'businessDate');
    const lesson = await mustGet(ctx, 'lesson', lessonId);
    if (lesson.archived === true) throw new Reject('rule_violation', 'الدرس ملغي من قبل');
    // The lesson's own month decides (the op's date is today): a locked month stays as it is.
    const lock = await ctx.tx.get(ctx.path('month_lock', (lesson.businessDate as string).substring(0, 7)));
    if (lock && lock.locked !== false) throw new Reject('month_locked', 'الشهر مثبّت · التصحيح بيصير بالشهر المفتوح');
    const enr = await mustGet(ctx, 'enrollment', lesson.enrollmentId as string);
    if (['graduated', 'withdrawn'].includes(enr.stage as string)) throw new Reject('rule_violation', 'حساب الطالب مقفل · ما بينلغى درس بعد التخرج أو الانسحاب');
    const own = lesson.createdBy === ctx.user.id && lesson.businessDate === ctx.deviceDay;
    if (!own) requireTask(ctx.user, 'editLesson');
    else requireTask(ctx.user, 'lesson');

    const enrollmentId = lesson.enrollmentId as string;
    const type = lesson.type as string;
    const same = (await ctx.tx.query(ctx.col('lesson'), { enrollmentId, type })).filter((l) => !l.archived);
    const latest = same.reduce((m, l) => Math.max(m, l.number as number), 0);
    if ((lesson.number as number) !== latest) throw new Reject('rule_violation', 'بس آخر درس بينلغى · الدروس اللي بعده لازم تنلغى أول');

    const summary = await readSummary(ctx, enrollmentId, lesson.studentId as string);
    const writes: Write[] = [{ path: ctx.path('lesson', lessonId), mode: 'merge', data: { archived: true } }];
    let refund = 0;
    if (type === 'practical') {
      const charges = (await ctx.tx.query(ctx.col('student_ledger'), { lessonId })).filter((c) => c.kind === 'lesson_charge' && c.reversed !== true);
      const reversalId = str(p, 'reversalId');
      for (const c of charges) {
        refund += c.amount as number;
        writes.push({ path: ctx.path('student_ledger', c.id as string), mode: 'merge', data: { reversed: true, reversedBy: reversalId } });
        writes.push({ path: ctx.path('student_ledger', reversalId), mode: 'set', data: { id: reversalId, enrollmentId, studentId: lesson.studentId, kind: 'charge_reversal', amount: c.amount, reversesId: c.id, lessonId, reason: reason ?? null, businessDate: lesson.businessDate } });
      }
    }
    writes.push({
      path: summaryPath(ctx, enrollmentId), mode: 'set',
      data: {
        ...summary,
        charged: summary.charged - refund,
        theoryLessons: summary.theoryLessons - (type === 'theory' ? 1 : 0),
        practicalLessons: summary.practicalLessons - (type === 'practical' ? 1 : 0),
      },
    });
    const label = (type === 'practical' ? 'درس عملي ' : 'درس نظري ') + String(lesson.number);
    return {
      writes,
      log: [{ opType: 'archive', entity: 'lesson', recordId: lessonId, recordLabel: label, changes: [{ field: 'الحالة', old: 'مسجّل', new: refund ? `ملغي · رجع ${shekel(refund)}` : 'ملغي' }], reason }],
    };
  },
};
