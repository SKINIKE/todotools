// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: Constant(DateTime.now()));
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isPinnedMeta =
      const VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
      'is_pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        createdAt,
        dueDate,
        isCompleted,
        isPinned,
        category,
        priority
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('is_pinned')) {
      context.handle(_isPinnedMeta,
          isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {id},
      ];
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      isPinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pinned'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority']),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool isCompleted;
  final bool isPinned;
  final String? category;
  final String? priority;
  const Task(
      {required this.id,
      required this.title,
      this.description,
      required this.createdAt,
      this.dueDate,
      required this.isCompleted,
      required this.isPinned,
      this.category,
      this.priority});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['is_pinned'] = Variable<bool>(isPinned);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<String>(priority);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      isCompleted: Value(isCompleted),
      isPinned: Value(isPinned),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      category: serializer.fromJson<String?>(json['category']),
      priority: serializer.fromJson<String?>(json['priority']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'isPinned': serializer.toJson<bool>(isPinned),
      'category': serializer.toJson<String?>(category),
      'priority': serializer.toJson<String?>(priority),
    };
  }

  Task copyWith(
          {int? id,
          String? title,
          Value<String?> description = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> dueDate = const Value.absent(),
          bool? isCompleted,
          bool? isPinned,
          Value<String?> category = const Value.absent(),
          Value<String?> priority = const Value.absent()}) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        createdAt: createdAt ?? this.createdAt,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        isCompleted: isCompleted ?? this.isCompleted,
        isPinned: isPinned ?? this.isPinned,
        category: category.present ? category.value : this.category,
        priority: priority.present ? priority.value : this.priority,
      );
  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isPinned: $isPinned, ')
          ..write('category: $category, ')
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, createdAt, dueDate,
      isCompleted, isPinned, category, priority);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.dueDate == this.dueDate &&
          other.isCompleted == this.isCompleted &&
          other.isPinned == this.isPinned &&
          other.category == this.category &&
          other.priority == this.priority);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime?> dueDate;
  final Value<bool> isCompleted;
  final Value<bool> isPinned;
  final Value<String?> category;
  final Value<String?> priority;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.category = const Value.absent(),
    this.priority = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.category = const Value.absent(),
    this.priority = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? dueDate,
    Expression<bool>? isCompleted,
    Expression<bool>? isPinned,
    Expression<String>? category,
    Expression<String>? priority,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (dueDate != null) 'due_date': dueDate,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (isPinned != null) 'is_pinned': isPinned,
      if (category != null) 'category': category,
      if (priority != null) 'priority': priority,
    });
  }

  TasksCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<DateTime>? createdAt,
      Value<DateTime?>? dueDate,
      Value<bool>? isCompleted,
      Value<bool>? isPinned,
      Value<String?>? category,
      Value<String?>? priority}) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isPinned: isPinned ?? this.isPinned,
      category: category ?? this.category,
      priority: priority ?? this.priority,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isPinned: $isPinned, ')
          ..write('category: $category, ')
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }
}

class $PomodoroSettingsTable extends PomodoroSettings
    with TableInfo<$PomodoroSettingsTable, PomodoroSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PomodoroSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _focusMinutesMeta =
      const VerificationMeta('focusMinutes');
  @override
  late final GeneratedColumn<int> focusMinutes = GeneratedColumn<int>(
      'focus_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(25));
  static const VerificationMeta _restMinutesMeta =
      const VerificationMeta('restMinutes');
  @override
  late final GeneratedColumn<int> restMinutes = GeneratedColumn<int>(
      'rest_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _longRestMinutesMeta =
      const VerificationMeta('longRestMinutes');
  @override
  late final GeneratedColumn<int> longRestMinutes = GeneratedColumn<int>(
      'long_rest_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(15));
  static const VerificationMeta _longRestIntervalMeta =
      const VerificationMeta('longRestInterval');
  @override
  late final GeneratedColumn<int> longRestInterval = GeneratedColumn<int>(
      'long_rest_interval', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(4));
  static const VerificationMeta _autoStartNextSessionMeta =
      const VerificationMeta('autoStartNextSession');
  @override
  late final GeneratedColumn<bool> autoStartNextSession = GeneratedColumn<bool>(
      'auto_start_next_session', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_start_next_session" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _playSoundMeta =
      const VerificationMeta('playSound');
  @override
  late final GeneratedColumn<bool> playSound = GeneratedColumn<bool>(
      'play_sound', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("play_sound" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _focusColorHexMeta =
      const VerificationMeta('focusColorHex');
  @override
  late final GeneratedColumn<String> focusColorHex = GeneratedColumn<String>(
      'focus_color_hex', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('FFC8C8'));
  static const VerificationMeta _restColorHexMeta =
      const VerificationMeta('restColorHex');
  @override
  late final GeneratedColumn<String> restColorHex = GeneratedColumn<String>(
      'rest_color_hex', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('D1EAC8'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: Constant(DateTime.now()));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: Constant(DateTime.now()));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        focusMinutes,
        restMinutes,
        longRestMinutes,
        longRestInterval,
        autoStartNextSession,
        playSound,
        focusColorHex,
        restColorHex,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pomodoro_settings';
  @override
  VerificationContext validateIntegrity(Insertable<PomodoroSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('focus_minutes')) {
      context.handle(
          _focusMinutesMeta,
          focusMinutes.isAcceptableOrUnknown(
              data['focus_minutes']!, _focusMinutesMeta));
    }
    if (data.containsKey('rest_minutes')) {
      context.handle(
          _restMinutesMeta,
          restMinutes.isAcceptableOrUnknown(
              data['rest_minutes']!, _restMinutesMeta));
    }
    if (data.containsKey('long_rest_minutes')) {
      context.handle(
          _longRestMinutesMeta,
          longRestMinutes.isAcceptableOrUnknown(
              data['long_rest_minutes']!, _longRestMinutesMeta));
    }
    if (data.containsKey('long_rest_interval')) {
      context.handle(
          _longRestIntervalMeta,
          longRestInterval.isAcceptableOrUnknown(
              data['long_rest_interval']!, _longRestIntervalMeta));
    }
    if (data.containsKey('auto_start_next_session')) {
      context.handle(
          _autoStartNextSessionMeta,
          autoStartNextSession.isAcceptableOrUnknown(
              data['auto_start_next_session']!, _autoStartNextSessionMeta));
    }
    if (data.containsKey('play_sound')) {
      context.handle(_playSoundMeta,
          playSound.isAcceptableOrUnknown(data['play_sound']!, _playSoundMeta));
    }
    if (data.containsKey('focus_color_hex')) {
      context.handle(
          _focusColorHexMeta,
          focusColorHex.isAcceptableOrUnknown(
              data['focus_color_hex']!, _focusColorHexMeta));
    }
    if (data.containsKey('rest_color_hex')) {
      context.handle(
          _restColorHexMeta,
          restColorHex.isAcceptableOrUnknown(
              data['rest_color_hex']!, _restColorHexMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {id},
      ];
  @override
  PomodoroSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PomodoroSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      focusMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}focus_minutes'])!,
      restMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rest_minutes'])!,
      longRestMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}long_rest_minutes'])!,
      longRestInterval: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}long_rest_interval'])!,
      autoStartNextSession: attachedDatabase.typeMapping.read(DriftSqlType.bool,
          data['${effectivePrefix}auto_start_next_session'])!,
      playSound: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}play_sound'])!,
      focusColorHex: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}focus_color_hex'])!,
      restColorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rest_color_hex'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PomodoroSettingsTable createAlias(String alias) {
    return $PomodoroSettingsTable(attachedDatabase, alias);
  }
}

class PomodoroSetting extends DataClass implements Insertable<PomodoroSetting> {
  final int id;
  final int focusMinutes;
  final int restMinutes;
  final int longRestMinutes;
  final int longRestInterval;
  final bool autoStartNextSession;
  final bool playSound;
  final String focusColorHex;
  final String restColorHex;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PomodoroSetting(
      {required this.id,
      required this.focusMinutes,
      required this.restMinutes,
      required this.longRestMinutes,
      required this.longRestInterval,
      required this.autoStartNextSession,
      required this.playSound,
      required this.focusColorHex,
      required this.restColorHex,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['focus_minutes'] = Variable<int>(focusMinutes);
    map['rest_minutes'] = Variable<int>(restMinutes);
    map['long_rest_minutes'] = Variable<int>(longRestMinutes);
    map['long_rest_interval'] = Variable<int>(longRestInterval);
    map['auto_start_next_session'] = Variable<bool>(autoStartNextSession);
    map['play_sound'] = Variable<bool>(playSound);
    map['focus_color_hex'] = Variable<String>(focusColorHex);
    map['rest_color_hex'] = Variable<String>(restColorHex);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PomodoroSettingsCompanion toCompanion(bool nullToAbsent) {
    return PomodoroSettingsCompanion(
      id: Value(id),
      focusMinutes: Value(focusMinutes),
      restMinutes: Value(restMinutes),
      longRestMinutes: Value(longRestMinutes),
      longRestInterval: Value(longRestInterval),
      autoStartNextSession: Value(autoStartNextSession),
      playSound: Value(playSound),
      focusColorHex: Value(focusColorHex),
      restColorHex: Value(restColorHex),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PomodoroSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PomodoroSetting(
      id: serializer.fromJson<int>(json['id']),
      focusMinutes: serializer.fromJson<int>(json['focusMinutes']),
      restMinutes: serializer.fromJson<int>(json['restMinutes']),
      longRestMinutes: serializer.fromJson<int>(json['longRestMinutes']),
      longRestInterval: serializer.fromJson<int>(json['longRestInterval']),
      autoStartNextSession:
          serializer.fromJson<bool>(json['autoStartNextSession']),
      playSound: serializer.fromJson<bool>(json['playSound']),
      focusColorHex: serializer.fromJson<String>(json['focusColorHex']),
      restColorHex: serializer.fromJson<String>(json['restColorHex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'focusMinutes': serializer.toJson<int>(focusMinutes),
      'restMinutes': serializer.toJson<int>(restMinutes),
      'longRestMinutes': serializer.toJson<int>(longRestMinutes),
      'longRestInterval': serializer.toJson<int>(longRestInterval),
      'autoStartNextSession': serializer.toJson<bool>(autoStartNextSession),
      'playSound': serializer.toJson<bool>(playSound),
      'focusColorHex': serializer.toJson<String>(focusColorHex),
      'restColorHex': serializer.toJson<String>(restColorHex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PomodoroSetting copyWith(
          {int? id,
          int? focusMinutes,
          int? restMinutes,
          int? longRestMinutes,
          int? longRestInterval,
          bool? autoStartNextSession,
          bool? playSound,
          String? focusColorHex,
          String? restColorHex,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      PomodoroSetting(
        id: id ?? this.id,
        focusMinutes: focusMinutes ?? this.focusMinutes,
        restMinutes: restMinutes ?? this.restMinutes,
        longRestMinutes: longRestMinutes ?? this.longRestMinutes,
        longRestInterval: longRestInterval ?? this.longRestInterval,
        autoStartNextSession: autoStartNextSession ?? this.autoStartNextSession,
        playSound: playSound ?? this.playSound,
        focusColorHex: focusColorHex ?? this.focusColorHex,
        restColorHex: restColorHex ?? this.restColorHex,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  @override
  String toString() {
    return (StringBuffer('PomodoroSetting(')
          ..write('id: $id, ')
          ..write('focusMinutes: $focusMinutes, ')
          ..write('restMinutes: $restMinutes, ')
          ..write('longRestMinutes: $longRestMinutes, ')
          ..write('longRestInterval: $longRestInterval, ')
          ..write('autoStartNextSession: $autoStartNextSession, ')
          ..write('playSound: $playSound, ')
          ..write('focusColorHex: $focusColorHex, ')
          ..write('restColorHex: $restColorHex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      focusMinutes,
      restMinutes,
      longRestMinutes,
      longRestInterval,
      autoStartNextSession,
      playSound,
      focusColorHex,
      restColorHex,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PomodoroSetting &&
          other.id == this.id &&
          other.focusMinutes == this.focusMinutes &&
          other.restMinutes == this.restMinutes &&
          other.longRestMinutes == this.longRestMinutes &&
          other.longRestInterval == this.longRestInterval &&
          other.autoStartNextSession == this.autoStartNextSession &&
          other.playSound == this.playSound &&
          other.focusColorHex == this.focusColorHex &&
          other.restColorHex == this.restColorHex &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PomodoroSettingsCompanion extends UpdateCompanion<PomodoroSetting> {
  final Value<int> id;
  final Value<int> focusMinutes;
  final Value<int> restMinutes;
  final Value<int> longRestMinutes;
  final Value<int> longRestInterval;
  final Value<bool> autoStartNextSession;
  final Value<bool> playSound;
  final Value<String> focusColorHex;
  final Value<String> restColorHex;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PomodoroSettingsCompanion({
    this.id = const Value.absent(),
    this.focusMinutes = const Value.absent(),
    this.restMinutes = const Value.absent(),
    this.longRestMinutes = const Value.absent(),
    this.longRestInterval = const Value.absent(),
    this.autoStartNextSession = const Value.absent(),
    this.playSound = const Value.absent(),
    this.focusColorHex = const Value.absent(),
    this.restColorHex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PomodoroSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.focusMinutes = const Value.absent(),
    this.restMinutes = const Value.absent(),
    this.longRestMinutes = const Value.absent(),
    this.longRestInterval = const Value.absent(),
    this.autoStartNextSession = const Value.absent(),
    this.playSound = const Value.absent(),
    this.focusColorHex = const Value.absent(),
    this.restColorHex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<PomodoroSetting> custom({
    Expression<int>? id,
    Expression<int>? focusMinutes,
    Expression<int>? restMinutes,
    Expression<int>? longRestMinutes,
    Expression<int>? longRestInterval,
    Expression<bool>? autoStartNextSession,
    Expression<bool>? playSound,
    Expression<String>? focusColorHex,
    Expression<String>? restColorHex,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (focusMinutes != null) 'focus_minutes': focusMinutes,
      if (restMinutes != null) 'rest_minutes': restMinutes,
      if (longRestMinutes != null) 'long_rest_minutes': longRestMinutes,
      if (longRestInterval != null) 'long_rest_interval': longRestInterval,
      if (autoStartNextSession != null)
        'auto_start_next_session': autoStartNextSession,
      if (playSound != null) 'play_sound': playSound,
      if (focusColorHex != null) 'focus_color_hex': focusColorHex,
      if (restColorHex != null) 'rest_color_hex': restColorHex,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PomodoroSettingsCompanion copyWith(
      {Value<int>? id,
      Value<int>? focusMinutes,
      Value<int>? restMinutes,
      Value<int>? longRestMinutes,
      Value<int>? longRestInterval,
      Value<bool>? autoStartNextSession,
      Value<bool>? playSound,
      Value<String>? focusColorHex,
      Value<String>? restColorHex,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return PomodoroSettingsCompanion(
      id: id ?? this.id,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      restMinutes: restMinutes ?? this.restMinutes,
      longRestMinutes: longRestMinutes ?? this.longRestMinutes,
      longRestInterval: longRestInterval ?? this.longRestInterval,
      autoStartNextSession: autoStartNextSession ?? this.autoStartNextSession,
      playSound: playSound ?? this.playSound,
      focusColorHex: focusColorHex ?? this.focusColorHex,
      restColorHex: restColorHex ?? this.restColorHex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (focusMinutes.present) {
      map['focus_minutes'] = Variable<int>(focusMinutes.value);
    }
    if (restMinutes.present) {
      map['rest_minutes'] = Variable<int>(restMinutes.value);
    }
    if (longRestMinutes.present) {
      map['long_rest_minutes'] = Variable<int>(longRestMinutes.value);
    }
    if (longRestInterval.present) {
      map['long_rest_interval'] = Variable<int>(longRestInterval.value);
    }
    if (autoStartNextSession.present) {
      map['auto_start_next_session'] =
          Variable<bool>(autoStartNextSession.value);
    }
    if (playSound.present) {
      map['play_sound'] = Variable<bool>(playSound.value);
    }
    if (focusColorHex.present) {
      map['focus_color_hex'] = Variable<String>(focusColorHex.value);
    }
    if (restColorHex.present) {
      map['rest_color_hex'] = Variable<String>(restColorHex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PomodoroSettingsCompanion(')
          ..write('id: $id, ')
          ..write('focusMinutes: $focusMinutes, ')
          ..write('restMinutes: $restMinutes, ')
          ..write('longRestMinutes: $longRestMinutes, ')
          ..write('longRestInterval: $longRestInterval, ')
          ..write('autoStartNextSession: $autoStartNextSession, ')
          ..write('playSound: $playSound, ')
          ..write('focusColorHex: $focusColorHex, ')
          ..write('restColorHex: $restColorHex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CalculatorHistoryTable extends CalculatorHistory
    with TableInfo<$CalculatorHistoryTable, CalculatorHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalculatorHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _expressionMeta =
      const VerificationMeta('expression');
  @override
  late final GeneratedColumn<String> expression = GeneratedColumn<String>(
      'expression', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
      'result', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: Constant(DateTime.now()));
  @override
  List<GeneratedColumn> get $columns => [id, expression, result, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calculator_history';
  @override
  VerificationContext validateIntegrity(
      Insertable<CalculatorHistoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('expression')) {
      context.handle(
          _expressionMeta,
          expression.isAcceptableOrUnknown(
              data['expression']!, _expressionMeta));
    } else if (isInserting) {
      context.missing(_expressionMeta);
    }
    if (data.containsKey('result')) {
      context.handle(_resultMeta,
          result.isAcceptableOrUnknown(data['result']!, _resultMeta));
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {id},
      ];
  @override
  CalculatorHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalculatorHistoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      expression: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}expression'])!,
      result: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CalculatorHistoryTable createAlias(String alias) {
    return $CalculatorHistoryTable(attachedDatabase, alias);
  }
}

class CalculatorHistoryData extends DataClass
    implements Insertable<CalculatorHistoryData> {
  final int id;
  final String expression;
  final String result;
  final DateTime createdAt;
  const CalculatorHistoryData(
      {required this.id,
      required this.expression,
      required this.result,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['expression'] = Variable<String>(expression);
    map['result'] = Variable<String>(result);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CalculatorHistoryCompanion toCompanion(bool nullToAbsent) {
    return CalculatorHistoryCompanion(
      id: Value(id),
      expression: Value(expression),
      result: Value(result),
      createdAt: Value(createdAt),
    );
  }

  factory CalculatorHistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalculatorHistoryData(
      id: serializer.fromJson<int>(json['id']),
      expression: serializer.fromJson<String>(json['expression']),
      result: serializer.fromJson<String>(json['result']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'expression': serializer.toJson<String>(expression),
      'result': serializer.toJson<String>(result),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CalculatorHistoryData copyWith(
          {int? id, String? expression, String? result, DateTime? createdAt}) =>
      CalculatorHistoryData(
        id: id ?? this.id,
        expression: expression ?? this.expression,
        result: result ?? this.result,
        createdAt: createdAt ?? this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('CalculatorHistoryData(')
          ..write('id: $id, ')
          ..write('expression: $expression, ')
          ..write('result: $result, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, expression, result, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalculatorHistoryData &&
          other.id == this.id &&
          other.expression == this.expression &&
          other.result == this.result &&
          other.createdAt == this.createdAt);
}

class CalculatorHistoryCompanion
    extends UpdateCompanion<CalculatorHistoryData> {
  final Value<int> id;
  final Value<String> expression;
  final Value<String> result;
  final Value<DateTime> createdAt;
  const CalculatorHistoryCompanion({
    this.id = const Value.absent(),
    this.expression = const Value.absent(),
    this.result = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CalculatorHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String expression,
    required String result,
    this.createdAt = const Value.absent(),
  })  : expression = Value(expression),
        result = Value(result);
  static Insertable<CalculatorHistoryData> custom({
    Expression<int>? id,
    Expression<String>? expression,
    Expression<String>? result,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (expression != null) 'expression': expression,
      if (result != null) 'result': result,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CalculatorHistoryCompanion copyWith(
      {Value<int>? id,
      Value<String>? expression,
      Value<String>? result,
      Value<DateTime>? createdAt}) {
    return CalculatorHistoryCompanion(
      id: id ?? this.id,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (expression.present) {
      map['expression'] = Variable<String>(expression.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalculatorHistoryCompanion(')
          ..write('id: $id, ')
          ..write('expression: $expression, ')
          ..write('result: $result, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $StickyNotesTable extends StickyNotes
    with TableInfo<$StickyNotesTable, StickyNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StickyNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(StickyNoteColor.defaultValue));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: Constant(DateTime.now()));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: Constant(DateTime.now()));
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, content, color, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sticky_notes';
  @override
  VerificationContext validateIntegrity(Insertable<StickyNote> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {id},
      ];
  @override
  StickyNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StickyNote(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $StickyNotesTable createAlias(String alias) {
    return $StickyNotesTable(attachedDatabase, alias);
  }
}

class StickyNote extends DataClass implements Insertable<StickyNote> {
  final int id;
  final String title;
  final String content;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;
  const StickyNote(
      {required this.id,
      required this.title,
      required this.content,
      required this.color,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['color'] = Variable<String>(color);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StickyNotesCompanion toCompanion(bool nullToAbsent) {
    return StickyNotesCompanion(
      id: Value(id),
      title: Value(title),
      content: Value(content),
      color: Value(color),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory StickyNote.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StickyNote(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      color: serializer.fromJson<String>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'color': serializer.toJson<String>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StickyNote copyWith(
          {int? id,
          String? title,
          String? content,
          String? color,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      StickyNote(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  @override
  String toString() {
    return (StringBuffer('StickyNote(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, content, color, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StickyNote &&
          other.id == this.id &&
          other.title == this.title &&
          other.content == this.content &&
          other.color == this.color &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StickyNotesCompanion extends UpdateCompanion<StickyNote> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> content;
  final Value<String> color;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const StickyNotesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  StickyNotesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String content,
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : title = Value(title),
        content = Value(content);
  static Insertable<StickyNote> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? color,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  StickyNotesCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? content,
      Value<String>? color,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return StickyNotesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StickyNotesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $TasksTable tasks = $TasksTable(this);
  late final $PomodoroSettingsTable pomodoroSettings =
      $PomodoroSettingsTable(this);
  late final $CalculatorHistoryTable calculatorHistory =
      $CalculatorHistoryTable(this);
  late final $StickyNotesTable stickyNotes = $StickyNotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [tasks, pomodoroSettings, calculatorHistory, stickyNotes];
}
