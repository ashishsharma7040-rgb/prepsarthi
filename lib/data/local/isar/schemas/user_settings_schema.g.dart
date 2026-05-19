// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserSettingsSchemaCollection on Isar {
  IsarCollection<UserSettingsSchema> get userSettingsSchemas =>
      this.collection();
}

const UserSettingsSchemaSchema = CollectionSchema(
  name: r'UserSettingsSchema',
  id: 6043819798327491665,
  properties: {
    r'appVersion': PropertySchema(
      id: 0,
      name: r'appVersion',
      type: IsarType.string,
    ),
    r'blackoutDates': PropertySchema(
      id: 1,
      name: r'blackoutDates',
      type: IsarType.dateTimeList,
    ),
    r'lastPlanGeneratedAt': PropertySchema(
      id: 2,
      name: r'lastPlanGeneratedAt',
      type: IsarType.dateTime,
    ),
    r'notificationTime': PropertySchema(
      id: 3,
      name: r'notificationTime',
      type: IsarType.string,
    ),
    r'notificationsEnabled': PropertySchema(
      id: 4,
      name: r'notificationsEnabled',
      type: IsarType.bool,
    ),
    r'pomodoroBreakMinutes': PropertySchema(
      id: 5,
      name: r'pomodoroBreakMinutes',
      type: IsarType.long,
    ),
    r'pomodoroCycles': PropertySchema(
      id: 6,
      name: r'pomodoroCycles',
      type: IsarType.long,
    ),
    r'pomodoroWorkMinutes': PropertySchema(
      id: 7,
      name: r'pomodoroWorkMinutes',
      type: IsarType.long,
    ),
    r'soundEnabled': PropertySchema(
      id: 8,
      name: r'soundEnabled',
      type: IsarType.bool,
    ),
    r'themeMode': PropertySchema(
      id: 9,
      name: r'themeMode',
      type: IsarType.string,
    ),
    r'vibrationEnabled': PropertySchema(
      id: 10,
      name: r'vibrationEnabled',
      type: IsarType.bool,
    )
  },
  estimateSize: _userSettingsSchemaEstimateSize,
  serialize: _userSettingsSchemaSerialize,
  deserialize: _userSettingsSchemaDeserialize,
  deserializeProp: _userSettingsSchemaDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userSettingsSchemaGetId,
  getLinks: _userSettingsSchemaGetLinks,
  attach: _userSettingsSchemaAttach,
  version: '3.1.0+1',
);

int _userSettingsSchemaEstimateSize(
  UserSettingsSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.appVersion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.blackoutDates.length * 8;
  bytesCount += 3 + object.notificationTime.length * 3;
  bytesCount += 3 + object.themeMode.length * 3;
  return bytesCount;
}

void _userSettingsSchemaSerialize(
  UserSettingsSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.appVersion);
  writer.writeDateTimeList(offsets[1], object.blackoutDates);
  writer.writeDateTime(offsets[2], object.lastPlanGeneratedAt);
  writer.writeString(offsets[3], object.notificationTime);
  writer.writeBool(offsets[4], object.notificationsEnabled);
  writer.writeLong(offsets[5], object.pomodoroBreakMinutes);
  writer.writeLong(offsets[6], object.pomodoroCycles);
  writer.writeLong(offsets[7], object.pomodoroWorkMinutes);
  writer.writeBool(offsets[8], object.soundEnabled);
  writer.writeString(offsets[9], object.themeMode);
  writer.writeBool(offsets[10], object.vibrationEnabled);
}

UserSettingsSchema _userSettingsSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserSettingsSchema();
  object.appVersion = reader.readStringOrNull(offsets[0]);
  object.blackoutDates = reader.readDateTimeList(offsets[1]) ?? [];
  object.id = id;
  object.lastPlanGeneratedAt = reader.readDateTimeOrNull(offsets[2]);
  object.notificationTime = reader.readString(offsets[3]);
  object.notificationsEnabled = reader.readBool(offsets[4]);
  object.pomodoroBreakMinutes = reader.readLong(offsets[5]);
  object.pomodoroCycles = reader.readLong(offsets[6]);
  object.pomodoroWorkMinutes = reader.readLong(offsets[7]);
  object.soundEnabled = reader.readBool(offsets[8]);
  object.themeMode = reader.readString(offsets[9]);
  object.vibrationEnabled = reader.readBool(offsets[10]);
  return object;
}

P _userSettingsSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeList(offset) ?? []) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userSettingsSchemaGetId(UserSettingsSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userSettingsSchemaGetLinks(
    UserSettingsSchema object) {
  return [];
}

void _userSettingsSchemaAttach(
    IsarCollection<dynamic> col, Id id, UserSettingsSchema object) {
  object.id = id;
}

extension UserSettingsSchemaQueryWhereSort
    on QueryBuilder<UserSettingsSchema, UserSettingsSchema, QWhere> {
  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserSettingsSchemaQueryWhere
    on QueryBuilder<UserSettingsSchema, UserSettingsSchema, QWhereClause> {
  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserSettingsSchemaQueryFilter
    on QueryBuilder<UserSettingsSchema, UserSettingsSchema, QFilterCondition> {
  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      appVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'appVersion',
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      appVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'appVersion',
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      appVersionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      appVersionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      appVersionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      appVersionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'appVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      appVersionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      appVersionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      appVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      appVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'appVersion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      appVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      appVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'appVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      blackoutDatesElementEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blackoutDates',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      blackoutDatesElementGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blackoutDates',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      blackoutDatesElementLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blackoutDates',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      blackoutDatesElementBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blackoutDates',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      blackoutDatesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blackoutDates',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      blackoutDatesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blackoutDates',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      blackoutDatesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blackoutDates',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      blackoutDatesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blackoutDates',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      blackoutDatesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blackoutDates',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      blackoutDatesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'blackoutDates',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      lastPlanGeneratedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPlanGeneratedAt',
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      lastPlanGeneratedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPlanGeneratedAt',
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      lastPlanGeneratedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPlanGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      lastPlanGeneratedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPlanGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      lastPlanGeneratedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPlanGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      lastPlanGeneratedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPlanGeneratedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      notificationTimeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      notificationTimeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notificationTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      notificationTimeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notificationTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      notificationTimeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notificationTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      notificationTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notificationTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      notificationTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notificationTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      notificationTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notificationTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      notificationTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notificationTime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      notificationTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationTime',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      notificationTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notificationTime',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      notificationsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationsEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      pomodoroBreakMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pomodoroBreakMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      pomodoroBreakMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pomodoroBreakMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      pomodoroBreakMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pomodoroBreakMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      pomodoroBreakMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pomodoroBreakMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      pomodoroCyclesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pomodoroCycles',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      pomodoroCyclesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pomodoroCycles',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      pomodoroCyclesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pomodoroCycles',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      pomodoroCyclesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pomodoroCycles',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      pomodoroWorkMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pomodoroWorkMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      pomodoroWorkMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pomodoroWorkMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      pomodoroWorkMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pomodoroWorkMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      pomodoroWorkMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pomodoroWorkMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      soundEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'soundEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      themeModeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      themeModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      themeModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      themeModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'themeMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      themeModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      themeModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      themeModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      themeModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'themeMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      themeModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themeMode',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      themeModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'themeMode',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterFilterCondition>
      vibrationEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vibrationEnabled',
        value: value,
      ));
    });
  }
}

extension UserSettingsSchemaQueryObject
    on QueryBuilder<UserSettingsSchema, UserSettingsSchema, QFilterCondition> {}

extension UserSettingsSchemaQueryLinks
    on QueryBuilder<UserSettingsSchema, UserSettingsSchema, QFilterCondition> {}

extension UserSettingsSchemaQuerySortBy
    on QueryBuilder<UserSettingsSchema, UserSettingsSchema, QSortBy> {
  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByAppVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appVersion', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByAppVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appVersion', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByLastPlanGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlanGeneratedAt', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByLastPlanGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlanGeneratedAt', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByNotificationTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationTime', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByNotificationTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationTime', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByPomodoroBreakMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroBreakMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByPomodoroBreakMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroBreakMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByPomodoroCycles() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroCycles', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByPomodoroCyclesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroCycles', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByPomodoroWorkMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroWorkMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByPomodoroWorkMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroWorkMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortBySoundEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortBySoundEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByVibrationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vibrationEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      sortByVibrationEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vibrationEnabled', Sort.desc);
    });
  }
}

extension UserSettingsSchemaQuerySortThenBy
    on QueryBuilder<UserSettingsSchema, UserSettingsSchema, QSortThenBy> {
  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByAppVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appVersion', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByAppVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appVersion', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByLastPlanGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlanGeneratedAt', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByLastPlanGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlanGeneratedAt', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByNotificationTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationTime', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByNotificationTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationTime', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByPomodoroBreakMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroBreakMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByPomodoroBreakMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroBreakMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByPomodoroCycles() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroCycles', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByPomodoroCyclesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroCycles', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByPomodoroWorkMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroWorkMinutes', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByPomodoroWorkMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroWorkMinutes', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenBySoundEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenBySoundEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soundEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByVibrationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vibrationEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QAfterSortBy>
      thenByVibrationEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vibrationEnabled', Sort.desc);
    });
  }
}

extension UserSettingsSchemaQueryWhereDistinct
    on QueryBuilder<UserSettingsSchema, UserSettingsSchema, QDistinct> {
  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QDistinct>
      distinctByAppVersion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appVersion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QDistinct>
      distinctByBlackoutDates() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blackoutDates');
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QDistinct>
      distinctByLastPlanGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlanGeneratedAt');
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QDistinct>
      distinctByNotificationTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationTime',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QDistinct>
      distinctByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationsEnabled');
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QDistinct>
      distinctByPomodoroBreakMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pomodoroBreakMinutes');
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QDistinct>
      distinctByPomodoroCycles() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pomodoroCycles');
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QDistinct>
      distinctByPomodoroWorkMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pomodoroWorkMinutes');
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QDistinct>
      distinctBySoundEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'soundEnabled');
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QDistinct>
      distinctByThemeMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSettingsSchema, UserSettingsSchema, QDistinct>
      distinctByVibrationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vibrationEnabled');
    });
  }
}

extension UserSettingsSchemaQueryProperty
    on QueryBuilder<UserSettingsSchema, UserSettingsSchema, QQueryProperty> {
  QueryBuilder<UserSettingsSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserSettingsSchema, String?, QQueryOperations>
      appVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appVersion');
    });
  }

  QueryBuilder<UserSettingsSchema, List<DateTime>, QQueryOperations>
      blackoutDatesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blackoutDates');
    });
  }

  QueryBuilder<UserSettingsSchema, DateTime?, QQueryOperations>
      lastPlanGeneratedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlanGeneratedAt');
    });
  }

  QueryBuilder<UserSettingsSchema, String, QQueryOperations>
      notificationTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationTime');
    });
  }

  QueryBuilder<UserSettingsSchema, bool, QQueryOperations>
      notificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationsEnabled');
    });
  }

  QueryBuilder<UserSettingsSchema, int, QQueryOperations>
      pomodoroBreakMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pomodoroBreakMinutes');
    });
  }

  QueryBuilder<UserSettingsSchema, int, QQueryOperations>
      pomodoroCyclesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pomodoroCycles');
    });
  }

  QueryBuilder<UserSettingsSchema, int, QQueryOperations>
      pomodoroWorkMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pomodoroWorkMinutes');
    });
  }

  QueryBuilder<UserSettingsSchema, bool, QQueryOperations>
      soundEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'soundEnabled');
    });
  }

  QueryBuilder<UserSettingsSchema, String, QQueryOperations>
      themeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeMode');
    });
  }

  QueryBuilder<UserSettingsSchema, bool, QQueryOperations>
      vibrationEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vibrationEnabled');
    });
  }
}
