// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserSchemaCollection on Isar {
  IsarCollection<UserSchema> get userSchemas => this.collection();
}

const UserSchemaSchema = CollectionSchema(
  name: r'UserSchema',
  id: 454180666620985307,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentStreak': PropertySchema(
      id: 1,
      name: r'currentStreak',
      type: IsarType.long,
    ),
    r'dailyStudyHours': PropertySchema(
      id: 2,
      name: r'dailyStudyHours',
      type: IsarType.double,
    ),
    r'displayName': PropertySchema(
      id: 3,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'email': PropertySchema(
      id: 4,
      name: r'email',
      type: IsarType.string,
    ),
    r'examDate': PropertySchema(
      id: 5,
      name: r'examDate',
      type: IsarType.dateTime,
    ),
    r'examYear': PropertySchema(
      id: 6,
      name: r'examYear',
      type: IsarType.string,
    ),
    r'hasActivePremium': PropertySchema(
      id: 7,
      name: r'hasActivePremium',
      type: IsarType.bool,
    ),
    r'isPremium': PropertySchema(
      id: 8,
      name: r'isPremium',
      type: IsarType.bool,
    ),
    r'isTrialEligible': PropertySchema(
      id: 9,
      name: r'isTrialEligible',
      type: IsarType.bool,
    ),
    r'lastActiveAt': PropertySchema(
      id: 10,
      name: r'lastActiveAt',
      type: IsarType.dateTime,
    ),
    r'lastStudyDate': PropertySchema(
      id: 11,
      name: r'lastStudyDate',
      type: IsarType.dateTime,
    ),
    r'longestStreak': PropertySchema(
      id: 12,
      name: r'longestStreak',
      type: IsarType.long,
    ),
    r'onboardingComplete': PropertySchema(
      id: 13,
      name: r'onboardingComplete',
      type: IsarType.bool,
    ),
    r'photoUrl': PropertySchema(
      id: 14,
      name: r'photoUrl',
      type: IsarType.string,
    ),
    r'planStartDate': PropertySchema(
      id: 15,
      name: r'planStartDate',
      type: IsarType.dateTime,
    ),
    r'premiumExpiry': PropertySchema(
      id: 16,
      name: r'premiumExpiry',
      type: IsarType.dateTime,
    ),
    r'subscriptionPlan': PropertySchema(
      id: 17,
      name: r'subscriptionPlan',
      type: IsarType.string,
    ),
    r'targetExam': PropertySchema(
      id: 18,
      name: r'targetExam',
      type: IsarType.string,
    ),
    r'trialEndedAt': PropertySchema(
      id: 19,
      name: r'trialEndedAt',
      type: IsarType.dateTime,
    ),
    r'trialStartedAt': PropertySchema(
      id: 20,
      name: r'trialStartedAt',
      type: IsarType.dateTime,
    ),
    r'trialUsed': PropertySchema(
      id: 21,
      name: r'trialUsed',
      type: IsarType.bool,
    ),
    r'uid': PropertySchema(
      id: 22,
      name: r'uid',
      type: IsarType.string,
    )
  },
  estimateSize: _userSchemaEstimateSize,
  serialize: _userSchemaSerialize,
  deserialize: _userSchemaDeserialize,
  deserializeProp: _userSchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'uid': IndexSchema(
      id: 8193695471701937315,
      name: r'uid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _userSchemaGetId,
  getLinks: _userSchemaGetLinks,
  attach: _userSchemaAttach,
  version: '3.1.0+1',
);

int _userSchemaEstimateSize(
  UserSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.displayName.length * 3;
  {
    final value = object.email;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.examYear.length * 3;
  {
    final value = object.photoUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.subscriptionPlan;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.targetExam.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _userSchemaSerialize(
  UserSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.currentStreak);
  writer.writeDouble(offsets[2], object.dailyStudyHours);
  writer.writeString(offsets[3], object.displayName);
  writer.writeString(offsets[4], object.email);
  writer.writeDateTime(offsets[5], object.examDate);
  writer.writeString(offsets[6], object.examYear);
  writer.writeBool(offsets[7], object.hasActivePremium);
  writer.writeBool(offsets[8], object.isPremium);
  writer.writeBool(offsets[9], object.isTrialEligible);
  writer.writeDateTime(offsets[10], object.lastActiveAt);
  writer.writeDateTime(offsets[11], object.lastStudyDate);
  writer.writeLong(offsets[12], object.longestStreak);
  writer.writeBool(offsets[13], object.onboardingComplete);
  writer.writeString(offsets[14], object.photoUrl);
  writer.writeDateTime(offsets[15], object.planStartDate);
  writer.writeDateTime(offsets[16], object.premiumExpiry);
  writer.writeString(offsets[17], object.subscriptionPlan);
  writer.writeString(offsets[18], object.targetExam);
  writer.writeDateTime(offsets[19], object.trialEndedAt);
  writer.writeDateTime(offsets[20], object.trialStartedAt);
  writer.writeBool(offsets[21], object.trialUsed);
  writer.writeString(offsets[22], object.uid);
}

UserSchema _userSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserSchema();
  object.createdAt = reader.readDateTimeOrNull(offsets[0]);
  object.currentStreak = reader.readLong(offsets[1]);
  object.dailyStudyHours = reader.readDouble(offsets[2]);
  object.displayName = reader.readString(offsets[3]);
  object.email = reader.readStringOrNull(offsets[4]);
  object.examDate = reader.readDateTimeOrNull(offsets[5]);
  object.examYear = reader.readString(offsets[6]);
  object.id = id;
  object.isPremium = reader.readBool(offsets[8]);
  object.lastActiveAt = reader.readDateTimeOrNull(offsets[10]);
  object.lastStudyDate = reader.readDateTimeOrNull(offsets[11]);
  object.longestStreak = reader.readLong(offsets[12]);
  object.onboardingComplete = reader.readBool(offsets[13]);
  object.photoUrl = reader.readStringOrNull(offsets[14]);
  object.planStartDate = reader.readDateTimeOrNull(offsets[15]);
  object.premiumExpiry = reader.readDateTimeOrNull(offsets[16]);
  object.subscriptionPlan = reader.readStringOrNull(offsets[17]);
  object.targetExam = reader.readString(offsets[18]);
  object.trialEndedAt = reader.readDateTimeOrNull(offsets[19]);
  object.trialStartedAt = reader.readDateTimeOrNull(offsets[20]);
  object.trialUsed = reader.readBool(offsets[21]);
  object.uid = reader.readString(offsets[22]);
  return object;
}

P _userSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 20:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 21:
      return (reader.readBool(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userSchemaGetId(UserSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userSchemaGetLinks(UserSchema object) {
  return [];
}

void _userSchemaAttach(IsarCollection<dynamic> col, Id id, UserSchema object) {
  object.id = id;
}

extension UserSchemaByIndex on IsarCollection<UserSchema> {
  Future<UserSchema?> getByUid(String uid) {
    return getByIndex(r'uid', [uid]);
  }

  UserSchema? getByUidSync(String uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<UserSchema?>> getAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<UserSchema?> getAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uid', values);
  }

  Future<int> deleteAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uid', values);
  }

  int deleteAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uid', values);
  }

  Future<Id> putByUid(UserSchema object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(UserSchema object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<UserSchema> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(List<UserSchema> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension UserSchemaQueryWhereSort
    on QueryBuilder<UserSchema, UserSchema, QWhere> {
  QueryBuilder<UserSchema, UserSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserSchemaQueryWhere
    on QueryBuilder<UserSchema, UserSchema, QWhereClause> {
  QueryBuilder<UserSchema, UserSchema, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<UserSchema, UserSchema, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterWhereClause> idBetween(
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

  QueryBuilder<UserSchema, UserSchema, QAfterWhereClause> uidEqualTo(
      String uid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uid',
        value: [uid],
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterWhereClause> uidNotEqualTo(
      String uid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension UserSchemaQueryFilter
    on QueryBuilder<UserSchema, UserSchema, QFilterCondition> {
  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> createdAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      currentStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      currentStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      currentStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      currentStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      dailyStudyHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyStudyHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      dailyStudyHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyStudyHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      dailyStudyHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyStudyHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      dailyStudyHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyStudyHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      displayNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      displayNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      displayNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      displayNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      displayNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      displayNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      displayNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      displayNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> emailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'email',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> emailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'email',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> emailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> emailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> emailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> emailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'email',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> emailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> emailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> emailContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> emailMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'email',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> emailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      emailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> examDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'examDate',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      examDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'examDate',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> examDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'examDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      examDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'examDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> examDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'examDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> examDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'examDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> examYearEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'examYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      examYearGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'examYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> examYearLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'examYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> examYearBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'examYear',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      examYearStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'examYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> examYearEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'examYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> examYearContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'examYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> examYearMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'examYear',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      examYearIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'examYear',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      examYearIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'examYear',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      hasActivePremiumEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasActivePremium',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> isPremiumEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPremium',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      isTrialEligibleEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isTrialEligible',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      lastActiveAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastActiveAt',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      lastActiveAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastActiveAt',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      lastActiveAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastActiveAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      lastActiveAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastActiveAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      lastActiveAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastActiveAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      lastActiveAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastActiveAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      lastStudyDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastStudyDate',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      lastStudyDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastStudyDate',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      lastStudyDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastStudyDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      lastStudyDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastStudyDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      lastStudyDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastStudyDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      lastStudyDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastStudyDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      longestStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      longestStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      longestStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      longestStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longestStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      onboardingCompleteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'onboardingComplete',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> photoUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'photoUrl',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      photoUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'photoUrl',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> photoUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      photoUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> photoUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> photoUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'photoUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      photoUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> photoUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> photoUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> photoUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photoUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      photoUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      photoUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      planStartDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'planStartDate',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      planStartDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'planStartDate',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      planStartDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      planStartDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'planStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      planStartDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'planStartDate',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      planStartDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'planStartDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      premiumExpiryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'premiumExpiry',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      premiumExpiryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'premiumExpiry',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      premiumExpiryEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'premiumExpiry',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      premiumExpiryGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'premiumExpiry',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      premiumExpiryLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'premiumExpiry',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      premiumExpiryBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'premiumExpiry',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      subscriptionPlanIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subscriptionPlan',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      subscriptionPlanIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subscriptionPlan',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      subscriptionPlanEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subscriptionPlan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      subscriptionPlanGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subscriptionPlan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      subscriptionPlanLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subscriptionPlan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      subscriptionPlanBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subscriptionPlan',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      subscriptionPlanStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subscriptionPlan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      subscriptionPlanEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subscriptionPlan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      subscriptionPlanContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subscriptionPlan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      subscriptionPlanMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subscriptionPlan',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      subscriptionPlanIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subscriptionPlan',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      subscriptionPlanIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subscriptionPlan',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> targetExamEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetExam',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      targetExamGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetExam',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      targetExamLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetExam',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> targetExamBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetExam',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      targetExamStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'targetExam',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      targetExamEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'targetExam',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      targetExamContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'targetExam',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> targetExamMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'targetExam',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      targetExamIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetExam',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      targetExamIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'targetExam',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      trialEndedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'trialEndedAt',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      trialEndedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'trialEndedAt',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      trialEndedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trialEndedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      trialEndedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trialEndedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      trialEndedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trialEndedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      trialEndedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trialEndedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      trialStartedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'trialStartedAt',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      trialStartedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'trialStartedAt',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      trialStartedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trialStartedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      trialStartedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trialStartedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      trialStartedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trialStartedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition>
      trialStartedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trialStartedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> trialUsedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trialUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> uidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> uidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }
}

extension UserSchemaQueryObject
    on QueryBuilder<UserSchema, UserSchema, QFilterCondition> {}

extension UserSchemaQueryLinks
    on QueryBuilder<UserSchema, UserSchema, QFilterCondition> {}

extension UserSchemaQuerySortBy
    on QueryBuilder<UserSchema, UserSchema, QSortBy> {
  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByDailyStudyHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyStudyHours', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy>
      sortByDailyStudyHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyStudyHours', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByExamDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examDate', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByExamDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examDate', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByExamYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examYear', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByExamYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examYear', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByHasActivePremium() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasActivePremium', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy>
      sortByHasActivePremiumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasActivePremium', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByIsPremium() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPremium', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByIsPremiumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPremium', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByIsTrialEligible() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrialEligible', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy>
      sortByIsTrialEligibleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrialEligible', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByLastActiveAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActiveAt', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByLastActiveAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActiveAt', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByLastStudyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStudyDate', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByLastStudyDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStudyDate', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByLongestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreak', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByLongestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreak', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy>
      sortByOnboardingComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingComplete', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy>
      sortByOnboardingCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingComplete', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByPlanStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planStartDate', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByPlanStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planStartDate', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByPremiumExpiry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'premiumExpiry', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByPremiumExpiryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'premiumExpiry', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortBySubscriptionPlan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscriptionPlan', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy>
      sortBySubscriptionPlanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscriptionPlan', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByTargetExam() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetExam', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByTargetExamDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetExam', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByTrialEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialEndedAt', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByTrialEndedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialEndedAt', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByTrialStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialStartedAt', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy>
      sortByTrialStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialStartedAt', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByTrialUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialUsed', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByTrialUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialUsed', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension UserSchemaQuerySortThenBy
    on QueryBuilder<UserSchema, UserSchema, QSortThenBy> {
  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByDailyStudyHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyStudyHours', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy>
      thenByDailyStudyHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyStudyHours', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByExamDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examDate', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByExamDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examDate', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByExamYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examYear', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByExamYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examYear', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByHasActivePremium() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasActivePremium', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy>
      thenByHasActivePremiumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasActivePremium', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByIsPremium() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPremium', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByIsPremiumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPremium', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByIsTrialEligible() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrialEligible', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy>
      thenByIsTrialEligibleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isTrialEligible', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByLastActiveAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActiveAt', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByLastActiveAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActiveAt', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByLastStudyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStudyDate', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByLastStudyDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStudyDate', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByLongestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreak', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByLongestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longestStreak', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy>
      thenByOnboardingComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingComplete', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy>
      thenByOnboardingCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingComplete', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByPlanStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planStartDate', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByPlanStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planStartDate', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByPremiumExpiry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'premiumExpiry', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByPremiumExpiryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'premiumExpiry', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenBySubscriptionPlan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscriptionPlan', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy>
      thenBySubscriptionPlanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subscriptionPlan', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByTargetExam() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetExam', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByTargetExamDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetExam', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByTrialEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialEndedAt', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByTrialEndedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialEndedAt', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByTrialStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialStartedAt', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy>
      thenByTrialStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialStartedAt', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByTrialUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialUsed', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByTrialUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trialUsed', Sort.desc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension UserSchemaQueryWhereDistinct
    on QueryBuilder<UserSchema, UserSchema, QDistinct> {
  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStreak');
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByDailyStudyHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyStudyHours');
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByDisplayName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByEmail(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'email', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByExamDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'examDate');
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByExamYear(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'examYear', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByHasActivePremium() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasActivePremium');
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByIsPremium() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPremium');
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByIsTrialEligible() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isTrialEligible');
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByLastActiveAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastActiveAt');
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByLastStudyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastStudyDate');
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByLongestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longestStreak');
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct>
      distinctByOnboardingComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onboardingComplete');
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByPhotoUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByPlanStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'planStartDate');
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByPremiumExpiry() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'premiumExpiry');
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctBySubscriptionPlan(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subscriptionPlan',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByTargetExam(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetExam', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByTrialEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trialEndedAt');
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByTrialStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trialStartedAt');
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByTrialUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trialUsed');
    });
  }

  QueryBuilder<UserSchema, UserSchema, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }
}

extension UserSchemaQueryProperty
    on QueryBuilder<UserSchema, UserSchema, QQueryProperty> {
  QueryBuilder<UserSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserSchema, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<UserSchema, int, QQueryOperations> currentStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStreak');
    });
  }

  QueryBuilder<UserSchema, double, QQueryOperations> dailyStudyHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyStudyHours');
    });
  }

  QueryBuilder<UserSchema, String, QQueryOperations> displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<UserSchema, String?, QQueryOperations> emailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'email');
    });
  }

  QueryBuilder<UserSchema, DateTime?, QQueryOperations> examDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'examDate');
    });
  }

  QueryBuilder<UserSchema, String, QQueryOperations> examYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'examYear');
    });
  }

  QueryBuilder<UserSchema, bool, QQueryOperations> hasActivePremiumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasActivePremium');
    });
  }

  QueryBuilder<UserSchema, bool, QQueryOperations> isPremiumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPremium');
    });
  }

  QueryBuilder<UserSchema, bool, QQueryOperations> isTrialEligibleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isTrialEligible');
    });
  }

  QueryBuilder<UserSchema, DateTime?, QQueryOperations> lastActiveAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastActiveAt');
    });
  }

  QueryBuilder<UserSchema, DateTime?, QQueryOperations>
      lastStudyDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastStudyDate');
    });
  }

  QueryBuilder<UserSchema, int, QQueryOperations> longestStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longestStreak');
    });
  }

  QueryBuilder<UserSchema, bool, QQueryOperations>
      onboardingCompleteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onboardingComplete');
    });
  }

  QueryBuilder<UserSchema, String?, QQueryOperations> photoUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoUrl');
    });
  }

  QueryBuilder<UserSchema, DateTime?, QQueryOperations>
      planStartDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'planStartDate');
    });
  }

  QueryBuilder<UserSchema, DateTime?, QQueryOperations>
      premiumExpiryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'premiumExpiry');
    });
  }

  QueryBuilder<UserSchema, String?, QQueryOperations>
      subscriptionPlanProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subscriptionPlan');
    });
  }

  QueryBuilder<UserSchema, String, QQueryOperations> targetExamProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetExam');
    });
  }

  QueryBuilder<UserSchema, DateTime?, QQueryOperations> trialEndedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trialEndedAt');
    });
  }

  QueryBuilder<UserSchema, DateTime?, QQueryOperations>
      trialStartedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trialStartedAt');
    });
  }

  QueryBuilder<UserSchema, bool, QQueryOperations> trialUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trialUsed');
    });
  }

  QueryBuilder<UserSchema, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }
}
