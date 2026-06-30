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
  static const VerificationMeta _consumesSuppliesMeta = const VerificationMeta(
    'consumesSupplies',
  );
  @override
  late final GeneratedColumn<bool> consumesSupplies = GeneratedColumn<bool>(
    'consumes_supplies',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("consumes_supplies" IN (0, 1))',
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
    consumesSupplies,
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
    if (data.containsKey('consumes_supplies')) {
      context.handle(
        _consumesSuppliesMeta,
        consumesSupplies.isAcceptableOrUnknown(
          data['consumes_supplies']!,
          _consumesSuppliesMeta,
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
      consumesSupplies: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}consumes_supplies'],
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
  final bool consumesSupplies;
  final int? defaultCadence;
  const TaskType({
    required this.id,
    required this.labels,
    required this.icon,
    required this.category,
    required this.requiresSubject,
    required this.weatherSensitive,
    required this.consumesSupplies,
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
    map['consumes_supplies'] = Variable<bool>(consumesSupplies);
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
      consumesSupplies: Value(consumesSupplies),
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
      consumesSupplies: serializer.fromJson<bool>(json['consumesSupplies']),
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
      'consumesSupplies': serializer.toJson<bool>(consumesSupplies),
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
    bool? consumesSupplies,
    Value<int?> defaultCadence = const Value.absent(),
  }) => TaskType(
    id: id ?? this.id,
    labels: labels ?? this.labels,
    icon: icon ?? this.icon,
    category: category ?? this.category,
    requiresSubject: requiresSubject ?? this.requiresSubject,
    weatherSensitive: weatherSensitive ?? this.weatherSensitive,
    consumesSupplies: consumesSupplies ?? this.consumesSupplies,
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
      consumesSupplies: data.consumesSupplies.present
          ? data.consumesSupplies.value
          : this.consumesSupplies,
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
          ..write('consumesSupplies: $consumesSupplies, ')
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
    consumesSupplies,
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
          other.consumesSupplies == this.consumesSupplies &&
          other.defaultCadence == this.defaultCadence);
}

class TaskTypesCompanion extends UpdateCompanion<TaskType> {
  final Value<String> id;
  final Value<String> labels;
  final Value<String> icon;
  final Value<String> category;
  final Value<bool> requiresSubject;
  final Value<bool> weatherSensitive;
  final Value<bool> consumesSupplies;
  final Value<int?> defaultCadence;
  final Value<int> rowid;
  const TaskTypesCompanion({
    this.id = const Value.absent(),
    this.labels = const Value.absent(),
    this.icon = const Value.absent(),
    this.category = const Value.absent(),
    this.requiresSubject = const Value.absent(),
    this.weatherSensitive = const Value.absent(),
    this.consumesSupplies = const Value.absent(),
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
    this.consumesSupplies = const Value.absent(),
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
    Expression<bool>? consumesSupplies,
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
      if (consumesSupplies != null) 'consumes_supplies': consumesSupplies,
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
    Value<bool>? consumesSupplies,
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
      consumesSupplies: consumesSupplies ?? this.consumesSupplies,
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
    if (consumesSupplies.present) {
      map['consumes_supplies'] = Variable<bool>(consumesSupplies.value);
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
          ..write('consumesSupplies: $consumesSupplies, ')
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

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _h3R7Meta = const VerificationMeta('h3R7');
  @override
  late final GeneratedColumn<String> h3R7 = GeneratedColumn<String>(
    'h3_r7',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _h3R6Meta = const VerificationMeta('h3R6');
  @override
  late final GeneratedColumn<String> h3R6 = GeneratedColumn<String>(
    'h3_r6',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _h3R5Meta = const VerificationMeta('h3R5');
  @override
  late final GeneratedColumn<String> h3R5 = GeneratedColumn<String>(
    'h3_r5',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notificationSettingsMeta =
      const VerificationMeta('notificationSettings');
  @override
  late final GeneratedColumn<String> notificationSettings =
      GeneratedColumn<String>(
        'notification_settings',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _defaultGardenSeededMeta =
      const VerificationMeta('defaultGardenSeeded');
  @override
  late final GeneratedColumn<bool> defaultGardenSeeded = GeneratedColumn<bool>(
    'default_garden_seeded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("default_garden_seeded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(kSyncPending),
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    h3R7,
    h3R6,
    h3R5,
    lang,
    notificationSettings,
    defaultGardenSeeded,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('h3_r7')) {
      context.handle(
        _h3R7Meta,
        h3R7.isAcceptableOrUnknown(data['h3_r7']!, _h3R7Meta),
      );
    }
    if (data.containsKey('h3_r6')) {
      context.handle(
        _h3R6Meta,
        h3R6.isAcceptableOrUnknown(data['h3_r6']!, _h3R6Meta),
      );
    }
    if (data.containsKey('h3_r5')) {
      context.handle(
        _h3R5Meta,
        h3R5.isAcceptableOrUnknown(data['h3_r5']!, _h3R5Meta),
      );
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    }
    if (data.containsKey('notification_settings')) {
      context.handle(
        _notificationSettingsMeta,
        notificationSettings.isAcceptableOrUnknown(
          data['notification_settings']!,
          _notificationSettingsMeta,
        ),
      );
    }
    if (data.containsKey('default_garden_seeded')) {
      context.handle(
        _defaultGardenSeededMeta,
        defaultGardenSeeded.isAcceptableOrUnknown(
          data['default_garden_seeded']!,
          _defaultGardenSeededMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      h3R7: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}h3_r7'],
      ),
      h3R6: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}h3_r6'],
      ),
      h3R5: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}h3_r5'],
      ),
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      ),
      notificationSettings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_settings'],
      ),
      defaultGardenSeeded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}default_garden_seeded'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final String userId;
  final String? h3R7;
  final String? h3R6;
  final String? h3R5;
  final String? lang;
  final String? notificationSettings;
  final bool defaultGardenSeeded;
  final DateTime updatedAt;
  final String syncStatus;
  const Profile({
    required this.userId,
    this.h3R7,
    this.h3R6,
    this.h3R5,
    this.lang,
    this.notificationSettings,
    required this.defaultGardenSeeded,
    required this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || h3R7 != null) {
      map['h3_r7'] = Variable<String>(h3R7);
    }
    if (!nullToAbsent || h3R6 != null) {
      map['h3_r6'] = Variable<String>(h3R6);
    }
    if (!nullToAbsent || h3R5 != null) {
      map['h3_r5'] = Variable<String>(h3R5);
    }
    if (!nullToAbsent || lang != null) {
      map['lang'] = Variable<String>(lang);
    }
    if (!nullToAbsent || notificationSettings != null) {
      map['notification_settings'] = Variable<String>(notificationSettings);
    }
    map['default_garden_seeded'] = Variable<bool>(defaultGardenSeeded);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      userId: Value(userId),
      h3R7: h3R7 == null && nullToAbsent ? const Value.absent() : Value(h3R7),
      h3R6: h3R6 == null && nullToAbsent ? const Value.absent() : Value(h3R6),
      h3R5: h3R5 == null && nullToAbsent ? const Value.absent() : Value(h3R5),
      lang: lang == null && nullToAbsent ? const Value.absent() : Value(lang),
      notificationSettings: notificationSettings == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationSettings),
      defaultGardenSeeded: Value(defaultGardenSeeded),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      userId: serializer.fromJson<String>(json['userId']),
      h3R7: serializer.fromJson<String?>(json['h3R7']),
      h3R6: serializer.fromJson<String?>(json['h3R6']),
      h3R5: serializer.fromJson<String?>(json['h3R5']),
      lang: serializer.fromJson<String?>(json['lang']),
      notificationSettings: serializer.fromJson<String?>(
        json['notificationSettings'],
      ),
      defaultGardenSeeded: serializer.fromJson<bool>(
        json['defaultGardenSeeded'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'h3R7': serializer.toJson<String?>(h3R7),
      'h3R6': serializer.toJson<String?>(h3R6),
      'h3R5': serializer.toJson<String?>(h3R5),
      'lang': serializer.toJson<String?>(lang),
      'notificationSettings': serializer.toJson<String?>(notificationSettings),
      'defaultGardenSeeded': serializer.toJson<bool>(defaultGardenSeeded),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Profile copyWith({
    String? userId,
    Value<String?> h3R7 = const Value.absent(),
    Value<String?> h3R6 = const Value.absent(),
    Value<String?> h3R5 = const Value.absent(),
    Value<String?> lang = const Value.absent(),
    Value<String?> notificationSettings = const Value.absent(),
    bool? defaultGardenSeeded,
    DateTime? updatedAt,
    String? syncStatus,
  }) => Profile(
    userId: userId ?? this.userId,
    h3R7: h3R7.present ? h3R7.value : this.h3R7,
    h3R6: h3R6.present ? h3R6.value : this.h3R6,
    h3R5: h3R5.present ? h3R5.value : this.h3R5,
    lang: lang.present ? lang.value : this.lang,
    notificationSettings: notificationSettings.present
        ? notificationSettings.value
        : this.notificationSettings,
    defaultGardenSeeded: defaultGardenSeeded ?? this.defaultGardenSeeded,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      userId: data.userId.present ? data.userId.value : this.userId,
      h3R7: data.h3R7.present ? data.h3R7.value : this.h3R7,
      h3R6: data.h3R6.present ? data.h3R6.value : this.h3R6,
      h3R5: data.h3R5.present ? data.h3R5.value : this.h3R5,
      lang: data.lang.present ? data.lang.value : this.lang,
      notificationSettings: data.notificationSettings.present
          ? data.notificationSettings.value
          : this.notificationSettings,
      defaultGardenSeeded: data.defaultGardenSeeded.present
          ? data.defaultGardenSeeded.value
          : this.defaultGardenSeeded,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('userId: $userId, ')
          ..write('h3R7: $h3R7, ')
          ..write('h3R6: $h3R6, ')
          ..write('h3R5: $h3R5, ')
          ..write('lang: $lang, ')
          ..write('notificationSettings: $notificationSettings, ')
          ..write('defaultGardenSeeded: $defaultGardenSeeded, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    h3R7,
    h3R6,
    h3R5,
    lang,
    notificationSettings,
    defaultGardenSeeded,
    updatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.userId == this.userId &&
          other.h3R7 == this.h3R7 &&
          other.h3R6 == this.h3R6 &&
          other.h3R5 == this.h3R5 &&
          other.lang == this.lang &&
          other.notificationSettings == this.notificationSettings &&
          other.defaultGardenSeeded == this.defaultGardenSeeded &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> userId;
  final Value<String?> h3R7;
  final Value<String?> h3R6;
  final Value<String?> h3R5;
  final Value<String?> lang;
  final Value<String?> notificationSettings;
  final Value<bool> defaultGardenSeeded;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.userId = const Value.absent(),
    this.h3R7 = const Value.absent(),
    this.h3R6 = const Value.absent(),
    this.h3R5 = const Value.absent(),
    this.lang = const Value.absent(),
    this.notificationSettings = const Value.absent(),
    this.defaultGardenSeeded = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String userId,
    this.h3R7 = const Value.absent(),
    this.h3R6 = const Value.absent(),
    this.h3R5 = const Value.absent(),
    this.lang = const Value.absent(),
    this.notificationSettings = const Value.absent(),
    this.defaultGardenSeeded = const Value.absent(),
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       updatedAt = Value(updatedAt);
  static Insertable<Profile> custom({
    Expression<String>? userId,
    Expression<String>? h3R7,
    Expression<String>? h3R6,
    Expression<String>? h3R5,
    Expression<String>? lang,
    Expression<String>? notificationSettings,
    Expression<bool>? defaultGardenSeeded,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (h3R7 != null) 'h3_r7': h3R7,
      if (h3R6 != null) 'h3_r6': h3R6,
      if (h3R5 != null) 'h3_r5': h3R5,
      if (lang != null) 'lang': lang,
      if (notificationSettings != null)
        'notification_settings': notificationSettings,
      if (defaultGardenSeeded != null)
        'default_garden_seeded': defaultGardenSeeded,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? userId,
    Value<String?>? h3R7,
    Value<String?>? h3R6,
    Value<String?>? h3R5,
    Value<String?>? lang,
    Value<String?>? notificationSettings,
    Value<bool>? defaultGardenSeeded,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      userId: userId ?? this.userId,
      h3R7: h3R7 ?? this.h3R7,
      h3R6: h3R6 ?? this.h3R6,
      h3R5: h3R5 ?? this.h3R5,
      lang: lang ?? this.lang,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      defaultGardenSeeded: defaultGardenSeeded ?? this.defaultGardenSeeded,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (h3R7.present) {
      map['h3_r7'] = Variable<String>(h3R7.value);
    }
    if (h3R6.present) {
      map['h3_r6'] = Variable<String>(h3R6.value);
    }
    if (h3R5.present) {
      map['h3_r5'] = Variable<String>(h3R5.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (notificationSettings.present) {
      map['notification_settings'] = Variable<String>(
        notificationSettings.value,
      );
    }
    if (defaultGardenSeeded.present) {
      map['default_garden_seeded'] = Variable<bool>(defaultGardenSeeded.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('h3R7: $h3R7, ')
          ..write('h3R6: $h3R6, ')
          ..write('h3R5: $h3R5, ')
          ..write('lang: $lang, ')
          ..write('notificationSettings: $notificationSettings, ')
          ..write('defaultGardenSeeded: $defaultGardenSeeded, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AreasTable extends Areas with TableInfo<$AreasTable, Area> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AreasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AreaType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('other'),
      ).withConverter<AreaType>($AreasTable.$convertertype);
  static const VerificationMeta _protectedMeta = const VerificationMeta(
    'protected',
  );
  @override
  late final GeneratedColumn<bool> protected = GeneratedColumn<bool>(
    'protected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("protected" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(kSyncPending),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    type,
    protected,
    updatedAt,
    deleted,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'area';
  @override
  VerificationContext validateIntegrity(
    Insertable<Area> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('protected')) {
      context.handle(
        _protectedMeta,
        protected.isAcceptableOrUnknown(data['protected']!, _protectedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Area map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Area(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $AreasTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      protected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}protected'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $AreasTable createAlias(String alias) {
    return $AreasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AreaType, String, String> $convertertype =
      const EnumNameConverter<AreaType>(AreaType.values);
}

class Area extends DataClass implements Insertable<Area> {
  final String id;
  final String userId;
  final String name;
  final AreaType type;
  final bool protected;
  final DateTime updatedAt;
  final bool deleted;
  final String syncStatus;
  const Area({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.protected,
    required this.updatedAt,
    required this.deleted,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>($AreasTable.$convertertype.toSql(type));
    }
    map['protected'] = Variable<bool>(protected);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  AreasCompanion toCompanion(bool nullToAbsent) {
    return AreasCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      type: Value(type),
      protected: Value(protected),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      syncStatus: Value(syncStatus),
    );
  }

  factory Area.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Area(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      type: $AreasTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      protected: serializer.fromJson<bool>(json['protected']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
        $AreasTable.$convertertype.toJson(type),
      ),
      'protected': serializer.toJson<bool>(protected),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Area copyWith({
    String? id,
    String? userId,
    String? name,
    AreaType? type,
    bool? protected,
    DateTime? updatedAt,
    bool? deleted,
    String? syncStatus,
  }) => Area(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    type: type ?? this.type,
    protected: protected ?? this.protected,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Area copyWithCompanion(AreasCompanion data) {
    return Area(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      protected: data.protected.present ? data.protected.value : this.protected,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Area(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('protected: $protected, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    type,
    protected,
    updatedAt,
    deleted,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Area &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.type == this.type &&
          other.protected == this.protected &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.syncStatus == this.syncStatus);
}

class AreasCompanion extends UpdateCompanion<Area> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<AreaType> type;
  final Value<bool> protected;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const AreasCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.protected = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AreasCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.type = const Value.absent(),
    this.protected = const Value.absent(),
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<Area> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<bool>? protected,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (protected != null) 'protected': protected,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AreasCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<AreaType>? type,
    Value<bool>? protected,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return AreasCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      protected: protected ?? this.protected,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $AreasTable.$convertertype.toSql(type.value),
      );
    }
    if (protected.present) {
      map['protected'] = Variable<bool>(protected.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AreasCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('protected: $protected, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPlantsTable extends UserPlants
    with TableInfo<$UserPlantsTable, UserPlant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPlantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<String> areaId = GeneratedColumn<String>(
    'area_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES area (id)',
    ),
  );
  static const VerificationMeta _plantIdMeta = const VerificationMeta(
    'plantId',
  );
  @override
  late final GeneratedColumn<String> plantId = GeneratedColumn<String>(
    'plant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plant (id)',
    ),
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personalAliasMeta = const VerificationMeta(
    'personalAlias',
  );
  @override
  late final GeneratedColumn<String> personalAlias = GeneratedColumn<String>(
    'personal_alias',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(kSyncPending),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    areaId,
    plantId,
    customName,
    personalAlias,
    isCustom,
    updatedAt,
    deleted,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_plant';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPlant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('area_id')) {
      context.handle(
        _areaIdMeta,
        areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta),
      );
    }
    if (data.containsKey('plant_id')) {
      context.handle(
        _plantIdMeta,
        plantId.isAcceptableOrUnknown(data['plant_id']!, _plantIdMeta),
      );
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    }
    if (data.containsKey('personal_alias')) {
      context.handle(
        _personalAliasMeta,
        personalAlias.isAcceptableOrUnknown(
          data['personal_alias']!,
          _personalAliasMeta,
        ),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserPlant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPlant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      areaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_id'],
      ),
      plantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plant_id'],
      ),
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      ),
      personalAlias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}personal_alias'],
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $UserPlantsTable createAlias(String alias) {
    return $UserPlantsTable(attachedDatabase, alias);
  }
}

class UserPlant extends DataClass implements Insertable<UserPlant> {
  final String id;
  final String userId;
  final String? areaId;
  final String? plantId;
  final String? customName;
  final String? personalAlias;
  final bool isCustom;
  final DateTime updatedAt;
  final bool deleted;
  final String syncStatus;
  const UserPlant({
    required this.id,
    required this.userId,
    this.areaId,
    this.plantId,
    this.customName,
    this.personalAlias,
    required this.isCustom,
    required this.updatedAt,
    required this.deleted,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || areaId != null) {
      map['area_id'] = Variable<String>(areaId);
    }
    if (!nullToAbsent || plantId != null) {
      map['plant_id'] = Variable<String>(plantId);
    }
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    if (!nullToAbsent || personalAlias != null) {
      map['personal_alias'] = Variable<String>(personalAlias);
    }
    map['is_custom'] = Variable<bool>(isCustom);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  UserPlantsCompanion toCompanion(bool nullToAbsent) {
    return UserPlantsCompanion(
      id: Value(id),
      userId: Value(userId),
      areaId: areaId == null && nullToAbsent
          ? const Value.absent()
          : Value(areaId),
      plantId: plantId == null && nullToAbsent
          ? const Value.absent()
          : Value(plantId),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      personalAlias: personalAlias == null && nullToAbsent
          ? const Value.absent()
          : Value(personalAlias),
      isCustom: Value(isCustom),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      syncStatus: Value(syncStatus),
    );
  }

  factory UserPlant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPlant(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      areaId: serializer.fromJson<String?>(json['areaId']),
      plantId: serializer.fromJson<String?>(json['plantId']),
      customName: serializer.fromJson<String?>(json['customName']),
      personalAlias: serializer.fromJson<String?>(json['personalAlias']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'areaId': serializer.toJson<String?>(areaId),
      'plantId': serializer.toJson<String?>(plantId),
      'customName': serializer.toJson<String?>(customName),
      'personalAlias': serializer.toJson<String?>(personalAlias),
      'isCustom': serializer.toJson<bool>(isCustom),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  UserPlant copyWith({
    String? id,
    String? userId,
    Value<String?> areaId = const Value.absent(),
    Value<String?> plantId = const Value.absent(),
    Value<String?> customName = const Value.absent(),
    Value<String?> personalAlias = const Value.absent(),
    bool? isCustom,
    DateTime? updatedAt,
    bool? deleted,
    String? syncStatus,
  }) => UserPlant(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    areaId: areaId.present ? areaId.value : this.areaId,
    plantId: plantId.present ? plantId.value : this.plantId,
    customName: customName.present ? customName.value : this.customName,
    personalAlias: personalAlias.present
        ? personalAlias.value
        : this.personalAlias,
    isCustom: isCustom ?? this.isCustom,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  UserPlant copyWithCompanion(UserPlantsCompanion data) {
    return UserPlant(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
      plantId: data.plantId.present ? data.plantId.value : this.plantId,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      personalAlias: data.personalAlias.present
          ? data.personalAlias.value
          : this.personalAlias,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPlant(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('areaId: $areaId, ')
          ..write('plantId: $plantId, ')
          ..write('customName: $customName, ')
          ..write('personalAlias: $personalAlias, ')
          ..write('isCustom: $isCustom, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    areaId,
    plantId,
    customName,
    personalAlias,
    isCustom,
    updatedAt,
    deleted,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPlant &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.areaId == this.areaId &&
          other.plantId == this.plantId &&
          other.customName == this.customName &&
          other.personalAlias == this.personalAlias &&
          other.isCustom == this.isCustom &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.syncStatus == this.syncStatus);
}

class UserPlantsCompanion extends UpdateCompanion<UserPlant> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> areaId;
  final Value<String?> plantId;
  final Value<String?> customName;
  final Value<String?> personalAlias;
  final Value<bool> isCustom;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const UserPlantsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.areaId = const Value.absent(),
    this.plantId = const Value.absent(),
    this.customName = const Value.absent(),
    this.personalAlias = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPlantsCompanion.insert({
    required String id,
    required String userId,
    this.areaId = const Value.absent(),
    this.plantId = const Value.absent(),
    this.customName = const Value.absent(),
    this.personalAlias = const Value.absent(),
    this.isCustom = const Value.absent(),
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       updatedAt = Value(updatedAt);
  static Insertable<UserPlant> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? areaId,
    Expression<String>? plantId,
    Expression<String>? customName,
    Expression<String>? personalAlias,
    Expression<bool>? isCustom,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (areaId != null) 'area_id': areaId,
      if (plantId != null) 'plant_id': plantId,
      if (customName != null) 'custom_name': customName,
      if (personalAlias != null) 'personal_alias': personalAlias,
      if (isCustom != null) 'is_custom': isCustom,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPlantsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? areaId,
    Value<String?>? plantId,
    Value<String?>? customName,
    Value<String?>? personalAlias,
    Value<bool>? isCustom,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return UserPlantsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      areaId: areaId ?? this.areaId,
      plantId: plantId ?? this.plantId,
      customName: customName ?? this.customName,
      personalAlias: personalAlias ?? this.personalAlias,
      isCustom: isCustom ?? this.isCustom,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<String>(areaId.value);
    }
    if (plantId.present) {
      map['plant_id'] = Variable<String>(plantId.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (personalAlias.present) {
      map['personal_alias'] = Variable<String>(personalAlias.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPlantsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('areaId: $areaId, ')
          ..write('plantId: $plantId, ')
          ..write('customName: $customName, ')
          ..write('personalAlias: $personalAlias, ')
          ..write('isCustom: $isCustom, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TaskStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('waiting'),
      ).withConverter<TaskStatus>($TasksTable.$converterstatus);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherMeta = const VerificationMeta(
    'weather',
  );
  @override
  late final GeneratedColumn<String> weather = GeneratedColumn<String>(
    'weather',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceMeta = const VerificationMeta(
    'recurrence',
  );
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
    'recurrence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(kSyncPending),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    taskTypeId,
    date,
    status,
    note,
    weather,
    recurrence,
    seriesId,
    updatedAt,
    deleted,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
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
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('weather')) {
      context.handle(
        _weatherMeta,
        weather.isAcceptableOrUnknown(data['weather']!, _weatherMeta),
      );
    }
    if (data.containsKey('recurrence')) {
      context.handle(
        _recurrenceMeta,
        recurrence.isAcceptableOrUnknown(data['recurrence']!, _recurrenceMeta),
      );
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      taskTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_type_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      status: $TasksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      weather: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather'],
      ),
      recurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence'],
      ),
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskStatus, String, String> $converterstatus =
      const EnumNameConverter<TaskStatus>(TaskStatus.values);
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String userId;
  final String taskTypeId;
  final DateTime date;
  final TaskStatus status;
  final String? note;
  final String? weather;
  final String? recurrence;
  final String? seriesId;
  final DateTime updatedAt;
  final bool deleted;
  final String syncStatus;
  const Task({
    required this.id,
    required this.userId,
    required this.taskTypeId,
    required this.date,
    required this.status,
    this.note,
    this.weather,
    this.recurrence,
    this.seriesId,
    required this.updatedAt,
    required this.deleted,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['task_type_id'] = Variable<String>(taskTypeId);
    map['date'] = Variable<DateTime>(date);
    {
      map['status'] = Variable<String>(
        $TasksTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || weather != null) {
      map['weather'] = Variable<String>(weather);
    }
    if (!nullToAbsent || recurrence != null) {
      map['recurrence'] = Variable<String>(recurrence);
    }
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<String>(seriesId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      userId: Value(userId),
      taskTypeId: Value(taskTypeId),
      date: Value(date),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      weather: weather == null && nullToAbsent
          ? const Value.absent()
          : Value(weather),
      recurrence: recurrence == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrence),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      syncStatus: Value(syncStatus),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      taskTypeId: serializer.fromJson<String>(json['taskTypeId']),
      date: serializer.fromJson<DateTime>(json['date']),
      status: $TasksTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      note: serializer.fromJson<String?>(json['note']),
      weather: serializer.fromJson<String?>(json['weather']),
      recurrence: serializer.fromJson<String?>(json['recurrence']),
      seriesId: serializer.fromJson<String?>(json['seriesId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'taskTypeId': serializer.toJson<String>(taskTypeId),
      'date': serializer.toJson<DateTime>(date),
      'status': serializer.toJson<String>(
        $TasksTable.$converterstatus.toJson(status),
      ),
      'note': serializer.toJson<String?>(note),
      'weather': serializer.toJson<String?>(weather),
      'recurrence': serializer.toJson<String?>(recurrence),
      'seriesId': serializer.toJson<String?>(seriesId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Task copyWith({
    String? id,
    String? userId,
    String? taskTypeId,
    DateTime? date,
    TaskStatus? status,
    Value<String?> note = const Value.absent(),
    Value<String?> weather = const Value.absent(),
    Value<String?> recurrence = const Value.absent(),
    Value<String?> seriesId = const Value.absent(),
    DateTime? updatedAt,
    bool? deleted,
    String? syncStatus,
  }) => Task(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    taskTypeId: taskTypeId ?? this.taskTypeId,
    date: date ?? this.date,
    status: status ?? this.status,
    note: note.present ? note.value : this.note,
    weather: weather.present ? weather.value : this.weather,
    recurrence: recurrence.present ? recurrence.value : this.recurrence,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      taskTypeId: data.taskTypeId.present
          ? data.taskTypeId.value
          : this.taskTypeId,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      weather: data.weather.present ? data.weather.value : this.weather,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('taskTypeId: $taskTypeId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('weather: $weather, ')
          ..write('recurrence: $recurrence, ')
          ..write('seriesId: $seriesId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    taskTypeId,
    date,
    status,
    note,
    weather,
    recurrence,
    seriesId,
    updatedAt,
    deleted,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.taskTypeId == this.taskTypeId &&
          other.date == this.date &&
          other.status == this.status &&
          other.note == this.note &&
          other.weather == this.weather &&
          other.recurrence == this.recurrence &&
          other.seriesId == this.seriesId &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.syncStatus == this.syncStatus);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> taskTypeId;
  final Value<DateTime> date;
  final Value<TaskStatus> status;
  final Value<String?> note;
  final Value<String?> weather;
  final Value<String?> recurrence;
  final Value<String?> seriesId;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.taskTypeId = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.weather = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String userId,
    required String taskTypeId,
    required DateTime date,
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.weather = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.seriesId = const Value.absent(),
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       taskTypeId = Value(taskTypeId),
       date = Value(date),
       updatedAt = Value(updatedAt);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? taskTypeId,
    Expression<DateTime>? date,
    Expression<String>? status,
    Expression<String>? note,
    Expression<String>? weather,
    Expression<String>? recurrence,
    Expression<String>? seriesId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (taskTypeId != null) 'task_type_id': taskTypeId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (weather != null) 'weather': weather,
      if (recurrence != null) 'recurrence': recurrence,
      if (seriesId != null) 'series_id': seriesId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? taskTypeId,
    Value<DateTime>? date,
    Value<TaskStatus>? status,
    Value<String?>? note,
    Value<String?>? weather,
    Value<String?>? recurrence,
    Value<String?>? seriesId,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskTypeId: taskTypeId ?? this.taskTypeId,
      date: date ?? this.date,
      status: status ?? this.status,
      note: note ?? this.note,
      weather: weather ?? this.weather,
      recurrence: recurrence ?? this.recurrence,
      seriesId: seriesId ?? this.seriesId,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (taskTypeId.present) {
      map['task_type_id'] = Variable<String>(taskTypeId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TasksTable.$converterstatus.toSql(status.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (weather.present) {
      map['weather'] = Variable<String>(weather.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('taskTypeId: $taskTypeId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('weather: $weather, ')
          ..write('recurrence: $recurrence, ')
          ..write('seriesId: $seriesId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskSubjectsTable extends TaskSubjects
    with TableInfo<$TaskSubjectsTable, TaskSubject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskSubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES task (id)',
    ),
  );
  static const VerificationMeta _userPlantIdMeta = const VerificationMeta(
    'userPlantId',
  );
  @override
  late final GeneratedColumn<String> userPlantId = GeneratedColumn<String>(
    'user_plant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_plant (id)',
    ),
  );
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<String> areaId = GeneratedColumn<String>(
    'area_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES area (id)',
    ),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(kSyncPending),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    userPlantId,
    areaId,
    updatedAt,
    deleted,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_subject';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskSubject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('user_plant_id')) {
      context.handle(
        _userPlantIdMeta,
        userPlantId.isAcceptableOrUnknown(
          data['user_plant_id']!,
          _userPlantIdMeta,
        ),
      );
    }
    if (data.containsKey('area_id')) {
      context.handle(
        _areaIdMeta,
        areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskSubject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskSubject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      userPlantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_plant_id'],
      ),
      areaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $TaskSubjectsTable createAlias(String alias) {
    return $TaskSubjectsTable(attachedDatabase, alias);
  }
}

class TaskSubject extends DataClass implements Insertable<TaskSubject> {
  final String id;
  final String taskId;
  final String? userPlantId;
  final String? areaId;
  final DateTime updatedAt;
  final bool deleted;
  final String syncStatus;
  const TaskSubject({
    required this.id,
    required this.taskId,
    this.userPlantId,
    this.areaId,
    required this.updatedAt,
    required this.deleted,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    if (!nullToAbsent || userPlantId != null) {
      map['user_plant_id'] = Variable<String>(userPlantId);
    }
    if (!nullToAbsent || areaId != null) {
      map['area_id'] = Variable<String>(areaId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  TaskSubjectsCompanion toCompanion(bool nullToAbsent) {
    return TaskSubjectsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      userPlantId: userPlantId == null && nullToAbsent
          ? const Value.absent()
          : Value(userPlantId),
      areaId: areaId == null && nullToAbsent
          ? const Value.absent()
          : Value(areaId),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      syncStatus: Value(syncStatus),
    );
  }

  factory TaskSubject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskSubject(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      userPlantId: serializer.fromJson<String?>(json['userPlantId']),
      areaId: serializer.fromJson<String?>(json['areaId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'userPlantId': serializer.toJson<String?>(userPlantId),
      'areaId': serializer.toJson<String?>(areaId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  TaskSubject copyWith({
    String? id,
    String? taskId,
    Value<String?> userPlantId = const Value.absent(),
    Value<String?> areaId = const Value.absent(),
    DateTime? updatedAt,
    bool? deleted,
    String? syncStatus,
  }) => TaskSubject(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    userPlantId: userPlantId.present ? userPlantId.value : this.userPlantId,
    areaId: areaId.present ? areaId.value : this.areaId,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  TaskSubject copyWithCompanion(TaskSubjectsCompanion data) {
    return TaskSubject(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      userPlantId: data.userPlantId.present
          ? data.userPlantId.value
          : this.userPlantId,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskSubject(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('userPlantId: $userPlantId, ')
          ..write('areaId: $areaId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    userPlantId,
    areaId,
    updatedAt,
    deleted,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskSubject &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.userPlantId == this.userPlantId &&
          other.areaId == this.areaId &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.syncStatus == this.syncStatus);
}

class TaskSubjectsCompanion extends UpdateCompanion<TaskSubject> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String?> userPlantId;
  final Value<String?> areaId;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const TaskSubjectsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.userPlantId = const Value.absent(),
    this.areaId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskSubjectsCompanion.insert({
    required String id,
    required String taskId,
    this.userPlantId = const Value.absent(),
    this.areaId = const Value.absent(),
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       updatedAt = Value(updatedAt);
  static Insertable<TaskSubject> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? userPlantId,
    Expression<String>? areaId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (userPlantId != null) 'user_plant_id': userPlantId,
      if (areaId != null) 'area_id': areaId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskSubjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String?>? userPlantId,
    Value<String?>? areaId,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return TaskSubjectsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userPlantId: userPlantId ?? this.userPlantId,
      areaId: areaId ?? this.areaId,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (userPlantId.present) {
      map['user_plant_id'] = Variable<String>(userPlantId.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<String>(areaId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskSubjectsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('userPlantId: $userPlantId, ')
          ..write('areaId: $areaId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskRemindersTable extends TaskReminders
    with TableInfo<$TaskRemindersTable, TaskReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskRemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES task (id)',
    ),
  );
  static const VerificationMeta _offsetMeta = const VerificationMeta('offset');
  @override
  late final GeneratedColumn<int> offset = GeneratedColumn<int>(
    'offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<String> reminderTime = GeneratedColumn<String>(
    'reminder_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(kSyncPending),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    offset,
    reminderTime,
    updatedAt,
    deleted,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_reminder';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskReminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('offset')) {
      context.handle(
        _offsetMeta,
        offset.isAcceptableOrUnknown(data['offset']!, _offsetMeta),
      );
    } else if (isInserting) {
      context.missing(_offsetMeta);
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskReminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      offset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}offset'],
      )!,
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_time'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $TaskRemindersTable createAlias(String alias) {
    return $TaskRemindersTable(attachedDatabase, alias);
  }
}

class TaskReminder extends DataClass implements Insertable<TaskReminder> {
  final String id;
  final String taskId;
  final int offset;
  final String? reminderTime;
  final DateTime updatedAt;
  final bool deleted;
  final String syncStatus;
  const TaskReminder({
    required this.id,
    required this.taskId,
    required this.offset,
    this.reminderTime,
    required this.updatedAt,
    required this.deleted,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['offset'] = Variable<int>(offset);
    if (!nullToAbsent || reminderTime != null) {
      map['reminder_time'] = Variable<String>(reminderTime);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  TaskRemindersCompanion toCompanion(bool nullToAbsent) {
    return TaskRemindersCompanion(
      id: Value(id),
      taskId: Value(taskId),
      offset: Value(offset),
      reminderTime: reminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTime),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      syncStatus: Value(syncStatus),
    );
  }

  factory TaskReminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskReminder(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      offset: serializer.fromJson<int>(json['offset']),
      reminderTime: serializer.fromJson<String?>(json['reminderTime']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'offset': serializer.toJson<int>(offset),
      'reminderTime': serializer.toJson<String?>(reminderTime),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  TaskReminder copyWith({
    String? id,
    String? taskId,
    int? offset,
    Value<String?> reminderTime = const Value.absent(),
    DateTime? updatedAt,
    bool? deleted,
    String? syncStatus,
  }) => TaskReminder(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    offset: offset ?? this.offset,
    reminderTime: reminderTime.present ? reminderTime.value : this.reminderTime,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  TaskReminder copyWithCompanion(TaskRemindersCompanion data) {
    return TaskReminder(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      offset: data.offset.present ? data.offset.value : this.offset,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskReminder(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('offset: $offset, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    offset,
    reminderTime,
    updatedAt,
    deleted,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskReminder &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.offset == this.offset &&
          other.reminderTime == this.reminderTime &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.syncStatus == this.syncStatus);
}

class TaskRemindersCompanion extends UpdateCompanion<TaskReminder> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<int> offset;
  final Value<String?> reminderTime;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const TaskRemindersCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.offset = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskRemindersCompanion.insert({
    required String id,
    required String taskId,
    required int offset,
    this.reminderTime = const Value.absent(),
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       offset = Value(offset),
       updatedAt = Value(updatedAt);
  static Insertable<TaskReminder> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<int>? offset,
    Expression<String>? reminderTime,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (offset != null) 'offset': offset,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskRemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<int>? offset,
    Value<String?>? reminderTime,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return TaskRemindersCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      offset: offset ?? this.offset,
      reminderTime: reminderTime ?? this.reminderTime,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (offset.present) {
      map['offset'] = Variable<int>(offset.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<String>(reminderTime.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskRemindersCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('offset: $offset, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _areaIdMeta = const VerificationMeta('areaId');
  @override
  late final GeneratedColumn<String> areaId = GeneratedColumn<String>(
    'area_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES area (id)',
    ),
  );
  static const VerificationMeta _userPlantIdMeta = const VerificationMeta(
    'userPlantId',
  );
  @override
  late final GeneratedColumn<String> userPlantId = GeneratedColumn<String>(
    'user_plant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_plant (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weatherMeta = const VerificationMeta(
    'weather',
  );
  @override
  late final GeneratedColumn<String> weather = GeneratedColumn<String>(
    'weather',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(kSyncPending),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    areaId,
    userPlantId,
    date,
    content,
    weather,
    updatedAt,
    deleted,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('area_id')) {
      context.handle(
        _areaIdMeta,
        areaId.isAcceptableOrUnknown(data['area_id']!, _areaIdMeta),
      );
    }
    if (data.containsKey('user_plant_id')) {
      context.handle(
        _userPlantIdMeta,
        userPlantId.isAcceptableOrUnknown(
          data['user_plant_id']!,
          _userPlantIdMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['text']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('weather')) {
      context.handle(
        _weatherMeta,
        weather.isAcceptableOrUnknown(data['weather']!, _weatherMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      areaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area_id'],
      ),
      userPlantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_plant_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      weather: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final String id;
  final String userId;
  final String? areaId;
  final String? userPlantId;
  final DateTime date;
  final String content;
  final String? weather;
  final DateTime updatedAt;
  final bool deleted;
  final String syncStatus;
  const Note({
    required this.id,
    required this.userId,
    this.areaId,
    this.userPlantId,
    required this.date,
    required this.content,
    this.weather,
    required this.updatedAt,
    required this.deleted,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || areaId != null) {
      map['area_id'] = Variable<String>(areaId);
    }
    if (!nullToAbsent || userPlantId != null) {
      map['user_plant_id'] = Variable<String>(userPlantId);
    }
    map['date'] = Variable<DateTime>(date);
    map['text'] = Variable<String>(content);
    if (!nullToAbsent || weather != null) {
      map['weather'] = Variable<String>(weather);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      userId: Value(userId),
      areaId: areaId == null && nullToAbsent
          ? const Value.absent()
          : Value(areaId),
      userPlantId: userPlantId == null && nullToAbsent
          ? const Value.absent()
          : Value(userPlantId),
      date: Value(date),
      content: Value(content),
      weather: weather == null && nullToAbsent
          ? const Value.absent()
          : Value(weather),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      syncStatus: Value(syncStatus),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      areaId: serializer.fromJson<String?>(json['areaId']),
      userPlantId: serializer.fromJson<String?>(json['userPlantId']),
      date: serializer.fromJson<DateTime>(json['date']),
      content: serializer.fromJson<String>(json['content']),
      weather: serializer.fromJson<String?>(json['weather']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'areaId': serializer.toJson<String?>(areaId),
      'userPlantId': serializer.toJson<String?>(userPlantId),
      'date': serializer.toJson<DateTime>(date),
      'content': serializer.toJson<String>(content),
      'weather': serializer.toJson<String?>(weather),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Note copyWith({
    String? id,
    String? userId,
    Value<String?> areaId = const Value.absent(),
    Value<String?> userPlantId = const Value.absent(),
    DateTime? date,
    String? content,
    Value<String?> weather = const Value.absent(),
    DateTime? updatedAt,
    bool? deleted,
    String? syncStatus,
  }) => Note(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    areaId: areaId.present ? areaId.value : this.areaId,
    userPlantId: userPlantId.present ? userPlantId.value : this.userPlantId,
    date: date ?? this.date,
    content: content ?? this.content,
    weather: weather.present ? weather.value : this.weather,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      areaId: data.areaId.present ? data.areaId.value : this.areaId,
      userPlantId: data.userPlantId.present
          ? data.userPlantId.value
          : this.userPlantId,
      date: data.date.present ? data.date.value : this.date,
      content: data.content.present ? data.content.value : this.content,
      weather: data.weather.present ? data.weather.value : this.weather,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('areaId: $areaId, ')
          ..write('userPlantId: $userPlantId, ')
          ..write('date: $date, ')
          ..write('content: $content, ')
          ..write('weather: $weather, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    areaId,
    userPlantId,
    date,
    content,
    weather,
    updatedAt,
    deleted,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.areaId == this.areaId &&
          other.userPlantId == this.userPlantId &&
          other.date == this.date &&
          other.content == this.content &&
          other.weather == this.weather &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.syncStatus == this.syncStatus);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> areaId;
  final Value<String?> userPlantId;
  final Value<DateTime> date;
  final Value<String> content;
  final Value<String?> weather;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.areaId = const Value.absent(),
    this.userPlantId = const Value.absent(),
    this.date = const Value.absent(),
    this.content = const Value.absent(),
    this.weather = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required String userId,
    this.areaId = const Value.absent(),
    this.userPlantId = const Value.absent(),
    required DateTime date,
    required String content,
    this.weather = const Value.absent(),
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       date = Value(date),
       content = Value(content),
       updatedAt = Value(updatedAt);
  static Insertable<Note> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? areaId,
    Expression<String>? userPlantId,
    Expression<DateTime>? date,
    Expression<String>? content,
    Expression<String>? weather,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (areaId != null) 'area_id': areaId,
      if (userPlantId != null) 'user_plant_id': userPlantId,
      if (date != null) 'date': date,
      if (content != null) 'text': content,
      if (weather != null) 'weather': weather,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? areaId,
    Value<String?>? userPlantId,
    Value<DateTime>? date,
    Value<String>? content,
    Value<String?>? weather,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      areaId: areaId ?? this.areaId,
      userPlantId: userPlantId ?? this.userPlantId,
      date: date ?? this.date,
      content: content ?? this.content,
      weather: weather ?? this.weather,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (areaId.present) {
      map['area_id'] = Variable<String>(areaId.value);
    }
    if (userPlantId.present) {
      map['user_plant_id'] = Variable<String>(userPlantId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (content.present) {
      map['text'] = Variable<String>(content.value);
    }
    if (weather.present) {
      map['weather'] = Variable<String>(weather.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('areaId: $areaId, ')
          ..write('userPlantId: $userPlantId, ')
          ..write('date: $date, ')
          ..write('content: $content, ')
          ..write('weather: $weather, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuppliesTable extends Supplies with TableInfo<$SuppliesTable, Supply> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SupplyCategory, String> category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('other'),
      ).withConverter<SupplyCategory>($SuppliesTable.$convertercategory);
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _lowThresholdMeta = const VerificationMeta(
    'lowThreshold',
  );
  @override
  late final GeneratedColumn<double> lowThreshold = GeneratedColumn<double>(
    'low_threshold',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(kSyncPending),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    unit,
    category,
    quantity,
    lowThreshold,
    updatedAt,
    deleted,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supply';
  @override
  VerificationContext validateIntegrity(
    Insertable<Supply> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('low_threshold')) {
      context.handle(
        _lowThresholdMeta,
        lowThreshold.isAcceptableOrUnknown(
          data['low_threshold']!,
          _lowThresholdMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Supply map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supply(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      category: $SuppliesTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      lowThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}low_threshold'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $SuppliesTable createAlias(String alias) {
    return $SuppliesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SupplyCategory, String, String> $convertercategory =
      const EnumNameConverter<SupplyCategory>(SupplyCategory.values);
}

class Supply extends DataClass implements Insertable<Supply> {
  final String id;
  final String userId;
  final String name;
  final String? unit;
  final SupplyCategory category;
  final double quantity;
  final double? lowThreshold;
  final DateTime updatedAt;
  final bool deleted;
  final String syncStatus;
  const Supply({
    required this.id,
    required this.userId,
    required this.name,
    this.unit,
    required this.category,
    required this.quantity,
    this.lowThreshold,
    required this.updatedAt,
    required this.deleted,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    {
      map['category'] = Variable<String>(
        $SuppliesTable.$convertercategory.toSql(category),
      );
    }
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || lowThreshold != null) {
      map['low_threshold'] = Variable<double>(lowThreshold);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  SuppliesCompanion toCompanion(bool nullToAbsent) {
    return SuppliesCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      category: Value(category),
      quantity: Value(quantity),
      lowThreshold: lowThreshold == null && nullToAbsent
          ? const Value.absent()
          : Value(lowThreshold),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      syncStatus: Value(syncStatus),
    );
  }

  factory Supply.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supply(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String?>(json['unit']),
      category: $SuppliesTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      quantity: serializer.fromJson<double>(json['quantity']),
      lowThreshold: serializer.fromJson<double?>(json['lowThreshold']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String?>(unit),
      'category': serializer.toJson<String>(
        $SuppliesTable.$convertercategory.toJson(category),
      ),
      'quantity': serializer.toJson<double>(quantity),
      'lowThreshold': serializer.toJson<double?>(lowThreshold),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Supply copyWith({
    String? id,
    String? userId,
    String? name,
    Value<String?> unit = const Value.absent(),
    SupplyCategory? category,
    double? quantity,
    Value<double?> lowThreshold = const Value.absent(),
    DateTime? updatedAt,
    bool? deleted,
    String? syncStatus,
  }) => Supply(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    unit: unit.present ? unit.value : this.unit,
    category: category ?? this.category,
    quantity: quantity ?? this.quantity,
    lowThreshold: lowThreshold.present ? lowThreshold.value : this.lowThreshold,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Supply copyWithCompanion(SuppliesCompanion data) {
    return Supply(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      category: data.category.present ? data.category.value : this.category,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      lowThreshold: data.lowThreshold.present
          ? data.lowThreshold.value
          : this.lowThreshold,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supply(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('quantity: $quantity, ')
          ..write('lowThreshold: $lowThreshold, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    unit,
    category,
    quantity,
    lowThreshold,
    updatedAt,
    deleted,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supply &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.category == this.category &&
          other.quantity == this.quantity &&
          other.lowThreshold == this.lowThreshold &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.syncStatus == this.syncStatus);
}

class SuppliesCompanion extends UpdateCompanion<Supply> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> unit;
  final Value<SupplyCategory> category;
  final Value<double> quantity;
  final Value<double?> lowThreshold;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const SuppliesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.category = const Value.absent(),
    this.quantity = const Value.absent(),
    this.lowThreshold = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliesCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.unit = const Value.absent(),
    this.category = const Value.absent(),
    this.quantity = const Value.absent(),
    this.lowThreshold = const Value.absent(),
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<Supply> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<String>? category,
    Expression<double>? quantity,
    Expression<double>? lowThreshold,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (category != null) 'category': category,
      if (quantity != null) 'quantity': quantity,
      if (lowThreshold != null) 'low_threshold': lowThreshold,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String?>? unit,
    Value<SupplyCategory>? category,
    Value<double>? quantity,
    Value<double?>? lowThreshold,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return SuppliesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      lowThreshold: lowThreshold ?? this.lowThreshold,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $SuppliesTable.$convertercategory.toSql(category.value),
      );
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (lowThreshold.present) {
      map['low_threshold'] = Variable<double>(lowThreshold.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('quantity: $quantity, ')
          ..write('lowThreshold: $lowThreshold, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipesTable extends Recipes with TableInfo<$RecipesTable, Recipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemsMeta = const VerificationMeta('items');
  @override
  late final GeneratedColumn<String> items = GeneratedColumn<String>(
    'items',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(kSyncPending),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    equipment,
    items,
    updatedAt,
    deleted,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recipe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    }
    if (data.containsKey('items')) {
      context.handle(
        _itemsMeta,
        items.isAcceptableOrUnknown(data['items']!, _itemsMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recipe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      ),
      items: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}items'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class Recipe extends DataClass implements Insertable<Recipe> {
  final String id;
  final String userId;
  final String name;
  final String? equipment;
  final String? items;
  final DateTime updatedAt;
  final bool deleted;
  final String syncStatus;
  const Recipe({
    required this.id,
    required this.userId,
    required this.name,
    this.equipment,
    this.items,
    required this.updatedAt,
    required this.deleted,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || equipment != null) {
      map['equipment'] = Variable<String>(equipment);
    }
    if (!nullToAbsent || items != null) {
      map['items'] = Variable<String>(items);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      equipment: equipment == null && nullToAbsent
          ? const Value.absent()
          : Value(equipment),
      items: items == null && nullToAbsent
          ? const Value.absent()
          : Value(items),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      syncStatus: Value(syncStatus),
    );
  }

  factory Recipe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recipe(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      equipment: serializer.fromJson<String?>(json['equipment']),
      items: serializer.fromJson<String?>(json['items']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'equipment': serializer.toJson<String?>(equipment),
      'items': serializer.toJson<String?>(items),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Recipe copyWith({
    String? id,
    String? userId,
    String? name,
    Value<String?> equipment = const Value.absent(),
    Value<String?> items = const Value.absent(),
    DateTime? updatedAt,
    bool? deleted,
    String? syncStatus,
  }) => Recipe(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    equipment: equipment.present ? equipment.value : this.equipment,
    items: items.present ? items.value : this.items,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Recipe copyWithCompanion(RecipesCompanion data) {
    return Recipe(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      items: data.items.present ? data.items.value : this.items,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recipe(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('equipment: $equipment, ')
          ..write('items: $items, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    equipment,
    items,
    updatedAt,
    deleted,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recipe &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.equipment == this.equipment &&
          other.items == this.items &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.syncStatus == this.syncStatus);
}

class RecipesCompanion extends UpdateCompanion<Recipe> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> equipment;
  final Value<String?> items;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.equipment = const Value.absent(),
    this.items = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipesCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.equipment = const Value.absent(),
    this.items = const Value.absent(),
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<Recipe> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? equipment,
    Expression<String>? items,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (equipment != null) 'equipment': equipment,
      if (items != null) 'items': items,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String?>? equipment,
    Value<String?>? items,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return RecipesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      equipment: equipment ?? this.equipment,
      items: items ?? this.items,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (items.present) {
      map['items'] = Variable<String>(items.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('equipment: $equipment, ')
          ..write('items: $items, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskSuppliesTable extends TaskSupplies
    with TableInfo<$TaskSuppliesTable, TaskSupply> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskSuppliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES task (id)',
    ),
  );
  static const VerificationMeta _supplyIdMeta = const VerificationMeta(
    'supplyId',
  );
  @override
  late final GeneratedColumn<String> supplyId = GeneratedColumn<String>(
    'supply_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES supply (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedMeta = const VerificationMeta(
    'applied',
  );
  @override
  late final GeneratedColumn<bool> applied = GeneratedColumn<bool>(
    'applied',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("applied" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(kSyncPending),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    supplyId,
    amount,
    applied,
    updatedAt,
    deleted,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_supply';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskSupply> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('supply_id')) {
      context.handle(
        _supplyIdMeta,
        supplyId.isAcceptableOrUnknown(data['supply_id']!, _supplyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplyIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('applied')) {
      context.handle(
        _appliedMeta,
        applied.isAcceptableOrUnknown(data['applied']!, _appliedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskSupply map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskSupply(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      supplyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supply_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      applied: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}applied'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $TaskSuppliesTable createAlias(String alias) {
    return $TaskSuppliesTable(attachedDatabase, alias);
  }
}

class TaskSupply extends DataClass implements Insertable<TaskSupply> {
  final String id;
  final String taskId;
  final String supplyId;
  final double amount;
  final bool applied;
  final DateTime updatedAt;
  final bool deleted;
  final String syncStatus;
  const TaskSupply({
    required this.id,
    required this.taskId,
    required this.supplyId,
    required this.amount,
    required this.applied,
    required this.updatedAt,
    required this.deleted,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['supply_id'] = Variable<String>(supplyId);
    map['amount'] = Variable<double>(amount);
    map['applied'] = Variable<bool>(applied);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  TaskSuppliesCompanion toCompanion(bool nullToAbsent) {
    return TaskSuppliesCompanion(
      id: Value(id),
      taskId: Value(taskId),
      supplyId: Value(supplyId),
      amount: Value(amount),
      applied: Value(applied),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      syncStatus: Value(syncStatus),
    );
  }

  factory TaskSupply.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskSupply(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      supplyId: serializer.fromJson<String>(json['supplyId']),
      amount: serializer.fromJson<double>(json['amount']),
      applied: serializer.fromJson<bool>(json['applied']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'supplyId': serializer.toJson<String>(supplyId),
      'amount': serializer.toJson<double>(amount),
      'applied': serializer.toJson<bool>(applied),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  TaskSupply copyWith({
    String? id,
    String? taskId,
    String? supplyId,
    double? amount,
    bool? applied,
    DateTime? updatedAt,
    bool? deleted,
    String? syncStatus,
  }) => TaskSupply(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    supplyId: supplyId ?? this.supplyId,
    amount: amount ?? this.amount,
    applied: applied ?? this.applied,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  TaskSupply copyWithCompanion(TaskSuppliesCompanion data) {
    return TaskSupply(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      supplyId: data.supplyId.present ? data.supplyId.value : this.supplyId,
      amount: data.amount.present ? data.amount.value : this.amount,
      applied: data.applied.present ? data.applied.value : this.applied,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskSupply(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('supplyId: $supplyId, ')
          ..write('amount: $amount, ')
          ..write('applied: $applied, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    supplyId,
    amount,
    applied,
    updatedAt,
    deleted,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskSupply &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.supplyId == this.supplyId &&
          other.amount == this.amount &&
          other.applied == this.applied &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.syncStatus == this.syncStatus);
}

class TaskSuppliesCompanion extends UpdateCompanion<TaskSupply> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> supplyId;
  final Value<double> amount;
  final Value<bool> applied;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const TaskSuppliesCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.supplyId = const Value.absent(),
    this.amount = const Value.absent(),
    this.applied = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskSuppliesCompanion.insert({
    required String id,
    required String taskId,
    required String supplyId,
    required double amount,
    this.applied = const Value.absent(),
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       supplyId = Value(supplyId),
       amount = Value(amount),
       updatedAt = Value(updatedAt);
  static Insertable<TaskSupply> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? supplyId,
    Expression<double>? amount,
    Expression<bool>? applied,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (supplyId != null) 'supply_id': supplyId,
      if (amount != null) 'amount': amount,
      if (applied != null) 'applied': applied,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskSuppliesCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String>? supplyId,
    Value<double>? amount,
    Value<bool>? applied,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return TaskSuppliesCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      supplyId: supplyId ?? this.supplyId,
      amount: amount ?? this.amount,
      applied: applied ?? this.applied,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (supplyId.present) {
      map['supply_id'] = Variable<String>(supplyId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (applied.present) {
      map['applied'] = Variable<bool>(applied.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskSuppliesCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('supplyId: $supplyId, ')
          ..write('amount: $amount, ')
          ..write('applied: $applied, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPulledAtMeta = const VerificationMeta(
    'lastPulledAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPulledAt = GeneratedColumn<DateTime>(
    'last_pulled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, lastPulledAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursor';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('last_pulled_at')) {
      context.handle(
        _lastPulledAtMeta,
        lastPulledAt.isAcceptableOrUnknown(
          data['last_pulled_at']!,
          _lastPulledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastPulledAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      lastPulledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_pulled_at'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String name;
  final DateTime lastPulledAt;
  const SyncCursor({required this.name, required this.lastPulledAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['last_pulled_at'] = Variable<DateTime>(lastPulledAt);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      name: Value(name),
      lastPulledAt: Value(lastPulledAt),
    );
  }

  factory SyncCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      name: serializer.fromJson<String>(json['name']),
      lastPulledAt: serializer.fromJson<DateTime>(json['lastPulledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'lastPulledAt': serializer.toJson<DateTime>(lastPulledAt),
    };
  }

  SyncCursor copyWith({String? name, DateTime? lastPulledAt}) => SyncCursor(
    name: name ?? this.name,
    lastPulledAt: lastPulledAt ?? this.lastPulledAt,
  );
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      name: data.name.present ? data.name.value : this.name,
      lastPulledAt: data.lastPulledAt.present
          ? data.lastPulledAt.value
          : this.lastPulledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('name: $name, ')
          ..write('lastPulledAt: $lastPulledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, lastPulledAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor &&
          other.name == this.name &&
          other.lastPulledAt == this.lastPulledAt);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> name;
  final Value<DateTime> lastPulledAt;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.name = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String name,
    required DateTime lastPulledAt,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       lastPulledAt = Value(lastPulledAt);
  static Insertable<SyncCursor> custom({
    Expression<String>? name,
    Expression<DateTime>? lastPulledAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (lastPulledAt != null) 'last_pulled_at': lastPulledAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? name,
    Value<DateTime>? lastPulledAt,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      name: name ?? this.name,
      lastPulledAt: lastPulledAt ?? this.lastPulledAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lastPulledAt.present) {
      map['last_pulled_at'] = Variable<DateTime>(lastPulledAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('name: $name, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalFlagsTable extends LocalFlags
    with TableInfo<$LocalFlagsTable, LocalFlag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFlagsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'local_flag';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalFlag> instance, {
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
  LocalFlag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFlag(
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
  $LocalFlagsTable createAlias(String alias) {
    return $LocalFlagsTable(attachedDatabase, alias);
  }
}

class LocalFlag extends DataClass implements Insertable<LocalFlag> {
  final String key;
  final String value;
  const LocalFlag({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  LocalFlagsCompanion toCompanion(bool nullToAbsent) {
    return LocalFlagsCompanion(key: Value(key), value: Value(value));
  }

  factory LocalFlag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFlag(
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

  LocalFlag copyWith({String? key, String? value}) =>
      LocalFlag(key: key ?? this.key, value: value ?? this.value);
  LocalFlag copyWithCompanion(LocalFlagsCompanion data) {
    return LocalFlag(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFlag(')
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
      (other is LocalFlag &&
          other.key == this.key &&
          other.value == this.value);
}

class LocalFlagsCompanion extends UpdateCompanion<LocalFlag> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const LocalFlagsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFlagsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<LocalFlag> custom({
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

  LocalFlagsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return LocalFlagsCompanion(
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
    return (StringBuffer('LocalFlagsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
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
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $AreasTable areas = $AreasTable(this);
  late final $UserPlantsTable userPlants = $UserPlantsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TaskSubjectsTable taskSubjects = $TaskSubjectsTable(this);
  late final $TaskRemindersTable taskReminders = $TaskRemindersTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $SuppliesTable supplies = $SuppliesTable(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $TaskSuppliesTable taskSupplies = $TaskSuppliesTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $LocalFlagsTable localFlags = $LocalFlagsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    taskTypes,
    plants,
    plantSynonyms,
    categoryTaskTypes,
    profiles,
    areas,
    userPlants,
    tasks,
    taskSubjects,
    taskReminders,
    notes,
    supplies,
    recipes,
    taskSupplies,
    syncCursors,
    localFlags,
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
      Value<bool> consumesSupplies,
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
      Value<bool> consumesSupplies,
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

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: $_aliasNameGenerator(db.taskTypes.id, db.tasks.taskTypeId),
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.taskTypeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
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

  ColumnFilters<bool> get consumesSupplies => $composableBuilder(
    column: $table.consumesSupplies,
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

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.taskTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
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

  ColumnOrderings<bool> get consumesSupplies => $composableBuilder(
    column: $table.consumesSupplies,
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

  GeneratedColumn<bool> get consumesSupplies => $composableBuilder(
    column: $table.consumesSupplies,
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

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.taskTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
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
          PrefetchHooks Function({bool categoryTaskTypesRefs, bool tasksRefs})
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
                Value<bool> consumesSupplies = const Value.absent(),
                Value<int?> defaultCadence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskTypesCompanion(
                id: id,
                labels: labels,
                icon: icon,
                category: category,
                requiresSubject: requiresSubject,
                weatherSensitive: weatherSensitive,
                consumesSupplies: consumesSupplies,
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
                Value<bool> consumesSupplies = const Value.absent(),
                Value<int?> defaultCadence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskTypesCompanion.insert(
                id: id,
                labels: labels,
                icon: icon,
                category: category,
                requiresSubject: requiresSubject,
                weatherSensitive: weatherSensitive,
                consumesSupplies: consumesSupplies,
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
          prefetchHooksCallback:
              ({categoryTaskTypesRefs = false, tasksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (categoryTaskTypesRefs) db.categoryTaskTypes,
                    if (tasksRefs) db.tasks,
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
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskTypeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tasksRefs)
                        await $_getPrefetchedData<
                          TaskType,
                          $TaskTypesTable,
                          Task
                        >(
                          currentTable: table,
                          referencedTable: $$TaskTypesTableReferences
                              ._tasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TaskTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).tasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskTypeId == item.id,
                              ),
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
      PrefetchHooks Function({bool categoryTaskTypesRefs, bool tasksRefs})
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

  static MultiTypedResultKey<$UserPlantsTable, List<UserPlant>>
  _userPlantsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userPlants,
    aliasName: $_aliasNameGenerator(db.plants.id, db.userPlants.plantId),
  );

  $$UserPlantsTableProcessedTableManager get userPlantsRefs {
    final manager = $$UserPlantsTableTableManager(
      $_db,
      $_db.userPlants,
    ).filter((f) => f.plantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userPlantsRefsTable($_db));
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

  Expression<bool> userPlantsRefs(
    Expression<bool> Function($$UserPlantsTableFilterComposer f) f,
  ) {
    final $$UserPlantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userPlants,
      getReferencedColumn: (t) => t.plantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPlantsTableFilterComposer(
            $db: $db,
            $table: $db.userPlants,
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

  Expression<T> userPlantsRefs<T extends Object>(
    Expression<T> Function($$UserPlantsTableAnnotationComposer a) f,
  ) {
    final $$UserPlantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userPlants,
      getReferencedColumn: (t) => t.plantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPlantsTableAnnotationComposer(
            $db: $db,
            $table: $db.userPlants,
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
          PrefetchHooks Function({bool plantSynonymsRefs, bool userPlantsRefs})
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
          prefetchHooksCallback:
              ({plantSynonymsRefs = false, userPlantsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (plantSynonymsRefs) db.plantSynonyms,
                    if (userPlantsRefs) db.userPlants,
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
                          managerFromTypedResult: (p0) =>
                              $$PlantsTableReferences(
                                db,
                                table,
                                p0,
                              ).plantSynonymsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.plantId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userPlantsRefs)
                        await $_getPrefetchedData<
                          Plant,
                          $PlantsTable,
                          UserPlant
                        >(
                          currentTable: table,
                          referencedTable: $$PlantsTableReferences
                              ._userPlantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlantsTableReferences(
                                db,
                                table,
                                p0,
                              ).userPlantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.plantId == item.id,
                              ),
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
      PrefetchHooks Function({bool plantSynonymsRefs, bool userPlantsRefs})
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
typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String userId,
      Value<String?> h3R7,
      Value<String?> h3R6,
      Value<String?> h3R5,
      Value<String?> lang,
      Value<String?> notificationSettings,
      Value<bool> defaultGardenSeeded,
      required DateTime updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> userId,
      Value<String?> h3R7,
      Value<String?> h3R6,
      Value<String?> h3R5,
      Value<String?> lang,
      Value<String?> notificationSettings,
      Value<bool> defaultGardenSeeded,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get h3R7 => $composableBuilder(
    column: $table.h3R7,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get h3R6 => $composableBuilder(
    column: $table.h3R6,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get h3R5 => $composableBuilder(
    column: $table.h3R5,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationSettings => $composableBuilder(
    column: $table.notificationSettings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get defaultGardenSeeded => $composableBuilder(
    column: $table.defaultGardenSeeded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get h3R7 => $composableBuilder(
    column: $table.h3R7,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get h3R6 => $composableBuilder(
    column: $table.h3R6,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get h3R5 => $composableBuilder(
    column: $table.h3R5,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationSettings => $composableBuilder(
    column: $table.notificationSettings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get defaultGardenSeeded => $composableBuilder(
    column: $table.defaultGardenSeeded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get h3R7 =>
      $composableBuilder(column: $table.h3R7, builder: (column) => column);

  GeneratedColumn<String> get h3R6 =>
      $composableBuilder(column: $table.h3R6, builder: (column) => column);

  GeneratedColumn<String> get h3R5 =>
      $composableBuilder(column: $table.h3R5, builder: (column) => column);

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get notificationSettings => $composableBuilder(
    column: $table.notificationSettings,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get defaultGardenSeeded => $composableBuilder(
    column: $table.defaultGardenSeeded,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String?> h3R7 = const Value.absent(),
                Value<String?> h3R6 = const Value.absent(),
                Value<String?> h3R5 = const Value.absent(),
                Value<String?> lang = const Value.absent(),
                Value<String?> notificationSettings = const Value.absent(),
                Value<bool> defaultGardenSeeded = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                userId: userId,
                h3R7: h3R7,
                h3R6: h3R6,
                h3R5: h3R5,
                lang: lang,
                notificationSettings: notificationSettings,
                defaultGardenSeeded: defaultGardenSeeded,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<String?> h3R7 = const Value.absent(),
                Value<String?> h3R6 = const Value.absent(),
                Value<String?> h3R5 = const Value.absent(),
                Value<String?> lang = const Value.absent(),
                Value<String?> notificationSettings = const Value.absent(),
                Value<bool> defaultGardenSeeded = const Value.absent(),
                required DateTime updatedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                userId: userId,
                h3R7: h3R7,
                h3R6: h3R6,
                h3R5: h3R5,
                lang: lang,
                notificationSettings: notificationSettings,
                defaultGardenSeeded: defaultGardenSeeded,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$AreasTableCreateCompanionBuilder =
    AreasCompanion Function({
      required String id,
      required String userId,
      required String name,
      Value<AreaType> type,
      Value<bool> protected,
      required DateTime updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$AreasTableUpdateCompanionBuilder =
    AreasCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<AreaType> type,
      Value<bool> protected,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$AreasTableReferences
    extends BaseReferences<_$AppDatabase, $AreasTable, Area> {
  $$AreasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserPlantsTable, List<UserPlant>>
  _userPlantsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userPlants,
    aliasName: $_aliasNameGenerator(db.areas.id, db.userPlants.areaId),
  );

  $$UserPlantsTableProcessedTableManager get userPlantsRefs {
    final manager = $$UserPlantsTableTableManager(
      $_db,
      $_db.userPlants,
    ).filter((f) => f.areaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userPlantsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TaskSubjectsTable, List<TaskSubject>>
  _taskSubjectsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.taskSubjects,
    aliasName: $_aliasNameGenerator(db.areas.id, db.taskSubjects.areaId),
  );

  $$TaskSubjectsTableProcessedTableManager get taskSubjectsRefs {
    final manager = $$TaskSubjectsTableTableManager(
      $_db,
      $_db.taskSubjects,
    ).filter((f) => f.areaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskSubjectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NotesTable, List<Note>> _notesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.notes,
    aliasName: $_aliasNameGenerator(db.areas.id, db.notes.areaId),
  );

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.areaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AreasTableFilterComposer extends Composer<_$AppDatabase, $AreasTable> {
  $$AreasTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AreaType, AreaType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get protected => $composableBuilder(
    column: $table.protected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userPlantsRefs(
    Expression<bool> Function($$UserPlantsTableFilterComposer f) f,
  ) {
    final $$UserPlantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userPlants,
      getReferencedColumn: (t) => t.areaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPlantsTableFilterComposer(
            $db: $db,
            $table: $db.userPlants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> taskSubjectsRefs(
    Expression<bool> Function($$TaskSubjectsTableFilterComposer f) f,
  ) {
    final $$TaskSubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSubjects,
      getReferencedColumn: (t) => t.areaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSubjectsTableFilterComposer(
            $db: $db,
            $table: $db.taskSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notesRefs(
    Expression<bool> Function($$NotesTableFilterComposer f) f,
  ) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.areaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AreasTableOrderingComposer
    extends Composer<_$AppDatabase, $AreasTable> {
  $$AreasTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get protected => $composableBuilder(
    column: $table.protected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AreasTableAnnotationComposer
    extends Composer<_$AppDatabase, $AreasTable> {
  $$AreasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AreaType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get protected =>
      $composableBuilder(column: $table.protected, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  Expression<T> userPlantsRefs<T extends Object>(
    Expression<T> Function($$UserPlantsTableAnnotationComposer a) f,
  ) {
    final $$UserPlantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userPlants,
      getReferencedColumn: (t) => t.areaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPlantsTableAnnotationComposer(
            $db: $db,
            $table: $db.userPlants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> taskSubjectsRefs<T extends Object>(
    Expression<T> Function($$TaskSubjectsTableAnnotationComposer a) f,
  ) {
    final $$TaskSubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSubjects,
      getReferencedColumn: (t) => t.areaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.taskSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notesRefs<T extends Object>(
    Expression<T> Function($$NotesTableAnnotationComposer a) f,
  ) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.areaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AreasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AreasTable,
          Area,
          $$AreasTableFilterComposer,
          $$AreasTableOrderingComposer,
          $$AreasTableAnnotationComposer,
          $$AreasTableCreateCompanionBuilder,
          $$AreasTableUpdateCompanionBuilder,
          (Area, $$AreasTableReferences),
          Area,
          PrefetchHooks Function({
            bool userPlantsRefs,
            bool taskSubjectsRefs,
            bool notesRefs,
          })
        > {
  $$AreasTableTableManager(_$AppDatabase db, $AreasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AreasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AreasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AreasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<AreaType> type = const Value.absent(),
                Value<bool> protected = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AreasCompanion(
                id: id,
                userId: userId,
                name: name,
                type: type,
                protected: protected,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                Value<AreaType> type = const Value.absent(),
                Value<bool> protected = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AreasCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                type: type,
                protected: protected,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AreasTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                userPlantsRefs = false,
                taskSubjectsRefs = false,
                notesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (userPlantsRefs) db.userPlants,
                    if (taskSubjectsRefs) db.taskSubjects,
                    if (notesRefs) db.notes,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (userPlantsRefs)
                        await $_getPrefetchedData<Area, $AreasTable, UserPlant>(
                          currentTable: table,
                          referencedTable: $$AreasTableReferences
                              ._userPlantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AreasTableReferences(
                                db,
                                table,
                                p0,
                              ).userPlantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.areaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (taskSubjectsRefs)
                        await $_getPrefetchedData<
                          Area,
                          $AreasTable,
                          TaskSubject
                        >(
                          currentTable: table,
                          referencedTable: $$AreasTableReferences
                              ._taskSubjectsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AreasTableReferences(
                                db,
                                table,
                                p0,
                              ).taskSubjectsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.areaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (notesRefs)
                        await $_getPrefetchedData<Area, $AreasTable, Note>(
                          currentTable: table,
                          referencedTable: $$AreasTableReferences
                              ._notesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AreasTableReferences(db, table, p0).notesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.areaId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AreasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AreasTable,
      Area,
      $$AreasTableFilterComposer,
      $$AreasTableOrderingComposer,
      $$AreasTableAnnotationComposer,
      $$AreasTableCreateCompanionBuilder,
      $$AreasTableUpdateCompanionBuilder,
      (Area, $$AreasTableReferences),
      Area,
      PrefetchHooks Function({
        bool userPlantsRefs,
        bool taskSubjectsRefs,
        bool notesRefs,
      })
    >;
typedef $$UserPlantsTableCreateCompanionBuilder =
    UserPlantsCompanion Function({
      required String id,
      required String userId,
      Value<String?> areaId,
      Value<String?> plantId,
      Value<String?> customName,
      Value<String?> personalAlias,
      Value<bool> isCustom,
      required DateTime updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$UserPlantsTableUpdateCompanionBuilder =
    UserPlantsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> areaId,
      Value<String?> plantId,
      Value<String?> customName,
      Value<String?> personalAlias,
      Value<bool> isCustom,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$UserPlantsTableReferences
    extends BaseReferences<_$AppDatabase, $UserPlantsTable, UserPlant> {
  $$UserPlantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AreasTable _areaIdTable(_$AppDatabase db) => db.areas.createAlias(
    $_aliasNameGenerator(db.userPlants.areaId, db.areas.id),
  );

  $$AreasTableProcessedTableManager? get areaId {
    final $_column = $_itemColumn<String>('area_id');
    if ($_column == null) return null;
    final manager = $$AreasTableTableManager(
      $_db,
      $_db.areas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_areaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlantsTable _plantIdTable(_$AppDatabase db) => db.plants.createAlias(
    $_aliasNameGenerator(db.userPlants.plantId, db.plants.id),
  );

  $$PlantsTableProcessedTableManager? get plantId {
    final $_column = $_itemColumn<String>('plant_id');
    if ($_column == null) return null;
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

  static MultiTypedResultKey<$TaskSubjectsTable, List<TaskSubject>>
  _taskSubjectsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.taskSubjects,
    aliasName: $_aliasNameGenerator(
      db.userPlants.id,
      db.taskSubjects.userPlantId,
    ),
  );

  $$TaskSubjectsTableProcessedTableManager get taskSubjectsRefs {
    final manager = $$TaskSubjectsTableTableManager(
      $_db,
      $_db.taskSubjects,
    ).filter((f) => f.userPlantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskSubjectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NotesTable, List<Note>> _notesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.notes,
    aliasName: $_aliasNameGenerator(db.userPlants.id, db.notes.userPlantId),
  );

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.userPlantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserPlantsTableFilterComposer
    extends Composer<_$AppDatabase, $UserPlantsTable> {
  $$UserPlantsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personalAlias => $composableBuilder(
    column: $table.personalAlias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$AreasTableFilterComposer get areaId {
    final $$AreasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.areaId,
      referencedTable: $db.areas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AreasTableFilterComposer(
            $db: $db,
            $table: $db.areas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  Expression<bool> taskSubjectsRefs(
    Expression<bool> Function($$TaskSubjectsTableFilterComposer f) f,
  ) {
    final $$TaskSubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSubjects,
      getReferencedColumn: (t) => t.userPlantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSubjectsTableFilterComposer(
            $db: $db,
            $table: $db.taskSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notesRefs(
    Expression<bool> Function($$NotesTableFilterComposer f) f,
  ) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.userPlantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserPlantsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPlantsTable> {
  $$UserPlantsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personalAlias => $composableBuilder(
    column: $table.personalAlias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$AreasTableOrderingComposer get areaId {
    final $$AreasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.areaId,
      referencedTable: $db.areas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AreasTableOrderingComposer(
            $db: $db,
            $table: $db.areas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

class $$UserPlantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPlantsTable> {
  $$UserPlantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personalAlias => $composableBuilder(
    column: $table.personalAlias,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$AreasTableAnnotationComposer get areaId {
    final $$AreasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.areaId,
      referencedTable: $db.areas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AreasTableAnnotationComposer(
            $db: $db,
            $table: $db.areas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

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

  Expression<T> taskSubjectsRefs<T extends Object>(
    Expression<T> Function($$TaskSubjectsTableAnnotationComposer a) f,
  ) {
    final $$TaskSubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSubjects,
      getReferencedColumn: (t) => t.userPlantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.taskSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notesRefs<T extends Object>(
    Expression<T> Function($$NotesTableAnnotationComposer a) f,
  ) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.userPlantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserPlantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPlantsTable,
          UserPlant,
          $$UserPlantsTableFilterComposer,
          $$UserPlantsTableOrderingComposer,
          $$UserPlantsTableAnnotationComposer,
          $$UserPlantsTableCreateCompanionBuilder,
          $$UserPlantsTableUpdateCompanionBuilder,
          (UserPlant, $$UserPlantsTableReferences),
          UserPlant,
          PrefetchHooks Function({
            bool areaId,
            bool plantId,
            bool taskSubjectsRefs,
            bool notesRefs,
          })
        > {
  $$UserPlantsTableTableManager(_$AppDatabase db, $UserPlantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPlantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPlantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPlantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> areaId = const Value.absent(),
                Value<String?> plantId = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String?> personalAlias = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPlantsCompanion(
                id: id,
                userId: userId,
                areaId: areaId,
                plantId: plantId,
                customName: customName,
                personalAlias: personalAlias,
                isCustom: isCustom,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> areaId = const Value.absent(),
                Value<String?> plantId = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String?> personalAlias = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPlantsCompanion.insert(
                id: id,
                userId: userId,
                areaId: areaId,
                plantId: plantId,
                customName: customName,
                personalAlias: personalAlias,
                isCustom: isCustom,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserPlantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                areaId = false,
                plantId = false,
                taskSubjectsRefs = false,
                notesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (taskSubjectsRefs) db.taskSubjects,
                    if (notesRefs) db.notes,
                  ],
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
                        if (areaId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.areaId,
                                    referencedTable: $$UserPlantsTableReferences
                                        ._areaIdTable(db),
                                    referencedColumn:
                                        $$UserPlantsTableReferences
                                            ._areaIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (plantId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.plantId,
                                    referencedTable: $$UserPlantsTableReferences
                                        ._plantIdTable(db),
                                    referencedColumn:
                                        $$UserPlantsTableReferences
                                            ._plantIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (taskSubjectsRefs)
                        await $_getPrefetchedData<
                          UserPlant,
                          $UserPlantsTable,
                          TaskSubject
                        >(
                          currentTable: table,
                          referencedTable: $$UserPlantsTableReferences
                              ._taskSubjectsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserPlantsTableReferences(
                                db,
                                table,
                                p0,
                              ).taskSubjectsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userPlantId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (notesRefs)
                        await $_getPrefetchedData<
                          UserPlant,
                          $UserPlantsTable,
                          Note
                        >(
                          currentTable: table,
                          referencedTable: $$UserPlantsTableReferences
                              ._notesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserPlantsTableReferences(
                                db,
                                table,
                                p0,
                              ).notesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userPlantId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UserPlantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPlantsTable,
      UserPlant,
      $$UserPlantsTableFilterComposer,
      $$UserPlantsTableOrderingComposer,
      $$UserPlantsTableAnnotationComposer,
      $$UserPlantsTableCreateCompanionBuilder,
      $$UserPlantsTableUpdateCompanionBuilder,
      (UserPlant, $$UserPlantsTableReferences),
      UserPlant,
      PrefetchHooks Function({
        bool areaId,
        bool plantId,
        bool taskSubjectsRefs,
        bool notesRefs,
      })
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      required String id,
      required String userId,
      required String taskTypeId,
      required DateTime date,
      Value<TaskStatus> status,
      Value<String?> note,
      Value<String?> weather,
      Value<String?> recurrence,
      Value<String?> seriesId,
      required DateTime updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> taskTypeId,
      Value<DateTime> date,
      Value<TaskStatus> status,
      Value<String?> note,
      Value<String?> weather,
      Value<String?> recurrence,
      Value<String?> seriesId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TaskTypesTable _taskTypeIdTable(_$AppDatabase db) => db.taskTypes
      .createAlias($_aliasNameGenerator(db.tasks.taskTypeId, db.taskTypes.id));

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

  static MultiTypedResultKey<$TaskSubjectsTable, List<TaskSubject>>
  _taskSubjectsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.taskSubjects,
    aliasName: $_aliasNameGenerator(db.tasks.id, db.taskSubjects.taskId),
  );

  $$TaskSubjectsTableProcessedTableManager get taskSubjectsRefs {
    final manager = $$TaskSubjectsTableTableManager(
      $_db,
      $_db.taskSubjects,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskSubjectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TaskRemindersTable, List<TaskReminder>>
  _taskRemindersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.taskReminders,
    aliasName: $_aliasNameGenerator(db.tasks.id, db.taskReminders.taskId),
  );

  $$TaskRemindersTableProcessedTableManager get taskRemindersRefs {
    final manager = $$TaskRemindersTableTableManager(
      $_db,
      $_db.taskReminders,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskRemindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TaskSuppliesTable, List<TaskSupply>>
  _taskSuppliesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.taskSupplies,
    aliasName: $_aliasNameGenerator(db.tasks.id, db.taskSupplies.taskId),
  );

  $$TaskSuppliesTableProcessedTableManager get taskSuppliesRefs {
    final manager = $$TaskSuppliesTableTableManager(
      $_db,
      $_db.taskSupplies,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskSuppliesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TaskStatus, TaskStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weather => $composableBuilder(
    column: $table.weather,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
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

  Expression<bool> taskSubjectsRefs(
    Expression<bool> Function($$TaskSubjectsTableFilterComposer f) f,
  ) {
    final $$TaskSubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSubjects,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSubjectsTableFilterComposer(
            $db: $db,
            $table: $db.taskSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> taskRemindersRefs(
    Expression<bool> Function($$TaskRemindersTableFilterComposer f) f,
  ) {
    final $$TaskRemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskReminders,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskRemindersTableFilterComposer(
            $db: $db,
            $table: $db.taskReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> taskSuppliesRefs(
    Expression<bool> Function($$TaskSuppliesTableFilterComposer f) f,
  ) {
    final $$TaskSuppliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSupplies,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSuppliesTableFilterComposer(
            $db: $db,
            $table: $db.taskSupplies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weather => $composableBuilder(
    column: $table.weather,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
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

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get weather =>
      $composableBuilder(column: $table.weather, builder: (column) => column);

  GeneratedColumn<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

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

  Expression<T> taskSubjectsRefs<T extends Object>(
    Expression<T> Function($$TaskSubjectsTableAnnotationComposer a) f,
  ) {
    final $$TaskSubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSubjects,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.taskSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> taskRemindersRefs<T extends Object>(
    Expression<T> Function($$TaskRemindersTableAnnotationComposer a) f,
  ) {
    final $$TaskRemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskReminders,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskRemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.taskReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> taskSuppliesRefs<T extends Object>(
    Expression<T> Function($$TaskSuppliesTableAnnotationComposer a) f,
  ) {
    final $$TaskSuppliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSupplies,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSuppliesTableAnnotationComposer(
            $db: $db,
            $table: $db.taskSupplies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({
            bool taskTypeId,
            bool taskSubjectsRefs,
            bool taskRemindersRefs,
            bool taskSuppliesRefs,
          })
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> taskTypeId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<TaskStatus> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> weather = const Value.absent(),
                Value<String?> recurrence = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                userId: userId,
                taskTypeId: taskTypeId,
                date: date,
                status: status,
                note: note,
                weather: weather,
                recurrence: recurrence,
                seriesId: seriesId,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String taskTypeId,
                required DateTime date,
                Value<TaskStatus> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> weather = const Value.absent(),
                Value<String?> recurrence = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                userId: userId,
                taskTypeId: taskTypeId,
                date: date,
                status: status,
                note: note,
                weather: weather,
                recurrence: recurrence,
                seriesId: seriesId,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TasksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                taskTypeId = false,
                taskSubjectsRefs = false,
                taskRemindersRefs = false,
                taskSuppliesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (taskSubjectsRefs) db.taskSubjects,
                    if (taskRemindersRefs) db.taskReminders,
                    if (taskSuppliesRefs) db.taskSupplies,
                  ],
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
                                    referencedTable: $$TasksTableReferences
                                        ._taskTypeIdTable(db),
                                    referencedColumn: $$TasksTableReferences
                                        ._taskTypeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (taskSubjectsRefs)
                        await $_getPrefetchedData<
                          Task,
                          $TasksTable,
                          TaskSubject
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._taskSubjectsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).taskSubjectsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (taskRemindersRefs)
                        await $_getPrefetchedData<
                          Task,
                          $TasksTable,
                          TaskReminder
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._taskRemindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).taskRemindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (taskSuppliesRefs)
                        await $_getPrefetchedData<
                          Task,
                          $TasksTable,
                          TaskSupply
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._taskSuppliesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).taskSuppliesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({
        bool taskTypeId,
        bool taskSubjectsRefs,
        bool taskRemindersRefs,
        bool taskSuppliesRefs,
      })
    >;
typedef $$TaskSubjectsTableCreateCompanionBuilder =
    TaskSubjectsCompanion Function({
      required String id,
      required String taskId,
      Value<String?> userPlantId,
      Value<String?> areaId,
      required DateTime updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$TaskSubjectsTableUpdateCompanionBuilder =
    TaskSubjectsCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<String?> userPlantId,
      Value<String?> areaId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$TaskSubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $TaskSubjectsTable, TaskSubject> {
  $$TaskSubjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks.createAlias(
    $_aliasNameGenerator(db.taskSubjects.taskId, db.tasks.id),
  );

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UserPlantsTable _userPlantIdTable(_$AppDatabase db) =>
      db.userPlants.createAlias(
        $_aliasNameGenerator(db.taskSubjects.userPlantId, db.userPlants.id),
      );

  $$UserPlantsTableProcessedTableManager? get userPlantId {
    final $_column = $_itemColumn<String>('user_plant_id');
    if ($_column == null) return null;
    final manager = $$UserPlantsTableTableManager(
      $_db,
      $_db.userPlants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userPlantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AreasTable _areaIdTable(_$AppDatabase db) => db.areas.createAlias(
    $_aliasNameGenerator(db.taskSubjects.areaId, db.areas.id),
  );

  $$AreasTableProcessedTableManager? get areaId {
    final $_column = $_itemColumn<String>('area_id');
    if ($_column == null) return null;
    final manager = $$AreasTableTableManager(
      $_db,
      $_db.areas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_areaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TaskSubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskSubjectsTable> {
  $$TaskSubjectsTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UserPlantsTableFilterComposer get userPlantId {
    final $$UserPlantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userPlantId,
      referencedTable: $db.userPlants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPlantsTableFilterComposer(
            $db: $db,
            $table: $db.userPlants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AreasTableFilterComposer get areaId {
    final $$AreasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.areaId,
      referencedTable: $db.areas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AreasTableFilterComposer(
            $db: $db,
            $table: $db.areas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskSubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskSubjectsTable> {
  $$TaskSubjectsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UserPlantsTableOrderingComposer get userPlantId {
    final $$UserPlantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userPlantId,
      referencedTable: $db.userPlants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPlantsTableOrderingComposer(
            $db: $db,
            $table: $db.userPlants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AreasTableOrderingComposer get areaId {
    final $$AreasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.areaId,
      referencedTable: $db.areas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AreasTableOrderingComposer(
            $db: $db,
            $table: $db.areas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskSubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskSubjectsTable> {
  $$TaskSubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UserPlantsTableAnnotationComposer get userPlantId {
    final $$UserPlantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userPlantId,
      referencedTable: $db.userPlants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPlantsTableAnnotationComposer(
            $db: $db,
            $table: $db.userPlants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AreasTableAnnotationComposer get areaId {
    final $$AreasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.areaId,
      referencedTable: $db.areas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AreasTableAnnotationComposer(
            $db: $db,
            $table: $db.areas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskSubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskSubjectsTable,
          TaskSubject,
          $$TaskSubjectsTableFilterComposer,
          $$TaskSubjectsTableOrderingComposer,
          $$TaskSubjectsTableAnnotationComposer,
          $$TaskSubjectsTableCreateCompanionBuilder,
          $$TaskSubjectsTableUpdateCompanionBuilder,
          (TaskSubject, $$TaskSubjectsTableReferences),
          TaskSubject,
          PrefetchHooks Function({bool taskId, bool userPlantId, bool areaId})
        > {
  $$TaskSubjectsTableTableManager(_$AppDatabase db, $TaskSubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskSubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskSubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskSubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String?> userPlantId = const Value.absent(),
                Value<String?> areaId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskSubjectsCompanion(
                id: id,
                taskId: taskId,
                userPlantId: userPlantId,
                areaId: areaId,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                Value<String?> userPlantId = const Value.absent(),
                Value<String?> areaId = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskSubjectsCompanion.insert(
                id: id,
                taskId: taskId,
                userPlantId: userPlantId,
                areaId: areaId,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TaskSubjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({taskId = false, userPlantId = false, areaId = false}) {
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
                        if (taskId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.taskId,
                                    referencedTable:
                                        $$TaskSubjectsTableReferences
                                            ._taskIdTable(db),
                                    referencedColumn:
                                        $$TaskSubjectsTableReferences
                                            ._taskIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (userPlantId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userPlantId,
                                    referencedTable:
                                        $$TaskSubjectsTableReferences
                                            ._userPlantIdTable(db),
                                    referencedColumn:
                                        $$TaskSubjectsTableReferences
                                            ._userPlantIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (areaId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.areaId,
                                    referencedTable:
                                        $$TaskSubjectsTableReferences
                                            ._areaIdTable(db),
                                    referencedColumn:
                                        $$TaskSubjectsTableReferences
                                            ._areaIdTable(db)
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

typedef $$TaskSubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskSubjectsTable,
      TaskSubject,
      $$TaskSubjectsTableFilterComposer,
      $$TaskSubjectsTableOrderingComposer,
      $$TaskSubjectsTableAnnotationComposer,
      $$TaskSubjectsTableCreateCompanionBuilder,
      $$TaskSubjectsTableUpdateCompanionBuilder,
      (TaskSubject, $$TaskSubjectsTableReferences),
      TaskSubject,
      PrefetchHooks Function({bool taskId, bool userPlantId, bool areaId})
    >;
typedef $$TaskRemindersTableCreateCompanionBuilder =
    TaskRemindersCompanion Function({
      required String id,
      required String taskId,
      required int offset,
      Value<String?> reminderTime,
      required DateTime updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$TaskRemindersTableUpdateCompanionBuilder =
    TaskRemindersCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<int> offset,
      Value<String?> reminderTime,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$TaskRemindersTableReferences
    extends BaseReferences<_$AppDatabase, $TaskRemindersTable, TaskReminder> {
  $$TaskRemindersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks.createAlias(
    $_aliasNameGenerator(db.taskReminders.taskId, db.tasks.id),
  );

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TaskRemindersTableFilterComposer
    extends Composer<_$AppDatabase, $TaskRemindersTable> {
  $$TaskRemindersTableFilterComposer({
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

  ColumnFilters<int> get offset => $composableBuilder(
    column: $table.offset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskRemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskRemindersTable> {
  $$TaskRemindersTableOrderingComposer({
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

  ColumnOrderings<int> get offset => $composableBuilder(
    column: $table.offset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskRemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskRemindersTable> {
  $$TaskRemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get offset =>
      $composableBuilder(column: $table.offset, builder: (column) => column);

  GeneratedColumn<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskRemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskRemindersTable,
          TaskReminder,
          $$TaskRemindersTableFilterComposer,
          $$TaskRemindersTableOrderingComposer,
          $$TaskRemindersTableAnnotationComposer,
          $$TaskRemindersTableCreateCompanionBuilder,
          $$TaskRemindersTableUpdateCompanionBuilder,
          (TaskReminder, $$TaskRemindersTableReferences),
          TaskReminder,
          PrefetchHooks Function({bool taskId})
        > {
  $$TaskRemindersTableTableManager(_$AppDatabase db, $TaskRemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskRemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskRemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<int> offset = const Value.absent(),
                Value<String?> reminderTime = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskRemindersCompanion(
                id: id,
                taskId: taskId,
                offset: offset,
                reminderTime: reminderTime,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required int offset,
                Value<String?> reminderTime = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskRemindersCompanion.insert(
                id: id,
                taskId: taskId,
                offset: offset,
                reminderTime: reminderTime,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TaskRemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
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
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable: $$TaskRemindersTableReferences
                                    ._taskIdTable(db),
                                referencedColumn: $$TaskRemindersTableReferences
                                    ._taskIdTable(db)
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

typedef $$TaskRemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskRemindersTable,
      TaskReminder,
      $$TaskRemindersTableFilterComposer,
      $$TaskRemindersTableOrderingComposer,
      $$TaskRemindersTableAnnotationComposer,
      $$TaskRemindersTableCreateCompanionBuilder,
      $$TaskRemindersTableUpdateCompanionBuilder,
      (TaskReminder, $$TaskRemindersTableReferences),
      TaskReminder,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      required String id,
      required String userId,
      Value<String?> areaId,
      Value<String?> userPlantId,
      required DateTime date,
      required String content,
      Value<String?> weather,
      required DateTime updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> areaId,
      Value<String?> userPlantId,
      Value<DateTime> date,
      Value<String> content,
      Value<String?> weather,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, Note> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AreasTable _areaIdTable(_$AppDatabase db) =>
      db.areas.createAlias($_aliasNameGenerator(db.notes.areaId, db.areas.id));

  $$AreasTableProcessedTableManager? get areaId {
    final $_column = $_itemColumn<String>('area_id');
    if ($_column == null) return null;
    final manager = $$AreasTableTableManager(
      $_db,
      $_db.areas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_areaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UserPlantsTable _userPlantIdTable(_$AppDatabase db) =>
      db.userPlants.createAlias(
        $_aliasNameGenerator(db.notes.userPlantId, db.userPlants.id),
      );

  $$UserPlantsTableProcessedTableManager? get userPlantId {
    final $_column = $_itemColumn<String>('user_plant_id');
    if ($_column == null) return null;
    final manager = $$UserPlantsTableTableManager(
      $_db,
      $_db.userPlants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userPlantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weather => $composableBuilder(
    column: $table.weather,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$AreasTableFilterComposer get areaId {
    final $$AreasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.areaId,
      referencedTable: $db.areas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AreasTableFilterComposer(
            $db: $db,
            $table: $db.areas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UserPlantsTableFilterComposer get userPlantId {
    final $$UserPlantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userPlantId,
      referencedTable: $db.userPlants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPlantsTableFilterComposer(
            $db: $db,
            $table: $db.userPlants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weather => $composableBuilder(
    column: $table.weather,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$AreasTableOrderingComposer get areaId {
    final $$AreasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.areaId,
      referencedTable: $db.areas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AreasTableOrderingComposer(
            $db: $db,
            $table: $db.areas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UserPlantsTableOrderingComposer get userPlantId {
    final $$UserPlantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userPlantId,
      referencedTable: $db.userPlants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPlantsTableOrderingComposer(
            $db: $db,
            $table: $db.userPlants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get weather =>
      $composableBuilder(column: $table.weather, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$AreasTableAnnotationComposer get areaId {
    final $$AreasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.areaId,
      referencedTable: $db.areas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AreasTableAnnotationComposer(
            $db: $db,
            $table: $db.areas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UserPlantsTableAnnotationComposer get userPlantId {
    final $$UserPlantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userPlantId,
      referencedTable: $db.userPlants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPlantsTableAnnotationComposer(
            $db: $db,
            $table: $db.userPlants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, $$NotesTableReferences),
          Note,
          PrefetchHooks Function({bool areaId, bool userPlantId})
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> areaId = const Value.absent(),
                Value<String?> userPlantId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> weather = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                userId: userId,
                areaId: areaId,
                userPlantId: userPlantId,
                date: date,
                content: content,
                weather: weather,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> areaId = const Value.absent(),
                Value<String?> userPlantId = const Value.absent(),
                required DateTime date,
                required String content,
                Value<String?> weather = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                userId: userId,
                areaId: areaId,
                userPlantId: userPlantId,
                date: date,
                content: content,
                weather: weather,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$NotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({areaId = false, userPlantId = false}) {
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
                    if (areaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.areaId,
                                referencedTable: $$NotesTableReferences
                                    ._areaIdTable(db),
                                referencedColumn: $$NotesTableReferences
                                    ._areaIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (userPlantId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userPlantId,
                                referencedTable: $$NotesTableReferences
                                    ._userPlantIdTable(db),
                                referencedColumn: $$NotesTableReferences
                                    ._userPlantIdTable(db)
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

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, $$NotesTableReferences),
      Note,
      PrefetchHooks Function({bool areaId, bool userPlantId})
    >;
typedef $$SuppliesTableCreateCompanionBuilder =
    SuppliesCompanion Function({
      required String id,
      required String userId,
      required String name,
      Value<String?> unit,
      Value<SupplyCategory> category,
      Value<double> quantity,
      Value<double?> lowThreshold,
      required DateTime updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$SuppliesTableUpdateCompanionBuilder =
    SuppliesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String?> unit,
      Value<SupplyCategory> category,
      Value<double> quantity,
      Value<double?> lowThreshold,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$SuppliesTableReferences
    extends BaseReferences<_$AppDatabase, $SuppliesTable, Supply> {
  $$SuppliesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TaskSuppliesTable, List<TaskSupply>>
  _taskSuppliesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.taskSupplies,
    aliasName: $_aliasNameGenerator(db.supplies.id, db.taskSupplies.supplyId),
  );

  $$TaskSuppliesTableProcessedTableManager get taskSuppliesRefs {
    final manager = $$TaskSuppliesTableTableManager(
      $_db,
      $_db.taskSupplies,
    ).filter((f) => f.supplyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskSuppliesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SuppliesTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliesTable> {
  $$SuppliesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SupplyCategory, SupplyCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lowThreshold => $composableBuilder(
    column: $table.lowThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> taskSuppliesRefs(
    Expression<bool> Function($$TaskSuppliesTableFilterComposer f) f,
  ) {
    final $$TaskSuppliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSupplies,
      getReferencedColumn: (t) => t.supplyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSuppliesTableFilterComposer(
            $db: $db,
            $table: $db.taskSupplies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliesTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliesTable> {
  $$SuppliesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lowThreshold => $composableBuilder(
    column: $table.lowThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuppliesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliesTable> {
  $$SuppliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SupplyCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get lowThreshold => $composableBuilder(
    column: $table.lowThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  Expression<T> taskSuppliesRefs<T extends Object>(
    Expression<T> Function($$TaskSuppliesTableAnnotationComposer a) f,
  ) {
    final $$TaskSuppliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSupplies,
      getReferencedColumn: (t) => t.supplyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskSuppliesTableAnnotationComposer(
            $db: $db,
            $table: $db.taskSupplies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuppliesTable,
          Supply,
          $$SuppliesTableFilterComposer,
          $$SuppliesTableOrderingComposer,
          $$SuppliesTableAnnotationComposer,
          $$SuppliesTableCreateCompanionBuilder,
          $$SuppliesTableUpdateCompanionBuilder,
          (Supply, $$SuppliesTableReferences),
          Supply,
          PrefetchHooks Function({bool taskSuppliesRefs})
        > {
  $$SuppliesTableTableManager(_$AppDatabase db, $SuppliesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<SupplyCategory> category = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double?> lowThreshold = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliesCompanion(
                id: id,
                userId: userId,
                name: name,
                unit: unit,
                category: category,
                quantity: quantity,
                lowThreshold: lowThreshold,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                Value<String?> unit = const Value.absent(),
                Value<SupplyCategory> category = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double?> lowThreshold = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliesCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                unit: unit,
                category: category,
                quantity: quantity,
                lowThreshold: lowThreshold,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SuppliesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskSuppliesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (taskSuppliesRefs) db.taskSupplies],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskSuppliesRefs)
                    await $_getPrefetchedData<
                      Supply,
                      $SuppliesTable,
                      TaskSupply
                    >(
                      currentTable: table,
                      referencedTable: $$SuppliesTableReferences
                          ._taskSuppliesRefsTable(db),
                      managerFromTypedResult: (p0) => $$SuppliesTableReferences(
                        db,
                        table,
                        p0,
                      ).taskSuppliesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.supplyId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SuppliesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuppliesTable,
      Supply,
      $$SuppliesTableFilterComposer,
      $$SuppliesTableOrderingComposer,
      $$SuppliesTableAnnotationComposer,
      $$SuppliesTableCreateCompanionBuilder,
      $$SuppliesTableUpdateCompanionBuilder,
      (Supply, $$SuppliesTableReferences),
      Supply,
      PrefetchHooks Function({bool taskSuppliesRefs})
    >;
typedef $$RecipesTableCreateCompanionBuilder =
    RecipesCompanion Function({
      required String id,
      required String userId,
      required String name,
      Value<String?> equipment,
      Value<String?> items,
      required DateTime updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$RecipesTableUpdateCompanionBuilder =
    RecipesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String?> equipment,
      Value<String?> items,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$RecipesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get items => $composableBuilder(
    column: $table.items,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get items => $composableBuilder(
    column: $table.items,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<String> get items =>
      $composableBuilder(column: $table.items, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$RecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipesTable,
          Recipe,
          $$RecipesTableFilterComposer,
          $$RecipesTableOrderingComposer,
          $$RecipesTableAnnotationComposer,
          $$RecipesTableCreateCompanionBuilder,
          $$RecipesTableUpdateCompanionBuilder,
          (Recipe, BaseReferences<_$AppDatabase, $RecipesTable, Recipe>),
          Recipe,
          PrefetchHooks Function()
        > {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> equipment = const Value.absent(),
                Value<String?> items = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion(
                id: id,
                userId: userId,
                name: name,
                equipment: equipment,
                items: items,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                Value<String?> equipment = const Value.absent(),
                Value<String?> items = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                equipment: equipment,
                items: items,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipesTable,
      Recipe,
      $$RecipesTableFilterComposer,
      $$RecipesTableOrderingComposer,
      $$RecipesTableAnnotationComposer,
      $$RecipesTableCreateCompanionBuilder,
      $$RecipesTableUpdateCompanionBuilder,
      (Recipe, BaseReferences<_$AppDatabase, $RecipesTable, Recipe>),
      Recipe,
      PrefetchHooks Function()
    >;
typedef $$TaskSuppliesTableCreateCompanionBuilder =
    TaskSuppliesCompanion Function({
      required String id,
      required String taskId,
      required String supplyId,
      required double amount,
      Value<bool> applied,
      required DateTime updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$TaskSuppliesTableUpdateCompanionBuilder =
    TaskSuppliesCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<String> supplyId,
      Value<double> amount,
      Value<bool> applied,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> syncStatus,
      Value<int> rowid,
    });

final class $$TaskSuppliesTableReferences
    extends BaseReferences<_$AppDatabase, $TaskSuppliesTable, TaskSupply> {
  $$TaskSuppliesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks.createAlias(
    $_aliasNameGenerator(db.taskSupplies.taskId, db.tasks.id),
  );

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SuppliesTable _supplyIdTable(_$AppDatabase db) =>
      db.supplies.createAlias(
        $_aliasNameGenerator(db.taskSupplies.supplyId, db.supplies.id),
      );

  $$SuppliesTableProcessedTableManager get supplyId {
    final $_column = $_itemColumn<String>('supply_id')!;

    final manager = $$SuppliesTableTableManager(
      $_db,
      $_db.supplies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TaskSuppliesTableFilterComposer
    extends Composer<_$AppDatabase, $TaskSuppliesTable> {
  $$TaskSuppliesTableFilterComposer({
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

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get applied => $composableBuilder(
    column: $table.applied,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SuppliesTableFilterComposer get supplyId {
    final $$SuppliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplyId,
      referencedTable: $db.supplies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliesTableFilterComposer(
            $db: $db,
            $table: $db.supplies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskSuppliesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskSuppliesTable> {
  $$TaskSuppliesTableOrderingComposer({
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

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get applied => $composableBuilder(
    column: $table.applied,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SuppliesTableOrderingComposer get supplyId {
    final $$SuppliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplyId,
      referencedTable: $db.supplies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliesTableOrderingComposer(
            $db: $db,
            $table: $db.supplies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskSuppliesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskSuppliesTable> {
  $$TaskSuppliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get applied =>
      $composableBuilder(column: $table.applied, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SuppliesTableAnnotationComposer get supplyId {
    final $$SuppliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplyId,
      referencedTable: $db.supplies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliesTableAnnotationComposer(
            $db: $db,
            $table: $db.supplies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskSuppliesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskSuppliesTable,
          TaskSupply,
          $$TaskSuppliesTableFilterComposer,
          $$TaskSuppliesTableOrderingComposer,
          $$TaskSuppliesTableAnnotationComposer,
          $$TaskSuppliesTableCreateCompanionBuilder,
          $$TaskSuppliesTableUpdateCompanionBuilder,
          (TaskSupply, $$TaskSuppliesTableReferences),
          TaskSupply,
          PrefetchHooks Function({bool taskId, bool supplyId})
        > {
  $$TaskSuppliesTableTableManager(_$AppDatabase db, $TaskSuppliesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskSuppliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskSuppliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskSuppliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> supplyId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<bool> applied = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskSuppliesCompanion(
                id: id,
                taskId: taskId,
                supplyId: supplyId,
                amount: amount,
                applied: applied,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required String supplyId,
                required double amount,
                Value<bool> applied = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskSuppliesCompanion.insert(
                id: id,
                taskId: taskId,
                supplyId: supplyId,
                amount: amount,
                applied: applied,
                updatedAt: updatedAt,
                deleted: deleted,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TaskSuppliesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false, supplyId = false}) {
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
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable: $$TaskSuppliesTableReferences
                                    ._taskIdTable(db),
                                referencedColumn: $$TaskSuppliesTableReferences
                                    ._taskIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (supplyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.supplyId,
                                referencedTable: $$TaskSuppliesTableReferences
                                    ._supplyIdTable(db),
                                referencedColumn: $$TaskSuppliesTableReferences
                                    ._supplyIdTable(db)
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

typedef $$TaskSuppliesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskSuppliesTable,
      TaskSupply,
      $$TaskSuppliesTableFilterComposer,
      $$TaskSuppliesTableOrderingComposer,
      $$TaskSuppliesTableAnnotationComposer,
      $$TaskSuppliesTableCreateCompanionBuilder,
      $$TaskSuppliesTableUpdateCompanionBuilder,
      (TaskSupply, $$TaskSuppliesTableReferences),
      TaskSupply,
      PrefetchHooks Function({bool taskId, bool supplyId})
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String name,
      required DateTime lastPulledAt,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> name,
      Value<DateTime> lastPulledAt,
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
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
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
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
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
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => column,
  );
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursor,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursor,
            BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
          ),
          SyncCursor,
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
                Value<String> name = const Value.absent(),
                Value<DateTime> lastPulledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                name: name,
                lastPulledAt: lastPulledAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required DateTime lastPulledAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                name: name,
                lastPulledAt: lastPulledAt,
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
      SyncCursor,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursor,
        BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
      ),
      SyncCursor,
      PrefetchHooks Function()
    >;
typedef $$LocalFlagsTableCreateCompanionBuilder =
    LocalFlagsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$LocalFlagsTableUpdateCompanionBuilder =
    LocalFlagsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$LocalFlagsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalFlagsTable> {
  $$LocalFlagsTableFilterComposer({
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

class $$LocalFlagsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalFlagsTable> {
  $$LocalFlagsTableOrderingComposer({
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

class $$LocalFlagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalFlagsTable> {
  $$LocalFlagsTableAnnotationComposer({
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

class $$LocalFlagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalFlagsTable,
          LocalFlag,
          $$LocalFlagsTableFilterComposer,
          $$LocalFlagsTableOrderingComposer,
          $$LocalFlagsTableAnnotationComposer,
          $$LocalFlagsTableCreateCompanionBuilder,
          $$LocalFlagsTableUpdateCompanionBuilder,
          (
            LocalFlag,
            BaseReferences<_$AppDatabase, $LocalFlagsTable, LocalFlag>,
          ),
          LocalFlag,
          PrefetchHooks Function()
        > {
  $$LocalFlagsTableTableManager(_$AppDatabase db, $LocalFlagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFlagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFlagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalFlagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalFlagsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => LocalFlagsCompanion.insert(
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

typedef $$LocalFlagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalFlagsTable,
      LocalFlag,
      $$LocalFlagsTableFilterComposer,
      $$LocalFlagsTableOrderingComposer,
      $$LocalFlagsTableAnnotationComposer,
      $$LocalFlagsTableCreateCompanionBuilder,
      $$LocalFlagsTableUpdateCompanionBuilder,
      (LocalFlag, BaseReferences<_$AppDatabase, $LocalFlagsTable, LocalFlag>),
      LocalFlag,
      PrefetchHooks Function()
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
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$AreasTableTableManager get areas =>
      $$AreasTableTableManager(_db, _db.areas);
  $$UserPlantsTableTableManager get userPlants =>
      $$UserPlantsTableTableManager(_db, _db.userPlants);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$TaskSubjectsTableTableManager get taskSubjects =>
      $$TaskSubjectsTableTableManager(_db, _db.taskSubjects);
  $$TaskRemindersTableTableManager get taskReminders =>
      $$TaskRemindersTableTableManager(_db, _db.taskReminders);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$SuppliesTableTableManager get supplies =>
      $$SuppliesTableTableManager(_db, _db.supplies);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$TaskSuppliesTableTableManager get taskSupplies =>
      $$TaskSuppliesTableTableManager(_db, _db.taskSupplies);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$LocalFlagsTableTableManager get localFlags =>
      $$LocalFlagsTableTableManager(_db, _db.localFlags);
}
