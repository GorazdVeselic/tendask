// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TaskTypesTable extends TaskTypes
    with TableInfo<$TaskTypesTable, TaskType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelsMeta = const VerificationMeta('labels');
  @override
  late final GeneratedColumn<String> labels = GeneratedColumn<String>(
    'labels',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requiresSubjectMeta = const VerificationMeta(
    'requiresSubject',
  );
  @override
  late final GeneratedColumn<bool> requiresSubject = GeneratedColumn<bool>(
    'requires_subject',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("requires_subject" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _weatherSensitiveMeta = const VerificationMeta(
    'weatherSensitive',
  );
  @override
  late final GeneratedColumn<bool> weatherSensitive = GeneratedColumn<bool>(
    'weather_sensitive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("weather_sensitive" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _defaultCadenceMeta = const VerificationMeta(
    'defaultCadence',
  );
  @override
  late final GeneratedColumn<int> defaultCadence = GeneratedColumn<int>(
    'default_cadence',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    labels,
    icon,
    category,
    requiresSubject,
    weatherSensitive,
    defaultCadence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_type';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('labels')) {
      context.handle(
        _labelsMeta,
        labels.isAcceptableOrUnknown(data['labels']!, _labelsMeta),
      );
    } else if (isInserting) {
      context.missing(_labelsMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('requires_subject')) {
      context.handle(
        _requiresSubjectMeta,
        requiresSubject.isAcceptableOrUnknown(
          data['requires_subject']!,
          _requiresSubjectMeta,
        ),
      );
    }
    if (data.containsKey('weather_sensitive')) {
      context.handle(
        _weatherSensitiveMeta,
        weatherSensitive.isAcceptableOrUnknown(
          data['weather_sensitive']!,
          _weatherSensitiveMeta,
        ),
      );
    }
    if (data.containsKey('default_cadence')) {
      context.handle(
        _defaultCadenceMeta,
        defaultCadence.isAcceptableOrUnknown(
          data['default_cadence']!,
          _defaultCadenceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      labels: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}labels'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      requiresSubject: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}requires_subject'],
      )!,
      weatherSensitive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}weather_sensitive'],
      )!,
      defaultCadence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_cadence'],
      ),
    );
  }

  @override
  $TaskTypesTable createAlias(String alias) {
    return $TaskTypesTable(attachedDatabase, alias);
  }
}

class TaskType extends DataClass implements Insertable<TaskType> {
  final String id;
  final String labels;
  final String icon;
  final String category;
  final bool requiresSubject;
  final bool weatherSensitive;
  final int? defaultCadence;
  const TaskType({
    required this.id,
    required this.labels,
    required this.icon,
    required this.category,
    required this.requiresSubject,
    required this.weatherSensitive,
    this.defaultCadence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['labels'] = Variable<String>(labels);
    map['icon'] = Variable<String>(icon);
    map['category'] = Variable<String>(category);
    map['requires_subject'] = Variable<bool>(requiresSubject);
    map['weather_sensitive'] = Variable<bool>(weatherSensitive);
    if (!nullToAbsent || defaultCadence != null) {
      map['default_cadence'] = Variable<int>(defaultCadence);
    }
    return map;
  }

  TaskTypesCompanion toCompanion(bool nullToAbsent) {
    return TaskTypesCompanion(
      id: Value(id),
      labels: Value(labels),
      icon: Value(icon),
      category: Value(category),
      requiresSubject: Value(requiresSubject),
      weatherSensitive: Value(weatherSensitive),
      defaultCadence: defaultCadence == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultCadence),
    );
  }

  factory TaskType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskType(
      id: serializer.fromJson<String>(json['id']),
      labels: serializer.fromJson<String>(json['labels']),
      icon: serializer.fromJson<String>(json['icon']),
      category: serializer.fromJson<String>(json['category']),
      requiresSubject: serializer.fromJson<bool>(json['requiresSubject']),
      weatherSensitive: serializer.fromJson<bool>(json['weatherSensitive']),
      defaultCadence: serializer.fromJson<int?>(json['defaultCadence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'labels': serializer.toJson<String>(labels),
      'icon': serializer.toJson<String>(icon),
      'category': serializer.toJson<String>(category),
      'requiresSubject': serializer.toJson<bool>(requiresSubject),
      'weatherSensitive': serializer.toJson<bool>(weatherSensitive),
      'defaultCadence': serializer.toJson<int?>(defaultCadence),
    };
  }

  TaskType copyWith({
    String? id,
    String? labels,
    String? icon,
    String? category,
    bool? requiresSubject,
    bool? weatherSensitive,
    Value<int?> defaultCadence = const Value.absent(),
  }) => TaskType(
    id: id ?? this.id,
    labels: labels ?? this.labels,
    icon: icon ?? this.icon,
    category: category ?? this.category,
    requiresSubject: requiresSubject ?? this.requiresSubject,
    weatherSensitive: weatherSensitive ?? this.weatherSensitive,
    defaultCadence: defaultCadence.present
        ? defaultCadence.value
        : this.defaultCadence,
  );
  TaskType copyWithCompanion(TaskTypesCompanion data) {
    return TaskType(
      id: data.id.present ? data.id.value : this.id,
      labels: data.labels.present ? data.labels.value : this.labels,
      icon: data.icon.present ? data.icon.value : this.icon,
      category: data.category.present ? data.category.value : this.category,
      requiresSubject: data.requiresSubject.present
          ? data.requiresSubject.value
          : this.requiresSubject,
      weatherSensitive: data.weatherSensitive.present
          ? data.weatherSensitive.value
          : this.weatherSensitive,
      defaultCadence: data.defaultCadence.present
          ? data.defaultCadence.value
          : this.defaultCadence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskType(')
          ..write('id: $id, ')
          ..write('labels: $labels, ')
          ..write('icon: $icon, ')
          ..write('category: $category, ')
          ..write('requiresSubject: $requiresSubject, ')
          ..write('weatherSensitive: $weatherSensitive, ')
          ..write('defaultCadence: $defaultCadence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    labels,
    icon,
    category,
    requiresSubject,
    weatherSensitive,
    defaultCadence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskType &&
          other.id == this.id &&
          other.labels == this.labels &&
          other.icon == this.icon &&
          other.category == this.category &&
          other.requiresSubject == this.requiresSubject &&
          other.weatherSensitive == this.weatherSensitive &&
          other.defaultCadence == this.defaultCadence);
}

class TaskTypesCompanion extends UpdateCompanion<TaskType> {
  final Value<String> id;
  final Value<String> labels;
  final Value<String> icon;
  final Value<String> category;
  final Value<bool> requiresSubject;
  final Value<bool> weatherSensitive;
  final Value<int?> defaultCadence;
  final Value<int> rowid;
  const TaskTypesCompanion({
    this.id = const Value.absent(),
    this.labels = const Value.absent(),
    this.icon = const Value.absent(),
    this.category = const Value.absent(),
    this.requiresSubject = const Value.absent(),
    this.weatherSensitive = const Value.absent(),
    this.defaultCadence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskTypesCompanion.insert({
    required String id,
    required String labels,
    required String icon,
    required String category,
    this.requiresSubject = const Value.absent(),
    this.weatherSensitive = const Value.absent(),
    this.defaultCadence = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       labels = Value(labels),
       icon = Value(icon),
       category = Value(category);
  static Insertable<TaskType> custom({
    Expression<String>? id,
    Expression<String>? labels,
    Expression<String>? icon,
    Expression<String>? category,
    Expression<bool>? requiresSubject,
    Expression<bool>? weatherSensitive,
    Expression<int>? defaultCadence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (labels != null) 'labels': labels,
      if (icon != null) 'icon': icon,
      if (category != null) 'category': category,
      if (requiresSubject != null) 'requires_subject': requiresSubject,
      if (weatherSensitive != null) 'weather_sensitive': weatherSensitive,
      if (defaultCadence != null) 'default_cadence': defaultCadence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskTypesCompanion copyWith({
    Value<String>? id,
    Value<String>? labels,
    Value<String>? icon,
    Value<String>? category,
    Value<bool>? requiresSubject,
    Value<bool>? weatherSensitive,
    Value<int?>? defaultCadence,
    Value<int>? rowid,
  }) {
    return TaskTypesCompanion(
      id: id ?? this.id,
      labels: labels ?? this.labels,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      requiresSubject: requiresSubject ?? this.requiresSubject,
      weatherSensitive: weatherSensitive ?? this.weatherSensitive,
      defaultCadence: defaultCadence ?? this.defaultCadence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (labels.present) {
      map['labels'] = Variable<String>(labels.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (requiresSubject.present) {
      map['requires_subject'] = Variable<bool>(requiresSubject.value);
    }
    if (weatherSensitive.present) {
      map['weather_sensitive'] = Variable<bool>(weatherSensitive.value);
    }
    if (defaultCadence.present) {
      map['default_cadence'] = Variable<int>(defaultCadence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskTypesCompanion(')
          ..write('id: $id, ')
          ..write('labels: $labels, ')
          ..write('icon: $icon, ')
          ..write('category: $category, ')
          ..write('requiresSubject: $requiresSubject, ')
          ..write('weatherSensitive: $weatherSensitive, ')
          ..write('defaultCadence: $defaultCadence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlantsTable extends Plants with TableInfo<$PlantsTable, Plant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelsMeta = const VerificationMeta('labels');
  @override
  late final GeneratedColumn<String> labels = GeneratedColumn<String>(
    'labels',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scientificNameMeta = const VerificationMeta(
    'scientificName',
  );
  @override
  late final GeneratedColumn<String> scientificName = GeneratedColumn<String>(
    'scientific_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    labels,
    scientificName,
    category,
    icon,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plant';
  @override
  VerificationContext validateIntegrity(
    Insertable<Plant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('labels')) {
      context.handle(
        _labelsMeta,
        labels.isAcceptableOrUnknown(data['labels']!, _labelsMeta),
      );
    } else if (isInserting) {
      context.missing(_labelsMeta);
    }
    if (data.containsKey('scientific_name')) {
      context.handle(
        _scientificNameMeta,
        scientificName.isAcceptableOrUnknown(
          data['scientific_name']!,
          _scientificNameMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      labels: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}labels'],
      )!,
      scientificName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scientific_name'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
    );
  }

  @override
  $PlantsTable createAlias(String alias) {
    return $PlantsTable(attachedDatabase, alias);
  }
}

class Plant extends DataClass implements Insertable<Plant> {
  final String id;
  final String labels;
  final String? scientificName;
  final String category;
  final String? icon;
  const Plant({
    required this.id,
    required this.labels,
    this.scientificName,
    required this.category,
    this.icon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['labels'] = Variable<String>(labels);
    if (!nullToAbsent || scientificName != null) {
      map['scientific_name'] = Variable<String>(scientificName);
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    return map;
  }

  PlantsCompanion toCompanion(bool nullToAbsent) {
    return PlantsCompanion(
      id: Value(id),
      labels: Value(labels),
      scientificName: scientificName == null && nullToAbsent
          ? const Value.absent()
          : Value(scientificName),
      category: Value(category),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
    );
  }

  factory Plant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plant(
      id: serializer.fromJson<String>(json['id']),
      labels: serializer.fromJson<String>(json['labels']),
      scientificName: serializer.fromJson<String?>(json['scientificName']),
      category: serializer.fromJson<String>(json['category']),
      icon: serializer.fromJson<String?>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'labels': serializer.toJson<String>(labels),
      'scientificName': serializer.toJson<String?>(scientificName),
      'category': serializer.toJson<String>(category),
      'icon': serializer.toJson<String?>(icon),
    };
  }

  Plant copyWith({
    String? id,
    String? labels,
    Value<String?> scientificName = const Value.absent(),
    String? category,
    Value<String?> icon = const Value.absent(),
  }) => Plant(
    id: id ?? this.id,
    labels: labels ?? this.labels,
    scientificName: scientificName.present
        ? scientificName.value
        : this.scientificName,
    category: category ?? this.category,
    icon: icon.present ? icon.value : this.icon,
  );
  Plant copyWithCompanion(PlantsCompanion data) {
    return Plant(
      id: data.id.present ? data.id.value : this.id,
      labels: data.labels.present ? data.labels.value : this.labels,
      scientificName: data.scientificName.present
          ? data.scientificName.value
          : this.scientificName,
      category: data.category.present ? data.category.value : this.category,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plant(')
          ..write('id: $id, ')
          ..write('labels: $labels, ')
          ..write('scientificName: $scientificName, ')
          ..write('category: $category, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, labels, scientificName, category, icon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plant &&
          other.id == this.id &&
          other.labels == this.labels &&
          other.scientificName == this.scientificName &&
          other.category == this.category &&
          other.icon == this.icon);
}

class PlantsCompanion extends UpdateCompanion<Plant> {
  final Value<String> id;
  final Value<String> labels;
  final Value<String?> scientificName;
  final Value<String> category;
  final Value<String?> icon;
  final Value<int> rowid;
  const PlantsCompanion({
    this.id = const Value.absent(),
    this.labels = const Value.absent(),
    this.scientificName = const Value.absent(),
    this.category = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlantsCompanion.insert({
    required String id,
    required String labels,
    this.scientificName = const Value.absent(),
    required String category,
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       labels = Value(labels),
       category = Value(category);
  static Insertable<Plant> custom({
    Expression<String>? id,
    Expression<String>? labels,
    Expression<String>? scientificName,
    Expression<String>? category,
    Expression<String>? icon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (labels != null) 'labels': labels,
      if (scientificName != null) 'scientific_name': scientificName,
      if (category != null) 'category': category,
      if (icon != null) 'icon': icon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlantsCompanion copyWith({
    Value<String>? id,
    Value<String>? labels,
    Value<String?>? scientificName,
    Value<String>? category,
    Value<String?>? icon,
    Value<int>? rowid,
  }) {
    return PlantsCompanion(
      id: id ?? this.id,
      labels: labels ?? this.labels,
      scientificName: scientificName ?? this.scientificName,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (labels.present) {
      map['labels'] = Variable<String>(labels.value);
    }
    if (scientificName.present) {
      map['scientific_name'] = Variable<String>(scientificName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantsCompanion(')
          ..write('id: $id, ')
          ..write('labels: $labels, ')
          ..write('scientificName: $scientificName, ')
          ..write('category: $category, ')
          ..write('icon: $icon, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlantSynonymsTable extends PlantSynonyms
    with TableInfo<$PlantSynonymsTable, PlantSynonym> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlantSynonymsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _plantIdMeta = const VerificationMeta(
    'plantId',
  );
  @override
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
    'plant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plant (id)',
    ),
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textNormMeta = const VerificationMeta(
    'textNorm',
  );
  @override
  late final GeneratedColumn<String> textNorm = GeneratedColumn<String>(
    'text_norm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, plantId, lang, textNorm];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plant_synonym';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlantSynonym> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plant_id')) {
      context.handle(
        _plantIdMeta,
        plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plantIdMeta);
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    } else if (isInserting) {
      context.missing(_langMeta);
    }
    if (data.containsKey('text_norm')) {
      context.handle(
        _textNormMeta,
        textNorm.isAcceptableOrUnknown(data['text_norm']!, _textNormMeta),
      );
    } else if (isInserting) {
      context.missing(_textNormMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlantSynonym map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlantSynonym(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      plantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plant_id'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      )!,
      textNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_norm'],
      )!,
    );
  }

  @override
  $PlantSynonymsTable createAlias(String alias) {
    return $PlantSynonymsTable(attachedDatabase, alias);
  }
}

class PlantSynonym extends DataClass implements Insertable<PlantSynonym> {
  final int id;
  final String plantId;
  final String lang;
  final String textNorm;
  const PlantSynonym({
    required this.id,
    required this.plantId,
    required this.lang,
    required this.textNorm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plant_id'] = Variable<String>(plantId);
    map['lang'] = Variable<String>(lang);
    map['text_norm'] = Variable<String>(textNorm);
    return map;
  }

  PlantSynonymsCompanion toCompanion(bool nullToAbsent) {
    return PlantSynonymsCompanion(
      id: Value(id),
      plantId: Value(plantId),
      lang: Value(lang),
      textNorm: Value(textNorm),
    );
  }

  factory PlantSynonym.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlantSynonym(
      id: serializer.fromJson<int>(json['id']),
      plantId: serializer.fromJson<String>(json['plantId']),
      lang: serializer.fromJson<String>(json['lang']),
      textNorm: serializer.fromJson<String>(json['textNorm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'plantId': serializer.toJson<String>(plantId),
      'lang': serializer.toJson<String>(lang),
      'textNorm': serializer.toJson<String>(textNorm),
    };
  }

  PlantSynonym copyWith({
    int? id,
    String? plantId,
    String? lang,
    String? textNorm,
  }) => PlantSynonym(
    id: id ?? this.id,
    plantId: plantId ?? this.plantId,
    lang: lang ?? this.lang,
    textNorm: textNorm ?? this.textNorm,
  );
  PlantSynonym copyWithCompanion(PlantSynonymsCompanion data) {
    return PlantSynonym(
      id: data.id.present ? data.id.value : this.id,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      lang: data.lang.present ? data.lang.value : this.lang,
      textNorm: data.textNorm.present ? data.textNorm.value : this.textNorm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlantSynonym(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('lang: $lang, ')
          ..write('textNorm: $textNorm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, plantId, lang, textNorm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlantSynonym &&
          other.id == this.id &&
          other.plantId == this.plantId &&
          other.lang == this.lang &&
          other.textNorm == this.textNorm);
}

class PlantSynonymsCompanion extends UpdateCompanion<PlantSynonym> {
  final Value<int> id;
  final Value<String> plantId;
  final Value<String> lang;
  final Value<String> textNorm;
  const PlantSynonymsCompanion({
    this.id = const Value.absent(),
    this.plantId = const Value.absent(),
    this.lang = const Value.absent(),
    this.textNorm = const Value.absent(),
  });
  PlantSynonymsCompanion.insert({
    this.id = const Value.absent(),
    required String plantId,
    required String lang,
    required String textNorm,
  }) : plantId = Value(plantId),
       lang = Value(lang),
       textNorm = Value(textNorm);
  static Insertable<PlantSynonym> custom({
    Expression<int>? id,
    Expression<String>? plantId,
    Expression<String>? lang,
    Expression<String>? textNorm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plantId != null) 'plant_id': plantId,
      if (lang != null) 'lang': lang,
      if (textNorm != null) 'text_norm': textNorm,
    });
  }

  PlantSynonymsCompanion copyWith({
    Value<int>? id,
    Value<String>? plantId,
    Value<String>? lang,
    Value<String>? textNorm,
  }) {
    return PlantSynonymsCompanion(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      lang: lang ?? this.lang,
      textNorm: textNorm ?? this.textNorm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (textNorm.present) {
      map['text_norm'] = Variable<String>(textNorm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantSynonymsCompanion(')
          ..write('id: $id, ')
          ..write('plantId: $plantId, ')
          ..write('lang: $lang, ')
          ..write('textNorm: $textNorm')
          ..write(')'))
        .toString();
  }
}

class $CategoryTaskTypesTable extends CategoryTaskTypes
    with TableInfo<$CategoryTaskTypesTable, CategoryTaskType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryTaskTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskTypeIdMeta = const VerificationMeta(
    'taskTypeId',
  );
  @override
  late final GeneratedColumn<String> taskTypeId = GeneratedColumn<String>(
    'task_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES task_type (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [category, taskTypeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_task_type';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryTaskType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('task_type_id')) {
      context.handle(
        _taskTypeIdMeta,
        taskTypeId.isAcceptableOrUnknown(
          data['task_type_id']!,
          _taskTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_taskTypeIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {category, taskTypeId};
  @override
  CategoryTaskType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryTaskType(
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      taskTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_type_id'],
      )!,
    );
  }

  @override
  $CategoryTaskTypesTable createAlias(String alias) {
    return $CategoryTaskTypesTable(attachedDatabase, alias);
  }
}

class CategoryTaskType extends DataClass
    implements Insertable<CategoryTaskType> {
  final String category;
  final String taskTypeId;
  const CategoryTaskType({required this.category, required this.taskTypeId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category'] = Variable<String>(category);
    map['task_type_id'] = Variable<String>(taskTypeId);
    return map;
  }

  CategoryTaskTypesCompanion toCompanion(bool nullToAbsent) {
    return CategoryTaskTypesCompanion(
      category: Value(category),
      taskTypeId: Value(taskTypeId),
    );
  }

  factory CategoryTaskType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryTaskType(
      category: serializer.fromJson<String>(json['category']),
      taskTypeId: serializer.fromJson<String>(json['taskTypeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'category': serializer.toJson<String>(category),
      'taskTypeId': serializer.toJson<String>(taskTypeId),
    };
  }

  CategoryTaskType copyWith({String? category, String? taskTypeId}) =>
      CategoryTaskType(
        category: category ?? this.category,
        taskTypeId: taskTypeId ?? this.taskTypeId,
      );
  CategoryTaskType copyWithCompanion(CategoryTaskTypesCompanion data) {
    return CategoryTaskType(
      category: data.category.present ? data.category.value : this.category,
      taskTypeId: data.taskTypeId.present
          ? data.taskTypeId.value
          : this.taskTypeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryTaskType(')
          ..write('category: $category, ')
          ..write('taskTypeId: $taskTypeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(category, taskTypeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryTaskType &&
          other.category == this.category &&
          other.taskTypeId == this.taskTypeId);
}

class CategoryTaskTypesCompanion extends UpdateCompanion<CategoryTaskType> {
  final Value<String> category;
  final Value<String> taskTypeId;
  final Value<int> rowid;
  const CategoryTaskTypesCompanion({
    this.category = const Value.absent(),
    this.taskTypeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryTaskTypesCompanion.insert({
    required String category,
    required String taskTypeId,
    this.rowid = const Value.absent(),
  }) : category = Value(category),
       taskTypeId = Value(taskTypeId);
  static Insertable<CategoryTaskType> custom({
    Expression<String>? category,
    Expression<String>? taskTypeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (category != null) 'category': category,
      if (taskTypeId != null) 'task_type_id': taskTypeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryTaskTypesCompanion copyWith({
    Value<String>? category,
    Value<String>? taskTypeId,
    Value<int>? rowid,
  }) {
    return CategoryTaskTypesCompanion(
      category: category ?? this.category,
      taskTypeId: taskTypeId ?? this.taskTypeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (taskTypeId.present) {
      map['task_type_id'] = Variable<String>(taskTypeId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryTaskTypesCompanion(')
          ..write('category: $category, ')
          ..write('taskTypeId: $taskTypeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TaskTypesTable taskTypes = $TaskTypesTable(this);
  late final $PlantsTable plants = $PlantsTable(this);
  late final $PlantSynonymsTable plantSynonyms = $PlantSynonymsTable(this);
  late final $CategoryTaskTypesTable categoryTaskTypes =
      $CategoryTaskTypesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    taskTypes,
    plants,
    plantSynonyms,
    categoryTaskTypes,
  ];
}

typedef $$TaskTypesTableCreateCompanionBuilder =
    TaskTypesCompanion Function({
      required String id,
      required String labels,
      required String icon,
      required String category,
      Value<bool> requiresSubject,
      Value<bool> weatherSensitive,
      Value<int?> defaultCadence,
      Value<int> rowid,
    });
typedef $$TaskTypesTableUpdateCompanionBuilder =
    TaskTypesCompanion Function({
      Value<String> id,
      Value<String> labels,
      Value<String> icon,
      Value<String> category,
      Value<bool> requiresSubject,
      Value<bool> weatherSensitive,
      Value<int?> defaultCadence,
      Value<int> rowid,
    });

final class $$TaskTypesTableReferences
    extends BaseReferences<_$AppDatabase, $TaskTypesTable, TaskType> {
  $$TaskTypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CategoryTaskTypesTable, List<CategoryTaskType>>
  _categoryTaskTypesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.categoryTaskTypes,
        aliasName: $_aliasNameGenerator(
          db.taskTypes.id,
          db.categoryTaskTypes.taskTypeId,
        ),
      );

  $$CategoryTaskTypesTableProcessedTableManager get categoryTaskTypesRefs {
    final manager = $$CategoryTaskTypesTableTableManager(
      $_db,
      $_db.categoryTaskTypes,
    ).filter((f) => f.taskTypeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _categoryTaskTypesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TaskTypesTableFilterComposer
    extends Composer<_$AppDatabase, $TaskTypesTable> {
  $$TaskTypesTableFilterComposer({
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

  ColumnFilters<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requiresSubject => $composableBuilder(
    column: $table.requiresSubject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get weatherSensitive => $composableBuilder(
    column: $table.weatherSensitive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultCadence => $composableBuilder(
    column: $table.defaultCadence,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> categoryTaskTypesRefs(
    Expression<bool> Function($$CategoryTaskTypesTableFilterComposer f) f,
  ) {
    final $$CategoryTaskTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categoryTaskTypes,
      getReferencedColumn: (t) => t.taskTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryTaskTypesTableFilterComposer(
            $db: $db,
            $table: $db.categoryTaskTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TaskTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskTypesTable> {
  $$TaskTypesTableOrderingComposer({
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

  ColumnOrderings<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requiresSubject => $composableBuilder(
    column: $table.requiresSubject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get weatherSensitive => $composableBuilder(
    column: $table.weatherSensitive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultCadence => $composableBuilder(
    column: $table.defaultCadence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskTypesTable> {
  $$TaskTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get requiresSubject => $composableBuilder(
    column: $table.requiresSubject,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get weatherSensitive => $composableBuilder(
    column: $table.weatherSensitive,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultCadence => $composableBuilder(
    column: $table.defaultCadence,
    builder: (column) => column,
  );

  Expression<T> categoryTaskTypesRefs<T extends Object>(
    Expression<T> Function($$CategoryTaskTypesTableAnnotationComposer a) f,
  ) {
    final $$CategoryTaskTypesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.categoryTaskTypes,
          getReferencedColumn: (t) => t.taskTypeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CategoryTaskTypesTableAnnotationComposer(
                $db: $db,
                $table: $db.categoryTaskTypes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TaskTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskTypesTable,
          TaskType,
          $$TaskTypesTableFilterComposer,
          $$TaskTypesTableOrderingComposer,
          $$TaskTypesTableAnnotationComposer,
          $$TaskTypesTableCreateCompanionBuilder,
          $$TaskTypesTableUpdateCompanionBuilder,
          (TaskType, $$TaskTypesTableReferences),
          TaskType,
          PrefetchHooks Function({bool categoryTaskTypesRefs})
        > {
  $$TaskTypesTableTableManager(_$AppDatabase db, $TaskTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> labels = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> requiresSubject = const Value.absent(),
                Value<bool> weatherSensitive = const Value.absent(),
                Value<int?> defaultCadence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskTypesCompanion(
                id: id,
                labels: labels,
                icon: icon,
                category: category,
                requiresSubject: requiresSubject,
                weatherSensitive: weatherSensitive,
                defaultCadence: defaultCadence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String labels,
                required String icon,
                required String category,
                Value<bool> requiresSubject = const Value.absent(),
                Value<bool> weatherSensitive = const Value.absent(),
                Value<int?> defaultCadence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskTypesCompanion.insert(
                id: id,
                labels: labels,
                icon: icon,
                category: category,
                requiresSubject: requiresSubject,
                weatherSensitive: weatherSensitive,
                defaultCadence: defaultCadence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TaskTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryTaskTypesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (categoryTaskTypesRefs) db.categoryTaskTypes,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (categoryTaskTypesRefs)
                    await $_getPrefetchedData<
                      TaskType,
                      $TaskTypesTable,
                      CategoryTaskType
                    >(
                      currentTable: table,
                      referencedTable: $$TaskTypesTableReferences
                          ._categoryTaskTypesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TaskTypesTableReferences(
                            db,
                            table,
                            p0,
                          ).categoryTaskTypesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.taskTypeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TaskTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskTypesTable,
      TaskType,
      $$TaskTypesTableFilterComposer,
      $$TaskTypesTableOrderingComposer,
      $$TaskTypesTableAnnotationComposer,
      $$TaskTypesTableCreateCompanionBuilder,
      $$TaskTypesTableUpdateCompanionBuilder,
      (TaskType, $$TaskTypesTableReferences),
      TaskType,
      PrefetchHooks Function({bool categoryTaskTypesRefs})
    >;
typedef $$PlantsTableCreateCompanionBuilder =
    PlantsCompanion Function({
      required String id,
      required String labels,
      Value<String?> scientificName,
      required String category,
      Value<String?> icon,
      Value<int> rowid,
    });
typedef $$PlantsTableUpdateCompanionBuilder =
    PlantsCompanion Function({
      Value<String> id,
      Value<String> labels,
      Value<String?> scientificName,
      Value<String> category,
      Value<String?> icon,
      Value<int> rowid,
    });

final class $$PlantsTableReferences
    extends BaseReferences<_$AppDatabase, $PlantsTable, Plant> {
  $$PlantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlantSynonymsTable, List<PlantSynonym>>
  _plantSynonymsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.plantSynonyms,
    aliasName: $_aliasNameGenerator(db.plants.id, db.plantSynonyms.plantId),
  );

  $$PlantSynonymsTableProcessedTableManager get plantSynonymsRefs {
    final manager = $$PlantSynonymsTableTableManager(
      $_db,
      $_db.plantSynonyms,
    ).filter((f) => f.plantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_plantSynonymsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlantsTableFilterComposer
    extends Composer<_$AppDatabase, $PlantsTable> {
  $$PlantsTableFilterComposer({
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

  ColumnFilters<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> plantSynonymsRefs(
    Expression<bool> Function($$PlantSynonymsTableFilterComposer f) f,
  ) {
    final $$PlantSynonymsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plantSynonyms,
      getReferencedColumn: (t) => t.plantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantSynonymsTableFilterComposer(
            $db: $db,
            $table: $db.plantSynonyms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlantsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlantsTable> {
  $$PlantsTableOrderingComposer({
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

  ColumnOrderings<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlantsTable> {
  $$PlantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => column);

  GeneratedColumn<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  Expression<T> plantSynonymsRefs<T extends Object>(
    Expression<T> Function($$PlantSynonymsTableAnnotationComposer a) f,
  ) {
    final $$PlantSynonymsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plantSynonyms,
      getReferencedColumn: (t) => t.plantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantSynonymsTableAnnotationComposer(
            $db: $db,
            $table: $db.plantSynonyms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlantsTable,
          Plant,
          $$PlantsTableFilterComposer,
          $$PlantsTableOrderingComposer,
          $$PlantsTableAnnotationComposer,
          $$PlantsTableCreateCompanionBuilder,
          $$PlantsTableUpdateCompanionBuilder,
          (Plant, $$PlantsTableReferences),
          Plant,
          PrefetchHooks Function({bool plantSynonymsRefs})
        > {
  $$PlantsTableTableManager(_$AppDatabase db, $PlantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> labels = const Value.absent(),
                Value<String?> scientificName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantsCompanion(
                id: id,
                labels: labels,
                scientificName: scientificName,
                category: category,
                icon: icon,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String labels,
                Value<String?> scientificName = const Value.absent(),
                required String category,
                Value<String?> icon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantsCompanion.insert(
                id: id,
                labels: labels,
                scientificName: scientificName,
                category: category,
                icon: icon,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PlantsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({plantSynonymsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (plantSynonymsRefs) db.plantSynonyms,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (plantSynonymsRefs)
                    await $_getPrefetchedData<
                      Plant,
                      $PlantsTable,
                      PlantSynonym
                    >(
                      currentTable: table,
                      referencedTable: $$PlantsTableReferences
                          ._plantSynonymsRefsTable(db),
                      managerFromTypedResult: (p0) => $$PlantsTableReferences(
                        db,
                        table,
                        p0,
                      ).plantSynonymsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.plantId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlantsTable,
      Plant,
      $$PlantsTableFilterComposer,
      $$PlantsTableOrderingComposer,
      $$PlantsTableAnnotationComposer,
      $$PlantsTableCreateCompanionBuilder,
      $$PlantsTableUpdateCompanionBuilder,
      (Plant, $$PlantsTableReferences),
      Plant,
      PrefetchHooks Function({bool plantSynonymsRefs})
    >;
typedef $$PlantSynonymsTableCreateCompanionBuilder =
    PlantSynonymsCompanion Function({
      Value<int> id,
      required String plantId,
      required String lang,
      required String textNorm,
    });
typedef $$PlantSynonymsTableUpdateCompanionBuilder =
    PlantSynonymsCompanion Function({
      Value<int> id,
      Value<String> plantId,
      Value<String> lang,
      Value<String> textNorm,
    });

final class $$PlantSynonymsTableReferences
    extends BaseReferences<_$AppDatabase, $PlantSynonymsTable, PlantSynonym> {
  $$PlantSynonymsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlantsTable _plantIdTable(_$AppDatabase db) => db.plants.createAlias(
    $_aliasNameGenerator(db.plantSynonyms.plantId, db.plants.id),
  );

  $$PlantsTableProcessedTableManager get plantId {
    final $_column = $_itemColumn<String>('plant_id')!;

    final manager = $$PlantsTableTableManager(
      $_db,
      $_db.plants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_plantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlantSynonymsTableFilterComposer
    extends Composer<_$AppDatabase, $PlantSynonymsTable> {
  $$PlantSynonymsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textNorm => $composableBuilder(
    column: $table.textNorm,
    builder: (column) => ColumnFilters(column),
  );

  $$PlantsTableFilterComposer get plantId {
    final $$PlantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plantId,
      referencedTable: $db.plants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantsTableFilterComposer(
            $db: $db,
            $table: $db.plants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlantSynonymsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlantSynonymsTable> {
  $$PlantSynonymsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textNorm => $composableBuilder(
    column: $table.textNorm,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlantsTableOrderingComposer get plantId {
    final $$PlantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plantId,
      referencedTable: $db.plants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantsTableOrderingComposer(
            $db: $db,
            $table: $db.plants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlantSynonymsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlantSynonymsTable> {
  $$PlantSynonymsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get textNorm =>
      $composableBuilder(column: $table.textNorm, builder: (column) => column);

  $$PlantsTableAnnotationComposer get plantId {
    final $$PlantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plantId,
      referencedTable: $db.plants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlantsTableAnnotationComposer(
            $db: $db,
            $table: $db.plants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlantSynonymsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlantSynonymsTable,
          PlantSynonym,
          $$PlantSynonymsTableFilterComposer,
          $$PlantSynonymsTableOrderingComposer,
          $$PlantSynonymsTableAnnotationComposer,
          $$PlantSynonymsTableCreateCompanionBuilder,
          $$PlantSynonymsTableUpdateCompanionBuilder,
          (PlantSynonym, $$PlantSynonymsTableReferences),
          PlantSynonym,
          PrefetchHooks Function({bool plantId})
        > {
  $$PlantSynonymsTableTableManager(_$AppDatabase db, $PlantSynonymsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlantSynonymsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlantSynonymsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlantSynonymsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> plantId = const Value.absent(),
                Value<String> lang = const Value.absent(),
                Value<String> textNorm = const Value.absent(),
              }) => PlantSynonymsCompanion(
                id: id,
                plantId: plantId,
                lang: lang,
                textNorm: textNorm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String plantId,
                required String lang,
                required String textNorm,
              }) => PlantSynonymsCompanion.insert(
                id: id,
                plantId: plantId,
                lang: lang,
                textNorm: textNorm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlantSynonymsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({plantId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (plantId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.plantId,
                                referencedTable: $$PlantSynonymsTableReferences
                                    ._plantIdTable(db),
                                referencedColumn: $$PlantSynonymsTableReferences
                                    ._plantIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlantSynonymsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlantSynonymsTable,
      PlantSynonym,
      $$PlantSynonymsTableFilterComposer,
      $$PlantSynonymsTableOrderingComposer,
      $$PlantSynonymsTableAnnotationComposer,
      $$PlantSynonymsTableCreateCompanionBuilder,
      $$PlantSynonymsTableUpdateCompanionBuilder,
      (PlantSynonym, $$PlantSynonymsTableReferences),
      PlantSynonym,
      PrefetchHooks Function({bool plantId})
    >;
typedef $$CategoryTaskTypesTableCreateCompanionBuilder =
    CategoryTaskTypesCompanion Function({
      required String category,
      required String taskTypeId,
      Value<int> rowid,
    });
typedef $$CategoryTaskTypesTableUpdateCompanionBuilder =
    CategoryTaskTypesCompanion Function({
      Value<String> category,
      Value<String> taskTypeId,
      Value<int> rowid,
    });

final class $$CategoryTaskTypesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CategoryTaskTypesTable,
          CategoryTaskType
        > {
  $$CategoryTaskTypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TaskTypesTable _taskTypeIdTable(_$AppDatabase db) =>
      db.taskTypes.createAlias(
        $_aliasNameGenerator(db.categoryTaskTypes.taskTypeId, db.taskTypes.id),
      );

  $$TaskTypesTableProcessedTableManager get taskTypeId {
    final $_column = $_itemColumn<String>('task_type_id')!;

    final manager = $$TaskTypesTableTableManager(
      $_db,
      $_db.taskTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CategoryTaskTypesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryTaskTypesTable> {
  $$CategoryTaskTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  $$TaskTypesTableFilterComposer get taskTypeId {
    final $$TaskTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskTypeId,
      referencedTable: $db.taskTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskTypesTableFilterComposer(
            $db: $db,
            $table: $db.taskTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryTaskTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryTaskTypesTable> {
  $$CategoryTaskTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  $$TaskTypesTableOrderingComposer get taskTypeId {
    final $$TaskTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskTypeId,
      referencedTable: $db.taskTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskTypesTableOrderingComposer(
            $db: $db,
            $table: $db.taskTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryTaskTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryTaskTypesTable> {
  $$CategoryTaskTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  $$TaskTypesTableAnnotationComposer get taskTypeId {
    final $$TaskTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskTypeId,
      referencedTable: $db.taskTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.taskTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryTaskTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryTaskTypesTable,
          CategoryTaskType,
          $$CategoryTaskTypesTableFilterComposer,
          $$CategoryTaskTypesTableOrderingComposer,
          $$CategoryTaskTypesTableAnnotationComposer,
          $$CategoryTaskTypesTableCreateCompanionBuilder,
          $$CategoryTaskTypesTableUpdateCompanionBuilder,
          (CategoryTaskType, $$CategoryTaskTypesTableReferences),
          CategoryTaskType,
          PrefetchHooks Function({bool taskTypeId})
        > {
  $$CategoryTaskTypesTableTableManager(
    _$AppDatabase db,
    $CategoryTaskTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryTaskTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryTaskTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryTaskTypesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> category = const Value.absent(),
                Value<String> taskTypeId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryTaskTypesCompanion(
                category: category,
                taskTypeId: taskTypeId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String category,
                required String taskTypeId,
                Value<int> rowid = const Value.absent(),
              }) => CategoryTaskTypesCompanion.insert(
                category: category,
                taskTypeId: taskTypeId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoryTaskTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskTypeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskTypeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskTypeId,
                                referencedTable:
                                    $$CategoryTaskTypesTableReferences
                                        ._taskTypeIdTable(db),
                                referencedColumn:
                                    $$CategoryTaskTypesTableReferences
                                        ._taskTypeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CategoryTaskTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryTaskTypesTable,
      CategoryTaskType,
      $$CategoryTaskTypesTableFilterComposer,
      $$CategoryTaskTypesTableOrderingComposer,
      $$CategoryTaskTypesTableAnnotationComposer,
      $$CategoryTaskTypesTableCreateCompanionBuilder,
      $$CategoryTaskTypesTableUpdateCompanionBuilder,
      (CategoryTaskType, $$CategoryTaskTypesTableReferences),
      CategoryTaskType,
      PrefetchHooks Function({bool taskTypeId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TaskTypesTableTableManager get taskTypes =>
      $$TaskTypesTableTableManager(_db, _db.taskTypes);
  $$PlantsTableTableManager get plants =>
      $$PlantsTableTableManager(_db, _db.plants);
  $$PlantSynonymsTableTableManager get plantSynonyms =>
      $$PlantSynonymsTableTableManager(_db, _db.plantSynonyms);
  $$CategoryTaskTypesTableTableManager get categoryTaskTypes =>
      $$CategoryTaskTypesTableTableManager(_db, _db.categoryTaskTypes);
}
