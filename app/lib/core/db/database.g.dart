// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $StudentsTable extends Students
    with TableInfo<$StudentsTable, StudentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nationalIdMeta = const VerificationMeta(
    'nationalId',
  );
  @override
  late final GeneratedColumn<String> nationalId = GeneratedColumn<String>(
    'national_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    syncState,
    serverSeq,
    at,
    id,
    name,
    nationalId,
    phone,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('national_id')) {
      context.handle(
        _nationalIdMeta,
        nationalId.isAcceptableOrUnknown(data['national_id']!, _nationalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nationalIdMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nationalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}national_id'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class StudentRow extends DataClass implements Insertable<StudentRow> {
  /// The op that created/changed this row (links local rows to outbox results).
  final String? opId;

  /// pending | synced | rejected
  final String syncState;
  final int? serverSeq;

  /// When it happened (ISO-8601): device time while pending, server time once synced.
  final String? at;
  final String id;
  final String name;
  final String nationalId;
  final String? phone;
  final bool archived;
  const StudentRow({
    this.opId,
    required this.syncState,
    this.serverSeq,
    this.at,
    required this.id,
    required this.name,
    required this.nationalId,
    this.phone,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || opId != null) {
      map['op_id'] = Variable<String>(opId);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    if (!nullToAbsent || at != null) {
      map['at'] = Variable<String>(at);
    }
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['national_id'] = Variable<String>(nationalId);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      opId: opId == null && nullToAbsent ? const Value.absent() : Value(opId),
      syncState: Value(syncState),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      at: at == null && nullToAbsent ? const Value.absent() : Value(at),
      id: Value(id),
      name: Value(name),
      nationalId: Value(nationalId),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      archived: Value(archived),
    );
  }

  factory StudentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudentRow(
      opId: serializer.fromJson<String?>(json['opId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      at: serializer.fromJson<String?>(json['at']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nationalId: serializer.fromJson<String>(json['nationalId']),
      phone: serializer.fromJson<String?>(json['phone']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String?>(opId),
      'syncState': serializer.toJson<String>(syncState),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'at': serializer.toJson<String?>(at),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'nationalId': serializer.toJson<String>(nationalId),
      'phone': serializer.toJson<String?>(phone),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  StudentRow copyWith({
    Value<String?> opId = const Value.absent(),
    String? syncState,
    Value<int?> serverSeq = const Value.absent(),
    Value<String?> at = const Value.absent(),
    String? id,
    String? name,
    String? nationalId,
    Value<String?> phone = const Value.absent(),
    bool? archived,
  }) => StudentRow(
    opId: opId.present ? opId.value : this.opId,
    syncState: syncState ?? this.syncState,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    at: at.present ? at.value : this.at,
    id: id ?? this.id,
    name: name ?? this.name,
    nationalId: nationalId ?? this.nationalId,
    phone: phone.present ? phone.value : this.phone,
    archived: archived ?? this.archived,
  );
  StudentRow copyWithCompanion(StudentsCompanion data) {
    return StudentRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      at: data.at.present ? data.at.value : this.at,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nationalId: data.nationalId.present
          ? data.nationalId.value
          : this.nationalId,
      phone: data.phone.present ? data.phone.value : this.phone,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudentRow(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nationalId: $nationalId, ')
          ..write('phone: $phone, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    syncState,
    serverSeq,
    at,
    id,
    name,
    nationalId,
    phone,
    archived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudentRow &&
          other.opId == this.opId &&
          other.syncState == this.syncState &&
          other.serverSeq == this.serverSeq &&
          other.at == this.at &&
          other.id == this.id &&
          other.name == this.name &&
          other.nationalId == this.nationalId &&
          other.phone == this.phone &&
          other.archived == this.archived);
}

class StudentsCompanion extends UpdateCompanion<StudentRow> {
  final Value<String?> opId;
  final Value<String> syncState;
  final Value<int?> serverSeq;
  final Value<String?> at;
  final Value<String> id;
  final Value<String> name;
  final Value<String> nationalId;
  final Value<String?> phone;
  final Value<bool> archived;
  final Value<int> rowid;
  const StudentsCompanion({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.phone = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentsCompanion.insert({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    required String id,
    required String name,
    required String nationalId,
    this.phone = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       nationalId = Value(nationalId);
  static Insertable<StudentRow> custom({
    Expression<String>? opId,
    Expression<String>? syncState,
    Expression<int>? serverSeq,
    Expression<String>? at,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? nationalId,
    Expression<String>? phone,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (syncState != null) 'sync_state': syncState,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (at != null) 'at': at,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nationalId != null) 'national_id': nationalId,
      if (phone != null) 'phone': phone,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentsCompanion copyWith({
    Value<String?>? opId,
    Value<String>? syncState,
    Value<int?>? serverSeq,
    Value<String?>? at,
    Value<String>? id,
    Value<String>? name,
    Value<String>? nationalId,
    Value<String?>? phone,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return StudentsCompanion(
      opId: opId ?? this.opId,
      syncState: syncState ?? this.syncState,
      serverSeq: serverSeq ?? this.serverSeq,
      at: at ?? this.at,
      id: id ?? this.id,
      name: name ?? this.name,
      nationalId: nationalId ?? this.nationalId,
      phone: phone ?? this.phone,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nationalId.present) {
      map['national_id'] = Variable<String>(nationalId.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nationalId: $nationalId, ')
          ..write('phone: $phone, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnrollmentsTable extends Enrollments
    with TableInfo<$EnrollmentsTable, EnrollmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnrollmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentNameMeta = const VerificationMeta(
    'studentName',
  );
  @override
  late final GeneratedColumn<String> studentName = GeneratedColumn<String>(
    'student_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _licenseTypeIdMeta = const VerificationMeta(
    'licenseTypeId',
  );
  @override
  late final GeneratedColumn<String> licenseTypeId = GeneratedColumn<String>(
    'license_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carIdMeta = const VerificationMeta('carId');
  @override
  late final GeneratedColumn<String> carId = GeneratedColumn<String>(
    'car_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('theory'),
  );
  static const VerificationMeta _registeredOnMeta = const VerificationMeta(
    'registeredOn',
  );
  @override
  late final GeneratedColumn<String> registeredOn = GeneratedColumn<String>(
    'registered_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _graduatedOnMeta = const VerificationMeta(
    'graduatedOn',
  );
  @override
  late final GeneratedColumn<String> graduatedOn = GeneratedColumn<String>(
    'graduated_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _withdrawReasonMeta = const VerificationMeta(
    'withdrawReason',
  );
  @override
  late final GeneratedColumn<String> withdrawReason = GeneratedColumn<String>(
    'withdraw_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finalSummaryJsonMeta = const VerificationMeta(
    'finalSummaryJson',
  );
  @override
  late final GeneratedColumn<String> finalSummaryJson = GeneratedColumn<String>(
    'final_summary_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedTheoryMeta = const VerificationMeta(
    'plannedTheory',
  );
  @override
  late final GeneratedColumn<int> plannedTheory = GeneratedColumn<int>(
    'planned_theory',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedPracticalMeta = const VerificationMeta(
    'plannedPractical',
  );
  @override
  late final GeneratedColumn<int> plannedPractical = GeneratedColumn<int>(
    'planned_practical',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    syncState,
    serverSeq,
    at,
    id,
    studentId,
    studentName,
    licenseTypeId,
    carId,
    stage,
    registeredOn,
    archived,
    graduatedOn,
    withdrawReason,
    finalSummaryJson,
    plannedTheory,
    plannedPractical,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'enrollments';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnrollmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('student_name')) {
      context.handle(
        _studentNameMeta,
        studentName.isAcceptableOrUnknown(
          data['student_name']!,
          _studentNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_studentNameMeta);
    }
    if (data.containsKey('license_type_id')) {
      context.handle(
        _licenseTypeIdMeta,
        licenseTypeId.isAcceptableOrUnknown(
          data['license_type_id']!,
          _licenseTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_licenseTypeIdMeta);
    }
    if (data.containsKey('car_id')) {
      context.handle(
        _carIdMeta,
        carId.isAcceptableOrUnknown(data['car_id']!, _carIdMeta),
      );
    } else if (isInserting) {
      context.missing(_carIdMeta);
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    }
    if (data.containsKey('registered_on')) {
      context.handle(
        _registeredOnMeta,
        registeredOn.isAcceptableOrUnknown(
          data['registered_on']!,
          _registeredOnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registeredOnMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('graduated_on')) {
      context.handle(
        _graduatedOnMeta,
        graduatedOn.isAcceptableOrUnknown(
          data['graduated_on']!,
          _graduatedOnMeta,
        ),
      );
    }
    if (data.containsKey('withdraw_reason')) {
      context.handle(
        _withdrawReasonMeta,
        withdrawReason.isAcceptableOrUnknown(
          data['withdraw_reason']!,
          _withdrawReasonMeta,
        ),
      );
    }
    if (data.containsKey('final_summary_json')) {
      context.handle(
        _finalSummaryJsonMeta,
        finalSummaryJson.isAcceptableOrUnknown(
          data['final_summary_json']!,
          _finalSummaryJsonMeta,
        ),
      );
    }
    if (data.containsKey('planned_theory')) {
      context.handle(
        _plannedTheoryMeta,
        plannedTheory.isAcceptableOrUnknown(
          data['planned_theory']!,
          _plannedTheoryMeta,
        ),
      );
    }
    if (data.containsKey('planned_practical')) {
      context.handle(
        _plannedPracticalMeta,
        plannedPractical.isAcceptableOrUnknown(
          data['planned_practical']!,
          _plannedPracticalMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnrollmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnrollmentRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      studentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_name'],
      )!,
      licenseTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_type_id'],
      )!,
      carId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}car_id'],
      )!,
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      )!,
      registeredOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registered_on'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      graduatedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}graduated_on'],
      ),
      withdrawReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}withdraw_reason'],
      ),
      finalSummaryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}final_summary_json'],
      ),
      plannedTheory: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_theory'],
      ),
      plannedPractical: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_practical'],
      ),
    );
  }

  @override
  $EnrollmentsTable createAlias(String alias) {
    return $EnrollmentsTable(attachedDatabase, alias);
  }
}

class EnrollmentRow extends DataClass implements Insertable<EnrollmentRow> {
  /// The op that created/changed this row (links local rows to outbox results).
  final String? opId;

  /// pending | synced | rejected
  final String syncState;
  final int? serverSeq;

  /// When it happened (ISO-8601): device time while pending, server time once synced.
  final String? at;
  final String id;
  final String studentId;

  /// Denormalized so instructors never need the student doc (national ID, phone).
  final String studentName;
  final String licenseTypeId;
  final String carId;

  /// theory | practical | ready_practical (legacy) | passed (practical passed, not graduated yet) | graduated | withdrawn
  final String stage;
  final String registeredOn;
  final bool archived;
  final String? graduatedOn;
  final String? withdrawReason;

  /// JSON {charged, paid, discounts, theoryLessons, practicalLessons} written at graduation.
  final String? finalSummaryJson;

  /// Planned lesson counts copied from the price at registration (instructors can't read prices).
  final int? plannedTheory;
  final int? plannedPractical;
  const EnrollmentRow({
    this.opId,
    required this.syncState,
    this.serverSeq,
    this.at,
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.licenseTypeId,
    required this.carId,
    required this.stage,
    required this.registeredOn,
    required this.archived,
    this.graduatedOn,
    this.withdrawReason,
    this.finalSummaryJson,
    this.plannedTheory,
    this.plannedPractical,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || opId != null) {
      map['op_id'] = Variable<String>(opId);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    if (!nullToAbsent || at != null) {
      map['at'] = Variable<String>(at);
    }
    map['id'] = Variable<String>(id);
    map['student_id'] = Variable<String>(studentId);
    map['student_name'] = Variable<String>(studentName);
    map['license_type_id'] = Variable<String>(licenseTypeId);
    map['car_id'] = Variable<String>(carId);
    map['stage'] = Variable<String>(stage);
    map['registered_on'] = Variable<String>(registeredOn);
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || graduatedOn != null) {
      map['graduated_on'] = Variable<String>(graduatedOn);
    }
    if (!nullToAbsent || withdrawReason != null) {
      map['withdraw_reason'] = Variable<String>(withdrawReason);
    }
    if (!nullToAbsent || finalSummaryJson != null) {
      map['final_summary_json'] = Variable<String>(finalSummaryJson);
    }
    if (!nullToAbsent || plannedTheory != null) {
      map['planned_theory'] = Variable<int>(plannedTheory);
    }
    if (!nullToAbsent || plannedPractical != null) {
      map['planned_practical'] = Variable<int>(plannedPractical);
    }
    return map;
  }

  EnrollmentsCompanion toCompanion(bool nullToAbsent) {
    return EnrollmentsCompanion(
      opId: opId == null && nullToAbsent ? const Value.absent() : Value(opId),
      syncState: Value(syncState),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      at: at == null && nullToAbsent ? const Value.absent() : Value(at),
      id: Value(id),
      studentId: Value(studentId),
      studentName: Value(studentName),
      licenseTypeId: Value(licenseTypeId),
      carId: Value(carId),
      stage: Value(stage),
      registeredOn: Value(registeredOn),
      archived: Value(archived),
      graduatedOn: graduatedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(graduatedOn),
      withdrawReason: withdrawReason == null && nullToAbsent
          ? const Value.absent()
          : Value(withdrawReason),
      finalSummaryJson: finalSummaryJson == null && nullToAbsent
          ? const Value.absent()
          : Value(finalSummaryJson),
      plannedTheory: plannedTheory == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedTheory),
      plannedPractical: plannedPractical == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedPractical),
    );
  }

  factory EnrollmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnrollmentRow(
      opId: serializer.fromJson<String?>(json['opId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      at: serializer.fromJson<String?>(json['at']),
      id: serializer.fromJson<String>(json['id']),
      studentId: serializer.fromJson<String>(json['studentId']),
      studentName: serializer.fromJson<String>(json['studentName']),
      licenseTypeId: serializer.fromJson<String>(json['licenseTypeId']),
      carId: serializer.fromJson<String>(json['carId']),
      stage: serializer.fromJson<String>(json['stage']),
      registeredOn: serializer.fromJson<String>(json['registeredOn']),
      archived: serializer.fromJson<bool>(json['archived']),
      graduatedOn: serializer.fromJson<String?>(json['graduatedOn']),
      withdrawReason: serializer.fromJson<String?>(json['withdrawReason']),
      finalSummaryJson: serializer.fromJson<String?>(json['finalSummaryJson']),
      plannedTheory: serializer.fromJson<int?>(json['plannedTheory']),
      plannedPractical: serializer.fromJson<int?>(json['plannedPractical']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String?>(opId),
      'syncState': serializer.toJson<String>(syncState),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'at': serializer.toJson<String?>(at),
      'id': serializer.toJson<String>(id),
      'studentId': serializer.toJson<String>(studentId),
      'studentName': serializer.toJson<String>(studentName),
      'licenseTypeId': serializer.toJson<String>(licenseTypeId),
      'carId': serializer.toJson<String>(carId),
      'stage': serializer.toJson<String>(stage),
      'registeredOn': serializer.toJson<String>(registeredOn),
      'archived': serializer.toJson<bool>(archived),
      'graduatedOn': serializer.toJson<String?>(graduatedOn),
      'withdrawReason': serializer.toJson<String?>(withdrawReason),
      'finalSummaryJson': serializer.toJson<String?>(finalSummaryJson),
      'plannedTheory': serializer.toJson<int?>(plannedTheory),
      'plannedPractical': serializer.toJson<int?>(plannedPractical),
    };
  }

  EnrollmentRow copyWith({
    Value<String?> opId = const Value.absent(),
    String? syncState,
    Value<int?> serverSeq = const Value.absent(),
    Value<String?> at = const Value.absent(),
    String? id,
    String? studentId,
    String? studentName,
    String? licenseTypeId,
    String? carId,
    String? stage,
    String? registeredOn,
    bool? archived,
    Value<String?> graduatedOn = const Value.absent(),
    Value<String?> withdrawReason = const Value.absent(),
    Value<String?> finalSummaryJson = const Value.absent(),
    Value<int?> plannedTheory = const Value.absent(),
    Value<int?> plannedPractical = const Value.absent(),
  }) => EnrollmentRow(
    opId: opId.present ? opId.value : this.opId,
    syncState: syncState ?? this.syncState,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    at: at.present ? at.value : this.at,
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    studentName: studentName ?? this.studentName,
    licenseTypeId: licenseTypeId ?? this.licenseTypeId,
    carId: carId ?? this.carId,
    stage: stage ?? this.stage,
    registeredOn: registeredOn ?? this.registeredOn,
    archived: archived ?? this.archived,
    graduatedOn: graduatedOn.present ? graduatedOn.value : this.graduatedOn,
    withdrawReason: withdrawReason.present
        ? withdrawReason.value
        : this.withdrawReason,
    finalSummaryJson: finalSummaryJson.present
        ? finalSummaryJson.value
        : this.finalSummaryJson,
    plannedTheory: plannedTheory.present
        ? plannedTheory.value
        : this.plannedTheory,
    plannedPractical: plannedPractical.present
        ? plannedPractical.value
        : this.plannedPractical,
  );
  EnrollmentRow copyWithCompanion(EnrollmentsCompanion data) {
    return EnrollmentRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      at: data.at.present ? data.at.value : this.at,
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      studentName: data.studentName.present
          ? data.studentName.value
          : this.studentName,
      licenseTypeId: data.licenseTypeId.present
          ? data.licenseTypeId.value
          : this.licenseTypeId,
      carId: data.carId.present ? data.carId.value : this.carId,
      stage: data.stage.present ? data.stage.value : this.stage,
      registeredOn: data.registeredOn.present
          ? data.registeredOn.value
          : this.registeredOn,
      archived: data.archived.present ? data.archived.value : this.archived,
      graduatedOn: data.graduatedOn.present
          ? data.graduatedOn.value
          : this.graduatedOn,
      withdrawReason: data.withdrawReason.present
          ? data.withdrawReason.value
          : this.withdrawReason,
      finalSummaryJson: data.finalSummaryJson.present
          ? data.finalSummaryJson.value
          : this.finalSummaryJson,
      plannedTheory: data.plannedTheory.present
          ? data.plannedTheory.value
          : this.plannedTheory,
      plannedPractical: data.plannedPractical.present
          ? data.plannedPractical.value
          : this.plannedPractical,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnrollmentRow(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('studentName: $studentName, ')
          ..write('licenseTypeId: $licenseTypeId, ')
          ..write('carId: $carId, ')
          ..write('stage: $stage, ')
          ..write('registeredOn: $registeredOn, ')
          ..write('archived: $archived, ')
          ..write('graduatedOn: $graduatedOn, ')
          ..write('withdrawReason: $withdrawReason, ')
          ..write('finalSummaryJson: $finalSummaryJson, ')
          ..write('plannedTheory: $plannedTheory, ')
          ..write('plannedPractical: $plannedPractical')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    syncState,
    serverSeq,
    at,
    id,
    studentId,
    studentName,
    licenseTypeId,
    carId,
    stage,
    registeredOn,
    archived,
    graduatedOn,
    withdrawReason,
    finalSummaryJson,
    plannedTheory,
    plannedPractical,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnrollmentRow &&
          other.opId == this.opId &&
          other.syncState == this.syncState &&
          other.serverSeq == this.serverSeq &&
          other.at == this.at &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.studentName == this.studentName &&
          other.licenseTypeId == this.licenseTypeId &&
          other.carId == this.carId &&
          other.stage == this.stage &&
          other.registeredOn == this.registeredOn &&
          other.archived == this.archived &&
          other.graduatedOn == this.graduatedOn &&
          other.withdrawReason == this.withdrawReason &&
          other.finalSummaryJson == this.finalSummaryJson &&
          other.plannedTheory == this.plannedTheory &&
          other.plannedPractical == this.plannedPractical);
}

class EnrollmentsCompanion extends UpdateCompanion<EnrollmentRow> {
  final Value<String?> opId;
  final Value<String> syncState;
  final Value<int?> serverSeq;
  final Value<String?> at;
  final Value<String> id;
  final Value<String> studentId;
  final Value<String> studentName;
  final Value<String> licenseTypeId;
  final Value<String> carId;
  final Value<String> stage;
  final Value<String> registeredOn;
  final Value<bool> archived;
  final Value<String?> graduatedOn;
  final Value<String?> withdrawReason;
  final Value<String?> finalSummaryJson;
  final Value<int?> plannedTheory;
  final Value<int?> plannedPractical;
  final Value<int> rowid;
  const EnrollmentsCompanion({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.studentName = const Value.absent(),
    this.licenseTypeId = const Value.absent(),
    this.carId = const Value.absent(),
    this.stage = const Value.absent(),
    this.registeredOn = const Value.absent(),
    this.archived = const Value.absent(),
    this.graduatedOn = const Value.absent(),
    this.withdrawReason = const Value.absent(),
    this.finalSummaryJson = const Value.absent(),
    this.plannedTheory = const Value.absent(),
    this.plannedPractical = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnrollmentsCompanion.insert({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    required String id,
    required String studentId,
    required String studentName,
    required String licenseTypeId,
    required String carId,
    this.stage = const Value.absent(),
    required String registeredOn,
    this.archived = const Value.absent(),
    this.graduatedOn = const Value.absent(),
    this.withdrawReason = const Value.absent(),
    this.finalSummaryJson = const Value.absent(),
    this.plannedTheory = const Value.absent(),
    this.plannedPractical = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentId = Value(studentId),
       studentName = Value(studentName),
       licenseTypeId = Value(licenseTypeId),
       carId = Value(carId),
       registeredOn = Value(registeredOn);
  static Insertable<EnrollmentRow> custom({
    Expression<String>? opId,
    Expression<String>? syncState,
    Expression<int>? serverSeq,
    Expression<String>? at,
    Expression<String>? id,
    Expression<String>? studentId,
    Expression<String>? studentName,
    Expression<String>? licenseTypeId,
    Expression<String>? carId,
    Expression<String>? stage,
    Expression<String>? registeredOn,
    Expression<bool>? archived,
    Expression<String>? graduatedOn,
    Expression<String>? withdrawReason,
    Expression<String>? finalSummaryJson,
    Expression<int>? plannedTheory,
    Expression<int>? plannedPractical,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (syncState != null) 'sync_state': syncState,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (at != null) 'at': at,
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (studentName != null) 'student_name': studentName,
      if (licenseTypeId != null) 'license_type_id': licenseTypeId,
      if (carId != null) 'car_id': carId,
      if (stage != null) 'stage': stage,
      if (registeredOn != null) 'registered_on': registeredOn,
      if (archived != null) 'archived': archived,
      if (graduatedOn != null) 'graduated_on': graduatedOn,
      if (withdrawReason != null) 'withdraw_reason': withdrawReason,
      if (finalSummaryJson != null) 'final_summary_json': finalSummaryJson,
      if (plannedTheory != null) 'planned_theory': plannedTheory,
      if (plannedPractical != null) 'planned_practical': plannedPractical,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnrollmentsCompanion copyWith({
    Value<String?>? opId,
    Value<String>? syncState,
    Value<int?>? serverSeq,
    Value<String?>? at,
    Value<String>? id,
    Value<String>? studentId,
    Value<String>? studentName,
    Value<String>? licenseTypeId,
    Value<String>? carId,
    Value<String>? stage,
    Value<String>? registeredOn,
    Value<bool>? archived,
    Value<String?>? graduatedOn,
    Value<String?>? withdrawReason,
    Value<String?>? finalSummaryJson,
    Value<int?>? plannedTheory,
    Value<int?>? plannedPractical,
    Value<int>? rowid,
  }) {
    return EnrollmentsCompanion(
      opId: opId ?? this.opId,
      syncState: syncState ?? this.syncState,
      serverSeq: serverSeq ?? this.serverSeq,
      at: at ?? this.at,
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      licenseTypeId: licenseTypeId ?? this.licenseTypeId,
      carId: carId ?? this.carId,
      stage: stage ?? this.stage,
      registeredOn: registeredOn ?? this.registeredOn,
      archived: archived ?? this.archived,
      graduatedOn: graduatedOn ?? this.graduatedOn,
      withdrawReason: withdrawReason ?? this.withdrawReason,
      finalSummaryJson: finalSummaryJson ?? this.finalSummaryJson,
      plannedTheory: plannedTheory ?? this.plannedTheory,
      plannedPractical: plannedPractical ?? this.plannedPractical,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (studentName.present) {
      map['student_name'] = Variable<String>(studentName.value);
    }
    if (licenseTypeId.present) {
      map['license_type_id'] = Variable<String>(licenseTypeId.value);
    }
    if (carId.present) {
      map['car_id'] = Variable<String>(carId.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (registeredOn.present) {
      map['registered_on'] = Variable<String>(registeredOn.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (graduatedOn.present) {
      map['graduated_on'] = Variable<String>(graduatedOn.value);
    }
    if (withdrawReason.present) {
      map['withdraw_reason'] = Variable<String>(withdrawReason.value);
    }
    if (finalSummaryJson.present) {
      map['final_summary_json'] = Variable<String>(finalSummaryJson.value);
    }
    if (plannedTheory.present) {
      map['planned_theory'] = Variable<int>(plannedTheory.value);
    }
    if (plannedPractical.present) {
      map['planned_practical'] = Variable<int>(plannedPractical.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnrollmentsCompanion(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('studentName: $studentName, ')
          ..write('licenseTypeId: $licenseTypeId, ')
          ..write('carId: $carId, ')
          ..write('stage: $stage, ')
          ..write('registeredOn: $registeredOn, ')
          ..write('archived: $archived, ')
          ..write('graduatedOn: $graduatedOn, ')
          ..write('withdrawReason: $withdrawReason, ')
          ..write('finalSummaryJson: $finalSummaryJson, ')
          ..write('plannedTheory: $plannedTheory, ')
          ..write('plannedPractical: $plannedPractical, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LessonsTable extends Lessons with TableInfo<$LessonsTable, LessonRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enrollmentIdMeta = const VerificationMeta(
    'enrollmentId',
  );
  @override
  late final GeneratedColumn<String> enrollmentId = GeneratedColumn<String>(
    'enrollment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _withoutDrivingMeta = const VerificationMeta(
    'withoutDriving',
  );
  @override
  late final GeneratedColumn<bool> withoutDriving = GeneratedColumn<bool>(
    'without_driving',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("without_driving" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carIdMeta = const VerificationMeta('carId');
  @override
  late final GeneratedColumn<String> carId = GeneratedColumn<String>(
    'car_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<String> startedAt = GeneratedColumn<String>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    syncState,
    serverSeq,
    at,
    id,
    enrollmentId,
    studentId,
    type,
    number,
    withoutDriving,
    employeeId,
    carId,
    startedAt,
    businessDate,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lessons';
  @override
  VerificationContext validateIntegrity(
    Insertable<LessonRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('enrollment_id')) {
      context.handle(
        _enrollmentIdMeta,
        enrollmentId.isAcceptableOrUnknown(
          data['enrollment_id']!,
          _enrollmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_enrollmentIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('without_driving')) {
      context.handle(
        _withoutDrivingMeta,
        withoutDriving.isAcceptableOrUnknown(
          data['without_driving']!,
          _withoutDrivingMeta,
        ),
      );
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('car_id')) {
      context.handle(
        _carIdMeta,
        carId.isAcceptableOrUnknown(data['car_id']!, _carIdMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LessonRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      enrollmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enrollment_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      withoutDriving: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}without_driving'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      )!,
      carId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}car_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_at'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $LessonsTable createAlias(String alias) {
    return $LessonsTable(attachedDatabase, alias);
  }
}

class LessonRow extends DataClass implements Insertable<LessonRow> {
  /// The op that created/changed this row (links local rows to outbox results).
  final String? opId;

  /// pending | synced | rejected
  final String syncState;
  final int? serverSeq;

  /// When it happened (ISO-8601): device time while pending, server time once synced.
  final String? at;
  final String id;
  final String enrollmentId;
  final String studentId;

  /// theory | practical
  final String type;

  /// Provisional on the phone until the server assigns the final number.
  final int number;
  final bool withoutDriving;
  final String employeeId;
  final String? carId;
  final String startedAt;
  final String businessDate;
  final bool archived;
  const LessonRow({
    this.opId,
    required this.syncState,
    this.serverSeq,
    this.at,
    required this.id,
    required this.enrollmentId,
    required this.studentId,
    required this.type,
    required this.number,
    required this.withoutDriving,
    required this.employeeId,
    this.carId,
    required this.startedAt,
    required this.businessDate,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || opId != null) {
      map['op_id'] = Variable<String>(opId);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    if (!nullToAbsent || at != null) {
      map['at'] = Variable<String>(at);
    }
    map['id'] = Variable<String>(id);
    map['enrollment_id'] = Variable<String>(enrollmentId);
    map['student_id'] = Variable<String>(studentId);
    map['type'] = Variable<String>(type);
    map['number'] = Variable<int>(number);
    map['without_driving'] = Variable<bool>(withoutDriving);
    map['employee_id'] = Variable<String>(employeeId);
    if (!nullToAbsent || carId != null) {
      map['car_id'] = Variable<String>(carId);
    }
    map['started_at'] = Variable<String>(startedAt);
    map['business_date'] = Variable<String>(businessDate);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  LessonsCompanion toCompanion(bool nullToAbsent) {
    return LessonsCompanion(
      opId: opId == null && nullToAbsent ? const Value.absent() : Value(opId),
      syncState: Value(syncState),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      at: at == null && nullToAbsent ? const Value.absent() : Value(at),
      id: Value(id),
      enrollmentId: Value(enrollmentId),
      studentId: Value(studentId),
      type: Value(type),
      number: Value(number),
      withoutDriving: Value(withoutDriving),
      employeeId: Value(employeeId),
      carId: carId == null && nullToAbsent
          ? const Value.absent()
          : Value(carId),
      startedAt: Value(startedAt),
      businessDate: Value(businessDate),
      archived: Value(archived),
    );
  }

  factory LessonRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonRow(
      opId: serializer.fromJson<String?>(json['opId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      at: serializer.fromJson<String?>(json['at']),
      id: serializer.fromJson<String>(json['id']),
      enrollmentId: serializer.fromJson<String>(json['enrollmentId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      type: serializer.fromJson<String>(json['type']),
      number: serializer.fromJson<int>(json['number']),
      withoutDriving: serializer.fromJson<bool>(json['withoutDriving']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
      carId: serializer.fromJson<String?>(json['carId']),
      startedAt: serializer.fromJson<String>(json['startedAt']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String?>(opId),
      'syncState': serializer.toJson<String>(syncState),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'at': serializer.toJson<String?>(at),
      'id': serializer.toJson<String>(id),
      'enrollmentId': serializer.toJson<String>(enrollmentId),
      'studentId': serializer.toJson<String>(studentId),
      'type': serializer.toJson<String>(type),
      'number': serializer.toJson<int>(number),
      'withoutDriving': serializer.toJson<bool>(withoutDriving),
      'employeeId': serializer.toJson<String>(employeeId),
      'carId': serializer.toJson<String?>(carId),
      'startedAt': serializer.toJson<String>(startedAt),
      'businessDate': serializer.toJson<String>(businessDate),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  LessonRow copyWith({
    Value<String?> opId = const Value.absent(),
    String? syncState,
    Value<int?> serverSeq = const Value.absent(),
    Value<String?> at = const Value.absent(),
    String? id,
    String? enrollmentId,
    String? studentId,
    String? type,
    int? number,
    bool? withoutDriving,
    String? employeeId,
    Value<String?> carId = const Value.absent(),
    String? startedAt,
    String? businessDate,
    bool? archived,
  }) => LessonRow(
    opId: opId.present ? opId.value : this.opId,
    syncState: syncState ?? this.syncState,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    at: at.present ? at.value : this.at,
    id: id ?? this.id,
    enrollmentId: enrollmentId ?? this.enrollmentId,
    studentId: studentId ?? this.studentId,
    type: type ?? this.type,
    number: number ?? this.number,
    withoutDriving: withoutDriving ?? this.withoutDriving,
    employeeId: employeeId ?? this.employeeId,
    carId: carId.present ? carId.value : this.carId,
    startedAt: startedAt ?? this.startedAt,
    businessDate: businessDate ?? this.businessDate,
    archived: archived ?? this.archived,
  );
  LessonRow copyWithCompanion(LessonsCompanion data) {
    return LessonRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      at: data.at.present ? data.at.value : this.at,
      id: data.id.present ? data.id.value : this.id,
      enrollmentId: data.enrollmentId.present
          ? data.enrollmentId.value
          : this.enrollmentId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      type: data.type.present ? data.type.value : this.type,
      number: data.number.present ? data.number.value : this.number,
      withoutDriving: data.withoutDriving.present
          ? data.withoutDriving.value
          : this.withoutDriving,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      carId: data.carId.present ? data.carId.value : this.carId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonRow(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('enrollmentId: $enrollmentId, ')
          ..write('studentId: $studentId, ')
          ..write('type: $type, ')
          ..write('number: $number, ')
          ..write('withoutDriving: $withoutDriving, ')
          ..write('employeeId: $employeeId, ')
          ..write('carId: $carId, ')
          ..write('startedAt: $startedAt, ')
          ..write('businessDate: $businessDate, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    syncState,
    serverSeq,
    at,
    id,
    enrollmentId,
    studentId,
    type,
    number,
    withoutDriving,
    employeeId,
    carId,
    startedAt,
    businessDate,
    archived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LessonRow &&
          other.opId == this.opId &&
          other.syncState == this.syncState &&
          other.serverSeq == this.serverSeq &&
          other.at == this.at &&
          other.id == this.id &&
          other.enrollmentId == this.enrollmentId &&
          other.studentId == this.studentId &&
          other.type == this.type &&
          other.number == this.number &&
          other.withoutDriving == this.withoutDriving &&
          other.employeeId == this.employeeId &&
          other.carId == this.carId &&
          other.startedAt == this.startedAt &&
          other.businessDate == this.businessDate &&
          other.archived == this.archived);
}

class LessonsCompanion extends UpdateCompanion<LessonRow> {
  final Value<String?> opId;
  final Value<String> syncState;
  final Value<int?> serverSeq;
  final Value<String?> at;
  final Value<String> id;
  final Value<String> enrollmentId;
  final Value<String> studentId;
  final Value<String> type;
  final Value<int> number;
  final Value<bool> withoutDriving;
  final Value<String> employeeId;
  final Value<String?> carId;
  final Value<String> startedAt;
  final Value<String> businessDate;
  final Value<bool> archived;
  final Value<int> rowid;
  const LessonsCompanion({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    this.id = const Value.absent(),
    this.enrollmentId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.type = const Value.absent(),
    this.number = const Value.absent(),
    this.withoutDriving = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.carId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonsCompanion.insert({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    required String id,
    required String enrollmentId,
    required String studentId,
    required String type,
    required int number,
    this.withoutDriving = const Value.absent(),
    required String employeeId,
    this.carId = const Value.absent(),
    required String startedAt,
    required String businessDate,
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       enrollmentId = Value(enrollmentId),
       studentId = Value(studentId),
       type = Value(type),
       number = Value(number),
       employeeId = Value(employeeId),
       startedAt = Value(startedAt),
       businessDate = Value(businessDate);
  static Insertable<LessonRow> custom({
    Expression<String>? opId,
    Expression<String>? syncState,
    Expression<int>? serverSeq,
    Expression<String>? at,
    Expression<String>? id,
    Expression<String>? enrollmentId,
    Expression<String>? studentId,
    Expression<String>? type,
    Expression<int>? number,
    Expression<bool>? withoutDriving,
    Expression<String>? employeeId,
    Expression<String>? carId,
    Expression<String>? startedAt,
    Expression<String>? businessDate,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (syncState != null) 'sync_state': syncState,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (at != null) 'at': at,
      if (id != null) 'id': id,
      if (enrollmentId != null) 'enrollment_id': enrollmentId,
      if (studentId != null) 'student_id': studentId,
      if (type != null) 'type': type,
      if (number != null) 'number': number,
      if (withoutDriving != null) 'without_driving': withoutDriving,
      if (employeeId != null) 'employee_id': employeeId,
      if (carId != null) 'car_id': carId,
      if (startedAt != null) 'started_at': startedAt,
      if (businessDate != null) 'business_date': businessDate,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonsCompanion copyWith({
    Value<String?>? opId,
    Value<String>? syncState,
    Value<int?>? serverSeq,
    Value<String?>? at,
    Value<String>? id,
    Value<String>? enrollmentId,
    Value<String>? studentId,
    Value<String>? type,
    Value<int>? number,
    Value<bool>? withoutDriving,
    Value<String>? employeeId,
    Value<String?>? carId,
    Value<String>? startedAt,
    Value<String>? businessDate,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return LessonsCompanion(
      opId: opId ?? this.opId,
      syncState: syncState ?? this.syncState,
      serverSeq: serverSeq ?? this.serverSeq,
      at: at ?? this.at,
      id: id ?? this.id,
      enrollmentId: enrollmentId ?? this.enrollmentId,
      studentId: studentId ?? this.studentId,
      type: type ?? this.type,
      number: number ?? this.number,
      withoutDriving: withoutDriving ?? this.withoutDriving,
      employeeId: employeeId ?? this.employeeId,
      carId: carId ?? this.carId,
      startedAt: startedAt ?? this.startedAt,
      businessDate: businessDate ?? this.businessDate,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (enrollmentId.present) {
      map['enrollment_id'] = Variable<String>(enrollmentId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (withoutDriving.present) {
      map['without_driving'] = Variable<bool>(withoutDriving.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (carId.present) {
      map['car_id'] = Variable<String>(carId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<String>(startedAt.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonsCompanion(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('enrollmentId: $enrollmentId, ')
          ..write('studentId: $studentId, ')
          ..write('type: $type, ')
          ..write('number: $number, ')
          ..write('withoutDriving: $withoutDriving, ')
          ..write('employeeId: $employeeId, ')
          ..write('carId: $carId, ')
          ..write('startedAt: $startedAt, ')
          ..write('businessDate: $businessDate, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LedgerEntriesTable extends LedgerEntries
    with TableInfo<$LedgerEntriesTable, LedgerRowData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enrollmentIdMeta = const VerificationMeta(
    'enrollmentId',
  );
  @override
  late final GeneratedColumn<String> enrollmentId = GeneratedColumn<String>(
    'enrollment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptNoMeta = const VerificationMeta(
    'receiptNo',
  );
  @override
  late final GeneratedColumn<String> receiptNo = GeneratedColumn<String>(
    'receipt_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reversesIdMeta = const VerificationMeta(
    'reversesId',
  );
  @override
  late final GeneratedColumn<String> reversesId = GeneratedColumn<String>(
    'reverses_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reversedMeta = const VerificationMeta(
    'reversed',
  );
  @override
  late final GeneratedColumn<bool> reversed = GeneratedColumn<bool>(
    'reversed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reversed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    syncState,
    serverSeq,
    at,
    id,
    enrollmentId,
    studentId,
    kind,
    amount,
    accountId,
    purpose,
    receiptNo,
    lessonId,
    reversesId,
    reversed,
    businessDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'student_ledger';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerRowData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('enrollment_id')) {
      context.handle(
        _enrollmentIdMeta,
        enrollmentId.isAcceptableOrUnknown(
          data['enrollment_id']!,
          _enrollmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_enrollmentIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    }
    if (data.containsKey('receipt_no')) {
      context.handle(
        _receiptNoMeta,
        receiptNo.isAcceptableOrUnknown(data['receipt_no']!, _receiptNoMeta),
      );
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    }
    if (data.containsKey('reverses_id')) {
      context.handle(
        _reversesIdMeta,
        reversesId.isAcceptableOrUnknown(data['reverses_id']!, _reversesIdMeta),
      );
    }
    if (data.containsKey('reversed')) {
      context.handle(
        _reversedMeta,
        reversed.isAcceptableOrUnknown(data['reversed']!, _reversedMeta),
      );
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerRowData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerRowData(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      enrollmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enrollment_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      ),
      receiptNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_no'],
      ),
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      ),
      reversesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reverses_id'],
      ),
      reversed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reversed'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
    );
  }

  @override
  $LedgerEntriesTable createAlias(String alias) {
    return $LedgerEntriesTable(attachedDatabase, alias);
  }
}

class LedgerRowData extends DataClass implements Insertable<LedgerRowData> {
  /// The op that created/changed this row (links local rows to outbox results).
  final String? opId;

  /// pending | synced | rejected
  final String syncState;
  final int? serverSeq;

  /// When it happened (ISO-8601): device time while pending, server time once synced.
  final String? at;
  final String id;
  final String enrollmentId;
  final String studentId;

  /// registration_fee | lesson_charge | exam_fee | retake_fee | payment | discount | reversal (of a payment) | charge_reversal
  final String kind;
  final int amount;
  final String? accountId;
  final String? purpose;
  final String? receiptNo;
  final String? lessonId;
  final String? reversesId;
  final bool reversed;
  final String businessDate;
  const LedgerRowData({
    this.opId,
    required this.syncState,
    this.serverSeq,
    this.at,
    required this.id,
    required this.enrollmentId,
    required this.studentId,
    required this.kind,
    required this.amount,
    this.accountId,
    this.purpose,
    this.receiptNo,
    this.lessonId,
    this.reversesId,
    required this.reversed,
    required this.businessDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || opId != null) {
      map['op_id'] = Variable<String>(opId);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    if (!nullToAbsent || at != null) {
      map['at'] = Variable<String>(at);
    }
    map['id'] = Variable<String>(id);
    map['enrollment_id'] = Variable<String>(enrollmentId);
    map['student_id'] = Variable<String>(studentId);
    map['kind'] = Variable<String>(kind);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    if (!nullToAbsent || purpose != null) {
      map['purpose'] = Variable<String>(purpose);
    }
    if (!nullToAbsent || receiptNo != null) {
      map['receipt_no'] = Variable<String>(receiptNo);
    }
    if (!nullToAbsent || lessonId != null) {
      map['lesson_id'] = Variable<String>(lessonId);
    }
    if (!nullToAbsent || reversesId != null) {
      map['reverses_id'] = Variable<String>(reversesId);
    }
    map['reversed'] = Variable<bool>(reversed);
    map['business_date'] = Variable<String>(businessDate);
    return map;
  }

  LedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return LedgerEntriesCompanion(
      opId: opId == null && nullToAbsent ? const Value.absent() : Value(opId),
      syncState: Value(syncState),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      at: at == null && nullToAbsent ? const Value.absent() : Value(at),
      id: Value(id),
      enrollmentId: Value(enrollmentId),
      studentId: Value(studentId),
      kind: Value(kind),
      amount: Value(amount),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      purpose: purpose == null && nullToAbsent
          ? const Value.absent()
          : Value(purpose),
      receiptNo: receiptNo == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptNo),
      lessonId: lessonId == null && nullToAbsent
          ? const Value.absent()
          : Value(lessonId),
      reversesId: reversesId == null && nullToAbsent
          ? const Value.absent()
          : Value(reversesId),
      reversed: Value(reversed),
      businessDate: Value(businessDate),
    );
  }

  factory LedgerRowData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerRowData(
      opId: serializer.fromJson<String?>(json['opId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      at: serializer.fromJson<String?>(json['at']),
      id: serializer.fromJson<String>(json['id']),
      enrollmentId: serializer.fromJson<String>(json['enrollmentId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      kind: serializer.fromJson<String>(json['kind']),
      amount: serializer.fromJson<int>(json['amount']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      purpose: serializer.fromJson<String?>(json['purpose']),
      receiptNo: serializer.fromJson<String?>(json['receiptNo']),
      lessonId: serializer.fromJson<String?>(json['lessonId']),
      reversesId: serializer.fromJson<String?>(json['reversesId']),
      reversed: serializer.fromJson<bool>(json['reversed']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String?>(opId),
      'syncState': serializer.toJson<String>(syncState),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'at': serializer.toJson<String?>(at),
      'id': serializer.toJson<String>(id),
      'enrollmentId': serializer.toJson<String>(enrollmentId),
      'studentId': serializer.toJson<String>(studentId),
      'kind': serializer.toJson<String>(kind),
      'amount': serializer.toJson<int>(amount),
      'accountId': serializer.toJson<String?>(accountId),
      'purpose': serializer.toJson<String?>(purpose),
      'receiptNo': serializer.toJson<String?>(receiptNo),
      'lessonId': serializer.toJson<String?>(lessonId),
      'reversesId': serializer.toJson<String?>(reversesId),
      'reversed': serializer.toJson<bool>(reversed),
      'businessDate': serializer.toJson<String>(businessDate),
    };
  }

  LedgerRowData copyWith({
    Value<String?> opId = const Value.absent(),
    String? syncState,
    Value<int?> serverSeq = const Value.absent(),
    Value<String?> at = const Value.absent(),
    String? id,
    String? enrollmentId,
    String? studentId,
    String? kind,
    int? amount,
    Value<String?> accountId = const Value.absent(),
    Value<String?> purpose = const Value.absent(),
    Value<String?> receiptNo = const Value.absent(),
    Value<String?> lessonId = const Value.absent(),
    Value<String?> reversesId = const Value.absent(),
    bool? reversed,
    String? businessDate,
  }) => LedgerRowData(
    opId: opId.present ? opId.value : this.opId,
    syncState: syncState ?? this.syncState,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    at: at.present ? at.value : this.at,
    id: id ?? this.id,
    enrollmentId: enrollmentId ?? this.enrollmentId,
    studentId: studentId ?? this.studentId,
    kind: kind ?? this.kind,
    amount: amount ?? this.amount,
    accountId: accountId.present ? accountId.value : this.accountId,
    purpose: purpose.present ? purpose.value : this.purpose,
    receiptNo: receiptNo.present ? receiptNo.value : this.receiptNo,
    lessonId: lessonId.present ? lessonId.value : this.lessonId,
    reversesId: reversesId.present ? reversesId.value : this.reversesId,
    reversed: reversed ?? this.reversed,
    businessDate: businessDate ?? this.businessDate,
  );
  LedgerRowData copyWithCompanion(LedgerEntriesCompanion data) {
    return LedgerRowData(
      opId: data.opId.present ? data.opId.value : this.opId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      at: data.at.present ? data.at.value : this.at,
      id: data.id.present ? data.id.value : this.id,
      enrollmentId: data.enrollmentId.present
          ? data.enrollmentId.value
          : this.enrollmentId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      kind: data.kind.present ? data.kind.value : this.kind,
      amount: data.amount.present ? data.amount.value : this.amount,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      receiptNo: data.receiptNo.present ? data.receiptNo.value : this.receiptNo,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      reversesId: data.reversesId.present
          ? data.reversesId.value
          : this.reversesId,
      reversed: data.reversed.present ? data.reversed.value : this.reversed,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerRowData(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('enrollmentId: $enrollmentId, ')
          ..write('studentId: $studentId, ')
          ..write('kind: $kind, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('purpose: $purpose, ')
          ..write('receiptNo: $receiptNo, ')
          ..write('lessonId: $lessonId, ')
          ..write('reversesId: $reversesId, ')
          ..write('reversed: $reversed, ')
          ..write('businessDate: $businessDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    syncState,
    serverSeq,
    at,
    id,
    enrollmentId,
    studentId,
    kind,
    amount,
    accountId,
    purpose,
    receiptNo,
    lessonId,
    reversesId,
    reversed,
    businessDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerRowData &&
          other.opId == this.opId &&
          other.syncState == this.syncState &&
          other.serverSeq == this.serverSeq &&
          other.at == this.at &&
          other.id == this.id &&
          other.enrollmentId == this.enrollmentId &&
          other.studentId == this.studentId &&
          other.kind == this.kind &&
          other.amount == this.amount &&
          other.accountId == this.accountId &&
          other.purpose == this.purpose &&
          other.receiptNo == this.receiptNo &&
          other.lessonId == this.lessonId &&
          other.reversesId == this.reversesId &&
          other.reversed == this.reversed &&
          other.businessDate == this.businessDate);
}

class LedgerEntriesCompanion extends UpdateCompanion<LedgerRowData> {
  final Value<String?> opId;
  final Value<String> syncState;
  final Value<int?> serverSeq;
  final Value<String?> at;
  final Value<String> id;
  final Value<String> enrollmentId;
  final Value<String> studentId;
  final Value<String> kind;
  final Value<int> amount;
  final Value<String?> accountId;
  final Value<String?> purpose;
  final Value<String?> receiptNo;
  final Value<String?> lessonId;
  final Value<String?> reversesId;
  final Value<bool> reversed;
  final Value<String> businessDate;
  final Value<int> rowid;
  const LedgerEntriesCompanion({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    this.id = const Value.absent(),
    this.enrollmentId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.kind = const Value.absent(),
    this.amount = const Value.absent(),
    this.accountId = const Value.absent(),
    this.purpose = const Value.absent(),
    this.receiptNo = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.reversesId = const Value.absent(),
    this.reversed = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerEntriesCompanion.insert({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    required String id,
    required String enrollmentId,
    required String studentId,
    required String kind,
    required int amount,
    this.accountId = const Value.absent(),
    this.purpose = const Value.absent(),
    this.receiptNo = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.reversesId = const Value.absent(),
    this.reversed = const Value.absent(),
    required String businessDate,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       enrollmentId = Value(enrollmentId),
       studentId = Value(studentId),
       kind = Value(kind),
       amount = Value(amount),
       businessDate = Value(businessDate);
  static Insertable<LedgerRowData> custom({
    Expression<String>? opId,
    Expression<String>? syncState,
    Expression<int>? serverSeq,
    Expression<String>? at,
    Expression<String>? id,
    Expression<String>? enrollmentId,
    Expression<String>? studentId,
    Expression<String>? kind,
    Expression<int>? amount,
    Expression<String>? accountId,
    Expression<String>? purpose,
    Expression<String>? receiptNo,
    Expression<String>? lessonId,
    Expression<String>? reversesId,
    Expression<bool>? reversed,
    Expression<String>? businessDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (syncState != null) 'sync_state': syncState,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (at != null) 'at': at,
      if (id != null) 'id': id,
      if (enrollmentId != null) 'enrollment_id': enrollmentId,
      if (studentId != null) 'student_id': studentId,
      if (kind != null) 'kind': kind,
      if (amount != null) 'amount': amount,
      if (accountId != null) 'account_id': accountId,
      if (purpose != null) 'purpose': purpose,
      if (receiptNo != null) 'receipt_no': receiptNo,
      if (lessonId != null) 'lesson_id': lessonId,
      if (reversesId != null) 'reverses_id': reversesId,
      if (reversed != null) 'reversed': reversed,
      if (businessDate != null) 'business_date': businessDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerEntriesCompanion copyWith({
    Value<String?>? opId,
    Value<String>? syncState,
    Value<int?>? serverSeq,
    Value<String?>? at,
    Value<String>? id,
    Value<String>? enrollmentId,
    Value<String>? studentId,
    Value<String>? kind,
    Value<int>? amount,
    Value<String?>? accountId,
    Value<String?>? purpose,
    Value<String?>? receiptNo,
    Value<String?>? lessonId,
    Value<String?>? reversesId,
    Value<bool>? reversed,
    Value<String>? businessDate,
    Value<int>? rowid,
  }) {
    return LedgerEntriesCompanion(
      opId: opId ?? this.opId,
      syncState: syncState ?? this.syncState,
      serverSeq: serverSeq ?? this.serverSeq,
      at: at ?? this.at,
      id: id ?? this.id,
      enrollmentId: enrollmentId ?? this.enrollmentId,
      studentId: studentId ?? this.studentId,
      kind: kind ?? this.kind,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      purpose: purpose ?? this.purpose,
      receiptNo: receiptNo ?? this.receiptNo,
      lessonId: lessonId ?? this.lessonId,
      reversesId: reversesId ?? this.reversesId,
      reversed: reversed ?? this.reversed,
      businessDate: businessDate ?? this.businessDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (enrollmentId.present) {
      map['enrollment_id'] = Variable<String>(enrollmentId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (receiptNo.present) {
      map['receipt_no'] = Variable<String>(receiptNo.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (reversesId.present) {
      map['reverses_id'] = Variable<String>(reversesId.value);
    }
    if (reversed.present) {
      map['reversed'] = Variable<bool>(reversed.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntriesCompanion(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('enrollmentId: $enrollmentId, ')
          ..write('studentId: $studentId, ')
          ..write('kind: $kind, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('purpose: $purpose, ')
          ..write('receiptNo: $receiptNo, ')
          ..write('lessonId: $lessonId, ')
          ..write('reversesId: $reversesId, ')
          ..write('reversed: $reversed, ')
          ..write('businessDate: $businessDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TreasuryMovementsTable extends TreasuryMovements
    with TableInfo<$TreasuryMovementsTable, MovementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TreasuryMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<String> refId = GeneratedColumn<String>(
    'ref_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    syncState,
    serverSeq,
    at,
    id,
    accountId,
    direction,
    amount,
    kind,
    refId,
    businessDate,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'treasury_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('ref_id')) {
      context.handle(
        _refIdMeta,
        refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta),
      );
    } else if (isInserting) {
      context.missing(_refIdMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovementRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      refId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_id'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $TreasuryMovementsTable createAlias(String alias) {
    return $TreasuryMovementsTable(attachedDatabase, alias);
  }
}

class MovementRow extends DataClass implements Insertable<MovementRow> {
  /// The op that created/changed this row (links local rows to outbox results).
  final String? opId;

  /// pending | synced | rejected
  final String syncState;
  final int? serverSeq;

  /// When it happened (ISO-8601): device time while pending, server time once synced.
  final String? at;
  final String id;
  final String accountId;

  /// in | out
  final String direction;
  final int amount;
  final String kind;
  final String refId;
  final String businessDate;
  final String? note;
  const MovementRow({
    this.opId,
    required this.syncState,
    this.serverSeq,
    this.at,
    required this.id,
    required this.accountId,
    required this.direction,
    required this.amount,
    required this.kind,
    required this.refId,
    required this.businessDate,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || opId != null) {
      map['op_id'] = Variable<String>(opId);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    if (!nullToAbsent || at != null) {
      map['at'] = Variable<String>(at);
    }
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['direction'] = Variable<String>(direction);
    map['amount'] = Variable<int>(amount);
    map['kind'] = Variable<String>(kind);
    map['ref_id'] = Variable<String>(refId);
    map['business_date'] = Variable<String>(businessDate);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  TreasuryMovementsCompanion toCompanion(bool nullToAbsent) {
    return TreasuryMovementsCompanion(
      opId: opId == null && nullToAbsent ? const Value.absent() : Value(opId),
      syncState: Value(syncState),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      at: at == null && nullToAbsent ? const Value.absent() : Value(at),
      id: Value(id),
      accountId: Value(accountId),
      direction: Value(direction),
      amount: Value(amount),
      kind: Value(kind),
      refId: Value(refId),
      businessDate: Value(businessDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory MovementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovementRow(
      opId: serializer.fromJson<String?>(json['opId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      at: serializer.fromJson<String?>(json['at']),
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      direction: serializer.fromJson<String>(json['direction']),
      amount: serializer.fromJson<int>(json['amount']),
      kind: serializer.fromJson<String>(json['kind']),
      refId: serializer.fromJson<String>(json['refId']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String?>(opId),
      'syncState': serializer.toJson<String>(syncState),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'at': serializer.toJson<String?>(at),
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'direction': serializer.toJson<String>(direction),
      'amount': serializer.toJson<int>(amount),
      'kind': serializer.toJson<String>(kind),
      'refId': serializer.toJson<String>(refId),
      'businessDate': serializer.toJson<String>(businessDate),
      'note': serializer.toJson<String?>(note),
    };
  }

  MovementRow copyWith({
    Value<String?> opId = const Value.absent(),
    String? syncState,
    Value<int?> serverSeq = const Value.absent(),
    Value<String?> at = const Value.absent(),
    String? id,
    String? accountId,
    String? direction,
    int? amount,
    String? kind,
    String? refId,
    String? businessDate,
    Value<String?> note = const Value.absent(),
  }) => MovementRow(
    opId: opId.present ? opId.value : this.opId,
    syncState: syncState ?? this.syncState,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    at: at.present ? at.value : this.at,
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    direction: direction ?? this.direction,
    amount: amount ?? this.amount,
    kind: kind ?? this.kind,
    refId: refId ?? this.refId,
    businessDate: businessDate ?? this.businessDate,
    note: note.present ? note.value : this.note,
  );
  MovementRow copyWithCompanion(TreasuryMovementsCompanion data) {
    return MovementRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      at: data.at.present ? data.at.value : this.at,
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      direction: data.direction.present ? data.direction.value : this.direction,
      amount: data.amount.present ? data.amount.value : this.amount,
      kind: data.kind.present ? data.kind.value : this.kind,
      refId: data.refId.present ? data.refId.value : this.refId,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovementRow(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('direction: $direction, ')
          ..write('amount: $amount, ')
          ..write('kind: $kind, ')
          ..write('refId: $refId, ')
          ..write('businessDate: $businessDate, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    syncState,
    serverSeq,
    at,
    id,
    accountId,
    direction,
    amount,
    kind,
    refId,
    businessDate,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovementRow &&
          other.opId == this.opId &&
          other.syncState == this.syncState &&
          other.serverSeq == this.serverSeq &&
          other.at == this.at &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.direction == this.direction &&
          other.amount == this.amount &&
          other.kind == this.kind &&
          other.refId == this.refId &&
          other.businessDate == this.businessDate &&
          other.note == this.note);
}

class TreasuryMovementsCompanion extends UpdateCompanion<MovementRow> {
  final Value<String?> opId;
  final Value<String> syncState;
  final Value<int?> serverSeq;
  final Value<String?> at;
  final Value<String> id;
  final Value<String> accountId;
  final Value<String> direction;
  final Value<int> amount;
  final Value<String> kind;
  final Value<String> refId;
  final Value<String> businessDate;
  final Value<String?> note;
  final Value<int> rowid;
  const TreasuryMovementsCompanion({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.direction = const Value.absent(),
    this.amount = const Value.absent(),
    this.kind = const Value.absent(),
    this.refId = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TreasuryMovementsCompanion.insert({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    required String id,
    required String accountId,
    required String direction,
    required int amount,
    required String kind,
    required String refId,
    required String businessDate,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       direction = Value(direction),
       amount = Value(amount),
       kind = Value(kind),
       refId = Value(refId),
       businessDate = Value(businessDate);
  static Insertable<MovementRow> custom({
    Expression<String>? opId,
    Expression<String>? syncState,
    Expression<int>? serverSeq,
    Expression<String>? at,
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? direction,
    Expression<int>? amount,
    Expression<String>? kind,
    Expression<String>? refId,
    Expression<String>? businessDate,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (syncState != null) 'sync_state': syncState,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (at != null) 'at': at,
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (direction != null) 'direction': direction,
      if (amount != null) 'amount': amount,
      if (kind != null) 'kind': kind,
      if (refId != null) 'ref_id': refId,
      if (businessDate != null) 'business_date': businessDate,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TreasuryMovementsCompanion copyWith({
    Value<String?>? opId,
    Value<String>? syncState,
    Value<int?>? serverSeq,
    Value<String?>? at,
    Value<String>? id,
    Value<String>? accountId,
    Value<String>? direction,
    Value<int>? amount,
    Value<String>? kind,
    Value<String>? refId,
    Value<String>? businessDate,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return TreasuryMovementsCompanion(
      opId: opId ?? this.opId,
      syncState: syncState ?? this.syncState,
      serverSeq: serverSeq ?? this.serverSeq,
      at: at ?? this.at,
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      direction: direction ?? this.direction,
      amount: amount ?? this.amount,
      kind: kind ?? this.kind,
      refId: refId ?? this.refId,
      businessDate: businessDate ?? this.businessDate,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<String>(refId.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TreasuryMovementsCompanion(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('direction: $direction, ')
          ..write('amount: $amount, ')
          ..write('kind: $kind, ')
          ..write('refId: $refId, ')
          ..write('businessDate: $businessDate, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LicensePricesTable extends LicensePrices
    with TableInfo<$LicensePricesTable, LicensePriceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LicensePricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _licenseTypeIdMeta = const VerificationMeta(
    'licenseTypeId',
  );
  @override
  late final GeneratedColumn<String> licenseTypeId = GeneratedColumn<String>(
    'license_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  @override
  late final GeneratedColumn<String> effectiveFrom = GeneratedColumn<String>(
    'effective_from',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registrationFeeMeta = const VerificationMeta(
    'registrationFee',
  );
  @override
  late final GeneratedColumn<int> registrationFee = GeneratedColumn<int>(
    'registration_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _practicalLessonPriceMeta =
      const VerificationMeta('practicalLessonPrice');
  @override
  late final GeneratedColumn<int> practicalLessonPrice = GeneratedColumn<int>(
    'practical_lesson_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _theoryRetakeFeeMeta = const VerificationMeta(
    'theoryRetakeFee',
  );
  @override
  late final GeneratedColumn<int> theoryRetakeFee = GeneratedColumn<int>(
    'theory_retake_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _practicalExamFeeMeta = const VerificationMeta(
    'practicalExamFee',
  );
  @override
  late final GeneratedColumn<int> practicalExamFee = GeneratedColumn<int>(
    'practical_exam_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedTheoryLessonsMeta =
      const VerificationMeta('plannedTheoryLessons');
  @override
  late final GeneratedColumn<int> plannedTheoryLessons = GeneratedColumn<int>(
    'planned_theory_lessons',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _plannedPracticalLessonsMeta =
      const VerificationMeta('plannedPracticalLessons');
  @override
  late final GeneratedColumn<int> plannedPracticalLessons =
      GeneratedColumn<int>(
        'planned_practical_lessons',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _minTheoryBeforeExamMeta =
      const VerificationMeta('minTheoryBeforeExam');
  @override
  late final GeneratedColumn<int> minTheoryBeforeExam = GeneratedColumn<int>(
    'min_theory_before_exam',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _minPracticalBeforeExamMeta =
      const VerificationMeta('minPracticalBeforeExam');
  @override
  late final GeneratedColumn<int> minPracticalBeforeExam = GeneratedColumn<int>(
    'min_practical_before_exam',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _practicalAfterTheoryMeta =
      const VerificationMeta('practicalAfterTheory');
  @override
  late final GeneratedColumn<bool> practicalAfterTheory = GeneratedColumn<bool>(
    'practical_after_theory',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("practical_after_theory" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    syncState,
    serverSeq,
    at,
    id,
    licenseTypeId,
    effectiveFrom,
    registrationFee,
    practicalLessonPrice,
    theoryRetakeFee,
    practicalExamFee,
    plannedTheoryLessons,
    plannedPracticalLessons,
    minTheoryBeforeExam,
    minPracticalBeforeExam,
    practicalAfterTheory,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'license_prices';
  @override
  VerificationContext validateIntegrity(
    Insertable<LicensePriceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('license_type_id')) {
      context.handle(
        _licenseTypeIdMeta,
        licenseTypeId.isAcceptableOrUnknown(
          data['license_type_id']!,
          _licenseTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_licenseTypeIdMeta);
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    if (data.containsKey('registration_fee')) {
      context.handle(
        _registrationFeeMeta,
        registrationFee.isAcceptableOrUnknown(
          data['registration_fee']!,
          _registrationFeeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registrationFeeMeta);
    }
    if (data.containsKey('practical_lesson_price')) {
      context.handle(
        _practicalLessonPriceMeta,
        practicalLessonPrice.isAcceptableOrUnknown(
          data['practical_lesson_price']!,
          _practicalLessonPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_practicalLessonPriceMeta);
    }
    if (data.containsKey('theory_retake_fee')) {
      context.handle(
        _theoryRetakeFeeMeta,
        theoryRetakeFee.isAcceptableOrUnknown(
          data['theory_retake_fee']!,
          _theoryRetakeFeeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_theoryRetakeFeeMeta);
    }
    if (data.containsKey('practical_exam_fee')) {
      context.handle(
        _practicalExamFeeMeta,
        practicalExamFee.isAcceptableOrUnknown(
          data['practical_exam_fee']!,
          _practicalExamFeeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_practicalExamFeeMeta);
    }
    if (data.containsKey('planned_theory_lessons')) {
      context.handle(
        _plannedTheoryLessonsMeta,
        plannedTheoryLessons.isAcceptableOrUnknown(
          data['planned_theory_lessons']!,
          _plannedTheoryLessonsMeta,
        ),
      );
    }
    if (data.containsKey('planned_practical_lessons')) {
      context.handle(
        _plannedPracticalLessonsMeta,
        plannedPracticalLessons.isAcceptableOrUnknown(
          data['planned_practical_lessons']!,
          _plannedPracticalLessonsMeta,
        ),
      );
    }
    if (data.containsKey('min_theory_before_exam')) {
      context.handle(
        _minTheoryBeforeExamMeta,
        minTheoryBeforeExam.isAcceptableOrUnknown(
          data['min_theory_before_exam']!,
          _minTheoryBeforeExamMeta,
        ),
      );
    }
    if (data.containsKey('min_practical_before_exam')) {
      context.handle(
        _minPracticalBeforeExamMeta,
        minPracticalBeforeExam.isAcceptableOrUnknown(
          data['min_practical_before_exam']!,
          _minPracticalBeforeExamMeta,
        ),
      );
    }
    if (data.containsKey('practical_after_theory')) {
      context.handle(
        _practicalAfterTheoryMeta,
        practicalAfterTheory.isAcceptableOrUnknown(
          data['practical_after_theory']!,
          _practicalAfterTheoryMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LicensePriceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LicensePriceRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      licenseTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_type_id'],
      )!,
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_from'],
      )!,
      registrationFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}registration_fee'],
      )!,
      practicalLessonPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}practical_lesson_price'],
      )!,
      theoryRetakeFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}theory_retake_fee'],
      )!,
      practicalExamFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}practical_exam_fee'],
      )!,
      plannedTheoryLessons: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_theory_lessons'],
      )!,
      plannedPracticalLessons: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_practical_lessons'],
      )!,
      minTheoryBeforeExam: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_theory_before_exam'],
      )!,
      minPracticalBeforeExam: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_practical_before_exam'],
      )!,
      practicalAfterTheory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}practical_after_theory'],
      )!,
    );
  }

  @override
  $LicensePricesTable createAlias(String alias) {
    return $LicensePricesTable(attachedDatabase, alias);
  }
}

class LicensePriceRow extends DataClass implements Insertable<LicensePriceRow> {
  /// The op that created/changed this row (links local rows to outbox results).
  final String? opId;

  /// pending | synced | rejected
  final String syncState;
  final int? serverSeq;

  /// When it happened (ISO-8601): device time while pending, server time once synced.
  final String? at;
  final String id;
  final String licenseTypeId;
  final String effectiveFrom;
  final int registrationFee;
  final int practicalLessonPrice;
  final int theoryRetakeFee;
  final int practicalExamFee;
  final int plannedTheoryLessons;
  final int plannedPracticalLessons;
  final int minTheoryBeforeExam;
  final int minPracticalBeforeExam;
  final bool practicalAfterTheory;
  const LicensePriceRow({
    this.opId,
    required this.syncState,
    this.serverSeq,
    this.at,
    required this.id,
    required this.licenseTypeId,
    required this.effectiveFrom,
    required this.registrationFee,
    required this.practicalLessonPrice,
    required this.theoryRetakeFee,
    required this.practicalExamFee,
    required this.plannedTheoryLessons,
    required this.plannedPracticalLessons,
    required this.minTheoryBeforeExam,
    required this.minPracticalBeforeExam,
    required this.practicalAfterTheory,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || opId != null) {
      map['op_id'] = Variable<String>(opId);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    if (!nullToAbsent || at != null) {
      map['at'] = Variable<String>(at);
    }
    map['id'] = Variable<String>(id);
    map['license_type_id'] = Variable<String>(licenseTypeId);
    map['effective_from'] = Variable<String>(effectiveFrom);
    map['registration_fee'] = Variable<int>(registrationFee);
    map['practical_lesson_price'] = Variable<int>(practicalLessonPrice);
    map['theory_retake_fee'] = Variable<int>(theoryRetakeFee);
    map['practical_exam_fee'] = Variable<int>(practicalExamFee);
    map['planned_theory_lessons'] = Variable<int>(plannedTheoryLessons);
    map['planned_practical_lessons'] = Variable<int>(plannedPracticalLessons);
    map['min_theory_before_exam'] = Variable<int>(minTheoryBeforeExam);
    map['min_practical_before_exam'] = Variable<int>(minPracticalBeforeExam);
    map['practical_after_theory'] = Variable<bool>(practicalAfterTheory);
    return map;
  }

  LicensePricesCompanion toCompanion(bool nullToAbsent) {
    return LicensePricesCompanion(
      opId: opId == null && nullToAbsent ? const Value.absent() : Value(opId),
      syncState: Value(syncState),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      at: at == null && nullToAbsent ? const Value.absent() : Value(at),
      id: Value(id),
      licenseTypeId: Value(licenseTypeId),
      effectiveFrom: Value(effectiveFrom),
      registrationFee: Value(registrationFee),
      practicalLessonPrice: Value(practicalLessonPrice),
      theoryRetakeFee: Value(theoryRetakeFee),
      practicalExamFee: Value(practicalExamFee),
      plannedTheoryLessons: Value(plannedTheoryLessons),
      plannedPracticalLessons: Value(plannedPracticalLessons),
      minTheoryBeforeExam: Value(minTheoryBeforeExam),
      minPracticalBeforeExam: Value(minPracticalBeforeExam),
      practicalAfterTheory: Value(practicalAfterTheory),
    );
  }

  factory LicensePriceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LicensePriceRow(
      opId: serializer.fromJson<String?>(json['opId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      at: serializer.fromJson<String?>(json['at']),
      id: serializer.fromJson<String>(json['id']),
      licenseTypeId: serializer.fromJson<String>(json['licenseTypeId']),
      effectiveFrom: serializer.fromJson<String>(json['effectiveFrom']),
      registrationFee: serializer.fromJson<int>(json['registrationFee']),
      practicalLessonPrice: serializer.fromJson<int>(
        json['practicalLessonPrice'],
      ),
      theoryRetakeFee: serializer.fromJson<int>(json['theoryRetakeFee']),
      practicalExamFee: serializer.fromJson<int>(json['practicalExamFee']),
      plannedTheoryLessons: serializer.fromJson<int>(
        json['plannedTheoryLessons'],
      ),
      plannedPracticalLessons: serializer.fromJson<int>(
        json['plannedPracticalLessons'],
      ),
      minTheoryBeforeExam: serializer.fromJson<int>(
        json['minTheoryBeforeExam'],
      ),
      minPracticalBeforeExam: serializer.fromJson<int>(
        json['minPracticalBeforeExam'],
      ),
      practicalAfterTheory: serializer.fromJson<bool>(
        json['practicalAfterTheory'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String?>(opId),
      'syncState': serializer.toJson<String>(syncState),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'at': serializer.toJson<String?>(at),
      'id': serializer.toJson<String>(id),
      'licenseTypeId': serializer.toJson<String>(licenseTypeId),
      'effectiveFrom': serializer.toJson<String>(effectiveFrom),
      'registrationFee': serializer.toJson<int>(registrationFee),
      'practicalLessonPrice': serializer.toJson<int>(practicalLessonPrice),
      'theoryRetakeFee': serializer.toJson<int>(theoryRetakeFee),
      'practicalExamFee': serializer.toJson<int>(practicalExamFee),
      'plannedTheoryLessons': serializer.toJson<int>(plannedTheoryLessons),
      'plannedPracticalLessons': serializer.toJson<int>(
        plannedPracticalLessons,
      ),
      'minTheoryBeforeExam': serializer.toJson<int>(minTheoryBeforeExam),
      'minPracticalBeforeExam': serializer.toJson<int>(minPracticalBeforeExam),
      'practicalAfterTheory': serializer.toJson<bool>(practicalAfterTheory),
    };
  }

  LicensePriceRow copyWith({
    Value<String?> opId = const Value.absent(),
    String? syncState,
    Value<int?> serverSeq = const Value.absent(),
    Value<String?> at = const Value.absent(),
    String? id,
    String? licenseTypeId,
    String? effectiveFrom,
    int? registrationFee,
    int? practicalLessonPrice,
    int? theoryRetakeFee,
    int? practicalExamFee,
    int? plannedTheoryLessons,
    int? plannedPracticalLessons,
    int? minTheoryBeforeExam,
    int? minPracticalBeforeExam,
    bool? practicalAfterTheory,
  }) => LicensePriceRow(
    opId: opId.present ? opId.value : this.opId,
    syncState: syncState ?? this.syncState,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    at: at.present ? at.value : this.at,
    id: id ?? this.id,
    licenseTypeId: licenseTypeId ?? this.licenseTypeId,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    registrationFee: registrationFee ?? this.registrationFee,
    practicalLessonPrice: practicalLessonPrice ?? this.practicalLessonPrice,
    theoryRetakeFee: theoryRetakeFee ?? this.theoryRetakeFee,
    practicalExamFee: practicalExamFee ?? this.practicalExamFee,
    plannedTheoryLessons: plannedTheoryLessons ?? this.plannedTheoryLessons,
    plannedPracticalLessons:
        plannedPracticalLessons ?? this.plannedPracticalLessons,
    minTheoryBeforeExam: minTheoryBeforeExam ?? this.minTheoryBeforeExam,
    minPracticalBeforeExam:
        minPracticalBeforeExam ?? this.minPracticalBeforeExam,
    practicalAfterTheory: practicalAfterTheory ?? this.practicalAfterTheory,
  );
  LicensePriceRow copyWithCompanion(LicensePricesCompanion data) {
    return LicensePriceRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      at: data.at.present ? data.at.value : this.at,
      id: data.id.present ? data.id.value : this.id,
      licenseTypeId: data.licenseTypeId.present
          ? data.licenseTypeId.value
          : this.licenseTypeId,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
      registrationFee: data.registrationFee.present
          ? data.registrationFee.value
          : this.registrationFee,
      practicalLessonPrice: data.practicalLessonPrice.present
          ? data.practicalLessonPrice.value
          : this.practicalLessonPrice,
      theoryRetakeFee: data.theoryRetakeFee.present
          ? data.theoryRetakeFee.value
          : this.theoryRetakeFee,
      practicalExamFee: data.practicalExamFee.present
          ? data.practicalExamFee.value
          : this.practicalExamFee,
      plannedTheoryLessons: data.plannedTheoryLessons.present
          ? data.plannedTheoryLessons.value
          : this.plannedTheoryLessons,
      plannedPracticalLessons: data.plannedPracticalLessons.present
          ? data.plannedPracticalLessons.value
          : this.plannedPracticalLessons,
      minTheoryBeforeExam: data.minTheoryBeforeExam.present
          ? data.minTheoryBeforeExam.value
          : this.minTheoryBeforeExam,
      minPracticalBeforeExam: data.minPracticalBeforeExam.present
          ? data.minPracticalBeforeExam.value
          : this.minPracticalBeforeExam,
      practicalAfterTheory: data.practicalAfterTheory.present
          ? data.practicalAfterTheory.value
          : this.practicalAfterTheory,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LicensePriceRow(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('licenseTypeId: $licenseTypeId, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('registrationFee: $registrationFee, ')
          ..write('practicalLessonPrice: $practicalLessonPrice, ')
          ..write('theoryRetakeFee: $theoryRetakeFee, ')
          ..write('practicalExamFee: $practicalExamFee, ')
          ..write('plannedTheoryLessons: $plannedTheoryLessons, ')
          ..write('plannedPracticalLessons: $plannedPracticalLessons, ')
          ..write('minTheoryBeforeExam: $minTheoryBeforeExam, ')
          ..write('minPracticalBeforeExam: $minPracticalBeforeExam, ')
          ..write('practicalAfterTheory: $practicalAfterTheory')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    syncState,
    serverSeq,
    at,
    id,
    licenseTypeId,
    effectiveFrom,
    registrationFee,
    practicalLessonPrice,
    theoryRetakeFee,
    practicalExamFee,
    plannedTheoryLessons,
    plannedPracticalLessons,
    minTheoryBeforeExam,
    minPracticalBeforeExam,
    practicalAfterTheory,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LicensePriceRow &&
          other.opId == this.opId &&
          other.syncState == this.syncState &&
          other.serverSeq == this.serverSeq &&
          other.at == this.at &&
          other.id == this.id &&
          other.licenseTypeId == this.licenseTypeId &&
          other.effectiveFrom == this.effectiveFrom &&
          other.registrationFee == this.registrationFee &&
          other.practicalLessonPrice == this.practicalLessonPrice &&
          other.theoryRetakeFee == this.theoryRetakeFee &&
          other.practicalExamFee == this.practicalExamFee &&
          other.plannedTheoryLessons == this.plannedTheoryLessons &&
          other.plannedPracticalLessons == this.plannedPracticalLessons &&
          other.minTheoryBeforeExam == this.minTheoryBeforeExam &&
          other.minPracticalBeforeExam == this.minPracticalBeforeExam &&
          other.practicalAfterTheory == this.practicalAfterTheory);
}

class LicensePricesCompanion extends UpdateCompanion<LicensePriceRow> {
  final Value<String?> opId;
  final Value<String> syncState;
  final Value<int?> serverSeq;
  final Value<String?> at;
  final Value<String> id;
  final Value<String> licenseTypeId;
  final Value<String> effectiveFrom;
  final Value<int> registrationFee;
  final Value<int> practicalLessonPrice;
  final Value<int> theoryRetakeFee;
  final Value<int> practicalExamFee;
  final Value<int> plannedTheoryLessons;
  final Value<int> plannedPracticalLessons;
  final Value<int> minTheoryBeforeExam;
  final Value<int> minPracticalBeforeExam;
  final Value<bool> practicalAfterTheory;
  final Value<int> rowid;
  const LicensePricesCompanion({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    this.id = const Value.absent(),
    this.licenseTypeId = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.registrationFee = const Value.absent(),
    this.practicalLessonPrice = const Value.absent(),
    this.theoryRetakeFee = const Value.absent(),
    this.practicalExamFee = const Value.absent(),
    this.plannedTheoryLessons = const Value.absent(),
    this.plannedPracticalLessons = const Value.absent(),
    this.minTheoryBeforeExam = const Value.absent(),
    this.minPracticalBeforeExam = const Value.absent(),
    this.practicalAfterTheory = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LicensePricesCompanion.insert({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    required String id,
    required String licenseTypeId,
    required String effectiveFrom,
    required int registrationFee,
    required int practicalLessonPrice,
    required int theoryRetakeFee,
    required int practicalExamFee,
    this.plannedTheoryLessons = const Value.absent(),
    this.plannedPracticalLessons = const Value.absent(),
    this.minTheoryBeforeExam = const Value.absent(),
    this.minPracticalBeforeExam = const Value.absent(),
    this.practicalAfterTheory = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       licenseTypeId = Value(licenseTypeId),
       effectiveFrom = Value(effectiveFrom),
       registrationFee = Value(registrationFee),
       practicalLessonPrice = Value(practicalLessonPrice),
       theoryRetakeFee = Value(theoryRetakeFee),
       practicalExamFee = Value(practicalExamFee);
  static Insertable<LicensePriceRow> custom({
    Expression<String>? opId,
    Expression<String>? syncState,
    Expression<int>? serverSeq,
    Expression<String>? at,
    Expression<String>? id,
    Expression<String>? licenseTypeId,
    Expression<String>? effectiveFrom,
    Expression<int>? registrationFee,
    Expression<int>? practicalLessonPrice,
    Expression<int>? theoryRetakeFee,
    Expression<int>? practicalExamFee,
    Expression<int>? plannedTheoryLessons,
    Expression<int>? plannedPracticalLessons,
    Expression<int>? minTheoryBeforeExam,
    Expression<int>? minPracticalBeforeExam,
    Expression<bool>? practicalAfterTheory,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (syncState != null) 'sync_state': syncState,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (at != null) 'at': at,
      if (id != null) 'id': id,
      if (licenseTypeId != null) 'license_type_id': licenseTypeId,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (registrationFee != null) 'registration_fee': registrationFee,
      if (practicalLessonPrice != null)
        'practical_lesson_price': practicalLessonPrice,
      if (theoryRetakeFee != null) 'theory_retake_fee': theoryRetakeFee,
      if (practicalExamFee != null) 'practical_exam_fee': practicalExamFee,
      if (plannedTheoryLessons != null)
        'planned_theory_lessons': plannedTheoryLessons,
      if (plannedPracticalLessons != null)
        'planned_practical_lessons': plannedPracticalLessons,
      if (minTheoryBeforeExam != null)
        'min_theory_before_exam': minTheoryBeforeExam,
      if (minPracticalBeforeExam != null)
        'min_practical_before_exam': minPracticalBeforeExam,
      if (practicalAfterTheory != null)
        'practical_after_theory': practicalAfterTheory,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LicensePricesCompanion copyWith({
    Value<String?>? opId,
    Value<String>? syncState,
    Value<int?>? serverSeq,
    Value<String?>? at,
    Value<String>? id,
    Value<String>? licenseTypeId,
    Value<String>? effectiveFrom,
    Value<int>? registrationFee,
    Value<int>? practicalLessonPrice,
    Value<int>? theoryRetakeFee,
    Value<int>? practicalExamFee,
    Value<int>? plannedTheoryLessons,
    Value<int>? plannedPracticalLessons,
    Value<int>? minTheoryBeforeExam,
    Value<int>? minPracticalBeforeExam,
    Value<bool>? practicalAfterTheory,
    Value<int>? rowid,
  }) {
    return LicensePricesCompanion(
      opId: opId ?? this.opId,
      syncState: syncState ?? this.syncState,
      serverSeq: serverSeq ?? this.serverSeq,
      at: at ?? this.at,
      id: id ?? this.id,
      licenseTypeId: licenseTypeId ?? this.licenseTypeId,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      registrationFee: registrationFee ?? this.registrationFee,
      practicalLessonPrice: practicalLessonPrice ?? this.practicalLessonPrice,
      theoryRetakeFee: theoryRetakeFee ?? this.theoryRetakeFee,
      practicalExamFee: practicalExamFee ?? this.practicalExamFee,
      plannedTheoryLessons: plannedTheoryLessons ?? this.plannedTheoryLessons,
      plannedPracticalLessons:
          plannedPracticalLessons ?? this.plannedPracticalLessons,
      minTheoryBeforeExam: minTheoryBeforeExam ?? this.minTheoryBeforeExam,
      minPracticalBeforeExam:
          minPracticalBeforeExam ?? this.minPracticalBeforeExam,
      practicalAfterTheory: practicalAfterTheory ?? this.practicalAfterTheory,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (licenseTypeId.present) {
      map['license_type_id'] = Variable<String>(licenseTypeId.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<String>(effectiveFrom.value);
    }
    if (registrationFee.present) {
      map['registration_fee'] = Variable<int>(registrationFee.value);
    }
    if (practicalLessonPrice.present) {
      map['practical_lesson_price'] = Variable<int>(practicalLessonPrice.value);
    }
    if (theoryRetakeFee.present) {
      map['theory_retake_fee'] = Variable<int>(theoryRetakeFee.value);
    }
    if (practicalExamFee.present) {
      map['practical_exam_fee'] = Variable<int>(practicalExamFee.value);
    }
    if (plannedTheoryLessons.present) {
      map['planned_theory_lessons'] = Variable<int>(plannedTheoryLessons.value);
    }
    if (plannedPracticalLessons.present) {
      map['planned_practical_lessons'] = Variable<int>(
        plannedPracticalLessons.value,
      );
    }
    if (minTheoryBeforeExam.present) {
      map['min_theory_before_exam'] = Variable<int>(minTheoryBeforeExam.value);
    }
    if (minPracticalBeforeExam.present) {
      map['min_practical_before_exam'] = Variable<int>(
        minPracticalBeforeExam.value,
      );
    }
    if (practicalAfterTheory.present) {
      map['practical_after_theory'] = Variable<bool>(
        practicalAfterTheory.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LicensePricesCompanion(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('licenseTypeId: $licenseTypeId, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('registrationFee: $registrationFee, ')
          ..write('practicalLessonPrice: $practicalLessonPrice, ')
          ..write('theoryRetakeFee: $theoryRetakeFee, ')
          ..write('practicalExamFee: $practicalExamFee, ')
          ..write('plannedTheoryLessons: $plannedTheoryLessons, ')
          ..write('plannedPracticalLessons: $plannedPracticalLessons, ')
          ..write('minTheoryBeforeExam: $minTheoryBeforeExam, ')
          ..write('minPracticalBeforeExam: $minPracticalBeforeExam, ')
          ..write('practicalAfterTheory: $practicalAfterTheory, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudentSummariesTable extends StudentSummaries
    with TableInfo<$StudentSummariesTable, StudentSummaryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentSummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _enrollmentIdMeta = const VerificationMeta(
    'enrollmentId',
  );
  @override
  late final GeneratedColumn<String> enrollmentId = GeneratedColumn<String>(
    'enrollment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chargedMeta = const VerificationMeta(
    'charged',
  );
  @override
  late final GeneratedColumn<int> charged = GeneratedColumn<int>(
    'charged',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paidMeta = const VerificationMeta('paid');
  @override
  late final GeneratedColumn<int> paid = GeneratedColumn<int>(
    'paid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discountsMeta = const VerificationMeta(
    'discounts',
  );
  @override
  late final GeneratedColumn<int> discounts = GeneratedColumn<int>(
    'discounts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _theoryLessonsMeta = const VerificationMeta(
    'theoryLessons',
  );
  @override
  late final GeneratedColumn<int> theoryLessons = GeneratedColumn<int>(
    'theory_lessons',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _practicalLessonsMeta = const VerificationMeta(
    'practicalLessons',
  );
  @override
  late final GeneratedColumn<int> practicalLessons = GeneratedColumn<int>(
    'practical_lessons',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    enrollmentId,
    studentId,
    charged,
    paid,
    discounts,
    theoryLessons,
    practicalLessons,
    serverSeq,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'student_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudentSummaryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('enrollment_id')) {
      context.handle(
        _enrollmentIdMeta,
        enrollmentId.isAcceptableOrUnknown(
          data['enrollment_id']!,
          _enrollmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_enrollmentIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('charged')) {
      context.handle(
        _chargedMeta,
        charged.isAcceptableOrUnknown(data['charged']!, _chargedMeta),
      );
    }
    if (data.containsKey('paid')) {
      context.handle(
        _paidMeta,
        paid.isAcceptableOrUnknown(data['paid']!, _paidMeta),
      );
    }
    if (data.containsKey('discounts')) {
      context.handle(
        _discountsMeta,
        discounts.isAcceptableOrUnknown(data['discounts']!, _discountsMeta),
      );
    }
    if (data.containsKey('theory_lessons')) {
      context.handle(
        _theoryLessonsMeta,
        theoryLessons.isAcceptableOrUnknown(
          data['theory_lessons']!,
          _theoryLessonsMeta,
        ),
      );
    }
    if (data.containsKey('practical_lessons')) {
      context.handle(
        _practicalLessonsMeta,
        practicalLessons.isAcceptableOrUnknown(
          data['practical_lessons']!,
          _practicalLessonsMeta,
        ),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {enrollmentId};
  @override
  StudentSummaryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentSummaryRow(
      enrollmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enrollment_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      charged: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}charged'],
      )!,
      paid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid'],
      )!,
      discounts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discounts'],
      )!,
      theoryLessons: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}theory_lessons'],
      )!,
      practicalLessons: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}practical_lessons'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
    );
  }

  @override
  $StudentSummariesTable createAlias(String alias) {
    return $StudentSummariesTable(attachedDatabase, alias);
  }
}

class StudentSummaryRow extends DataClass
    implements Insertable<StudentSummaryRow> {
  final String enrollmentId;
  final String studentId;
  final int charged;
  final int paid;
  final int discounts;
  final int theoryLessons;
  final int practicalLessons;

  /// Summary reflects every server change up to this sequence.
  final int serverSeq;
  const StudentSummaryRow({
    required this.enrollmentId,
    required this.studentId,
    required this.charged,
    required this.paid,
    required this.discounts,
    required this.theoryLessons,
    required this.practicalLessons,
    required this.serverSeq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['enrollment_id'] = Variable<String>(enrollmentId);
    map['student_id'] = Variable<String>(studentId);
    map['charged'] = Variable<int>(charged);
    map['paid'] = Variable<int>(paid);
    map['discounts'] = Variable<int>(discounts);
    map['theory_lessons'] = Variable<int>(theoryLessons);
    map['practical_lessons'] = Variable<int>(practicalLessons);
    map['server_seq'] = Variable<int>(serverSeq);
    return map;
  }

  StudentSummariesCompanion toCompanion(bool nullToAbsent) {
    return StudentSummariesCompanion(
      enrollmentId: Value(enrollmentId),
      studentId: Value(studentId),
      charged: Value(charged),
      paid: Value(paid),
      discounts: Value(discounts),
      theoryLessons: Value(theoryLessons),
      practicalLessons: Value(practicalLessons),
      serverSeq: Value(serverSeq),
    );
  }

  factory StudentSummaryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudentSummaryRow(
      enrollmentId: serializer.fromJson<String>(json['enrollmentId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      charged: serializer.fromJson<int>(json['charged']),
      paid: serializer.fromJson<int>(json['paid']),
      discounts: serializer.fromJson<int>(json['discounts']),
      theoryLessons: serializer.fromJson<int>(json['theoryLessons']),
      practicalLessons: serializer.fromJson<int>(json['practicalLessons']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'enrollmentId': serializer.toJson<String>(enrollmentId),
      'studentId': serializer.toJson<String>(studentId),
      'charged': serializer.toJson<int>(charged),
      'paid': serializer.toJson<int>(paid),
      'discounts': serializer.toJson<int>(discounts),
      'theoryLessons': serializer.toJson<int>(theoryLessons),
      'practicalLessons': serializer.toJson<int>(practicalLessons),
      'serverSeq': serializer.toJson<int>(serverSeq),
    };
  }

  StudentSummaryRow copyWith({
    String? enrollmentId,
    String? studentId,
    int? charged,
    int? paid,
    int? discounts,
    int? theoryLessons,
    int? practicalLessons,
    int? serverSeq,
  }) => StudentSummaryRow(
    enrollmentId: enrollmentId ?? this.enrollmentId,
    studentId: studentId ?? this.studentId,
    charged: charged ?? this.charged,
    paid: paid ?? this.paid,
    discounts: discounts ?? this.discounts,
    theoryLessons: theoryLessons ?? this.theoryLessons,
    practicalLessons: practicalLessons ?? this.practicalLessons,
    serverSeq: serverSeq ?? this.serverSeq,
  );
  StudentSummaryRow copyWithCompanion(StudentSummariesCompanion data) {
    return StudentSummaryRow(
      enrollmentId: data.enrollmentId.present
          ? data.enrollmentId.value
          : this.enrollmentId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      charged: data.charged.present ? data.charged.value : this.charged,
      paid: data.paid.present ? data.paid.value : this.paid,
      discounts: data.discounts.present ? data.discounts.value : this.discounts,
      theoryLessons: data.theoryLessons.present
          ? data.theoryLessons.value
          : this.theoryLessons,
      practicalLessons: data.practicalLessons.present
          ? data.practicalLessons.value
          : this.practicalLessons,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudentSummaryRow(')
          ..write('enrollmentId: $enrollmentId, ')
          ..write('studentId: $studentId, ')
          ..write('charged: $charged, ')
          ..write('paid: $paid, ')
          ..write('discounts: $discounts, ')
          ..write('theoryLessons: $theoryLessons, ')
          ..write('practicalLessons: $practicalLessons, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    enrollmentId,
    studentId,
    charged,
    paid,
    discounts,
    theoryLessons,
    practicalLessons,
    serverSeq,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudentSummaryRow &&
          other.enrollmentId == this.enrollmentId &&
          other.studentId == this.studentId &&
          other.charged == this.charged &&
          other.paid == this.paid &&
          other.discounts == this.discounts &&
          other.theoryLessons == this.theoryLessons &&
          other.practicalLessons == this.practicalLessons &&
          other.serverSeq == this.serverSeq);
}

class StudentSummariesCompanion extends UpdateCompanion<StudentSummaryRow> {
  final Value<String> enrollmentId;
  final Value<String> studentId;
  final Value<int> charged;
  final Value<int> paid;
  final Value<int> discounts;
  final Value<int> theoryLessons;
  final Value<int> practicalLessons;
  final Value<int> serverSeq;
  final Value<int> rowid;
  const StudentSummariesCompanion({
    this.enrollmentId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.charged = const Value.absent(),
    this.paid = const Value.absent(),
    this.discounts = const Value.absent(),
    this.theoryLessons = const Value.absent(),
    this.practicalLessons = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentSummariesCompanion.insert({
    required String enrollmentId,
    required String studentId,
    this.charged = const Value.absent(),
    this.paid = const Value.absent(),
    this.discounts = const Value.absent(),
    this.theoryLessons = const Value.absent(),
    this.practicalLessons = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : enrollmentId = Value(enrollmentId),
       studentId = Value(studentId);
  static Insertable<StudentSummaryRow> custom({
    Expression<String>? enrollmentId,
    Expression<String>? studentId,
    Expression<int>? charged,
    Expression<int>? paid,
    Expression<int>? discounts,
    Expression<int>? theoryLessons,
    Expression<int>? practicalLessons,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (enrollmentId != null) 'enrollment_id': enrollmentId,
      if (studentId != null) 'student_id': studentId,
      if (charged != null) 'charged': charged,
      if (paid != null) 'paid': paid,
      if (discounts != null) 'discounts': discounts,
      if (theoryLessons != null) 'theory_lessons': theoryLessons,
      if (practicalLessons != null) 'practical_lessons': practicalLessons,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentSummariesCompanion copyWith({
    Value<String>? enrollmentId,
    Value<String>? studentId,
    Value<int>? charged,
    Value<int>? paid,
    Value<int>? discounts,
    Value<int>? theoryLessons,
    Value<int>? practicalLessons,
    Value<int>? serverSeq,
    Value<int>? rowid,
  }) {
    return StudentSummariesCompanion(
      enrollmentId: enrollmentId ?? this.enrollmentId,
      studentId: studentId ?? this.studentId,
      charged: charged ?? this.charged,
      paid: paid ?? this.paid,
      discounts: discounts ?? this.discounts,
      theoryLessons: theoryLessons ?? this.theoryLessons,
      practicalLessons: practicalLessons ?? this.practicalLessons,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (enrollmentId.present) {
      map['enrollment_id'] = Variable<String>(enrollmentId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (charged.present) {
      map['charged'] = Variable<int>(charged.value);
    }
    if (paid.present) {
      map['paid'] = Variable<int>(paid.value);
    }
    if (discounts.present) {
      map['discounts'] = Variable<int>(discounts.value);
    }
    if (theoryLessons.present) {
      map['theory_lessons'] = Variable<int>(theoryLessons.value);
    }
    if (practicalLessons.present) {
      map['practical_lessons'] = Variable<int>(practicalLessons.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentSummariesCompanion(')
          ..write('enrollmentId: $enrollmentId, ')
          ..write('studentId: $studentId, ')
          ..write('charged: $charged, ')
          ..write('paid: $paid, ')
          ..write('discounts: $discounts, ')
          ..write('theoryLessons: $theoryLessons, ')
          ..write('practicalLessons: $practicalLessons, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxOpsTable extends OutboxOps
    with TableInfo<$OutboxOpsTable, OutboxOpRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceSeqMeta = const VerificationMeta(
    'deviceSeq',
  );
  @override
  late final GeneratedColumn<int> deviceSeq = GeneratedColumn<int>(
    'device_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceTimeMeta = const VerificationMeta(
    'deviceTime',
  );
  @override
  late final GeneratedColumn<String> deviceTime = GeneratedColumn<String>(
    'device_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    type,
    payloadJson,
    deviceSeq,
    deviceTime,
    userId,
    attempts,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxOpRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('device_seq')) {
      context.handle(
        _deviceSeqMeta,
        deviceSeq.isAcceptableOrUnknown(data['device_seq']!, _deviceSeqMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceSeqMeta);
    }
    if (data.containsKey('device_time')) {
      context.handle(
        _deviceTimeMeta,
        deviceTime.isAcceptableOrUnknown(data['device_time']!, _deviceTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceTimeMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opId};
  @override
  OutboxOpRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxOpRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      deviceSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_seq'],
      )!,
      deviceTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_time'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $OutboxOpsTable createAlias(String alias) {
    return $OutboxOpsTable(attachedDatabase, alias);
  }
}

class OutboxOpRow extends DataClass implements Insertable<OutboxOpRow> {
  final String opId;
  final String type;
  final String payloadJson;
  final int deviceSeq;
  final String deviceTime;
  final String userId;
  final int attempts;
  final String? lastError;
  const OutboxOpRow({
    required this.opId,
    required this.type,
    required this.payloadJson,
    required this.deviceSeq,
    required this.deviceTime,
    required this.userId,
    required this.attempts,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_id'] = Variable<String>(opId);
    map['type'] = Variable<String>(type);
    map['payload_json'] = Variable<String>(payloadJson);
    map['device_seq'] = Variable<int>(deviceSeq);
    map['device_time'] = Variable<String>(deviceTime);
    map['user_id'] = Variable<String>(userId);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  OutboxOpsCompanion toCompanion(bool nullToAbsent) {
    return OutboxOpsCompanion(
      opId: Value(opId),
      type: Value(type),
      payloadJson: Value(payloadJson),
      deviceSeq: Value(deviceSeq),
      deviceTime: Value(deviceTime),
      userId: Value(userId),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory OutboxOpRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxOpRow(
      opId: serializer.fromJson<String>(json['opId']),
      type: serializer.fromJson<String>(json['type']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      deviceSeq: serializer.fromJson<int>(json['deviceSeq']),
      deviceTime: serializer.fromJson<String>(json['deviceTime']),
      userId: serializer.fromJson<String>(json['userId']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String>(opId),
      'type': serializer.toJson<String>(type),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'deviceSeq': serializer.toJson<int>(deviceSeq),
      'deviceTime': serializer.toJson<String>(deviceTime),
      'userId': serializer.toJson<String>(userId),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  OutboxOpRow copyWith({
    String? opId,
    String? type,
    String? payloadJson,
    int? deviceSeq,
    String? deviceTime,
    String? userId,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
  }) => OutboxOpRow(
    opId: opId ?? this.opId,
    type: type ?? this.type,
    payloadJson: payloadJson ?? this.payloadJson,
    deviceSeq: deviceSeq ?? this.deviceSeq,
    deviceTime: deviceTime ?? this.deviceTime,
    userId: userId ?? this.userId,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  OutboxOpRow copyWithCompanion(OutboxOpsCompanion data) {
    return OutboxOpRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      type: data.type.present ? data.type.value : this.type,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      deviceSeq: data.deviceSeq.present ? data.deviceSeq.value : this.deviceSeq,
      deviceTime: data.deviceTime.present
          ? data.deviceTime.value
          : this.deviceTime,
      userId: data.userId.present ? data.userId.value : this.userId,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxOpRow(')
          ..write('opId: $opId, ')
          ..write('type: $type, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('deviceSeq: $deviceSeq, ')
          ..write('deviceTime: $deviceTime, ')
          ..write('userId: $userId, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    type,
    payloadJson,
    deviceSeq,
    deviceTime,
    userId,
    attempts,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxOpRow &&
          other.opId == this.opId &&
          other.type == this.type &&
          other.payloadJson == this.payloadJson &&
          other.deviceSeq == this.deviceSeq &&
          other.deviceTime == this.deviceTime &&
          other.userId == this.userId &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class OutboxOpsCompanion extends UpdateCompanion<OutboxOpRow> {
  final Value<String> opId;
  final Value<String> type;
  final Value<String> payloadJson;
  final Value<int> deviceSeq;
  final Value<String> deviceTime;
  final Value<String> userId;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<int> rowid;
  const OutboxOpsCompanion({
    this.opId = const Value.absent(),
    this.type = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.deviceSeq = const Value.absent(),
    this.deviceTime = const Value.absent(),
    this.userId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxOpsCompanion.insert({
    required String opId,
    required String type,
    required String payloadJson,
    required int deviceSeq,
    required String deviceTime,
    required String userId,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : opId = Value(opId),
       type = Value(type),
       payloadJson = Value(payloadJson),
       deviceSeq = Value(deviceSeq),
       deviceTime = Value(deviceTime),
       userId = Value(userId);
  static Insertable<OutboxOpRow> custom({
    Expression<String>? opId,
    Expression<String>? type,
    Expression<String>? payloadJson,
    Expression<int>? deviceSeq,
    Expression<String>? deviceTime,
    Expression<String>? userId,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (type != null) 'type': type,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (deviceSeq != null) 'device_seq': deviceSeq,
      if (deviceTime != null) 'device_time': deviceTime,
      if (userId != null) 'user_id': userId,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxOpsCompanion copyWith({
    Value<String>? opId,
    Value<String>? type,
    Value<String>? payloadJson,
    Value<int>? deviceSeq,
    Value<String>? deviceTime,
    Value<String>? userId,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return OutboxOpsCompanion(
      opId: opId ?? this.opId,
      type: type ?? this.type,
      payloadJson: payloadJson ?? this.payloadJson,
      deviceSeq: deviceSeq ?? this.deviceSeq,
      deviceTime: deviceTime ?? this.deviceTime,
      userId: userId ?? this.userId,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (deviceSeq.present) {
      map['device_seq'] = Variable<int>(deviceSeq.value);
    }
    if (deviceTime.present) {
      map['device_time'] = Variable<String>(deviceTime.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxOpsCompanion(')
          ..write('opId: $opId, ')
          ..write('type: $type, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('deviceSeq: $deviceSeq, ')
          ..write('deviceTime: $deviceTime, ')
          ..write('userId: $userId, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RejectedOpsTable extends RejectedOps
    with TableInfo<$RejectedOpsTable, RejectedOpRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RejectedOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rejectedAtMeta = const VerificationMeta(
    'rejectedAt',
  );
  @override
  late final GeneratedColumn<String> rejectedAt = GeneratedColumn<String>(
    'rejected_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    type,
    payloadJson,
    reason,
    message,
    rejectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rejected_ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<RejectedOpRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('rejected_at')) {
      context.handle(
        _rejectedAtMeta,
        rejectedAt.isAcceptableOrUnknown(data['rejected_at']!, _rejectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_rejectedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opId};
  @override
  RejectedOpRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RejectedOpRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      rejectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rejected_at'],
      )!,
    );
  }

  @override
  $RejectedOpsTable createAlias(String alias) {
    return $RejectedOpsTable(attachedDatabase, alias);
  }
}

class RejectedOpRow extends DataClass implements Insertable<RejectedOpRow> {
  final String opId;
  final String type;
  final String payloadJson;
  final String reason;
  final String message;
  final String rejectedAt;
  const RejectedOpRow({
    required this.opId,
    required this.type,
    required this.payloadJson,
    required this.reason,
    required this.message,
    required this.rejectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_id'] = Variable<String>(opId);
    map['type'] = Variable<String>(type);
    map['payload_json'] = Variable<String>(payloadJson);
    map['reason'] = Variable<String>(reason);
    map['message'] = Variable<String>(message);
    map['rejected_at'] = Variable<String>(rejectedAt);
    return map;
  }

  RejectedOpsCompanion toCompanion(bool nullToAbsent) {
    return RejectedOpsCompanion(
      opId: Value(opId),
      type: Value(type),
      payloadJson: Value(payloadJson),
      reason: Value(reason),
      message: Value(message),
      rejectedAt: Value(rejectedAt),
    );
  }

  factory RejectedOpRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RejectedOpRow(
      opId: serializer.fromJson<String>(json['opId']),
      type: serializer.fromJson<String>(json['type']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      reason: serializer.fromJson<String>(json['reason']),
      message: serializer.fromJson<String>(json['message']),
      rejectedAt: serializer.fromJson<String>(json['rejectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String>(opId),
      'type': serializer.toJson<String>(type),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'reason': serializer.toJson<String>(reason),
      'message': serializer.toJson<String>(message),
      'rejectedAt': serializer.toJson<String>(rejectedAt),
    };
  }

  RejectedOpRow copyWith({
    String? opId,
    String? type,
    String? payloadJson,
    String? reason,
    String? message,
    String? rejectedAt,
  }) => RejectedOpRow(
    opId: opId ?? this.opId,
    type: type ?? this.type,
    payloadJson: payloadJson ?? this.payloadJson,
    reason: reason ?? this.reason,
    message: message ?? this.message,
    rejectedAt: rejectedAt ?? this.rejectedAt,
  );
  RejectedOpRow copyWithCompanion(RejectedOpsCompanion data) {
    return RejectedOpRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      type: data.type.present ? data.type.value : this.type,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      reason: data.reason.present ? data.reason.value : this.reason,
      message: data.message.present ? data.message.value : this.message,
      rejectedAt: data.rejectedAt.present
          ? data.rejectedAt.value
          : this.rejectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RejectedOpRow(')
          ..write('opId: $opId, ')
          ..write('type: $type, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('reason: $reason, ')
          ..write('message: $message, ')
          ..write('rejectedAt: $rejectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(opId, type, payloadJson, reason, message, rejectedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RejectedOpRow &&
          other.opId == this.opId &&
          other.type == this.type &&
          other.payloadJson == this.payloadJson &&
          other.reason == this.reason &&
          other.message == this.message &&
          other.rejectedAt == this.rejectedAt);
}

class RejectedOpsCompanion extends UpdateCompanion<RejectedOpRow> {
  final Value<String> opId;
  final Value<String> type;
  final Value<String> payloadJson;
  final Value<String> reason;
  final Value<String> message;
  final Value<String> rejectedAt;
  final Value<int> rowid;
  const RejectedOpsCompanion({
    this.opId = const Value.absent(),
    this.type = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.reason = const Value.absent(),
    this.message = const Value.absent(),
    this.rejectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RejectedOpsCompanion.insert({
    required String opId,
    required String type,
    required String payloadJson,
    required String reason,
    required String message,
    required String rejectedAt,
    this.rowid = const Value.absent(),
  }) : opId = Value(opId),
       type = Value(type),
       payloadJson = Value(payloadJson),
       reason = Value(reason),
       message = Value(message),
       rejectedAt = Value(rejectedAt);
  static Insertable<RejectedOpRow> custom({
    Expression<String>? opId,
    Expression<String>? type,
    Expression<String>? payloadJson,
    Expression<String>? reason,
    Expression<String>? message,
    Expression<String>? rejectedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (type != null) 'type': type,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (reason != null) 'reason': reason,
      if (message != null) 'message': message,
      if (rejectedAt != null) 'rejected_at': rejectedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RejectedOpsCompanion copyWith({
    Value<String>? opId,
    Value<String>? type,
    Value<String>? payloadJson,
    Value<String>? reason,
    Value<String>? message,
    Value<String>? rejectedAt,
    Value<int>? rowid,
  }) {
    return RejectedOpsCompanion(
      opId: opId ?? this.opId,
      type: type ?? this.type,
      payloadJson: payloadJson ?? this.payloadJson,
      reason: reason ?? this.reason,
      message: message ?? this.message,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (rejectedAt.present) {
      map['rejected_at'] = Variable<String>(rejectedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RejectedOpsCompanion(')
          ..write('opId: $opId, ')
          ..write('type: $type, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('reason: $reason, ')
          ..write('message: $message, ')
          ..write('rejectedAt: $rejectedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectionMeta = const VerificationMeta(
    'collection',
  );
  @override
  late final GeneratedColumn<String> collection = GeneratedColumn<String>(
    'collection',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeqMeta = const VerificationMeta(
    'lastSeq',
  );
  @override
  late final GeneratedColumn<int> lastSeq = GeneratedColumn<int>(
    'last_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [collection, lastSeq];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collection')) {
      context.handle(
        _collectionMeta,
        collection.isAcceptableOrUnknown(data['collection']!, _collectionMeta),
      );
    } else if (isInserting) {
      context.missing(_collectionMeta);
    }
    if (data.containsKey('last_seq')) {
      context.handle(
        _lastSeqMeta,
        lastSeq.isAcceptableOrUnknown(data['last_seq']!, _lastSeqMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collection};
  @override
  SyncCursorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursorRow(
      collection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection'],
      )!,
      lastSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seq'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursorRow extends DataClass implements Insertable<SyncCursorRow> {
  final String collection;
  final int lastSeq;
  const SyncCursorRow({required this.collection, required this.lastSeq});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collection'] = Variable<String>(collection);
    map['last_seq'] = Variable<int>(lastSeq);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      collection: Value(collection),
      lastSeq: Value(lastSeq),
    );
  }

  factory SyncCursorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursorRow(
      collection: serializer.fromJson<String>(json['collection']),
      lastSeq: serializer.fromJson<int>(json['lastSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collection': serializer.toJson<String>(collection),
      'lastSeq': serializer.toJson<int>(lastSeq),
    };
  }

  SyncCursorRow copyWith({String? collection, int? lastSeq}) => SyncCursorRow(
    collection: collection ?? this.collection,
    lastSeq: lastSeq ?? this.lastSeq,
  );
  SyncCursorRow copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursorRow(
      collection: data.collection.present
          ? data.collection.value
          : this.collection,
      lastSeq: data.lastSeq.present ? data.lastSeq.value : this.lastSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorRow(')
          ..write('collection: $collection, ')
          ..write('lastSeq: $lastSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(collection, lastSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursorRow &&
          other.collection == this.collection &&
          other.lastSeq == this.lastSeq);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursorRow> {
  final Value<String> collection;
  final Value<int> lastSeq;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.collection = const Value.absent(),
    this.lastSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String collection,
    this.lastSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : collection = Value(collection);
  static Insertable<SyncCursorRow> custom({
    Expression<String>? collection,
    Expression<int>? lastSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collection != null) 'collection': collection,
      if (lastSeq != null) 'last_seq': lastSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? collection,
    Value<int>? lastSeq,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      collection: collection ?? this.collection,
      lastSeq: lastSeq ?? this.lastSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collection.present) {
      map['collection'] = Variable<String>(collection.value);
    }
    if (lastSeq.present) {
      map['last_seq'] = Variable<int>(lastSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('collection: $collection, ')
          ..write('lastSeq: $lastSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KvEntriesTable extends KvEntries with TableInfo<$KvEntriesTable, KvRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KvEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kv_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<KvRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KvRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $KvEntriesTable createAlias(String alias) {
    return $KvEntriesTable(attachedDatabase, alias);
  }
}

class KvRow extends DataClass implements Insertable<KvRow> {
  final String key;
  final String value;
  const KvRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  KvEntriesCompanion toCompanion(bool nullToAbsent) {
    return KvEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory KvRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  KvRow copyWith({String? key, String? value}) =>
      KvRow(key: key ?? this.key, value: value ?? this.value);
  KvRow copyWithCompanion(KvEntriesCompanion data) {
    return KvRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KvRow && other.key == this.key && other.value == this.value);
}

class KvEntriesCompanion extends UpdateCompanion<KvRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KvEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KvEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<KvRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KvEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return KvEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KvEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CarsTable extends Cars with TableInfo<$CarsTable, CarRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CarsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plateMeta = const VerificationMeta('plate');
  @override
  late final GeneratedColumn<String> plate = GeneratedColumn<String>(
    'plate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gearboxMeta = const VerificationMeta(
    'gearbox',
  );
  @override
  late final GeneratedColumn<String> gearbox = GeneratedColumn<String>(
    'gearbox',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    plate,
    active,
    serverSeq,
    gearbox,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cars';
  @override
  VerificationContext validateIntegrity(
    Insertable<CarRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('plate')) {
      context.handle(
        _plateMeta,
        plate.isAcceptableOrUnknown(data['plate']!, _plateMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('gearbox')) {
      context.handle(
        _gearboxMeta,
        gearbox.isAcceptableOrUnknown(data['gearbox']!, _gearboxMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CarRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CarRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      plate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plate'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      gearbox: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gearbox'],
      )!,
    );
  }

  @override
  $CarsTable createAlias(String alias) {
    return $CarsTable(attachedDatabase, alias);
  }
}

class CarRow extends DataClass implements Insertable<CarRow> {
  final String id;
  final String name;
  final String? plate;
  final bool active;
  final int? serverSeq;

  /// manual | auto
  final String gearbox;
  const CarRow({
    required this.id,
    required this.name,
    this.plate,
    required this.active,
    this.serverSeq,
    required this.gearbox,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || plate != null) {
      map['plate'] = Variable<String>(plate);
    }
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['gearbox'] = Variable<String>(gearbox);
    return map;
  }

  CarsCompanion toCompanion(bool nullToAbsent) {
    return CarsCompanion(
      id: Value(id),
      name: Value(name),
      plate: plate == null && nullToAbsent
          ? const Value.absent()
          : Value(plate),
      active: Value(active),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      gearbox: Value(gearbox),
    );
  }

  factory CarRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CarRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      plate: serializer.fromJson<String?>(json['plate']),
      active: serializer.fromJson<bool>(json['active']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      gearbox: serializer.fromJson<String>(json['gearbox']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'plate': serializer.toJson<String?>(plate),
      'active': serializer.toJson<bool>(active),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'gearbox': serializer.toJson<String>(gearbox),
    };
  }

  CarRow copyWith({
    String? id,
    String? name,
    Value<String?> plate = const Value.absent(),
    bool? active,
    Value<int?> serverSeq = const Value.absent(),
    String? gearbox,
  }) => CarRow(
    id: id ?? this.id,
    name: name ?? this.name,
    plate: plate.present ? plate.value : this.plate,
    active: active ?? this.active,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    gearbox: gearbox ?? this.gearbox,
  );
  CarRow copyWithCompanion(CarsCompanion data) {
    return CarRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      plate: data.plate.present ? data.plate.value : this.plate,
      active: data.active.present ? data.active.value : this.active,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      gearbox: data.gearbox.present ? data.gearbox.value : this.gearbox,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CarRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('plate: $plate, ')
          ..write('active: $active, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('gearbox: $gearbox')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, plate, active, serverSeq, gearbox);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CarRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.plate == this.plate &&
          other.active == this.active &&
          other.serverSeq == this.serverSeq &&
          other.gearbox == this.gearbox);
}

class CarsCompanion extends UpdateCompanion<CarRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> plate;
  final Value<bool> active;
  final Value<int?> serverSeq;
  final Value<String> gearbox;
  final Value<int> rowid;
  const CarsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.plate = const Value.absent(),
    this.active = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.gearbox = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CarsCompanion.insert({
    required String id,
    required String name,
    this.plate = const Value.absent(),
    this.active = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.gearbox = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CarRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? plate,
    Expression<bool>? active,
    Expression<int>? serverSeq,
    Expression<String>? gearbox,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (plate != null) 'plate': plate,
      if (active != null) 'active': active,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (gearbox != null) 'gearbox': gearbox,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CarsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? plate,
    Value<bool>? active,
    Value<int?>? serverSeq,
    Value<String>? gearbox,
    Value<int>? rowid,
  }) {
    return CarsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      plate: plate ?? this.plate,
      active: active ?? this.active,
      serverSeq: serverSeq ?? this.serverSeq,
      gearbox: gearbox ?? this.gearbox,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (plate.present) {
      map['plate'] = Variable<String>(plate.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (gearbox.present) {
      map['gearbox'] = Variable<String>(gearbox.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CarsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('plate: $plate, ')
          ..write('active: $active, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('gearbox: $gearbox, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CarInstructorsTable extends CarInstructors
    with TableInfo<$CarInstructorsTable, CarInstructorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CarInstructorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carIdMeta = const VerificationMeta('carId');
  @override
  late final GeneratedColumn<String> carId = GeneratedColumn<String>(
    'car_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromMeta = const VerificationMeta('from');
  @override
  late final GeneratedColumn<String> from = GeneratedColumn<String>(
    'from_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toMeta = const VerificationMeta('to');
  @override
  late final GeneratedColumn<String> to = GeneratedColumn<String>(
    'to_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    carId,
    employeeId,
    from,
    to,
    serverSeq,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'car_instructors';
  @override
  VerificationContext validateIntegrity(
    Insertable<CarInstructorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('car_id')) {
      context.handle(
        _carIdMeta,
        carId.isAcceptableOrUnknown(data['car_id']!, _carIdMeta),
      );
    } else if (isInserting) {
      context.missing(_carIdMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('from_date')) {
      context.handle(
        _fromMeta,
        from.isAcceptableOrUnknown(data['from_date']!, _fromMeta),
      );
    }
    if (data.containsKey('to_date')) {
      context.handle(
        _toMeta,
        to.isAcceptableOrUnknown(data['to_date']!, _toMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CarInstructorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CarInstructorRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      carId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}car_id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      )!,
      from: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_date'],
      ),
      to: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_date'],
      ),
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
    );
  }

  @override
  $CarInstructorsTable createAlias(String alias) {
    return $CarInstructorsTable(attachedDatabase, alias);
  }
}

class CarInstructorRow extends DataClass
    implements Insertable<CarInstructorRow> {
  final String id;
  final String carId;
  final String employeeId;
  final String? from;
  final String? to;
  final int? serverSeq;
  const CarInstructorRow({
    required this.id,
    required this.carId,
    required this.employeeId,
    this.from,
    this.to,
    this.serverSeq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['car_id'] = Variable<String>(carId);
    map['employee_id'] = Variable<String>(employeeId);
    if (!nullToAbsent || from != null) {
      map['from_date'] = Variable<String>(from);
    }
    if (!nullToAbsent || to != null) {
      map['to_date'] = Variable<String>(to);
    }
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    return map;
  }

  CarInstructorsCompanion toCompanion(bool nullToAbsent) {
    return CarInstructorsCompanion(
      id: Value(id),
      carId: Value(carId),
      employeeId: Value(employeeId),
      from: from == null && nullToAbsent ? const Value.absent() : Value(from),
      to: to == null && nullToAbsent ? const Value.absent() : Value(to),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
    );
  }

  factory CarInstructorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CarInstructorRow(
      id: serializer.fromJson<String>(json['id']),
      carId: serializer.fromJson<String>(json['carId']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
      from: serializer.fromJson<String?>(json['from']),
      to: serializer.fromJson<String?>(json['to']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'carId': serializer.toJson<String>(carId),
      'employeeId': serializer.toJson<String>(employeeId),
      'from': serializer.toJson<String?>(from),
      'to': serializer.toJson<String?>(to),
      'serverSeq': serializer.toJson<int?>(serverSeq),
    };
  }

  CarInstructorRow copyWith({
    String? id,
    String? carId,
    String? employeeId,
    Value<String?> from = const Value.absent(),
    Value<String?> to = const Value.absent(),
    Value<int?> serverSeq = const Value.absent(),
  }) => CarInstructorRow(
    id: id ?? this.id,
    carId: carId ?? this.carId,
    employeeId: employeeId ?? this.employeeId,
    from: from.present ? from.value : this.from,
    to: to.present ? to.value : this.to,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
  );
  CarInstructorRow copyWithCompanion(CarInstructorsCompanion data) {
    return CarInstructorRow(
      id: data.id.present ? data.id.value : this.id,
      carId: data.carId.present ? data.carId.value : this.carId,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      from: data.from.present ? data.from.value : this.from,
      to: data.to.present ? data.to.value : this.to,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CarInstructorRow(')
          ..write('id: $id, ')
          ..write('carId: $carId, ')
          ..write('employeeId: $employeeId, ')
          ..write('from: $from, ')
          ..write('to: $to, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, carId, employeeId, from, to, serverSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CarInstructorRow &&
          other.id == this.id &&
          other.carId == this.carId &&
          other.employeeId == this.employeeId &&
          other.from == this.from &&
          other.to == this.to &&
          other.serverSeq == this.serverSeq);
}

class CarInstructorsCompanion extends UpdateCompanion<CarInstructorRow> {
  final Value<String> id;
  final Value<String> carId;
  final Value<String> employeeId;
  final Value<String?> from;
  final Value<String?> to;
  final Value<int?> serverSeq;
  final Value<int> rowid;
  const CarInstructorsCompanion({
    this.id = const Value.absent(),
    this.carId = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.from = const Value.absent(),
    this.to = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CarInstructorsCompanion.insert({
    required String id,
    required String carId,
    required String employeeId,
    this.from = const Value.absent(),
    this.to = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       carId = Value(carId),
       employeeId = Value(employeeId);
  static Insertable<CarInstructorRow> custom({
    Expression<String>? id,
    Expression<String>? carId,
    Expression<String>? employeeId,
    Expression<String>? from,
    Expression<String>? to,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (carId != null) 'car_id': carId,
      if (employeeId != null) 'employee_id': employeeId,
      if (from != null) 'from_date': from,
      if (to != null) 'to_date': to,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CarInstructorsCompanion copyWith({
    Value<String>? id,
    Value<String>? carId,
    Value<String>? employeeId,
    Value<String?>? from,
    Value<String?>? to,
    Value<int?>? serverSeq,
    Value<int>? rowid,
  }) {
    return CarInstructorsCompanion(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      employeeId: employeeId ?? this.employeeId,
      from: from ?? this.from,
      to: to ?? this.to,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (carId.present) {
      map['car_id'] = Variable<String>(carId.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (from.present) {
      map['from_date'] = Variable<String>(from.value);
    }
    if (to.present) {
      map['to_date'] = Variable<String>(to.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CarInstructorsCompanion(')
          ..write('id: $id, ')
          ..write('carId: $carId, ')
          ..write('employeeId: $employeeId, ')
          ..write('from: $from, ')
          ..write('to: $to, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmployeesTable extends Employees
    with TableInfo<$EmployeesTable, EmployeeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmployeesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _salaryMeta = const VerificationMeta('salary');
  @override
  late final GeneratedColumn<int> salary = GeneratedColumn<int>(
    'salary',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    role,
    active,
    serverSeq,
    phone,
    userId,
    salary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'employees';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmployeeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('salary')) {
      context.handle(
        _salaryMeta,
        salary.isAcceptableOrUnknown(data['salary']!, _salaryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmployeeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmployeeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      salary: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}salary'],
      )!,
    );
  }

  @override
  $EmployeesTable createAlias(String alias) {
    return $EmployeesTable(attachedDatabase, alias);
  }
}

class EmployeeRow extends DataClass implements Insertable<EmployeeRow> {
  final String id;
  final String name;

  /// instructor | staff
  final String role;
  final bool active;
  final int? serverSeq;
  final String? phone;
  final String? userId;

  /// Current monthly salary (agorot); past months use [SalaryRates].
  final int salary;
  const EmployeeRow({
    required this.id,
    required this.name,
    required this.role,
    required this.active,
    this.serverSeq,
    this.phone,
    this.userId,
    required this.salary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['role'] = Variable<String>(role);
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['salary'] = Variable<int>(salary);
    return map;
  }

  EmployeesCompanion toCompanion(bool nullToAbsent) {
    return EmployeesCompanion(
      id: Value(id),
      name: Value(name),
      role: Value(role),
      active: Value(active),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      salary: Value(salary),
    );
  }

  factory EmployeeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmployeeRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      active: serializer.fromJson<bool>(json['active']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      phone: serializer.fromJson<String?>(json['phone']),
      userId: serializer.fromJson<String?>(json['userId']),
      salary: serializer.fromJson<int>(json['salary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String>(role),
      'active': serializer.toJson<bool>(active),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'phone': serializer.toJson<String?>(phone),
      'userId': serializer.toJson<String?>(userId),
      'salary': serializer.toJson<int>(salary),
    };
  }

  EmployeeRow copyWith({
    String? id,
    String? name,
    String? role,
    bool? active,
    Value<int?> serverSeq = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> userId = const Value.absent(),
    int? salary,
  }) => EmployeeRow(
    id: id ?? this.id,
    name: name ?? this.name,
    role: role ?? this.role,
    active: active ?? this.active,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    phone: phone.present ? phone.value : this.phone,
    userId: userId.present ? userId.value : this.userId,
    salary: salary ?? this.salary,
  );
  EmployeeRow copyWithCompanion(EmployeesCompanion data) {
    return EmployeeRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      active: data.active.present ? data.active.value : this.active,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      phone: data.phone.present ? data.phone.value : this.phone,
      userId: data.userId.present ? data.userId.value : this.userId,
      salary: data.salary.present ? data.salary.value : this.salary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmployeeRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('active: $active, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('phone: $phone, ')
          ..write('userId: $userId, ')
          ..write('salary: $salary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, role, active, serverSeq, phone, userId, salary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmployeeRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.role == this.role &&
          other.active == this.active &&
          other.serverSeq == this.serverSeq &&
          other.phone == this.phone &&
          other.userId == this.userId &&
          other.salary == this.salary);
}

class EmployeesCompanion extends UpdateCompanion<EmployeeRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> role;
  final Value<bool> active;
  final Value<int?> serverSeq;
  final Value<String?> phone;
  final Value<String?> userId;
  final Value<int> salary;
  final Value<int> rowid;
  const EmployeesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.active = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.phone = const Value.absent(),
    this.userId = const Value.absent(),
    this.salary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmployeesCompanion.insert({
    required String id,
    required String name,
    required String role,
    this.active = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.phone = const Value.absent(),
    this.userId = const Value.absent(),
    this.salary = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       role = Value(role);
  static Insertable<EmployeeRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? role,
    Expression<bool>? active,
    Expression<int>? serverSeq,
    Expression<String>? phone,
    Expression<String>? userId,
    Expression<int>? salary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (active != null) 'active': active,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (phone != null) 'phone': phone,
      if (userId != null) 'user_id': userId,
      if (salary != null) 'salary': salary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmployeesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? role,
    Value<bool>? active,
    Value<int?>? serverSeq,
    Value<String?>? phone,
    Value<String?>? userId,
    Value<int>? salary,
    Value<int>? rowid,
  }) {
    return EmployeesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      active: active ?? this.active,
      serverSeq: serverSeq ?? this.serverSeq,
      phone: phone ?? this.phone,
      userId: userId ?? this.userId,
      salary: salary ?? this.salary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (salary.present) {
      map['salary'] = Variable<int>(salary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmployeesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('active: $active, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('phone: $phone, ')
          ..write('userId: $userId, ')
          ..write('salary: $salary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LicenseTypesTable extends LicenseTypes
    with TableInfo<$LicenseTypesTable, LicenseTypeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LicenseTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    active,
    sortOrder,
    serverSeq,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'license_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<LicenseTypeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LicenseTypeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LicenseTypeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
    );
  }

  @override
  $LicenseTypesTable createAlias(String alias) {
    return $LicenseTypesTable(attachedDatabase, alias);
  }
}

class LicenseTypeRow extends DataClass implements Insertable<LicenseTypeRow> {
  final String id;
  final String name;
  final bool active;
  final int sortOrder;
  final int? serverSeq;
  const LicenseTypeRow({
    required this.id,
    required this.name,
    required this.active,
    required this.sortOrder,
    this.serverSeq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['active'] = Variable<bool>(active);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    return map;
  }

  LicenseTypesCompanion toCompanion(bool nullToAbsent) {
    return LicenseTypesCompanion(
      id: Value(id),
      name: Value(name),
      active: Value(active),
      sortOrder: Value(sortOrder),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
    );
  }

  factory LicenseTypeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LicenseTypeRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      active: serializer.fromJson<bool>(json['active']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'active': serializer.toJson<bool>(active),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'serverSeq': serializer.toJson<int?>(serverSeq),
    };
  }

  LicenseTypeRow copyWith({
    String? id,
    String? name,
    bool? active,
    int? sortOrder,
    Value<int?> serverSeq = const Value.absent(),
  }) => LicenseTypeRow(
    id: id ?? this.id,
    name: name ?? this.name,
    active: active ?? this.active,
    sortOrder: sortOrder ?? this.sortOrder,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
  );
  LicenseTypeRow copyWithCompanion(LicenseTypesCompanion data) {
    return LicenseTypeRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      active: data.active.present ? data.active.value : this.active,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LicenseTypeRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('active: $active, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, active, sortOrder, serverSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LicenseTypeRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.active == this.active &&
          other.sortOrder == this.sortOrder &&
          other.serverSeq == this.serverSeq);
}

class LicenseTypesCompanion extends UpdateCompanion<LicenseTypeRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> active;
  final Value<int> sortOrder;
  final Value<int?> serverSeq;
  final Value<int> rowid;
  const LicenseTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.active = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LicenseTypesCompanion.insert({
    required String id,
    required String name,
    this.active = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<LicenseTypeRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? active,
    Expression<int>? sortOrder,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (active != null) 'active': active,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LicenseTypesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? active,
    Value<int>? sortOrder,
    Value<int?>? serverSeq,
    Value<int>? rowid,
  }) {
    return LicenseTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      active: active ?? this.active,
      sortOrder: sortOrder ?? this.sortOrder,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LicenseTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('active: $active, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TreasuryAccountsTable extends TreasuryAccounts
    with TableInfo<$TreasuryAccountsTable, TreasuryAccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TreasuryAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _openingBalanceMeta = const VerificationMeta(
    'openingBalance',
  );
  @override
  late final GeneratedColumn<int> openingBalance = GeneratedColumn<int>(
    'opening_balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    active,
    openingBalance,
    serverSeq,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'treasury_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<TreasuryAccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
        _openingBalanceMeta,
        openingBalance.isAcceptableOrUnknown(
          data['opening_balance']!,
          _openingBalanceMeta,
        ),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TreasuryAccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TreasuryAccountRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      openingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
    );
  }

  @override
  $TreasuryAccountsTable createAlias(String alias) {
    return $TreasuryAccountsTable(attachedDatabase, alias);
  }
}

class TreasuryAccountRow extends DataClass
    implements Insertable<TreasuryAccountRow> {
  final String id;
  final String name;

  /// cash | wallet | bank
  final String kind;
  final bool active;
  final int openingBalance;
  final int? serverSeq;
  const TreasuryAccountRow({
    required this.id,
    required this.name,
    required this.kind,
    required this.active,
    required this.openingBalance,
    this.serverSeq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['active'] = Variable<bool>(active);
    map['opening_balance'] = Variable<int>(openingBalance);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    return map;
  }

  TreasuryAccountsCompanion toCompanion(bool nullToAbsent) {
    return TreasuryAccountsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      active: Value(active),
      openingBalance: Value(openingBalance),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
    );
  }

  factory TreasuryAccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TreasuryAccountRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      active: serializer.fromJson<bool>(json['active']),
      openingBalance: serializer.fromJson<int>(json['openingBalance']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'active': serializer.toJson<bool>(active),
      'openingBalance': serializer.toJson<int>(openingBalance),
      'serverSeq': serializer.toJson<int?>(serverSeq),
    };
  }

  TreasuryAccountRow copyWith({
    String? id,
    String? name,
    String? kind,
    bool? active,
    int? openingBalance,
    Value<int?> serverSeq = const Value.absent(),
  }) => TreasuryAccountRow(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    active: active ?? this.active,
    openingBalance: openingBalance ?? this.openingBalance,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
  );
  TreasuryAccountRow copyWithCompanion(TreasuryAccountsCompanion data) {
    return TreasuryAccountRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      active: data.active.present ? data.active.value : this.active,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TreasuryAccountRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('active: $active, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, kind, active, openingBalance, serverSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TreasuryAccountRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.active == this.active &&
          other.openingBalance == this.openingBalance &&
          other.serverSeq == this.serverSeq);
}

class TreasuryAccountsCompanion extends UpdateCompanion<TreasuryAccountRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<bool> active;
  final Value<int> openingBalance;
  final Value<int?> serverSeq;
  final Value<int> rowid;
  const TreasuryAccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.active = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TreasuryAccountsCompanion.insert({
    required String id,
    required String name,
    required String kind,
    this.active = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind);
  static Insertable<TreasuryAccountRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<bool>? active,
    Expression<int>? openingBalance,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (active != null) 'active': active,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TreasuryAccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<bool>? active,
    Value<int>? openingBalance,
    Value<int?>? serverSeq,
    Value<int>? rowid,
  }) {
    return TreasuryAccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      active: active ?? this.active,
      openingBalance: openingBalance ?? this.openingBalance,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<int>(openingBalance.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TreasuryAccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('active: $active, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses
    with TableInfo<$ExpensesTable, ExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemMeta = const VerificationMeta('item');
  @override
  late final GeneratedColumn<String> item = GeneratedColumn<String>(
    'item',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carIdMeta = const VerificationMeta('carId');
  @override
  late final GeneratedColumn<String> carId = GeneratedColumn<String>(
    'car_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _litersMeta = const VerificationMeta('liters');
  @override
  late final GeneratedColumn<int> liters = GeneratedColumn<int>(
    'liters',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reversedMeta = const VerificationMeta(
    'reversed',
  );
  @override
  late final GeneratedColumn<bool> reversed = GeneratedColumn<bool>(
    'reversed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reversed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    syncState,
    serverSeq,
    at,
    id,
    kind,
    item,
    label,
    carId,
    liters,
    studentId,
    amount,
    accountId,
    note,
    businessDate,
    reversed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('item')) {
      context.handle(
        _itemMeta,
        item.isAcceptableOrUnknown(data['item']!, _itemMeta),
      );
    } else if (isInserting) {
      context.missing(_itemMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('car_id')) {
      context.handle(
        _carIdMeta,
        carId.isAcceptableOrUnknown(data['car_id']!, _carIdMeta),
      );
    }
    if (data.containsKey('liters')) {
      context.handle(
        _litersMeta,
        liters.isAcceptableOrUnknown(data['liters']!, _litersMeta),
      );
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('reversed')) {
      context.handle(
        _reversedMeta,
        reversed.isAcceptableOrUnknown(data['reversed']!, _reversedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      item: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      carId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}car_id'],
      ),
      liters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}liters'],
      ),
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      reversed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reversed'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class ExpenseRow extends DataClass implements Insertable<ExpenseRow> {
  /// The op that created/changed this row (links local rows to outbox results).
  final String? opId;

  /// pending | synced | rejected
  final String syncState;
  final int? serverSeq;

  /// When it happened (ISO-8601): device time while pending, server time once synced.
  final String? at;
  final String id;

  /// cars | ministry | other  (salaries and advances live in Payroll)
  final String kind;
  final String item;
  final String label;
  final String? carId;
  final int? liters;
  final String? studentId;
  final int amount;
  final String accountId;
  final String? note;
  final String businessDate;
  final bool reversed;
  const ExpenseRow({
    this.opId,
    required this.syncState,
    this.serverSeq,
    this.at,
    required this.id,
    required this.kind,
    required this.item,
    required this.label,
    this.carId,
    this.liters,
    this.studentId,
    required this.amount,
    required this.accountId,
    this.note,
    required this.businessDate,
    required this.reversed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || opId != null) {
      map['op_id'] = Variable<String>(opId);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    if (!nullToAbsent || at != null) {
      map['at'] = Variable<String>(at);
    }
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['item'] = Variable<String>(item);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || carId != null) {
      map['car_id'] = Variable<String>(carId);
    }
    if (!nullToAbsent || liters != null) {
      map['liters'] = Variable<int>(liters);
    }
    if (!nullToAbsent || studentId != null) {
      map['student_id'] = Variable<String>(studentId);
    }
    map['amount'] = Variable<int>(amount);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['business_date'] = Variable<String>(businessDate);
    map['reversed'] = Variable<bool>(reversed);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      opId: opId == null && nullToAbsent ? const Value.absent() : Value(opId),
      syncState: Value(syncState),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      at: at == null && nullToAbsent ? const Value.absent() : Value(at),
      id: Value(id),
      kind: Value(kind),
      item: Value(item),
      label: Value(label),
      carId: carId == null && nullToAbsent
          ? const Value.absent()
          : Value(carId),
      liters: liters == null && nullToAbsent
          ? const Value.absent()
          : Value(liters),
      studentId: studentId == null && nullToAbsent
          ? const Value.absent()
          : Value(studentId),
      amount: Value(amount),
      accountId: Value(accountId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      businessDate: Value(businessDate),
      reversed: Value(reversed),
    );
  }

  factory ExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseRow(
      opId: serializer.fromJson<String?>(json['opId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      at: serializer.fromJson<String?>(json['at']),
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      item: serializer.fromJson<String>(json['item']),
      label: serializer.fromJson<String>(json['label']),
      carId: serializer.fromJson<String?>(json['carId']),
      liters: serializer.fromJson<int?>(json['liters']),
      studentId: serializer.fromJson<String?>(json['studentId']),
      amount: serializer.fromJson<int>(json['amount']),
      accountId: serializer.fromJson<String>(json['accountId']),
      note: serializer.fromJson<String?>(json['note']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      reversed: serializer.fromJson<bool>(json['reversed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String?>(opId),
      'syncState': serializer.toJson<String>(syncState),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'at': serializer.toJson<String?>(at),
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'item': serializer.toJson<String>(item),
      'label': serializer.toJson<String>(label),
      'carId': serializer.toJson<String?>(carId),
      'liters': serializer.toJson<int?>(liters),
      'studentId': serializer.toJson<String?>(studentId),
      'amount': serializer.toJson<int>(amount),
      'accountId': serializer.toJson<String>(accountId),
      'note': serializer.toJson<String?>(note),
      'businessDate': serializer.toJson<String>(businessDate),
      'reversed': serializer.toJson<bool>(reversed),
    };
  }

  ExpenseRow copyWith({
    Value<String?> opId = const Value.absent(),
    String? syncState,
    Value<int?> serverSeq = const Value.absent(),
    Value<String?> at = const Value.absent(),
    String? id,
    String? kind,
    String? item,
    String? label,
    Value<String?> carId = const Value.absent(),
    Value<int?> liters = const Value.absent(),
    Value<String?> studentId = const Value.absent(),
    int? amount,
    String? accountId,
    Value<String?> note = const Value.absent(),
    String? businessDate,
    bool? reversed,
  }) => ExpenseRow(
    opId: opId.present ? opId.value : this.opId,
    syncState: syncState ?? this.syncState,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    at: at.present ? at.value : this.at,
    id: id ?? this.id,
    kind: kind ?? this.kind,
    item: item ?? this.item,
    label: label ?? this.label,
    carId: carId.present ? carId.value : this.carId,
    liters: liters.present ? liters.value : this.liters,
    studentId: studentId.present ? studentId.value : this.studentId,
    amount: amount ?? this.amount,
    accountId: accountId ?? this.accountId,
    note: note.present ? note.value : this.note,
    businessDate: businessDate ?? this.businessDate,
    reversed: reversed ?? this.reversed,
  );
  ExpenseRow copyWithCompanion(ExpensesCompanion data) {
    return ExpenseRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      at: data.at.present ? data.at.value : this.at,
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      item: data.item.present ? data.item.value : this.item,
      label: data.label.present ? data.label.value : this.label,
      carId: data.carId.present ? data.carId.value : this.carId,
      liters: data.liters.present ? data.liters.value : this.liters,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      amount: data.amount.present ? data.amount.value : this.amount,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      note: data.note.present ? data.note.value : this.note,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      reversed: data.reversed.present ? data.reversed.value : this.reversed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseRow(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('item: $item, ')
          ..write('label: $label, ')
          ..write('carId: $carId, ')
          ..write('liters: $liters, ')
          ..write('studentId: $studentId, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('note: $note, ')
          ..write('businessDate: $businessDate, ')
          ..write('reversed: $reversed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    syncState,
    serverSeq,
    at,
    id,
    kind,
    item,
    label,
    carId,
    liters,
    studentId,
    amount,
    accountId,
    note,
    businessDate,
    reversed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseRow &&
          other.opId == this.opId &&
          other.syncState == this.syncState &&
          other.serverSeq == this.serverSeq &&
          other.at == this.at &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.item == this.item &&
          other.label == this.label &&
          other.carId == this.carId &&
          other.liters == this.liters &&
          other.studentId == this.studentId &&
          other.amount == this.amount &&
          other.accountId == this.accountId &&
          other.note == this.note &&
          other.businessDate == this.businessDate &&
          other.reversed == this.reversed);
}

class ExpensesCompanion extends UpdateCompanion<ExpenseRow> {
  final Value<String?> opId;
  final Value<String> syncState;
  final Value<int?> serverSeq;
  final Value<String?> at;
  final Value<String> id;
  final Value<String> kind;
  final Value<String> item;
  final Value<String> label;
  final Value<String?> carId;
  final Value<int?> liters;
  final Value<String?> studentId;
  final Value<int> amount;
  final Value<String> accountId;
  final Value<String?> note;
  final Value<String> businessDate;
  final Value<bool> reversed;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.item = const Value.absent(),
    this.label = const Value.absent(),
    this.carId = const Value.absent(),
    this.liters = const Value.absent(),
    this.studentId = const Value.absent(),
    this.amount = const Value.absent(),
    this.accountId = const Value.absent(),
    this.note = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.reversed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    required String id,
    required String kind,
    required String item,
    required String label,
    this.carId = const Value.absent(),
    this.liters = const Value.absent(),
    this.studentId = const Value.absent(),
    required int amount,
    required String accountId,
    this.note = const Value.absent(),
    required String businessDate,
    this.reversed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       item = Value(item),
       label = Value(label),
       amount = Value(amount),
       accountId = Value(accountId),
       businessDate = Value(businessDate);
  static Insertable<ExpenseRow> custom({
    Expression<String>? opId,
    Expression<String>? syncState,
    Expression<int>? serverSeq,
    Expression<String>? at,
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? item,
    Expression<String>? label,
    Expression<String>? carId,
    Expression<int>? liters,
    Expression<String>? studentId,
    Expression<int>? amount,
    Expression<String>? accountId,
    Expression<String>? note,
    Expression<String>? businessDate,
    Expression<bool>? reversed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (syncState != null) 'sync_state': syncState,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (at != null) 'at': at,
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (item != null) 'item': item,
      if (label != null) 'label': label,
      if (carId != null) 'car_id': carId,
      if (liters != null) 'liters': liters,
      if (studentId != null) 'student_id': studentId,
      if (amount != null) 'amount': amount,
      if (accountId != null) 'account_id': accountId,
      if (note != null) 'note': note,
      if (businessDate != null) 'business_date': businessDate,
      if (reversed != null) 'reversed': reversed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String?>? opId,
    Value<String>? syncState,
    Value<int?>? serverSeq,
    Value<String?>? at,
    Value<String>? id,
    Value<String>? kind,
    Value<String>? item,
    Value<String>? label,
    Value<String?>? carId,
    Value<int?>? liters,
    Value<String?>? studentId,
    Value<int>? amount,
    Value<String>? accountId,
    Value<String?>? note,
    Value<String>? businessDate,
    Value<bool>? reversed,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      opId: opId ?? this.opId,
      syncState: syncState ?? this.syncState,
      serverSeq: serverSeq ?? this.serverSeq,
      at: at ?? this.at,
      id: id ?? this.id,
      kind: kind ?? this.kind,
      item: item ?? this.item,
      label: label ?? this.label,
      carId: carId ?? this.carId,
      liters: liters ?? this.liters,
      studentId: studentId ?? this.studentId,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      note: note ?? this.note,
      businessDate: businessDate ?? this.businessDate,
      reversed: reversed ?? this.reversed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (item.present) {
      map['item'] = Variable<String>(item.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (carId.present) {
      map['car_id'] = Variable<String>(carId.value);
    }
    if (liters.present) {
      map['liters'] = Variable<int>(liters.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (reversed.present) {
      map['reversed'] = Variable<bool>(reversed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('item: $item, ')
          ..write('label: $label, ')
          ..write('carId: $carId, ')
          ..write('liters: $liters, ')
          ..write('studentId: $studentId, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('note: $note, ')
          ..write('businessDate: $businessDate, ')
          ..write('reversed: $reversed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountBalancesTable extends AccountBalances
    with TableInfo<$AccountBalancesTable, AccountBalanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountBalancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<int> balance = GeneratedColumn<int>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [accountId, balance, serverSeq];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_balances';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountBalanceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId};
  @override
  AccountBalanceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountBalanceRow(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      )!,
    );
  }

  @override
  $AccountBalancesTable createAlias(String alias) {
    return $AccountBalancesTable(attachedDatabase, alias);
  }
}

class AccountBalanceRow extends DataClass
    implements Insertable<AccountBalanceRow> {
  final String accountId;
  final int balance;
  final int serverSeq;
  const AccountBalanceRow({
    required this.accountId,
    required this.balance,
    required this.serverSeq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['balance'] = Variable<int>(balance);
    map['server_seq'] = Variable<int>(serverSeq);
    return map;
  }

  AccountBalancesCompanion toCompanion(bool nullToAbsent) {
    return AccountBalancesCompanion(
      accountId: Value(accountId),
      balance: Value(balance),
      serverSeq: Value(serverSeq),
    );
  }

  factory AccountBalanceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountBalanceRow(
      accountId: serializer.fromJson<String>(json['accountId']),
      balance: serializer.fromJson<int>(json['balance']),
      serverSeq: serializer.fromJson<int>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'balance': serializer.toJson<int>(balance),
      'serverSeq': serializer.toJson<int>(serverSeq),
    };
  }

  AccountBalanceRow copyWith({
    String? accountId,
    int? balance,
    int? serverSeq,
  }) => AccountBalanceRow(
    accountId: accountId ?? this.accountId,
    balance: balance ?? this.balance,
    serverSeq: serverSeq ?? this.serverSeq,
  );
  AccountBalanceRow copyWithCompanion(AccountBalancesCompanion data) {
    return AccountBalanceRow(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      balance: data.balance.present ? data.balance.value : this.balance,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountBalanceRow(')
          ..write('accountId: $accountId, ')
          ..write('balance: $balance, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(accountId, balance, serverSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountBalanceRow &&
          other.accountId == this.accountId &&
          other.balance == this.balance &&
          other.serverSeq == this.serverSeq);
}

class AccountBalancesCompanion extends UpdateCompanion<AccountBalanceRow> {
  final Value<String> accountId;
  final Value<int> balance;
  final Value<int> serverSeq;
  final Value<int> rowid;
  const AccountBalancesCompanion({
    this.accountId = const Value.absent(),
    this.balance = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountBalancesCompanion.insert({
    required String accountId,
    required int balance,
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       balance = Value(balance);
  static Insertable<AccountBalanceRow> custom({
    Expression<String>? accountId,
    Expression<int>? balance,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (balance != null) 'balance': balance,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountBalancesCompanion copyWith({
    Value<String>? accountId,
    Value<int>? balance,
    Value<int>? serverSeq,
    Value<int>? rowid,
  }) {
    return AccountBalancesCompanion(
      accountId: accountId ?? this.accountId,
      balance: balance ?? this.balance,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (balance.present) {
      map['balance'] = Variable<int>(balance.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountBalancesCompanion(')
          ..write('accountId: $accountId, ')
          ..write('balance: $balance, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayClosesTable extends DayCloses
    with TableInfo<$DayClosesTable, DayCloseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayClosesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedByNameMeta = const VerificationMeta(
    'closedByName',
  );
  @override
  late final GeneratedColumn<String> closedByName = GeneratedColumn<String>(
    'closed_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diffsMeta = const VerificationMeta('diffs');
  @override
  late final GeneratedColumn<int> diffs = GeneratedColumn<int>(
    'diffs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lateEntriesMeta = const VerificationMeta(
    'lateEntries',
  );
  @override
  late final GeneratedColumn<int> lateEntries = GeneratedColumn<int>(
    'late_entries',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reopenReasonMeta = const VerificationMeta(
    'reopenReason',
  );
  @override
  late final GeneratedColumn<String> reopenReason = GeneratedColumn<String>(
    'reopen_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    syncState,
    serverSeq,
    at,
    id,
    state,
    mode,
    closedByName,
    diffs,
    lateEntries,
    reopenReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_closes';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayCloseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('closed_by_name')) {
      context.handle(
        _closedByNameMeta,
        closedByName.isAcceptableOrUnknown(
          data['closed_by_name']!,
          _closedByNameMeta,
        ),
      );
    }
    if (data.containsKey('diffs')) {
      context.handle(
        _diffsMeta,
        diffs.isAcceptableOrUnknown(data['diffs']!, _diffsMeta),
      );
    }
    if (data.containsKey('late_entries')) {
      context.handle(
        _lateEntriesMeta,
        lateEntries.isAcceptableOrUnknown(
          data['late_entries']!,
          _lateEntriesMeta,
        ),
      );
    }
    if (data.containsKey('reopen_reason')) {
      context.handle(
        _reopenReasonMeta,
        reopenReason.isAcceptableOrUnknown(
          data['reopen_reason']!,
          _reopenReasonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DayCloseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayCloseRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      closedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_by_name'],
      ),
      diffs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}diffs'],
      )!,
      lateEntries: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}late_entries'],
      )!,
      reopenReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reopen_reason'],
      ),
    );
  }

  @override
  $DayClosesTable createAlias(String alias) {
    return $DayClosesTable(attachedDatabase, alias);
  }
}

class DayCloseRow extends DataClass implements Insertable<DayCloseRow> {
  /// The op that created/changed this row (links local rows to outbox results).
  final String? opId;

  /// pending | synced | rejected
  final String syncState;
  final int? serverSeq;

  /// When it happened (ISO-8601): device time while pending, server time once synced.
  final String? at;

  /// = businessDate
  final String id;

  /// closed | reopened
  final String state;

  /// blind | full
  final String mode;
  final String? closedByName;
  final int diffs;
  final int lateEntries;
  final String? reopenReason;
  const DayCloseRow({
    this.opId,
    required this.syncState,
    this.serverSeq,
    this.at,
    required this.id,
    required this.state,
    required this.mode,
    this.closedByName,
    required this.diffs,
    required this.lateEntries,
    this.reopenReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || opId != null) {
      map['op_id'] = Variable<String>(opId);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    if (!nullToAbsent || at != null) {
      map['at'] = Variable<String>(at);
    }
    map['id'] = Variable<String>(id);
    map['state'] = Variable<String>(state);
    map['mode'] = Variable<String>(mode);
    if (!nullToAbsent || closedByName != null) {
      map['closed_by_name'] = Variable<String>(closedByName);
    }
    map['diffs'] = Variable<int>(diffs);
    map['late_entries'] = Variable<int>(lateEntries);
    if (!nullToAbsent || reopenReason != null) {
      map['reopen_reason'] = Variable<String>(reopenReason);
    }
    return map;
  }

  DayClosesCompanion toCompanion(bool nullToAbsent) {
    return DayClosesCompanion(
      opId: opId == null && nullToAbsent ? const Value.absent() : Value(opId),
      syncState: Value(syncState),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      at: at == null && nullToAbsent ? const Value.absent() : Value(at),
      id: Value(id),
      state: Value(state),
      mode: Value(mode),
      closedByName: closedByName == null && nullToAbsent
          ? const Value.absent()
          : Value(closedByName),
      diffs: Value(diffs),
      lateEntries: Value(lateEntries),
      reopenReason: reopenReason == null && nullToAbsent
          ? const Value.absent()
          : Value(reopenReason),
    );
  }

  factory DayCloseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayCloseRow(
      opId: serializer.fromJson<String?>(json['opId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      at: serializer.fromJson<String?>(json['at']),
      id: serializer.fromJson<String>(json['id']),
      state: serializer.fromJson<String>(json['state']),
      mode: serializer.fromJson<String>(json['mode']),
      closedByName: serializer.fromJson<String?>(json['closedByName']),
      diffs: serializer.fromJson<int>(json['diffs']),
      lateEntries: serializer.fromJson<int>(json['lateEntries']),
      reopenReason: serializer.fromJson<String?>(json['reopenReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String?>(opId),
      'syncState': serializer.toJson<String>(syncState),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'at': serializer.toJson<String?>(at),
      'id': serializer.toJson<String>(id),
      'state': serializer.toJson<String>(state),
      'mode': serializer.toJson<String>(mode),
      'closedByName': serializer.toJson<String?>(closedByName),
      'diffs': serializer.toJson<int>(diffs),
      'lateEntries': serializer.toJson<int>(lateEntries),
      'reopenReason': serializer.toJson<String?>(reopenReason),
    };
  }

  DayCloseRow copyWith({
    Value<String?> opId = const Value.absent(),
    String? syncState,
    Value<int?> serverSeq = const Value.absent(),
    Value<String?> at = const Value.absent(),
    String? id,
    String? state,
    String? mode,
    Value<String?> closedByName = const Value.absent(),
    int? diffs,
    int? lateEntries,
    Value<String?> reopenReason = const Value.absent(),
  }) => DayCloseRow(
    opId: opId.present ? opId.value : this.opId,
    syncState: syncState ?? this.syncState,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    at: at.present ? at.value : this.at,
    id: id ?? this.id,
    state: state ?? this.state,
    mode: mode ?? this.mode,
    closedByName: closedByName.present ? closedByName.value : this.closedByName,
    diffs: diffs ?? this.diffs,
    lateEntries: lateEntries ?? this.lateEntries,
    reopenReason: reopenReason.present ? reopenReason.value : this.reopenReason,
  );
  DayCloseRow copyWithCompanion(DayClosesCompanion data) {
    return DayCloseRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      at: data.at.present ? data.at.value : this.at,
      id: data.id.present ? data.id.value : this.id,
      state: data.state.present ? data.state.value : this.state,
      mode: data.mode.present ? data.mode.value : this.mode,
      closedByName: data.closedByName.present
          ? data.closedByName.value
          : this.closedByName,
      diffs: data.diffs.present ? data.diffs.value : this.diffs,
      lateEntries: data.lateEntries.present
          ? data.lateEntries.value
          : this.lateEntries,
      reopenReason: data.reopenReason.present
          ? data.reopenReason.value
          : this.reopenReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayCloseRow(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('state: $state, ')
          ..write('mode: $mode, ')
          ..write('closedByName: $closedByName, ')
          ..write('diffs: $diffs, ')
          ..write('lateEntries: $lateEntries, ')
          ..write('reopenReason: $reopenReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    syncState,
    serverSeq,
    at,
    id,
    state,
    mode,
    closedByName,
    diffs,
    lateEntries,
    reopenReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayCloseRow &&
          other.opId == this.opId &&
          other.syncState == this.syncState &&
          other.serverSeq == this.serverSeq &&
          other.at == this.at &&
          other.id == this.id &&
          other.state == this.state &&
          other.mode == this.mode &&
          other.closedByName == this.closedByName &&
          other.diffs == this.diffs &&
          other.lateEntries == this.lateEntries &&
          other.reopenReason == this.reopenReason);
}

class DayClosesCompanion extends UpdateCompanion<DayCloseRow> {
  final Value<String?> opId;
  final Value<String> syncState;
  final Value<int?> serverSeq;
  final Value<String?> at;
  final Value<String> id;
  final Value<String> state;
  final Value<String> mode;
  final Value<String?> closedByName;
  final Value<int> diffs;
  final Value<int> lateEntries;
  final Value<String?> reopenReason;
  final Value<int> rowid;
  const DayClosesCompanion({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    this.id = const Value.absent(),
    this.state = const Value.absent(),
    this.mode = const Value.absent(),
    this.closedByName = const Value.absent(),
    this.diffs = const Value.absent(),
    this.lateEntries = const Value.absent(),
    this.reopenReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayClosesCompanion.insert({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    required String id,
    required String state,
    required String mode,
    this.closedByName = const Value.absent(),
    this.diffs = const Value.absent(),
    this.lateEntries = const Value.absent(),
    this.reopenReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       state = Value(state),
       mode = Value(mode);
  static Insertable<DayCloseRow> custom({
    Expression<String>? opId,
    Expression<String>? syncState,
    Expression<int>? serverSeq,
    Expression<String>? at,
    Expression<String>? id,
    Expression<String>? state,
    Expression<String>? mode,
    Expression<String>? closedByName,
    Expression<int>? diffs,
    Expression<int>? lateEntries,
    Expression<String>? reopenReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (syncState != null) 'sync_state': syncState,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (at != null) 'at': at,
      if (id != null) 'id': id,
      if (state != null) 'state': state,
      if (mode != null) 'mode': mode,
      if (closedByName != null) 'closed_by_name': closedByName,
      if (diffs != null) 'diffs': diffs,
      if (lateEntries != null) 'late_entries': lateEntries,
      if (reopenReason != null) 'reopen_reason': reopenReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayClosesCompanion copyWith({
    Value<String?>? opId,
    Value<String>? syncState,
    Value<int?>? serverSeq,
    Value<String?>? at,
    Value<String>? id,
    Value<String>? state,
    Value<String>? mode,
    Value<String?>? closedByName,
    Value<int>? diffs,
    Value<int>? lateEntries,
    Value<String?>? reopenReason,
    Value<int>? rowid,
  }) {
    return DayClosesCompanion(
      opId: opId ?? this.opId,
      syncState: syncState ?? this.syncState,
      serverSeq: serverSeq ?? this.serverSeq,
      at: at ?? this.at,
      id: id ?? this.id,
      state: state ?? this.state,
      mode: mode ?? this.mode,
      closedByName: closedByName ?? this.closedByName,
      diffs: diffs ?? this.diffs,
      lateEntries: lateEntries ?? this.lateEntries,
      reopenReason: reopenReason ?? this.reopenReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (closedByName.present) {
      map['closed_by_name'] = Variable<String>(closedByName.value);
    }
    if (diffs.present) {
      map['diffs'] = Variable<int>(diffs.value);
    }
    if (lateEntries.present) {
      map['late_entries'] = Variable<int>(lateEntries.value);
    }
    if (reopenReason.present) {
      map['reopen_reason'] = Variable<String>(reopenReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayClosesCompanion(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('state: $state, ')
          ..write('mode: $mode, ')
          ..write('closedByName: $closedByName, ')
          ..write('diffs: $diffs, ')
          ..write('lateEntries: $lateEntries, ')
          ..write('reopenReason: $reopenReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayCloseCountsTable extends DayCloseCounts
    with TableInfo<$DayCloseCountsTable, DayCloseCountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayCloseCountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedMeta = const VerificationMeta(
    'expected',
  );
  @override
  late final GeneratedColumn<int> expected = GeneratedColumn<int>(
    'expected',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countedMeta = const VerificationMeta(
    'counted',
  );
  @override
  late final GeneratedColumn<int> counted = GeneratedColumn<int>(
    'counted',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diffMeta = const VerificationMeta('diff');
  @override
  late final GeneratedColumn<int> diff = GeneratedColumn<int>(
    'diff',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    syncState,
    serverSeq,
    at,
    id,
    businessDate,
    accountId,
    expected,
    counted,
    diff,
    reason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_close_counts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayCloseCountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('expected')) {
      context.handle(
        _expectedMeta,
        expected.isAcceptableOrUnknown(data['expected']!, _expectedMeta),
      );
    } else if (isInserting) {
      context.missing(_expectedMeta);
    }
    if (data.containsKey('counted')) {
      context.handle(
        _countedMeta,
        counted.isAcceptableOrUnknown(data['counted']!, _countedMeta),
      );
    } else if (isInserting) {
      context.missing(_countedMeta);
    }
    if (data.containsKey('diff')) {
      context.handle(
        _diffMeta,
        diff.isAcceptableOrUnknown(data['diff']!, _diffMeta),
      );
    } else if (isInserting) {
      context.missing(_diffMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DayCloseCountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayCloseCountRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      expected: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected'],
      )!,
      counted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}counted'],
      )!,
      diff: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}diff'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
    );
  }

  @override
  $DayCloseCountsTable createAlias(String alias) {
    return $DayCloseCountsTable(attachedDatabase, alias);
  }
}

class DayCloseCountRow extends DataClass
    implements Insertable<DayCloseCountRow> {
  /// The op that created/changed this row (links local rows to outbox results).
  final String? opId;

  /// pending | synced | rejected
  final String syncState;
  final int? serverSeq;

  /// When it happened (ISO-8601): device time while pending, server time once synced.
  final String? at;
  final String id;
  final String businessDate;
  final String accountId;
  final int expected;
  final int counted;
  final int diff;
  final String? reason;
  const DayCloseCountRow({
    this.opId,
    required this.syncState,
    this.serverSeq,
    this.at,
    required this.id,
    required this.businessDate,
    required this.accountId,
    required this.expected,
    required this.counted,
    required this.diff,
    this.reason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || opId != null) {
      map['op_id'] = Variable<String>(opId);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    if (!nullToAbsent || at != null) {
      map['at'] = Variable<String>(at);
    }
    map['id'] = Variable<String>(id);
    map['business_date'] = Variable<String>(businessDate);
    map['account_id'] = Variable<String>(accountId);
    map['expected'] = Variable<int>(expected);
    map['counted'] = Variable<int>(counted);
    map['diff'] = Variable<int>(diff);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    return map;
  }

  DayCloseCountsCompanion toCompanion(bool nullToAbsent) {
    return DayCloseCountsCompanion(
      opId: opId == null && nullToAbsent ? const Value.absent() : Value(opId),
      syncState: Value(syncState),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      at: at == null && nullToAbsent ? const Value.absent() : Value(at),
      id: Value(id),
      businessDate: Value(businessDate),
      accountId: Value(accountId),
      expected: Value(expected),
      counted: Value(counted),
      diff: Value(diff),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
    );
  }

  factory DayCloseCountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayCloseCountRow(
      opId: serializer.fromJson<String?>(json['opId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      at: serializer.fromJson<String?>(json['at']),
      id: serializer.fromJson<String>(json['id']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      accountId: serializer.fromJson<String>(json['accountId']),
      expected: serializer.fromJson<int>(json['expected']),
      counted: serializer.fromJson<int>(json['counted']),
      diff: serializer.fromJson<int>(json['diff']),
      reason: serializer.fromJson<String?>(json['reason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String?>(opId),
      'syncState': serializer.toJson<String>(syncState),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'at': serializer.toJson<String?>(at),
      'id': serializer.toJson<String>(id),
      'businessDate': serializer.toJson<String>(businessDate),
      'accountId': serializer.toJson<String>(accountId),
      'expected': serializer.toJson<int>(expected),
      'counted': serializer.toJson<int>(counted),
      'diff': serializer.toJson<int>(diff),
      'reason': serializer.toJson<String?>(reason),
    };
  }

  DayCloseCountRow copyWith({
    Value<String?> opId = const Value.absent(),
    String? syncState,
    Value<int?> serverSeq = const Value.absent(),
    Value<String?> at = const Value.absent(),
    String? id,
    String? businessDate,
    String? accountId,
    int? expected,
    int? counted,
    int? diff,
    Value<String?> reason = const Value.absent(),
  }) => DayCloseCountRow(
    opId: opId.present ? opId.value : this.opId,
    syncState: syncState ?? this.syncState,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    at: at.present ? at.value : this.at,
    id: id ?? this.id,
    businessDate: businessDate ?? this.businessDate,
    accountId: accountId ?? this.accountId,
    expected: expected ?? this.expected,
    counted: counted ?? this.counted,
    diff: diff ?? this.diff,
    reason: reason.present ? reason.value : this.reason,
  );
  DayCloseCountRow copyWithCompanion(DayCloseCountsCompanion data) {
    return DayCloseCountRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      at: data.at.present ? data.at.value : this.at,
      id: data.id.present ? data.id.value : this.id,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      expected: data.expected.present ? data.expected.value : this.expected,
      counted: data.counted.present ? data.counted.value : this.counted,
      diff: data.diff.present ? data.diff.value : this.diff,
      reason: data.reason.present ? data.reason.value : this.reason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayCloseCountRow(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('businessDate: $businessDate, ')
          ..write('accountId: $accountId, ')
          ..write('expected: $expected, ')
          ..write('counted: $counted, ')
          ..write('diff: $diff, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    syncState,
    serverSeq,
    at,
    id,
    businessDate,
    accountId,
    expected,
    counted,
    diff,
    reason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayCloseCountRow &&
          other.opId == this.opId &&
          other.syncState == this.syncState &&
          other.serverSeq == this.serverSeq &&
          other.at == this.at &&
          other.id == this.id &&
          other.businessDate == this.businessDate &&
          other.accountId == this.accountId &&
          other.expected == this.expected &&
          other.counted == this.counted &&
          other.diff == this.diff &&
          other.reason == this.reason);
}

class DayCloseCountsCompanion extends UpdateCompanion<DayCloseCountRow> {
  final Value<String?> opId;
  final Value<String> syncState;
  final Value<int?> serverSeq;
  final Value<String?> at;
  final Value<String> id;
  final Value<String> businessDate;
  final Value<String> accountId;
  final Value<int> expected;
  final Value<int> counted;
  final Value<int> diff;
  final Value<String?> reason;
  final Value<int> rowid;
  const DayCloseCountsCompanion({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    this.id = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.accountId = const Value.absent(),
    this.expected = const Value.absent(),
    this.counted = const Value.absent(),
    this.diff = const Value.absent(),
    this.reason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayCloseCountsCompanion.insert({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    required String id,
    required String businessDate,
    required String accountId,
    required int expected,
    required int counted,
    required int diff,
    this.reason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessDate = Value(businessDate),
       accountId = Value(accountId),
       expected = Value(expected),
       counted = Value(counted),
       diff = Value(diff);
  static Insertable<DayCloseCountRow> custom({
    Expression<String>? opId,
    Expression<String>? syncState,
    Expression<int>? serverSeq,
    Expression<String>? at,
    Expression<String>? id,
    Expression<String>? businessDate,
    Expression<String>? accountId,
    Expression<int>? expected,
    Expression<int>? counted,
    Expression<int>? diff,
    Expression<String>? reason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (syncState != null) 'sync_state': syncState,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (at != null) 'at': at,
      if (id != null) 'id': id,
      if (businessDate != null) 'business_date': businessDate,
      if (accountId != null) 'account_id': accountId,
      if (expected != null) 'expected': expected,
      if (counted != null) 'counted': counted,
      if (diff != null) 'diff': diff,
      if (reason != null) 'reason': reason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayCloseCountsCompanion copyWith({
    Value<String?>? opId,
    Value<String>? syncState,
    Value<int?>? serverSeq,
    Value<String?>? at,
    Value<String>? id,
    Value<String>? businessDate,
    Value<String>? accountId,
    Value<int>? expected,
    Value<int>? counted,
    Value<int>? diff,
    Value<String?>? reason,
    Value<int>? rowid,
  }) {
    return DayCloseCountsCompanion(
      opId: opId ?? this.opId,
      syncState: syncState ?? this.syncState,
      serverSeq: serverSeq ?? this.serverSeq,
      at: at ?? this.at,
      id: id ?? this.id,
      businessDate: businessDate ?? this.businessDate,
      accountId: accountId ?? this.accountId,
      expected: expected ?? this.expected,
      counted: counted ?? this.counted,
      diff: diff ?? this.diff,
      reason: reason ?? this.reason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (expected.present) {
      map['expected'] = Variable<int>(expected.value);
    }
    if (counted.present) {
      map['counted'] = Variable<int>(counted.value);
    }
    if (diff.present) {
      map['diff'] = Variable<int>(diff.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayCloseCountsCompanion(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('businessDate: $businessDate, ')
          ..write('accountId: $accountId, ')
          ..write('expected: $expected, ')
          ..write('counted: $counted, ')
          ..write('diff: $diff, ')
          ..write('reason: $reason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExamsTable extends Exams with TableInfo<$ExamsTable, ExamRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enrollmentIdMeta = const VerificationMeta(
    'enrollmentId',
  );
  @override
  late final GeneratedColumn<String> enrollmentId = GeneratedColumn<String>(
    'enrollment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentNameMeta = const VerificationMeta(
    'studentName',
  );
  @override
  late final GeneratedColumn<String> studentName = GeneratedColumn<String>(
    'student_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carIdMeta = const VerificationMeta('carId');
  @override
  late final GeneratedColumn<String> carId = GeneratedColumn<String>(
    'car_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptMeta = const VerificationMeta(
    'attempt',
  );
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
    'attempt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<String> scheduledDate = GeneratedColumn<String>(
    'scheduled_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _feeMeta = const VerificationMeta('fee');
  @override
  late final GeneratedColumn<int> fee = GeneratedColumn<int>(
    'fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _historyJsonMeta = const VerificationMeta(
    'historyJson',
  );
  @override
  late final GeneratedColumn<String> historyJson = GeneratedColumn<String>(
    'history_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    syncState,
    serverSeq,
    at,
    id,
    enrollmentId,
    studentId,
    studentName,
    carId,
    type,
    attempt,
    scheduledDate,
    result,
    fee,
    historyJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exams';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExamRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('enrollment_id')) {
      context.handle(
        _enrollmentIdMeta,
        enrollmentId.isAcceptableOrUnknown(
          data['enrollment_id']!,
          _enrollmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_enrollmentIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('student_name')) {
      context.handle(
        _studentNameMeta,
        studentName.isAcceptableOrUnknown(
          data['student_name']!,
          _studentNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_studentNameMeta);
    }
    if (data.containsKey('car_id')) {
      context.handle(
        _carIdMeta,
        carId.isAcceptableOrUnknown(data['car_id']!, _carIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('attempt')) {
      context.handle(
        _attemptMeta,
        attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptMeta);
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledDateMeta);
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    }
    if (data.containsKey('fee')) {
      context.handle(
        _feeMeta,
        fee.isAcceptableOrUnknown(data['fee']!, _feeMeta),
      );
    }
    if (data.containsKey('history_json')) {
      context.handle(
        _historyJsonMeta,
        historyJson.isAcceptableOrUnknown(
          data['history_json']!,
          _historyJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExamRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExamRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      enrollmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enrollment_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      studentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_name'],
      )!,
      carId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}car_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      attempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt'],
      )!,
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scheduled_date'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      fee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fee'],
      )!,
      historyJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}history_json'],
      )!,
    );
  }

  @override
  $ExamsTable createAlias(String alias) {
    return $ExamsTable(attachedDatabase, alias);
  }
}

class ExamRow extends DataClass implements Insertable<ExamRow> {
  /// The op that created/changed this row (links local rows to outbox results).
  final String? opId;

  /// pending | synced | rejected
  final String syncState;
  final int? serverSeq;

  /// When it happened (ISO-8601): device time while pending, server time once synced.
  final String? at;
  final String id;
  final String enrollmentId;
  final String studentId;
  final String studentName;
  final String? carId;

  /// theory | theory_retake | practical
  final String type;
  final int attempt;
  final String scheduledDate;

  /// pending | passed | failed | absent
  final String result;
  final int fee;

  /// JSON list of postponements [{from, to, reason, details, by}]
  final String historyJson;
  const ExamRow({
    this.opId,
    required this.syncState,
    this.serverSeq,
    this.at,
    required this.id,
    required this.enrollmentId,
    required this.studentId,
    required this.studentName,
    this.carId,
    required this.type,
    required this.attempt,
    required this.scheduledDate,
    required this.result,
    required this.fee,
    required this.historyJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || opId != null) {
      map['op_id'] = Variable<String>(opId);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    if (!nullToAbsent || at != null) {
      map['at'] = Variable<String>(at);
    }
    map['id'] = Variable<String>(id);
    map['enrollment_id'] = Variable<String>(enrollmentId);
    map['student_id'] = Variable<String>(studentId);
    map['student_name'] = Variable<String>(studentName);
    if (!nullToAbsent || carId != null) {
      map['car_id'] = Variable<String>(carId);
    }
    map['type'] = Variable<String>(type);
    map['attempt'] = Variable<int>(attempt);
    map['scheduled_date'] = Variable<String>(scheduledDate);
    map['result'] = Variable<String>(result);
    map['fee'] = Variable<int>(fee);
    map['history_json'] = Variable<String>(historyJson);
    return map;
  }

  ExamsCompanion toCompanion(bool nullToAbsent) {
    return ExamsCompanion(
      opId: opId == null && nullToAbsent ? const Value.absent() : Value(opId),
      syncState: Value(syncState),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      at: at == null && nullToAbsent ? const Value.absent() : Value(at),
      id: Value(id),
      enrollmentId: Value(enrollmentId),
      studentId: Value(studentId),
      studentName: Value(studentName),
      carId: carId == null && nullToAbsent
          ? const Value.absent()
          : Value(carId),
      type: Value(type),
      attempt: Value(attempt),
      scheduledDate: Value(scheduledDate),
      result: Value(result),
      fee: Value(fee),
      historyJson: Value(historyJson),
    );
  }

  factory ExamRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExamRow(
      opId: serializer.fromJson<String?>(json['opId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      at: serializer.fromJson<String?>(json['at']),
      id: serializer.fromJson<String>(json['id']),
      enrollmentId: serializer.fromJson<String>(json['enrollmentId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      studentName: serializer.fromJson<String>(json['studentName']),
      carId: serializer.fromJson<String?>(json['carId']),
      type: serializer.fromJson<String>(json['type']),
      attempt: serializer.fromJson<int>(json['attempt']),
      scheduledDate: serializer.fromJson<String>(json['scheduledDate']),
      result: serializer.fromJson<String>(json['result']),
      fee: serializer.fromJson<int>(json['fee']),
      historyJson: serializer.fromJson<String>(json['historyJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String?>(opId),
      'syncState': serializer.toJson<String>(syncState),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'at': serializer.toJson<String?>(at),
      'id': serializer.toJson<String>(id),
      'enrollmentId': serializer.toJson<String>(enrollmentId),
      'studentId': serializer.toJson<String>(studentId),
      'studentName': serializer.toJson<String>(studentName),
      'carId': serializer.toJson<String?>(carId),
      'type': serializer.toJson<String>(type),
      'attempt': serializer.toJson<int>(attempt),
      'scheduledDate': serializer.toJson<String>(scheduledDate),
      'result': serializer.toJson<String>(result),
      'fee': serializer.toJson<int>(fee),
      'historyJson': serializer.toJson<String>(historyJson),
    };
  }

  ExamRow copyWith({
    Value<String?> opId = const Value.absent(),
    String? syncState,
    Value<int?> serverSeq = const Value.absent(),
    Value<String?> at = const Value.absent(),
    String? id,
    String? enrollmentId,
    String? studentId,
    String? studentName,
    Value<String?> carId = const Value.absent(),
    String? type,
    int? attempt,
    String? scheduledDate,
    String? result,
    int? fee,
    String? historyJson,
  }) => ExamRow(
    opId: opId.present ? opId.value : this.opId,
    syncState: syncState ?? this.syncState,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    at: at.present ? at.value : this.at,
    id: id ?? this.id,
    enrollmentId: enrollmentId ?? this.enrollmentId,
    studentId: studentId ?? this.studentId,
    studentName: studentName ?? this.studentName,
    carId: carId.present ? carId.value : this.carId,
    type: type ?? this.type,
    attempt: attempt ?? this.attempt,
    scheduledDate: scheduledDate ?? this.scheduledDate,
    result: result ?? this.result,
    fee: fee ?? this.fee,
    historyJson: historyJson ?? this.historyJson,
  );
  ExamRow copyWithCompanion(ExamsCompanion data) {
    return ExamRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      at: data.at.present ? data.at.value : this.at,
      id: data.id.present ? data.id.value : this.id,
      enrollmentId: data.enrollmentId.present
          ? data.enrollmentId.value
          : this.enrollmentId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      studentName: data.studentName.present
          ? data.studentName.value
          : this.studentName,
      carId: data.carId.present ? data.carId.value : this.carId,
      type: data.type.present ? data.type.value : this.type,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      result: data.result.present ? data.result.value : this.result,
      fee: data.fee.present ? data.fee.value : this.fee,
      historyJson: data.historyJson.present
          ? data.historyJson.value
          : this.historyJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExamRow(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('enrollmentId: $enrollmentId, ')
          ..write('studentId: $studentId, ')
          ..write('studentName: $studentName, ')
          ..write('carId: $carId, ')
          ..write('type: $type, ')
          ..write('attempt: $attempt, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('result: $result, ')
          ..write('fee: $fee, ')
          ..write('historyJson: $historyJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    syncState,
    serverSeq,
    at,
    id,
    enrollmentId,
    studentId,
    studentName,
    carId,
    type,
    attempt,
    scheduledDate,
    result,
    fee,
    historyJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExamRow &&
          other.opId == this.opId &&
          other.syncState == this.syncState &&
          other.serverSeq == this.serverSeq &&
          other.at == this.at &&
          other.id == this.id &&
          other.enrollmentId == this.enrollmentId &&
          other.studentId == this.studentId &&
          other.studentName == this.studentName &&
          other.carId == this.carId &&
          other.type == this.type &&
          other.attempt == this.attempt &&
          other.scheduledDate == this.scheduledDate &&
          other.result == this.result &&
          other.fee == this.fee &&
          other.historyJson == this.historyJson);
}

class ExamsCompanion extends UpdateCompanion<ExamRow> {
  final Value<String?> opId;
  final Value<String> syncState;
  final Value<int?> serverSeq;
  final Value<String?> at;
  final Value<String> id;
  final Value<String> enrollmentId;
  final Value<String> studentId;
  final Value<String> studentName;
  final Value<String?> carId;
  final Value<String> type;
  final Value<int> attempt;
  final Value<String> scheduledDate;
  final Value<String> result;
  final Value<int> fee;
  final Value<String> historyJson;
  final Value<int> rowid;
  const ExamsCompanion({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    this.id = const Value.absent(),
    this.enrollmentId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.studentName = const Value.absent(),
    this.carId = const Value.absent(),
    this.type = const Value.absent(),
    this.attempt = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.result = const Value.absent(),
    this.fee = const Value.absent(),
    this.historyJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExamsCompanion.insert({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    required String id,
    required String enrollmentId,
    required String studentId,
    required String studentName,
    this.carId = const Value.absent(),
    required String type,
    required int attempt,
    required String scheduledDate,
    this.result = const Value.absent(),
    this.fee = const Value.absent(),
    this.historyJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       enrollmentId = Value(enrollmentId),
       studentId = Value(studentId),
       studentName = Value(studentName),
       type = Value(type),
       attempt = Value(attempt),
       scheduledDate = Value(scheduledDate);
  static Insertable<ExamRow> custom({
    Expression<String>? opId,
    Expression<String>? syncState,
    Expression<int>? serverSeq,
    Expression<String>? at,
    Expression<String>? id,
    Expression<String>? enrollmentId,
    Expression<String>? studentId,
    Expression<String>? studentName,
    Expression<String>? carId,
    Expression<String>? type,
    Expression<int>? attempt,
    Expression<String>? scheduledDate,
    Expression<String>? result,
    Expression<int>? fee,
    Expression<String>? historyJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (syncState != null) 'sync_state': syncState,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (at != null) 'at': at,
      if (id != null) 'id': id,
      if (enrollmentId != null) 'enrollment_id': enrollmentId,
      if (studentId != null) 'student_id': studentId,
      if (studentName != null) 'student_name': studentName,
      if (carId != null) 'car_id': carId,
      if (type != null) 'type': type,
      if (attempt != null) 'attempt': attempt,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (result != null) 'result': result,
      if (fee != null) 'fee': fee,
      if (historyJson != null) 'history_json': historyJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExamsCompanion copyWith({
    Value<String?>? opId,
    Value<String>? syncState,
    Value<int?>? serverSeq,
    Value<String?>? at,
    Value<String>? id,
    Value<String>? enrollmentId,
    Value<String>? studentId,
    Value<String>? studentName,
    Value<String?>? carId,
    Value<String>? type,
    Value<int>? attempt,
    Value<String>? scheduledDate,
    Value<String>? result,
    Value<int>? fee,
    Value<String>? historyJson,
    Value<int>? rowid,
  }) {
    return ExamsCompanion(
      opId: opId ?? this.opId,
      syncState: syncState ?? this.syncState,
      serverSeq: serverSeq ?? this.serverSeq,
      at: at ?? this.at,
      id: id ?? this.id,
      enrollmentId: enrollmentId ?? this.enrollmentId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      carId: carId ?? this.carId,
      type: type ?? this.type,
      attempt: attempt ?? this.attempt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      result: result ?? this.result,
      fee: fee ?? this.fee,
      historyJson: historyJson ?? this.historyJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (enrollmentId.present) {
      map['enrollment_id'] = Variable<String>(enrollmentId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (studentName.present) {
      map['student_name'] = Variable<String>(studentName.value);
    }
    if (carId.present) {
      map['car_id'] = Variable<String>(carId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<String>(scheduledDate.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (fee.present) {
      map['fee'] = Variable<int>(fee.value);
    }
    if (historyJson.present) {
      map['history_json'] = Variable<String>(historyJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamsCompanion(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('enrollmentId: $enrollmentId, ')
          ..write('studentId: $studentId, ')
          ..write('studentName: $studentName, ')
          ..write('carId: $carId, ')
          ..write('type: $type, ')
          ..write('attempt: $attempt, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('result: $result, ')
          ..write('fee: $fee, ')
          ..write('historyJson: $historyJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalaryRatesTable extends SalaryRates
    with TableInfo<$SalaryRatesTable, SalaryRateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalaryRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  @override
  late final GeneratedColumn<String> effectiveFrom = GeneratedColumn<String>(
    'effective_from',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyAmountMeta = const VerificationMeta(
    'monthlyAmount',
  );
  @override
  late final GeneratedColumn<int> monthlyAmount = GeneratedColumn<int>(
    'monthly_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    employeeId,
    effectiveFrom,
    monthlyAmount,
    serverSeq,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'salary_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<SalaryRateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    if (data.containsKey('monthly_amount')) {
      context.handle(
        _monthlyAmountMeta,
        monthlyAmount.isAcceptableOrUnknown(
          data['monthly_amount']!,
          _monthlyAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyAmountMeta);
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SalaryRateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalaryRateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      )!,
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_from'],
      )!,
      monthlyAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_amount'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
    );
  }

  @override
  $SalaryRatesTable createAlias(String alias) {
    return $SalaryRatesTable(attachedDatabase, alias);
  }
}

class SalaryRateRow extends DataClass implements Insertable<SalaryRateRow> {
  final String id;
  final String employeeId;

  /// YYYY-MM
  final String effectiveFrom;
  final int monthlyAmount;
  final int? serverSeq;
  const SalaryRateRow({
    required this.id,
    required this.employeeId,
    required this.effectiveFrom,
    required this.monthlyAmount,
    this.serverSeq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['employee_id'] = Variable<String>(employeeId);
    map['effective_from'] = Variable<String>(effectiveFrom);
    map['monthly_amount'] = Variable<int>(monthlyAmount);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    return map;
  }

  SalaryRatesCompanion toCompanion(bool nullToAbsent) {
    return SalaryRatesCompanion(
      id: Value(id),
      employeeId: Value(employeeId),
      effectiveFrom: Value(effectiveFrom),
      monthlyAmount: Value(monthlyAmount),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
    );
  }

  factory SalaryRateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalaryRateRow(
      id: serializer.fromJson<String>(json['id']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
      effectiveFrom: serializer.fromJson<String>(json['effectiveFrom']),
      monthlyAmount: serializer.fromJson<int>(json['monthlyAmount']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'employeeId': serializer.toJson<String>(employeeId),
      'effectiveFrom': serializer.toJson<String>(effectiveFrom),
      'monthlyAmount': serializer.toJson<int>(monthlyAmount),
      'serverSeq': serializer.toJson<int?>(serverSeq),
    };
  }

  SalaryRateRow copyWith({
    String? id,
    String? employeeId,
    String? effectiveFrom,
    int? monthlyAmount,
    Value<int?> serverSeq = const Value.absent(),
  }) => SalaryRateRow(
    id: id ?? this.id,
    employeeId: employeeId ?? this.employeeId,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    monthlyAmount: monthlyAmount ?? this.monthlyAmount,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
  );
  SalaryRateRow copyWithCompanion(SalaryRatesCompanion data) {
    return SalaryRateRow(
      id: data.id.present ? data.id.value : this.id,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
      monthlyAmount: data.monthlyAmount.present
          ? data.monthlyAmount.value
          : this.monthlyAmount,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalaryRateRow(')
          ..write('id: $id, ')
          ..write('employeeId: $employeeId, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('monthlyAmount: $monthlyAmount, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, employeeId, effectiveFrom, monthlyAmount, serverSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalaryRateRow &&
          other.id == this.id &&
          other.employeeId == this.employeeId &&
          other.effectiveFrom == this.effectiveFrom &&
          other.monthlyAmount == this.monthlyAmount &&
          other.serverSeq == this.serverSeq);
}

class SalaryRatesCompanion extends UpdateCompanion<SalaryRateRow> {
  final Value<String> id;
  final Value<String> employeeId;
  final Value<String> effectiveFrom;
  final Value<int> monthlyAmount;
  final Value<int?> serverSeq;
  final Value<int> rowid;
  const SalaryRatesCompanion({
    this.id = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.monthlyAmount = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalaryRatesCompanion.insert({
    required String id,
    required String employeeId,
    required String effectiveFrom,
    required int monthlyAmount,
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       employeeId = Value(employeeId),
       effectiveFrom = Value(effectiveFrom),
       monthlyAmount = Value(monthlyAmount);
  static Insertable<SalaryRateRow> custom({
    Expression<String>? id,
    Expression<String>? employeeId,
    Expression<String>? effectiveFrom,
    Expression<int>? monthlyAmount,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (employeeId != null) 'employee_id': employeeId,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (monthlyAmount != null) 'monthly_amount': monthlyAmount,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalaryRatesCompanion copyWith({
    Value<String>? id,
    Value<String>? employeeId,
    Value<String>? effectiveFrom,
    Value<int>? monthlyAmount,
    Value<int?>? serverSeq,
    Value<int>? rowid,
  }) {
    return SalaryRatesCompanion(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<String>(effectiveFrom.value);
    }
    if (monthlyAmount.present) {
      map['monthly_amount'] = Variable<int>(monthlyAmount.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalaryRatesCompanion(')
          ..write('id: $id, ')
          ..write('employeeId: $employeeId, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('monthlyAmount: $monthlyAmount, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PayrollItemsTable extends PayrollItems
    with TableInfo<$PayrollItemsTable, PayrollItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayrollItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeNameMeta = const VerificationMeta(
    'employeeName',
  );
  @override
  late final GeneratedColumn<String> employeeName = GeneratedColumn<String>(
    'employee_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payrollMonthMeta = const VerificationMeta(
    'payrollMonth',
  );
  @override
  late final GeneratedColumn<String> payrollMonth = GeneratedColumn<String>(
    'payroll_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedByNameMeta = const VerificationMeta(
    'recordedByName',
  );
  @override
  late final GeneratedColumn<String> recordedByName = GeneratedColumn<String>(
    'recorded_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    syncState,
    serverSeq,
    at,
    id,
    employeeId,
    employeeName,
    payrollMonth,
    kind,
    reason,
    note,
    amount,
    accountId,
    businessDate,
    recordedByName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payroll_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PayrollItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('employee_name')) {
      context.handle(
        _employeeNameMeta,
        employeeName.isAcceptableOrUnknown(
          data['employee_name']!,
          _employeeNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employeeNameMeta);
    }
    if (data.containsKey('payroll_month')) {
      context.handle(
        _payrollMonthMeta,
        payrollMonth.isAcceptableOrUnknown(
          data['payroll_month']!,
          _payrollMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payrollMonthMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('recorded_by_name')) {
      context.handle(
        _recordedByNameMeta,
        recordedByName.isAcceptableOrUnknown(
          data['recorded_by_name']!,
          _recordedByNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PayrollItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayrollItemRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      )!,
      employeeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_name'],
      )!,
      payrollMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payroll_month'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      recordedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recorded_by_name'],
      ),
    );
  }

  @override
  $PayrollItemsTable createAlias(String alias) {
    return $PayrollItemsTable(attachedDatabase, alias);
  }
}

class PayrollItemRow extends DataClass implements Insertable<PayrollItemRow> {
  /// The op that created/changed this row (links local rows to outbox results).
  final String? opId;

  /// pending | synced | rejected
  final String syncState;
  final int? serverSeq;

  /// When it happened (ISO-8601): device time while pending, server time once synced.
  final String? at;
  final String id;
  final String employeeId;
  final String employeeName;

  /// YYYY-MM
  final String payrollMonth;

  /// advance | deduction | bonus
  final String kind;
  final String reason;
  final String? note;
  final int amount;
  final String? accountId;
  final String businessDate;
  final String? recordedByName;
  const PayrollItemRow({
    this.opId,
    required this.syncState,
    this.serverSeq,
    this.at,
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.payrollMonth,
    required this.kind,
    required this.reason,
    this.note,
    required this.amount,
    this.accountId,
    required this.businessDate,
    this.recordedByName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || opId != null) {
      map['op_id'] = Variable<String>(opId);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    if (!nullToAbsent || at != null) {
      map['at'] = Variable<String>(at);
    }
    map['id'] = Variable<String>(id);
    map['employee_id'] = Variable<String>(employeeId);
    map['employee_name'] = Variable<String>(employeeName);
    map['payroll_month'] = Variable<String>(payrollMonth);
    map['kind'] = Variable<String>(kind);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    map['business_date'] = Variable<String>(businessDate);
    if (!nullToAbsent || recordedByName != null) {
      map['recorded_by_name'] = Variable<String>(recordedByName);
    }
    return map;
  }

  PayrollItemsCompanion toCompanion(bool nullToAbsent) {
    return PayrollItemsCompanion(
      opId: opId == null && nullToAbsent ? const Value.absent() : Value(opId),
      syncState: Value(syncState),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      at: at == null && nullToAbsent ? const Value.absent() : Value(at),
      id: Value(id),
      employeeId: Value(employeeId),
      employeeName: Value(employeeName),
      payrollMonth: Value(payrollMonth),
      kind: Value(kind),
      reason: Value(reason),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      amount: Value(amount),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      businessDate: Value(businessDate),
      recordedByName: recordedByName == null && nullToAbsent
          ? const Value.absent()
          : Value(recordedByName),
    );
  }

  factory PayrollItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayrollItemRow(
      opId: serializer.fromJson<String?>(json['opId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      at: serializer.fromJson<String?>(json['at']),
      id: serializer.fromJson<String>(json['id']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
      employeeName: serializer.fromJson<String>(json['employeeName']),
      payrollMonth: serializer.fromJson<String>(json['payrollMonth']),
      kind: serializer.fromJson<String>(json['kind']),
      reason: serializer.fromJson<String>(json['reason']),
      note: serializer.fromJson<String?>(json['note']),
      amount: serializer.fromJson<int>(json['amount']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      recordedByName: serializer.fromJson<String?>(json['recordedByName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String?>(opId),
      'syncState': serializer.toJson<String>(syncState),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'at': serializer.toJson<String?>(at),
      'id': serializer.toJson<String>(id),
      'employeeId': serializer.toJson<String>(employeeId),
      'employeeName': serializer.toJson<String>(employeeName),
      'payrollMonth': serializer.toJson<String>(payrollMonth),
      'kind': serializer.toJson<String>(kind),
      'reason': serializer.toJson<String>(reason),
      'note': serializer.toJson<String?>(note),
      'amount': serializer.toJson<int>(amount),
      'accountId': serializer.toJson<String?>(accountId),
      'businessDate': serializer.toJson<String>(businessDate),
      'recordedByName': serializer.toJson<String?>(recordedByName),
    };
  }

  PayrollItemRow copyWith({
    Value<String?> opId = const Value.absent(),
    String? syncState,
    Value<int?> serverSeq = const Value.absent(),
    Value<String?> at = const Value.absent(),
    String? id,
    String? employeeId,
    String? employeeName,
    String? payrollMonth,
    String? kind,
    String? reason,
    Value<String?> note = const Value.absent(),
    int? amount,
    Value<String?> accountId = const Value.absent(),
    String? businessDate,
    Value<String?> recordedByName = const Value.absent(),
  }) => PayrollItemRow(
    opId: opId.present ? opId.value : this.opId,
    syncState: syncState ?? this.syncState,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    at: at.present ? at.value : this.at,
    id: id ?? this.id,
    employeeId: employeeId ?? this.employeeId,
    employeeName: employeeName ?? this.employeeName,
    payrollMonth: payrollMonth ?? this.payrollMonth,
    kind: kind ?? this.kind,
    reason: reason ?? this.reason,
    note: note.present ? note.value : this.note,
    amount: amount ?? this.amount,
    accountId: accountId.present ? accountId.value : this.accountId,
    businessDate: businessDate ?? this.businessDate,
    recordedByName: recordedByName.present
        ? recordedByName.value
        : this.recordedByName,
  );
  PayrollItemRow copyWithCompanion(PayrollItemsCompanion data) {
    return PayrollItemRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      at: data.at.present ? data.at.value : this.at,
      id: data.id.present ? data.id.value : this.id,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      employeeName: data.employeeName.present
          ? data.employeeName.value
          : this.employeeName,
      payrollMonth: data.payrollMonth.present
          ? data.payrollMonth.value
          : this.payrollMonth,
      kind: data.kind.present ? data.kind.value : this.kind,
      reason: data.reason.present ? data.reason.value : this.reason,
      note: data.note.present ? data.note.value : this.note,
      amount: data.amount.present ? data.amount.value : this.amount,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      recordedByName: data.recordedByName.present
          ? data.recordedByName.value
          : this.recordedByName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayrollItemRow(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('employeeId: $employeeId, ')
          ..write('employeeName: $employeeName, ')
          ..write('payrollMonth: $payrollMonth, ')
          ..write('kind: $kind, ')
          ..write('reason: $reason, ')
          ..write('note: $note, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('businessDate: $businessDate, ')
          ..write('recordedByName: $recordedByName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    syncState,
    serverSeq,
    at,
    id,
    employeeId,
    employeeName,
    payrollMonth,
    kind,
    reason,
    note,
    amount,
    accountId,
    businessDate,
    recordedByName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayrollItemRow &&
          other.opId == this.opId &&
          other.syncState == this.syncState &&
          other.serverSeq == this.serverSeq &&
          other.at == this.at &&
          other.id == this.id &&
          other.employeeId == this.employeeId &&
          other.employeeName == this.employeeName &&
          other.payrollMonth == this.payrollMonth &&
          other.kind == this.kind &&
          other.reason == this.reason &&
          other.note == this.note &&
          other.amount == this.amount &&
          other.accountId == this.accountId &&
          other.businessDate == this.businessDate &&
          other.recordedByName == this.recordedByName);
}

class PayrollItemsCompanion extends UpdateCompanion<PayrollItemRow> {
  final Value<String?> opId;
  final Value<String> syncState;
  final Value<int?> serverSeq;
  final Value<String?> at;
  final Value<String> id;
  final Value<String> employeeId;
  final Value<String> employeeName;
  final Value<String> payrollMonth;
  final Value<String> kind;
  final Value<String> reason;
  final Value<String?> note;
  final Value<int> amount;
  final Value<String?> accountId;
  final Value<String> businessDate;
  final Value<String?> recordedByName;
  final Value<int> rowid;
  const PayrollItemsCompanion({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    this.id = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.employeeName = const Value.absent(),
    this.payrollMonth = const Value.absent(),
    this.kind = const Value.absent(),
    this.reason = const Value.absent(),
    this.note = const Value.absent(),
    this.amount = const Value.absent(),
    this.accountId = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.recordedByName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PayrollItemsCompanion.insert({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    required String id,
    required String employeeId,
    required String employeeName,
    required String payrollMonth,
    required String kind,
    required String reason,
    this.note = const Value.absent(),
    required int amount,
    this.accountId = const Value.absent(),
    required String businessDate,
    this.recordedByName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       employeeId = Value(employeeId),
       employeeName = Value(employeeName),
       payrollMonth = Value(payrollMonth),
       kind = Value(kind),
       reason = Value(reason),
       amount = Value(amount),
       businessDate = Value(businessDate);
  static Insertable<PayrollItemRow> custom({
    Expression<String>? opId,
    Expression<String>? syncState,
    Expression<int>? serverSeq,
    Expression<String>? at,
    Expression<String>? id,
    Expression<String>? employeeId,
    Expression<String>? employeeName,
    Expression<String>? payrollMonth,
    Expression<String>? kind,
    Expression<String>? reason,
    Expression<String>? note,
    Expression<int>? amount,
    Expression<String>? accountId,
    Expression<String>? businessDate,
    Expression<String>? recordedByName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (syncState != null) 'sync_state': syncState,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (at != null) 'at': at,
      if (id != null) 'id': id,
      if (employeeId != null) 'employee_id': employeeId,
      if (employeeName != null) 'employee_name': employeeName,
      if (payrollMonth != null) 'payroll_month': payrollMonth,
      if (kind != null) 'kind': kind,
      if (reason != null) 'reason': reason,
      if (note != null) 'note': note,
      if (amount != null) 'amount': amount,
      if (accountId != null) 'account_id': accountId,
      if (businessDate != null) 'business_date': businessDate,
      if (recordedByName != null) 'recorded_by_name': recordedByName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PayrollItemsCompanion copyWith({
    Value<String?>? opId,
    Value<String>? syncState,
    Value<int?>? serverSeq,
    Value<String?>? at,
    Value<String>? id,
    Value<String>? employeeId,
    Value<String>? employeeName,
    Value<String>? payrollMonth,
    Value<String>? kind,
    Value<String>? reason,
    Value<String?>? note,
    Value<int>? amount,
    Value<String?>? accountId,
    Value<String>? businessDate,
    Value<String?>? recordedByName,
    Value<int>? rowid,
  }) {
    return PayrollItemsCompanion(
      opId: opId ?? this.opId,
      syncState: syncState ?? this.syncState,
      serverSeq: serverSeq ?? this.serverSeq,
      at: at ?? this.at,
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      payrollMonth: payrollMonth ?? this.payrollMonth,
      kind: kind ?? this.kind,
      reason: reason ?? this.reason,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      businessDate: businessDate ?? this.businessDate,
      recordedByName: recordedByName ?? this.recordedByName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (employeeName.present) {
      map['employee_name'] = Variable<String>(employeeName.value);
    }
    if (payrollMonth.present) {
      map['payroll_month'] = Variable<String>(payrollMonth.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (recordedByName.present) {
      map['recorded_by_name'] = Variable<String>(recordedByName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayrollItemsCompanion(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('employeeId: $employeeId, ')
          ..write('employeeName: $employeeName, ')
          ..write('payrollMonth: $payrollMonth, ')
          ..write('kind: $kind, ')
          ..write('reason: $reason, ')
          ..write('note: $note, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('businessDate: $businessDate, ')
          ..write('recordedByName: $recordedByName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalaryPaymentsTable extends SalaryPayments
    with TableInfo<$SalaryPaymentsTable, SalaryPaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalaryPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeNameMeta = const VerificationMeta(
    'employeeName',
  );
  @override
  late final GeneratedColumn<String> employeeName = GeneratedColumn<String>(
    'employee_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payrollMonthMeta = const VerificationMeta(
    'payrollMonth',
  );
  @override
  late final GeneratedColumn<String> payrollMonth = GeneratedColumn<String>(
    'payroll_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _salaryAtMonthMeta = const VerificationMeta(
    'salaryAtMonth',
  );
  @override
  late final GeneratedColumn<int> salaryAtMonth = GeneratedColumn<int>(
    'salary_at_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bonusesMeta = const VerificationMeta(
    'bonuses',
  );
  @override
  late final GeneratedColumn<int> bonuses = GeneratedColumn<int>(
    'bonuses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deductionsMeta = const VerificationMeta(
    'deductions',
  );
  @override
  late final GeneratedColumn<int> deductions = GeneratedColumn<int>(
    'deductions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _advancesMeta = const VerificationMeta(
    'advances',
  );
  @override
  late final GeneratedColumn<int> advances = GeneratedColumn<int>(
    'advances',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _netMeta = const VerificationMeta('net');
  @override
  late final GeneratedColumn<int> net = GeneratedColumn<int>(
    'net',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _earlyMeta = const VerificationMeta('early');
  @override
  late final GeneratedColumn<bool> early = GeneratedColumn<bool>(
    'early',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("early" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _paidByNameMeta = const VerificationMeta(
    'paidByName',
  );
  @override
  late final GeneratedColumn<String> paidByName = GeneratedColumn<String>(
    'paid_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    syncState,
    serverSeq,
    at,
    id,
    employeeId,
    employeeName,
    payrollMonth,
    salaryAtMonth,
    bonuses,
    deductions,
    advances,
    net,
    accountId,
    businessDate,
    early,
    paidByName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'salary_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<SalaryPaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('employee_name')) {
      context.handle(
        _employeeNameMeta,
        employeeName.isAcceptableOrUnknown(
          data['employee_name']!,
          _employeeNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employeeNameMeta);
    }
    if (data.containsKey('payroll_month')) {
      context.handle(
        _payrollMonthMeta,
        payrollMonth.isAcceptableOrUnknown(
          data['payroll_month']!,
          _payrollMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payrollMonthMeta);
    }
    if (data.containsKey('salary_at_month')) {
      context.handle(
        _salaryAtMonthMeta,
        salaryAtMonth.isAcceptableOrUnknown(
          data['salary_at_month']!,
          _salaryAtMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_salaryAtMonthMeta);
    }
    if (data.containsKey('bonuses')) {
      context.handle(
        _bonusesMeta,
        bonuses.isAcceptableOrUnknown(data['bonuses']!, _bonusesMeta),
      );
    } else if (isInserting) {
      context.missing(_bonusesMeta);
    }
    if (data.containsKey('deductions')) {
      context.handle(
        _deductionsMeta,
        deductions.isAcceptableOrUnknown(data['deductions']!, _deductionsMeta),
      );
    } else if (isInserting) {
      context.missing(_deductionsMeta);
    }
    if (data.containsKey('advances')) {
      context.handle(
        _advancesMeta,
        advances.isAcceptableOrUnknown(data['advances']!, _advancesMeta),
      );
    } else if (isInserting) {
      context.missing(_advancesMeta);
    }
    if (data.containsKey('net')) {
      context.handle(
        _netMeta,
        net.isAcceptableOrUnknown(data['net']!, _netMeta),
      );
    } else if (isInserting) {
      context.missing(_netMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('early')) {
      context.handle(
        _earlyMeta,
        early.isAcceptableOrUnknown(data['early']!, _earlyMeta),
      );
    }
    if (data.containsKey('paid_by_name')) {
      context.handle(
        _paidByNameMeta,
        paidByName.isAcceptableOrUnknown(
          data['paid_by_name']!,
          _paidByNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SalaryPaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalaryPaymentRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      )!,
      employeeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_name'],
      )!,
      payrollMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payroll_month'],
      )!,
      salaryAtMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}salary_at_month'],
      )!,
      bonuses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bonuses'],
      )!,
      deductions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deductions'],
      )!,
      advances: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}advances'],
      )!,
      net: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}net'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      early: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}early'],
      )!,
      paidByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_by_name'],
      ),
    );
  }

  @override
  $SalaryPaymentsTable createAlias(String alias) {
    return $SalaryPaymentsTable(attachedDatabase, alias);
  }
}

class SalaryPaymentRow extends DataClass
    implements Insertable<SalaryPaymentRow> {
  /// The op that created/changed this row (links local rows to outbox results).
  final String? opId;

  /// pending | synced | rejected
  final String syncState;
  final int? serverSeq;

  /// When it happened (ISO-8601): device time while pending, server time once synced.
  final String? at;
  final String id;
  final String employeeId;
  final String employeeName;
  final String payrollMonth;
  final int salaryAtMonth;
  final int bonuses;
  final int deductions;
  final int advances;
  final int net;
  final String accountId;
  final String businessDate;
  final bool early;
  final String? paidByName;
  const SalaryPaymentRow({
    this.opId,
    required this.syncState,
    this.serverSeq,
    this.at,
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.payrollMonth,
    required this.salaryAtMonth,
    required this.bonuses,
    required this.deductions,
    required this.advances,
    required this.net,
    required this.accountId,
    required this.businessDate,
    required this.early,
    this.paidByName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || opId != null) {
      map['op_id'] = Variable<String>(opId);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    if (!nullToAbsent || at != null) {
      map['at'] = Variable<String>(at);
    }
    map['id'] = Variable<String>(id);
    map['employee_id'] = Variable<String>(employeeId);
    map['employee_name'] = Variable<String>(employeeName);
    map['payroll_month'] = Variable<String>(payrollMonth);
    map['salary_at_month'] = Variable<int>(salaryAtMonth);
    map['bonuses'] = Variable<int>(bonuses);
    map['deductions'] = Variable<int>(deductions);
    map['advances'] = Variable<int>(advances);
    map['net'] = Variable<int>(net);
    map['account_id'] = Variable<String>(accountId);
    map['business_date'] = Variable<String>(businessDate);
    map['early'] = Variable<bool>(early);
    if (!nullToAbsent || paidByName != null) {
      map['paid_by_name'] = Variable<String>(paidByName);
    }
    return map;
  }

  SalaryPaymentsCompanion toCompanion(bool nullToAbsent) {
    return SalaryPaymentsCompanion(
      opId: opId == null && nullToAbsent ? const Value.absent() : Value(opId),
      syncState: Value(syncState),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      at: at == null && nullToAbsent ? const Value.absent() : Value(at),
      id: Value(id),
      employeeId: Value(employeeId),
      employeeName: Value(employeeName),
      payrollMonth: Value(payrollMonth),
      salaryAtMonth: Value(salaryAtMonth),
      bonuses: Value(bonuses),
      deductions: Value(deductions),
      advances: Value(advances),
      net: Value(net),
      accountId: Value(accountId),
      businessDate: Value(businessDate),
      early: Value(early),
      paidByName: paidByName == null && nullToAbsent
          ? const Value.absent()
          : Value(paidByName),
    );
  }

  factory SalaryPaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalaryPaymentRow(
      opId: serializer.fromJson<String?>(json['opId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      at: serializer.fromJson<String?>(json['at']),
      id: serializer.fromJson<String>(json['id']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
      employeeName: serializer.fromJson<String>(json['employeeName']),
      payrollMonth: serializer.fromJson<String>(json['payrollMonth']),
      salaryAtMonth: serializer.fromJson<int>(json['salaryAtMonth']),
      bonuses: serializer.fromJson<int>(json['bonuses']),
      deductions: serializer.fromJson<int>(json['deductions']),
      advances: serializer.fromJson<int>(json['advances']),
      net: serializer.fromJson<int>(json['net']),
      accountId: serializer.fromJson<String>(json['accountId']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      early: serializer.fromJson<bool>(json['early']),
      paidByName: serializer.fromJson<String?>(json['paidByName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String?>(opId),
      'syncState': serializer.toJson<String>(syncState),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'at': serializer.toJson<String?>(at),
      'id': serializer.toJson<String>(id),
      'employeeId': serializer.toJson<String>(employeeId),
      'employeeName': serializer.toJson<String>(employeeName),
      'payrollMonth': serializer.toJson<String>(payrollMonth),
      'salaryAtMonth': serializer.toJson<int>(salaryAtMonth),
      'bonuses': serializer.toJson<int>(bonuses),
      'deductions': serializer.toJson<int>(deductions),
      'advances': serializer.toJson<int>(advances),
      'net': serializer.toJson<int>(net),
      'accountId': serializer.toJson<String>(accountId),
      'businessDate': serializer.toJson<String>(businessDate),
      'early': serializer.toJson<bool>(early),
      'paidByName': serializer.toJson<String?>(paidByName),
    };
  }

  SalaryPaymentRow copyWith({
    Value<String?> opId = const Value.absent(),
    String? syncState,
    Value<int?> serverSeq = const Value.absent(),
    Value<String?> at = const Value.absent(),
    String? id,
    String? employeeId,
    String? employeeName,
    String? payrollMonth,
    int? salaryAtMonth,
    int? bonuses,
    int? deductions,
    int? advances,
    int? net,
    String? accountId,
    String? businessDate,
    bool? early,
    Value<String?> paidByName = const Value.absent(),
  }) => SalaryPaymentRow(
    opId: opId.present ? opId.value : this.opId,
    syncState: syncState ?? this.syncState,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    at: at.present ? at.value : this.at,
    id: id ?? this.id,
    employeeId: employeeId ?? this.employeeId,
    employeeName: employeeName ?? this.employeeName,
    payrollMonth: payrollMonth ?? this.payrollMonth,
    salaryAtMonth: salaryAtMonth ?? this.salaryAtMonth,
    bonuses: bonuses ?? this.bonuses,
    deductions: deductions ?? this.deductions,
    advances: advances ?? this.advances,
    net: net ?? this.net,
    accountId: accountId ?? this.accountId,
    businessDate: businessDate ?? this.businessDate,
    early: early ?? this.early,
    paidByName: paidByName.present ? paidByName.value : this.paidByName,
  );
  SalaryPaymentRow copyWithCompanion(SalaryPaymentsCompanion data) {
    return SalaryPaymentRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      at: data.at.present ? data.at.value : this.at,
      id: data.id.present ? data.id.value : this.id,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      employeeName: data.employeeName.present
          ? data.employeeName.value
          : this.employeeName,
      payrollMonth: data.payrollMonth.present
          ? data.payrollMonth.value
          : this.payrollMonth,
      salaryAtMonth: data.salaryAtMonth.present
          ? data.salaryAtMonth.value
          : this.salaryAtMonth,
      bonuses: data.bonuses.present ? data.bonuses.value : this.bonuses,
      deductions: data.deductions.present
          ? data.deductions.value
          : this.deductions,
      advances: data.advances.present ? data.advances.value : this.advances,
      net: data.net.present ? data.net.value : this.net,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      early: data.early.present ? data.early.value : this.early,
      paidByName: data.paidByName.present
          ? data.paidByName.value
          : this.paidByName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalaryPaymentRow(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('employeeId: $employeeId, ')
          ..write('employeeName: $employeeName, ')
          ..write('payrollMonth: $payrollMonth, ')
          ..write('salaryAtMonth: $salaryAtMonth, ')
          ..write('bonuses: $bonuses, ')
          ..write('deductions: $deductions, ')
          ..write('advances: $advances, ')
          ..write('net: $net, ')
          ..write('accountId: $accountId, ')
          ..write('businessDate: $businessDate, ')
          ..write('early: $early, ')
          ..write('paidByName: $paidByName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    syncState,
    serverSeq,
    at,
    id,
    employeeId,
    employeeName,
    payrollMonth,
    salaryAtMonth,
    bonuses,
    deductions,
    advances,
    net,
    accountId,
    businessDate,
    early,
    paidByName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalaryPaymentRow &&
          other.opId == this.opId &&
          other.syncState == this.syncState &&
          other.serverSeq == this.serverSeq &&
          other.at == this.at &&
          other.id == this.id &&
          other.employeeId == this.employeeId &&
          other.employeeName == this.employeeName &&
          other.payrollMonth == this.payrollMonth &&
          other.salaryAtMonth == this.salaryAtMonth &&
          other.bonuses == this.bonuses &&
          other.deductions == this.deductions &&
          other.advances == this.advances &&
          other.net == this.net &&
          other.accountId == this.accountId &&
          other.businessDate == this.businessDate &&
          other.early == this.early &&
          other.paidByName == this.paidByName);
}

class SalaryPaymentsCompanion extends UpdateCompanion<SalaryPaymentRow> {
  final Value<String?> opId;
  final Value<String> syncState;
  final Value<int?> serverSeq;
  final Value<String?> at;
  final Value<String> id;
  final Value<String> employeeId;
  final Value<String> employeeName;
  final Value<String> payrollMonth;
  final Value<int> salaryAtMonth;
  final Value<int> bonuses;
  final Value<int> deductions;
  final Value<int> advances;
  final Value<int> net;
  final Value<String> accountId;
  final Value<String> businessDate;
  final Value<bool> early;
  final Value<String?> paidByName;
  final Value<int> rowid;
  const SalaryPaymentsCompanion({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    this.id = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.employeeName = const Value.absent(),
    this.payrollMonth = const Value.absent(),
    this.salaryAtMonth = const Value.absent(),
    this.bonuses = const Value.absent(),
    this.deductions = const Value.absent(),
    this.advances = const Value.absent(),
    this.net = const Value.absent(),
    this.accountId = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.early = const Value.absent(),
    this.paidByName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalaryPaymentsCompanion.insert({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    required String id,
    required String employeeId,
    required String employeeName,
    required String payrollMonth,
    required int salaryAtMonth,
    required int bonuses,
    required int deductions,
    required int advances,
    required int net,
    required String accountId,
    required String businessDate,
    this.early = const Value.absent(),
    this.paidByName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       employeeId = Value(employeeId),
       employeeName = Value(employeeName),
       payrollMonth = Value(payrollMonth),
       salaryAtMonth = Value(salaryAtMonth),
       bonuses = Value(bonuses),
       deductions = Value(deductions),
       advances = Value(advances),
       net = Value(net),
       accountId = Value(accountId),
       businessDate = Value(businessDate);
  static Insertable<SalaryPaymentRow> custom({
    Expression<String>? opId,
    Expression<String>? syncState,
    Expression<int>? serverSeq,
    Expression<String>? at,
    Expression<String>? id,
    Expression<String>? employeeId,
    Expression<String>? employeeName,
    Expression<String>? payrollMonth,
    Expression<int>? salaryAtMonth,
    Expression<int>? bonuses,
    Expression<int>? deductions,
    Expression<int>? advances,
    Expression<int>? net,
    Expression<String>? accountId,
    Expression<String>? businessDate,
    Expression<bool>? early,
    Expression<String>? paidByName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (syncState != null) 'sync_state': syncState,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (at != null) 'at': at,
      if (id != null) 'id': id,
      if (employeeId != null) 'employee_id': employeeId,
      if (employeeName != null) 'employee_name': employeeName,
      if (payrollMonth != null) 'payroll_month': payrollMonth,
      if (salaryAtMonth != null) 'salary_at_month': salaryAtMonth,
      if (bonuses != null) 'bonuses': bonuses,
      if (deductions != null) 'deductions': deductions,
      if (advances != null) 'advances': advances,
      if (net != null) 'net': net,
      if (accountId != null) 'account_id': accountId,
      if (businessDate != null) 'business_date': businessDate,
      if (early != null) 'early': early,
      if (paidByName != null) 'paid_by_name': paidByName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalaryPaymentsCompanion copyWith({
    Value<String?>? opId,
    Value<String>? syncState,
    Value<int?>? serverSeq,
    Value<String?>? at,
    Value<String>? id,
    Value<String>? employeeId,
    Value<String>? employeeName,
    Value<String>? payrollMonth,
    Value<int>? salaryAtMonth,
    Value<int>? bonuses,
    Value<int>? deductions,
    Value<int>? advances,
    Value<int>? net,
    Value<String>? accountId,
    Value<String>? businessDate,
    Value<bool>? early,
    Value<String?>? paidByName,
    Value<int>? rowid,
  }) {
    return SalaryPaymentsCompanion(
      opId: opId ?? this.opId,
      syncState: syncState ?? this.syncState,
      serverSeq: serverSeq ?? this.serverSeq,
      at: at ?? this.at,
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      payrollMonth: payrollMonth ?? this.payrollMonth,
      salaryAtMonth: salaryAtMonth ?? this.salaryAtMonth,
      bonuses: bonuses ?? this.bonuses,
      deductions: deductions ?? this.deductions,
      advances: advances ?? this.advances,
      net: net ?? this.net,
      accountId: accountId ?? this.accountId,
      businessDate: businessDate ?? this.businessDate,
      early: early ?? this.early,
      paidByName: paidByName ?? this.paidByName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (employeeName.present) {
      map['employee_name'] = Variable<String>(employeeName.value);
    }
    if (payrollMonth.present) {
      map['payroll_month'] = Variable<String>(payrollMonth.value);
    }
    if (salaryAtMonth.present) {
      map['salary_at_month'] = Variable<int>(salaryAtMonth.value);
    }
    if (bonuses.present) {
      map['bonuses'] = Variable<int>(bonuses.value);
    }
    if (deductions.present) {
      map['deductions'] = Variable<int>(deductions.value);
    }
    if (advances.present) {
      map['advances'] = Variable<int>(advances.value);
    }
    if (net.present) {
      map['net'] = Variable<int>(net.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (early.present) {
      map['early'] = Variable<bool>(early.value);
    }
    if (paidByName.present) {
      map['paid_by_name'] = Variable<String>(paidByName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalaryPaymentsCompanion(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('employeeId: $employeeId, ')
          ..write('employeeName: $employeeName, ')
          ..write('payrollMonth: $payrollMonth, ')
          ..write('salaryAtMonth: $salaryAtMonth, ')
          ..write('bonuses: $bonuses, ')
          ..write('deductions: $deductions, ')
          ..write('advances: $advances, ')
          ..write('net: $net, ')
          ..write('accountId: $accountId, ')
          ..write('businessDate: $businessDate, ')
          ..write('early: $early, ')
          ..write('paidByName: $paidByName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppUsersTable extends AppUsers
    with TableInfo<$AppUsersTable, AppUserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nationalIdMeta = const VerificationMeta(
    'nationalId',
  );
  @override
  late final GeneratedColumn<String> nationalId = GeneratedColumn<String>(
    'national_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _jobMeta = const VerificationMeta('job');
  @override
  late final GeneratedColumn<String> job = GeneratedColumn<String>(
    'job',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _permissionsJsonMeta = const VerificationMeta(
    'permissionsJson',
  );
  @override
  late final GeneratedColumn<String> permissionsJson = GeneratedColumn<String>(
    'permissions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _permVersionMeta = const VerificationMeta(
    'permVersion',
  );
  @override
  late final GeneratedColumn<int> permVersion = GeneratedColumn<int>(
    'perm_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    syncState,
    serverSeq,
    at,
    id,
    name,
    nationalId,
    phone,
    kind,
    status,
    job,
    employeeId,
    permissionsJson,
    permVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppUserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('national_id')) {
      context.handle(
        _nationalIdMeta,
        nationalId.isAcceptableOrUnknown(data['national_id']!, _nationalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nationalIdMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('job')) {
      context.handle(
        _jobMeta,
        job.isAcceptableOrUnknown(data['job']!, _jobMeta),
      );
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    }
    if (data.containsKey('permissions_json')) {
      context.handle(
        _permissionsJsonMeta,
        permissionsJson.isAcceptableOrUnknown(
          data['permissions_json']!,
          _permissionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('perm_version')) {
      context.handle(
        _permVersionMeta,
        permVersion.isAcceptableOrUnknown(
          data['perm_version']!,
          _permVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppUserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUserRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nationalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}national_id'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      job: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job'],
      ),
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      ),
      permissionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permissions_json'],
      )!,
      permVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}perm_version'],
      )!,
    );
  }

  @override
  $AppUsersTable createAlias(String alias) {
    return $AppUsersTable(attachedDatabase, alias);
  }
}

class AppUserRow extends DataClass implements Insertable<AppUserRow> {
  /// The op that created/changed this row (links local rows to outbox results).
  final String? opId;

  /// pending | synced | rejected
  final String syncState;
  final int? serverSeq;

  /// When it happened (ISO-8601): device time while pending, server time once synced.
  final String? at;
  final String id;
  final String name;
  final String nationalId;
  final String? phone;

  /// admin | staff | instructor | student
  final String kind;

  /// active | disabled
  final String status;

  /// accountant | secretary | instructor | manager
  final String? job;
  final String? employeeId;

  /// JSON {tasks, allowedAccounts, expenseCategories, discountMax, closeMode, logScope, backdateDays}
  final String permissionsJson;
  final int permVersion;
  const AppUserRow({
    this.opId,
    required this.syncState,
    this.serverSeq,
    this.at,
    required this.id,
    required this.name,
    required this.nationalId,
    this.phone,
    required this.kind,
    required this.status,
    this.job,
    this.employeeId,
    required this.permissionsJson,
    required this.permVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || opId != null) {
      map['op_id'] = Variable<String>(opId);
    }
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    if (!nullToAbsent || at != null) {
      map['at'] = Variable<String>(at);
    }
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['national_id'] = Variable<String>(nationalId);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['kind'] = Variable<String>(kind);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || job != null) {
      map['job'] = Variable<String>(job);
    }
    if (!nullToAbsent || employeeId != null) {
      map['employee_id'] = Variable<String>(employeeId);
    }
    map['permissions_json'] = Variable<String>(permissionsJson);
    map['perm_version'] = Variable<int>(permVersion);
    return map;
  }

  AppUsersCompanion toCompanion(bool nullToAbsent) {
    return AppUsersCompanion(
      opId: opId == null && nullToAbsent ? const Value.absent() : Value(opId),
      syncState: Value(syncState),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      at: at == null && nullToAbsent ? const Value.absent() : Value(at),
      id: Value(id),
      name: Value(name),
      nationalId: Value(nationalId),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      kind: Value(kind),
      status: Value(status),
      job: job == null && nullToAbsent ? const Value.absent() : Value(job),
      employeeId: employeeId == null && nullToAbsent
          ? const Value.absent()
          : Value(employeeId),
      permissionsJson: Value(permissionsJson),
      permVersion: Value(permVersion),
    );
  }

  factory AppUserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUserRow(
      opId: serializer.fromJson<String?>(json['opId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      at: serializer.fromJson<String?>(json['at']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nationalId: serializer.fromJson<String>(json['nationalId']),
      phone: serializer.fromJson<String?>(json['phone']),
      kind: serializer.fromJson<String>(json['kind']),
      status: serializer.fromJson<String>(json['status']),
      job: serializer.fromJson<String?>(json['job']),
      employeeId: serializer.fromJson<String?>(json['employeeId']),
      permissionsJson: serializer.fromJson<String>(json['permissionsJson']),
      permVersion: serializer.fromJson<int>(json['permVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String?>(opId),
      'syncState': serializer.toJson<String>(syncState),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'at': serializer.toJson<String?>(at),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'nationalId': serializer.toJson<String>(nationalId),
      'phone': serializer.toJson<String?>(phone),
      'kind': serializer.toJson<String>(kind),
      'status': serializer.toJson<String>(status),
      'job': serializer.toJson<String?>(job),
      'employeeId': serializer.toJson<String?>(employeeId),
      'permissionsJson': serializer.toJson<String>(permissionsJson),
      'permVersion': serializer.toJson<int>(permVersion),
    };
  }

  AppUserRow copyWith({
    Value<String?> opId = const Value.absent(),
    String? syncState,
    Value<int?> serverSeq = const Value.absent(),
    Value<String?> at = const Value.absent(),
    String? id,
    String? name,
    String? nationalId,
    Value<String?> phone = const Value.absent(),
    String? kind,
    String? status,
    Value<String?> job = const Value.absent(),
    Value<String?> employeeId = const Value.absent(),
    String? permissionsJson,
    int? permVersion,
  }) => AppUserRow(
    opId: opId.present ? opId.value : this.opId,
    syncState: syncState ?? this.syncState,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    at: at.present ? at.value : this.at,
    id: id ?? this.id,
    name: name ?? this.name,
    nationalId: nationalId ?? this.nationalId,
    phone: phone.present ? phone.value : this.phone,
    kind: kind ?? this.kind,
    status: status ?? this.status,
    job: job.present ? job.value : this.job,
    employeeId: employeeId.present ? employeeId.value : this.employeeId,
    permissionsJson: permissionsJson ?? this.permissionsJson,
    permVersion: permVersion ?? this.permVersion,
  );
  AppUserRow copyWithCompanion(AppUsersCompanion data) {
    return AppUserRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      at: data.at.present ? data.at.value : this.at,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nationalId: data.nationalId.present
          ? data.nationalId.value
          : this.nationalId,
      phone: data.phone.present ? data.phone.value : this.phone,
      kind: data.kind.present ? data.kind.value : this.kind,
      status: data.status.present ? data.status.value : this.status,
      job: data.job.present ? data.job.value : this.job,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      permissionsJson: data.permissionsJson.present
          ? data.permissionsJson.value
          : this.permissionsJson,
      permVersion: data.permVersion.present
          ? data.permVersion.value
          : this.permVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUserRow(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nationalId: $nationalId, ')
          ..write('phone: $phone, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('job: $job, ')
          ..write('employeeId: $employeeId, ')
          ..write('permissionsJson: $permissionsJson, ')
          ..write('permVersion: $permVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    syncState,
    serverSeq,
    at,
    id,
    name,
    nationalId,
    phone,
    kind,
    status,
    job,
    employeeId,
    permissionsJson,
    permVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUserRow &&
          other.opId == this.opId &&
          other.syncState == this.syncState &&
          other.serverSeq == this.serverSeq &&
          other.at == this.at &&
          other.id == this.id &&
          other.name == this.name &&
          other.nationalId == this.nationalId &&
          other.phone == this.phone &&
          other.kind == this.kind &&
          other.status == this.status &&
          other.job == this.job &&
          other.employeeId == this.employeeId &&
          other.permissionsJson == this.permissionsJson &&
          other.permVersion == this.permVersion);
}

class AppUsersCompanion extends UpdateCompanion<AppUserRow> {
  final Value<String?> opId;
  final Value<String> syncState;
  final Value<int?> serverSeq;
  final Value<String?> at;
  final Value<String> id;
  final Value<String> name;
  final Value<String> nationalId;
  final Value<String?> phone;
  final Value<String> kind;
  final Value<String> status;
  final Value<String?> job;
  final Value<String?> employeeId;
  final Value<String> permissionsJson;
  final Value<int> permVersion;
  final Value<int> rowid;
  const AppUsersCompanion({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.phone = const Value.absent(),
    this.kind = const Value.absent(),
    this.status = const Value.absent(),
    this.job = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.permissionsJson = const Value.absent(),
    this.permVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppUsersCompanion.insert({
    this.opId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.at = const Value.absent(),
    required String id,
    required String name,
    required String nationalId,
    this.phone = const Value.absent(),
    required String kind,
    this.status = const Value.absent(),
    this.job = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.permissionsJson = const Value.absent(),
    this.permVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       nationalId = Value(nationalId),
       kind = Value(kind);
  static Insertable<AppUserRow> custom({
    Expression<String>? opId,
    Expression<String>? syncState,
    Expression<int>? serverSeq,
    Expression<String>? at,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? nationalId,
    Expression<String>? phone,
    Expression<String>? kind,
    Expression<String>? status,
    Expression<String>? job,
    Expression<String>? employeeId,
    Expression<String>? permissionsJson,
    Expression<int>? permVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (syncState != null) 'sync_state': syncState,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (at != null) 'at': at,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nationalId != null) 'national_id': nationalId,
      if (phone != null) 'phone': phone,
      if (kind != null) 'kind': kind,
      if (status != null) 'status': status,
      if (job != null) 'job': job,
      if (employeeId != null) 'employee_id': employeeId,
      if (permissionsJson != null) 'permissions_json': permissionsJson,
      if (permVersion != null) 'perm_version': permVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppUsersCompanion copyWith({
    Value<String?>? opId,
    Value<String>? syncState,
    Value<int?>? serverSeq,
    Value<String?>? at,
    Value<String>? id,
    Value<String>? name,
    Value<String>? nationalId,
    Value<String?>? phone,
    Value<String>? kind,
    Value<String>? status,
    Value<String?>? job,
    Value<String?>? employeeId,
    Value<String>? permissionsJson,
    Value<int>? permVersion,
    Value<int>? rowid,
  }) {
    return AppUsersCompanion(
      opId: opId ?? this.opId,
      syncState: syncState ?? this.syncState,
      serverSeq: serverSeq ?? this.serverSeq,
      at: at ?? this.at,
      id: id ?? this.id,
      name: name ?? this.name,
      nationalId: nationalId ?? this.nationalId,
      phone: phone ?? this.phone,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      job: job ?? this.job,
      employeeId: employeeId ?? this.employeeId,
      permissionsJson: permissionsJson ?? this.permissionsJson,
      permVersion: permVersion ?? this.permVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nationalId.present) {
      map['national_id'] = Variable<String>(nationalId.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (job.present) {
      map['job'] = Variable<String>(job.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (permissionsJson.present) {
      map['permissions_json'] = Variable<String>(permissionsJson.value);
    }
    if (permVersion.present) {
      map['perm_version'] = Variable<int>(permVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUsersCompanion(')
          ..write('opId: $opId, ')
          ..write('syncState: $syncState, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('at: $at, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nationalId: $nationalId, ')
          ..write('phone: $phone, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('job: $job, ')
          ..write('employeeId: $employeeId, ')
          ..write('permissionsJson: $permissionsJson, ')
          ..write('permVersion: $permVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityLogsTable extends ActivityLogs
    with TableInfo<$ActivityLogsTable, ActivityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  @override
  late final GeneratedColumn<String> opType = GeneratedColumn<String>(
    'op_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordLabelMeta = const VerificationMeta(
    'recordLabel',
  );
  @override
  late final GeneratedColumn<String> recordLabel = GeneratedColumn<String>(
    'record_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changesJsonMeta = const VerificationMeta(
    'changesJson',
  );
  @override
  late final GeneratedColumn<String> changesJson = GeneratedColumn<String>(
    'changes_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorNameMeta = const VerificationMeta(
    'actorName',
  );
  @override
  late final GeneratedColumn<String> actorName = GeneratedColumn<String>(
    'actor_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lateAfterCloseMeta = const VerificationMeta(
    'lateAfterClose',
  );
  @override
  late final GeneratedColumn<bool> lateAfterClose = GeneratedColumn<bool>(
    'late_after_close',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("late_after_close" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    opType,
    entity,
    recordId,
    recordLabel,
    changesJson,
    reason,
    actorId,
    actorName,
    deviceId,
    opId,
    at,
    lateAfterClose,
    serverSeq,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('op_type')) {
      context.handle(
        _opTypeMeta,
        opType.isAcceptableOrUnknown(data['op_type']!, _opTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_opTypeMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('record_label')) {
      context.handle(
        _recordLabelMeta,
        recordLabel.isAcceptableOrUnknown(
          data['record_label']!,
          _recordLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordLabelMeta);
    }
    if (data.containsKey('changes_json')) {
      context.handle(
        _changesJsonMeta,
        changesJson.isAcceptableOrUnknown(
          data['changes_json']!,
          _changesJsonMeta,
        ),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('actor_name')) {
      context.handle(
        _actorNameMeta,
        actorName.isAcceptableOrUnknown(data['actor_name']!, _actorNameMeta),
      );
    } else if (isInserting) {
      context.missing(_actorNameMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('late_after_close')) {
      context.handle(
        _lateAfterCloseMeta,
        lateAfterClose.isAcceptableOrUnknown(
          data['late_after_close']!,
          _lateAfterCloseMeta,
        ),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      opType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_type'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      recordLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_label'],
      )!,
      changesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}changes_json'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      )!,
      actorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_name'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      )!,
      lateAfterClose: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}late_after_close'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
    );
  }

  @override
  $ActivityLogsTable createAlias(String alias) {
    return $ActivityLogsTable(attachedDatabase, alias);
  }
}

class ActivityRow extends DataClass implements Insertable<ActivityRow> {
  final String id;

  /// create | edit | archive | restore | postpone | settings | permission | close | reopen
  final String opType;
  final String entity;
  final String recordId;
  final String recordLabel;

  /// JSON [{field, old, new}]
  final String changesJson;
  final String? reason;
  final String actorId;
  final String actorName;
  final String? deviceId;
  final String? opId;

  /// Server time (ISO-8601).
  final String at;
  final bool lateAfterClose;
  final int? serverSeq;
  const ActivityRow({
    required this.id,
    required this.opType,
    required this.entity,
    required this.recordId,
    required this.recordLabel,
    required this.changesJson,
    this.reason,
    required this.actorId,
    required this.actorName,
    this.deviceId,
    this.opId,
    required this.at,
    required this.lateAfterClose,
    this.serverSeq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['op_type'] = Variable<String>(opType);
    map['entity'] = Variable<String>(entity);
    map['record_id'] = Variable<String>(recordId);
    map['record_label'] = Variable<String>(recordLabel);
    map['changes_json'] = Variable<String>(changesJson);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['actor_id'] = Variable<String>(actorId);
    map['actor_name'] = Variable<String>(actorName);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    if (!nullToAbsent || opId != null) {
      map['op_id'] = Variable<String>(opId);
    }
    map['at'] = Variable<String>(at);
    map['late_after_close'] = Variable<bool>(lateAfterClose);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    return map;
  }

  ActivityLogsCompanion toCompanion(bool nullToAbsent) {
    return ActivityLogsCompanion(
      id: Value(id),
      opType: Value(opType),
      entity: Value(entity),
      recordId: Value(recordId),
      recordLabel: Value(recordLabel),
      changesJson: Value(changesJson),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      actorId: Value(actorId),
      actorName: Value(actorName),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      opId: opId == null && nullToAbsent ? const Value.absent() : Value(opId),
      at: Value(at),
      lateAfterClose: Value(lateAfterClose),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
    );
  }

  factory ActivityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityRow(
      id: serializer.fromJson<String>(json['id']),
      opType: serializer.fromJson<String>(json['opType']),
      entity: serializer.fromJson<String>(json['entity']),
      recordId: serializer.fromJson<String>(json['recordId']),
      recordLabel: serializer.fromJson<String>(json['recordLabel']),
      changesJson: serializer.fromJson<String>(json['changesJson']),
      reason: serializer.fromJson<String?>(json['reason']),
      actorId: serializer.fromJson<String>(json['actorId']),
      actorName: serializer.fromJson<String>(json['actorName']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      opId: serializer.fromJson<String?>(json['opId']),
      at: serializer.fromJson<String>(json['at']),
      lateAfterClose: serializer.fromJson<bool>(json['lateAfterClose']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'opType': serializer.toJson<String>(opType),
      'entity': serializer.toJson<String>(entity),
      'recordId': serializer.toJson<String>(recordId),
      'recordLabel': serializer.toJson<String>(recordLabel),
      'changesJson': serializer.toJson<String>(changesJson),
      'reason': serializer.toJson<String?>(reason),
      'actorId': serializer.toJson<String>(actorId),
      'actorName': serializer.toJson<String>(actorName),
      'deviceId': serializer.toJson<String?>(deviceId),
      'opId': serializer.toJson<String?>(opId),
      'at': serializer.toJson<String>(at),
      'lateAfterClose': serializer.toJson<bool>(lateAfterClose),
      'serverSeq': serializer.toJson<int?>(serverSeq),
    };
  }

  ActivityRow copyWith({
    String? id,
    String? opType,
    String? entity,
    String? recordId,
    String? recordLabel,
    String? changesJson,
    Value<String?> reason = const Value.absent(),
    String? actorId,
    String? actorName,
    Value<String?> deviceId = const Value.absent(),
    Value<String?> opId = const Value.absent(),
    String? at,
    bool? lateAfterClose,
    Value<int?> serverSeq = const Value.absent(),
  }) => ActivityRow(
    id: id ?? this.id,
    opType: opType ?? this.opType,
    entity: entity ?? this.entity,
    recordId: recordId ?? this.recordId,
    recordLabel: recordLabel ?? this.recordLabel,
    changesJson: changesJson ?? this.changesJson,
    reason: reason.present ? reason.value : this.reason,
    actorId: actorId ?? this.actorId,
    actorName: actorName ?? this.actorName,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    opId: opId.present ? opId.value : this.opId,
    at: at ?? this.at,
    lateAfterClose: lateAfterClose ?? this.lateAfterClose,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
  );
  ActivityRow copyWithCompanion(ActivityLogsCompanion data) {
    return ActivityRow(
      id: data.id.present ? data.id.value : this.id,
      opType: data.opType.present ? data.opType.value : this.opType,
      entity: data.entity.present ? data.entity.value : this.entity,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      recordLabel: data.recordLabel.present
          ? data.recordLabel.value
          : this.recordLabel,
      changesJson: data.changesJson.present
          ? data.changesJson.value
          : this.changesJson,
      reason: data.reason.present ? data.reason.value : this.reason,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      actorName: data.actorName.present ? data.actorName.value : this.actorName,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      opId: data.opId.present ? data.opId.value : this.opId,
      at: data.at.present ? data.at.value : this.at,
      lateAfterClose: data.lateAfterClose.present
          ? data.lateAfterClose.value
          : this.lateAfterClose,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityRow(')
          ..write('id: $id, ')
          ..write('opType: $opType, ')
          ..write('entity: $entity, ')
          ..write('recordId: $recordId, ')
          ..write('recordLabel: $recordLabel, ')
          ..write('changesJson: $changesJson, ')
          ..write('reason: $reason, ')
          ..write('actorId: $actorId, ')
          ..write('actorName: $actorName, ')
          ..write('deviceId: $deviceId, ')
          ..write('opId: $opId, ')
          ..write('at: $at, ')
          ..write('lateAfterClose: $lateAfterClose, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    opType,
    entity,
    recordId,
    recordLabel,
    changesJson,
    reason,
    actorId,
    actorName,
    deviceId,
    opId,
    at,
    lateAfterClose,
    serverSeq,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityRow &&
          other.id == this.id &&
          other.opType == this.opType &&
          other.entity == this.entity &&
          other.recordId == this.recordId &&
          other.recordLabel == this.recordLabel &&
          other.changesJson == this.changesJson &&
          other.reason == this.reason &&
          other.actorId == this.actorId &&
          other.actorName == this.actorName &&
          other.deviceId == this.deviceId &&
          other.opId == this.opId &&
          other.at == this.at &&
          other.lateAfterClose == this.lateAfterClose &&
          other.serverSeq == this.serverSeq);
}

class ActivityLogsCompanion extends UpdateCompanion<ActivityRow> {
  final Value<String> id;
  final Value<String> opType;
  final Value<String> entity;
  final Value<String> recordId;
  final Value<String> recordLabel;
  final Value<String> changesJson;
  final Value<String?> reason;
  final Value<String> actorId;
  final Value<String> actorName;
  final Value<String?> deviceId;
  final Value<String?> opId;
  final Value<String> at;
  final Value<bool> lateAfterClose;
  final Value<int?> serverSeq;
  final Value<int> rowid;
  const ActivityLogsCompanion({
    this.id = const Value.absent(),
    this.opType = const Value.absent(),
    this.entity = const Value.absent(),
    this.recordId = const Value.absent(),
    this.recordLabel = const Value.absent(),
    this.changesJson = const Value.absent(),
    this.reason = const Value.absent(),
    this.actorId = const Value.absent(),
    this.actorName = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.opId = const Value.absent(),
    this.at = const Value.absent(),
    this.lateAfterClose = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityLogsCompanion.insert({
    required String id,
    required String opType,
    required String entity,
    required String recordId,
    required String recordLabel,
    this.changesJson = const Value.absent(),
    this.reason = const Value.absent(),
    required String actorId,
    required String actorName,
    this.deviceId = const Value.absent(),
    this.opId = const Value.absent(),
    required String at,
    this.lateAfterClose = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       opType = Value(opType),
       entity = Value(entity),
       recordId = Value(recordId),
       recordLabel = Value(recordLabel),
       actorId = Value(actorId),
       actorName = Value(actorName),
       at = Value(at);
  static Insertable<ActivityRow> custom({
    Expression<String>? id,
    Expression<String>? opType,
    Expression<String>? entity,
    Expression<String>? recordId,
    Expression<String>? recordLabel,
    Expression<String>? changesJson,
    Expression<String>? reason,
    Expression<String>? actorId,
    Expression<String>? actorName,
    Expression<String>? deviceId,
    Expression<String>? opId,
    Expression<String>? at,
    Expression<bool>? lateAfterClose,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (opType != null) 'op_type': opType,
      if (entity != null) 'entity': entity,
      if (recordId != null) 'record_id': recordId,
      if (recordLabel != null) 'record_label': recordLabel,
      if (changesJson != null) 'changes_json': changesJson,
      if (reason != null) 'reason': reason,
      if (actorId != null) 'actor_id': actorId,
      if (actorName != null) 'actor_name': actorName,
      if (deviceId != null) 'device_id': deviceId,
      if (opId != null) 'op_id': opId,
      if (at != null) 'at': at,
      if (lateAfterClose != null) 'late_after_close': lateAfterClose,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? opType,
    Value<String>? entity,
    Value<String>? recordId,
    Value<String>? recordLabel,
    Value<String>? changesJson,
    Value<String?>? reason,
    Value<String>? actorId,
    Value<String>? actorName,
    Value<String?>? deviceId,
    Value<String?>? opId,
    Value<String>? at,
    Value<bool>? lateAfterClose,
    Value<int?>? serverSeq,
    Value<int>? rowid,
  }) {
    return ActivityLogsCompanion(
      id: id ?? this.id,
      opType: opType ?? this.opType,
      entity: entity ?? this.entity,
      recordId: recordId ?? this.recordId,
      recordLabel: recordLabel ?? this.recordLabel,
      changesJson: changesJson ?? this.changesJson,
      reason: reason ?? this.reason,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      deviceId: deviceId ?? this.deviceId,
      opId: opId ?? this.opId,
      at: at ?? this.at,
      lateAfterClose: lateAfterClose ?? this.lateAfterClose,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<String>(opType.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (recordLabel.present) {
      map['record_label'] = Variable<String>(recordLabel.value);
    }
    if (changesJson.present) {
      map['changes_json'] = Variable<String>(changesJson.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (actorName.present) {
      map['actor_name'] = Variable<String>(actorName.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (lateAfterClose.present) {
      map['late_after_close'] = Variable<bool>(lateAfterClose.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogsCompanion(')
          ..write('id: $id, ')
          ..write('opType: $opType, ')
          ..write('entity: $entity, ')
          ..write('recordId: $recordId, ')
          ..write('recordLabel: $recordLabel, ')
          ..write('changesJson: $changesJson, ')
          ..write('reason: $reason, ')
          ..write('actorId: $actorId, ')
          ..write('actorName: $actorName, ')
          ..write('deviceId: $deviceId, ')
          ..write('opId: $opId, ')
          ..write('at: $at, ')
          ..write('lateAfterClose: $lateAfterClose, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MonthLocksTable extends MonthLocks
    with TableInfo<$MonthLocksTable, MonthLockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthLocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lockedByNameMeta = const VerificationMeta(
    'lockedByName',
  );
  @override
  late final GeneratedColumn<String> lockedByName = GeneratedColumn<String>(
    'locked_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unlockReasonMeta = const VerificationMeta(
    'unlockReason',
  );
  @override
  late final GeneratedColumn<String> unlockReason = GeneratedColumn<String>(
    'unlock_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    locked,
    lockedByName,
    unlockReason,
    serverSeq,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'month_locks';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonthLockRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('locked')) {
      context.handle(
        _lockedMeta,
        locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta),
      );
    }
    if (data.containsKey('locked_by_name')) {
      context.handle(
        _lockedByNameMeta,
        lockedByName.isAcceptableOrUnknown(
          data['locked_by_name']!,
          _lockedByNameMeta,
        ),
      );
    }
    if (data.containsKey('unlock_reason')) {
      context.handle(
        _unlockReasonMeta,
        unlockReason.isAcceptableOrUnknown(
          data['unlock_reason']!,
          _unlockReasonMeta,
        ),
      );
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MonthLockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthLockRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      )!,
      lockedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locked_by_name'],
      ),
      unlockReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unlock_reason'],
      ),
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
    );
  }

  @override
  $MonthLocksTable createAlias(String alias) {
    return $MonthLocksTable(attachedDatabase, alias);
  }
}

class MonthLockRow extends DataClass implements Insertable<MonthLockRow> {
  /// YYYY-MM
  final String id;
  final bool locked;
  final String? lockedByName;
  final String? unlockReason;
  final int? serverSeq;
  const MonthLockRow({
    required this.id,
    required this.locked,
    this.lockedByName,
    this.unlockReason,
    this.serverSeq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['locked'] = Variable<bool>(locked);
    if (!nullToAbsent || lockedByName != null) {
      map['locked_by_name'] = Variable<String>(lockedByName);
    }
    if (!nullToAbsent || unlockReason != null) {
      map['unlock_reason'] = Variable<String>(unlockReason);
    }
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    return map;
  }

  MonthLocksCompanion toCompanion(bool nullToAbsent) {
    return MonthLocksCompanion(
      id: Value(id),
      locked: Value(locked),
      lockedByName: lockedByName == null && nullToAbsent
          ? const Value.absent()
          : Value(lockedByName),
      unlockReason: unlockReason == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockReason),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
    );
  }

  factory MonthLockRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthLockRow(
      id: serializer.fromJson<String>(json['id']),
      locked: serializer.fromJson<bool>(json['locked']),
      lockedByName: serializer.fromJson<String?>(json['lockedByName']),
      unlockReason: serializer.fromJson<String?>(json['unlockReason']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'locked': serializer.toJson<bool>(locked),
      'lockedByName': serializer.toJson<String?>(lockedByName),
      'unlockReason': serializer.toJson<String?>(unlockReason),
      'serverSeq': serializer.toJson<int?>(serverSeq),
    };
  }

  MonthLockRow copyWith({
    String? id,
    bool? locked,
    Value<String?> lockedByName = const Value.absent(),
    Value<String?> unlockReason = const Value.absent(),
    Value<int?> serverSeq = const Value.absent(),
  }) => MonthLockRow(
    id: id ?? this.id,
    locked: locked ?? this.locked,
    lockedByName: lockedByName.present ? lockedByName.value : this.lockedByName,
    unlockReason: unlockReason.present ? unlockReason.value : this.unlockReason,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
  );
  MonthLockRow copyWithCompanion(MonthLocksCompanion data) {
    return MonthLockRow(
      id: data.id.present ? data.id.value : this.id,
      locked: data.locked.present ? data.locked.value : this.locked,
      lockedByName: data.lockedByName.present
          ? data.lockedByName.value
          : this.lockedByName,
      unlockReason: data.unlockReason.present
          ? data.unlockReason.value
          : this.unlockReason,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthLockRow(')
          ..write('id: $id, ')
          ..write('locked: $locked, ')
          ..write('lockedByName: $lockedByName, ')
          ..write('unlockReason: $unlockReason, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, locked, lockedByName, unlockReason, serverSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthLockRow &&
          other.id == this.id &&
          other.locked == this.locked &&
          other.lockedByName == this.lockedByName &&
          other.unlockReason == this.unlockReason &&
          other.serverSeq == this.serverSeq);
}

class MonthLocksCompanion extends UpdateCompanion<MonthLockRow> {
  final Value<String> id;
  final Value<bool> locked;
  final Value<String?> lockedByName;
  final Value<String?> unlockReason;
  final Value<int?> serverSeq;
  final Value<int> rowid;
  const MonthLocksCompanion({
    this.id = const Value.absent(),
    this.locked = const Value.absent(),
    this.lockedByName = const Value.absent(),
    this.unlockReason = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonthLocksCompanion.insert({
    required String id,
    this.locked = const Value.absent(),
    this.lockedByName = const Value.absent(),
    this.unlockReason = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<MonthLockRow> custom({
    Expression<String>? id,
    Expression<bool>? locked,
    Expression<String>? lockedByName,
    Expression<String>? unlockReason,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (locked != null) 'locked': locked,
      if (lockedByName != null) 'locked_by_name': lockedByName,
      if (unlockReason != null) 'unlock_reason': unlockReason,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonthLocksCompanion copyWith({
    Value<String>? id,
    Value<bool>? locked,
    Value<String?>? lockedByName,
    Value<String?>? unlockReason,
    Value<int?>? serverSeq,
    Value<int>? rowid,
  }) {
    return MonthLocksCompanion(
      id: id ?? this.id,
      locked: locked ?? this.locked,
      lockedByName: lockedByName ?? this.lockedByName,
      unlockReason: unlockReason ?? this.unlockReason,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    if (lockedByName.present) {
      map['locked_by_name'] = Variable<String>(lockedByName.value);
    }
    if (unlockReason.present) {
      map['unlock_reason'] = Variable<String>(unlockReason.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonthLocksCompanion(')
          ..write('id: $id, ')
          ..write('locked: $locked, ')
          ..write('lockedByName: $lockedByName, ')
          ..write('unlockReason: $unlockReason, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, valueJson, serverSeq];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String valueJson;
  final int? serverSeq;
  const SettingRow({
    required this.key,
    required this.valueJson,
    this.serverSeq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value_json'] = Variable<String>(valueJson);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      valueJson: Value(valueJson),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
    );
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'valueJson': serializer.toJson<String>(valueJson),
      'serverSeq': serializer.toJson<int?>(serverSeq),
    };
  }

  SettingRow copyWith({
    String? key,
    String? valueJson,
    Value<int?> serverSeq = const Value.absent(),
  }) => SettingRow(
    key: key ?? this.key,
    valueJson: valueJson ?? this.valueJson,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
  );
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, valueJson, serverSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.valueJson == this.valueJson &&
          other.serverSeq == this.serverSeq);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> valueJson;
  final Value<int?> serverSeq;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String valueJson,
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       valueJson = Value(valueJson);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? valueJson,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (valueJson != null) 'value_json': valueJson,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? valueJson,
    Value<int?>? serverSeq,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StudentsTable students = $StudentsTable(this);
  late final $EnrollmentsTable enrollments = $EnrollmentsTable(this);
  late final $LessonsTable lessons = $LessonsTable(this);
  late final $LedgerEntriesTable ledgerEntries = $LedgerEntriesTable(this);
  late final $TreasuryMovementsTable treasuryMovements =
      $TreasuryMovementsTable(this);
  late final $LicensePricesTable licensePrices = $LicensePricesTable(this);
  late final $StudentSummariesTable studentSummaries = $StudentSummariesTable(
    this,
  );
  late final $OutboxOpsTable outboxOps = $OutboxOpsTable(this);
  late final $RejectedOpsTable rejectedOps = $RejectedOpsTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $KvEntriesTable kvEntries = $KvEntriesTable(this);
  late final $CarsTable cars = $CarsTable(this);
  late final $CarInstructorsTable carInstructors = $CarInstructorsTable(this);
  late final $EmployeesTable employees = $EmployeesTable(this);
  late final $LicenseTypesTable licenseTypes = $LicenseTypesTable(this);
  late final $TreasuryAccountsTable treasuryAccounts = $TreasuryAccountsTable(
    this,
  );
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $AccountBalancesTable accountBalances = $AccountBalancesTable(
    this,
  );
  late final $DayClosesTable dayCloses = $DayClosesTable(this);
  late final $DayCloseCountsTable dayCloseCounts = $DayCloseCountsTable(this);
  late final $ExamsTable exams = $ExamsTable(this);
  late final $SalaryRatesTable salaryRates = $SalaryRatesTable(this);
  late final $PayrollItemsTable payrollItems = $PayrollItemsTable(this);
  late final $SalaryPaymentsTable salaryPayments = $SalaryPaymentsTable(this);
  late final $AppUsersTable appUsers = $AppUsersTable(this);
  late final $ActivityLogsTable activityLogs = $ActivityLogsTable(this);
  late final $MonthLocksTable monthLocks = $MonthLocksTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    students,
    enrollments,
    lessons,
    ledgerEntries,
    treasuryMovements,
    licensePrices,
    studentSummaries,
    outboxOps,
    rejectedOps,
    syncCursors,
    kvEntries,
    cars,
    carInstructors,
    employees,
    licenseTypes,
    treasuryAccounts,
    expenses,
    accountBalances,
    dayCloses,
    dayCloseCounts,
    exams,
    salaryRates,
    payrollItems,
    salaryPayments,
    appUsers,
    activityLogs,
    monthLocks,
    settings,
  ];
}

typedef $$StudentsTableCreateCompanionBuilder =
    StudentsCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      required String id,
      required String name,
      required String nationalId,
      Value<String?> phone,
      Value<bool> archived,
      Value<int> rowid,
    });
typedef $$StudentsTableUpdateCompanionBuilder =
    StudentsCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      Value<String> id,
      Value<String> name,
      Value<String> nationalId,
      Value<String?> phone,
      Value<bool> archived,
      Value<int> rowid,
    });

class $$StudentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);
}

class $$StudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentsTable,
          StudentRow,
          $$StudentsTableFilterComposer,
          $$StudentsTableOrderingComposer,
          $$StudentsTableAnnotationComposer,
          $$StudentsTableCreateCompanionBuilder,
          $$StudentsTableUpdateCompanionBuilder,
          (
            StudentRow,
            BaseReferences<_$AppDatabase, $StudentsTable, StudentRow>,
          ),
          StudentRow,
          PrefetchHooks Function()
        > {
  $$StudentsTableTableManager(_$AppDatabase db, $StudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nationalId = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                name: name,
                nationalId: nationalId,
                phone: phone,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                required String id,
                required String name,
                required String nationalId,
                Value<String?> phone = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion.insert(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                name: name,
                nationalId: nationalId,
                phone: phone,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentsTable,
      StudentRow,
      $$StudentsTableFilterComposer,
      $$StudentsTableOrderingComposer,
      $$StudentsTableAnnotationComposer,
      $$StudentsTableCreateCompanionBuilder,
      $$StudentsTableUpdateCompanionBuilder,
      (StudentRow, BaseReferences<_$AppDatabase, $StudentsTable, StudentRow>),
      StudentRow,
      PrefetchHooks Function()
    >;
typedef $$EnrollmentsTableCreateCompanionBuilder =
    EnrollmentsCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      required String id,
      required String studentId,
      required String studentName,
      required String licenseTypeId,
      required String carId,
      Value<String> stage,
      required String registeredOn,
      Value<bool> archived,
      Value<String?> graduatedOn,
      Value<String?> withdrawReason,
      Value<String?> finalSummaryJson,
      Value<int?> plannedTheory,
      Value<int?> plannedPractical,
      Value<int> rowid,
    });
typedef $$EnrollmentsTableUpdateCompanionBuilder =
    EnrollmentsCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      Value<String> id,
      Value<String> studentId,
      Value<String> studentName,
      Value<String> licenseTypeId,
      Value<String> carId,
      Value<String> stage,
      Value<String> registeredOn,
      Value<bool> archived,
      Value<String?> graduatedOn,
      Value<String?> withdrawReason,
      Value<String?> finalSummaryJson,
      Value<int?> plannedTheory,
      Value<int?> plannedPractical,
      Value<int> rowid,
    });

class $$EnrollmentsTableFilterComposer
    extends Composer<_$AppDatabase, $EnrollmentsTable> {
  $$EnrollmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licenseTypeId => $composableBuilder(
    column: $table.licenseTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get carId => $composableBuilder(
    column: $table.carId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registeredOn => $composableBuilder(
    column: $table.registeredOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get graduatedOn => $composableBuilder(
    column: $table.graduatedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get withdrawReason => $composableBuilder(
    column: $table.withdrawReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finalSummaryJson => $composableBuilder(
    column: $table.finalSummaryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedTheory => $composableBuilder(
    column: $table.plannedTheory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedPractical => $composableBuilder(
    column: $table.plannedPractical,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EnrollmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnrollmentsTable> {
  $$EnrollmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licenseTypeId => $composableBuilder(
    column: $table.licenseTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get carId => $composableBuilder(
    column: $table.carId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registeredOn => $composableBuilder(
    column: $table.registeredOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get graduatedOn => $composableBuilder(
    column: $table.graduatedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get withdrawReason => $composableBuilder(
    column: $table.withdrawReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finalSummaryJson => $composableBuilder(
    column: $table.finalSummaryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedTheory => $composableBuilder(
    column: $table.plannedTheory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedPractical => $composableBuilder(
    column: $table.plannedPractical,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EnrollmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnrollmentsTable> {
  $$EnrollmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get licenseTypeId => $composableBuilder(
    column: $table.licenseTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get carId =>
      $composableBuilder(column: $table.carId, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get registeredOn => $composableBuilder(
    column: $table.registeredOn,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<String> get graduatedOn => $composableBuilder(
    column: $table.graduatedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get withdrawReason => $composableBuilder(
    column: $table.withdrawReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get finalSummaryJson => $composableBuilder(
    column: $table.finalSummaryJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedTheory => $composableBuilder(
    column: $table.plannedTheory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedPractical => $composableBuilder(
    column: $table.plannedPractical,
    builder: (column) => column,
  );
}

class $$EnrollmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnrollmentsTable,
          EnrollmentRow,
          $$EnrollmentsTableFilterComposer,
          $$EnrollmentsTableOrderingComposer,
          $$EnrollmentsTableAnnotationComposer,
          $$EnrollmentsTableCreateCompanionBuilder,
          $$EnrollmentsTableUpdateCompanionBuilder,
          (
            EnrollmentRow,
            BaseReferences<_$AppDatabase, $EnrollmentsTable, EnrollmentRow>,
          ),
          EnrollmentRow,
          PrefetchHooks Function()
        > {
  $$EnrollmentsTableTableManager(_$AppDatabase db, $EnrollmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnrollmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnrollmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnrollmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> studentName = const Value.absent(),
                Value<String> licenseTypeId = const Value.absent(),
                Value<String> carId = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<String> registeredOn = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> graduatedOn = const Value.absent(),
                Value<String?> withdrawReason = const Value.absent(),
                Value<String?> finalSummaryJson = const Value.absent(),
                Value<int?> plannedTheory = const Value.absent(),
                Value<int?> plannedPractical = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnrollmentsCompanion(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                studentId: studentId,
                studentName: studentName,
                licenseTypeId: licenseTypeId,
                carId: carId,
                stage: stage,
                registeredOn: registeredOn,
                archived: archived,
                graduatedOn: graduatedOn,
                withdrawReason: withdrawReason,
                finalSummaryJson: finalSummaryJson,
                plannedTheory: plannedTheory,
                plannedPractical: plannedPractical,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                required String id,
                required String studentId,
                required String studentName,
                required String licenseTypeId,
                required String carId,
                Value<String> stage = const Value.absent(),
                required String registeredOn,
                Value<bool> archived = const Value.absent(),
                Value<String?> graduatedOn = const Value.absent(),
                Value<String?> withdrawReason = const Value.absent(),
                Value<String?> finalSummaryJson = const Value.absent(),
                Value<int?> plannedTheory = const Value.absent(),
                Value<int?> plannedPractical = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnrollmentsCompanion.insert(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                studentId: studentId,
                studentName: studentName,
                licenseTypeId: licenseTypeId,
                carId: carId,
                stage: stage,
                registeredOn: registeredOn,
                archived: archived,
                graduatedOn: graduatedOn,
                withdrawReason: withdrawReason,
                finalSummaryJson: finalSummaryJson,
                plannedTheory: plannedTheory,
                plannedPractical: plannedPractical,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EnrollmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnrollmentsTable,
      EnrollmentRow,
      $$EnrollmentsTableFilterComposer,
      $$EnrollmentsTableOrderingComposer,
      $$EnrollmentsTableAnnotationComposer,
      $$EnrollmentsTableCreateCompanionBuilder,
      $$EnrollmentsTableUpdateCompanionBuilder,
      (
        EnrollmentRow,
        BaseReferences<_$AppDatabase, $EnrollmentsTable, EnrollmentRow>,
      ),
      EnrollmentRow,
      PrefetchHooks Function()
    >;
typedef $$LessonsTableCreateCompanionBuilder =
    LessonsCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      required String id,
      required String enrollmentId,
      required String studentId,
      required String type,
      required int number,
      Value<bool> withoutDriving,
      required String employeeId,
      Value<String?> carId,
      required String startedAt,
      required String businessDate,
      Value<bool> archived,
      Value<int> rowid,
    });
typedef $$LessonsTableUpdateCompanionBuilder =
    LessonsCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      Value<String> id,
      Value<String> enrollmentId,
      Value<String> studentId,
      Value<String> type,
      Value<int> number,
      Value<bool> withoutDriving,
      Value<String> employeeId,
      Value<String?> carId,
      Value<String> startedAt,
      Value<String> businessDate,
      Value<bool> archived,
      Value<int> rowid,
    });

class $$LessonsTableFilterComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enrollmentId => $composableBuilder(
    column: $table.enrollmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get withoutDriving => $composableBuilder(
    column: $table.withoutDriving,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get carId => $composableBuilder(
    column: $table.carId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LessonsTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enrollmentId => $composableBuilder(
    column: $table.enrollmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get withoutDriving => $composableBuilder(
    column: $table.withoutDriving,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get carId => $composableBuilder(
    column: $table.carId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LessonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonsTable> {
  $$LessonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get enrollmentId => $composableBuilder(
    column: $table.enrollmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<bool> get withoutDriving => $composableBuilder(
    column: $table.withoutDriving,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get carId =>
      $composableBuilder(column: $table.carId, builder: (column) => column);

  GeneratedColumn<String> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);
}

class $$LessonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonsTable,
          LessonRow,
          $$LessonsTableFilterComposer,
          $$LessonsTableOrderingComposer,
          $$LessonsTableAnnotationComposer,
          $$LessonsTableCreateCompanionBuilder,
          $$LessonsTableUpdateCompanionBuilder,
          (LessonRow, BaseReferences<_$AppDatabase, $LessonsTable, LessonRow>),
          LessonRow,
          PrefetchHooks Function()
        > {
  $$LessonsTableTableManager(_$AppDatabase db, $LessonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> enrollmentId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<bool> withoutDriving = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<String?> carId = const Value.absent(),
                Value<String> startedAt = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonsCompanion(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                enrollmentId: enrollmentId,
                studentId: studentId,
                type: type,
                number: number,
                withoutDriving: withoutDriving,
                employeeId: employeeId,
                carId: carId,
                startedAt: startedAt,
                businessDate: businessDate,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                required String id,
                required String enrollmentId,
                required String studentId,
                required String type,
                required int number,
                Value<bool> withoutDriving = const Value.absent(),
                required String employeeId,
                Value<String?> carId = const Value.absent(),
                required String startedAt,
                required String businessDate,
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonsCompanion.insert(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                enrollmentId: enrollmentId,
                studentId: studentId,
                type: type,
                number: number,
                withoutDriving: withoutDriving,
                employeeId: employeeId,
                carId: carId,
                startedAt: startedAt,
                businessDate: businessDate,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LessonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonsTable,
      LessonRow,
      $$LessonsTableFilterComposer,
      $$LessonsTableOrderingComposer,
      $$LessonsTableAnnotationComposer,
      $$LessonsTableCreateCompanionBuilder,
      $$LessonsTableUpdateCompanionBuilder,
      (LessonRow, BaseReferences<_$AppDatabase, $LessonsTable, LessonRow>),
      LessonRow,
      PrefetchHooks Function()
    >;
typedef $$LedgerEntriesTableCreateCompanionBuilder =
    LedgerEntriesCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      required String id,
      required String enrollmentId,
      required String studentId,
      required String kind,
      required int amount,
      Value<String?> accountId,
      Value<String?> purpose,
      Value<String?> receiptNo,
      Value<String?> lessonId,
      Value<String?> reversesId,
      Value<bool> reversed,
      required String businessDate,
      Value<int> rowid,
    });
typedef $$LedgerEntriesTableUpdateCompanionBuilder =
    LedgerEntriesCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      Value<String> id,
      Value<String> enrollmentId,
      Value<String> studentId,
      Value<String> kind,
      Value<int> amount,
      Value<String?> accountId,
      Value<String?> purpose,
      Value<String?> receiptNo,
      Value<String?> lessonId,
      Value<String?> reversesId,
      Value<bool> reversed,
      Value<String> businessDate,
      Value<int> rowid,
    });

class $$LedgerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enrollmentId => $composableBuilder(
    column: $table.enrollmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptNo => $composableBuilder(
    column: $table.receiptNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reversesId => $composableBuilder(
    column: $table.reversesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reversed => $composableBuilder(
    column: $table.reversed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LedgerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enrollmentId => $composableBuilder(
    column: $table.enrollmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptNo => $composableBuilder(
    column: $table.receiptNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reversesId => $composableBuilder(
    column: $table.reversesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reversed => $composableBuilder(
    column: $table.reversed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LedgerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get enrollmentId => $composableBuilder(
    column: $table.enrollmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get receiptNo =>
      $composableBuilder(column: $table.receiptNo, builder: (column) => column);

  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<String> get reversesId => $composableBuilder(
    column: $table.reversesId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reversed =>
      $composableBuilder(column: $table.reversed, builder: (column) => column);

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );
}

class $$LedgerEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LedgerEntriesTable,
          LedgerRowData,
          $$LedgerEntriesTableFilterComposer,
          $$LedgerEntriesTableOrderingComposer,
          $$LedgerEntriesTableAnnotationComposer,
          $$LedgerEntriesTableCreateCompanionBuilder,
          $$LedgerEntriesTableUpdateCompanionBuilder,
          (
            LedgerRowData,
            BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerRowData>,
          ),
          LedgerRowData,
          PrefetchHooks Function()
        > {
  $$LedgerEntriesTableTableManager(_$AppDatabase db, $LedgerEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> enrollmentId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String?> purpose = const Value.absent(),
                Value<String?> receiptNo = const Value.absent(),
                Value<String?> lessonId = const Value.absent(),
                Value<String?> reversesId = const Value.absent(),
                Value<bool> reversed = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerEntriesCompanion(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                enrollmentId: enrollmentId,
                studentId: studentId,
                kind: kind,
                amount: amount,
                accountId: accountId,
                purpose: purpose,
                receiptNo: receiptNo,
                lessonId: lessonId,
                reversesId: reversesId,
                reversed: reversed,
                businessDate: businessDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                required String id,
                required String enrollmentId,
                required String studentId,
                required String kind,
                required int amount,
                Value<String?> accountId = const Value.absent(),
                Value<String?> purpose = const Value.absent(),
                Value<String?> receiptNo = const Value.absent(),
                Value<String?> lessonId = const Value.absent(),
                Value<String?> reversesId = const Value.absent(),
                Value<bool> reversed = const Value.absent(),
                required String businessDate,
                Value<int> rowid = const Value.absent(),
              }) => LedgerEntriesCompanion.insert(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                enrollmentId: enrollmentId,
                studentId: studentId,
                kind: kind,
                amount: amount,
                accountId: accountId,
                purpose: purpose,
                receiptNo: receiptNo,
                lessonId: lessonId,
                reversesId: reversesId,
                reversed: reversed,
                businessDate: businessDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LedgerEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LedgerEntriesTable,
      LedgerRowData,
      $$LedgerEntriesTableFilterComposer,
      $$LedgerEntriesTableOrderingComposer,
      $$LedgerEntriesTableAnnotationComposer,
      $$LedgerEntriesTableCreateCompanionBuilder,
      $$LedgerEntriesTableUpdateCompanionBuilder,
      (
        LedgerRowData,
        BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerRowData>,
      ),
      LedgerRowData,
      PrefetchHooks Function()
    >;
typedef $$TreasuryMovementsTableCreateCompanionBuilder =
    TreasuryMovementsCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      required String id,
      required String accountId,
      required String direction,
      required int amount,
      required String kind,
      required String refId,
      required String businessDate,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$TreasuryMovementsTableUpdateCompanionBuilder =
    TreasuryMovementsCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      Value<String> id,
      Value<String> accountId,
      Value<String> direction,
      Value<int> amount,
      Value<String> kind,
      Value<String> refId,
      Value<String> businessDate,
      Value<String?> note,
      Value<int> rowid,
    });

class $$TreasuryMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $TreasuryMovementsTable> {
  $$TreasuryMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TreasuryMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $TreasuryMovementsTable> {
  $$TreasuryMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TreasuryMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TreasuryMovementsTable> {
  $$TreasuryMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$TreasuryMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TreasuryMovementsTable,
          MovementRow,
          $$TreasuryMovementsTableFilterComposer,
          $$TreasuryMovementsTableOrderingComposer,
          $$TreasuryMovementsTableAnnotationComposer,
          $$TreasuryMovementsTableCreateCompanionBuilder,
          $$TreasuryMovementsTableUpdateCompanionBuilder,
          (
            MovementRow,
            BaseReferences<_$AppDatabase, $TreasuryMovementsTable, MovementRow>,
          ),
          MovementRow,
          PrefetchHooks Function()
        > {
  $$TreasuryMovementsTableTableManager(
    _$AppDatabase db,
    $TreasuryMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TreasuryMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TreasuryMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TreasuryMovementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> refId = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreasuryMovementsCompanion(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                accountId: accountId,
                direction: direction,
                amount: amount,
                kind: kind,
                refId: refId,
                businessDate: businessDate,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                required String id,
                required String accountId,
                required String direction,
                required int amount,
                required String kind,
                required String refId,
                required String businessDate,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreasuryMovementsCompanion.insert(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                accountId: accountId,
                direction: direction,
                amount: amount,
                kind: kind,
                refId: refId,
                businessDate: businessDate,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TreasuryMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TreasuryMovementsTable,
      MovementRow,
      $$TreasuryMovementsTableFilterComposer,
      $$TreasuryMovementsTableOrderingComposer,
      $$TreasuryMovementsTableAnnotationComposer,
      $$TreasuryMovementsTableCreateCompanionBuilder,
      $$TreasuryMovementsTableUpdateCompanionBuilder,
      (
        MovementRow,
        BaseReferences<_$AppDatabase, $TreasuryMovementsTable, MovementRow>,
      ),
      MovementRow,
      PrefetchHooks Function()
    >;
typedef $$LicensePricesTableCreateCompanionBuilder =
    LicensePricesCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      required String id,
      required String licenseTypeId,
      required String effectiveFrom,
      required int registrationFee,
      required int practicalLessonPrice,
      required int theoryRetakeFee,
      required int practicalExamFee,
      Value<int> plannedTheoryLessons,
      Value<int> plannedPracticalLessons,
      Value<int> minTheoryBeforeExam,
      Value<int> minPracticalBeforeExam,
      Value<bool> practicalAfterTheory,
      Value<int> rowid,
    });
typedef $$LicensePricesTableUpdateCompanionBuilder =
    LicensePricesCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      Value<String> id,
      Value<String> licenseTypeId,
      Value<String> effectiveFrom,
      Value<int> registrationFee,
      Value<int> practicalLessonPrice,
      Value<int> theoryRetakeFee,
      Value<int> practicalExamFee,
      Value<int> plannedTheoryLessons,
      Value<int> plannedPracticalLessons,
      Value<int> minTheoryBeforeExam,
      Value<int> minPracticalBeforeExam,
      Value<bool> practicalAfterTheory,
      Value<int> rowid,
    });

class $$LicensePricesTableFilterComposer
    extends Composer<_$AppDatabase, $LicensePricesTable> {
  $$LicensePricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licenseTypeId => $composableBuilder(
    column: $table.licenseTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get registrationFee => $composableBuilder(
    column: $table.registrationFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get practicalLessonPrice => $composableBuilder(
    column: $table.practicalLessonPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get theoryRetakeFee => $composableBuilder(
    column: $table.theoryRetakeFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get practicalExamFee => $composableBuilder(
    column: $table.practicalExamFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedTheoryLessons => $composableBuilder(
    column: $table.plannedTheoryLessons,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedPracticalLessons => $composableBuilder(
    column: $table.plannedPracticalLessons,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minTheoryBeforeExam => $composableBuilder(
    column: $table.minTheoryBeforeExam,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minPracticalBeforeExam => $composableBuilder(
    column: $table.minPracticalBeforeExam,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get practicalAfterTheory => $composableBuilder(
    column: $table.practicalAfterTheory,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LicensePricesTableOrderingComposer
    extends Composer<_$AppDatabase, $LicensePricesTable> {
  $$LicensePricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licenseTypeId => $composableBuilder(
    column: $table.licenseTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get registrationFee => $composableBuilder(
    column: $table.registrationFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get practicalLessonPrice => $composableBuilder(
    column: $table.practicalLessonPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get theoryRetakeFee => $composableBuilder(
    column: $table.theoryRetakeFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get practicalExamFee => $composableBuilder(
    column: $table.practicalExamFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedTheoryLessons => $composableBuilder(
    column: $table.plannedTheoryLessons,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedPracticalLessons => $composableBuilder(
    column: $table.plannedPracticalLessons,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minTheoryBeforeExam => $composableBuilder(
    column: $table.minTheoryBeforeExam,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minPracticalBeforeExam => $composableBuilder(
    column: $table.minPracticalBeforeExam,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get practicalAfterTheory => $composableBuilder(
    column: $table.practicalAfterTheory,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LicensePricesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LicensePricesTable> {
  $$LicensePricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get licenseTypeId => $composableBuilder(
    column: $table.licenseTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  GeneratedColumn<int> get registrationFee => $composableBuilder(
    column: $table.registrationFee,
    builder: (column) => column,
  );

  GeneratedColumn<int> get practicalLessonPrice => $composableBuilder(
    column: $table.practicalLessonPrice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get theoryRetakeFee => $composableBuilder(
    column: $table.theoryRetakeFee,
    builder: (column) => column,
  );

  GeneratedColumn<int> get practicalExamFee => $composableBuilder(
    column: $table.practicalExamFee,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedTheoryLessons => $composableBuilder(
    column: $table.plannedTheoryLessons,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedPracticalLessons => $composableBuilder(
    column: $table.plannedPracticalLessons,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minTheoryBeforeExam => $composableBuilder(
    column: $table.minTheoryBeforeExam,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minPracticalBeforeExam => $composableBuilder(
    column: $table.minPracticalBeforeExam,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get practicalAfterTheory => $composableBuilder(
    column: $table.practicalAfterTheory,
    builder: (column) => column,
  );
}

class $$LicensePricesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LicensePricesTable,
          LicensePriceRow,
          $$LicensePricesTableFilterComposer,
          $$LicensePricesTableOrderingComposer,
          $$LicensePricesTableAnnotationComposer,
          $$LicensePricesTableCreateCompanionBuilder,
          $$LicensePricesTableUpdateCompanionBuilder,
          (
            LicensePriceRow,
            BaseReferences<_$AppDatabase, $LicensePricesTable, LicensePriceRow>,
          ),
          LicensePriceRow,
          PrefetchHooks Function()
        > {
  $$LicensePricesTableTableManager(_$AppDatabase db, $LicensePricesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LicensePricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LicensePricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LicensePricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> licenseTypeId = const Value.absent(),
                Value<String> effectiveFrom = const Value.absent(),
                Value<int> registrationFee = const Value.absent(),
                Value<int> practicalLessonPrice = const Value.absent(),
                Value<int> theoryRetakeFee = const Value.absent(),
                Value<int> practicalExamFee = const Value.absent(),
                Value<int> plannedTheoryLessons = const Value.absent(),
                Value<int> plannedPracticalLessons = const Value.absent(),
                Value<int> minTheoryBeforeExam = const Value.absent(),
                Value<int> minPracticalBeforeExam = const Value.absent(),
                Value<bool> practicalAfterTheory = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LicensePricesCompanion(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                licenseTypeId: licenseTypeId,
                effectiveFrom: effectiveFrom,
                registrationFee: registrationFee,
                practicalLessonPrice: practicalLessonPrice,
                theoryRetakeFee: theoryRetakeFee,
                practicalExamFee: practicalExamFee,
                plannedTheoryLessons: plannedTheoryLessons,
                plannedPracticalLessons: plannedPracticalLessons,
                minTheoryBeforeExam: minTheoryBeforeExam,
                minPracticalBeforeExam: minPracticalBeforeExam,
                practicalAfterTheory: practicalAfterTheory,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                required String id,
                required String licenseTypeId,
                required String effectiveFrom,
                required int registrationFee,
                required int practicalLessonPrice,
                required int theoryRetakeFee,
                required int practicalExamFee,
                Value<int> plannedTheoryLessons = const Value.absent(),
                Value<int> plannedPracticalLessons = const Value.absent(),
                Value<int> minTheoryBeforeExam = const Value.absent(),
                Value<int> minPracticalBeforeExam = const Value.absent(),
                Value<bool> practicalAfterTheory = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LicensePricesCompanion.insert(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                licenseTypeId: licenseTypeId,
                effectiveFrom: effectiveFrom,
                registrationFee: registrationFee,
                practicalLessonPrice: practicalLessonPrice,
                theoryRetakeFee: theoryRetakeFee,
                practicalExamFee: practicalExamFee,
                plannedTheoryLessons: plannedTheoryLessons,
                plannedPracticalLessons: plannedPracticalLessons,
                minTheoryBeforeExam: minTheoryBeforeExam,
                minPracticalBeforeExam: minPracticalBeforeExam,
                practicalAfterTheory: practicalAfterTheory,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LicensePricesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LicensePricesTable,
      LicensePriceRow,
      $$LicensePricesTableFilterComposer,
      $$LicensePricesTableOrderingComposer,
      $$LicensePricesTableAnnotationComposer,
      $$LicensePricesTableCreateCompanionBuilder,
      $$LicensePricesTableUpdateCompanionBuilder,
      (
        LicensePriceRow,
        BaseReferences<_$AppDatabase, $LicensePricesTable, LicensePriceRow>,
      ),
      LicensePriceRow,
      PrefetchHooks Function()
    >;
typedef $$StudentSummariesTableCreateCompanionBuilder =
    StudentSummariesCompanion Function({
      required String enrollmentId,
      required String studentId,
      Value<int> charged,
      Value<int> paid,
      Value<int> discounts,
      Value<int> theoryLessons,
      Value<int> practicalLessons,
      Value<int> serverSeq,
      Value<int> rowid,
    });
typedef $$StudentSummariesTableUpdateCompanionBuilder =
    StudentSummariesCompanion Function({
      Value<String> enrollmentId,
      Value<String> studentId,
      Value<int> charged,
      Value<int> paid,
      Value<int> discounts,
      Value<int> theoryLessons,
      Value<int> practicalLessons,
      Value<int> serverSeq,
      Value<int> rowid,
    });

class $$StudentSummariesTableFilterComposer
    extends Composer<_$AppDatabase, $StudentSummariesTable> {
  $$StudentSummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get enrollmentId => $composableBuilder(
    column: $table.enrollmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get charged => $composableBuilder(
    column: $table.charged,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paid => $composableBuilder(
    column: $table.paid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discounts => $composableBuilder(
    column: $table.discounts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get theoryLessons => $composableBuilder(
    column: $table.theoryLessons,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get practicalLessons => $composableBuilder(
    column: $table.practicalLessons,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudentSummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentSummariesTable> {
  $$StudentSummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get enrollmentId => $composableBuilder(
    column: $table.enrollmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get charged => $composableBuilder(
    column: $table.charged,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paid => $composableBuilder(
    column: $table.paid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discounts => $composableBuilder(
    column: $table.discounts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get theoryLessons => $composableBuilder(
    column: $table.theoryLessons,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get practicalLessons => $composableBuilder(
    column: $table.practicalLessons,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudentSummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentSummariesTable> {
  $$StudentSummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get enrollmentId => $composableBuilder(
    column: $table.enrollmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get charged =>
      $composableBuilder(column: $table.charged, builder: (column) => column);

  GeneratedColumn<int> get paid =>
      $composableBuilder(column: $table.paid, builder: (column) => column);

  GeneratedColumn<int> get discounts =>
      $composableBuilder(column: $table.discounts, builder: (column) => column);

  GeneratedColumn<int> get theoryLessons => $composableBuilder(
    column: $table.theoryLessons,
    builder: (column) => column,
  );

  GeneratedColumn<int> get practicalLessons => $composableBuilder(
    column: $table.practicalLessons,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$StudentSummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentSummariesTable,
          StudentSummaryRow,
          $$StudentSummariesTableFilterComposer,
          $$StudentSummariesTableOrderingComposer,
          $$StudentSummariesTableAnnotationComposer,
          $$StudentSummariesTableCreateCompanionBuilder,
          $$StudentSummariesTableUpdateCompanionBuilder,
          (
            StudentSummaryRow,
            BaseReferences<
              _$AppDatabase,
              $StudentSummariesTable,
              StudentSummaryRow
            >,
          ),
          StudentSummaryRow,
          PrefetchHooks Function()
        > {
  $$StudentSummariesTableTableManager(
    _$AppDatabase db,
    $StudentSummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentSummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentSummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentSummariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> enrollmentId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<int> charged = const Value.absent(),
                Value<int> paid = const Value.absent(),
                Value<int> discounts = const Value.absent(),
                Value<int> theoryLessons = const Value.absent(),
                Value<int> practicalLessons = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentSummariesCompanion(
                enrollmentId: enrollmentId,
                studentId: studentId,
                charged: charged,
                paid: paid,
                discounts: discounts,
                theoryLessons: theoryLessons,
                practicalLessons: practicalLessons,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String enrollmentId,
                required String studentId,
                Value<int> charged = const Value.absent(),
                Value<int> paid = const Value.absent(),
                Value<int> discounts = const Value.absent(),
                Value<int> theoryLessons = const Value.absent(),
                Value<int> practicalLessons = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentSummariesCompanion.insert(
                enrollmentId: enrollmentId,
                studentId: studentId,
                charged: charged,
                paid: paid,
                discounts: discounts,
                theoryLessons: theoryLessons,
                practicalLessons: practicalLessons,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudentSummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentSummariesTable,
      StudentSummaryRow,
      $$StudentSummariesTableFilterComposer,
      $$StudentSummariesTableOrderingComposer,
      $$StudentSummariesTableAnnotationComposer,
      $$StudentSummariesTableCreateCompanionBuilder,
      $$StudentSummariesTableUpdateCompanionBuilder,
      (
        StudentSummaryRow,
        BaseReferences<
          _$AppDatabase,
          $StudentSummariesTable,
          StudentSummaryRow
        >,
      ),
      StudentSummaryRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxOpsTableCreateCompanionBuilder =
    OutboxOpsCompanion Function({
      required String opId,
      required String type,
      required String payloadJson,
      required int deviceSeq,
      required String deviceTime,
      required String userId,
      Value<int> attempts,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$OutboxOpsTableUpdateCompanionBuilder =
    OutboxOpsCompanion Function({
      Value<String> opId,
      Value<String> type,
      Value<String> payloadJson,
      Value<int> deviceSeq,
      Value<String> deviceTime,
      Value<String> userId,
      Value<int> attempts,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$OutboxOpsTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deviceSeq => $composableBuilder(
    column: $table.deviceSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxOpsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deviceSeq => $composableBuilder(
    column: $table.deviceSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxOpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deviceSeq =>
      $composableBuilder(column: $table.deviceSeq, builder: (column) => column);

  GeneratedColumn<String> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$OutboxOpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxOpsTable,
          OutboxOpRow,
          $$OutboxOpsTableFilterComposer,
          $$OutboxOpsTableOrderingComposer,
          $$OutboxOpsTableAnnotationComposer,
          $$OutboxOpsTableCreateCompanionBuilder,
          $$OutboxOpsTableUpdateCompanionBuilder,
          (
            OutboxOpRow,
            BaseReferences<_$AppDatabase, $OutboxOpsTable, OutboxOpRow>,
          ),
          OutboxOpRow,
          PrefetchHooks Function()
        > {
  $$OutboxOpsTableTableManager(_$AppDatabase db, $OutboxOpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> opId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> deviceSeq = const Value.absent(),
                Value<String> deviceTime = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxOpsCompanion(
                opId: opId,
                type: type,
                payloadJson: payloadJson,
                deviceSeq: deviceSeq,
                deviceTime: deviceTime,
                userId: userId,
                attempts: attempts,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String opId,
                required String type,
                required String payloadJson,
                required int deviceSeq,
                required String deviceTime,
                required String userId,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxOpsCompanion.insert(
                opId: opId,
                type: type,
                payloadJson: payloadJson,
                deviceSeq: deviceSeq,
                deviceTime: deviceTime,
                userId: userId,
                attempts: attempts,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxOpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxOpsTable,
      OutboxOpRow,
      $$OutboxOpsTableFilterComposer,
      $$OutboxOpsTableOrderingComposer,
      $$OutboxOpsTableAnnotationComposer,
      $$OutboxOpsTableCreateCompanionBuilder,
      $$OutboxOpsTableUpdateCompanionBuilder,
      (
        OutboxOpRow,
        BaseReferences<_$AppDatabase, $OutboxOpsTable, OutboxOpRow>,
      ),
      OutboxOpRow,
      PrefetchHooks Function()
    >;
typedef $$RejectedOpsTableCreateCompanionBuilder =
    RejectedOpsCompanion Function({
      required String opId,
      required String type,
      required String payloadJson,
      required String reason,
      required String message,
      required String rejectedAt,
      Value<int> rowid,
    });
typedef $$RejectedOpsTableUpdateCompanionBuilder =
    RejectedOpsCompanion Function({
      Value<String> opId,
      Value<String> type,
      Value<String> payloadJson,
      Value<String> reason,
      Value<String> message,
      Value<String> rejectedAt,
      Value<int> rowid,
    });

class $$RejectedOpsTableFilterComposer
    extends Composer<_$AppDatabase, $RejectedOpsTable> {
  $$RejectedOpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rejectedAt => $composableBuilder(
    column: $table.rejectedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RejectedOpsTableOrderingComposer
    extends Composer<_$AppDatabase, $RejectedOpsTable> {
  $$RejectedOpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rejectedAt => $composableBuilder(
    column: $table.rejectedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RejectedOpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RejectedOpsTable> {
  $$RejectedOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get rejectedAt => $composableBuilder(
    column: $table.rejectedAt,
    builder: (column) => column,
  );
}

class $$RejectedOpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RejectedOpsTable,
          RejectedOpRow,
          $$RejectedOpsTableFilterComposer,
          $$RejectedOpsTableOrderingComposer,
          $$RejectedOpsTableAnnotationComposer,
          $$RejectedOpsTableCreateCompanionBuilder,
          $$RejectedOpsTableUpdateCompanionBuilder,
          (
            RejectedOpRow,
            BaseReferences<_$AppDatabase, $RejectedOpsTable, RejectedOpRow>,
          ),
          RejectedOpRow,
          PrefetchHooks Function()
        > {
  $$RejectedOpsTableTableManager(_$AppDatabase db, $RejectedOpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RejectedOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RejectedOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RejectedOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> opId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String> rejectedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RejectedOpsCompanion(
                opId: opId,
                type: type,
                payloadJson: payloadJson,
                reason: reason,
                message: message,
                rejectedAt: rejectedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String opId,
                required String type,
                required String payloadJson,
                required String reason,
                required String message,
                required String rejectedAt,
                Value<int> rowid = const Value.absent(),
              }) => RejectedOpsCompanion.insert(
                opId: opId,
                type: type,
                payloadJson: payloadJson,
                reason: reason,
                message: message,
                rejectedAt: rejectedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RejectedOpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RejectedOpsTable,
      RejectedOpRow,
      $$RejectedOpsTableFilterComposer,
      $$RejectedOpsTableOrderingComposer,
      $$RejectedOpsTableAnnotationComposer,
      $$RejectedOpsTableCreateCompanionBuilder,
      $$RejectedOpsTableUpdateCompanionBuilder,
      (
        RejectedOpRow,
        BaseReferences<_$AppDatabase, $RejectedOpsTable, RejectedOpRow>,
      ),
      RejectedOpRow,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String collection,
      Value<int> lastSeq,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> collection,
      Value<int> lastSeq,
      Value<int> rowid,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeq => $composableBuilder(
    column: $table.lastSeq,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeq => $composableBuilder(
    column: $table.lastSeq,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeq =>
      $composableBuilder(column: $table.lastSeq, builder: (column) => column);
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursorRow,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursorRow,
            BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursorRow>,
          ),
          SyncCursorRow,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> collection = const Value.absent(),
                Value<int> lastSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                collection: collection,
                lastSeq: lastSeq,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String collection,
                Value<int> lastSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                collection: collection,
                lastSeq: lastSeq,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursorRow,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursorRow,
        BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursorRow>,
      ),
      SyncCursorRow,
      PrefetchHooks Function()
    >;
typedef $$KvEntriesTableCreateCompanionBuilder =
    KvEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$KvEntriesTableUpdateCompanionBuilder =
    KvEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$KvEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $KvEntriesTable> {
  $$KvEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KvEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $KvEntriesTable> {
  $$KvEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KvEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KvEntriesTable> {
  $$KvEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$KvEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KvEntriesTable,
          KvRow,
          $$KvEntriesTableFilterComposer,
          $$KvEntriesTableOrderingComposer,
          $$KvEntriesTableAnnotationComposer,
          $$KvEntriesTableCreateCompanionBuilder,
          $$KvEntriesTableUpdateCompanionBuilder,
          (KvRow, BaseReferences<_$AppDatabase, $KvEntriesTable, KvRow>),
          KvRow,
          PrefetchHooks Function()
        > {
  $$KvEntriesTableTableManager(_$AppDatabase db, $KvEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KvEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KvEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KvEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KvEntriesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => KvEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KvEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KvEntriesTable,
      KvRow,
      $$KvEntriesTableFilterComposer,
      $$KvEntriesTableOrderingComposer,
      $$KvEntriesTableAnnotationComposer,
      $$KvEntriesTableCreateCompanionBuilder,
      $$KvEntriesTableUpdateCompanionBuilder,
      (KvRow, BaseReferences<_$AppDatabase, $KvEntriesTable, KvRow>),
      KvRow,
      PrefetchHooks Function()
    >;
typedef $$CarsTableCreateCompanionBuilder =
    CarsCompanion Function({
      required String id,
      required String name,
      Value<String?> plate,
      Value<bool> active,
      Value<int?> serverSeq,
      Value<String> gearbox,
      Value<int> rowid,
    });
typedef $$CarsTableUpdateCompanionBuilder =
    CarsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> plate,
      Value<bool> active,
      Value<int?> serverSeq,
      Value<String> gearbox,
      Value<int> rowid,
    });

class $$CarsTableFilterComposer extends Composer<_$AppDatabase, $CarsTable> {
  $$CarsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plate => $composableBuilder(
    column: $table.plate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gearbox => $composableBuilder(
    column: $table.gearbox,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CarsTableOrderingComposer extends Composer<_$AppDatabase, $CarsTable> {
  $$CarsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plate => $composableBuilder(
    column: $table.plate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gearbox => $composableBuilder(
    column: $table.gearbox,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CarsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CarsTable> {
  $$CarsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get plate =>
      $composableBuilder(column: $table.plate, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get gearbox =>
      $composableBuilder(column: $table.gearbox, builder: (column) => column);
}

class $$CarsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CarsTable,
          CarRow,
          $$CarsTableFilterComposer,
          $$CarsTableOrderingComposer,
          $$CarsTableAnnotationComposer,
          $$CarsTableCreateCompanionBuilder,
          $$CarsTableUpdateCompanionBuilder,
          (CarRow, BaseReferences<_$AppDatabase, $CarsTable, CarRow>),
          CarRow,
          PrefetchHooks Function()
        > {
  $$CarsTableTableManager(_$AppDatabase db, $CarsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CarsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CarsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CarsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> plate = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String> gearbox = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CarsCompanion(
                id: id,
                name: name,
                plate: plate,
                active: active,
                serverSeq: serverSeq,
                gearbox: gearbox,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> plate = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String> gearbox = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CarsCompanion.insert(
                id: id,
                name: name,
                plate: plate,
                active: active,
                serverSeq: serverSeq,
                gearbox: gearbox,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CarsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CarsTable,
      CarRow,
      $$CarsTableFilterComposer,
      $$CarsTableOrderingComposer,
      $$CarsTableAnnotationComposer,
      $$CarsTableCreateCompanionBuilder,
      $$CarsTableUpdateCompanionBuilder,
      (CarRow, BaseReferences<_$AppDatabase, $CarsTable, CarRow>),
      CarRow,
      PrefetchHooks Function()
    >;
typedef $$CarInstructorsTableCreateCompanionBuilder =
    CarInstructorsCompanion Function({
      required String id,
      required String carId,
      required String employeeId,
      Value<String?> from,
      Value<String?> to,
      Value<int?> serverSeq,
      Value<int> rowid,
    });
typedef $$CarInstructorsTableUpdateCompanionBuilder =
    CarInstructorsCompanion Function({
      Value<String> id,
      Value<String> carId,
      Value<String> employeeId,
      Value<String?> from,
      Value<String?> to,
      Value<int?> serverSeq,
      Value<int> rowid,
    });

class $$CarInstructorsTableFilterComposer
    extends Composer<_$AppDatabase, $CarInstructorsTable> {
  $$CarInstructorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get carId => $composableBuilder(
    column: $table.carId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get from => $composableBuilder(
    column: $table.from,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get to => $composableBuilder(
    column: $table.to,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CarInstructorsTableOrderingComposer
    extends Composer<_$AppDatabase, $CarInstructorsTable> {
  $$CarInstructorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get carId => $composableBuilder(
    column: $table.carId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get from => $composableBuilder(
    column: $table.from,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get to => $composableBuilder(
    column: $table.to,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CarInstructorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CarInstructorsTable> {
  $$CarInstructorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get carId =>
      $composableBuilder(column: $table.carId, builder: (column) => column);

  GeneratedColumn<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get from =>
      $composableBuilder(column: $table.from, builder: (column) => column);

  GeneratedColumn<String> get to =>
      $composableBuilder(column: $table.to, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$CarInstructorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CarInstructorsTable,
          CarInstructorRow,
          $$CarInstructorsTableFilterComposer,
          $$CarInstructorsTableOrderingComposer,
          $$CarInstructorsTableAnnotationComposer,
          $$CarInstructorsTableCreateCompanionBuilder,
          $$CarInstructorsTableUpdateCompanionBuilder,
          (
            CarInstructorRow,
            BaseReferences<
              _$AppDatabase,
              $CarInstructorsTable,
              CarInstructorRow
            >,
          ),
          CarInstructorRow,
          PrefetchHooks Function()
        > {
  $$CarInstructorsTableTableManager(
    _$AppDatabase db,
    $CarInstructorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CarInstructorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CarInstructorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CarInstructorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> carId = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<String?> from = const Value.absent(),
                Value<String?> to = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CarInstructorsCompanion(
                id: id,
                carId: carId,
                employeeId: employeeId,
                from: from,
                to: to,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String carId,
                required String employeeId,
                Value<String?> from = const Value.absent(),
                Value<String?> to = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CarInstructorsCompanion.insert(
                id: id,
                carId: carId,
                employeeId: employeeId,
                from: from,
                to: to,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CarInstructorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CarInstructorsTable,
      CarInstructorRow,
      $$CarInstructorsTableFilterComposer,
      $$CarInstructorsTableOrderingComposer,
      $$CarInstructorsTableAnnotationComposer,
      $$CarInstructorsTableCreateCompanionBuilder,
      $$CarInstructorsTableUpdateCompanionBuilder,
      (
        CarInstructorRow,
        BaseReferences<_$AppDatabase, $CarInstructorsTable, CarInstructorRow>,
      ),
      CarInstructorRow,
      PrefetchHooks Function()
    >;
typedef $$EmployeesTableCreateCompanionBuilder =
    EmployeesCompanion Function({
      required String id,
      required String name,
      required String role,
      Value<bool> active,
      Value<int?> serverSeq,
      Value<String?> phone,
      Value<String?> userId,
      Value<int> salary,
      Value<int> rowid,
    });
typedef $$EmployeesTableUpdateCompanionBuilder =
    EmployeesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> role,
      Value<bool> active,
      Value<int?> serverSeq,
      Value<String?> phone,
      Value<String?> userId,
      Value<int> salary,
      Value<int> rowid,
    });

class $$EmployeesTableFilterComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get salary => $composableBuilder(
    column: $table.salary,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmployeesTableOrderingComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salary => $composableBuilder(
    column: $table.salary,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmployeesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get salary =>
      $composableBuilder(column: $table.salary, builder: (column) => column);
}

class $$EmployeesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmployeesTable,
          EmployeeRow,
          $$EmployeesTableFilterComposer,
          $$EmployeesTableOrderingComposer,
          $$EmployeesTableAnnotationComposer,
          $$EmployeesTableCreateCompanionBuilder,
          $$EmployeesTableUpdateCompanionBuilder,
          (
            EmployeeRow,
            BaseReferences<_$AppDatabase, $EmployeesTable, EmployeeRow>,
          ),
          EmployeeRow,
          PrefetchHooks Function()
        > {
  $$EmployeesTableTableManager(_$AppDatabase db, $EmployeesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmployeesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmployeesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmployeesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<int> salary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmployeesCompanion(
                id: id,
                name: name,
                role: role,
                active: active,
                serverSeq: serverSeq,
                phone: phone,
                userId: userId,
                salary: salary,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String role,
                Value<bool> active = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<int> salary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmployeesCompanion.insert(
                id: id,
                name: name,
                role: role,
                active: active,
                serverSeq: serverSeq,
                phone: phone,
                userId: userId,
                salary: salary,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmployeesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmployeesTable,
      EmployeeRow,
      $$EmployeesTableFilterComposer,
      $$EmployeesTableOrderingComposer,
      $$EmployeesTableAnnotationComposer,
      $$EmployeesTableCreateCompanionBuilder,
      $$EmployeesTableUpdateCompanionBuilder,
      (
        EmployeeRow,
        BaseReferences<_$AppDatabase, $EmployeesTable, EmployeeRow>,
      ),
      EmployeeRow,
      PrefetchHooks Function()
    >;
typedef $$LicenseTypesTableCreateCompanionBuilder =
    LicenseTypesCompanion Function({
      required String id,
      required String name,
      Value<bool> active,
      Value<int> sortOrder,
      Value<int?> serverSeq,
      Value<int> rowid,
    });
typedef $$LicenseTypesTableUpdateCompanionBuilder =
    LicenseTypesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> active,
      Value<int> sortOrder,
      Value<int?> serverSeq,
      Value<int> rowid,
    });

class $$LicenseTypesTableFilterComposer
    extends Composer<_$AppDatabase, $LicenseTypesTable> {
  $$LicenseTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LicenseTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $LicenseTypesTable> {
  $$LicenseTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LicenseTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LicenseTypesTable> {
  $$LicenseTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$LicenseTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LicenseTypesTable,
          LicenseTypeRow,
          $$LicenseTypesTableFilterComposer,
          $$LicenseTypesTableOrderingComposer,
          $$LicenseTypesTableAnnotationComposer,
          $$LicenseTypesTableCreateCompanionBuilder,
          $$LicenseTypesTableUpdateCompanionBuilder,
          (
            LicenseTypeRow,
            BaseReferences<_$AppDatabase, $LicenseTypesTable, LicenseTypeRow>,
          ),
          LicenseTypeRow,
          PrefetchHooks Function()
        > {
  $$LicenseTypesTableTableManager(_$AppDatabase db, $LicenseTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LicenseTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LicenseTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LicenseTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LicenseTypesCompanion(
                id: id,
                name: name,
                active: active,
                sortOrder: sortOrder,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> active = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LicenseTypesCompanion.insert(
                id: id,
                name: name,
                active: active,
                sortOrder: sortOrder,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LicenseTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LicenseTypesTable,
      LicenseTypeRow,
      $$LicenseTypesTableFilterComposer,
      $$LicenseTypesTableOrderingComposer,
      $$LicenseTypesTableAnnotationComposer,
      $$LicenseTypesTableCreateCompanionBuilder,
      $$LicenseTypesTableUpdateCompanionBuilder,
      (
        LicenseTypeRow,
        BaseReferences<_$AppDatabase, $LicenseTypesTable, LicenseTypeRow>,
      ),
      LicenseTypeRow,
      PrefetchHooks Function()
    >;
typedef $$TreasuryAccountsTableCreateCompanionBuilder =
    TreasuryAccountsCompanion Function({
      required String id,
      required String name,
      required String kind,
      Value<bool> active,
      Value<int> openingBalance,
      Value<int?> serverSeq,
      Value<int> rowid,
    });
typedef $$TreasuryAccountsTableUpdateCompanionBuilder =
    TreasuryAccountsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> kind,
      Value<bool> active,
      Value<int> openingBalance,
      Value<int?> serverSeq,
      Value<int> rowid,
    });

class $$TreasuryAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $TreasuryAccountsTable> {
  $$TreasuryAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TreasuryAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $TreasuryAccountsTable> {
  $$TreasuryAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TreasuryAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TreasuryAccountsTable> {
  $$TreasuryAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<int> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$TreasuryAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TreasuryAccountsTable,
          TreasuryAccountRow,
          $$TreasuryAccountsTableFilterComposer,
          $$TreasuryAccountsTableOrderingComposer,
          $$TreasuryAccountsTableAnnotationComposer,
          $$TreasuryAccountsTableCreateCompanionBuilder,
          $$TreasuryAccountsTableUpdateCompanionBuilder,
          (
            TreasuryAccountRow,
            BaseReferences<
              _$AppDatabase,
              $TreasuryAccountsTable,
              TreasuryAccountRow
            >,
          ),
          TreasuryAccountRow,
          PrefetchHooks Function()
        > {
  $$TreasuryAccountsTableTableManager(
    _$AppDatabase db,
    $TreasuryAccountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TreasuryAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TreasuryAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TreasuryAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> openingBalance = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreasuryAccountsCompanion(
                id: id,
                name: name,
                kind: kind,
                active: active,
                openingBalance: openingBalance,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String kind,
                Value<bool> active = const Value.absent(),
                Value<int> openingBalance = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreasuryAccountsCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                active: active,
                openingBalance: openingBalance,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TreasuryAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TreasuryAccountsTable,
      TreasuryAccountRow,
      $$TreasuryAccountsTableFilterComposer,
      $$TreasuryAccountsTableOrderingComposer,
      $$TreasuryAccountsTableAnnotationComposer,
      $$TreasuryAccountsTableCreateCompanionBuilder,
      $$TreasuryAccountsTableUpdateCompanionBuilder,
      (
        TreasuryAccountRow,
        BaseReferences<
          _$AppDatabase,
          $TreasuryAccountsTable,
          TreasuryAccountRow
        >,
      ),
      TreasuryAccountRow,
      PrefetchHooks Function()
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      required String id,
      required String kind,
      required String item,
      required String label,
      Value<String?> carId,
      Value<int?> liters,
      Value<String?> studentId,
      required int amount,
      required String accountId,
      Value<String?> note,
      required String businessDate,
      Value<bool> reversed,
      Value<int> rowid,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      Value<String> id,
      Value<String> kind,
      Value<String> item,
      Value<String> label,
      Value<String?> carId,
      Value<int?> liters,
      Value<String?> studentId,
      Value<int> amount,
      Value<String> accountId,
      Value<String?> note,
      Value<String> businessDate,
      Value<bool> reversed,
      Value<int> rowid,
    });

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get carId => $composableBuilder(
    column: $table.carId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get liters => $composableBuilder(
    column: $table.liters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reversed => $composableBuilder(
    column: $table.reversed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get carId => $composableBuilder(
    column: $table.carId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get liters => $composableBuilder(
    column: $table.liters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reversed => $composableBuilder(
    column: $table.reversed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get item =>
      $composableBuilder(column: $table.item, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get carId =>
      $composableBuilder(column: $table.carId, builder: (column) => column);

  GeneratedColumn<int> get liters =>
      $composableBuilder(column: $table.liters, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reversed =>
      $composableBuilder(column: $table.reversed, builder: (column) => column);
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          ExpenseRow,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (
            ExpenseRow,
            BaseReferences<_$AppDatabase, $ExpensesTable, ExpenseRow>,
          ),
          ExpenseRow,
          PrefetchHooks Function()
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> item = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> carId = const Value.absent(),
                Value<int?> liters = const Value.absent(),
                Value<String?> studentId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<bool> reversed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                kind: kind,
                item: item,
                label: label,
                carId: carId,
                liters: liters,
                studentId: studentId,
                amount: amount,
                accountId: accountId,
                note: note,
                businessDate: businessDate,
                reversed: reversed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                required String id,
                required String kind,
                required String item,
                required String label,
                Value<String?> carId = const Value.absent(),
                Value<int?> liters = const Value.absent(),
                Value<String?> studentId = const Value.absent(),
                required int amount,
                required String accountId,
                Value<String?> note = const Value.absent(),
                required String businessDate,
                Value<bool> reversed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                kind: kind,
                item: item,
                label: label,
                carId: carId,
                liters: liters,
                studentId: studentId,
                amount: amount,
                accountId: accountId,
                note: note,
                businessDate: businessDate,
                reversed: reversed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      ExpenseRow,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (ExpenseRow, BaseReferences<_$AppDatabase, $ExpensesTable, ExpenseRow>),
      ExpenseRow,
      PrefetchHooks Function()
    >;
typedef $$AccountBalancesTableCreateCompanionBuilder =
    AccountBalancesCompanion Function({
      required String accountId,
      required int balance,
      Value<int> serverSeq,
      Value<int> rowid,
    });
typedef $$AccountBalancesTableUpdateCompanionBuilder =
    AccountBalancesCompanion Function({
      Value<String> accountId,
      Value<int> balance,
      Value<int> serverSeq,
      Value<int> rowid,
    });

class $$AccountBalancesTableFilterComposer
    extends Composer<_$AppDatabase, $AccountBalancesTable> {
  $$AccountBalancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountBalancesTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountBalancesTable> {
  $$AccountBalancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountBalancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountBalancesTable> {
  $$AccountBalancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$AccountBalancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountBalancesTable,
          AccountBalanceRow,
          $$AccountBalancesTableFilterComposer,
          $$AccountBalancesTableOrderingComposer,
          $$AccountBalancesTableAnnotationComposer,
          $$AccountBalancesTableCreateCompanionBuilder,
          $$AccountBalancesTableUpdateCompanionBuilder,
          (
            AccountBalanceRow,
            BaseReferences<
              _$AppDatabase,
              $AccountBalancesTable,
              AccountBalanceRow
            >,
          ),
          AccountBalanceRow,
          PrefetchHooks Function()
        > {
  $$AccountBalancesTableTableManager(
    _$AppDatabase db,
    $AccountBalancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountBalancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountBalancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountBalancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<int> balance = const Value.absent(),
                Value<int> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountBalancesCompanion(
                accountId: accountId,
                balance: balance,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required int balance,
                Value<int> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountBalancesCompanion.insert(
                accountId: accountId,
                balance: balance,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountBalancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountBalancesTable,
      AccountBalanceRow,
      $$AccountBalancesTableFilterComposer,
      $$AccountBalancesTableOrderingComposer,
      $$AccountBalancesTableAnnotationComposer,
      $$AccountBalancesTableCreateCompanionBuilder,
      $$AccountBalancesTableUpdateCompanionBuilder,
      (
        AccountBalanceRow,
        BaseReferences<_$AppDatabase, $AccountBalancesTable, AccountBalanceRow>,
      ),
      AccountBalanceRow,
      PrefetchHooks Function()
    >;
typedef $$DayClosesTableCreateCompanionBuilder =
    DayClosesCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      required String id,
      required String state,
      required String mode,
      Value<String?> closedByName,
      Value<int> diffs,
      Value<int> lateEntries,
      Value<String?> reopenReason,
      Value<int> rowid,
    });
typedef $$DayClosesTableUpdateCompanionBuilder =
    DayClosesCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      Value<String> id,
      Value<String> state,
      Value<String> mode,
      Value<String?> closedByName,
      Value<int> diffs,
      Value<int> lateEntries,
      Value<String?> reopenReason,
      Value<int> rowid,
    });

class $$DayClosesTableFilterComposer
    extends Composer<_$AppDatabase, $DayClosesTable> {
  $$DayClosesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedByName => $composableBuilder(
    column: $table.closedByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diffs => $composableBuilder(
    column: $table.diffs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lateEntries => $composableBuilder(
    column: $table.lateEntries,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reopenReason => $composableBuilder(
    column: $table.reopenReason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayClosesTableOrderingComposer
    extends Composer<_$AppDatabase, $DayClosesTable> {
  $$DayClosesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedByName => $composableBuilder(
    column: $table.closedByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diffs => $composableBuilder(
    column: $table.diffs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lateEntries => $composableBuilder(
    column: $table.lateEntries,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reopenReason => $composableBuilder(
    column: $table.reopenReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayClosesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayClosesTable> {
  $$DayClosesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get closedByName => $composableBuilder(
    column: $table.closedByName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get diffs =>
      $composableBuilder(column: $table.diffs, builder: (column) => column);

  GeneratedColumn<int> get lateEntries => $composableBuilder(
    column: $table.lateEntries,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reopenReason => $composableBuilder(
    column: $table.reopenReason,
    builder: (column) => column,
  );
}

class $$DayClosesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayClosesTable,
          DayCloseRow,
          $$DayClosesTableFilterComposer,
          $$DayClosesTableOrderingComposer,
          $$DayClosesTableAnnotationComposer,
          $$DayClosesTableCreateCompanionBuilder,
          $$DayClosesTableUpdateCompanionBuilder,
          (
            DayCloseRow,
            BaseReferences<_$AppDatabase, $DayClosesTable, DayCloseRow>,
          ),
          DayCloseRow,
          PrefetchHooks Function()
        > {
  $$DayClosesTableTableManager(_$AppDatabase db, $DayClosesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayClosesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayClosesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayClosesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String?> closedByName = const Value.absent(),
                Value<int> diffs = const Value.absent(),
                Value<int> lateEntries = const Value.absent(),
                Value<String?> reopenReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayClosesCompanion(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                state: state,
                mode: mode,
                closedByName: closedByName,
                diffs: diffs,
                lateEntries: lateEntries,
                reopenReason: reopenReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                required String id,
                required String state,
                required String mode,
                Value<String?> closedByName = const Value.absent(),
                Value<int> diffs = const Value.absent(),
                Value<int> lateEntries = const Value.absent(),
                Value<String?> reopenReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayClosesCompanion.insert(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                state: state,
                mode: mode,
                closedByName: closedByName,
                diffs: diffs,
                lateEntries: lateEntries,
                reopenReason: reopenReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayClosesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayClosesTable,
      DayCloseRow,
      $$DayClosesTableFilterComposer,
      $$DayClosesTableOrderingComposer,
      $$DayClosesTableAnnotationComposer,
      $$DayClosesTableCreateCompanionBuilder,
      $$DayClosesTableUpdateCompanionBuilder,
      (
        DayCloseRow,
        BaseReferences<_$AppDatabase, $DayClosesTable, DayCloseRow>,
      ),
      DayCloseRow,
      PrefetchHooks Function()
    >;
typedef $$DayCloseCountsTableCreateCompanionBuilder =
    DayCloseCountsCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      required String id,
      required String businessDate,
      required String accountId,
      required int expected,
      required int counted,
      required int diff,
      Value<String?> reason,
      Value<int> rowid,
    });
typedef $$DayCloseCountsTableUpdateCompanionBuilder =
    DayCloseCountsCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      Value<String> id,
      Value<String> businessDate,
      Value<String> accountId,
      Value<int> expected,
      Value<int> counted,
      Value<int> diff,
      Value<String?> reason,
      Value<int> rowid,
    });

class $$DayCloseCountsTableFilterComposer
    extends Composer<_$AppDatabase, $DayCloseCountsTable> {
  $$DayCloseCountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expected => $composableBuilder(
    column: $table.expected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get counted => $composableBuilder(
    column: $table.counted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diff => $composableBuilder(
    column: $table.diff,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayCloseCountsTableOrderingComposer
    extends Composer<_$AppDatabase, $DayCloseCountsTable> {
  $$DayCloseCountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expected => $composableBuilder(
    column: $table.expected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get counted => $composableBuilder(
    column: $table.counted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diff => $composableBuilder(
    column: $table.diff,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayCloseCountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayCloseCountsTable> {
  $$DayCloseCountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get expected =>
      $composableBuilder(column: $table.expected, builder: (column) => column);

  GeneratedColumn<int> get counted =>
      $composableBuilder(column: $table.counted, builder: (column) => column);

  GeneratedColumn<int> get diff =>
      $composableBuilder(column: $table.diff, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);
}

class $$DayCloseCountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayCloseCountsTable,
          DayCloseCountRow,
          $$DayCloseCountsTableFilterComposer,
          $$DayCloseCountsTableOrderingComposer,
          $$DayCloseCountsTableAnnotationComposer,
          $$DayCloseCountsTableCreateCompanionBuilder,
          $$DayCloseCountsTableUpdateCompanionBuilder,
          (
            DayCloseCountRow,
            BaseReferences<
              _$AppDatabase,
              $DayCloseCountsTable,
              DayCloseCountRow
            >,
          ),
          DayCloseCountRow,
          PrefetchHooks Function()
        > {
  $$DayCloseCountsTableTableManager(
    _$AppDatabase db,
    $DayCloseCountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayCloseCountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayCloseCountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayCloseCountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> expected = const Value.absent(),
                Value<int> counted = const Value.absent(),
                Value<int> diff = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayCloseCountsCompanion(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                businessDate: businessDate,
                accountId: accountId,
                expected: expected,
                counted: counted,
                diff: diff,
                reason: reason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                required String id,
                required String businessDate,
                required String accountId,
                required int expected,
                required int counted,
                required int diff,
                Value<String?> reason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayCloseCountsCompanion.insert(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                businessDate: businessDate,
                accountId: accountId,
                expected: expected,
                counted: counted,
                diff: diff,
                reason: reason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayCloseCountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayCloseCountsTable,
      DayCloseCountRow,
      $$DayCloseCountsTableFilterComposer,
      $$DayCloseCountsTableOrderingComposer,
      $$DayCloseCountsTableAnnotationComposer,
      $$DayCloseCountsTableCreateCompanionBuilder,
      $$DayCloseCountsTableUpdateCompanionBuilder,
      (
        DayCloseCountRow,
        BaseReferences<_$AppDatabase, $DayCloseCountsTable, DayCloseCountRow>,
      ),
      DayCloseCountRow,
      PrefetchHooks Function()
    >;
typedef $$ExamsTableCreateCompanionBuilder =
    ExamsCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      required String id,
      required String enrollmentId,
      required String studentId,
      required String studentName,
      Value<String?> carId,
      required String type,
      required int attempt,
      required String scheduledDate,
      Value<String> result,
      Value<int> fee,
      Value<String> historyJson,
      Value<int> rowid,
    });
typedef $$ExamsTableUpdateCompanionBuilder =
    ExamsCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      Value<String> id,
      Value<String> enrollmentId,
      Value<String> studentId,
      Value<String> studentName,
      Value<String?> carId,
      Value<String> type,
      Value<int> attempt,
      Value<String> scheduledDate,
      Value<String> result,
      Value<int> fee,
      Value<String> historyJson,
      Value<int> rowid,
    });

class $$ExamsTableFilterComposer extends Composer<_$AppDatabase, $ExamsTable> {
  $$ExamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enrollmentId => $composableBuilder(
    column: $table.enrollmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get carId => $composableBuilder(
    column: $table.carId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fee => $composableBuilder(
    column: $table.fee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get historyJson => $composableBuilder(
    column: $table.historyJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExamsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExamsTable> {
  $$ExamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enrollmentId => $composableBuilder(
    column: $table.enrollmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get carId => $composableBuilder(
    column: $table.carId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fee => $composableBuilder(
    column: $table.fee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get historyJson => $composableBuilder(
    column: $table.historyJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExamsTable> {
  $$ExamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get enrollmentId => $composableBuilder(
    column: $table.enrollmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get carId =>
      $composableBuilder(column: $table.carId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  GeneratedColumn<String> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<int> get fee =>
      $composableBuilder(column: $table.fee, builder: (column) => column);

  GeneratedColumn<String> get historyJson => $composableBuilder(
    column: $table.historyJson,
    builder: (column) => column,
  );
}

class $$ExamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExamsTable,
          ExamRow,
          $$ExamsTableFilterComposer,
          $$ExamsTableOrderingComposer,
          $$ExamsTableAnnotationComposer,
          $$ExamsTableCreateCompanionBuilder,
          $$ExamsTableUpdateCompanionBuilder,
          (ExamRow, BaseReferences<_$AppDatabase, $ExamsTable, ExamRow>),
          ExamRow,
          PrefetchHooks Function()
        > {
  $$ExamsTableTableManager(_$AppDatabase db, $ExamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> enrollmentId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> studentName = const Value.absent(),
                Value<String?> carId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<String> scheduledDate = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<int> fee = const Value.absent(),
                Value<String> historyJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExamsCompanion(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                enrollmentId: enrollmentId,
                studentId: studentId,
                studentName: studentName,
                carId: carId,
                type: type,
                attempt: attempt,
                scheduledDate: scheduledDate,
                result: result,
                fee: fee,
                historyJson: historyJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                required String id,
                required String enrollmentId,
                required String studentId,
                required String studentName,
                Value<String?> carId = const Value.absent(),
                required String type,
                required int attempt,
                required String scheduledDate,
                Value<String> result = const Value.absent(),
                Value<int> fee = const Value.absent(),
                Value<String> historyJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExamsCompanion.insert(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                enrollmentId: enrollmentId,
                studentId: studentId,
                studentName: studentName,
                carId: carId,
                type: type,
                attempt: attempt,
                scheduledDate: scheduledDate,
                result: result,
                fee: fee,
                historyJson: historyJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExamsTable,
      ExamRow,
      $$ExamsTableFilterComposer,
      $$ExamsTableOrderingComposer,
      $$ExamsTableAnnotationComposer,
      $$ExamsTableCreateCompanionBuilder,
      $$ExamsTableUpdateCompanionBuilder,
      (ExamRow, BaseReferences<_$AppDatabase, $ExamsTable, ExamRow>),
      ExamRow,
      PrefetchHooks Function()
    >;
typedef $$SalaryRatesTableCreateCompanionBuilder =
    SalaryRatesCompanion Function({
      required String id,
      required String employeeId,
      required String effectiveFrom,
      required int monthlyAmount,
      Value<int?> serverSeq,
      Value<int> rowid,
    });
typedef $$SalaryRatesTableUpdateCompanionBuilder =
    SalaryRatesCompanion Function({
      Value<String> id,
      Value<String> employeeId,
      Value<String> effectiveFrom,
      Value<int> monthlyAmount,
      Value<int?> serverSeq,
      Value<int> rowid,
    });

class $$SalaryRatesTableFilterComposer
    extends Composer<_$AppDatabase, $SalaryRatesTable> {
  $$SalaryRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyAmount => $composableBuilder(
    column: $table.monthlyAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SalaryRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalaryRatesTable> {
  $$SalaryRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyAmount => $composableBuilder(
    column: $table.monthlyAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalaryRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalaryRatesTable> {
  $$SalaryRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthlyAmount => $composableBuilder(
    column: $table.monthlyAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$SalaryRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalaryRatesTable,
          SalaryRateRow,
          $$SalaryRatesTableFilterComposer,
          $$SalaryRatesTableOrderingComposer,
          $$SalaryRatesTableAnnotationComposer,
          $$SalaryRatesTableCreateCompanionBuilder,
          $$SalaryRatesTableUpdateCompanionBuilder,
          (
            SalaryRateRow,
            BaseReferences<_$AppDatabase, $SalaryRatesTable, SalaryRateRow>,
          ),
          SalaryRateRow,
          PrefetchHooks Function()
        > {
  $$SalaryRatesTableTableManager(_$AppDatabase db, $SalaryRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalaryRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalaryRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalaryRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<String> effectiveFrom = const Value.absent(),
                Value<int> monthlyAmount = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalaryRatesCompanion(
                id: id,
                employeeId: employeeId,
                effectiveFrom: effectiveFrom,
                monthlyAmount: monthlyAmount,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String employeeId,
                required String effectiveFrom,
                required int monthlyAmount,
                Value<int?> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalaryRatesCompanion.insert(
                id: id,
                employeeId: employeeId,
                effectiveFrom: effectiveFrom,
                monthlyAmount: monthlyAmount,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SalaryRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalaryRatesTable,
      SalaryRateRow,
      $$SalaryRatesTableFilterComposer,
      $$SalaryRatesTableOrderingComposer,
      $$SalaryRatesTableAnnotationComposer,
      $$SalaryRatesTableCreateCompanionBuilder,
      $$SalaryRatesTableUpdateCompanionBuilder,
      (
        SalaryRateRow,
        BaseReferences<_$AppDatabase, $SalaryRatesTable, SalaryRateRow>,
      ),
      SalaryRateRow,
      PrefetchHooks Function()
    >;
typedef $$PayrollItemsTableCreateCompanionBuilder =
    PayrollItemsCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      required String id,
      required String employeeId,
      required String employeeName,
      required String payrollMonth,
      required String kind,
      required String reason,
      Value<String?> note,
      required int amount,
      Value<String?> accountId,
      required String businessDate,
      Value<String?> recordedByName,
      Value<int> rowid,
    });
typedef $$PayrollItemsTableUpdateCompanionBuilder =
    PayrollItemsCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      Value<String> id,
      Value<String> employeeId,
      Value<String> employeeName,
      Value<String> payrollMonth,
      Value<String> kind,
      Value<String> reason,
      Value<String?> note,
      Value<int> amount,
      Value<String?> accountId,
      Value<String> businessDate,
      Value<String?> recordedByName,
      Value<int> rowid,
    });

class $$PayrollItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PayrollItemsTable> {
  $$PayrollItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payrollMonth => $composableBuilder(
    column: $table.payrollMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordedByName => $composableBuilder(
    column: $table.recordedByName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PayrollItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PayrollItemsTable> {
  $$PayrollItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payrollMonth => $composableBuilder(
    column: $table.payrollMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordedByName => $composableBuilder(
    column: $table.recordedByName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PayrollItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayrollItemsTable> {
  $$PayrollItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payrollMonth => $composableBuilder(
    column: $table.payrollMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordedByName => $composableBuilder(
    column: $table.recordedByName,
    builder: (column) => column,
  );
}

class $$PayrollItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PayrollItemsTable,
          PayrollItemRow,
          $$PayrollItemsTableFilterComposer,
          $$PayrollItemsTableOrderingComposer,
          $$PayrollItemsTableAnnotationComposer,
          $$PayrollItemsTableCreateCompanionBuilder,
          $$PayrollItemsTableUpdateCompanionBuilder,
          (
            PayrollItemRow,
            BaseReferences<_$AppDatabase, $PayrollItemsTable, PayrollItemRow>,
          ),
          PayrollItemRow,
          PrefetchHooks Function()
        > {
  $$PayrollItemsTableTableManager(_$AppDatabase db, $PayrollItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayrollItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayrollItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayrollItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<String> employeeName = const Value.absent(),
                Value<String> payrollMonth = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<String?> recordedByName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayrollItemsCompanion(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                employeeId: employeeId,
                employeeName: employeeName,
                payrollMonth: payrollMonth,
                kind: kind,
                reason: reason,
                note: note,
                amount: amount,
                accountId: accountId,
                businessDate: businessDate,
                recordedByName: recordedByName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                required String id,
                required String employeeId,
                required String employeeName,
                required String payrollMonth,
                required String kind,
                required String reason,
                Value<String?> note = const Value.absent(),
                required int amount,
                Value<String?> accountId = const Value.absent(),
                required String businessDate,
                Value<String?> recordedByName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayrollItemsCompanion.insert(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                employeeId: employeeId,
                employeeName: employeeName,
                payrollMonth: payrollMonth,
                kind: kind,
                reason: reason,
                note: note,
                amount: amount,
                accountId: accountId,
                businessDate: businessDate,
                recordedByName: recordedByName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PayrollItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PayrollItemsTable,
      PayrollItemRow,
      $$PayrollItemsTableFilterComposer,
      $$PayrollItemsTableOrderingComposer,
      $$PayrollItemsTableAnnotationComposer,
      $$PayrollItemsTableCreateCompanionBuilder,
      $$PayrollItemsTableUpdateCompanionBuilder,
      (
        PayrollItemRow,
        BaseReferences<_$AppDatabase, $PayrollItemsTable, PayrollItemRow>,
      ),
      PayrollItemRow,
      PrefetchHooks Function()
    >;
typedef $$SalaryPaymentsTableCreateCompanionBuilder =
    SalaryPaymentsCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      required String id,
      required String employeeId,
      required String employeeName,
      required String payrollMonth,
      required int salaryAtMonth,
      required int bonuses,
      required int deductions,
      required int advances,
      required int net,
      required String accountId,
      required String businessDate,
      Value<bool> early,
      Value<String?> paidByName,
      Value<int> rowid,
    });
typedef $$SalaryPaymentsTableUpdateCompanionBuilder =
    SalaryPaymentsCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      Value<String> id,
      Value<String> employeeId,
      Value<String> employeeName,
      Value<String> payrollMonth,
      Value<int> salaryAtMonth,
      Value<int> bonuses,
      Value<int> deductions,
      Value<int> advances,
      Value<int> net,
      Value<String> accountId,
      Value<String> businessDate,
      Value<bool> early,
      Value<String?> paidByName,
      Value<int> rowid,
    });

class $$SalaryPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $SalaryPaymentsTable> {
  $$SalaryPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payrollMonth => $composableBuilder(
    column: $table.payrollMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get salaryAtMonth => $composableBuilder(
    column: $table.salaryAtMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bonuses => $composableBuilder(
    column: $table.bonuses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deductions => $composableBuilder(
    column: $table.deductions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get advances => $composableBuilder(
    column: $table.advances,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get net => $composableBuilder(
    column: $table.net,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get early => $composableBuilder(
    column: $table.early,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paidByName => $composableBuilder(
    column: $table.paidByName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SalaryPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SalaryPaymentsTable> {
  $$SalaryPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payrollMonth => $composableBuilder(
    column: $table.payrollMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salaryAtMonth => $composableBuilder(
    column: $table.salaryAtMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bonuses => $composableBuilder(
    column: $table.bonuses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deductions => $composableBuilder(
    column: $table.deductions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get advances => $composableBuilder(
    column: $table.advances,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get net => $composableBuilder(
    column: $table.net,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get early => $composableBuilder(
    column: $table.early,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paidByName => $composableBuilder(
    column: $table.paidByName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalaryPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalaryPaymentsTable> {
  $$SalaryPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get employeeName => $composableBuilder(
    column: $table.employeeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payrollMonth => $composableBuilder(
    column: $table.payrollMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get salaryAtMonth => $composableBuilder(
    column: $table.salaryAtMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bonuses =>
      $composableBuilder(column: $table.bonuses, builder: (column) => column);

  GeneratedColumn<int> get deductions => $composableBuilder(
    column: $table.deductions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get advances =>
      $composableBuilder(column: $table.advances, builder: (column) => column);

  GeneratedColumn<int> get net =>
      $composableBuilder(column: $table.net, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get early =>
      $composableBuilder(column: $table.early, builder: (column) => column);

  GeneratedColumn<String> get paidByName => $composableBuilder(
    column: $table.paidByName,
    builder: (column) => column,
  );
}

class $$SalaryPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalaryPaymentsTable,
          SalaryPaymentRow,
          $$SalaryPaymentsTableFilterComposer,
          $$SalaryPaymentsTableOrderingComposer,
          $$SalaryPaymentsTableAnnotationComposer,
          $$SalaryPaymentsTableCreateCompanionBuilder,
          $$SalaryPaymentsTableUpdateCompanionBuilder,
          (
            SalaryPaymentRow,
            BaseReferences<
              _$AppDatabase,
              $SalaryPaymentsTable,
              SalaryPaymentRow
            >,
          ),
          SalaryPaymentRow,
          PrefetchHooks Function()
        > {
  $$SalaryPaymentsTableTableManager(
    _$AppDatabase db,
    $SalaryPaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalaryPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalaryPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalaryPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<String> employeeName = const Value.absent(),
                Value<String> payrollMonth = const Value.absent(),
                Value<int> salaryAtMonth = const Value.absent(),
                Value<int> bonuses = const Value.absent(),
                Value<int> deductions = const Value.absent(),
                Value<int> advances = const Value.absent(),
                Value<int> net = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<bool> early = const Value.absent(),
                Value<String?> paidByName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalaryPaymentsCompanion(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                employeeId: employeeId,
                employeeName: employeeName,
                payrollMonth: payrollMonth,
                salaryAtMonth: salaryAtMonth,
                bonuses: bonuses,
                deductions: deductions,
                advances: advances,
                net: net,
                accountId: accountId,
                businessDate: businessDate,
                early: early,
                paidByName: paidByName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                required String id,
                required String employeeId,
                required String employeeName,
                required String payrollMonth,
                required int salaryAtMonth,
                required int bonuses,
                required int deductions,
                required int advances,
                required int net,
                required String accountId,
                required String businessDate,
                Value<bool> early = const Value.absent(),
                Value<String?> paidByName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalaryPaymentsCompanion.insert(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                employeeId: employeeId,
                employeeName: employeeName,
                payrollMonth: payrollMonth,
                salaryAtMonth: salaryAtMonth,
                bonuses: bonuses,
                deductions: deductions,
                advances: advances,
                net: net,
                accountId: accountId,
                businessDate: businessDate,
                early: early,
                paidByName: paidByName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SalaryPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalaryPaymentsTable,
      SalaryPaymentRow,
      $$SalaryPaymentsTableFilterComposer,
      $$SalaryPaymentsTableOrderingComposer,
      $$SalaryPaymentsTableAnnotationComposer,
      $$SalaryPaymentsTableCreateCompanionBuilder,
      $$SalaryPaymentsTableUpdateCompanionBuilder,
      (
        SalaryPaymentRow,
        BaseReferences<_$AppDatabase, $SalaryPaymentsTable, SalaryPaymentRow>,
      ),
      SalaryPaymentRow,
      PrefetchHooks Function()
    >;
typedef $$AppUsersTableCreateCompanionBuilder =
    AppUsersCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      required String id,
      required String name,
      required String nationalId,
      Value<String?> phone,
      required String kind,
      Value<String> status,
      Value<String?> job,
      Value<String?> employeeId,
      Value<String> permissionsJson,
      Value<int> permVersion,
      Value<int> rowid,
    });
typedef $$AppUsersTableUpdateCompanionBuilder =
    AppUsersCompanion Function({
      Value<String?> opId,
      Value<String> syncState,
      Value<int?> serverSeq,
      Value<String?> at,
      Value<String> id,
      Value<String> name,
      Value<String> nationalId,
      Value<String?> phone,
      Value<String> kind,
      Value<String> status,
      Value<String?> job,
      Value<String?> employeeId,
      Value<String> permissionsJson,
      Value<int> permVersion,
      Value<int> rowid,
    });

class $$AppUsersTableFilterComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get job => $composableBuilder(
    column: $table.job,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permissionsJson => $composableBuilder(
    column: $table.permissionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get permVersion => $composableBuilder(
    column: $table.permVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get job => $composableBuilder(
    column: $table.job,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permissionsJson => $composableBuilder(
    column: $table.permissionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get permVersion => $composableBuilder(
    column: $table.permVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get job =>
      $composableBuilder(column: $table.job, builder: (column) => column);

  GeneratedColumn<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get permissionsJson => $composableBuilder(
    column: $table.permissionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get permVersion => $composableBuilder(
    column: $table.permVersion,
    builder: (column) => column,
  );
}

class $$AppUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppUsersTable,
          AppUserRow,
          $$AppUsersTableFilterComposer,
          $$AppUsersTableOrderingComposer,
          $$AppUsersTableAnnotationComposer,
          $$AppUsersTableCreateCompanionBuilder,
          $$AppUsersTableUpdateCompanionBuilder,
          (
            AppUserRow,
            BaseReferences<_$AppDatabase, $AppUsersTable, AppUserRow>,
          ),
          AppUserRow,
          PrefetchHooks Function()
        > {
  $$AppUsersTableTableManager(_$AppDatabase db, $AppUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nationalId = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> job = const Value.absent(),
                Value<String?> employeeId = const Value.absent(),
                Value<String> permissionsJson = const Value.absent(),
                Value<int> permVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppUsersCompanion(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                name: name,
                nationalId: nationalId,
                phone: phone,
                kind: kind,
                status: status,
                job: job,
                employeeId: employeeId,
                permissionsJson: permissionsJson,
                permVersion: permVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> opId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String?> at = const Value.absent(),
                required String id,
                required String name,
                required String nationalId,
                Value<String?> phone = const Value.absent(),
                required String kind,
                Value<String> status = const Value.absent(),
                Value<String?> job = const Value.absent(),
                Value<String?> employeeId = const Value.absent(),
                Value<String> permissionsJson = const Value.absent(),
                Value<int> permVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppUsersCompanion.insert(
                opId: opId,
                syncState: syncState,
                serverSeq: serverSeq,
                at: at,
                id: id,
                name: name,
                nationalId: nationalId,
                phone: phone,
                kind: kind,
                status: status,
                job: job,
                employeeId: employeeId,
                permissionsJson: permissionsJson,
                permVersion: permVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppUsersTable,
      AppUserRow,
      $$AppUsersTableFilterComposer,
      $$AppUsersTableOrderingComposer,
      $$AppUsersTableAnnotationComposer,
      $$AppUsersTableCreateCompanionBuilder,
      $$AppUsersTableUpdateCompanionBuilder,
      (AppUserRow, BaseReferences<_$AppDatabase, $AppUsersTable, AppUserRow>),
      AppUserRow,
      PrefetchHooks Function()
    >;
typedef $$ActivityLogsTableCreateCompanionBuilder =
    ActivityLogsCompanion Function({
      required String id,
      required String opType,
      required String entity,
      required String recordId,
      required String recordLabel,
      Value<String> changesJson,
      Value<String?> reason,
      required String actorId,
      required String actorName,
      Value<String?> deviceId,
      Value<String?> opId,
      required String at,
      Value<bool> lateAfterClose,
      Value<int?> serverSeq,
      Value<int> rowid,
    });
typedef $$ActivityLogsTableUpdateCompanionBuilder =
    ActivityLogsCompanion Function({
      Value<String> id,
      Value<String> opType,
      Value<String> entity,
      Value<String> recordId,
      Value<String> recordLabel,
      Value<String> changesJson,
      Value<String?> reason,
      Value<String> actorId,
      Value<String> actorName,
      Value<String?> deviceId,
      Value<String?> opId,
      Value<String> at,
      Value<bool> lateAfterClose,
      Value<int?> serverSeq,
      Value<int> rowid,
    });

class $$ActivityLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityLogsTable> {
  $$ActivityLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordLabel => $composableBuilder(
    column: $table.recordLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changesJson => $composableBuilder(
    column: $table.changesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorName => $composableBuilder(
    column: $table.actorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lateAfterClose => $composableBuilder(
    column: $table.lateAfterClose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivityLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityLogsTable> {
  $$ActivityLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordLabel => $composableBuilder(
    column: $table.recordLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changesJson => $composableBuilder(
    column: $table.changesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorName => $composableBuilder(
    column: $table.actorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lateAfterClose => $composableBuilder(
    column: $table.lateAfterClose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivityLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityLogsTable> {
  $$ActivityLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get recordLabel => $composableBuilder(
    column: $table.recordLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get changesJson => $composableBuilder(
    column: $table.changesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get actorName =>
      $composableBuilder(column: $table.actorName, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<bool> get lateAfterClose => $composableBuilder(
    column: $table.lateAfterClose,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$ActivityLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityLogsTable,
          ActivityRow,
          $$ActivityLogsTableFilterComposer,
          $$ActivityLogsTableOrderingComposer,
          $$ActivityLogsTableAnnotationComposer,
          $$ActivityLogsTableCreateCompanionBuilder,
          $$ActivityLogsTableUpdateCompanionBuilder,
          (
            ActivityRow,
            BaseReferences<_$AppDatabase, $ActivityLogsTable, ActivityRow>,
          ),
          ActivityRow,
          PrefetchHooks Function()
        > {
  $$ActivityLogsTableTableManager(_$AppDatabase db, $ActivityLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> opType = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> recordLabel = const Value.absent(),
                Value<String> changesJson = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String> actorId = const Value.absent(),
                Value<String> actorName = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String?> opId = const Value.absent(),
                Value<String> at = const Value.absent(),
                Value<bool> lateAfterClose = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityLogsCompanion(
                id: id,
                opType: opType,
                entity: entity,
                recordId: recordId,
                recordLabel: recordLabel,
                changesJson: changesJson,
                reason: reason,
                actorId: actorId,
                actorName: actorName,
                deviceId: deviceId,
                opId: opId,
                at: at,
                lateAfterClose: lateAfterClose,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String opType,
                required String entity,
                required String recordId,
                required String recordLabel,
                Value<String> changesJson = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                required String actorId,
                required String actorName,
                Value<String?> deviceId = const Value.absent(),
                Value<String?> opId = const Value.absent(),
                required String at,
                Value<bool> lateAfterClose = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityLogsCompanion.insert(
                id: id,
                opType: opType,
                entity: entity,
                recordId: recordId,
                recordLabel: recordLabel,
                changesJson: changesJson,
                reason: reason,
                actorId: actorId,
                actorName: actorName,
                deviceId: deviceId,
                opId: opId,
                at: at,
                lateAfterClose: lateAfterClose,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivityLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityLogsTable,
      ActivityRow,
      $$ActivityLogsTableFilterComposer,
      $$ActivityLogsTableOrderingComposer,
      $$ActivityLogsTableAnnotationComposer,
      $$ActivityLogsTableCreateCompanionBuilder,
      $$ActivityLogsTableUpdateCompanionBuilder,
      (
        ActivityRow,
        BaseReferences<_$AppDatabase, $ActivityLogsTable, ActivityRow>,
      ),
      ActivityRow,
      PrefetchHooks Function()
    >;
typedef $$MonthLocksTableCreateCompanionBuilder =
    MonthLocksCompanion Function({
      required String id,
      Value<bool> locked,
      Value<String?> lockedByName,
      Value<String?> unlockReason,
      Value<int?> serverSeq,
      Value<int> rowid,
    });
typedef $$MonthLocksTableUpdateCompanionBuilder =
    MonthLocksCompanion Function({
      Value<String> id,
      Value<bool> locked,
      Value<String?> lockedByName,
      Value<String?> unlockReason,
      Value<int?> serverSeq,
      Value<int> rowid,
    });

class $$MonthLocksTableFilterComposer
    extends Composer<_$AppDatabase, $MonthLocksTable> {
  $$MonthLocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lockedByName => $composableBuilder(
    column: $table.lockedByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unlockReason => $composableBuilder(
    column: $table.unlockReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MonthLocksTableOrderingComposer
    extends Composer<_$AppDatabase, $MonthLocksTable> {
  $$MonthLocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lockedByName => $composableBuilder(
    column: $table.lockedByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unlockReason => $composableBuilder(
    column: $table.unlockReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonthLocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonthLocksTable> {
  $$MonthLocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);

  GeneratedColumn<String> get lockedByName => $composableBuilder(
    column: $table.lockedByName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unlockReason => $composableBuilder(
    column: $table.unlockReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$MonthLocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonthLocksTable,
          MonthLockRow,
          $$MonthLocksTableFilterComposer,
          $$MonthLocksTableOrderingComposer,
          $$MonthLocksTableAnnotationComposer,
          $$MonthLocksTableCreateCompanionBuilder,
          $$MonthLocksTableUpdateCompanionBuilder,
          (
            MonthLockRow,
            BaseReferences<_$AppDatabase, $MonthLocksTable, MonthLockRow>,
          ),
          MonthLockRow,
          PrefetchHooks Function()
        > {
  $$MonthLocksTableTableManager(_$AppDatabase db, $MonthLocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonthLocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonthLocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonthLocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<String?> lockedByName = const Value.absent(),
                Value<String?> unlockReason = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonthLocksCompanion(
                id: id,
                locked: locked,
                lockedByName: lockedByName,
                unlockReason: unlockReason,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<bool> locked = const Value.absent(),
                Value<String?> lockedByName = const Value.absent(),
                Value<String?> unlockReason = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonthLocksCompanion.insert(
                id: id,
                locked: locked,
                lockedByName: lockedByName,
                unlockReason: unlockReason,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MonthLocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonthLocksTable,
      MonthLockRow,
      $$MonthLocksTableFilterComposer,
      $$MonthLocksTableOrderingComposer,
      $$MonthLocksTableAnnotationComposer,
      $$MonthLocksTableCreateCompanionBuilder,
      $$MonthLocksTableUpdateCompanionBuilder,
      (
        MonthLockRow,
        BaseReferences<_$AppDatabase, $MonthLocksTable, MonthLockRow>,
      ),
      MonthLockRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String valueJson,
      Value<int?> serverSeq,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> valueJson,
      Value<int?> serverSeq,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(
                key: key,
                valueJson: valueJson,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String valueJson,
                Value<int?> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                valueJson: valueJson,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$EnrollmentsTableTableManager get enrollments =>
      $$EnrollmentsTableTableManager(_db, _db.enrollments);
  $$LessonsTableTableManager get lessons =>
      $$LessonsTableTableManager(_db, _db.lessons);
  $$LedgerEntriesTableTableManager get ledgerEntries =>
      $$LedgerEntriesTableTableManager(_db, _db.ledgerEntries);
  $$TreasuryMovementsTableTableManager get treasuryMovements =>
      $$TreasuryMovementsTableTableManager(_db, _db.treasuryMovements);
  $$LicensePricesTableTableManager get licensePrices =>
      $$LicensePricesTableTableManager(_db, _db.licensePrices);
  $$StudentSummariesTableTableManager get studentSummaries =>
      $$StudentSummariesTableTableManager(_db, _db.studentSummaries);
  $$OutboxOpsTableTableManager get outboxOps =>
      $$OutboxOpsTableTableManager(_db, _db.outboxOps);
  $$RejectedOpsTableTableManager get rejectedOps =>
      $$RejectedOpsTableTableManager(_db, _db.rejectedOps);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$KvEntriesTableTableManager get kvEntries =>
      $$KvEntriesTableTableManager(_db, _db.kvEntries);
  $$CarsTableTableManager get cars => $$CarsTableTableManager(_db, _db.cars);
  $$CarInstructorsTableTableManager get carInstructors =>
      $$CarInstructorsTableTableManager(_db, _db.carInstructors);
  $$EmployeesTableTableManager get employees =>
      $$EmployeesTableTableManager(_db, _db.employees);
  $$LicenseTypesTableTableManager get licenseTypes =>
      $$LicenseTypesTableTableManager(_db, _db.licenseTypes);
  $$TreasuryAccountsTableTableManager get treasuryAccounts =>
      $$TreasuryAccountsTableTableManager(_db, _db.treasuryAccounts);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$AccountBalancesTableTableManager get accountBalances =>
      $$AccountBalancesTableTableManager(_db, _db.accountBalances);
  $$DayClosesTableTableManager get dayCloses =>
      $$DayClosesTableTableManager(_db, _db.dayCloses);
  $$DayCloseCountsTableTableManager get dayCloseCounts =>
      $$DayCloseCountsTableTableManager(_db, _db.dayCloseCounts);
  $$ExamsTableTableManager get exams =>
      $$ExamsTableTableManager(_db, _db.exams);
  $$SalaryRatesTableTableManager get salaryRates =>
      $$SalaryRatesTableTableManager(_db, _db.salaryRates);
  $$PayrollItemsTableTableManager get payrollItems =>
      $$PayrollItemsTableTableManager(_db, _db.payrollItems);
  $$SalaryPaymentsTableTableManager get salaryPayments =>
      $$SalaryPaymentsTableTableManager(_db, _db.salaryPayments);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db, _db.appUsers);
  $$ActivityLogsTableTableManager get activityLogs =>
      $$ActivityLogsTableTableManager(_db, _db.activityLogs);
  $$MonthLocksTableTableManager get monthLocks =>
      $$MonthLocksTableTableManager(_db, _db.monthLocks);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
