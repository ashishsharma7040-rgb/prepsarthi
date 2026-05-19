// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAchievementSchemaCollection on Isar {
  IsarCollection<AchievementSchema> get achievementSchemas => this.collection();
}

const AchievementSchemaSchema = CollectionSchema(
  name: r'AchievementSchema',
  id: 7698302722180940375,
  properties: {
    r'badgeId': PropertySchema(
      id: 0,
      name: r'badgeId',
      type: IsarType.string,
    ),
    r'currentProgress': PropertySchema(
      id: 1,
      name: r'currentProgress',
      type: IsarType.long,
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'emoji': PropertySchema(
      id: 3,
      name: r'emoji',
      type: IsarType.string,
    ),
    r'targetProgress': PropertySchema(
      id: 4,
      name: r'targetProgress',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 5,
      name: r'title',
      type: IsarType.string,
    ),
    r'unlocked': PropertySchema(
      id: 6,
      name: r'unlocked',
      type: IsarType.bool,
    ),
    r'unlockedAt': PropertySchema(
      id: 7,
      name: r'unlockedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _achievementSchemaEstimateSize,
  serialize: _achievementSchemaSerialize,
  deserialize: _achievementSchemaDeserialize,
  deserializeProp: _achievementSchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'badgeId': IndexSchema(
      id: 2632729407329682508,
      name: r'badgeId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'badgeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _achievementSchemaGetId,
  getLinks: _achievementSchemaGetLinks,
  attach: _achievementSchemaAttach,
  version: '3.1.0+1',
);

int _achievementSchemaEstimateSize(
  AchievementSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.badgeId.length * 3;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.emoji.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _achievementSchemaSerialize(
  AchievementSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.badgeId);
  writer.writeLong(offsets[1], object.currentProgress);
  writer.writeString(offsets[2], object.description);
  writer.writeString(offsets[3], object.emoji);
  writer.writeLong(offsets[4], object.targetProgress);
  writer.writeString(offsets[5], object.title);
  writer.writeBool(offsets[6], object.unlocked);
  writer.writeDateTime(offsets[7], object.unlockedAt);
}

AchievementSchema _achievementSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AchievementSchema();
  object.badgeId = reader.readString(offsets[0]);
  object.currentProgress = reader.readLong(offsets[1]);
  object.description = reader.readString(offsets[2]);
  object.emoji = reader.readString(offsets[3]);
  object.id = id;
  object.targetProgress = reader.readLong(offsets[4]);
  object.title = reader.readString(offsets[5]);
  object.unlocked = reader.readBool(offsets[6]);
  object.unlockedAt = reader.readDateTimeOrNull(offsets[7]);
  return object;
}

P _achievementSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _achievementSchemaGetId(AchievementSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _achievementSchemaGetLinks(
    AchievementSchema object) {
  return [];
}

void _achievementSchemaAttach(
    IsarCollection<dynamic> col, Id id, AchievementSchema object) {
  object.id = id;
}

extension AchievementSchemaByIndex on IsarCollection<AchievementSchema> {
  Future<AchievementSchema?> getByBadgeId(String badgeId) {
    return getByIndex(r'badgeId', [badgeId]);
  }

  AchievementSchema? getByBadgeIdSync(String badgeId) {
    return getByIndexSync(r'badgeId', [badgeId]);
  }

  Future<bool> deleteByBadgeId(String badgeId) {
    return deleteByIndex(r'badgeId', [badgeId]);
  }

  bool deleteByBadgeIdSync(String badgeId) {
    return deleteByIndexSync(r'badgeId', [badgeId]);
  }

  Future<List<AchievementSchema?>> getAllByBadgeId(List<String> badgeIdValues) {
    final values = badgeIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'badgeId', values);
  }

  List<AchievementSchema?> getAllByBadgeIdSync(List<String> badgeIdValues) {
    final values = badgeIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'badgeId', values);
  }

  Future<int> deleteAllByBadgeId(List<String> badgeIdValues) {
    final values = badgeIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'badgeId', values);
  }

  int deleteAllByBadgeIdSync(List<String> badgeIdValues) {
    final values = badgeIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'badgeId', values);
  }

  Future<Id> putByBadgeId(AchievementSchema object) {
    return putByIndex(r'badgeId', object);
  }

  Id putByBadgeIdSync(AchievementSchema object, {bool saveLinks = true}) {
    return putByIndexSync(r'badgeId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByBadgeId(List<AchievementSchema> objects) {
    return putAllByIndex(r'badgeId', objects);
  }

  List<Id> putAllByBadgeIdSync(List<AchievementSchema> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'badgeId', objects, saveLinks: saveLinks);
  }
}

extension AchievementSchemaQueryWhereSort
    on QueryBuilder<AchievementSchema, AchievementSchema, QWhere> {
  QueryBuilder<AchievementSchema, AchievementSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AchievementSchemaQueryWhere
    on QueryBuilder<AchievementSchema, AchievementSchema, QWhereClause> {
  QueryBuilder<AchievementSchema, AchievementSchema, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterWhereClause>
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

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterWhereClause>
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

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterWhereClause>
      badgeIdEqualTo(String badgeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'badgeId',
        value: [badgeId],
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterWhereClause>
      badgeIdNotEqualTo(String badgeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'badgeId',
              lower: [],
              upper: [badgeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'badgeId',
              lower: [badgeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'badgeId',
              lower: [badgeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'badgeId',
              lower: [],
              upper: [badgeId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AchievementSchemaQueryFilter
    on QueryBuilder<AchievementSchema, AchievementSchema, QFilterCondition> {
  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      badgeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'badgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      badgeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'badgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      badgeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'badgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      badgeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'badgeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      badgeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'badgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      badgeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'badgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      badgeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'badgeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      badgeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'badgeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      badgeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'badgeId',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      badgeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'badgeId',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      currentProgressEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      currentProgressGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      currentProgressLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      currentProgressBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentProgress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      emojiEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      emojiGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      emojiLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      emojiBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'emoji',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      emojiStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      emojiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      emojiContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      emojiMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'emoji',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      emojiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emoji',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      emojiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'emoji',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
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

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
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

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
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

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      targetProgressEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      targetProgressGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      targetProgressLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      targetProgressBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetProgress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      unlockedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlocked',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      unlockedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unlockedAt',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      unlockedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unlockedAt',
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      unlockedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      unlockedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      unlockedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterFilterCondition>
      unlockedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AchievementSchemaQueryObject
    on QueryBuilder<AchievementSchema, AchievementSchema, QFilterCondition> {}

extension AchievementSchemaQueryLinks
    on QueryBuilder<AchievementSchema, AchievementSchema, QFilterCondition> {}

extension AchievementSchemaQuerySortBy
    on QueryBuilder<AchievementSchema, AchievementSchema, QSortBy> {
  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByBadgeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeId', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByBadgeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeId', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByCurrentProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentProgress', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByCurrentProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentProgress', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByEmoji() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emoji', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByEmojiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emoji', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByTargetProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetProgress', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByTargetProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetProgress', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlocked', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByUnlockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlocked', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      sortByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }
}

extension AchievementSchemaQuerySortThenBy
    on QueryBuilder<AchievementSchema, AchievementSchema, QSortThenBy> {
  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByBadgeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeId', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByBadgeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeId', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByCurrentProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentProgress', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByCurrentProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentProgress', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByEmoji() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emoji', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByEmojiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emoji', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByTargetProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetProgress', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByTargetProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetProgress', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlocked', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByUnlockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlocked', Sort.desc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QAfterSortBy>
      thenByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }
}

extension AchievementSchemaQueryWhereDistinct
    on QueryBuilder<AchievementSchema, AchievementSchema, QDistinct> {
  QueryBuilder<AchievementSchema, AchievementSchema, QDistinct>
      distinctByBadgeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'badgeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QDistinct>
      distinctByCurrentProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentProgress');
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QDistinct> distinctByEmoji(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emoji', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QDistinct>
      distinctByTargetProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetProgress');
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QDistinct>
      distinctByUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlocked');
    });
  }

  QueryBuilder<AchievementSchema, AchievementSchema, QDistinct>
      distinctByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedAt');
    });
  }
}

extension AchievementSchemaQueryProperty
    on QueryBuilder<AchievementSchema, AchievementSchema, QQueryProperty> {
  QueryBuilder<AchievementSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AchievementSchema, String, QQueryOperations> badgeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'badgeId');
    });
  }

  QueryBuilder<AchievementSchema, int, QQueryOperations>
      currentProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentProgress');
    });
  }

  QueryBuilder<AchievementSchema, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<AchievementSchema, String, QQueryOperations> emojiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emoji');
    });
  }

  QueryBuilder<AchievementSchema, int, QQueryOperations>
      targetProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetProgress');
    });
  }

  QueryBuilder<AchievementSchema, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<AchievementSchema, bool, QQueryOperations> unlockedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlocked');
    });
  }

  QueryBuilder<AchievementSchema, DateTime?, QQueryOperations>
      unlockedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedAt');
    });
  }
}
