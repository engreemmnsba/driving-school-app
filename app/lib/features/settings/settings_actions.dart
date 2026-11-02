import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/domain/money.dart';
import '../../core/sync/outbox.dart';
import '../../data/settings_queries.dart';
import '../students/student_actions.dart' show ActionError;

/// The editable fields of one license (canvas LicenseSettings). Money in agorot.
class LicenseForm {
  LicenseForm({
    required this.name,
    required this.registrationFee,
    required this.practicalLessonPrice,
    required this.theoryRetakeFee,
    required this.practicalExamFee,
    this.plannedTheory = 8,
    this.minTheory = 8,
    this.plannedPractical = 10,
    this.minPractical = 10,
    this.practicalAfterTheory = true,
  });

  factory LicenseForm.empty() => LicenseForm(name: '', registrationFee: 0, practicalLessonPrice: 0, theoryRetakeFee: 0, practicalExamFee: 0);

  factory LicenseForm.of(LicenseTypeRow t, LicensePriceRow? p) => LicenseForm(
        name: t.name,
        registrationFee: p?.registrationFee ?? 0,
        practicalLessonPrice: p?.practicalLessonPrice ?? 0,
        theoryRetakeFee: p?.theoryRetakeFee ?? 0,
        practicalExamFee: p?.practicalExamFee ?? 0,
        plannedTheory: p?.plannedTheoryLessons ?? 8,
        minTheory: p?.minTheoryBeforeExam ?? 8,
        plannedPractical: p?.plannedPracticalLessons ?? 10,
        minPractical: p?.minPracticalBeforeExam ?? 10,
        practicalAfterTheory: p?.practicalAfterTheory ?? true,
      );

  String name;
  int registrationFee;
  int practicalLessonPrice;
  int theoryRetakeFee;
  int practicalExamFee;
  int plannedTheory;
  int minTheory;
  int plannedPractical;
  int minPractical;
  bool practicalAfterTheory;

  String? get nameError => name.trim().length < 2 ? 'اسم الرخصة مطلوب' : null;
  String? get registrationError => registrationFee <= 0 ? 'رسوم التسجيل مطلوبة' : null;
  String? get theoryError => minTheory > plannedTheory ? 'الحد الأدنى أكبر من عدد الدروس' : theoryRetakeFee <= 0 ? 'رسوم إعادة النظري مطلوبة' : null;
  String? get practicalError => practicalLessonPrice <= 0
      ? 'سعر الدرس العملي مطلوب'
      : minPractical > plannedPractical
          ? 'الحد الأدنى أكبر من عدد الدروس'
          : practicalExamFee <= 0
              ? 'رسوم الاختبار العملي مطلوبة'
              : null;
  bool get valid => nameError == null && registrationError == null && theoryError == null && practicalError == null;

  Money get expectedTotal => Money(registrationFee + plannedPractical * practicalLessonPrice + practicalExamFee);

  bool samePricesAs(LicensePriceRow? p) =>
      p != null &&
      p.registrationFee == registrationFee &&
      p.practicalLessonPrice == practicalLessonPrice &&
      p.theoryRetakeFee == theoryRetakeFee &&
      p.practicalExamFee == practicalExamFee &&
      p.plannedTheoryLessons == plannedTheory &&
      p.minTheoryBeforeExam == minTheory &&
      p.plannedPracticalLessons == plannedPractical &&
      p.minPracticalBeforeExam == minPractical &&
      p.practicalAfterTheory == practicalAfterTheory;
}

class SettingsActions {
  SettingsActions(this.db, this.outbox) : queries = SettingsQueries(db);
  final AppDatabase db;
  final Outbox outbox;
  final SettingsQueries queries;

  Future<void> setSetting(String key, Object value) async {
    await db.transaction(() async {
      await db.into(db.settings).insertOnConflictUpdate(SettingsCompanion.insert(key: key, valueJson: jsonEncode(value)));
      await outbox.enqueue('setting.set', {'key': key, 'value': value});
    });
  }

  /// Saves a license: a new type (+ its first prices), a rename, and/or a new price version from [effectiveFrom].
  /// Charges already recorded keep their price.
  Future<void> saveLicense({LicenseTypeRow? type, LicensePriceRow? current, required LicenseForm f, required String effectiveFrom}) async {
    if (!f.valid) throw const ActionError('في حقول ناقصة أو غلط بالأحمر');
    final name = f.name.trim();
    final others = await (db.select(db.licenseTypes)..where((t) => t.name.equals(name))).get();
    if (others.any((o) => o.id != type?.id)) throw const ActionError('في رخصة بنفس الاسم');
    await db.transaction(() async {
      var typeId = type?.id;
      if (typeId == null) {
        typeId = newId();
        final count = (await db.select(db.licenseTypes).get()).length;
        await db.into(db.licenseTypes).insert(LicenseTypesCompanion.insert(id: typeId, name: name, sortOrder: Value(count + 1)));
        await outbox.enqueue('licenseType.add', {'licenseTypeId': typeId, 'name': name, 'sortOrder': count + 1});
      } else if (name != type!.name) {
        await (db.update(db.licenseTypes)..where((t) => t.id.equals(typeId!))).write(LicenseTypesCompanion(name: Value(name)));
        await outbox.enqueue('licenseType.edit', {'licenseTypeId': typeId, 'name': name});
      }
      if (!f.samePricesAs(current)) {
        final priceId = newId();
        final opId = newId();
        await db.into(db.licensePrices).insert(LicensePricesCompanion.insert(
              id: priceId,
              licenseTypeId: typeId,
              effectiveFrom: effectiveFrom,
              registrationFee: f.registrationFee,
              practicalLessonPrice: f.practicalLessonPrice,
              theoryRetakeFee: f.theoryRetakeFee,
              practicalExamFee: f.practicalExamFee,
              plannedTheoryLessons: Value(f.plannedTheory),
              plannedPracticalLessons: Value(f.plannedPractical),
              minTheoryBeforeExam: Value(f.minTheory),
              minPracticalBeforeExam: Value(f.minPractical),
              practicalAfterTheory: Value(f.practicalAfterTheory),
              opId: Value(opId),
            ));
        await outbox.enqueue('licensePrice.set', {
          'priceId': priceId,
          'licenseTypeId': typeId,
          'effectiveFrom': effectiveFrom,
          'registrationFee': f.registrationFee,
          'practicalLessonPrice': f.practicalLessonPrice,
          'theoryRetakeFee': f.theoryRetakeFee,
          'practicalExamFee': f.practicalExamFee,
          'plannedTheoryLessons': f.plannedTheory,
          'plannedPracticalLessons': f.plannedPractical,
          'minTheoryBeforeExam': f.minTheory,
          'minPracticalBeforeExam': f.minPractical,
          'practicalAfterTheory': f.practicalAfterTheory,
        }, opId: opId);
      }
    });
  }

  Future<void> setLicenseActive(LicenseTypeRow type, bool active) => db.transaction(() async {
        await (db.update(db.licenseTypes)..where((t) => t.id.equals(type.id))).write(LicenseTypesCompanion(active: Value(active)));
        await outbox.enqueue('licenseType.edit', {'licenseTypeId': type.id, 'active': active});
      });

  Future<void> addAccount({required String name, required String kind, required Money opening}) async {
    final n = name.trim();
    if (n.isEmpty) throw const ActionError('اسم الصندوق مطلوب');
    final same = await (db.select(db.treasuryAccounts)..where((t) => t.name.equals(n) & t.active.equals(true))).get();
    if (same.isNotEmpty) throw const ActionError('في صندوق بنفس الاسم');
    final id = newId();
    await db.transaction(() async {
      await db.into(db.treasuryAccounts).insert(TreasuryAccountsCompanion.insert(id: id, name: n, kind: kind, openingBalance: Value(opening.agorot)));
      await outbox.enqueue('account.add', {'accountId': id, 'name': n, 'kind': kind, 'openingBalance': opening.agorot});
    });
  }

  Future<void> editAccount(TreasuryAccountRow a, {String? name, bool? active, Money? balance}) async {
    if (active == false && balance != null && !balance.isZero) {
      throw ActionError('بالصندوق ${balance.format()} · لازم يتحوّلوا لصندوق ثاني قبل الإيقاف');
    }
    await db.transaction(() async {
      await (db.update(db.treasuryAccounts)..where((t) => t.id.equals(a.id)))
          .write(TreasuryAccountsCompanion(name: name == null ? const Value.absent() : Value(name.trim()), active: active == null ? const Value.absent() : Value(active)));
      await outbox.enqueue('account.edit', {'accountId': a.id, if (name != null) 'name': name.trim(), 'active': ?active});
    });
  }
}
