import { requireAccount, requireTask } from '../core/permissions.js';
import { Reject } from '../core/types.js';
import { date, money, mustGet, optStr, readSummary, remaining, shekel, str, summaryPath, type Handler } from '../core/context.js';

const PURPOSES = ['lessons', 'registration', 'exam', 'general'];

/** Student pays into an allowed treasury account. */
export const paymentRecord: Handler = {
  creates: ['paymentId', 'movementId'],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'addPay');
    const paymentId = str(p, 'paymentId');
    const movementId = str(p, 'movementId');
    const enrollmentId = str(p, 'enrollmentId');
    const accountId = str(p, 'accountId');
    const amount = money(p, 'amount');
    const purpose = str(p, 'purpose');
    if (!PURPOSES.includes(purpose)) throw new Reject('invalid_payload', 'نوع الدفعة غلط');
    const receiptNo = str(p, 'receiptNo');
    const businessDate = date(p, 'businessDate');
    requireAccount(ctx.user, accountId);

    const enr = await mustGet(ctx, 'enrollment', enrollmentId);
    const account = await mustGet(ctx, 'treasury_account', accountId);
    if (account.active === false) throw new Reject('rule_violation', 'الصندوق موقوف');
    const studentId = enr.studentId as string;
    const summary = await readSummary(ctx, enrollmentId, studentId);

    return {
      writes: [
        { path: ctx.path('student_ledger', paymentId), mode: 'set', data: { id: paymentId, enrollmentId, studentId, kind: 'payment', amount, accountId, purpose, receiptNo, businessDate, reversed: false } },
        { path: ctx.path('treasury_movement', movementId), mode: 'set', data: { id: movementId, accountId, direction: 'in', amount, kind: 'student_payment', refId: paymentId, businessDate } },
        { path: summaryPath(ctx, enrollmentId), mode: 'set', data: { ...summary, paid: summary.paid + amount } },
      ],
      log: [{ opType: 'create', entity: 'payment', recordId: paymentId, recordLabel: `دفعة ${shekel(amount)} · وصل ${receiptNo}`, changes: [] }],
      assigned: { remaining: remaining({ ...summary, paid: summary.paid + amount }) },
    };
  },
};

/** Reverses a payment (correction or undo). Never deletes. */
export const paymentReverse: Handler = {
  creates: ['reversalId', 'movementId'],
  async run(ctx) {
    const p = ctx.op.payload;
    const paymentId = str(p, 'paymentId');
    const pay = await mustGet(ctx, 'student_ledger', paymentId);
    // The person who recorded it may undo it the same day (Undo snackbar); otherwise editPay is needed.
    const ownUndo = pay.createdBy === ctx.user.id && pay.businessDate === ctx.today;
    if (!ownUndo) requireTask(ctx.user, 'editPay');
    const reversalId = str(p, 'reversalId');
    const movementId = str(p, 'movementId');
    const reason = optStr(p, 'reason');
    const businessDate = date(p, 'businessDate');
    if (pay.kind !== 'payment') throw new Reject('rule_violation', 'هاد مش دفعة');
    if (pay.reversed === true) throw new Reject('rule_violation', 'الدفعة مرجّعة من قبل');

    const enrollmentId = pay.enrollmentId as string;
    const summary = await readSummary(ctx, enrollmentId, pay.studentId as string);
    const amount = pay.amount as number;
    return {
      writes: [
        { path: ctx.path('student_ledger', paymentId), mode: 'merge', data: { reversed: true, reversedBy: reversalId } },
        { path: ctx.path('student_ledger', reversalId), mode: 'set', data: { id: reversalId, enrollmentId, studentId: pay.studentId, kind: 'reversal', amount, reversesId: paymentId, reason: reason ?? null, businessDate } },
        { path: ctx.path('treasury_movement', movementId), mode: 'set', data: { id: movementId, accountId: pay.accountId, direction: 'out', amount, kind: 'student_payment', refId: reversalId, businessDate } },
        { path: summaryPath(ctx, enrollmentId), mode: 'set', data: { ...summary, paid: summary.paid - amount } },
      ],
      log: [{ opType: 'archive', entity: 'payment', recordId: paymentId, recordLabel: `دفعة ${shekel(amount)}`, changes: [{ field: 'الحالة', old: 'فعّالة', new: 'مرجّعة' }], reason }],
    };
  },
};

/** Discount for an enrollment, limited by the user's per-student maximum. */
export const discountGive: Handler = {
  creates: ['discountId'],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'discount');
    const discountId = str(p, 'discountId');
    const enrollmentId = str(p, 'enrollmentId');
    const amount = money(p, 'amount');
    const reason = optStr(p, 'reason');
    const businessDate = date(p, 'businessDate');
    const enr = await mustGet(ctx, 'enrollment', enrollmentId);
    const summary = await readSummary(ctx, enrollmentId, enr.studentId as string);
    const max = ctx.user.kind === 'admin' ? null : ctx.user.permissions.discountMax ?? 0;
    if (max !== null && summary.discounts + amount > max) {
      throw new Reject('discount_over_limit', `أقصى خصم مسموح لهالطالب ${shekel(max)}`);
    }
    return {
      writes: [
        { path: ctx.path('student_ledger', discountId), mode: 'set', data: { id: discountId, enrollmentId, studentId: enr.studentId, kind: 'discount', amount, reason: reason ?? null, businessDate } },
        { path: summaryPath(ctx, enrollmentId), mode: 'set', data: { ...summary, discounts: summary.discounts + amount } },
      ],
      log: [{ opType: 'create', entity: 'discount', recordId: discountId, recordLabel: `خصم ${shekel(amount)}`, changes: [], reason }],
    };
  },
};
