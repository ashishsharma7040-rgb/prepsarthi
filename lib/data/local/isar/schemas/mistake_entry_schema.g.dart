// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mistake_entry_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMistakeEntrySchemaCollection on Isar {
  IsarCollection<MistakeEntrySchema> get mistakeEntrySchemas =>
      this.collection();
}

const MistakeEntrySchemaSchema = CollectionSchema(
  name: r'MistakeEntrySchema',
  id: -2986781068699452834,
  properties: {
    r'chapterName': PropertySchema(
      id: 0,
      name: r'chapterName',
      type: IsarType.string,
    ),
    r'correctApproach': PropertySchema(
      id: 1,
      name: r'correctApproach',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'date': PropertySchema(
      id: 3,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'isResolved': PropertySchema(
      id: 4,
      name: r'isResolved',
      type: IsarType.bool,
    ),
    r'mistakeTypeIndex': PropertySchema(
      id: 5,
      name: r'mistakeTypeIndex',
      type: IsarType.long,
    ),
    r'questionSummary': PropertySchema(
      id: 6,
      name: r'questionSummary',
      type: IsarType.string,
    ),
    r'resolvedAt': PropertySchema(
      id: 7,
      name: r'resolvedAt',
      type: IsarType.dateTime,
    ),
    r'subjectName': PropertySchema(
      id: 8,
      name: r'subjectName',
      type: IsarType.string,
    ),
    r'testName': PropertySchema(
      id: 9,
      name: r'testName',
      type: IsarType.string,
    )
  },
  estimateSize: _mistakeEntrySchemaEstimateSize,
  serialize: _mistakeEntrySchemaSerialize,
  deserialize: _mistakeEntrySchemaDeserialize,
  deserializeProp: _mistakeEntrySchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: 1251174398498568780,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'chapterName': IndexSchema(
      id: 8348268986590834461,
      name: r'chapterName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'chapterName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'subjectName': IndexSchema(
      id: -4385583183438878820,
      name: r'subjectName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'subjectName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isResolved': IndexSchema(
      id: 5765586762074638419,
      name: r'isResolved',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isResolved',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _mistakeEntrySchemaGetId,
  getLinks: _mistakeEntrySchemaGetLinks,
  attach: _mistakeEntrySchemaAttach,
  version: '3.1.0+1',
);

int _mistakeEntrySchemaEstimateSize(
  MistakeEntrySchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.chapterName.length * 3;
  bytesCount += 3 + object.correctApproach.length * 3;
  bytesCount += 3 + object.questionSummary.length * 3;
  bytesCount += 3 + object.subjectName.length * 3;
  {
    final value = object.testName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _mistakeEntrySchemaSerialize(
  MistakeEntrySchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.chapterName);
  writer.writeString(offsets[1], object.correctApproach);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeDateTime(offsets[3], object.date);
  writer.writeBool(offsets[4], object.isResolved);
  writer.writeLong(offsets[5], object.mistakeTypeIndex);
  writer.writeString(offsets[6], object.questionSummary);
  writer.writeDateTime(offsets[7], object.resolvedAt);
  writer.writeString(offsets[8], object.subjectName);
  writer.writeString(offsets[9], object.testName);
}

MistakeEntrySchema _mistakeEntrySchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MistakeEntrySchema();
  object.chapterName = reader.readString(offsets[0]);
  object.correctApproach = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.date = reader.readDateTime(offsets[3]);
  object.id = id;
  object.isResolved = reader.readBool(offsets[4]);
  object.mistakeTypeIndex = reader.readLong(offsets[5]);
  object.questionSummary = reader.readString(offsets[6]);
  object.resolvedAt = reader.readDateTimeOrNull(offsets[7]);
  object.subjectName = reader.readString(offsets[8]);
  object.testName = reader.readStringOrNull(offsets[9]);
  return object;
}

P _mistakeEntrySchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _mistakeEntrySchemaGetId(MistakeEntrySchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mistakeEntrySchemaGetLinks(
    MistakeEntrySchema object) {
  return [];
}

void _mistakeEntrySchemaAttach(
    IsarCollection<dynamic> col, Id id, MistakeEntrySchema object) {
  object.id = id;
}

extension MistakeEntrySchemaQueryWhereSort
    on QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QWhere> {
  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension MistakeEntrySchemaQueryWhere
    on QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QWhereClause> {
  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhereClause>
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

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhereClause>
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

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhereClause>
      dateEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhereClause>
      dateNotEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhereClause>
      dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhereClause>
      dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhereClause>
      dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhereClause>
      chapterNameEqualTo(String chapterName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'chapterName',
        value: [chapterName],
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhereClause>
      chapterNameNotEqualTo(String chapterName) {
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

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhereClause>
      subjectNameEqualTo(String subjectName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subjectName',
        value: [subjectName],
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhereClause>
      subjectNameNotEqualTo(String subjectName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectName',
              lower: [],
              upper: [subjectName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectName',
              lower: [subjectName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectName',
              lower: [subjectName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectName',
              lower: [],
              upper: [subjectName],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhereClause>
      isResolvedEqualTo(bool isResolved) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isResolved',
        value: [isResolved],
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterWhereClause>
      isResolvedNotEqualTo(bool isResolved) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isResolved',
              lower: [],
              upper: [isResolved],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isResolved',
              lower: [isResolved],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isResolved',
              lower: [isResolved],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isResolved',
              lower: [],
              upper: [isResolved],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MistakeEntrySchemaQueryFilter
    on QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QFilterCondition> {
  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      chapterNameEqualTo(
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

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      chapterNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chapterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      chapterNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterName',
        value: '',
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      chapterNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chapterName',
        value: '',
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      correctApproachEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctApproach',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      correctApproachContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'correctApproach',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
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

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
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

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
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

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
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

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      isResolvedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isResolved',
        value: value,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      mistakeTypeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mistakeTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      mistakeTypeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mistakeTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      mistakeTypeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mistakeTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      mistakeTypeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mistakeTypeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      questionSummaryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questionSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      questionSummaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'questionSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      resolvedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'resolvedAt',
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      resolvedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'resolvedAt',
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      resolvedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resolvedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      resolvedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'resolvedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      resolvedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'resolvedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      subjectNameEqualTo(
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

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      subjectNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      subjectNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectName',
        value: '',
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      subjectNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectName',
        value: '',
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      testNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'testName',
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      testNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'testName',
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      testNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'testName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterFilterCondition>
      testNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'testName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }
}

extension MistakeEntrySchemaQueryObject
    on QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QFilterCondition> {}

extension MistakeEntrySchemaQueryLinks
    on QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QFilterCondition> {}

extension MistakeEntrySchemaQuerySortBy
    on QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QSortBy> {
  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      sortByChapterName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterName', Sort.asc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      sortByChapterNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterName', Sort.desc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      sortByIsResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.asc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      sortByIsResolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.desc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      sortByMistakeTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mistakeTypeIndex', Sort.asc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      sortByMistakeTypeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mistakeTypeIndex', Sort.desc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      sortBySubjectName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.asc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      sortBySubjectNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.desc);
    });
  }
}

extension MistakeEntrySchemaQuerySortThenBy
    on QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QSortThenBy> {
  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      thenByChapterName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterName', Sort.asc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      thenByChapterNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterName', Sort.desc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      thenByIsResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.asc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      thenByIsResolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isResolved', Sort.desc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      thenByMistakeTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mistakeTypeIndex', Sort.asc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      thenByMistakeTypeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mistakeTypeIndex', Sort.desc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      thenBySubjectName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.asc);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QAfterSortBy>
      thenBySubjectNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.desc);
    });
  }
}

extension MistakeEntrySchemaQueryWhereDistinct
    on QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QDistinct> {
  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QDistinct>
      distinctByChapterName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QDistinct>
      distinctByIsResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isResolved');
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QDistinct>
      distinctByMistakeTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mistakeTypeIndex');
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QDistinct>
      distinctBySubjectName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QDistinct>
      distinctByTestName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'testName', caseSensitive: caseSensitive);
    });
  }
}

extension MistakeEntrySchemaQueryProperty
    on QueryBuilder<MistakeEntrySchema, MistakeEntrySchema, QQueryProperty> {
  QueryBuilder<MistakeEntrySchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MistakeEntrySchema, String, QQueryOperations>
      chapterNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterName');
    });
  }

  QueryBuilder<MistakeEntrySchema, String, QQueryOperations>
      correctApproachProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctApproach');
    });
  }

  QueryBuilder<MistakeEntrySchema, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MistakeEntrySchema, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<MistakeEntrySchema, bool, QQueryOperations>
      isResolvedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isResolved');
    });
  }

  QueryBuilder<MistakeEntrySchema, int, QQueryOperations>
      mistakeTypeIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mistakeTypeIndex');
    });
  }

  QueryBuilder<MistakeEntrySchema, String, QQueryOperations>
      questionSummaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'questionSummary');
    });
  }

  QueryBuilder<MistakeEntrySchema, DateTime?, QQueryOperations>
      resolvedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resolvedAt');
    });
  }

  QueryBuilder<MistakeEntrySchema, String, QQueryOperations>
      subjectNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectName');
    });
  }

  QueryBuilder<MistakeEntrySchema, String?, QQueryOperations>
      testNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'testName');
    });
  }
}
