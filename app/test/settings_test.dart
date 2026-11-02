import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:driving_school/core/db/database.dart';
import 'package:driving_school/core/domain/money.dart';
import 'package:driving_school/core/sync/outbox.dart';
import 'package:driving_school/features/settings/settings_actions.dart';
import 'package:driving_school/features/students/student_actions.dart' show ActionError;
import 'package:flutter_test/flutter_test.dart';

import 'support/test_db.dart';

void main() {
  late AppDatabase db;
  late SettingsActions s;
  setUp(() {
    db = memoryDb();
    s = SettingsActions(db, Outbox(db, testSession));
  });
  tearDown(() => db.close());

  test('defaults until set, then the saved value; school name falls back', () async {
    expect(await s.queries.intOf('lessonDurationMin'), 45);
    expect(await s.queries.schoolName(), 'مدرسة القيادة');
    await s.setSetting('lessonDurationMin', 40);
    await s.setSetting('school', {'name': 'مدرسة الأمل', 'phone': '', 'address': ''});
    expect(await s.queries.intOf('lessonDurationMin'), 40);
    expect(await s.queries.schoolName(), 'مدرسة الأمل');
    expect((await db.select(db.outboxOps).get()).map((o) => o.type), ['setting.set', 'setting.set']);
  });

  test('a new license = type + first prices; unchanged prices are not re-sent', () async {
    final f = LicenseForm(name: 'شحن', registrationFee: 70000, practicalLessonPrice: 15000, theoryRetakeFee: 8000, practicalExamFee: 12000, plannedPractical: 14, minPractical: 12);
    expect(f.expectedTotal, Money.shekels(700 + 14 * 150 + 120));
    await s.saveLicense(f: f, effectiveFrom: '2026-10-26');
    final l = (await s.queries.licenses()).single;
    expect(l.price?.practicalLessonPrice, 15000);
    expect((await db.select(db.outboxOps).get()).map((o) => o.type), ['licenseType.add', 'licensePrice.set']);
    await s.saveLicense(type: l.type, current: l.price, f: LicenseForm.of(l.type, l.price), effectiveFrom: '2026-10-26');
    expect((await db.select(db.outboxOps).get()).length, 2);
  });

  test('invalid licenses are refused with a clear reason', () async {
    final f = LicenseForm(name: 'خصوصي', registrationFee: 50000, practicalLessonPrice: 12000, theoryRetakeFee: 8000, practicalExamFee: 10000, plannedPractical: 8, minPractical: 10);
    expect(f.practicalError, 'الحد الأدنى أكبر من عدد الدروس');
    await expectLater(s.saveLicense(f: f, effectiveFrom: '2026-10-26'), throwsA(isA<ActionError>()));
  });

  test('setup checklist follows the data', () async {
    var steps = await s.queries.setup();
    expect(steps.where((x) => x.required && !x.done).length, 4);
    await s.setSetting('school', {'name': 'مدرسة الأمل'});
    await s.addAccount(name: 'كاش', kind: 'cash', opening: Money.shekels(500));
    await db.into(db.cars).insert(CarsCompanion.insert(id: 'c1', name: 'سيارة 1'));
    await db.into(db.carInstructors).insert(CarInstructorsCompanion.insert(id: 'l1', carId: 'c1', employeeId: 'e1', from: const Value('2026-10-01')));
    await s.saveLicense(f: LicenseForm(name: 'خصوصي', registrationFee: 50000, practicalLessonPrice: 12000, theoryRetakeFee: 8000, practicalExamFee: 10000), effectiveFrom: '2026-10-01');
    steps = await s.queries.setup();
    expect(steps.where((x) => x.required && !x.done), isEmpty);
    await expectLater(s.editAccount((await db.select(db.treasuryAccounts).get()).single, active: false, balance: Money.shekels(500)), throwsA(isA<ActionError>()));
  });

  test('sign-out wipes this user\'s data but keeps the device identity and counters', () async {
    await s.setSetting('lessonDurationMin', 40);
    await db.kvSet('deviceId', 'dev1');
    await db.kvSet('receiptCounter', '7');
    await db.kvSet('recentStudents', 'a,b');
    await db.wipeUserData();
    expect(await db.select(db.settings).get(), isEmpty);
    expect(await db.select(db.outboxOps).get(), isEmpty);
    expect((await db.kvGet('deviceId'), await db.kvGet('receiptCounter'), await db.kvGet('recentStudents')), ('dev1', '7', null));
  });
}
