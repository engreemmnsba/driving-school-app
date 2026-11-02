# 02 · Permission matrix

Each row is one checkbox on the permissions screen ("What does X do?"). ✓ = on in the template. Options shown when on. `needs` = turned on automatically with it (and turned off when its dependency is removed).

| Key | Task (as shown in Arabic) | Needs | Admin | Accountant | Secretary | Instructor | Options |
|---|---|---|---|---|---|---|---|
| students | رؤية الطلاب وملفاتهم | — | ✓ | ✓ | ✓ | ✓ (own cars) | scope: own cars / all |
| addStudent | تسجيل طالب جديد | students | ✓ | | ✓ | | |
| editStudent | تعديل بيانات طالب | students | ✓ | | ✓ | | |
| lesson | تسجيل درس | students | ✓ | | | ✓ | |
| editLesson | تعديل درس أو أرشفته | lesson | ✓ | | | | |
| exam | حجز اختبار وتأجيله وتسجيل النتيجة | students | ✓ | | ✓ | | |
| seeMoney | رؤية حسابات الطلاب | students | ✓ | ✓ | ✓ | | |
| addPay | تسجيل دفعة من طالب | students, seeMoney | ✓ | ✓ (cash) | ✓ (cash) | | accounts: cash / cash+wallet / all |
| editPay | تعديل دفعة أو إرجاعها | addPay | ✓ | | | | |
| discount | إعطاء خصم | seeMoney | ✓ | | | | up to ₪50 / ₪100 / no limit |
| addExp | تسجيل مصروف | — | ✓ | ✓ | | | categories; accounts (same list as addPay) |
| seeExp | رؤية كل المصاريف | — | ✓ | | | | |
| editExp | تعديل مصروف أو أرشفته | seeExp | ✓ | | | | |
| closeDay | عدّ الصندوق وإغلاق اليوم | — | ✓ | ✓ | | | blind / full |
| seeBal | رؤية أرصدة الصناديق | — | ✓ | | | | |
| moveMoney | شحن وسحب وتحويل | seeBal | ✓ | | | | |
| cashbook | رؤية الوارد والصادر | — | ✓ | ✓ (today) | | | today / all periods |
| reopen | إعادة فتح يوم مسكّر | closeDay | ✓ | | | | |
| payroll | رؤية الرواتب | — | ✓ | | | | |
| advance | تسجيل سلفة لموظف | payroll | ✓ | | | | |
| dedBon | خصم أو مكافأة لموظف | payroll | ✓ | | | | |
| paySalary | صرف الرواتب | payroll | ✓ | | | | |
| reports | رؤية التقارير المالية | — | ✓ | | | | |
| export | تصدير Excel و PDF | reports | ✓ | | | | |
| lockMonth | تثبيت الشهر | reports | ✓ | | | | |
| log | رؤية سجل العمليات | — | ✓ (all) | ✓ (own) | ✓ (own) | | own / all |
| users | إدارة المستخدمين والصلاحيات | — | ✓ | | | | |
| settings | تعديل الإعدادات والأسعار | — | ✓ | | | | |
| archive | الأرشيف والاسترجاع | — | ✓ | | | | purge = Admin only |
| backdate | تسجيل بتاريخ قديم | — | ✓ (any open day) | ✓ (2 days) | | | how far back |

Student: fixed read-only access to their own profile, lessons, exams and **full money detail** (no checkbox).

## Enforcement
1. **Phone** hides what the user can't do (instructor/student) or shows it locked with the reason (Admin previews) — UX only.
2. **`applyOps`** checks the *current* permission for every op — the real gate.
3. **Security rules** (read side) use custom claims `{schoolId, kind, money, balances, carIds}` so data a user may not see is **never synced** to their phone (balances, opening balances, other cars' students, salaries).
4. Every permission change → activity log ("المدير شغّل «تسجيل دفعة» لسلمى") + `permVersion`++ + claims refresh; offline ops made under the old version are re-checked and may be rejected visibly.
5. The last active Admin cannot lose `users` or be disabled.
