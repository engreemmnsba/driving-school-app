# 09 · Performance & battery plan · Testing plan · Phased delivery

## A. Performance & battery

| Target | How the design meets it | How we measure |
|---|---|---|
| Cold start ≤ 1.5 s (mid-range phone) | native splash; DB opened on a background isolate in parallel with session read; Home from local DB; all network after first frame; deferred Firebase pieces | `flutter run --profile`, startup trace, `adb shell am start -W` on a ~2022 mid-range phone |
| Warm start ≤ 0.5 s | no work on resume except a pull trigger | same |
| No jank (≤ 16 ms frames) | lists via `ListView.builder` + 30-row pages; totals from summaries/SQL aggregates, not Dart loops; heavy work (exports, recompute) on isolates | DevTools performance overlay on long lists (10k ledger rows seeded) |
| Firestore reads small | cursor pulls read each changed doc once; summaries; one tiny listener in foreground only | log reads per screen/sync in debug builds; budget per day documented |
| Battery | no background listeners; WorkManager only when outbox non-empty; timer updates every minute; exact alarm instead of a running service; no polling | Battery Historian on a full working day script |
| Memory | streamed Excel/PDF generation; logo ≤ 100 KB; Drift queries paged | DevTools memory, peak during year-end report export |
| App size | split per ABI; no heavy fonts beyond IBM Plex Sans Arabic subsets; tree-shaken icons | `flutter build apk --analyze-size` |
| DB size after 1 year | seed a simulated year (≈ 150 students, 6,000 lessons, 8,000 ledger rows) and report size; Admin window 90 days | test script |

## B. Testing plan

1. **Domain unit tests (pure Dart, must be 100% on money):** ledger math, reversals, discounts limits, price-on-businessDate, lesson numbering, payroll net + carry-over, fuel per lesson, permission dependencies.
2. **Sync scenario tests** (fake server + real `applyOps` against the Firestore emulator): drop mid-push and resend (idempotent), two devices offline same student, permission revoked while offline, op after day close, op in locked month, clock skew, long offline (5,000 ops), app killed mid-transaction.
3. **Security rules tests** (emulator): each role/claim can read exactly its scope; no client writes.
4. **Widget/golden tests:** key screens in AR/EN × light/dark; bidi strings with Arabic names in English UI.
5. **Updater tests (`direct`):** resume after network drop, corrupted file (bad SHA-256), forced update with pending ops (must sync/keep queue).
6. **Manual QA checklist** per release: the flows in `03`, offline day simulation, blind close, backups restore drill (quarterly).

## C. Phased delivery (solo developer)

| Phase | Scope | Exit criteria |
|---|---|---|
| **0 · Foundations** (≈ 2 wks) | project skeleton, flavors, design system & tokens (light/dark), l10n AR/EN, Drift schema, **outbox/pusher/puller**, `applyOps` skeleton with idempotency, auth + claims, setup checklist, settings & license prices | sync scenario tests green on emulator |
| **1 · Daily work MVP** (≈ 3 wks) | students & enrollments, lessons + timer/alarm, payments + receipts + WhatsApp, admin Home, students list/profile, instructor home, student home, activity log + detail | the school can run a full day on the app offline/online |
| **2 · Money control** (≈ 3 wks) | expenses, treasury accounts & transfers, cash book, day close (full + blind), exams (book/postpone/result/graduate), permissions screen & templates | a full week of real money reconciled with paper |
| **3 · Payroll & reports** (≈ 2 wks) | payroll months, employee statement, reports + Excel/PDF, month lock + snapshots, archive & purge | first month closed and locked in the app |
| **4 · Release** (≈ 1–2 wks) | backups (export, Drive/Gmail), notifications, updater (`direct`) + download page, Play build + privacy policy + Data Safety, performance measurements | targets met on a real phone; Play internal testing approved |

Risks per phase: Phase 0 sync correctness (most important — nothing else starts before its tests pass); Phase 2 day-close edge cases with late offline entries; Phase 4 Play review (permissions declarations).
