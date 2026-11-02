import { requireTask } from '../core/permissions.js';
import { Reject, type LogChange } from '../core/types.js';
import { date, mustGet, shekel, str, type Handler } from '../core/context.js';

const FEES = ['registrationFee', 'practicalLessonPrice', 'theoryRetakeFee', 'practicalExamFee'] as const;
const FEE_LABELS: Record<(typeof FEES)[number], string> = {
  registrationFee: 'رسوم التسجيل',
  practicalLessonPrice: 'سعر الدرس العملي',
  theoryRetakeFee: 'رسوم إعادة النظري',
  practicalExamFee: 'رسوم الاختبار العملي',
};

/** New price version for a license type, effective from a date (old charges never change). */
export const licensePriceSet: Handler = {
  creates: ['priceId'],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'settings');
    const priceId = str(p, 'priceId');
    const licenseTypeId = str(p, 'licenseTypeId');
    const effectiveFrom = date(p, 'effectiveFrom');
    const lt = await mustGet(ctx, 'license_type', licenseTypeId);
    const data: Record<string, unknown> = { id: priceId, licenseTypeId, effectiveFrom };
    for (const k of FEES) {
      const v = p[k];
      if (typeof v !== 'number' || !Number.isInteger(v) || v < 0) throw new Reject('invalid_payload', `${FEE_LABELS[k]} لازم يكون رقم`);
      data[k] = v;
    }
    for (const k of ['plannedTheoryLessons', 'plannedPracticalLessons', 'minTheoryBeforeExam', 'minPracticalBeforeExam']) {
      const v = p[k];
      if (typeof v !== 'number' || !Number.isInteger(v) || v < 0) throw new Reject('invalid_payload', `حقل غلط: ${k}`);
      data[k] = v;
    }
    data.practicalAfterTheory = p.practicalAfterTheory !== false;

    // Previous version (for the "from A to B" log sentence).
    const all = await ctx.tx.query(ctx.col('license_price'), { licenseTypeId });
    const prev = all.sort((a, b) => ((a.effectiveFrom as string) < (b.effectiveFrom as string) ? 1 : -1))[0];
    const changes: LogChange[] = [];
    for (const k of FEES) {
      const oldV = prev ? (prev[k] as number) : null;
      if (oldV !== data[k]) changes.push({ field: `${FEE_LABELS[k]} (${lt.name as string})`, old: oldV === null ? null : shekel(oldV), new: shekel(data[k] as number) });
    }
    return {
      writes: [{ path: ctx.path('license_price', priceId), mode: 'set', data }],
      log: [{ opType: 'settings', entity: 'license_price', recordId: priceId, recordLabel: lt.name as string, changes, reason: `من تاريخ ${effectiveFrom}` }],
    };
  },
};

// ---------------------------------------------------------------- batch 6

const NUM_SETTINGS: Record<string, { label: string; min: number; max: number; money?: boolean }> = {
  lessonDurationMin: { label: 'مدة الدرس (دقيقة)', min: 10, max: 180 },
  closeReminderHour: { label: 'تذكير إغلاق اليوم (الساعة)', min: 12, max: 23 },
  overdueAmount: { label: 'الدين المتأخر فوق', min: 0, max: 10_000_000, money: true },
  overdueDays: { label: 'بدون دفع من (يوم)', min: 1, max: 365 },
  salaryDueDay: { label: 'يوم صرف الرواتب (0 = آخر الشهر)', min: 0, max: 28 },
};
const BOOL_SETTINGS: Record<string, string> = { withoutDrivingEnabled: 'خيار درس بدون تشغيل', theoryLessonsEnabled: 'تسجيل الدروس النظري' };

/** Same defaults as the app (settings_queries.dart), so the log says "from on to off", not "from — to off". */
const BOOL_DEFAULTS: Record<string, boolean> = { withoutDrivingEnabled: false, theoryLessonsEnabled: true };

function show(key: string, v: unknown): string {
  if ((v === undefined || v === null) && key in BOOL_DEFAULTS) v = BOOL_DEFAULTS[key];
  if (v === undefined || v === null) return '—';
  if (typeof v === 'boolean') return v ? 'مفعّل' : 'مطفي';
  if (NUM_SETTINGS[key]?.money) return shekel(v as number);
  if (key === 'salaryDueDay') return v === 0 ? 'آخر الشهر' : String(v);
  return String(v);
}

/** One general setting (whitelisted keys, validated ranges). The old value goes to the log. */
export const settingSet: Handler = {
  creates: [],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'settings');
    const key = str(p, 'key');
    const value = p.value;
    if (NUM_SETTINGS[key]) {
      const r = NUM_SETTINGS[key];
      if (typeof value !== 'number' || !Number.isInteger(value) || value < r.min || value > r.max) throw new Reject('invalid_payload', `${r.label}: رقم بين ${r.min} و ${r.max}`);
    } else if (BOOL_SETTINGS[key]) {
      if (typeof value !== 'boolean') throw new Reject('invalid_payload', 'القيمة لازم تكون مفعّل أو مطفي');
    } else if (key === 'appVersion') {
      if (ctx.user.kind !== 'admin') throw new Reject('permission_denied', 'بس المدير بينشر تحديث');
      const v = value as Record<string, unknown> | null;
      if (!v || typeof v.version !== 'string' || typeof v.build !== 'number' || !Number.isInteger(v.build) || v.build < 1) throw new Reject('invalid_payload', 'رقم الإصدار ناقص');
      if (typeof v.apkUrl !== 'string' || !/^https:\/\//.test(v.apkUrl)) throw new Reject('invalid_payload', 'رابط التنزيل لازم يبدأ بـ https://');
    } else if (key === 'school') {
      const v = value as Record<string, unknown> | null;
      if (!v || typeof v.name !== 'string' || v.name.trim().length < 2) throw new Reject('invalid_payload', 'اسم المدرسة مطلوب');
    } else {
      throw new Reject('invalid_payload', `إعداد مش معروف: ${key}`);
    }
    const cur = await ctx.tx.get(ctx.path('setting', key));
    const label = NUM_SETTINGS[key]?.label ?? BOOL_SETTINGS[key] ?? (key === 'appVersion' ? 'إصدار التطبيق' : 'بيانات المدرسة');
    const clean = key === 'school'
      ? { name: ((value as Record<string, unknown>).name as string).trim(), phone: ((value as Record<string, unknown>).phone as string | undefined)?.trim() || null, address: ((value as Record<string, unknown>).address as string | undefined)?.trim() || null }
      : value;
    const changes: LogChange[] = key === 'school'
      ? Object.entries(clean as Record<string, unknown>)
          .filter(([k, v]) => ((cur?.value as Record<string, unknown> | undefined)?.[k] ?? null) !== v)
          .map(([k, v]) => ({ field: { name: 'اسم المدرسة', phone: 'الهاتف', address: 'العنوان' }[k] ?? k, old: ((cur?.value as Record<string, unknown> | undefined)?.[k] as string) ?? null, new: v }))
      : key === 'appVersion'
        ? [{ field: label, old: ((cur?.value as Record<string, unknown> | undefined)?.version as string) ?? null, new: (clean as Record<string, unknown>).version }]
        : [{ field: label, old: show(key, cur?.value), new: show(key, clean) }];
    if (changes.length === 0 || (key !== 'school' && JSON.stringify(cur?.value) === JSON.stringify(clean))) throw new Reject('invalid_payload', 'ما في تغيير');
    return {
      writes: [{ path: ctx.path('setting', key), mode: 'set', data: { id: key, key, value: clean } }],
      log: [{ opType: 'settings', entity: 'setting', recordId: key, recordLabel: label, changes }],
    };
  },
};

/** A new license type (its prices come right after with licensePrice.set). */
export const licenseTypeAdd: Handler = {
  creates: ['licenseTypeId'],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'settings');
    const id = str(p, 'licenseTypeId');
    const name = str(p, 'name').trim();
    if (name.length < 2) throw new Reject('invalid_payload', 'اسم الرخصة مطلوب');
    const same = await ctx.tx.query(ctx.col('license_type'), { name });
    if (same.length) throw new Reject('rule_violation', 'في رخصة بنفس الاسم');
    const sortOrder = typeof p.sortOrder === 'number' ? p.sortOrder : 99;
    return {
      writes: [{ path: ctx.path('license_type', id), mode: 'set', data: { id, name, active: true, sortOrder } }],
      log: [{ opType: 'settings', entity: 'license_type', recordId: id, recordLabel: name, changes: [{ field: 'نوع رخصة', old: null, new: name }] }],
    };
  },
};

/** Rename a license type or stop offering it (existing students keep it). */
export const licenseTypeEdit: Handler = {
  creates: [],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'settings');
    const id = str(p, 'licenseTypeId');
    const lt = await mustGet(ctx, 'license_type', id);
    const data: Record<string, unknown> = {};
    const changes: LogChange[] = [];
    if (typeof p.name === 'string' && p.name.trim() && p.name.trim() !== lt.name) {
      data.name = p.name.trim();
      changes.push({ field: 'الاسم', old: lt.name, new: data.name });
    }
    if (typeof p.active === 'boolean' && p.active !== (lt.active !== false)) {
      data.active = p.active;
      changes.push({ field: 'الحالة', old: lt.active !== false ? 'متاحة' : 'موقوفة', new: p.active ? 'متاحة' : 'موقوفة' });
    }
    if (!changes.length) throw new Reject('invalid_payload', 'ما في تغيير');
    return {
      writes: [{ path: ctx.path('license_type', id), mode: 'merge', data }],
      log: [{ opType: 'settings', entity: 'license_type', recordId: id, recordLabel: (data.name ?? lt.name) as string, changes }],
    };
  },
};

const ACCOUNT_KINDS: Record<string, string> = { cash: 'كاش', wallet: 'محفظة', bank: 'بنك' };

/** New treasury account with its opening balance (the balance starts from it). */
export const accountAdd: Handler = {
  creates: ['accountId'],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'settings');
    const id = str(p, 'accountId');
    const name = str(p, 'name').trim();
    const kind = str(p, 'kind');
    if (!ACCOUNT_KINDS[kind]) throw new Reject('invalid_payload', 'نوع الصندوق غلط');
    const opening = p.openingBalance;
    if (typeof opening !== 'number' || !Number.isInteger(opening) || opening < 0) throw new Reject('invalid_payload', 'رصيد البداية لازم يكون رقم');
    const same = await ctx.tx.query(ctx.col('treasury_account'), { name });
    if (same.some((a) => a.active !== false)) throw new Reject('rule_violation', 'في صندوق بنفس الاسم');
    return {
      writes: [{ path: ctx.path('treasury_account', id), mode: 'set', data: { id, name, kind, active: true, openingBalance: opening, openingDate: ctx.today } }],
      log: [{ opType: 'settings', entity: 'treasury_account', recordId: id, recordLabel: name, changes: [{ field: 'صندوق جديد', old: null, new: `${ACCOUNT_KINDS[kind]} · رصيد البداية ${shekel(opening)}` }] }],
    };
  },
};

/** Rename an account or stop using it (only when its balance is zero). */
export const accountEdit: Handler = {
  creates: [],
  async run(ctx) {
    const p = ctx.op.payload;
    requireTask(ctx.user, 'settings');
    const id = str(p, 'accountId');
    const a = await mustGet(ctx, 'treasury_account', id);
    const data: Record<string, unknown> = {};
    const changes: LogChange[] = [];
    if (typeof p.name === 'string' && p.name.trim() && p.name.trim() !== a.name) {
      data.name = p.name.trim();
      changes.push({ field: 'الاسم', old: a.name, new: data.name });
    }
    if (typeof p.active === 'boolean' && p.active !== (a.active !== false)) {
      if (!p.active) {
        const bal = await ctx.tx.get(ctx.path('account_balance', id));
        const b = (bal?.balance as number | undefined) ?? (a.openingBalance as number) ?? 0;
        if (b !== 0) throw new Reject('rule_violation', `بالصندوق ${shekel(b)} · لازم يتحوّلوا لصندوق ثاني قبل الإيقاف`);
      }
      data.active = p.active;
      changes.push({ field: 'الحالة', old: a.active !== false ? 'شغّال' : 'موقوف', new: p.active ? 'شغّال' : 'موقوف' });
    }
    if (!changes.length) throw new Reject('invalid_payload', 'ما في تغيير');
    return {
      writes: [{ path: ctx.path('treasury_account', id), mode: 'merge', data }],
      log: [{ opType: 'settings', entity: 'treasury_account', recordId: id, recordLabel: (data.name ?? a.name) as string, changes }],
    };
  },
};
