// Step 1 of going live: saves the school typed into the LOCAL emulator to a file.
// Usage (emulators running):  cd functions ; npm run export-school
// Writes ..\launch\school-export.json (Firestore docs of schools/main + the logins, without passwords).
import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';

process.env.FIRESTORE_EMULATOR_HOST ??= '127.0.0.1:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST ??= '127.0.0.1:9099';
for (const v of ['FIRESTORE_EMULATOR_HOST', 'FIREBASE_AUTH_EMULATOR_HOST']) {
  if (!/^(127\.0\.0\.1|localhost):\d+$/.test(process.env[v])) throw new Error(`${v} must point to the local emulator`);
}

const SCHOOL = 'main';
// Server bookkeeping that the live server rebuilds itself.
const SKIP = new Set(['ops', 'rejected_ids']);

initializeApp({ projectId: 'your-firebase-project' });
const db = getFirestore();
const auth = getAuth();

const plain = (v) => {
  if (v instanceof Timestamp) return { __ts: v.toMillis() };
  if (Array.isArray(v)) return v.map(plain);
  if (v && typeof v === 'object') return Object.fromEntries(Object.entries(v).map(([k, x]) => [k, plain(x)]));
  return v;
};

const docs = {};
let count = 0;
for (const col of await db.doc(`schools/${SCHOOL}`).listCollections()) {
  if (SKIP.has(col.id)) continue;
  const snap = await col.get();
  docs[col.id] = Object.fromEntries(snap.docs.map((d) => [d.id, plain(d.data())]));
  count += snap.size;
}

const users = [];
let page;
do {
  const r = await auth.listUsers(1000, page);
  for (const u of r.users) {
    if (u.customClaims?.schoolId !== SCHOOL) continue;
    users.push({ uid: u.uid, email: u.email, displayName: u.displayName ?? null, disabled: u.disabled, claims: u.customClaims });
  }
  page = r.pageToken;
} while (page);

const students = Object.keys(docs.student ?? {}).length;
const out = resolve(dirname(fileURLToPath(import.meta.url)), '../../launch/school-export.json');
mkdirSync(dirname(out), { recursive: true });
writeFileSync(out, JSON.stringify({ school: SCHOOL, exportedAt: new Date().toISOString(), docs, users }, null, 1));
console.log(`Saved ${count} records (${students} students) and ${users.length} logins to ${out}`);
console.log('Keep this file private: it has national IDs, phones and money.');
process.exit(0);
