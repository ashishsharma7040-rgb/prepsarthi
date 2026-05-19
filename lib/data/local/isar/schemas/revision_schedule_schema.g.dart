// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revision_schedule_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRevisionScheduleSchemaCollection on Isar {
  IsarCollection<RevisionScheduleSchema> get revisionScheduleSchemas =>
      this.collection();
}

const RevisionScheduleSchemaSchema = CollectionSchema(
  name: r'RevisionScheduleSchema',
  id: 3533867943474384056,
  properties: {
    r'active': PropertySchema(
      id: 0,
      name: r'active',
      type: IsarType.bool,
    ),
    r'chapterName': PropertySchema(
      id: 1,
      name: r'chapterName',
      type: IsarType.string,
    ),
    r'completedCount': PropertySchema(
      id: 2,
      name: r'completedCount',
      type: IsarType.long,
    ),
    r'completedDates': PropertySchema(
      id: 3,
      name: r'completedDates',
      type: IsarType.dateTimeList,
    ),
    r'firstLearnedDate': PropertySchema(
      id: 4,
      name: r'firstLearnedDate',
      type: IsarType.dateTime,
    ),
    r'isFullyRevised': PropertySchema(
      id: 5,
      name: r'isFullyRevised',
      type: IsarType.bool,
    ),
    r'scheduledDates': PropertySchema(
      id: 6,
      name: r'scheduledDates',
      type: IsarType.dateTimeList,
    ),
    r'subjectName': PropertySchema(
      id: 7,
      name: r'subjectName',
      type: IsarType.string,
    )
  },
  estimateSize: _revisionScheduleSchemaEstimateSize,
  serialize: _revisionScheduleSchemaSerialize,
  deserialize: _revisionScheduleSchemaDeserialize,
  deserializeProp: _revisionScheduleSchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'chapterName': IndexSchema(
      id: 1604687574535883829,
      name: r'chapterName',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'chapterName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _revisionScheduleSchemaGetId,
  getLinks: _revisionScheduleSchemaGetLinks,
  attach: _revisionScheduleSchemaAttach,
  version: '3.1.0+1',
);

int _revisionScheduleSchemaEstimateSize(
  RevisionScheduleSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.chapterName.length * 3;
  bytesCount += 3 + object.completedDates.length * 8;
  bytesCount += 3 + object.scheduledDates.length * 8;
  bytesCount += 3 + object.subjectName.length * 3;
  return bytesCount;
}

void _revisionScheduleSchemaSerialize(
  RevisionScheduleSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.active);
  writer.writeString(offsets[1], object.chapterName);
  writer.writeLong(offsets[2], object.completedCount);
  writer.writeDateTimeList(offsets[3], object.completedDates);
  writer.writeDateTime(offsets[4], object.firstLearnedDate);
  writer.writeBool(offsets[5], object.isFullyRevised);
  writer.writeDateTimeList(offsets[6], object.scheduledDates);
  writer.writeString(offsets[7], object.subjectName);
}

RevisionScheduleSchema _revisionScheduleSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RevisionScheduleSchema();
  object.active = reader.readBool(offsets[0]);
  object.chapterName = reader.readString(offsets[1]);
  object.completedCount = reader.readLong(offsets[2]);
  object.completedDates = reader.readDateTimeList(offsets[3]) ?? [];
  object.firstLearnedDate = reader.readDateTime(offsets[4]);
  object.id = id;
  object.isFullyRevised = reader.readBool(offsets[5]);
  object.scheduledDates = reader.readDateTimeList(offsets[6]) ?? [];
  object.subjectName = reader.readString(offsets[7]);
  return object;
}

P _revisionScheduleSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTimeList(offset) ?? []) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDateTimeList(offset) ?? []) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _revisionScheduleSchemaGetId(RevisionScheduleSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _revisionScheduleSchemaGetLinks(
    RevisionScheduleSchema object) {
  return [];
}

void _revisionScheduleSchemaAttach(
    IsarCollection<dynamic> col, Id id, RevisionScheduleSchema object) {
  object.id = id;
}

extension RevisionScheduleSchemaByIndex
    on IsarCollection<RevisionScheduleSchema> {
  Future<RevisionScheduleSchema?> getByChapterName(String chapterName) {
    return getByIndex(r'chapterName', [chapterName]);
  }

  RevisionScheduleSchema? getByChapterNameSync(String chapterName) {
    return getByIndexSync(r'chapterName', [chapterName]);
  }

  Future<bool> deleteByChapterName(String chapterName) {
    return deleteByIndex(r'chapterName', [chapterName]);
  }

  bool deleteByChapterNameSync(String chapterName) {
    return deleteByIndexSync(r'chapterName', [chapterName]);
  }

  Future<List<RevisionScheduleSchema?>> getAllByChapterName(
      List<String> chapterNameValues) {
    final values = chapterNameValues.map((e) => [e]).toList();
    return getAllByIndex(r'chapterName', values);
  }

  List<RevisionScheduleSchema?> getAllByChapterNameSync(
      List<String> chapterNameValues) {
    final values = chapterNameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'chapterName', values);
  }

  Future<int> deleteAllByChapterName(List<String> chapterNameValues) {
    final values = chapterNameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'chapterName', values);
  }

  int deleteAllByChapterNameSync(List<String> chapterNameValues) {
    final values = chapterNameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'chapterName', values);
  }

  Future<Id> putByChapterName(RevisionScheduleSchema object) {
    return putByIndex(r'chapterName', object);
  }

  Id putByChapterNameSync(RevisionScheduleSchema object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'chapterName', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByChapterName(List<RevisionScheduleSchema> objects) {
    return putAllByIndex(r'chapterName', objects);
  }

  List<Id> putAllByChapterNameSync(List<RevisionScheduleSchema> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'chapterName', objects, saveLinks: saveLinks);
  }
}

extension RevisionScheduleSchemaQueryWhereSort
    on QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QWhere> {
  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RevisionScheduleSchemaQueryWhere on QueryBuilder<
    RevisionScheduleSchema, RevisionScheduleSchema, QWhereClause> {
  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterWhereClause> chapterNameEqualTo(String chapterName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'chapterName',
        value: [chapterName],
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterWhereClause> chapterNameNotEqualTo(String chapterName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterName',
              lower: [],
              upper: [chapterName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterName',
              lower: [chapterName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterName',
              lower: [chapterName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'chapterName',
              lower: [],
              upper: [chapterName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension RevisionScheduleSchemaQueryFilter on QueryBuilder<
    RevisionScheduleSchema, RevisionScheduleSchema, QFilterCondition> {
  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> activeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'active',
        value: value,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> chapterNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> chapterNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> chapterNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> chapterNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> chapterNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chapterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> chapterNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chapterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
          QAfterFilterCondition>
      chapterNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chapterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
          QAfterFilterCondition>
      chapterNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chapterName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> chapterNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterName',
        value: '',
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> chapterNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chapterName',
        value: '',
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> completedCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedCount',
        value: value,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> completedCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedCount',
        value: value,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> completedCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedCount',
        value: value,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> completedCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> completedDatesElementEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedDates',
        value: value,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> completedDatesElementGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedDates',
        value: value,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> completedDatesElementLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedDates',
        value: value,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> completedDatesElementBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedDates',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> completedDatesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedDates',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> completedDatesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedDates',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> completedDatesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedDates',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> completedDatesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedDates',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> completedDatesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedDates',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> completedDatesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedDates',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> firstLearnedDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firstLearnedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> firstLearnedDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'firstLearnedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> firstLearnedDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'firstLearnedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> firstLearnedDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'firstLearnedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> isFullyRevisedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFullyRevised',
        value: value,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> scheduledDatesElementEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledDates',
        value: value,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> scheduledDatesElementGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledDates',
        value: value,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> scheduledDatesElementLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledDates',
        value: value,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> scheduledDatesElementBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledDates',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> scheduledDatesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'scheduledDates',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> scheduledDatesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'scheduledDates',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> scheduledDatesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'scheduledDates',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> scheduledDatesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'scheduledDates',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> scheduledDatesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'scheduledDates',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> scheduledDatesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'scheduledDates',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> subjectNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> subjectNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> subjectNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> subjectNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> subjectNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> subjectNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
          QAfterFilterCondition>
      subjectNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
          QAfterFilterCondition>
      subjectNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> subjectNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectName',
        value: '',
      ));
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema,
      QAfterFilterCondition> subjectNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectName',
        value: '',
      ));
    });
  }
}

extension RevisionScheduleSchemaQueryObject on QueryBuilder<
    RevisionScheduleSchema, RevisionScheduleSchema, QFilterCondition> {}

extension RevisionScheduleSchemaQueryLinks on QueryBuilder<
    RevisionScheduleSchema, RevisionScheduleSchema, QFilterCondition> {}

extension RevisionScheduleSchemaQuerySortBy
    on QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QSortBy> {
  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      sortByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.asc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      sortByActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.desc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      sortByChapterName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterName', Sort.asc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      sortByChapterNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterName', Sort.desc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      sortByCompletedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedCount', Sort.asc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      sortByCompletedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedCount', Sort.desc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      sortByFirstLearnedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstLearnedDate', Sort.asc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      sortByFirstLearnedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstLearnedDate', Sort.desc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      sortByIsFullyRevised() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFullyRevised', Sort.asc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      sortByIsFullyRevisedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFullyRevised', Sort.desc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      sortBySubjectName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.asc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      sortBySubjectNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.desc);
    });
  }
}

extension RevisionScheduleSchemaQuerySortThenBy on QueryBuilder<
    RevisionScheduleSchema, RevisionScheduleSchema, QSortThenBy> {
  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      thenByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.asc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      thenByActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'active', Sort.desc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      thenByChapterName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterName', Sort.asc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      thenByChapterNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterName', Sort.desc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      thenByCompletedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedCount', Sort.asc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      thenByCompletedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedCount', Sort.desc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      thenByFirstLearnedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstLearnedDate', Sort.asc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      thenByFirstLearnedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstLearnedDate', Sort.desc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      thenByIsFullyRevised() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFullyRevised', Sort.asc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      thenByIsFullyRevisedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFullyRevised', Sort.desc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      thenBySubjectName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.asc);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QAfterSortBy>
      thenBySubjectNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.desc);
    });
  }
}

extension RevisionScheduleSchemaQueryWhereDistinct
    on QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QDistinct> {
  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QDistinct>
      distinctByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'active');
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QDistinct>
      distinctByChapterName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QDistinct>
      distinctByCompletedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedCount');
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QDistinct>
      distinctByCompletedDates() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedDates');
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QDistinct>
      distinctByFirstLearnedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firstLearnedDate');
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QDistinct>
      distinctByIsFullyRevised() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFullyRevised');
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QDistinct>
      distinctByScheduledDates() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledDates');
    });
  }

  QueryBuilder<RevisionScheduleSchema, RevisionScheduleSchema, QDistinct>
      distinctBySubjectName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectName', caseSensitive: caseSensitive);
    });
  }
}

extension RevisionScheduleSchemaQueryProperty on QueryBuilder<
    RevisionScheduleSchema, RevisionScheduleSchema, QQueryProperty> {
  QueryBuilder<RevisionScheduleSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RevisionScheduleSchema, bool, QQueryOperations>
      activeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'active');
    });
  }

  QueryBuilder<RevisionScheduleSchema, String, QQueryOperations>
      chapterNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterName');
    });
  }

  QueryBuilder<RevisionScheduleSchema, int, QQueryOperations>
      completedCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedCount');
    });
  }

  QueryBuilder<RevisionScheduleSchema, List<DateTime>, QQueryOperations>
      completedDatesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedDates');
    });
  }

  QueryBuilder<RevisionScheduleSchema, DateTime, QQueryOperations>
      firstLearnedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstLearnedDate');
    });
  }

  QueryBuilder<RevisionScheduleSchema, bool, QQueryOperations>
      isFullyRevisedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFullyRevised');
    });
  }

  QueryBuilder<RevisionScheduleSchema, List<DateTime>, QQueryOperations>
      scheduledDatesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledDates');
    });
  }

  QueryBuilder<RevisionScheduleSchema, String, QQueryOperations>
      subjectNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectName');
    });
  }
}
