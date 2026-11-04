import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { randomUUID } from 'node:crypto';
import { applyOps } from './core/applyOps.js';
import type { AfterCommit } from './core/context.js';
import { loginEmail } from './core/loginEmail.js';
import { FirestoreStore } from './core/firestoreStore.js';
import type { Op } from './core/types.js';

initializeApp();
const store = new FirestoreStore(getFirestore());

const MAX_BATCH = 50;

/** Creates / updates Firebase Auth logins after the op that needs them is committed. */
async function afterCommit(a: AfterCommit): Promise<void> {
  const auth = getAuth();
  if (a.kind === 'createLogin') {
    try {
      await auth.createUser({ uid: a.uid, email: loginEmail(a.nationalId), password: a.password, displayName: a.name });
    } catch (e) {
      if ((e as { code?: string }).code !== 'auth/uid-already-exists') throw e;
    }
    await auth.setCustomUserClaims(a.uid, a.claims);
  } else if (a.kind === 'setClaims') {
    await auth.setCustomUserClaims(a.uid, a.claims);
  } else if (a.kind === 'resetPassword') {
    await auth.updateUser(a.uid, { password: a.password });
    await auth.revokeRefreshTokens(a.uid);
  } else if (a.kind === 'setDisabled') {
    await auth.updateUser(a.uid, { disabled: a.disabled });
    if (a.disabled) await auth.revokeRefreshTokens(a.uid);
  } else {
    await auth.updateUser(a.uid, {
      ...(a.nationalId ? { email: loginEmail(a.nationalId) } : {}),
      ...(a.name ? { displayName: a.name } : {}),
    });
  }
}

/** The only write path for clients. */
export const applyOpsFn = onCall({ region: 'europe-west1', enforceAppCheck: false }, async (req) => {
  if (!req.auth) throw new HttpsError('unauthenticated', 'login required');
  const ops = (req.data?.ops ?? []) as Op[];
  if (!Array.isArray(ops) || ops.length === 0 || ops.length > MAX_BATCH) {
    throw new HttpsError('invalid-argument', `1..${MAX_BATCH} ops`);
  }
  const results = await applyOps({ store, now: () => new Date(), newId: randomUUID, afterCommit }, req.auth.uid, ops);
  return { results };
});
