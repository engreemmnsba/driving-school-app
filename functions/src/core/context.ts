import type { Tx } from './store.js';
import { Reject, type Agorot, type BusinessDate, type Doc, type LogEntry, type Op, type UserDoc } from './types.js';

export interface Write {
  path: string;
  data: Doc;
  mode: 'set' | 'merge';
}

/** Side effects run once, after the op's transaction commits (never on an idempotent replay). */
export type AfterCommit =
  | { kind: 'createLogin'; uid: string; nationalId: string; password: string; name: string; claims: Record<string, unknown> }
  | { kind: 'updateLogin'; uid: string; nationalId?: string; name?: string }
  /** permissions / cars changed: new token claims (the app reloads them on the next sync). */
  | { kind: 'setClaims'; uid: string; claims: Record<string, unknown> }
  /** disabled → signed out everywhere (refresh tokens revoked); enabled → can log in again. */
  | { kind: 'setDisabled'; uid: string; disabled: boolean };

export interface HandlerOutput {
  writes: Write[];
  log: LogEntry[];
  assigned?: Record<string, unknown>;
  flags?: string[];
  after?: AfterCommit[];
}

export interface Ctx {
  tx: Tx;
  op: Op;
  user: UserDoc;
  serverTime: string;
  /** today in the school timezone */
  today: BusinessDate;
  /** `schools/{schoolId}/{collection}/{id}` */
  path(collection: string, id: string): string;
  col(collection: string): string;
}

export type Handler = {
  /** payload keys holding ids of records this op creates (marked if the op is rejected) */
  creates: string[];
  run(ctx: Ctx): Promise<HandlerOutput>;
};

// ---------- payload helpers ----------
export function str(p: Record<string, unknown>, k: string): string {
  const v = p[k];
  if (typeof v !== 'string' || v.length === 0) throw new Reject('invalid_payload', `حقل ناقص: ${k}`);
  return v;
}
export function optStr(p: Record<string, unknown>, k: string): string | undefined {
  const v = p[k];
  if (v === undefined || v === null || v === '') return undefined;
  if (typeof v !== 'string') throw new Reject('invalid_payload', `حقل غلط: ${k}`);
  return v;
}
export function money(p: Record<string, unknown>, k: string): Agorot {
  const v = p[k];
  if (typeof v !== 'number' || !Number.isInteger(v) || v <= 0) throw new Reject('invalid_payload', `المبلغ لازم يكون أكبر من صفر: ${k}`);
  return v;
}
export function bool(p: Record<string, unknown>, k: string): boolean {
  return p[k] === true;
}
export function date(p: Record<string, unknown>, k: string): BusinessDate {
  const v = str(p, k);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(v)) throw new Reject('invalid_payload', `تاريخ غلط: ${k}`);
  return v;
}

/** Reads a record created earlier; distinguishes "never existed" from "its op was rejected". */
export async function mustGet(ctx: Ctx, collection: string, id: string): Promise<Doc> {
  const d = await ctx.tx.get(ctx.path(collection, id));
  if (d) return d;
  const rejected = await ctx.tx.get(ctx.path('rejected_ids', id));
  if (rejected) throw new Reject('depends_on_rejected', 'مرتبطة بعملية انرفضت');
  throw new Reject('not_found', `مش موجود: ${collection}/${id}`);
}

/** Price row effective on a business date (latest effectiveFrom <= date). */
export async function priceAt(ctx: Ctx, licenseTypeId: string, on: BusinessDate): Promise<Doc> {
  const rows = await ctx.tx.query(ctx.col('license_price'), { licenseTypeId });
  const eligible = rows
    .filter((r) => typeof r.effectiveFrom === 'string' && (r.effectiveFrom as string) <= on)
    .sort((a, b) => ((a.effectiveFrom as string) < (b.effectiveFrom as string) ? 1 : -1));
  const p = eligible[0];
  if (!p) throw new Reject('rule_violation', 'ما في أسعار لهالرخصة بهالتاريخ · لازم تنحط بالإعدادات');
  return p;
}

export function summaryPath(ctx: Ctx, enrollmentId: string): string {
  return ctx.path('student_summary', enrollmentId);
}

export interface StudentSummary {
  enrollmentId: string;
  studentId: string;
  charged: Agorot;
  paid: Agorot;
  discounts: Agorot;
  theoryLessons: number;
  practicalLessons: number;
}

export async function readSummary(ctx: Ctx, enrollmentId: string, studentId: string): Promise<StudentSummary> {
  const s = await ctx.tx.get(summaryPath(ctx, enrollmentId));
  return {
    enrollmentId,
    studentId,
    charged: (s?.charged as number) ?? 0,
    paid: (s?.paid as number) ?? 0,
    discounts: (s?.discounts as number) ?? 0,
    theoryLessons: (s?.theoryLessons as number) ?? 0,
    practicalLessons: (s?.practicalLessons as number) ?? 0,
  };
}

export function remaining(s: StudentSummary): Agorot {
  return s.charged - s.paid - s.discounts;
}

export function shekel(a: Agorot): string {
  const whole = a / 100;
  return '₪' + (Number.isInteger(whole) ? whole.toLocaleString('en-US') : whole.toFixed(2));
}

/** A boolean general setting (`setting/{key}.value`), with its default when never set. */
export async function boolSetting(ctx: Ctx, key: string, fallback: boolean): Promise<boolean> {
  const d = await ctx.tx.get(ctx.path('setting', key));
  return typeof d?.value === 'boolean' ? d.value : fallback;
}
