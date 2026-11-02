/** Money is always integer agorot (₪1 = 100). */
export type Agorot = number;
/** YYYY-MM-DD, the day the thing happened. */
export type BusinessDate = string;

export interface Op {
  opId: string;
  schoolId: string;
  type: string;
  payload: Record<string, unknown>;
  deviceId: string;
  deviceSeq: number;
  deviceTime: string;
  userId: string;
  permVersion?: number;
  appVersion?: string;
}

export type RejectReason =
  | 'unknown_op_type'
  | 'invalid_payload'
  | 'permission_denied'
  | 'month_locked'
  | 'not_found'
  | 'account_not_allowed'
  | 'discount_over_limit'
  | 'backdate_not_allowed'
  | 'depends_on_rejected'
  | 'rule_violation'
  | 'wrong_school'
  | 'user_disabled';

export type OpResult =
  | { opId: string; status: 'accepted'; serverSeq: number; serverTime: string; assigned?: Record<string, unknown>; flags?: string[] }
  | { opId: string; status: 'rejected'; reason: RejectReason; message: string };

/** Permission options stored on the user doc (see docs/02-permissions-matrix.md). */
export interface UserPermissions {
  tasks: Record<string, boolean>;
  allowedAccounts?: string[] | 'all';
  expenseCategories?: string[] | 'all';
  discountMax?: Agorot | null; // null = no limit
  closeMode?: 'blind' | 'full';
  logScope?: 'own' | 'all';
  backdateDays?: number | 'any_open_day';
}

export interface UserDoc {
  id: string;
  schoolId: string;
  name: string;
  kind: 'admin' | 'staff' | 'instructor' | 'student';
  status: 'active' | 'disabled';
  permissions: UserPermissions;
  permVersion: number;
}

/** A single entity document written by a handler. */
export interface Doc {
  [k: string]: unknown;
}

export interface LogChange {
  field: string;
  old: unknown;
  new: unknown;
}

export interface LogEntry {
  opType: 'create' | 'edit' | 'archive' | 'restore' | 'postpone' | 'settings' | 'permission' | 'close' | 'reopen';
  entity: string;
  recordId: string;
  recordLabel: string;
  changes: LogChange[];
  reason?: string;
}

export class Reject extends Error {
  constructor(public reason: RejectReason, message: string) {
    super(message);
  }
}
