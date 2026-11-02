import type { LogChange } from './types.js';

/**
 * Renders an activity-log change as a gender-neutral Arabic sentence (verbal noun + actor),
 * so it reads right for any user: "تغيير سعر الدرس العملي (خصوصي) من ₪100 إلى ₪120 · بواسطة سلمى".
 * The app renders from the same structured data (AR/EN templates); this is the server copy for exports.
 */
export function sentenceAr(actorName: string, recordLabel: string, change: LogChange): string {
  const fmt = (v: unknown) => (v === null || v === undefined || v === '' ? 'فاضي' : String(v));
  if (change.old === null || change.old === undefined) return `تحديد ${change.field} لـ${recordLabel}: ${fmt(change.new)} · بواسطة ${actorName}`;
  return `تغيير ${change.field} لـ${recordLabel} من ${fmt(change.old)} إلى ${fmt(change.new)} · بواسطة ${actorName}`;
}
