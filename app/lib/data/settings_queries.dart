import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/db/database.dart';
import '../core/domain/money.dart';
import 'money_queries.dart';

/// Defaults used until the Admin changes them (A2, A3, D4).
const settingDefaults = <String, Object>{
  'lessonDurationMin': 45,
  'closeReminderHour': 16,
  'overdueAmount': 30000,
  'overdueDays': 30,
  'salaryDueDay': 0,
  'withoutDrivingEnabled': false,
  'theoryLessonsEnabled': true,
};

class SchoolInfo {
  const SchoolInfo({required this.name, this.phone, this.address});
  final String name;
  final String? phone;
  final String? address;
  bool get isSet => name.isNotEmpty;
}

class LicenseOverview {
  const LicenseOverview({required this.type, required this.price});
  final LicenseTypeRow type;

  /// The price version in force today (null = no prices yet).
  final LicensePriceRow? price;

  /// Registration + planned practical lessons × lesson price + practical exam.
  Money? get expectedTotal => price == null
      ? null
      : Money(price!.registrationFee + price!.plannedPracticalLessons * price!.practicalLessonPrice + price!.practicalExamFee);
}

class SetupStep {
  const SetupStep({required this.key, required this.title, required this.note, required this.done, required this.required});
  final String key;
  final String title;
  final String note;
  final bool done;
  final bool required;
}

class SettingsQueries {
  SettingsQueries(this.db);
  final AppDatabase db;

  Future<Object?> raw(String key) async {
    final r = await (db.select(db.settings)..where((t) => t.key.equals(key))).getSingleOrNull();
    if (r == null) return settingDefaults[key];
    try {
      return jsonDecode(r.valueJson);
    } on FormatException {
      return settingDefaults[key];
    }
  }

  Future<int> intOf(String key) async {
    final v = await raw(key);
    return v is num ? v.toInt() : (settingDefaults[key] as int? ?? 0);
  }

  Future<bool> boolOf(String key) async {
    final v = await raw(key);
    return v is bool ? v : (settingDefaults[key] as bool? ?? false);
  }

  Future<SchoolInfo> school() async {
    final v = await raw('school');
    if (v is Map) return SchoolInfo(name: '${v['name'] ?? ''}', phone: v['phone'] as String?, address: v['address'] as String?);
    return const SchoolInfo(name: '');
  }

  /// School name shown in the app, receipts and PDFs.
  Future<String> schoolName() async {
    final s = await school();
    return s.isSet ? s.name : 'مدرسة القيادة';
  }

  Future<Map<String, Object?>> general() async => {for (final k in settingDefaults.keys) k: await raw(k)};

  Future<List<LicenseOverview>> licenses({bool includeStopped = true}) async {
    final types = await (db.select(db.licenseTypes)..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)])).get();
    final today = DateTime.now();
    final d = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final out = <LicenseOverview>[];
    for (final t in types) {
      if (!includeStopped && !t.active) continue;
      final price = await (db.select(db.licensePrices)
            ..where((p) => p.licenseTypeId.equals(t.id) & p.effectiveFrom.isSmallerOrEqualValue(d) & p.syncState.equals('rejected').not())
            ..orderBy([(p) => OrderingTerm.desc(p.effectiveFrom)])
            ..limit(1))
          .getSingleOrNull();
      out.add(LicenseOverview(type: t, price: price));
    }
    return out;
  }

  Future<List<AccountView>> accounts() async {
    final rows = await db.select(db.treasuryAccounts).get();
    final balances = {for (final a in await MoneyQueries(db).accounts()) a.id: a.balance};
    const order = {'cash': 0, 'wallet': 1, 'bank': 2};
    rows.sort((a, b) {
      final x = (a.active ? 0 : 1).compareTo(b.active ? 0 : 1);
      return x != 0 ? x : (order[a.kind] ?? 9).compareTo(order[b.kind] ?? 9);
    });
    return [for (final a in rows) AccountView(a, balances[a.id] ?? Money(a.openingBalance))];
  }

  /// First-run checklist (canvas Setup), computed from what exists.
  Future<List<SetupStep>> setup() async {
    final info = await school();
    final lic = await licenses(includeStopped: false);
    final accounts = await (db.select(db.treasuryAccounts)..where((t) => t.active.equals(true))).get();
    final cars = await (db.select(db.cars)..where((t) => t.active.equals(true))).get();
    final links = await (db.select(db.carInstructors)..where((t) => t.to.isNull())).get();
    final employees = await (db.select(db.employees)..where((t) => t.active.equals(true))).get();
    final carsReady = cars.isNotEmpty && cars.every((c) => links.any((l) => l.carId == c.id));
    return [
      SetupStep(key: 'school', title: 'اسم المدرسة', note: 'بيظهر بالتطبيق والوصولات والتقارير', done: info.isSet, required: true),
      SetupStep(key: 'licenses', title: 'أنواع الرخص والأسعار', note: 'رسوم التسجيل، سعر الدرس العملي، رسوم الاختبارات', done: lic.isNotEmpty && lic.every((l) => l.price != null), required: true),
      SetupStep(key: 'accounts', title: 'الصناديق', note: 'كاش، محافظ، بنوك · ورصيد البداية', done: accounts.isNotEmpty, required: true),
      SetupStep(key: 'cars', title: 'السيارات والمدربين', note: cars.isEmpty ? 'كل سيارة ومين بيسوقها' : carsReady ? '${cars.length} سيارات · كلها عليها مدرب' : 'في سيارة بدون مدرب', done: carsReady, required: true),
      SetupStep(key: 'staff', title: 'الموظفين والرواتب', note: 'اختياري هلأ · بينضاف بعدين', done: employees.any((e) => e.role == 'staff'), required: false),
    ];
  }
}
