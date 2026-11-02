# Prompt: Full Analysis & Engineering Blueprint — Driving School Management App

## Your role
Act as a senior software architect, requirements analyst, and mobile UX lead. Produce a complete, implementation-ready engineering blueprint for the app described below. Be concrete: name tables/collections, fields, types, indexes, packages, screens, and numbers. Where a requirement is ambiguous or an assumption (marked **[ASSUMPTION]**) looks wrong, say so explicitly and propose the better option — do not silently invent requirements.

## Working rules (mandatory — read before anything else)
1. **Analysis before code.** Your first response is the full blueprint (Deliverables below). Do not write application code until I approve it.
2. **Never decide silently.** If anything is ambiguous, contradictory, missing, or you would need to assume it, **stop and ask me**. Collect all questions in one numbered list ("Questions before building"), each with your recommended answer and why, then wait for my answers. Items marked [ASSUMPTION] must be confirmed by me before code depends on them.
3. **Decisions log.** Keep a `DECISIONS.md` file: every confirmed decision, its date, and the reason. Never change an approved decision without asking me first.
4. **Build complete modules only**, in the order of the approved phased plan. A module is done only when: all its screens, rules, permissions, validation, messages (AR/EN), offline behavior, archive/activity logging, and tests are implemented; `flutter analyze` is clean; tests pass. **No TODOs, placeholders, mock data, or "implement later" stubs** in delivered code.
5. **Before each module**: restate its scope, its data model changes, and the permissions it touches; ask about anything unclear. **After each module**: report what was built, how it was tested, and anything that deviated from the plan.
6. **Get the foundations right first** (they are expensive to change later): data model and enrollments, ledger and computed balances, permissions and security rules, offline sync and IDs, `schoolId` multi-tenancy, activity log, localization/RTL, local schema migrations. Lock these in the blueprint and confirm them with me before any feature code.
7. If during building you discover a problem with an approved design, **stop and explain it with options** — do not patch around it.

## Context
- Client: a single-branch driving school, currently tracking everything in a paper notebook.
- Scale: ~30 new students every 2 months (~180/year), a handful of instructors and cars. Small data volume, but data integrity (money) is critical.
- Developer: solo full-stack engineer (Flutter/Dart, Firebase, ASP.NET Core, SQL Server). Fixed-price project (~$500), so the design must be simple to build and cheap to run.
- Network: unreliable internet (Gaza). **The app must work fully offline and sync when online.**
- Languages: **Arabic and English**, switchable in-app (full RTL/LTR support).
- Non-negotiables: no freezing, no long loading, **fast app startup**, **low battery usage**, easy UI/UX for non-technical users.

## Data volume & loading strategy (keep the app light — required)
- **Load only what a screen shows:** lists are paginated (first 30 items, more on scroll); no screen ever downloads a whole collection.
- **Totals, counts and balances are ALWAYS for the full filtered set, never for the loaded page.** They come from the pre-computed summaries (or a server-side aggregation for custom ranges), so "Expenses this month ₪6,420 · 87 items" is exact even when only 30 rows are loaded. The list header states both ("Showing 30 of 87").
- **Per-role sync scope:** an instructor's phone syncs only the active students of their cars and their own lessons; a student's phone syncs only their own records; the Admin syncs active students and the last 90 days of movements. Older history and archived records are **fetched on demand** (online) when a report or statement asks for them, never kept on the phone.
- **Pre-computed summaries instead of scanning raw records:** per-student balance and lesson counters, per-day and per-month totals (in/out by account and by type), per-car and per-instructor monthly counters — updated on each write and recomputable. Dashboards and reports read these small summary documents, so a monthly report reads a handful of documents, not thousands.
- **Indexes** for every filter combination used in the app (date + account, date + category, date + user + type, etc.).
- Lists show cached data instantly and refresh quietly; no full-screen spinners for data that is already on the phone.
- Exports (Excel/PDF) and long reports are generated in the background (isolate or server) with a progress indicator.
- Images: only the school logo, compressed and cached; no photos stored per student in this version.
- Archived/graduated records are excluded from day-to-day queries and from phone sync.
- Measure and report: documents read per screen open, local database size after one year of simulated data, cold start time, and memory — with targets in the blueprint.

## Performance, startup & battery targets (hard requirements)
- **Cold start ≤ 1.5 s** to an interactive home screen on a mid-range Android phone; warm start ≤ 0.5 s. Native splash only — no artificial splash delays.
- The app **never waits for the network to show data**: render from the local cache first, sync in the background.
- Defer non-critical initialization (analytics, update check, notification setup, heavy plugins) until after the first frame.
- Every screen interactive ≤ 300 ms from local data; lists of any size scroll at 60 fps (lazy lists, pagination, no heavy work on the UI thread — use isolates for report/PDF/Excel generation).
- **Battery**: no background polling, no always-on realtime listeners when the app is in the background, sync batched and triggered by app open/connectivity change, lesson-end alarm via scheduled notification (no running timers/foreground loops), update check rate-limited.
- **Memory**: target and measure peak usage; stream large exports instead of building them fully in memory; compress/cache the logo.
- **App size**: target and techniques (split per ABI, tree-shaking icons, font subsetting for Arabic).
- Include how each target is measured (Flutter DevTools, profile mode, startup tracing, Android vitals/battery historian) before release.

## Problems the app must solve
1. Register students and their payments.
2. Track how many lessons each student took (theory + practical).
3. Monthly reports for the school: revenue, outstanding debts, lessons per instructor per student, completed lessons, students who passed theory, students who passed practical, expenses.

## Roles & permissions
- Roles: **Admin (مدير)**, **Instructor (مدرب)**, **Student (طالب)**.
- **Every operation has its own permission**, toggled per user by the Admin. Defaults come from a role template; the Admin can override any permission per user (grant or revoke).

### Permission catalog (design every one of these)
For each module, separate permissions for **View / Add / Edit / Delete(archive) / Export** where applicable:
- **Students & enrollments**: view list, view details, add student, edit student data, add enrollment, change status, withdraw student.
- **Lessons**: add lesson, edit lesson, archive lesson.
- **Exams**: book theory exam, book practical exam, record result, **override minimum-lessons rule**.
- **Money**: add payment, edit/reverse payment, add discount (with a per-user maximum amount), send/print receipt, **see money amounts at all** (balances, prices, payments — when off, every amount is hidden everywhere in the UI and excluded from data synced to that device).
- **Treasury accounts**: view accounts and balances, top-up, withdraw, transfer between accounts, manage accounts.
- **Expenses**: view, add, edit/archive, per category (cars / salaries / ministry fees).
- **Reports**: view each report group separately (financial reports vs lessons/exams reports), export Excel/PDF, **lock/unlock month**.
- **Archive**: view archive, restore, **purge archived records**.
- **Activity log**: view (all users or own actions only).
- **Users & permissions**: add/disable users, reset passwords, revoke sessions, edit permissions.
- **Settings**: view, edit (license types/prices, lesson counts, accounts, school info/logo).
- **Payroll**: view payroll, add advance, add deduction/bonus, run monthly payroll.
- **Cash book & closing**: view cash book, close day, reopen a closed day, view reconciliation log.
- **Data**: run "check data", Excel import, view backup status, export everything.
- **Backdating**: allow entering records with a past date (and how far back).

### Fine-grained money permissions (decided — example: an accountant who records and closes the day but never sees account balances)
- **Permissions screen = plain checklist (decided after review; no level ladders, no abstract words like "view/add/edit").** Title "What does [name] do?". On top, ready-made jobs as one-tap starting points (Accountant · Secretary · Instructor · Admin; the Admin can save more). Below, collapsible groups with a count ("2 of 4", "all", "none"): Students & lessons · Payments from students · Expenses · Accounts & day close · Payroll · Reports & administration. Each permission is **one checkbox written as a task in plain words** ("تسجيل دفعة من طالب", "رؤية أرصدة الصناديق", "عدّ الصندوق وإغلاق اليوم") with a grey line saying **where it shows in the app** ("where: the Payment button on Home and the student profile"). Small options appear under a task only when it is checked (receives into: Cash / Cash & wallet / all accounts; expense categories; discount up to ₪50/₪100/no limit; day close: without seeing expected amounts / seeing them; activity log: own actions / everyone). **Dependencies are automatic**: checking a task that needs another checks it too, unchecking removes the tasks that depend on it, and a short message says what changed. Header shows "[job] (modified) · N permissions"; bottom bar: "preview as this user" and Save. All texts gender-neutral.
- Money permissions behind those tasks (the data model):
  - Payments: closed / view / add / edit & reverse. Discount: not allowed / allowed up to ₪X per student.
  - Expenses: closed / view / add / edit & archive — plus **allowed categories** (cars, ministry, salaries, other).
  - **Accounts used:** which treasury accounts this user may receive into / pay from (e.g. Cash only); other accounts never appear in their chips.
  - **Account balances:** hidden / view / top-up & transfer. When hidden, no balance appears anywhere — not on account chips, not on save-button results ("₪5,850 left in cash"), not in cash book totals — and balances are **not synced to that device** (server-side).
  - Cash book: closed / today only (no balances) / all periods.
  - Reconciliation & day close: closed / **blind reconciliation** / full reconciliation. Blind: the user types the counted amount per account without seeing the expected amount; amounts are locked on "submit count", and only then each account shows "matched ✓" or "difference · reason required" (no shekel amount); the Admin sees the exact difference in the reconciliation log. Reopen a closed day: separate permission.
  - Payroll: closed / view / advances / deductions & bonuses / pay salaries.
  - Financial reports: closed / view / view & export. Month lock: separate.
- Role templates include **Accountant** (payments add, discount none, expenses add for cars/ministry/other, accounts used = Cash, balances hidden, cash book today, blind reconciliation, no payroll, no financial reports, activity log own actions) alongside Admin, Instructor, Student; the Admin can create more templates.

### Data scope (row-level), separate from operations
- Instructor: by default sees **only the students of the cars they are assigned to**; an "all students" scope can be granted.
- Activity log: own actions only vs everyone.
- Student: only their own profile, enrollments, lessons, payments, exams. Fixed, not editable.

### Role templates (defaults)
- **Admin**: everything.
- **Instructor**: view own-car students, add lesson, see lesson progress; no money visibility, no payments, no reports, no settings — unless granted.
- **Student**: read-only own data, **including full money details** of their own enrollments: every charge, lesson charge, discount, payment (date, amount, method), receipts, and remaining balance.
- **Money visibility summary**: Admin sees all money; Student sees only their own money in full detail; Instructor sees **no money at all** (unless the Admin explicitly grants it).
- Deliver a full **matrix table: every permission × the 3 role defaults**.

### Rules & safeguards
- Enforced **server-side** (security rules / API) on every read and write, not only hidden in the UI. Hidden money fields must not even be sent to devices without the money-visibility permission.
- The **last active Admin** cannot be disabled, demoted, or lose "Users & permissions" (prevents lock-out).
- Permission changes take effect **immediately when online** and are cached locally for offline use. If a permission is revoked while a device is offline, its queued writes that are no longer allowed are **rejected on sync, kept visibly in a "rejected changes" list with the reason, never silently lost**, and the Admin is notified.
- Disabled accounts are signed out on all devices at next connection; their local data is wiped from shared phones.
- Every permission change is written to the activity log (who changed what for whom, before/after).
- Specify where permissions live (user document vs auth custom claims) and how security rules read them efficiently.

## Accounts & login
- Admin creates student accounts: login = **national ID + password set by Admin**.
- After registration, credentials are sent to the student via **WhatsApp or SMS**: WhatsApp via intent; SMS sent automatically in the `direct` flavor and via prefilled intent in the `play` flavor (see "Permissions, notifications & privacy"). No paid SMS gateway.
- Student home: amount paid, remaining balance, theory lessons x/N, practical lessons x/N, current status, exam bookings/results.
- **Instructor home ("My students")** — the instructor's whole daily job on one screen:
  - Lists only the students of the cars they are assigned to, with search; header shows "lessons I logged today" and the offline/sync state.
  - Each student card: name, license type and gearbox, counter (e.g., 14/20), a segmented progress bar (one segment per lesson: done / next / remaining, continuing past the planned count when the student needs more lessons), and "Next: practical lesson 15".
  - One big button **"Log lesson 15"**: **one tap records the next lesson immediately** (number assigned automatically, car and instructor filled automatically, timer starts) — no form, no second screen. A snackbar confirms with **Undo** (reversal entry, logged).
  - When the planned count is reached the button keeps going ("Log practical 11") with a small "beyond plan" tag; every practical lesson is charged at the current per-lesson price.
  - **No payment button and no money anywhere on the instructor's screens.** Recording payments is hidden for instructors by default; it appears only if the Admin explicitly grants the permission.
  - Bottom navigation: My students · My lessons today · My account.
- **Lessons are numbers only — no lesson names or topics.** Each new lesson is simply the next number in sequence for that student's current part (theory or practical).

## Usability & connected operations (top priority — the client's #1 requirement)
Ease of use and operations that flow into each other matter more than any feature. Apply these rules on every screen and verify them in the UX deliverable:
1. **Act where the data is.** Every record carries its own actions: a student row/profile has "Log lesson", "+ Payment", "Book exam"; a car has "+ Expense (fuel…)"; an employee has "+ Advance" and "Pay salary"; an account has "Top up / Transfer". Users never hunt for a separate menu.
2. **Shortest path.** Daily actions take at most 1–2 taps from home: logging a lesson = 1 tap; payment, expense, advance = 1 tap to open a bottom sheet + 1 tap to save. Money actions open as **bottom sheets over the current screen**, never full-screen navigation; closing returns to exactly where the user was.
3. **Every action leads to the next logical one (chained flows):**
   - Register student → registration fee charged → payment sheet opens → receipt and login credentials sent on WhatsApp in one share.
   - Log lesson → in-card timer → alarm → card shows the next lesson.
   - Student reaches the minimum lessons → "Book exam" appears on the card.
   - Book exam → student charged + ministry expense recorded (one step) → student notified.
   - Exam result "failed" → "Book retake" offered immediately with its fee.
   - Exam result "passed" (practical) → "Graduate & archive" offered with the summary.
   - Payment → receipt → balance updated everywhere.
   - End of day → "Close day" reminder → reconciliation → closing record → month lock enabled when all days are closed.
   - Advance → automatically deducted in the next payroll run.
4. **Everything is linked.** Every number is tappable and opens the list behind it (today's payments → the payments; a debt total → the students who owe; a car's fuel cost → its fuel expenses). Every movement links back to its student, car, employee, account and the user who made it.
5. **Smart defaults, minimal typing.** Today's date, last used account, payment purpose guessed from what is owed, salary amount from the employee file, fees from Settings, next lesson number. Use chips, steppers and the numeric keypad instead of free text.
6. **Undo for low-risk, summary for money.** Lessons use Undo; money shows the result on the save button itself ("Save ₪500 · ₪300 remains") instead of an extra confirmation dialog; destructive actions (purge, reopen day, unlock month) require an explicit confirmation.
7. **One consistent visual language.** Yellow = the main action of the screen; teal = save/money; red = danger/difference; the same bottom-sheet pattern for every quick entry; the same card layout for every list; large touch targets (≥ 48 px), Arabic-first RTL.
8. **No dead ends.** Empty states explain what to do next and offer the button (e.g., "No license types yet — Add the first license"). Errors say what to fix, inline, next to the field.

### Navigation & information architecture (decided)
- **Admin bottom navigation (5 tabs):** Home · Students · **Money** · Reports · More.
  - **Money** opens the cash book and has a top tab strip: Cash book (in/out) · Accounts · Expenses · Payroll. All money screens live here; "Close day" is the main button of the cash book.
  - **More** is a real menu: reconciliation log, activity log, car report, instructors, archive & graduates, settings & license types, users & permissions, backup status (each with a status badge, e.g., "today not closed", "last backup 02:00 ✓").
- **Instructor:** My students · My lessons today · My account. **Student:** a single home screen.
- **One path per operation (no duplicate entry points that can double-record):** salaries and advances are paid **only** from Payroll (the Expenses sheet's "Salaries" chip redirects there); exam fees are recorded **only** through exam booking (manual ministry expense is for corrections); a payment opened from Home starts with a student search (recent students preselected) before the amount.
- The "Book exam" button appears **on the student card in lists** as soon as the student reaches the minimum lessons, not only in the profile.
- The quick payment sheet always shows the payment purpose chips and the student's balance split by charge type.
- Destructive actions are never placed next to the primary action: e.g., "Cancel lesson (logged by mistake)" is a small secondary link under "End lesson now".
- Day closing: the cash amount must be typed (counted) — no "matches system" shortcut for cash; the shortcut is allowed for bank and wallet accounts.

### Filters on every list and report (decided)
- **Every list, money screen and report has the period filter** (cash book, accounts, expenses, payroll statements, reports, car report, activity log, reconciliation log, instructor details, student statement). One shared filter pattern: **a single period button** at the top showing the current period ("This month", or "1/10 – 19/10"); tapping it opens a small bottom sheet with Today · This week · This month · Last month · Custom range (Custom shows From/To date fields and a "Show this period" button). No horizontally scrolling chip rows for the period. Context chips (account, category, car, user, type) sit below it; totals at the top always recompute for the active filters; the active filters are written in plain words above the list ("Expenses · this month · Cars · Car 2"); every list has an empty state ("No movements in this period").
- Accounts: period + account (tapping an account card filters its movements; balances are current, in/out are for the period).
- Expenses: period + category (Cars / Ministry / Other) + sub-filter (which car, which exam type, which item).
- Payroll: month switcher (Previous / Next) with the month status ("2 employees not paid yet"); employee statement with a date range.
- Car report: period + car; tapping a car bar filters to it. Formulas: fuel cost per lesson = fuel expenses of the car in the period ÷ **driven practical lessons** in that car in the period (theory lessons and practical lessons marked "without driving" are excluded); total cost per lesson = (fuel + maintenance + other car expenses) ÷ lessons; bar length is relative to the most expensive car; the insight line compares the highest and lowest fuel cost per lesson.
- Activity log: period + user + operation type + text search.
- Cash book, reports, reconciliation log, instructor details: period + their own context filters.
- The last used filters per screen are remembered on the device.

### UI copy tone (decided)
- Interface text is written in **simple Palestinian colloquial Arabic** (e.g., "ما في حركات بهالفترة", "لسا ما انصرف") — and it is **gender-neutral**: no imperative verbs addressed to a man or a woman ("اكتبي / اكتب", "اضغط"). Use nouns and verbal nouns instead ("المبلغ الفعلي", "تسجيل الدخول", "سعر الدرس العملي مطلوب", "بحث عن طالب"). Applies to labels, buttons, errors, empty states, notifications and WhatsApp messages, in Arabic and English.

### Screens & flows added after UX review (required)
- **First-run setup checklist** (shown until done, reachable later from More): school name & logo → license types & prices → treasury accounts with opening balances → cars & instructors → employees & salaries (optional). Progress bar; "Register first student" is enabled only when the required steps are done.
- **Users screen:** list filtered by role (admin / instructor / staff), add user sheet (name, national ID, phone, role → default permissions; for instructors: cars and monthly salary), send login on WhatsApp, disable/enable (the last active admin cannot be disabled), open permissions per user.
- **Cars & instructors screen:** add car (name, plate, manual/automatic), assign/unassign instructors with one tap per chip, warning when a car has no instructor, link to the car report.
- **Money movement sheet** (from Accounts): Top up · Withdraw · Transfer, with account chips showing balances, amount, note, overdraft warning, and the result written on the save button.
- **Register student:** a "registered before? search by ID" field to add a new license (enrollment) to an existing student instead of duplicating them; inline national-ID validation ("valid and not duplicated").
- **Admin home (decided after review)** — "today's notebook page", top to bottom:
  1. Header: logo, school name, **today's date** (no greeting), sync status, notifications bell with unread count.
  2. **Cars now:** one row per car (scales to any number of cars): status dot, car name, "instructor with student · lesson N", and a pill "X min left" with a thin progress bar while a lesson timer runs; otherwise "free · last lesson 11:15". Caption: "2 running of 3 · 14 lessons today". Reliable because instructors log the lesson when it starts.
  3. **"Needs you" ("بدها منك"):** shown only when something is pending, max 3 rows + "and N more" (opens Notifications); each row has the action button itself (Record result / Review / Book). Orange dot = late or problem; grey = routine. When empty: one green line "nothing pending".
  4. **Today's page:** money card (in · out · net, tap → cash book filtered to today), then the last 5 operations of the day like the old notebook (registrations, payments, lessons, expenses, exam fees) with "all of today's operations (N)" → activity log for today; empty state "no operations yet today". The "close the day" button appears only after a configurable hour (Settings, e.g. 16:00) or when an earlier day is still open — not all morning.
  5. **Fixed quick-action bar** above the bottom navigation (thumb reach): New student (the only yellow button) · Payment · Expense, 44px high; the scroll area gets bottom padding so nothing hides behind it.
  - **Not on home:** student search (lives in Students, which opens with the search focused and "recently handled" student chips), total debts and other KPIs (Reports), lesson logging (Student profile).
- **Quick payment sheet:** step 1 = student search with recent students and their balances; step 2 = selected student (with "another student"), amount + quick chips, account chips; purpose, date and WhatsApp receipt are collapsed into one line ("for lessons · today · receipt on WhatsApp — change") and expand only when needed.
- **Instructor:** "without driving" is a small secondary link under the main button ("تسجيل بدون تشغيل السيارة"), shown only when enabled in Settings. **Only one running lesson per instructor:** while a timer runs, other cards' log buttons are disabled with the reason ("بعد ما يخلص درس سارة").
- **Student home:** recent lessons (number, instructor, date), payments with receipts, next exam, and log out.
- **Close day:** shows other days still open with a shortcut to close them.
- **Reports:** the month lock button appears only when the selected period is a full month.
- **Login:** show/hide password. **Archive:** search graduates by name or ID.
- Activity log entries open a detail view (see "Activity log") with before/after values, the record link, and a Restore button for archived records.
- **Edit student:** changed fields are highlighted with the old value ("كان: 0599123456"); a preview box shows the exact log sentence(s) that will be written before saving; optional reason; the save button shows the number of changes ("حفظ 1 تغيير"); license and car are read-only per enrollment; "withdraw from license" lives here.
- **Student statement rows are tappable:** payment rows open the receipt; other rows open the log detail.
- **Receipt preview:** school logo/name/address, receipt number, student, masked national ID, date/time, amount in numbers and words, purpose and account, charged to date / discount / paid / remaining, received by; actions: WhatsApp (primary), share PDF, print. Receipts are verifiable in the app by number.
- **Employee statement** (from Payroll): period filter, open net for the current month, timeline of salary / advance / deduction / bonus; + Advance / + Deduction / + Bonus sheets with reason chips (from Settings), amount, the effect written in words ("comes out of the cash now and is deducted from October's salary" / "reduces October's net · no cash movement"), and the new net on the save button. Payroll employee cards link to it ("الكشف"); no duplicate deduction/bonus entry point elsewhere.
- **Exams screen** (from More and notifications): tabs Upcoming / Awaiting result / Results; grouped by day; each row shows type, attempt number, car, and fee status; result buttons Passed / Failed / Absent appear **only from the exam date onward** (never at booking time — the booking sheet ends with a confirmation: what was charged, what was paid to the ministry and from which account, notification sent, "send date on WhatsApp", and a note that the result is recorded on exam day from "Needs you" or the Exams screen); an exam with no result after its date shows in "Needs you"; **no cancellation — only postponement (decided):** any booked exam without a result has "Postpone" → sheet with new date, reason chips (ministry postponed / student asked / car not ready / other) and optional details (e.g. ministry letter number); the paid fee stays on the same booking (no new charge, no new ministry expense); the student is notified; the row keeps a visible history ("postponed · was 22/10 · ministry postponed"); logged as "Admin postponed X's exam (practical) from 22/10 to 9/11 · reason". A postponement is never counted as an attempt; Failed/Absent show "book retake · ₪fee" which opens Book Exam; a banner lists students who reached the minimum but have no booking.
- **Notifications screen** (bell on admin home with unread count, also in More): tabs All / Money / Exams / Sync / System; unread highlighted, warning items in orange; each item opens its screen; "mark all read". Admin items: day not closed, exam today without result, rejected offline change, account balance below threshold, backup succeeded/failed, update available, students ready for exam.
- Dates shown to users in d/m/yyyy format.

### Money display rules
- In the **student statement** use words, not signs: "Charged ₪120", "Paid ₪300", "Discount ₪100", "Remaining ₪800". Signed amounts (+ / −) are used **only** in treasury/cash-book screens, where + = money in and − = money out. The same payment must never appear with opposite signs on two screens.
- **Money color system (one meaning per color, same on every screen; define as tokens):**
  - **Money in / paid / settled ("مسدّد") / matched** → green `#1E6B3E`.
  - **Money out / expenses / charges to a student ("عليه ₪120" in the statement)** → normal dark text `#14211F`. Spending is normal business, not an error, so it is never red.
  - **Outstanding debt / remaining owed** (student list balances, "عليه الآن", debts in reports) → amber `#B54708`.
  - **Discount / credit / neutral money info** → teal `#0A4246`.
  - **Big balance/total cards** → white on the brand teal; the net is the visually strongest number.
  - **Red `#B3261E` is reserved for real problems only:** negative net, reconciliation difference, overdue debt beyond the threshold in Settings, failed or rejected operations, validation errors.
  - Never color alone: every colored amount also carries a word or a sign. Signed amounts render left-to-right (`dir="ltr"` / bidi isolation) so "+₪300" never flips inside Arabic text.

### Visual & accessibility minimums
- Touch targets ≥ 44×44 px everywhere (≥ 48 px for primary actions); filter chips, steppers and segmented controls included.
- Minimum text size 12 px (Arabic), body 14–16 px; supports system font scaling up to 130% without clipping.
- **One yellow primary action per screen**; secondary actions are outlined; teal is for save/money confirmation; highlighted KPI cards use a light background with a teal border, not the button color.
- Month/period navigation uses words ("Previous / Next") rather than arrow glyphs that flip in RTL.

### Screen states (required on every screen — designed once as shared components)
- **Loading:** only on a cold first load: skeleton placeholders shaped like the content (shimmer, no spinners in lists). After that, screens render instantly from the local cache and refresh silently in the background; no full-screen loaders, no pull-to-refresh needed (optional only on long lists).
- **Empty:** every list/report has an empty state that says why it is empty and what to do next, with the button ("لسا ما في طلاب · سجّل أول طالب"); search with no result suggests another field ("جرّب رقم الهوية").
- **Offline:** a slim banner "working offline · N pending" with last sync time; every record not yet on the server shows a small clock icon until synced; nothing is blocked offline except actions that truly need the server (state them).
- **Error:** plain words — what happened, whether data is safe, what to do — with the action buttons and a short support code; never raw exceptions. Sync errors also go to Notifications.
- **No permission:** Admin sees the control disabled with a lock, and tapping it explains why ("ما عندك صلاحية … اسأل المدير"); instructors and students never see controls they cannot use (hidden).

### Save behavior (every save button: payment, lesson, expense, registration, settings)
- Idle: the button states the result before tapping ("حفظ ₪500 · يبقى عليه ₪440").
- Saving: spinner inside the button, button disabled (no double submit; plus idempotency keys). Writes go to the local DB first, so this normally takes well under a second even offline.
- Saved: the sheet closes, a snackbar for 5 s with **Undo** and a shrinking bar, the affected number pulses once; offline variant: "Saved on this phone · will sync when online".
- Failed: the button returns to idle and a red line under it explains what happened and what to do; the entered data is kept.

### Motion (few, purposeful, battery-friendly)
- Bottom sheet in 240 ms / out 200 ms (standard decelerate/accelerate), drag-down to dismiss. Button press: 0.96 scale 120 ms + Android ripple; light haptic only on successful save. Snackbar in 200 ms, stays 5 s. Changed number (net, balance) pulses once 400 ms. Day close: the lock closes once, 300 ms. Screen transitions: platform default only.
- Max 300 ms (400 ms for number change); animations never block input; the only continuous animations are first-load skeletons and the running lesson timer, which updates every minute (not every second) on screen.
- Respect the system "remove animations / reduce motion" setting: everything becomes instant.

### Dark mode (required)
- Theme setting per device: **System (default) · Light · Dark**, in Settings and on first launch. All colors come from semantic tokens with light and dark values (no hard-coded colors in widgets).
- Dark tokens (validated ≥ 4.5:1 on the dark card #18211F): background #0F1615, card #18211F, border #2E3B38, text #E8EEEC, secondary text #A9B5B2, brand/links #5CC2BE, money in #5BC98A, debt #F0A04B, discount/info #7FD3CF, problem #FF8A80, warning #F59A5B; the yellow primary button stays #F2B705 with dark text.
- Receipts, PDFs, Excel and printed reports are always light. The school logo is placed on a small light container in dark mode.

### Languages, RTL/LTR and mixed text (required)
- Arabic (default) and English, switchable per user in Settings and on the login screen; the whole layout mirrors (RTL ↔ LTR) using directional widgets/paddings only (`EdgeInsetsDirectional`, `AlignmentDirectional`, start/end), never left/right. Directional icons (back, chevrons, progress bars) mirror; media/clock icons do not.
- All strings in ARB files (Flutter gen-l10n), none hard-coded; Arabic plural rules handled (zero/one/two/few/many/other); the Arabic copy stays colloquial and gender-neutral, English plain and short.
- **User-entered names stay as typed** (Arabic names inside the English UI). Wrap every user-entered value and every amount in bidi isolation (FSI…PDI / `Directionality` per span) — otherwise lists like "أحمد خالد · محمد نبيل" flip order in English and "+₪300" flips in Arabic. Test both languages with mixed content.
- Digits: Western digits (0-9) in both languages; dates d/m/yyyy; currency "₪1,250" with the sign kept with its number.
- Messages sent to a student (WhatsApp/SMS/receipt) use that student's language preference (default Arabic); exported reports use the exporting user's language.

## Core domain rules
### Student
- Fields (minimum): full name, national ID (store as **text**, may have leading zeros), phone, license type, assigned car, status, created date. **[ASSUMPTION]** phone is needed to send credentials.
- Statuses: Registered → Theory in progress → Theory passed → Practical in progress → Ready for test → Passed / Failed → (Withdrawn at any point). Propose the exact state machine and which transitions are automatic vs manual.
- **A student can enroll in more than one license** over time (e.g., comes back later for another license type). Model this as **Student (person, one account) → Enrollments**: each enrollment has its own license type, registration fee (copied at registration), planned theory/practical lesson counts, status, car, lessons, exams, and ledger. Student identity data is entered once and reused.
- Within an enrollment the student is linked to **exactly one car** and **cannot be moved** to another car (a new enrollment may use a different car).
- Graduation, archiving, and the graduation summary are **per enrollment**; the student profile shows all enrollments (active and completed) and a total balance across them. Block two active enrollments for the same license type.

### Cars & instructors
- Car: only basic identification (name/plate). No insurance/licensing alerts.
- A car can be driven by **multiple instructors**; an instructor can drive multiple cars (many-to-many).
- Any instructor assigned to a car can add lessons to that car's students.
- Instructors are paid a **fixed monthly salary** (recorded as an expense, not computed from lessons).
- **Instructor details page** (Admin, permission-gated): instructor info, assigned cars, **all their students** (through their cars, with status and lesson progress), all lessons they gave (filter by date range, student, lesson type), lessons count per period and per student, exam results of their students (pass rate), salary payments, and their activity log entries. Exportable to Excel/PDF.

### Lessons
- Two lesson types: **Theory** and **Practical**.
- **Every license type is split into a Theory part and a Practical part, configured per license type in Settings** (decided pricing model):
  - **Registration fee** (fixed, per license type): charged once when the student registers. It covers **all theory lessons and the first theory exam**. Theory lessons are logged and counted but **never add a charge**.
  - **Practical lesson price** (per license type): every practical lesson adds one charge when it is logged.
  - **Theory retake fee** and **practical exam fee** (per license type): see Exams.
  - For each part: planned number of lessons and minimum lessons before that part's test.
  - Expected full price shown in settings and on the student profile = registration fee + planned practical lessons × practical price (e.g., ₪500 + 10 × ₪120 = ₪1,700) + expected practical exam fee. It is an estimate; the real total is what was actually charged. A per-license switch "practical lessons start only after passing the theory test" (default on). Lesson duration (minutes) is a global setting.
- License settings screen: chips for existing license types plus "+ New license"; name field; registration fee; theory part (planned lessons, minimum before test, theory retake fee); practical part (price per lesson, planned lessons, minimum before test, practical exam fee); the "practical after theory" switch; a computed, read-only expected total with its breakdown. Validation before save: name required and unique, fees and prices > 0, planned lessons ≥ 1, minimum ≤ planned lessons; invalid fields are outlined with a short message.
- **All prices and fees are entered by the Admin from Settings inside the app** (registration fee, practical lesson price, theory retake fee, practical exam fee, per license type). Nothing is hard-coded and no seed prices are needed; the app ships with no license types and the first-run setup asks the Admin to add at least one license type before registering students.
- **Price-change rule (decided):** every charge stores its own amount, **taken from Settings at the moment it is created**. Changing a price in Settings affects only charges created afterwards — for all students, including existing ones; charges already created never change. The registration fee and planned counts are copied into the enrollment at registration. The settings screen states this when a price is edited ("applies to lessons logged from now on, for all students").
- The instructor card and the one-tap button always show which part the student is in ("Log theory 5" vs "Log practical 7"); the counter and progress bar are per part.
- On registration the **registration fee is charged immediately** and the quick payment sheet opens right after registration so the first payment can be taken in the same flow; the student's planned counts are copied from the license. The instructor taps "Add lesson" → lesson 1 recorded; next time → lesson 2, etc. UI shows a counter (e.g., 3/10).
- **Do not pre-create empty lesson records.** Store a lesson only when it happens; derive the number and counter by ordering. This also avoids duplicate lesson numbers when two instructors add lessons offline at the same time — design for that case explicitly.
- **Every logged practical lesson immediately adds one charge to the student's ledger** at the practical price read from Settings at that moment; the amount is stored on the charge. Theory lessons add no charge. Lessons beyond the planned count are charged the same way; the UI only marks them "beyond plan". Undoing or archiving a lesson adds a reversal of its charge.
- **Student profile money detail:** a full statement listing every charge and payment in date order — each lesson with its number, date, instructor and the price it was charged at (old lessons at ₪100 and newer ones at ₪120 appear exactly as charged), registration fee, exam fees, discounts, and payments with their purpose and account — plus totals per charge type and the running balance.
- **Only practical lessons are linked to a car.** Theory lessons store no car and never count in car statistics or fuel-per-lesson.
- **"Without driving" lessons (optional, controlled from Settings):** a Settings switch "Allow marking practical lessons as without driving" (default off).
  - When off: nothing changes — one tap logs the lesson as today.
  - When on: the instructor card shows a small secondary toggle "بدون تشغيل" next to the main "Log practical N" button (the main one-tap flow stays the same; the toggle is only used when needed). The lesson is still counted, numbered and charged normally, but it is excluded from fuel-per-lesson in the car report (it still counts in lessons-per-car and lessons-per-instructor). It can also be changed afterwards by editing the lesson (logged).
- Lesson record: student, enrollment, instructor, car (practical only), type, start time, duration, created by, device, sync state. **[ASSUMPTION]** an optional instructor note per lesson.
- **Car vs instructor on a lesson (decided):** the student is linked to the **car** (fixed per enrollment); every lesson stores **both** the car and the **instructor who actually gave it**, because instructors on a car can change from lesson to lesson.
  - The car is filled automatically from the enrollment and cannot be edited on the lesson.
  - When an instructor adds the lesson, the instructor is automatically the logged-in instructor (no field shown).
  - When the Admin adds the lesson, it is also one tap: the instructor is set automatically to the last instructor who taught this student (or the car's only instructor). The Admin can correct the instructor afterwards by editing that lesson (logged in the activity log).
  - Instructor reports and "lessons per instructor" count lessons by the lesson's instructor field, never by the car.
- **Adding a lesson is ONE tap for everyone (Admin and instructor) — no form, no sheet, no confirmation screen.** The button on every student row and on the student profile shows the next lesson ("Log practical 8"). Tapping it immediately records the next number in sequence (if the student finished lesson 5, it records 6), with part (theory/practical), car, instructor and duration filled automatically, starts the in-card timer, and shows a snackbar with Undo. For a practical lesson the charge is added to the student's debt in the same write; the snackbar says so ("Practical 8 logged · +₪120 to Ahmed" — the amount is shown only to users allowed to see money).
- Adding a payment opens the quick payment sheet (see "Quick payment").
- **Lesson timer:** when an instructor adds a lesson, a countdown for the lesson duration **taken automatically from Settings** starts. The timer runs **inside that student's card on the same list screen** (the user never leaves the screen): the card switches to a "lesson running" state showing time left, a progress bar, "End now" and "Cancel (mistake)"; the rest of the list stays usable. After the timer ends the card returns to normal with the counter advanced. Restarting the app restores a running timer from the stored start time; when it ends the phone **rings/alerts** (must work offline and with the screen off — use scheduled local notifications/alarms, not a running loop; address Android 12+/14 exact-alarm and battery-optimization restrictions and iOS limits).
- A test cannot be booked before the student reaches the minimum lesson count (enforced, with an Admin override permission).

### Exams
- Theory and practical exams. Each attempt records: type, date, attempt number, result (passed / failed / absent).
- **Exam fees (decided) — every exam booking that costs money does two things in one step:**
  1. **Charges the student** the fee from Settings (a ledger charge of type "exam fee").
  2. **Records a school expense** (category "Ministry fees", linked to the student and the exam attempt, paid from a chosen account) for the amount the school pays the ministry on the student's behalf.
- Which exams cost money:
  - First theory exam: covered by the registration fee → no charge, no expense entry from this app (unless the Admin adds one).
  - **Theory retake** (after a failed theory attempt): "theory retake fee" from Settings → charge + ministry expense.
  - **Practical exam** (first attempt and every retake): "practical exam fee" from Settings → charge + ministry expense.
- The booking sheet shows both lines before saving ("Charge Ahmed ₪100 · Pay ministry ₪100 from cash") and the student profile shows per attempt: type, attempt number, date, result, "fee charged" and "fee paid to ministry".
- Each attempt records: type, date, attempt number, result (passed / failed / absent). Failing an exam returns the student to the matching stage and enables "Book retake".

### Money (ledger model)
- Use an **append-only ledger** per student: **typed charges** (registration fee, practical lesson, theory retake fee, practical exam fee), payments, and **discounts** (a permission-gated entry type; propose an optional maximum discount setting).
- **Balance is always computed** = charges − payments (− discounts). Never stored as an editable number. Propose whether a cached aggregate is needed for performance and how it stays consistent offline.
- Every charge stores its own amount at creation time (see the price-change rule), so later price changes never alter existing charges.
- **Payment purpose (decided):** each payment has a type — lessons, registration, exam fees, or general. The student has **one balance** (no separate balances per type); the purpose is shown on the receipt, the student statement and in revenue reports by type. Payments are not linked to individual lessons.
- Single currency: **Israeli Shekel (ILS / ₪)**.
- Payment receipt: PDF receipt with school logo/header, generated on-device (works offline) and **sent via WhatsApp** share.

### Quick payment (Admin / users with the payment permission)
- A "+ Payment" button on every student row and on the student profile opens a **quick bottom sheet over the current screen** (no navigation): student name and current balance, amount field with shortcut chips (100 / 200 / 500 / "all remaining"), payment purpose chips (lessons / registration / exam fees / general — default guessed from what is owed), account chips (cash / wallets / banks, last used preselected), date defaulting to today, "send receipt on WhatsApp" checked by default, and one button showing the result ("Save ₪500 · ₪300 remains"). Closing returns to exactly where the user was.

### Payment methods & treasury accounts
- Payment methods are managed in Settings: **Cash**, **Wallets** (e.g., several e-wallets), **Banks** (several bank accounts). Each method is a **treasury account** with a name, type, optional opening balance, and active/inactive flag.
- Every payment records which account received it; every expense records which account paid it.
- **"Top up" button per account** (شحن رصيد): adds funds to a wallet/bank/cash account (with amount, date, note). Also support **withdrawal** and **transfer between accounts** (e.g., depositing cash into the bank), all permission-gated and logged.
- Account balance is **computed**: opening + payments in + top-ups − expenses − withdrawals ± transfers.
- Treasury screen: total per account type (cash / wallets / banks) → tap an account → its full movement list with filters (date range, type, user) and running balance.
- Reports: revenue split by payment method and by account, for any period.
- Daily reconciliation and day closing: see "Daily cash book, reconciliation & closing".

### Receipts
- Receipt numbers must be unique and human-readable even when created offline on several devices: propose a scheme (e.g., per-device prefix + local counter, or a temporary number replaced by a sequential one on sync) and justify it.

### Expenses
- Categories: **Cars**, **Employees (salaries)**, **Ministry/licensing fees per student**, **Other**. Fields: category, amount, date, note, linked car/employee/student where relevant, paying account.
  - Cars: pick the car + quick sub-type chips (fuel, maintenance, licensing & insurance, wash). **Fuel adds an optional liters field** (no odometer).
  - Salaries and advances: handled by the payroll module (see "Payroll & advances"); the expense sheet's Salaries chip opens it.
  - Ministry fees: normally created automatically by exam booking (see Exams). Manual entry: pick the student from a **searchable student list** (name or national ID); students with a booked exam and no fee recorded yet appear first, tagged with exam type and date; amount prefilled from Settings; linked to that exam attempt.
  - Other: an item name from a reusable list the Admin can extend (rent, electricity, internet, stationery, …).
- **Quick expense sheet** (same pattern as quick payment): "+ Expense" on the Expenses screen and on the Admin home opens a bottom sheet over the current screen: category chips → the matching link chips appear (Cars → pick a car; Salaries → pick an employee; Ministry → pick a student), amount, short note, "paid from" account chips each showing its current balance (the default account depends on the category, e.g., bank for salaries; the user can switch), date defaulting to today, and one button showing the result ("Save ₪350 · ₪5,850 left in cash"). Warn if the expense is larger than the account's balance.

### Payroll & advances
- Employee file: name, role (instructor / staff), monthly salary, active flag.
- **Advance (سلفة):** recorded any day with amount, date, paying account and note; it leaves the treasury immediately.
- **Deductions and bonuses:** recorded per employee per month with a type (absence deduction, other deduction, overtime/bonus, other bonus), amount and note.
- **Monthly salary run:** one screen per month listing every active employee: salary + bonuses − deductions − advances = **net to pay**, with each line expandable. "Pay" records the payment from a chosen account and closes that month's advances. If advances exceed the month's net, the remainder carries over to next month automatically.
- **Payroll months (decided):** a payroll month = the month worked (October's salary may be paid on 1/11 and still belongs to October). The screen opens on the **current month**; Previous/Next plus a tap on the month title opens a month picker (newest first, with a year switch) where each month shows its state: "N unpaid" (amber) / "all paid ✓" / "all paid · locked 🔒". If an older month still has unpaid employees, the current month shows a banner "September payroll: 1 employee not paid yet · view".
- Every month is kept forever: each employee row stores the salary amount **as it was that month** (a later salary change never alters past months), and paid rows show when and from which account ("paid 1/10 · bank"). Months covered by a locked accounting month are read-only (no advance/pay buttons; corrections are made in the open month and logged); every month can be exported to Excel/PDF.
- Paying early (before month end) is allowed and shown ("paid 20/10 · cash · early"); advances recorded after an early payment carry to the next month.
- **Employee statement:** every salary, advance, deduction, bonus and payment with a running balance (what the school owes the employee or the employee owes the school).
  - Opens for the employee it was launched from (Payroll "Statement" button preselects them); the header is an **employee picker** (search, each employee with this month's state "paid ✓ / not yet"; disabled employees stay listed as "disabled" with their full history).
  - Period filter (this month / last 3 months / this year / custom); totals for the period: paid to the employee, advances, and what is due this month (net so far).
  - Grouped **by payroll month**, each month header showing its state ("net so far ₪1,200" / "paid ₪1,400"). Every row shows type tag, description, **date and time, account** (for money movements), **who recorded/paid it** and any note ("paid by Admin · after deducting ₪200 advance and ₪100 bonus"); tapping a row opens its activity-log detail.
  - Advance / deduction / bonus can be added from here; export to PDF/Excel.
- Accounting rule: the monthly **salary expense** in reports = salary + bonuses − deductions (counted once); advances are not double-counted as a separate expense. The **daily cash book** shows the actual cash movement on the day it happened (advance on its day, net payment on payday).
- Permissions: view payroll, add advance, add deduction/bonus, run payroll.

### Daily cash book, reconciliation & closing
- **Cash book screen (الوارد والصادر):** period switcher (today / this week / this month / custom), totals for **in, out, net**, split by account (cash, each wallet, each bank) and by type (lessons, registration, exam fees, other income / salaries, advances, cars, ministry, other), and the full movement list below; tapping a movement opens it. Weekly net and monthly net are shown with a per-day breakdown.
- **Reconciliation & day closing (مطابقة وإغلاق):** at end of day the Admin opens "Close day": for each account the app shows the system balance; the Admin enters the actual counted cash and the actual bank/wallet balances from their apps; differences are highlighted and **a reason is required for any difference**; the screen shows the day's in, out and net. "Close day" stores a closing record: date, per-account system vs actual and difference, reasons, day totals, who closed it and when.
- A closed day is read-only: entries dated in it are blocked; the Admin can reopen it with a permission (logged) and close again.
- **Late entries:** a record created offline before the close but synced after it is accepted, and the closed day is flagged "entries arrived after closing — review"; the flag is cleared after review.
- **Reconciliation log page (سجلات المطابقة):** one row per closed day: date, net, matched ✓ / difference ⚠, closed by; tap for full details; filters by period and status; export to Excel/PDF.
- A month can only be locked (month report lock) when all of its days are closed.

### Archive & audit (mandatory)
- **Nothing is ever hard-deleted.** Every edit or delete goes to an archive and stays visible: who, when, what changed (before/after values), and reason (optional). Every edit/archive/restore produces an activity-log entry in the sentence format defined under "Activity log".
- Archive screen with filters; Admin can restore archived records, and can permanently purge archived records by period (see "Graduated students & archive lifecycle").
- Money corrections are done by reversal entries, not by mutating the original record.

## Validation, safety & user messages (required for every operation)
- **Input validation** with inline, specific messages: required fields, amount > 0, national ID = 9 digits with check-digit validation (warn, Admin can override), phone format, duplicate national ID blocked.
- **Business-rule checks** before saving: lesson beyond the planned count (informational tag only), minimum lessons before booking a test, payment larger than the remaining balance (warn; record as student credit), discount above the allowed maximum, entries dated inside a locked month, missing permission.
- **Duplicate protection**: buttons disable during save; idempotency keys on every write; warn when the same lesson or payment for the same student is entered twice within a short window.
- **Money confirmations**: a summary dialog (student, amount, account, new balance) before saving any payment, discount, expense, top-up, or transfer.
- **Undo**: a short undo snackbar after a save, implemented as a reversal entry (logged), never as a hard delete.
- **Clear messages** in AR/EN: success ("Payment of ₪500 saved — new balance ₪300"), offline ("Saved on this phone — will sync when online"), and errors that say what happened and what to do, without technical jargon. Define a message catalog and error-code mapping.
- Always-visible **sync status** (synced / pending N items / error) with a manual "sync now".

## Data integrity check
- An Admin "Check data" action (and an automatic background check after sync) that recomputes balances, lesson counts, account balances, and month snapshots from source records, compares them with cached aggregates, fixes cache drift automatically, and reports any real inconsistency clearly.

## Settings (Admin)
Payment methods / treasury accounts, School name, school logo upload (used in app header and reports), license types — each with registration fee, practical lesson price, theory retake fee, practical exam fee, planned theory/practical lessons, minimum before each test, and the "practical after theory" switch — lesson duration, the "without driving" lesson option switch, "Other" expense items, deduction/bonus types, maximum discount, currency label, language (AR/EN), users & permissions.

## Notifications
- To student: theory exam booked, practical exam booked, **lesson started** (when the instructor adds a lesson).
- To instructor: local alarm when the lesson timer ends.
- To admin (in-app notifications screen, push for the important ones): day not closed by a set hour, exam today with no result, offline change rejected after sync, treasury account below a threshold (set in Settings), backup success/failure, update available, students who reached the exam minimum without a booking.
- Explain behavior when the sender is offline (queued and delivered after sync — state the latency honestly) and what requires a backend trigger.

## Reports
- In-app, clear, fast, with strong filtering: date range (default: current month), instructor, car, license type, student status, lesson type.
- **Car report:** per car and period: lessons given, fuel cost, liters, **fuel cost per lesson**, maintenance and other car costs, total car cost per lesson; comparison between cars.
- Required reports: revenue (payments received) split by cash / wallets / banks, per account and by payment purpose, treasury account balances and movements, outstanding debts per student and total, expenses by category, net (revenue − expenses), lessons per instructor (and per student), lessons completed, students passed theory, students passed practical, students by status, exam attempts and pass rate.
- Export to **Excel** and **PDF**, with school logo and header; PDFs must render Arabic correctly (RTL shaping, embedded Arabic font).
- Lists everywhere need search and filters.

## Platforms
- **Flutter, Android only** for this version. Admin, instructors and students all use the same app (role-based UI). A web admin panel is out of scope (possible phase 2).
- **Two build flavors from one codebase (decided):**
  - **`direct`** — APK distributed outside the Play Store (current client). Includes the self-update system (below), `REQUEST_INSTALL_PACKAGES`, and **automatic SMS sending from the device** (`SEND_SMS`).
  - **`play`** — the Google Play build. Must pass Play review: **no self-updater and no `REQUEST_INSTALL_PACKAGES`** (Play forbids apps updating themselves outside Play) — use Play In-App Updates (flexible + immediate for the forced minimum build) instead; **no `SEND_SMS`** (restricted to default SMS apps) — SMS goes through the SMS app with a prefilled message (intent, user taps send) or WhatsApp.
  - Flavor differences live behind interfaces (`UpdateService`, `SmsService`) selected at build time; manifests are per flavor so the Play build does not even declare the restricted permissions. Same `applicationId` question must be decided: separate IDs (e.g. `.direct` suffix) means users cannot move between them without reinstalling — document the choice.

## Permissions, notifications & privacy (required — Play-ready from day one)
- **Notification permission (Android 13+):** never asked on first launch. Ask in context: instructor on the first lesson timer, student after first login, admin when opening Notifications — with a short explanation screen before the system dialog. If denied: a banner in the Notifications screen and Settings with "Enable notifications" opening the system settings. The app works fully without it.
- **Notifications ring when the app is closed:** server-triggered notifications via FCM (Cloud Functions) with proper Android notification channels (money, exams, lessons, system) so users can tune them.
- **Lesson-end alarm with the app closed:** an ongoing notification with a countdown during the lesson + an exact alarm at the end; on Android 14+ this needs the user-granted "Alarms & reminders" permission (`SCHEDULE_EXACT_ALARM`) — request it once for instructors with an explanation; if refused, fall back to an inexact alarm and say so. Do not use `USE_EXACT_ALARM` or full-screen intents (reserved for alarm/calling apps on Play). Verify against current Play policy and Android version behavior at build time.
- **SMS (direct flavor):** sent automatically from the device in the background through a queued, retrying background job (WorkManager): credentials, receipts, exam booked. Respect a daily cap, show failures in Notifications, log every sent message (to whom, type, status). Ask for `SEND_SMS` in context with an explanation. **Play flavor:** prefilled SMS/WhatsApp intent.
- **No account deletion feature (decided).** Accounts are created only by the Admin, never self-registered, so there is no in-app sign-up; state this in the Play Console account-deletion declaration. Users can be **disabled** by the Admin (already in Users). Personal-data requests go to the school via the contact in the privacy policy. If Play review still demands deletion, raise it with the developer — do not add it unilaterally.
- **Privacy:** a privacy policy page (hosted next to the download page, AR/EN, linked in-app and in the Play listing) and a complete Data Safety form: what is collected (name, national ID, phone, lessons, payments, device ID for the log), why, encrypted in transit and at rest, not shared/sold. National ID shown masked (40•••••67) unless the user has the "view national ID" permission; every Excel/PDF export is written to the activity log; no analytics/ads SDKs that collect personal data; crash reports without personal data.
- **About screen** (from More, all roles): app name and logo, version and build, "check for update" (flavor-aware), privacy policy, terms of use, contact support, open-source licenses (`showLicensePage`).

## App download web page (required)
- A small public web page (e.g., on Firebase Hosting) with the school's name and logo, AR/EN, mobile-first, from which users download the Android app.
- The "Download for Android" button always serves the **latest APK** from the same version info used by the in-app updater (single source of truth); shows version number, size, and release date.
- A QR code of the page for printing at the school, and short illustrated steps for allowing "install unknown apps" on Android.
- If opened on iPhone or desktop: show a clear message that the app is Android-only (desktop shows the QR code).
- The WhatsApp/SMS message that sends a student their credentials includes this download link.
- Fast and lightweight: static page, no framework needed, loads in under 1 second on 3G.

## In-app update system (required — `direct` flavor only; the `play` flavor uses Play In-App Updates)
- The server holds the latest version info: version name, build number, APK download URL, file size, SHA-256 checksum, release notes (AR/EN), and a **minimum supported build** for forced updates.
- On app launch (non-blocking, after the first frame, at most once per N hours unless forced) the app checks the server. If a newer build exists:
  - Optional update: dialog with release notes, "Update now" / "Later".
  - Forced update (current build < minimum supported): a blocking update screen; the app cannot be used until updated (but must never lose unsynced data — sync first or keep the local queue intact across the update).
- Download inside the app on a dedicated screen with a **progress bar** (percent, MB downloaded / total, speed), cancel/pause.
- **Resumable download**: continue from where it stopped after a network drop or app restart (HTTP Range requests, partial file kept on disk, resume state persisted). Verify the server/storage supports Range.
- After download: verify size + SHA-256, then launch the Android package installer (REQUEST_INSTALL_PACKAGES permission, FileProvider, "install unknown apps" permission flow explained to the user). Same signing key every release so data is preserved.
- Each update must **replace the installed app in place** (never a second copy): same `applicationId`, same signing key, and a strictly increasing `versionCode`; local data and login are preserved.
- On the first launch after an update, delete the downloaded APK and any partial downloads; clean up old APK files; handle low storage, corrupted files, and Android version differences.
- Specify: where version info and APKs are hosted (e.g., a Firestore/Remote Config doc + Firebase Storage or another host), the release procedure the developer follows to publish an update, and the packages to use.

## Architecture stance
- **No microservices.** Use a **modular monolith**: one Flutter app and one backend, split into clean, independent feature modules (Students, Lessons, Exams, Finance/Ledger, Expenses, Payroll, Cash book & day closing, Reports, Settings, Users & Permissions, Archive/Audit, Sync, Updates), each with its own presentation/domain/data layers and explicit interfaces. Justify module boundaries so any module could later be extracted into its own service.
- **Multi-tenant ready from day one**: every record carries a `schoolId` (and optional `branchId`) so the system can grow into multiple branches or a SaaS for other schools without a rewrite. Security rules must scope all access by `schoolId`.

## Caching strategy (required)
- The **local database is the primary cache and the UI's only read source** (offline-first, cache-first); the network only updates it in the background.
- In-memory cache for settings, current user, and permissions (loaded once at startup, invalidated on change).
- Image cache: school logo stored compressed locally once; re-download only when its version changes.
- **Precomputed aggregates** for dashboards/reports (e.g., per-student balance and lesson counts, monthly totals), updated incrementally on writes and fully recomputable from source records to self-heal.
- For each cache: define what is cached, where, its invalidation rule, staleness tolerance, and size limit.

## Operational & engineering requirements
- **Time source**: server timestamps are authoritative for ordering and reports; handle wrong device clocks and offline-created records (store both client and server time).
- **Local schema migrations** across app versions with no data loss, including unsynced records.
- **Crash reporting and logging** (e.g., Crashlytics) with no personal data in logs.
- **Environments**: separate dev and prod projects; never test on real school data.
- **Backups (decided, three layers):**
  1. **Full restorable backup:** scheduled daily managed export of the whole database (e.g., Firestore scheduled export / point-in-time recovery) to a Cloud Storage bucket in the school's project, with retention (e.g., daily for 30 days, monthly for 12 months) and a **documented, tested restore procedure** (restore into a test project quarterly). Enable point-in-time recovery if available on the plan.
  2. **Readable daily copy to the school's Google account:** a scheduled backend job generates an Excel workbook (the day's movements, day summary, students and balances, expenses, payroll) and **uploads it to the school's Google Drive** in dated folders (Year/Month), and **emails it to the school's Gmail** with the day summary in the email body (attachment only if under the size limit; otherwise a Drive link).
  3. **Manual export:** the Admin can export everything to Excel from Settings at any time.
  - Backup jobs run server-side (they need the Blaze plan); failures are reported to the developer and shown to the Admin ("last successful backup: …"). Credentials for Drive/Gmail are stored server-side only, never in the app.
- **Remote config / feature flags** to disable a broken feature or show a message without shipping an update.
- **Localization**: AR/EN strings, number, currency and date formatting per locale.
- **Low-end devices**: all performance targets must be met on a low-end Android phone.
- **Account security**: Admin can reset passwords and instantly disable any account (e.g., lost instructor phone); define session handling on multiple devices.
- **Cost estimate**: monthly hosting cost at this scale and at 10× scale.

## Confirmed decisions
- **Password reset**: done by the Admin only.
- **Withdrawal**: no refunds. A withdrawn student's ledger is frozen as-is.
- **Sessions**: one account can be logged in on **any number of devices**; login is **persistent** (stay signed in, no login prompt on every launch) until logout or until the Admin disables the account / revokes sessions.
- **Admin home**: see "Admin home (decided after review)"; KPIs such as total outstanding debt live at the top of Reports.
- **Backend ownership**: the Firebase project is created under the **school's own email** (the school owns the account and data).

## Multi-account & multi-device consistency (required)
- Several different users may log in and out on the **same phone**: local data must be **isolated per user/session**; on logout or user switch, nothing from the previous user may appear or mix in. Define what happens to unsynced writes on logout (block logout until synced, or keep them safely queued under their original author — never attribute them to the next user).
- The same user on several devices, and several users editing the same student at once, must never corrupt balances or lesson counts: rely on the append-only ledger, client-generated IDs, idempotent writes, and derived counters. Specify the conflict rule for every editable entity.
- Cached aggregates must be recomputable from source records so any inconsistency self-heals.

## Activity log (operations page, required)
- **Every operation** (create, edit, delete/archive, restore, purge, login, permission change, settings change, payment, lesson, exam, expense) is recorded with: date & time (server time + device time), **who** did it, device, entity and record affected, and before/after values.
- An **Activity page** for the Admin, **filtered to today by default**, with a changeable date range and filters by user, operation type, module, and student; searchable; exportable to Excel/PDF.
- Log entries are immutable and are never removed by archive purges.
- **Every change reads as a plain sentence, field by field: "[who] changed [field] of [record] from [old] to [new]"** — e.g. "المدير غيّر مبلغ الدفعة من ₪500 إلى ₪450", "المدير غيّر الجوال لأحمد خالد من 0599123456 إلى 0597654321", "المدير غيّر سعر الدرس العملي (خصوصي) من ₪100 إلى ₪120 · للدروس الجاية بس", "المدير غيّر صلاحية «إضافة دفعة» للمدرب سامي من مغلقة إلى مفتوحة", "المدير أرشف درس عملي 3 لرامي عادل · السبب: تسجيل مرتين". Each line also carries time, device, and reason if given. This applies to **every** create, edit, archive (delete), restore, purge, settings change, price change, permission change, and day close/reopen — for students, lessons, payments, discounts, expenses, payroll items, cars, users, accounts and settings.
- Store each change as structured data (`entity, recordId, field, oldValue, newValue, actor, deviceId, serverTime, deviceTime, reason, opType`) and render the sentence from a localized template (AR/EN), so the wording stays consistent and translatable. One entry per operation; multi-field edits list each changed field.
- Log list rows show the sentence in a highlighted box under the title; tapping a row opens the **detail view**: the full sentence, a before/after table, who/when/device/reason, link to the affected record, and **Restore** for archived records. Restoring never edits the old entry — it adds a new entry ("المدير رجّع …").
- Edit forms preview the exact sentence(s) that will be logged before saving.

## Graduated students & archive lifecycle
- When a student **passes the license**, their profile collapses to a permanent **graduation summary**: name, national ID, license type, completion date, total charged, total paid, total discount, number of lessons — visible in a "Graduates" list with filters.
- The detailed records behind it (individual lessons, payments, exam attempts) move to the **archive**.
- Purge scope is **archived records only**: details of finished/graduated students and old versions of edited or deleted records. Records of active students (their lessons, payments, exams) can never be purged.
- The Admin (permission-gated) can **permanently delete archived records by period** (e.g., "everything archived in the previous month", or a custom date range), with a preview of what will be deleted, a strong confirmation, and an automatic Excel export/backup offered before deletion.
- Purging must **not change historical reports**. This is done with a manual **"Lock month report" (تثبيت التقرير) button** per month:
  - The Admin (permission-gated) locks a finished month; the system saves that month's final totals as a snapshot (revenue, expenses by category, net, outstanding debts at month end, lessons per instructor, lessons completed, passed theory, passed practical, new registrations, graduates).
  - Reports for a locked month read from the snapshot; the month is shown as "Locked on <date> by <user>".
  - Archived records can only be purged if their dates fall inside **locked months**.
  - New, edited or backdated entries dated inside a locked month are blocked; the Admin can **unlock** the month (permission-gated, logged), fix, and lock again.
  - Show a reminder on the Admin dashboard when the previous month is not yet locked.
- The graduation summary, monthly snapshots, and the activity log are never purged.

## Open questions for the client (list them in the spec; use the stated default until answered)
1. Existing students in the notebook: manual entry or Excel import? (default: provide an Excel import template)


## Proposed technical direction (verify or challenge)
- Flutter + Firebase: Firestore with offline persistence (unlimited cache), Firebase Auth (national ID mapped to a synthetic email), Cloud Storage (logo), FCM + Cloud Functions (server-side notifications, audit triggers), Security Rules for permissions.
- Known risks to address: Firestore transactions do not work offline (use batched writes and design the ledger to be conflict-free); report queries over cached data; Cloud Functions require the Blaze plan (billing card) — give a fallback if billing is not possible; read costs for computed balances.
- Compare briefly against: (a) Flutter + local SQLite (Drift) as the source of truth + custom sync to ASP.NET Core/SQL Server; (b) an offline-first sync engine (e.g., PowerSync + Postgres). Recommend one, with reasons tied to this project's size, budget, offline needs, and a solo developer.

## Design reference (approved mockups)
- The approved interactive mockups (Arabic RTL, 390×844) are on the design canvas: https://claude.ai/artifact/U85CDB6gQqsYfoVcagcDZ2 — every screen, flow, state (loading/empty/offline/error/permission), save behavior, motion, color tokens (light/dark), and the English LTR version of Home.
- Build screens to match them; this prompt holds the rules behind them. If the mockups and this prompt ever disagree, stop and ask the developer — do not pick one silently. "Home (old, for comparison)" on the canvas is superseded and must not be built.

## Deliverables (produce all, in this order)
1. **Requirements spec**: functional requirements by module, non-functional requirements, explicit list of assumptions and open questions for the client.
2. **Permission matrix**: every operation × role defaults, plus how per-user overrides are stored and enforced.
3. **Student state machine** (Mermaid stateDiagram) with transition rules.
4. **ER diagram** (Mermaid erDiagram) + full data dictionary: every entity, field, type, required/optional, constraints, indexes. If Firestore: also the collection/subcollection layout and the denormalization decisions.
5. **Architecture**: module map of the modular monolith, caching design per "Caching strategy", layers (presentation / state management / domain / data / sync), recommended packages with versions-agnostic names, folder structure, and the offline-first sync design: write queue, conflict resolution per entity, idempotency (client-generated IDs), clock/ordering, and sync status shown to the user.
6. **Key flows** as sequence diagrams (Mermaid): registration with registration fee + first payment, book exam (student charge + ministry expense in one step), monthly payroll with advances, end-of-day reconciliation and closing incl. late offline entries, daily backup jobs, payment into a chosen account + receipt number assignment offline, account top-up and transfer, register student + send credentials, user switch/logout on a shared phone with unsynced data, student graduation → summary + archive, purge archived records by period, add lesson (offline, two instructors at once) + timer + notification, add payment + receipt, book practical exam + ministry fee expense, edit/delete with archive, sync after a long offline period.
7. **Screens & UX**: verify every rule in "Usability & connected operations"; full screen list per role, navigation map, content of each screen, empty/loading/error/offline states, one-tap primary actions, RTL/LTR handling, accessibility (touch targets, font scaling), and the design system (colors, typography, components). Prioritize speed of daily actions: adding a lesson or a payment must take ≤ 2 taps from home.
8. **Reports spec**: each report's definition (exact formula), filters, data source, how it's computed efficiently, and the Excel/PDF layout.
9. **Performance, battery & memory plan**: how the design meets every target in "Performance, startup & battery targets" — startup sequence, query and index plan, caching, background behavior, alarm strategy, memory limits for report generation, app size, and the measurement checklist.
10. **In-app update system design**: version endpoint schema, check logic (optional vs forced), resumable download implementation, integrity check, install flow, release procedure, and failure handling.
11. **Security & operations**: security rules/API authorization per permission and per `schoolId`, password reset and account disabling, student data privacy, backups and restore, environments, crash reporting, remote config, and the monthly cost estimate.
12. **Testing plan**: unit tests for ledger math and lesson counting, offline/sync conflict tests, rules tests, update/resume-download tests, startup and battery measurements, and a manual QA checklist.
13. **Phased delivery plan**: MVP scope vs phase 2, with milestones a solo developer can hit, and the risks per phase.

Format: Markdown with clear headings, tables for matrices and data dictionaries, Mermaid for diagrams. Be specific and opinionated; justify each major decision in one or two sentences.
