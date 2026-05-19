// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_entry_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlanEntrySchemaCollection on Isar {
  IsarCollection<PlanEntrySchema> get planEntrySchemas => this.collection();
}

const PlanEntrySchemaSchema = CollectionSchema(
  name: r'PlanEntrySchema',
  id: -699105571442029754,
  properties: {
    r'actualHours': PropertySchema(
      id: 0,
      name: r'actualHours',
      type: IsarType.double,
    ),
    r'chapterName': PropertySchema(
      id: 1,
      name: r'chapterName',
      type: IsarType.string,
    ),
    r'isBufferDay': PropertySchema(
      id: 2,
      name: r'isBufferDay',
      type: IsarType.bool,
    ),
    r'isMockTest': PropertySchema(
      id: 3,
      name: r'isMockTest',
      type: IsarType.bool,
    ),
    r'isRevision': PropertySchema(
      id: 4,
      name: r'isRevision',
      type: IsarType.bool,
    ),
    r'mockTestSubject': PropertySchema(
      id: 5,
      name: r'mockTestSubject',
      type: IsarType.string,
    ),
    r'orderIndex': PropertySchema(
      id: 6,
      name: r'orderIndex',
      type: IsarType.long,
    ),
    r'plannedDate': PropertySchema(
      id: 7,
      name: r'plannedDate',
      type: IsarType.dateTime,
    ),
    r'plannedHours': PropertySchema(
      id: 8,
      name: r'plannedHours',
      type: IsarType.double,
    ),
    r'revisionOf': PropertySchema(
      id: 9,
      name: r'revisionOf',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 10,
      name: r'status',
      type: IsarType.string,
    ),
    r'subjectName': PropertySchema(
      id: 11,
      name: r'subjectName',
      type: IsarType.string,
    )
  },
  estimateSize: _planEntrySchemaEstimateSize,
  serialize: _planEntrySchemaSerialize,
  deserialize: _planEntrySchemaDeserialize,
  deserializeProp: _planEntrySchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'plannedDate': IndexSchema(
      id: -6358396177190863895,
      name: r'plannedDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'plannedDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _planEntrySchemaGetId,
  getLinks: _planEntrySchemaGetLinks,
  attach: _planEntrySchemaAttach,
  version: '3.1.0+1',
);

int _planEntrySchemaEstimateSize(
  PlanEntrySchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.chapterName.length * 3;
  {
    final value = object.mockTestSubject;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.revisionOf;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.subjectName.length * 3;
  return bytesCount;
}

void _planEntrySchemaSerialize(
  PlanEntrySchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.actualHours);
  writer.writeString(offsets[1], object.chapterName);
  writer.writeBool(offsets[2], object.isBufferDay);
  writer.writeBool(offsets[3], object.isMockTest);
  writer.writeBool(offsets[4], object.isRevision);
  writer.writeString(offsets[5], object.mockTestSubject);
  writer.writeLong(offsets[6], object.orderIndex);
  writer.writeDateTime(offsets[7], object.plannedDate);
  writer.writeDouble(offsets[8], object.plannedHours);
  writer.writeString(offsets[9], object.revisionOf);
  writer.writeString(offsets[10], object.status);
  writer.writeString(offsets[11], object.subjectName);
}

PlanEntrySchema _planEntrySchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlanEntrySchema();
  object.actualHours = reader.readDouble(offsets[0]);
  object.chapterName = reader.readString(offsets[1]);
  object.id = id;
  object.isBufferDay = reader.readBool(offsets[2]);
  object.isMockTest = reader.readBool(offsets[3]);
  object.isRevision = reader.readBool(offsets[4]);
  object.mockTestSubject = reader.readStringOrNull(offsets[5]);
  object.orderIndex = reader.readLong(offsets[6]);
  object.plannedDate = reader.readDateTime(offsets[7]);
  object.plannedHours = reader.readDouble(offsets[8]);
  object.revisionOf = reader.readStringOrNull(offsets[9]);
  object.status = reader.readString(offsets[10]);
  object.subjectName = reader.readString(offsets[11]);
  return object;
}

P _planEntrySchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _planEntrySchemaGetId(PlanEntrySchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _planEntrySchemaGetLinks(PlanEntrySchema object) {
  return [];
}

void _planEntrySchemaAttach(
    IsarCollection<dynamic> col, Id id, PlanEntrySchema object) {
  object.id = id;
}

extension PlanEntrySchemaQueryWhereSort
    on QueryBuilder<PlanEntrySchema, PlanEntrySchema, QWhere> {
  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterWhere> anyPlannedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'plannedDate'),
      );
    });
  }
}

extension PlanEntrySchemaQueryWhere
    on QueryBuilder<PlanEntrySchema, PlanEntrySchema, QWhereClause> {
  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterWhereClause>
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

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterWhereClause> idBetween(
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

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterWhereClause>
      plannedDateEqualTo(DateTime plannedDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'plannedDate',
        value: [plannedDate],
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterWhereClause>
      plannedDateNotEqualTo(DateTime plannedDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'plannedDate',
              lower: [],
              upper: [plannedDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'plannedDate',
              lower: [plannedDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'plannedDate',
              lower: [plannedDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'plannedDate',
              lower: [],
              upper: [plannedDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterWhereClause>
      plannedDateGreaterThan(
    DateTime plannedDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'plannedDate',
        lower: [plannedDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterWhereClause>
      plannedDateLessThan(
    DateTime plannedDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'plannedDate',
        lower: [],
        upper: [plannedDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterWhereClause>
      plannedDateBetween(
    DateTime lowerPlannedDate,
    DateTime upperPlannedDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'plannedDate',
        lower: [lowerPlannedDate],
        includeLower: includeLower,
        upper: [upperPlannedDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PlanEntrySchemaQueryFilter
    on QueryBuilder<PlanEntrySchema, PlanEntrySchema, QFilterCondition> {
  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      actualHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actualHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      actualHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actualHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      actualHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actualHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      actualHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actualHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
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

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      chapterNameGreaterThan(
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

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      chapterNameLessThan(
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

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      chapterNameBetween(
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

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      chapterNameStartsWith(
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

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      chapterNameEndsWith(
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

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      chapterNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chapterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      chapterNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chapterName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      chapterNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterName',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      chapterNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chapterName',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
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

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
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

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
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

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      isBufferDayEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isBufferDay',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      isMockTestEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMockTest',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      isRevisionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isRevision',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      mockTestSubjectIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mockTestSubject',
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      mockTestSubjectIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mockTestSubject',
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      mockTestSubjectEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mockTestSubject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      mockTestSubjectGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mockTestSubject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      mockTestSubjectLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mockTestSubject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      mockTestSubjectBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mockTestSubject',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      mockTestSubjectStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mockTestSubject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      mockTestSubjectEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mockTestSubject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      mockTestSubjectContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mockTestSubject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      mockTestSubjectMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mockTestSubject',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      mockTestSubjectIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mockTestSubject',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      mockTestSubjectIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mockTestSubject',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      orderIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      orderIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'orderIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      orderIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'orderIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      orderIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'orderIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      plannedDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'plannedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      plannedDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'plannedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      plannedDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'plannedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      plannedDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'plannedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      plannedHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'plannedHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      plannedHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'plannedHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      plannedHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'plannedHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      plannedHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'plannedHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      revisionOfIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'revisionOf',
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      revisionOfIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'revisionOf',
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      revisionOfEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'revisionOf',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      revisionOfGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'revisionOf',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      revisionOfLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'revisionOf',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      revisionOfBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'revisionOf',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      revisionOfStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'revisionOf',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      revisionOfEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'revisionOf',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      revisionOfContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'revisionOf',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      revisionOfMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'revisionOf',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      revisionOfIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'revisionOf',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      revisionOfIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'revisionOf',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
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

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      subjectNameGreaterThan(
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

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      subjectNameLessThan(
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

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      subjectNameBetween(
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

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      subjectNameStartsWith(
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

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      subjectNameEndsWith(
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

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      subjectNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      subjectNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      subjectNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectName',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterFilterCondition>
      subjectNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectName',
        value: '',
      ));
    });
  }
}

extension PlanEntrySchemaQueryObject
    on QueryBuilder<PlanEntrySchema, PlanEntrySchema, QFilterCondition> {}

extension PlanEntrySchemaQueryLinks
    on QueryBuilder<PlanEntrySchema, PlanEntrySchema, QFilterCondition> {}

extension PlanEntrySchemaQuerySortBy
    on QueryBuilder<PlanEntrySchema, PlanEntrySchema, QSortBy> {
  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByActualHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualHours', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByActualHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualHours', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByChapterName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterName', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByChapterNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterName', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByIsBufferDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBufferDay', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByIsBufferDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBufferDay', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByIsMockTest() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMockTest', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByIsMockTestDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMockTest', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByIsRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRevision', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByIsRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRevision', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByMockTestSubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mockTestSubject', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByMockTestSubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mockTestSubject', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByOrderIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByPlannedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDate', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByPlannedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDate', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByPlannedHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedHours', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByPlannedHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedHours', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByRevisionOf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revisionOf', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByRevisionOfDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revisionOf', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortBySubjectName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      sortBySubjectNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.desc);
    });
  }
}

extension PlanEntrySchemaQuerySortThenBy
    on QueryBuilder<PlanEntrySchema, PlanEntrySchema, QSortThenBy> {
  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByActualHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualHours', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByActualHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualHours', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByChapterName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterName', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByChapterNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterName', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByIsBufferDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBufferDay', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByIsBufferDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBufferDay', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByIsMockTest() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMockTest', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByIsMockTestDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMockTest', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByIsRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRevision', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByIsRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRevision', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByMockTestSubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mockTestSubject', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByMockTestSubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mockTestSubject', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByOrderIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByPlannedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDate', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByPlannedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDate', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByPlannedHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedHours', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByPlannedHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedHours', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByRevisionOf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revisionOf', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByRevisionOfDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revisionOf', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenBySubjectName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.asc);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QAfterSortBy>
      thenBySubjectNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.desc);
    });
  }
}

extension PlanEntrySchemaQueryWhereDistinct
    on QueryBuilder<PlanEntrySchema, PlanEntrySchema, QDistinct> {
  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QDistinct>
      distinctByActualHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualHours');
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QDistinct>
      distinctByChapterName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QDistinct>
      distinctByIsBufferDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBufferDay');
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QDistinct>
      distinctByIsMockTest() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMockTest');
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QDistinct>
      distinctByIsRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRevision');
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QDistinct>
      distinctByMockTestSubject({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mockTestSubject',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QDistinct>
      distinctByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderIndex');
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QDistinct>
      distinctByPlannedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plannedDate');
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QDistinct>
      distinctByPlannedHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plannedHours');
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QDistinct>
      distinctByRevisionOf({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'revisionOf', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlanEntrySchema, PlanEntrySchema, QDistinct>
      distinctBySubjectName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectName', caseSensitive: caseSensitive);
    });
  }
}

extension PlanEntrySchemaQueryProperty
    on QueryBuilder<PlanEntrySchema, PlanEntrySchema, QQueryProperty> {
  QueryBuilder<PlanEntrySchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlanEntrySchema, double, QQueryOperations>
      actualHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualHours');
    });
  }

  QueryBuilder<PlanEntrySchema, String, QQueryOperations>
      chapterNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterName');
    });
  }

  QueryBuilder<PlanEntrySchema, bool, QQueryOperations> isBufferDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBufferDay');
    });
  }

  QueryBuilder<PlanEntrySchema, bool, QQueryOperations> isMockTestProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMockTest');
    });
  }

  QueryBuilder<PlanEntrySchema, bool, QQueryOperations> isRevisionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRevision');
    });
  }

  QueryBuilder<PlanEntrySchema, String?, QQueryOperations>
      mockTestSubjectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mockTestSubject');
    });
  }

  QueryBuilder<PlanEntrySchema, int, QQueryOperations> orderIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderIndex');
    });
  }

  QueryBuilder<PlanEntrySchema, DateTime, QQueryOperations>
      plannedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plannedDate');
    });
  }

  QueryBuilder<PlanEntrySchema, double, QQueryOperations>
      plannedHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plannedHours');
    });
  }

  QueryBuilder<PlanEntrySchema, String?, QQueryOperations>
      revisionOfProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'revisionOf');
    });
  }

  QueryBuilder<PlanEntrySchema, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<PlanEntrySchema, String, QQueryOperations>
      subjectNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectName');
    });
  }
}
