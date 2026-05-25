// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_test_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMockTestSchemaCollection on Isar {
  IsarCollection<MockTestSchema> get mockTestSchemas => this.collection();
}

const MockTestSchemaSchema = CollectionSchema(
  name: r'MockTestSchema',
  id: 5038214670270498145,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'examType': PropertySchema(
      id: 2,
      name: r'examType',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 3,
      name: r'notes',
      type: IsarType.string,
    ),
    r'obtainedMarks': PropertySchema(
      id: 4,
      name: r'obtainedMarks',
      type: IsarType.long,
    ),
    r'subjectMarksJson': PropertySchema(
      id: 5,
      name: r'subjectMarksJson',
      type: IsarType.string,
    ),
    r'subjectMaxJson': PropertySchema(
      id: 6,
      name: r'subjectMaxJson',
      type: IsarType.string,
    ),
    r'testName': PropertySchema(
      id: 7,
      name: r'testName',
      type: IsarType.string,
    ),
    r'totalMarks': PropertySchema(
      id: 8,
      name: r'totalMarks',
      type: IsarType.long,
    )
  },
  estimateSize: _mockTestSchemaEstimateSize,
  serialize: _mockTestSchemaSerialize,
  deserialize: _mockTestSchemaDeserialize,
  deserializeProp: _mockTestSchemaDeserializeProp,
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
    r'examType': IndexSchema(
      id: -3271694080397476944,
      name: r'examType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'examType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _mockTestSchemaGetId,
  getLinks: _mockTestSchemaGetLinks,
  attach: _mockTestSchemaAttach,
  version: '3.1.0+1',
);

int _mockTestSchemaEstimateSize(
  MockTestSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.examType.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.subjectMarksJson.length * 3;
  bytesCount += 3 + object.subjectMaxJson.length * 3;
  bytesCount += 3 + object.testName.length * 3;
  return bytesCount;
}

void _mockTestSchemaSerialize(
  MockTestSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeString(offsets[2], object.examType);
  writer.writeString(offsets[3], object.notes);
  writer.writeLong(offsets[4], object.obtainedMarks);
  writer.writeString(offsets[5], object.subjectMarksJson);
  writer.writeString(offsets[6], object.subjectMaxJson);
  writer.writeString(offsets[7], object.testName);
  writer.writeLong(offsets[8], object.totalMarks);
}

MockTestSchema _mockTestSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MockTestSchema();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.examType = reader.readString(offsets[2]);
  object.id = id;
  object.notes = reader.readStringOrNull(offsets[3]);
  object.obtainedMarks = reader.readLong(offsets[4]);
  object.subjectMarksJson = reader.readString(offsets[5]);
  object.subjectMaxJson = reader.readString(offsets[6]);
  object.testName = reader.readString(offsets[7]);
  object.totalMarks = reader.readLong(offsets[8]);
  return object;
}

P _mockTestSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _mockTestSchemaGetId(MockTestSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mockTestSchemaGetLinks(MockTestSchema object) {
  return [];
}

void _mockTestSchemaAttach(
    IsarCollection<dynamic> col, Id id, MockTestSchema object) {
  object.id = id;
}

extension MockTestSchemaQueryWhereSort
    on QueryBuilder<MockTestSchema, MockTestSchema, QWhere> {
  QueryBuilder<MockTestSchema, MockTestSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension MockTestSchemaQueryWhere
    on QueryBuilder<MockTestSchema, MockTestSchema, QWhereClause> {
  QueryBuilder<MockTestSchema, MockTestSchema, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterWhereClause> idBetween(
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

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterWhereClause>
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

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterWhereClause>
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

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterWhereClause> dateLessThan(
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

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterWhereClause> dateBetween(
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

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterWhereClause>
      examTypeEqualTo(String examType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'examType',
        value: [examType],
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterWhereClause>
      examTypeNotEqualTo(String examType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'examType',
              lower: [],
              upper: [examType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'examType',
              lower: [examType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'examType',
              lower: [examType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'examType',
              lower: [],
              upper: [examType],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MockTestSchemaQueryFilter
    on QueryBuilder<MockTestSchema, MockTestSchema, QFilterCondition> {
  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
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

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
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

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
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

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
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

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
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

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      examTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'examType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      examTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'examType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      examTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'examType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      examTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'examType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      examTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'examType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      examTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'examType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      examTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'examType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      examTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'examType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      examTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'examType',
        value: '',
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      examTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'examType',
        value: '',
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
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

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
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

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      obtainedMarksEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'obtainedMarks',
        value: value,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      obtainedMarksGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'obtainedMarks',
        value: value,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      obtainedMarksLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'obtainedMarks',
        value: value,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      obtainedMarksBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'obtainedMarks',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      subjectMarksJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectMarksJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      subjectMarksJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectMarksJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      subjectMarksJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectMarksJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      subjectMarksJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectMarksJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      subjectMaxJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectMaxJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      subjectMaxJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectMaxJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      subjectMaxJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectMaxJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      subjectMaxJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectMaxJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      testNameEqualTo(
    String value, {
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

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      testNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'testName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      testNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'testName',
        value: '',
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      testNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'testName',
        value: '',
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      totalMarksEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalMarks',
        value: value,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      totalMarksGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalMarks',
        value: value,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      totalMarksLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalMarks',
        value: value,
      ));
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterFilterCondition>
      totalMarksBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalMarks',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MockTestSchemaQueryObject
    on QueryBuilder<MockTestSchema, MockTestSchema, QFilterCondition> {}

extension MockTestSchemaQueryLinks
    on QueryBuilder<MockTestSchema, MockTestSchema, QFilterCondition> {}

extension MockTestSchemaQuerySortBy
    on QueryBuilder<MockTestSchema, MockTestSchema, QSortBy> {
  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy> sortByExamType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examType', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      sortByExamTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examType', Sort.desc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      sortByObtainedMarks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'obtainedMarks', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      sortByObtainedMarksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'obtainedMarks', Sort.desc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      sortBySubjectMarksJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectMarksJson', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      sortBySubjectMarksJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectMarksJson', Sort.desc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      sortBySubjectMaxJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectMaxJson', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      sortBySubjectMaxJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectMaxJson', Sort.desc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy> sortByTestName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testName', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      sortByTestNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testName', Sort.desc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      sortByTotalMarks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMarks', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      sortByTotalMarksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMarks', Sort.desc);
    });
  }
}

extension MockTestSchemaQuerySortThenBy
    on QueryBuilder<MockTestSchema, MockTestSchema, QSortThenBy> {
  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy> thenByExamType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examType', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      thenByExamTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examType', Sort.desc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      thenByObtainedMarks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'obtainedMarks', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      thenByObtainedMarksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'obtainedMarks', Sort.desc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      thenBySubjectMarksJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectMarksJson', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      thenBySubjectMarksJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectMarksJson', Sort.desc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      thenBySubjectMaxJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectMaxJson', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      thenBySubjectMaxJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectMaxJson', Sort.desc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy> thenByTestName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testName', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      thenByTestNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testName', Sort.desc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      thenByTotalMarks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMarks', Sort.asc);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QAfterSortBy>
      thenByTotalMarksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMarks', Sort.desc);
    });
  }
}

extension MockTestSchemaQueryWhereDistinct
    on QueryBuilder<MockTestSchema, MockTestSchema, QDistinct> {
  QueryBuilder<MockTestSchema, MockTestSchema, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QDistinct> distinctByExamType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'examType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QDistinct>
      distinctByObtainedMarks() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'obtainedMarks');
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QDistinct>
      distinctBySubjectMarksJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectMarksJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QDistinct>
      distinctBySubjectMaxJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectMaxJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QDistinct> distinctByTestName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'testName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MockTestSchema, MockTestSchema, QDistinct>
      distinctByTotalMarks() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalMarks');
    });
  }
}

extension MockTestSchemaQueryProperty
    on QueryBuilder<MockTestSchema, MockTestSchema, QQueryProperty> {
  QueryBuilder<MockTestSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MockTestSchema, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MockTestSchema, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<MockTestSchema, String, QQueryOperations> examTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'examType');
    });
  }

  QueryBuilder<MockTestSchema, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<MockTestSchema, int, QQueryOperations> obtainedMarksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'obtainedMarks');
    });
  }

  QueryBuilder<MockTestSchema, String, QQueryOperations>
      subjectMarksJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectMarksJson');
    });
  }

  QueryBuilder<MockTestSchema, String, QQueryOperations>
      subjectMaxJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectMaxJson');
    });
  }

  QueryBuilder<MockTestSchema, String, QQueryOperations> testNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'testName');
    });
  }

  QueryBuilder<MockTestSchema, int, QQueryOperations> totalMarksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalMarks');
    });
  }
}
