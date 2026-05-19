// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_log_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStudyLogSchemaCollection on Isar {
  IsarCollection<StudyLogSchema> get studyLogSchemas => this.collection();
}

const StudyLogSchemaSchema = CollectionSchema(
  name: r'StudyLogSchema',
  id: -1309314849253731000,
  properties: {
    r'activityTag': PropertySchema(
      id: 0,
      name: r'activityTag',
      type: IsarType.string,
    ),
    r'chapterName': PropertySchema(
      id: 1,
      name: r'chapterName',
      type: IsarType.string,
    ),
    r'hoursStudied': PropertySchema(
      id: 2,
      name: r'hoursStudied',
      type: IsarType.double,
    ),
    r'isPomodoro': PropertySchema(
      id: 3,
      name: r'isPomodoro',
      type: IsarType.bool,
    ),
    r'notes': PropertySchema(
      id: 4,
      name: r'notes',
      type: IsarType.string,
    ),
    r'pomodoroSessions': PropertySchema(
      id: 5,
      name: r'pomodoroSessions',
      type: IsarType.long,
    ),
    r'subjectName': PropertySchema(
      id: 6,
      name: r'subjectName',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 7,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _studyLogSchemaEstimateSize,
  serialize: _studyLogSchemaSerialize,
  deserialize: _studyLogSchemaDeserialize,
  deserializeProp: _studyLogSchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _studyLogSchemaGetId,
  getLinks: _studyLogSchemaGetLinks,
  attach: _studyLogSchemaAttach,
  version: '3.1.0+1',
);

int _studyLogSchemaEstimateSize(
  StudyLogSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activityTag.length * 3;
  bytesCount += 3 + object.chapterName.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.subjectName.length * 3;
  return bytesCount;
}

void _studyLogSchemaSerialize(
  StudyLogSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activityTag);
  writer.writeString(offsets[1], object.chapterName);
  writer.writeDouble(offsets[2], object.hoursStudied);
  writer.writeBool(offsets[3], object.isPomodoro);
  writer.writeString(offsets[4], object.notes);
  writer.writeLong(offsets[5], object.pomodoroSessions);
  writer.writeString(offsets[6], object.subjectName);
  writer.writeDateTime(offsets[7], object.timestamp);
}

StudyLogSchema _studyLogSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StudyLogSchema();
  object.activityTag = reader.readString(offsets[0]);
  object.chapterName = reader.readString(offsets[1]);
  object.hoursStudied = reader.readDouble(offsets[2]);
  object.id = id;
  object.isPomodoro = reader.readBool(offsets[3]);
  object.notes = reader.readStringOrNull(offsets[4]);
  object.pomodoroSessions = reader.readLong(offsets[5]);
  object.subjectName = reader.readString(offsets[6]);
  object.timestamp = reader.readDateTime(offsets[7]);
  return object;
}

P _studyLogSchemaDeserializeProp<P>(
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
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _studyLogSchemaGetId(StudyLogSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _studyLogSchemaGetLinks(StudyLogSchema object) {
  return [];
}

void _studyLogSchemaAttach(
    IsarCollection<dynamic> col, Id id, StudyLogSchema object) {
  object.id = id;
}

extension StudyLogSchemaQueryWhereSort
    on QueryBuilder<StudyLogSchema, StudyLogSchema, QWhere> {
  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension StudyLogSchemaQueryWhere
    on QueryBuilder<StudyLogSchema, StudyLogSchema, QWhereClause> {
  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterWhereClause> idBetween(
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterWhereClause>
      timestampEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterWhereClause>
      timestampNotEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterWhereClause>
      timestampGreaterThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [timestamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterWhereClause>
      timestampLessThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [],
        upper: [timestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterWhereClause>
      timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [lowerTimestamp],
        includeLower: includeLower,
        upper: [upperTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension StudyLogSchemaQueryFilter
    on QueryBuilder<StudyLogSchema, StudyLogSchema, QFilterCondition> {
  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      activityTagEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      activityTagGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activityTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      activityTagLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activityTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      activityTagBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activityTag',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      activityTagStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activityTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      activityTagEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activityTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      activityTagContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activityTag',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      activityTagMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activityTag',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      activityTagIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityTag',
        value: '',
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      activityTagIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activityTag',
        value: '',
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      chapterNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chapterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      chapterNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chapterName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      chapterNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterName',
        value: '',
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      chapterNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chapterName',
        value: '',
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      hoursStudiedEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hoursStudied',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      hoursStudiedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hoursStudied',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      hoursStudiedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hoursStudied',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      hoursStudiedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hoursStudied',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition> idBetween(
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      isPomodoroEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPomodoro',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      pomodoroSessionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pomodoroSessions',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      pomodoroSessionsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pomodoroSessions',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      pomodoroSessionsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pomodoroSessions',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      pomodoroSessionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pomodoroSessions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
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

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      subjectNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      subjectNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      subjectNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectName',
        value: '',
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      subjectNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectName',
        value: '',
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension StudyLogSchemaQueryObject
    on QueryBuilder<StudyLogSchema, StudyLogSchema, QFilterCondition> {}

extension StudyLogSchemaQueryLinks
    on QueryBuilder<StudyLogSchema, StudyLogSchema, QFilterCondition> {}

extension StudyLogSchemaQuerySortBy
    on QueryBuilder<StudyLogSchema, StudyLogSchema, QSortBy> {
  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      sortByActivityTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityTag', Sort.asc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      sortByActivityTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityTag', Sort.desc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      sortByChapterName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterName', Sort.asc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      sortByChapterNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterName', Sort.desc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      sortByHoursStudied() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hoursStudied', Sort.asc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      sortByHoursStudiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hoursStudied', Sort.desc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      sortByIsPomodoro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPomodoro', Sort.asc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      sortByIsPomodoroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPomodoro', Sort.desc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      sortByPomodoroSessions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroSessions', Sort.asc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      sortByPomodoroSessionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroSessions', Sort.desc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      sortBySubjectName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.asc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      sortBySubjectNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.desc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension StudyLogSchemaQuerySortThenBy
    on QueryBuilder<StudyLogSchema, StudyLogSchema, QSortThenBy> {
  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      thenByActivityTag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityTag', Sort.asc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      thenByActivityTagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityTag', Sort.desc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      thenByChapterName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterName', Sort.asc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      thenByChapterNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterName', Sort.desc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      thenByHoursStudied() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hoursStudied', Sort.asc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      thenByHoursStudiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hoursStudied', Sort.desc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      thenByIsPomodoro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPomodoro', Sort.asc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      thenByIsPomodoroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPomodoro', Sort.desc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      thenByPomodoroSessions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroSessions', Sort.asc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      thenByPomodoroSessionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pomodoroSessions', Sort.desc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      thenBySubjectName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.asc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      thenBySubjectNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.desc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension StudyLogSchemaQueryWhereDistinct
    on QueryBuilder<StudyLogSchema, StudyLogSchema, QDistinct> {
  QueryBuilder<StudyLogSchema, StudyLogSchema, QDistinct> distinctByActivityTag(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activityTag', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QDistinct> distinctByChapterName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QDistinct>
      distinctByHoursStudied() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hoursStudied');
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QDistinct>
      distinctByIsPomodoro() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPomodoro');
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QDistinct>
      distinctByPomodoroSessions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pomodoroSessions');
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QDistinct> distinctBySubjectName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudyLogSchema, StudyLogSchema, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension StudyLogSchemaQueryProperty
    on QueryBuilder<StudyLogSchema, StudyLogSchema, QQueryProperty> {
  QueryBuilder<StudyLogSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StudyLogSchema, String, QQueryOperations> activityTagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activityTag');
    });
  }

  QueryBuilder<StudyLogSchema, String, QQueryOperations> chapterNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterName');
    });
  }

  QueryBuilder<StudyLogSchema, double, QQueryOperations>
      hoursStudiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hoursStudied');
    });
  }

  QueryBuilder<StudyLogSchema, bool, QQueryOperations> isPomodoroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPomodoro');
    });
  }

  QueryBuilder<StudyLogSchema, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<StudyLogSchema, int, QQueryOperations>
      pomodoroSessionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pomodoroSessions');
    });
  }

  QueryBuilder<StudyLogSchema, String, QQueryOperations> subjectNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectName');
    });
  }

  QueryBuilder<StudyLogSchema, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
