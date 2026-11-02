# Driving School Manager — offline-first Flutter + Firebase

A complete management app for a driving school: students, lessons, exams, payments, cash accounts, staff payroll, permissions and reports — built to keep working **with no internet**, which is the normal case for the school it was built for.

Built and shipped by **Reem Mansour** (freelance, Gaza) for a real driving school, which now runs on it. The client's name, logo and Firebase project are removed from this public copy; everything else is the production code.

<p>
<img alt="Flutter 3.38" src="https://img.shields.io/badge/Flutter-3.38-02569B?logo=flutter">
<img alt="Dart 3.10" src="https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart">
<img alt="Firebase" src="https://img.shields.io/badge/Firebase-Functions%20·%20Firestore%20·%20Auth%20·%20Hosting-FFCA28?logo=firebase">
<img alt="TypeScript" src="https://img.shields.io/badge/TypeScript-Node%2022-3178C6?logo=typescript">
<img alt="Tests" src="https://img.shields.io/badge/tests-57%20server%20·%20rules%20·%20app-2ea44f">
</p>

> **العربي باختصار:** نظام كامل لإدارة مدرسة تعليم قيادة (الطلاب، الدروس، الامتحانات، الدفعات، الصناديق، الرواتب، الصلاحيات، التقارير). بيشتغل بدون إنترنت: كل عملية بتنحفظ على الجهاز أولاً وبتتزامن مع السيرفر لما يرجع النت. تطبيق Android + نسخة ويب (PWA) للآيفون، وكل الواجهات بالعربي.

---

## What it does

| Area | Highlights |
|---|---|
| **Students** | Register with license type and car, track theory/practical stage, profile with full statement, graduate and archive |
| **Lessons** | One tap to log a lesson; a timer in the card; one running lesson per instructor; undo = reversal, never delete |
| **Exams** | Booking creates the student charge and the ministry expense in one step; result only from the exam date; postpone (never cancel) with a reason |
| **Money** | Payments with printable PDF receipts, discounts, expenses, transfers between accounts, **blind daily cash count** (the counter doesn't see the expected amount until they submit) |
| **Staff** | Instructors, cars, monthly payroll with bonuses/deductions/advances, past months frozen |
| **Permissions** | Plain-language task checklist per user with automatic dependencies, enforced on the server; per-user allowed cash accounts |
| **Oversight** | Activity log ("who changed what from A to B"), notifications, reports, month lock, CSV/Excel export |
| **Roles** | Admin, staff (accountant/secretary templates), instructor home, student home — each sees only their own data |

## Architecture

```
┌──────────── Phone / browser ────────────┐          ┌──────────── Firebase ────────────┐
│ Flutter UI  (Riverpod, Material 3, RTL) │          │                                  │
│      │ reads                            │  push    │  applyOpsFn (Cloud Function)     │
│      ▼                                  │ ───────▶ │   • checks permissions           │
│ SQLite via Drift  ◀── only read source  │  ops     │   • validates business rules     │
│      ▲                                  │          │   • writes events + server seq   │
│      │ writes = append-only operations  │  pull    │                                  │
│ Outbox (UUIDv7 op ids)                  │ ◀─────── │  Firestore (scoped per role)     │
└─────────────────────────────────────────┘ changes  └──────────────────────────────────┘
```

- **Offline-first.** The UI never waits for the network. It reads only from the local SQLite database (Drift). Firestore is the server, not the device cache.
- **Every write is an operation.** A local write is queued in an outbox with a client-generated UUIDv7. A single Cloud Function (`applyOpsFn`) validates it and applies it inside a transaction. Re-sending the same op is harmless (idempotent by op id).
- **Events, not edits.** Lessons, payments, charges, discounts, expenses, exam bookings and the activity log are append-only. A correction is a reversal event, so the money history can always be rebuilt.
- **Pull by cursor, scoped by role.** Devices pull changes per collection from a cursor. Instructors and students get scoped queries, so data a user may not see never reaches their phone.
- **Conflicts.** The few mutable records (student profile, settings, users) use last-write-wins per field by server time, and both versions are kept in the log.
- **Web too.** The same code builds an installable PWA for iPhone users. A custom service worker caches the app and the Flutter engine, so it opens with no connection.

Full design docs: [`docs/05-architecture-and-sync.md`](docs/05-architecture-and-sync.md), [`docs/04-data-model.md`](docs/04-data-model.md), [`docs/02-permissions-matrix.md`](docs/02-permissions-matrix.md), and the decision log [`DECISIONS.md`](DECISIONS.md) (every product/tech decision, who made it and why).

## Examples

### 1. Logging a lesson offline

The screen calls one action. It writes the lesson to SQLite right away, so the UI updates at once, and queues the op:

```jsonc
// queued in the outbox, sent when online (shape of Op in functions/src/core/types.ts)
{
  "opId": "0192f3a1-7c4e-7b2a-9d10-5e8f2c1a0b77",   // UUIDv7, made on the device
  "schoolId": "main",
  "type": "lesson.log",
  "payload": {
    "lessonId": "…", "enrollmentId": "…", "type": "practical",
    "employeeId": "…", "startedAt": "2026-11-02T09:15:00+02:00", "chargeId": "…"
  },
  "deviceId": "…", "deviceSeq": 418, "deviceTime": "…", "userId": "…"
}
```

The server applies it and returns one result per op. Money is always integer agorot (₪1 = 100):

```jsonc
[{ "opId": "0192f3a1-…", "status": "accepted", "serverSeq": 90211,
   "serverTime": "…", "assigned": { "number": 7, "charge": 6000 } }]
```

The server decides the final lesson number, and the device writes it back. If the instructor already has a running lesson, the month is locked, or the user lacks the permission, the op is **rejected with a reason** (`permission_denied`, `month_locked`, `rule_violation`, …). The local row is marked rejected and listed for the Admin with the Arabic message.

### 2. A server handler (TypeScript)

Every op type maps to a handler (`functions/src/core/applyOps.ts`):

```ts
export const HANDLERS: Record<string, Handler> = {
  'student.register': studentRegister,
  'lesson.log': lessonLog,
  'payment.record': paymentRecord,
  'payment.reverse': paymentReverse,
  'exam.book': examBook,
  'day.close': dayClose,
  'salary.pay': salaryPay,
  'month.lock': monthLock,
  // … 34 op types in total
};
```

Handlers run against a `Store` interface. In production it is Firestore in a transaction; in tests it is an in-memory store. So the business rules are unit-tested without the emulator:

```bash
cd functions && npm ci && npm test     # 57 tests, ~2 s
```

### 3. Money colours mean one thing everywhere

`app/lib/core/ui/tokens.dart` defines each colour with one meaning on every screen: money in = green, out = ink, debt = amber, discount = teal, **red only for problems**. Amounts always go through `MoneyText`, so formatting and direction never drift between screens.

## Project layout

```
app/          Flutter app (Android + web/PWA)
  lib/core/     db (Drift tables), sync (outbox, pusher, puller), auth, domain rules, UI tokens, PDF/CSV export
  lib/data/     queries per area (money, staff, roles, settings, ops)
  lib/features/ screens: students, money, exams, staff, oversight, settings, roles, system
  test/         unit + widget tests (in-memory SQLite)
functions/    Cloud Functions (TypeScript): applyOps, handlers per area, claims, scripts
  test/         handler tests on an in-memory store
  test-rules/   Firestore security-rules tests (emulator)
firebase/     firestore.rules, firestore.indexes.json
hosting/      download page for the Android APK
docs/         requirements, data model, architecture & sync, permissions, test plan
```

## Run it locally (no Firebase project or billing needed)

Requirements: Flutter 3.38, Node 22, Firebase CLI, Java 21 (for the emulators).

```bash
# 1) local Firebase (Auth + Firestore + Functions) — keep this window open
cd functions && npm ci && npm run build && cd ..
firebase emulators:start --only auth,firestore,functions   # or .\emulators.ps1 on Windows

# 2) demo school with students, lessons, payments and staff
cd functions && npm run seed

# 3) the app in Chrome, against the emulators
cd app
flutter pub get
dart run build_runner build --force-jit
flutter run -d chrome -t lib/main_direct.dart --dart-define=EMULATOR=true
```

Demo logins (emulator only), password `Test#2026`:

| Role | National ID |
|---|---|
| Admin | `900000001` |
| Instructor | `900000002` |
| Student | `401234567` |

To deploy to your own project: run `flutterfire configure` (this replaces the placeholder `app/lib/firebase_options.dart`), set your project id in `.firebaserc`, then run `deploy.ps1`. It runs the server tests, builds the web app and deploys functions, rules, indexes and hosting.

## Tests

| Suite | Command | What it covers |
|---|---|---|
| Server rules | `cd functions && npm test` | every op handler: permissions, locks, money maths, payroll, exams |
| Security rules | `cd functions && npm run test:rules` | who can read what in Firestore, per role and per school |
| App | `cd app && flutter test` | sync engine (push/pull/retry), domain rules, money, permissions, screens |

## Stack

Flutter 3.38 · Dart 3.10 · Riverpod · go_router · Drift (SQLite, web via WASM worker) · Firebase Auth / Firestore / Cloud Functions (Node 22, TypeScript) / Hosting · Vitest · pdf + printing · IBM Plex Sans Arabic.

---

**Reem Mansour** — Full-stack software engineer (Flutter, ASP.NET Core, Firebase, Node.js). Open to remote work.
