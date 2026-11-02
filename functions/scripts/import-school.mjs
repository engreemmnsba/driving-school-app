// Step 2 of going live: puts the saved school (launch\school-export.json) into the REAL Firebase project.
// Needs: Blaze + functions deployed, and a service-account key saved as launch\prod-key.json
// (Firebase console → Project settings → Service accounts → Generate new private key).
// Usage:  cd functions ; npm run import-school -- --confirm
// Refuses if the real school already has data. Every login gets a NEW temporary password
// (the emulator's passwords can't be carried over) → launch\new-passwords.csv, to send on WhatsApp.
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { randomInt } from 'node:crypto';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { cert, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';

for (const v of ['FIRESTORE_EMULATOR_HOST', 'FIREBASE_AUTH_EMULATOR_HOST']) {
  if (process.env[v]) throw new Error(`${v} is set: this script writes to the REAL project. Open a fresh PowerShell window.`);
}
if (!process.argv.some((a) => a.startsWith('--confirm'))) {
  console.log('This writes the saved school into the REAL Firebase project. Run again with:  npm run import-school -- --confirm');
  process.exit(1);
}

const launch = resolve(dirname(fileURLToPath(import.meta.url)), '../../launch');
const keyPath = resolve(launch, 'prod-key.json');
const dataPath = resolve(launch, 'school-export.json');
if (!existsSync(keyPath)) throw new Error(`Missing ${keyPath} (service-account key from the Firebase console).`);
if (!existsSync(dataPath)) throw new Error(`Missing ${dataPath}: run "npm run export-school" first (emulators running).`);

const key = JSON.parse(readFileSync(keyPath, 'utf8'));
if (key.project_id !== 'your-firebase-project') throw new Error(`Key is for project ${key.project_id}, expected your-firebase-project`);
initializeApp({ credential: cert(key), projectId: key.project_id });
const db = getFirestore();
const auth = getAuth();

const { school, docs, users } = JSON.parse(readFileSync(dataPath, 'utf8'));
const typed = (v) => {
  if (v && typeof v === 'object' && !Array.isArray(v) && Object.keys(v).length === 1 && '__ts' in v) return Timestamp.fromMillis(v.__ts);
  if (Array.isArray(v)) return v.map(typed);
  if (v && typeof v === 'object') return Object.fromEntries(Object.entries(v).map(([k, x]) => [k, typed(x)]));
  return v;
};

// Never mix with a school that is already in use.
const existing = await db.collection(`schools/${school}/user`).limit(1).get();
if (!existing.empty) throw new Error(`The real school "${school}" already has data. Nothing was written.`);

// 1. Records, 400 per batch.
let batch = db.batch();
let inBatch = 0;
let total = 0;
for (const [col, byId] of Object.entries(docs)) {
  for (const [id, data] of Object.entries(byId)) {
    batch.set(db.doc(`schools/${school}/${col}/${id}`), typed(data));
    inBatch += 1;
    total += 1;
    if (inBatch === 400) {
      await batch.commit();
      batch = db.batch();
      inBatch = 0;
    }
  }
}
if (inBatch) await batch.commit();

// 2. Logins: same uid and permissions, new temporary password.
const letters = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';
const tempPassword = () => Array.from({ length: 10 }, () => letters[randomInt(letters.length)]).join('');
const rows = ['national_id,name,temporary_password'];
for (const u of users) {
  const password = tempPassword();
  await auth.createUser({ uid: u.uid, email: u.email, displayName: u.displayName ?? undefined, password, disabled: u.disabled });
  await auth.setCustomUserClaims(u.uid, u.claims);
  rows.push(`${u.email.split('@')[0]},"${(u.displayName ?? '').replaceAll('"', '')}",${password}`);
}
writeFileSync(resolve(launch, 'new-passwords.csv'), '﻿' + rows.join('\n'));
console.log(`Real school "${school}": ${total} records and ${users.length} logins written.`);
console.log(`New passwords: ${resolve(launch, 'new-passwords.csv')} (send each one privately, then delete the file).`);
process.exit(0);
