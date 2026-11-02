// Creates the FIRST Admin login in the REAL project (only needed when the school starts from zero;
// if you carry the school over with import-school, the Admin comes with it).
// Needs launch\prod-key.json (Firebase console → Project settings → Service accounts → Generate new private key).
// Usage:  cd functions ; npm run create-admin -- 9DIGITID "الاسم"
// Prints a temporary password once. Refuses if the school already has an Admin.
import { existsSync, readFileSync } from 'node:fs';
import { randomInt } from 'node:crypto';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { cert, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

for (const v of ['FIRESTORE_EMULATOR_HOST', 'FIREBASE_AUTH_EMULATOR_HOST']) {
  if (process.env[v]) throw new Error(`${v} is set: this script writes to the REAL project. Open a fresh PowerShell window.`);
}
const [nationalId, ...nameParts] = process.argv.slice(2).filter((a) => !a.startsWith('--'));
const name = nameParts.join(' ').trim();
if (!/^\d{9}$/.test(nationalId ?? '') || name.length < 2) {
  console.log('Usage: npm run create-admin -- 900000001 "اسم المدير"');
  process.exit(1);
}

const keyPath = resolve(dirname(fileURLToPath(import.meta.url)), '../../launch/prod-key.json');
if (!existsSync(keyPath)) throw new Error(`Missing ${keyPath}`);
const key = JSON.parse(readFileSync(keyPath, 'utf8'));
if (key.project_id !== 'your-firebase-project') throw new Error(`Key is for project ${key.project_id}`);
initializeApp({ credential: cert(key), projectId: key.project_id });
const auth = getAuth();
const db = getFirestore();

const SCHOOL = 'main';
const admins = await db.collection(`schools/${SCHOOL}/user`).where('kind', '==', 'admin').limit(1).get();
if (!admins.empty) throw new Error('The school already has an Admin. Nothing was changed.');

// Must match app/lib/core/auth/login_email.dart
const email = `${nationalId}@login.your-firebase-project.web.app`;
const letters = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';
const password = Array.from({ length: 10 }, () => letters[randomInt(letters.length)]).join('');
const user = await auth.createUser({ email, password, displayName: name });
await auth.setCustomUserClaims(user.uid, { schoolId: SCHOOL, kind: 'admin', permVersion: 1 });
const now = new Date().toISOString();
await db.doc(`schools/${SCHOOL}/user/${user.uid}`).set({
  id: user.uid, schoolId: SCHOOL, name, nationalId, kind: 'admin', status: 'active',
  permissions: { tasks: {} }, permVersion: 1, serverSeq: 1, serverTime: now, createdBy: 'create-admin',
});
await db.doc(`schools/${SCHOOL}/meta/head`).set({ serverSeq: 1 }, { merge: true });
console.log(`Admin ready: national ID ${nationalId} · temporary password ${password}`);
console.log('Keep it private; send it to the Admin only.');
process.exit(0);
