import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/domain/money.dart';
import '../../core/domain/permissions.dart';
import '../../core/sync/outbox.dart';
import '../../data/staff_queries.dart';
import '../students/student_actions.dart' show ActionError, tempPassword;

String _now() => DateTime.now().toUtc().toIso8601String();

/// Advance / deduction / bonus on a payroll month. An advance also leaves the account now.
/// Payload = functions payrollItem.
class AddPayrollItem {
  AddPayrollItem(this.db, this.outbox, this.userName);
  final AppDatabase db;
  final Outbox outbox;
  final String userName;

  Future<String> call({
    required EmployeeRow employee,
    required String kind,
    required Money amount,
    required String payrollMonth,
    required String businessDate,
    String? reason,
    String? note,
    String? accountId,
  }) async {
    if (!amount.isPositive) throw const ActionError('المبلغ لازم يكون أكبر من صفر');
    if (kind == 'advance' && accountId == null) throw const ActionError('من أي صندوق؟');
    final paid = await (db.select(db.salaryPayments)
          ..where((t) => t.employeeId.equals(employee.id) & t.payrollMonth.equals(payrollMonth) & t.syncState.equals('rejected').not()))
        .getSingleOrNull();
    if (paid != null) throw const ActionError('راتب هالشهر انصرف · الحركة بتنحط على الشهر الجاي');
    final itemId = newId();
    final movementId = newId();
    final opId = newId();
    final at = _now();
    final label = switch (kind) { 'advance' => 'سلفة', 'deduction' => 'خصم', _ => 'مكافأة' };
    await db.transaction(() async {
      await db.into(db.payrollItems).insert(PayrollItemsCompanion.insert(
            id: itemId,
            employeeId: employee.id,
            employeeName: employee.name,
            payrollMonth: payrollMonth,
            kind: kind,
            reason: reason ?? label,
            note: Value(note),
            amount: amount.agorot,
            accountId: Value(kind == 'advance' ? accountId : null),
            businessDate: businessDate,
            recordedByName: Value(userName),
            opId: Value(opId),
            at: Value(at),
          ));
      if (kind == 'advance') {
        await db.into(db.treasuryMovements).insert(TreasuryMovementsCompanion.insert(
              id: movementId,
              accountId: accountId!,
              direction: 'out',
              amount: amount.agorot,
              kind: 'advance',
              refId: itemId,
              businessDate: businessDate,
              note: Value('سلفة ${employee.name}'),
              opId: Value(opId),
              at: Value(at),
            ));
      }
      await outbox.enqueue('payroll.item', {
        'itemId': itemId,
        'movementId': movementId,
        'employeeId': employee.id,
        'payrollMonth': payrollMonth,
        'kind': kind,
        'amount': amount.agorot,
        'reason': ?reason,
        'note': ?note,
        if (kind == 'advance') 'accountId': accountId,
        'businessDate': businessDate,
      }, opId: opId);
    });
    return itemId;
  }
}

/// Pays one employee's month from an account (net = salary + bonuses − deductions − advances).
class PaySalary {
  PaySalary(this.db, this.outbox, this.userName);
  final AppDatabase db;
  final Outbox outbox;
  final String userName;

  Future<Money> call({required PayrollLine line, required String payrollMonth, required String accountId, required String businessDate}) async {
    if (line.paid) throw const ActionError('راتب هالشهر انصرف من قبل');
    final net = line.net;
    if (net.isNegative) throw ActionError('السلف والخصومات أكثر من الراتب بـ ${net.abs().format()}');
    if (payrollMonth.compareTo(monthOf(businessDate)) > 0) throw const ActionError('ما بيصير صرف راتب شهر لسا ما إجا');
    final paymentId = newId();
    final movementId = newId();
    final opId = newId();
    final at = _now();
    final e = line.employee;
    await db.transaction(() async {
      await db.into(db.salaryPayments).insert(SalaryPaymentsCompanion.insert(
            id: paymentId,
            employeeId: e.id,
            employeeName: e.name,
            payrollMonth: payrollMonth,
            salaryAtMonth: line.salary.agorot,
            bonuses: line.bonuses.agorot,
            deductions: line.deductions.agorot,
            advances: line.advances.agorot,
            net: net.agorot,
            accountId: accountId,
            businessDate: businessDate,
            early: Value(businessDate.compareTo(lastDayOfMonth(payrollMonth)) < 0),
            paidByName: Value(userName),
            opId: Value(opId),
            at: Value(at),
          ));
      if (net.isPositive) {
        await db.into(db.treasuryMovements).insert(TreasuryMovementsCompanion.insert(
              id: movementId,
              accountId: accountId,
              direction: 'out',
              amount: net.agorot,
              kind: 'salary',
              refId: paymentId,
              businessDate: businessDate,
              note: Value('راتب ${e.name} $payrollMonth'),
              opId: Value(opId),
              at: Value(at),
            ));
      }
      await outbox.enqueue('salary.pay', {
        'paymentId': paymentId,
        'movementId': movementId,
        'employeeId': e.id,
        'payrollMonth': payrollMonth,
        'accountId': accountId,
        'businessDate': businessDate,
      }, opId: opId);
    });
    return net;
  }
}

/// Cars are catalog rows (no sync columns): written locally right away, confirmed by the next pull.
class AddCar {
  AddCar(this.db, this.outbox);
  final AppDatabase db;
  final Outbox outbox;

  Future<String> call({required String name, String? plate, required String gearbox}) async {
    final n = name.trim();
    if (n.isEmpty) throw const ActionError('اسم السيارة مطلوب');
    final same = await (db.select(db.cars)..where((t) => t.name.equals(n) & t.active.equals(true))).get();
    if (same.isNotEmpty) throw const ActionError('في سيارة بنفس الاسم');
    final carId = newId();
    await db.transaction(() async {
      await db.into(db.cars).insert(CarsCompanion.insert(id: carId, name: n, plate: Value(plate?.trim().isEmpty ?? true ? null : plate!.trim()), gearbox: Value(gearbox)));
      await outbox.enqueue('car.add', {'carId': carId, 'name': n, 'plate': ?(plate?.trim().isEmpty ?? true ? null : plate!.trim()), 'gearbox': gearbox});
    });
    return carId;
  }
}

/// Rename / plate / gearbox, or stop the car (only when no active student is on it).
class EditCar {
  EditCar(this.db, this.outbox);
  final AppDatabase db;
  final Outbox outbox;

  Future<void> call({required CarRow car, String? name, String? plate, String? gearbox, bool? active}) async {
    final n = name?.trim();
    if (n != null && n.isEmpty) throw const ActionError('اسم السيارة مطلوب');
    if (n != null && n != car.name) {
      final same = await (db.select(db.cars)..where((t) => t.name.equals(n) & t.active.equals(true) & t.id.equals(car.id).not())).get();
      if (same.isNotEmpty) throw const ActionError('في سيارة بنفس الاسم');
    }
    final p = plate?.trim();
    await db.transaction(() async {
      await (db.update(db.cars)..where((t) => t.id.equals(car.id))).write(CarsCompanion(
            name: n == null ? const Value.absent() : Value(n),
            plate: plate == null ? const Value.absent() : Value(p!.isEmpty ? null : p),
            gearbox: gearbox == null ? const Value.absent() : Value(gearbox),
            active: active == null ? const Value.absent() : Value(active),
          ));
      await outbox.enqueue('car.edit', {'carId': car.id, 'name': ?n, if (plate != null) 'plate': p!.isEmpty ? null : p, 'gearbox': ?gearbox, 'active': ?active});
    });
  }
}

/// On = the instructor drives this car from today; off = the link ends today (history kept).
class ToggleCarInstructor {
  ToggleCarInstructor(this.db, this.outbox);
  final AppDatabase db;
  final Outbox outbox;

  Future<void> call({required String carId, required String employeeId, required bool on, required String today}) async {
    final open = await (db.select(db.carInstructors)..where((t) => t.carId.equals(carId) & t.employeeId.equals(employeeId) & t.to.isNull())).get();
    final linkId = newId();
    await db.transaction(() async {
      if (on) {
        if (open.isNotEmpty) return;
        await db.into(db.carInstructors).insert(CarInstructorsCompanion.insert(id: linkId, carId: carId, employeeId: employeeId, from: Value(today)));
      } else {
        if (open.isEmpty) return;
        for (final l in open) {
          await (db.update(db.carInstructors)..where((t) => t.id.equals(l.id))).write(CarInstructorsCompanion(to: Value(today)));
        }
      }
      await outbox.enqueue('car.instructor', {'carId': carId, 'employeeId': employeeId, 'on': on, if (on) 'linkId': linkId});
    });
  }
}

class CreatedUser {
  const CreatedUser({required this.userId, required this.password});
  final String userId;
  final String password;
}

/// New login (+ employee file for staff and instructors). The password only goes to the server and WhatsApp.
class CreateUser {
  CreateUser(this.db, this.outbox);
  final AppDatabase db;
  final Outbox outbox;

  Future<CreatedUser> call({
    required String name,
    required String nationalId,
    String? phone,
    required String role,
    String? job,
    List<String> carIds = const [],
    Money salary = const Money.zero(),
    required String businessDate,
  }) async {
    final n = name.trim();
    final nid = nationalId.trim();
    if (n.length < 2) throw const ActionError('الاسم مطلوب');
    if (!RegExp(r'^\d{9}$').hasMatch(nid)) throw const ActionError('رقم الهوية لازم يكون 9 أرقام');
    if (await StaffQueries(db).nationalIdTaken(nid)) throw const ActionError('رقم الهوية إله حساب من قبل');
    final userId = newId();
    final employeeId = newId();
    final opId = newId();
    final password = tempPassword();
    final at = _now();
    final effectiveJob = role == 'instructor' ? 'instructor' : role == 'admin' ? 'manager' : (job ?? 'secretary');
    final tasks = role == 'admin' ? <String, bool>{} : {for (final e in jobTasks(effectiveJob).entries) if (e.value) e.key: true};
    final cash = [for (final a in await (db.select(db.treasuryAccounts)..where((t) => t.kind.equals('cash') & t.active.equals(true))).get()) a.id]..sort();
    final perms = role == 'admin'
        ? {'tasks': <String, bool>{}}
        : {
            'tasks': tasks,
            'allowedAccounts': effectiveJob == 'manager' ? 'all' : cash,
            'expenseCategories': effectiveJob == 'manager' ? 'all' : ['cars', 'ministry', 'other'],
            'discountMax': effectiveJob == 'manager' ? null : 0,
            'closeMode': effectiveJob == 'manager' ? 'full' : 'blind',
            'logScope': effectiveJob == 'manager' ? 'all' : 'own',
            'backdateDays': effectiveJob == 'accountant' ? 2 : 0, // A5: accountant up to 2 days back
          };
    final cleanPhone = phone?.trim().isEmpty ?? true ? null : phone!.trim();
    await db.transaction(() async {
      await db.into(db.appUsers).insert(AppUsersCompanion.insert(
            id: userId,
            name: n,
            nationalId: nid,
            phone: Value(cleanPhone),
            kind: role,
            job: Value(effectiveJob),
            employeeId: Value(role == 'admin' ? null : employeeId),
            permissionsJson: Value(jsonEncode(perms)),
            opId: Value(opId),
            at: Value(at),
          ));
      if (role != 'admin') {
        await db.into(db.employees).insertOnConflictUpdate(EmployeesCompanion.insert(
              id: employeeId,
              name: n,
              role: role,
              phone: Value(cleanPhone),
              userId: Value(userId),
              salary: Value(salary.agorot),
            ));
        if (salary.isPositive) {
          final m = monthOf(businessDate);
          await db.into(db.salaryRates).insertOnConflictUpdate(
              SalaryRatesCompanion.insert(id: '${employeeId}_$m', employeeId: employeeId, effectiveFrom: m, monthlyAmount: salary.agorot));
        }
        if (role == 'instructor') {
          for (final c in carIds) {
            await db.into(db.carInstructors).insertOnConflictUpdate(
                CarInstructorsCompanion.insert(id: '${c}_${employeeId}_$businessDate', carId: c, employeeId: employeeId, from: Value(businessDate)));
          }
        }
      }
      await outbox.enqueue('user.create', {
        'userId': userId,
        if (role != 'admin') 'employeeId': employeeId,
        'name': n,
        'nationalId': nid,
        'phone': ?cleanPhone,
        'role': role,
        if (role == 'staff') 'job': effectiveJob,
        if (role == 'instructor') 'carIds': carIds,
        if (role != 'admin' && salary.isPositive) 'salary': salary.agorot,
        'tempPassword': password,
        'businessDate': businessDate,
      }, opId: opId);
    });
    return CreatedUser(userId: userId, password: password);
  }
}

class SetUserStatus {
  SetUserStatus(this.db, this.outbox);
  final AppDatabase db;
  final Outbox outbox;

  Future<void> call({required AppUserRow user, required bool active, String? reason}) async {
    if (!active && user.kind == 'admin') {
      final admins = await (db.select(db.appUsers)..where((t) => t.kind.equals('admin') & t.status.equals('active'))).get();
      if (admins.length <= 1) throw const ActionError('ما بينفع إيقاف آخر مدير');
    }
    final opId = newId();
    await db.transaction(() async {
      await (db.update(db.appUsers)..where((t) => t.id.equals(user.id)))
          .write(AppUsersCompanion(status: Value(active ? 'active' : 'disabled'), opId: Value(opId), syncState: const Value('pending')));
      if (user.employeeId != null) {
        await (db.update(db.employees)..where((t) => t.id.equals(user.employeeId!))).write(EmployeesCompanion(active: Value(active)));
      }
      await outbox.enqueue('user.status', {'userId': user.id, 'active': active, 'reason': ?reason}, opId: opId);
    });
  }
}

/// Admin-side password reset (A11): a new temporary password, shown once / sent on WhatsApp.
/// The server sets it and signs the person out everywhere. Returns the password.
class ResetPassword {
  ResetPassword(this.outbox);
  final Outbox outbox;

  Future<String> call({required String userId}) async {
    final password = tempPassword();
    await outbox.enqueue('user.resetPassword', {'userId': userId, 'password': password});
    return password;
  }
}

/// Options shown under a task when it's checked (canvas Permissions).
class PermissionOptions {
  const PermissionOptions({
    this.allowedAccounts,
    this.expenseCategories,
    this.discountMax = 0,
    this.closeMode = 'blind',
    this.logScope = 'own',
    this.backdateDays = 0,
  });

  /// null = all accounts.
  final List<String>? allowedAccounts;

  /// null = all categories.
  final List<String>? expenseCategories;

  /// agorot; null = no limit.
  final int? discountMax;
  final String closeMode;
  final String logScope;
  final int backdateDays;

  factory PermissionOptions.fromJson(Map<String, dynamic> j) {
    List<String>? list(Object? v) => v == 'all' || v == null ? null : [for (final x in v as List) '$x'];
    return PermissionOptions(
      allowedAccounts: list(j['allowedAccounts']),
      expenseCategories: list(j['expenseCategories']),
      discountMax: j.containsKey('discountMax') ? (j['discountMax'] as num?)?.toInt() : 0,
      closeMode: j['closeMode'] == 'full' ? 'full' : 'blind',
      logScope: j['logScope'] == 'all' ? 'all' : 'own',
      backdateDays: j['backdateDays'] is num ? (j['backdateDays'] as num).toInt() : 0,
    );
  }

  PermissionOptions copyWith({List<String>? Function()? allowedAccounts, List<String>? Function()? expenseCategories, int? Function()? discountMax, String? closeMode, String? logScope, int? backdateDays}) =>
      PermissionOptions(
        allowedAccounts: allowedAccounts == null ? this.allowedAccounts : allowedAccounts(),
        expenseCategories: expenseCategories == null ? this.expenseCategories : expenseCategories(),
        discountMax: discountMax == null ? this.discountMax : discountMax(),
        closeMode: closeMode ?? this.closeMode,
        logScope: logScope ?? this.logScope,
        backdateDays: backdateDays ?? this.backdateDays,
      );

  Map<String, dynamic> toJson(Map<String, bool> tasks) => {
        'tasks': {for (final e in tasks.entries) if (e.value) e.key: true},
        'allowedAccounts': allowedAccounts ?? 'all',
        'expenseCategories': expenseCategories ?? 'all',
        'discountMax': discountMax,
        'closeMode': closeMode,
        'logScope': logScope,
        'backdateDays': backdateDays,
      };
}

class SavePermissions {
  SavePermissions(this.db, this.outbox);
  final AppDatabase db;
  final Outbox outbox;

  Future<void> call({required AppUserRow user, required String? job, required Map<String, bool> tasks, required PermissionOptions options}) async {
    if (user.kind == 'admin') throw const ActionError('المدير عنده كل الصلاحيات');
    final perms = options.toJson(withDependencies(tasks));
    final opId = newId();
    await db.transaction(() async {
      await (db.update(db.appUsers)..where((t) => t.id.equals(user.id))).write(AppUsersCompanion(
            permissionsJson: Value(jsonEncode(perms)),
            job: Value(job),
            permVersion: Value(user.permVersion + 1),
            opId: Value(opId),
            syncState: const Value('pending'),
          ));
      await outbox.enqueue('user.permissions', {'userId': user.id, 'job': ?job, 'permissions': perms}, opId: opId);
    });
  }
}

/// Every staff action, built once per signed-in user.
class StaffActions {
  StaffActions(AppDatabase db, Outbox outbox, String userName)
      : queries = StaffQueries(db),
        addItem = AddPayrollItem(db, outbox, userName),
        paySalary = PaySalary(db, outbox, userName),
        addCar = AddCar(db, outbox),
        editCar = EditCar(db, outbox),
        toggleInstructor = ToggleCarInstructor(db, outbox),
        createUser = CreateUser(db, outbox),
        setStatus = SetUserStatus(db, outbox),
        resetPassword = ResetPassword(outbox),
        savePermissions = SavePermissions(db, outbox);

  final StaffQueries queries;
  final AddPayrollItem addItem;
  final PaySalary paySalary;
  final AddCar addCar;
  final EditCar editCar;
  final ToggleCarInstructor toggleInstructor;
  final CreateUser createUser;
  final SetUserStatus setStatus;
  final ResetPassword resetPassword;
  final SavePermissions savePermissions;
}
