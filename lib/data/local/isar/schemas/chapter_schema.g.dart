// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_schema.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChapterSchemaCollection on Isar {
  IsarCollection<ChapterSchema> get chapterSchemas => this.collection();
}

const ChapterSchemaSchema = CollectionSchema(
  name: r'ChapterSchema',
  id: -746740756433934859,
  properties: {
    r'calculationMistakes': PropertySchema(
      id: 0,
      name: r'calculationMistakes',
      type: IsarType.long,
    ),
    r'classLevel': PropertySchema(
      id: 1,
      name: r'classLevel',
      type: IsarType.long,
    ),
    r'conceptualMistakes': PropertySchema(
      id: 2,
      name: r'conceptualMistakes',
      type: IsarType.long,
    ),
    r'difficulty': PropertySchema(
      id: 3,
      name: r'difficulty',
      type: IsarType.long,
    ),
    r'estimatedHours': PropertySchema(
      id: 4,
      name: r'estimatedHours',
      type: IsarType.double,
    ),
    r'firstLearnedDate': PropertySchema(
      id: 5,
      name: r'firstLearnedDate',
      type: IsarType.dateTime,
    ),
    r'hoursSpent': PropertySchema(
      id: 6,
      name: r'hoursSpent',
      type: IsarType.double,
    ),
    r'isPriorityRevision': PropertySchema(
      id: 7,
      name: r'isPriorityRevision',
      type: IsarType.bool,
    ),
    r'isWeakChapter': PropertySchema(
      id: 8,
      name: r'isWeakChapter',
      type: IsarType.bool,
    ),
    r'lastStudiedDate': PropertySchema(
      id: 9,
      name: r'lastStudiedDate',
      type: IsarType.dateTime,
    ),
    r'masteryLabel': PropertySchema(
      id: 10,
      name: r'masteryLabel',
      type: IsarType.string,
    ),
    r'masteryLevel': PropertySchema(
      id: 11,
      name: r'masteryLevel',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 12,
      name: r'name',
      type: IsarType.string,
    ),
    r'progressFraction': PropertySchema(
      id: 13,
      name: r'progressFraction',
      type: IsarType.double,
    ),
    r'pyqCount': PropertySchema(
      id: 14,
      name: r'pyqCount',
      type: IsarType.long,
    ),
    r'pyqProgress': PropertySchema(
      id: 15,
      name: r'pyqProgress',
      type: IsarType.long,
    ),
    r'pyqProgressLabel': PropertySchema(
      id: 16,
      name: r'pyqProgressLabel',
      type: IsarType.string,
    ),
    r'revisionCount': PropertySchema(
      id: 17,
      name: r'revisionCount',
      type: IsarType.long,
    ),
    r'sillyMistakes': PropertySchema(
      id: 18,
      name: r'sillyMistakes',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 19,
      name: r'status',
      type: IsarType.string,
    ),
    r'subjectName': PropertySchema(
      id: 20,
      name: r'subjectName',
      type: IsarType.string,
    ),
    r'syllabusSource': PropertySchema(
      id: 21,
      name: r'syllabusSource',
      type: IsarType.string,
    ),
    r'tags': PropertySchema(
      id: 22,
      name: r'tags',
      type: IsarType.stringList,
    ),
    r'testAccuracy': PropertySchema(
      id: 23,
      name: r'testAccuracy',
      type: IsarType.double,
    ),
    r'testAttempts': PropertySchema(
      id: 24,
      name: r'testAttempts',
      type: IsarType.long,
    ),
    r'testCorrect': PropertySchema(
      id: 25,
      name: r'testCorrect',
      type: IsarType.long,
    ),
    r'weightage': PropertySchema(
      id: 26,
      name: r'weightage',
      type: IsarType.double,
    )
  },
  estimateSize: _chapterSchemaEstimateSize,
  serialize: _chapterSchemaSerialize,
  deserialize: _chapterSchemaDeserialize,
  deserializeProp: _chapterSchemaDeserializeProp,
  idName: r'id',
  indexes: {
    r'subjectName': IndexSchema(
      id: -2702852998942163311,
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
    r'syllabusSource': IndexSchema(
      id: 6387315541480065039,
      name: r'syllabusSource',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'syllabusSource',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _chapterSchemaGetId,
  getLinks: _chapterSchemaGetLinks,
  attach: _chapterSchemaAttach,
  version: '3.1.0+1',
);

int _chapterSchemaEstimateSize(
  ChapterSchema object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.masteryLabel.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.pyqProgressLabel.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.subjectName.length * 3;
  bytesCount += 3 + object.syllabusSource.length * 3;
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _chapterSchemaSerialize(
  ChapterSchema object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.calculationMistakes);
  writer.writeLong(offsets[1], object.classLevel);
  writer.writeLong(offsets[2], object.conceptualMistakes);
  writer.writeLong(offsets[3], object.difficulty);
  writer.writeDouble(offsets[4], object.estimatedHours);
  writer.writeDateTime(offsets[5], object.firstLearnedDate);
  writer.writeDouble(offsets[6], object.hoursSpent);
  writer.writeBool(offsets[7], object.isPriorityRevision);
  writer.writeBool(offsets[8], object.isWeakChapter);
  writer.writeDateTime(offsets[9], object.lastStudiedDate);
  writer.writeString(offsets[10], object.masteryLabel);
  writer.writeLong(offsets[11], object.masteryLevel);
  writer.writeString(offsets[12], object.name);
  writer.writeDouble(offsets[13], object.progressFraction);
  writer.writeLong(offsets[14], object.pyqCount);
  writer.writeLong(offsets[15], object.pyqProgress);
  writer.writeString(offsets[16], object.pyqProgressLabel);
  writer.writeLong(offsets[17], object.revisionCount);
  writer.writeLong(offsets[18], object.sillyMistakes);
  writer.writeString(offsets[19], object.status);
  writer.writeString(offsets[20], object.subjectName);
  writer.writeString(offsets[21], object.syllabusSource);
  writer.writeStringList(offsets[22], object.tags);
  writer.writeDouble(offsets[23], object.testAccuracy);
  writer.writeLong(offsets[24], object.testAttempts);
  writer.writeLong(offsets[25], object.testCorrect);
  writer.writeDouble(offsets[26], object.weightage);
}

ChapterSchema _chapterSchemaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ChapterSchema();
  object.calculationMistakes = reader.readLong(offsets[0]);
  object.classLevel = reader.readLong(offsets[1]);
  object.conceptualMistakes = reader.readLong(offsets[2]);
  object.difficulty = reader.readLong(offsets[3]);
  object.estimatedHours = reader.readDouble(offsets[4]);
  object.firstLearnedDate = reader.readDateTimeOrNull(offsets[5]);
  object.hoursSpent = reader.readDouble(offsets[6]);
  object.id = id;
  object.isPriorityRevision = reader.readBool(offsets[7]);
  object.isWeakChapter = reader.readBool(offsets[8]);
  object.lastStudiedDate = reader.readDateTimeOrNull(offsets[9]);
  object.masteryLevel = reader.readLong(offsets[11]);
  object.name = reader.readString(offsets[12]);
  object.pyqCount = reader.readLong(offsets[14]);
  object.pyqProgress = reader.readLong(offsets[15]);
  object.revisionCount = reader.readLong(offsets[17]);
  object.sillyMistakes = reader.readLong(offsets[18]);
  object.status = reader.readString(offsets[19]);
  object.subjectName = reader.readString(offsets[20]);
  object.syllabusSource = reader.readString(offsets[21]);
  object.tags = reader.readStringList(offsets[22]) ?? [];
  object.testAttempts = reader.readLong(offsets[24]);
  object.testCorrect = reader.readLong(offsets[25]);
  object.weightage = reader.readDouble(offsets[26]);
  return object;
}

P _chapterSchemaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readStringList(offset) ?? []) as P;
    case 23:
      return (reader.readDouble(offset)) as P;
    case 24:
      return (reader.readLong(offset)) as P;
    case 25:
      return (reader.readLong(offset)) as P;
    case 26:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _chapterSchemaGetId(ChapterSchema object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _chapterSchemaGetLinks(ChapterSchema object) {
  return [];
}

void _chapterSchemaAttach(
    IsarCollection<dynamic> col, Id id, ChapterSchema object) {
  object.id = id;
}

extension ChapterSchemaQueryWhereSort
    on QueryBuilder<ChapterSchema, ChapterSchema, QWhere> {
  QueryBuilder<ChapterSchema, ChapterSchema, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ChapterSchemaQueryWhere
    on QueryBuilder<ChapterSchema, ChapterSchema, QWhereClause> {
  QueryBuilder<ChapterSchema, ChapterSchema, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterWhereClause> idBetween(
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterWhereClause>
      subjectNameEqualTo(String subjectName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subjectName',
        value: [subjectName],
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterWhereClause>
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterWhereClause>
      syllabusSourceEqualTo(String syllabusSource) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syllabusSource',
        value: [syllabusSource],
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterWhereClause>
      syllabusSourceNotEqualTo(String syllabusSource) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syllabusSource',
              lower: [],
              upper: [syllabusSource],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syllabusSource',
              lower: [syllabusSource],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syllabusSource',
              lower: [syllabusSource],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syllabusSource',
              lower: [],
              upper: [syllabusSource],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ChapterSchemaQueryFilter
    on QueryBuilder<ChapterSchema, ChapterSchema, QFilterCondition> {
  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      calculationMistakesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calculationMistakes',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      calculationMistakesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'calculationMistakes',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      calculationMistakesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'calculationMistakes',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      calculationMistakesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'calculationMistakes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      classLevelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      classLevelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'classLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      classLevelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'classLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      classLevelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'classLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      conceptualMistakesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conceptualMistakes',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      conceptualMistakesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'conceptualMistakes',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      conceptualMistakesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'conceptualMistakes',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      conceptualMistakesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'conceptualMistakes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      difficultyEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficulty',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      difficultyGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'difficulty',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      difficultyLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'difficulty',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      difficultyBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'difficulty',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      estimatedHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estimatedHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      estimatedHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estimatedHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      estimatedHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estimatedHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      estimatedHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estimatedHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      firstLearnedDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'firstLearnedDate',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      firstLearnedDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'firstLearnedDate',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      firstLearnedDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firstLearnedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      firstLearnedDateGreaterThan(
    DateTime? value, {
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      firstLearnedDateLessThan(
    DateTime? value, {
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      firstLearnedDateBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      hoursSpentEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hoursSpent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      hoursSpentGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hoursSpent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      hoursSpentLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hoursSpent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      hoursSpentBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hoursSpent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      isPriorityRevisionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPriorityRevision',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      isWeakChapterEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isWeakChapter',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      lastStudiedDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastStudiedDate',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      lastStudiedDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastStudiedDate',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      lastStudiedDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastStudiedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      lastStudiedDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastStudiedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      lastStudiedDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastStudiedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      lastStudiedDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastStudiedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      masteryLabelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'masteryLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      masteryLabelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'masteryLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      masteryLabelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'masteryLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      masteryLabelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'masteryLabel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      masteryLabelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'masteryLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      masteryLabelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'masteryLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      masteryLabelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'masteryLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      masteryLabelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'masteryLabel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      masteryLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'masteryLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      masteryLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'masteryLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      masteryLevelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'masteryLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      masteryLevelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'masteryLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      masteryLevelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'masteryLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      masteryLevelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'masteryLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      progressFractionEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progressFraction',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      progressFractionGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progressFraction',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      progressFractionLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progressFraction',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      progressFractionBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progressFraction',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pyqCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pyqCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pyqCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pyqCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqProgressEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pyqProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqProgressGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pyqProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqProgressLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pyqProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqProgressBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pyqProgress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqProgressLabelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pyqProgressLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqProgressLabelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pyqProgressLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqProgressLabelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pyqProgressLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqProgressLabelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pyqProgressLabel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqProgressLabelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pyqProgressLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqProgressLabelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pyqProgressLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqProgressLabelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pyqProgressLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqProgressLabelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pyqProgressLabel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqProgressLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pyqProgressLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      pyqProgressLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pyqProgressLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      revisionCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'revisionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      revisionCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'revisionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      revisionCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'revisionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      revisionCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'revisionCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      sillyMistakesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sillyMistakes',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      sillyMistakesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sillyMistakes',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      sillyMistakesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sillyMistakes',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      sillyMistakesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sillyMistakes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
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

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      subjectNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      subjectNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      subjectNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectName',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      subjectNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectName',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      syllabusSourceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syllabusSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      syllabusSourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syllabusSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      syllabusSourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syllabusSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      syllabusSourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syllabusSource',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      syllabusSourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syllabusSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      syllabusSourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syllabusSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      syllabusSourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syllabusSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      syllabusSourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syllabusSource',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      syllabusSourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syllabusSource',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      syllabusSourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syllabusSource',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      tagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      tagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      tagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      tagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      tagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      testAccuracyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'testAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      testAccuracyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'testAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      testAccuracyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'testAccuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      testAccuracyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'testAccuracy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      testAttemptsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'testAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      testAttemptsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'testAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      testAttemptsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'testAttempts',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      testAttemptsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'testAttempts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      testCorrectEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'testCorrect',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      testCorrectGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'testCorrect',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      testCorrectLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'testCorrect',
        value: value,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      testCorrectBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'testCorrect',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      weightageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weightage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      weightageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weightage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      weightageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weightage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterFilterCondition>
      weightageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weightage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension ChapterSchemaQueryObject
    on QueryBuilder<ChapterSchema, ChapterSchema, QFilterCondition> {}

extension ChapterSchemaQueryLinks
    on QueryBuilder<ChapterSchema, ChapterSchema, QFilterCondition> {}

extension ChapterSchemaQuerySortBy
    on QueryBuilder<ChapterSchema, ChapterSchema, QSortBy> {
  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByCalculationMistakes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calculationMistakes', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByCalculationMistakesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calculationMistakes', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> sortByClassLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classLevel', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByClassLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classLevel', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByConceptualMistakes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conceptualMistakes', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByConceptualMistakesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conceptualMistakes', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> sortByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByEstimatedHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedHours', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByEstimatedHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedHours', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByFirstLearnedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstLearnedDate', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByFirstLearnedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstLearnedDate', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> sortByHoursSpent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hoursSpent', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByHoursSpentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hoursSpent', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByIsPriorityRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPriorityRevision', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByIsPriorityRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPriorityRevision', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByIsWeakChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWeakChapter', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByIsWeakChapterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWeakChapter', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByLastStudiedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStudiedDate', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByLastStudiedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStudiedDate', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByMasteryLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'masteryLabel', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByMasteryLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'masteryLabel', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByMasteryLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'masteryLevel', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByMasteryLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'masteryLevel', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByProgressFraction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressFraction', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByProgressFractionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressFraction', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> sortByPyqCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pyqCount', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByPyqCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pyqCount', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> sortByPyqProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pyqProgress', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByPyqProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pyqProgress', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByPyqProgressLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pyqProgressLabel', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByPyqProgressLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pyqProgressLabel', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByRevisionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revisionCount', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByRevisionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revisionCount', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortBySillyMistakes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sillyMistakes', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortBySillyMistakesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sillyMistakes', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> sortBySubjectName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortBySubjectNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortBySyllabusSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllabusSource', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortBySyllabusSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllabusSource', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByTestAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testAccuracy', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByTestAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testAccuracy', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByTestAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testAttempts', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByTestAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testAttempts', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> sortByTestCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testCorrect', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByTestCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testCorrect', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> sortByWeightage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightage', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      sortByWeightageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightage', Sort.desc);
    });
  }
}

extension ChapterSchemaQuerySortThenBy
    on QueryBuilder<ChapterSchema, ChapterSchema, QSortThenBy> {
  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByCalculationMistakes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calculationMistakes', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByCalculationMistakesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calculationMistakes', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> thenByClassLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classLevel', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByClassLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classLevel', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByConceptualMistakes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conceptualMistakes', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByConceptualMistakesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conceptualMistakes', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> thenByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByEstimatedHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedHours', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByEstimatedHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedHours', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByFirstLearnedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstLearnedDate', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByFirstLearnedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstLearnedDate', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> thenByHoursSpent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hoursSpent', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByHoursSpentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hoursSpent', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByIsPriorityRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPriorityRevision', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByIsPriorityRevisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPriorityRevision', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByIsWeakChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWeakChapter', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByIsWeakChapterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isWeakChapter', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByLastStudiedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStudiedDate', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByLastStudiedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastStudiedDate', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByMasteryLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'masteryLabel', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByMasteryLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'masteryLabel', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByMasteryLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'masteryLevel', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByMasteryLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'masteryLevel', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByProgressFraction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressFraction', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByProgressFractionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressFraction', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> thenByPyqCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pyqCount', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByPyqCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pyqCount', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> thenByPyqProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pyqProgress', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByPyqProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pyqProgress', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByPyqProgressLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pyqProgressLabel', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByPyqProgressLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pyqProgressLabel', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByRevisionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revisionCount', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByRevisionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revisionCount', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenBySillyMistakes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sillyMistakes', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenBySillyMistakesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sillyMistakes', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> thenBySubjectName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenBySubjectNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenBySyllabusSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllabusSource', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenBySyllabusSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syllabusSource', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByTestAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testAccuracy', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByTestAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testAccuracy', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByTestAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testAttempts', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByTestAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testAttempts', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> thenByTestCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testCorrect', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByTestCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'testCorrect', Sort.desc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy> thenByWeightage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightage', Sort.asc);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QAfterSortBy>
      thenByWeightageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightage', Sort.desc);
    });
  }
}

extension ChapterSchemaQueryWhereDistinct
    on QueryBuilder<ChapterSchema, ChapterSchema, QDistinct> {
  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct>
      distinctByCalculationMistakes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calculationMistakes');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct> distinctByClassLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'classLevel');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct>
      distinctByConceptualMistakes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conceptualMistakes');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct> distinctByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'difficulty');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct>
      distinctByEstimatedHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estimatedHours');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct>
      distinctByFirstLearnedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firstLearnedDate');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct> distinctByHoursSpent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hoursSpent');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct>
      distinctByIsPriorityRevision() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPriorityRevision');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct>
      distinctByIsWeakChapter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isWeakChapter');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct>
      distinctByLastStudiedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastStudiedDate');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct> distinctByMasteryLabel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'masteryLabel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct>
      distinctByMasteryLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'masteryLevel');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct>
      distinctByProgressFraction() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progressFraction');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct> distinctByPyqCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pyqCount');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct>
      distinctByPyqProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pyqProgress');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct>
      distinctByPyqProgressLabel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pyqProgressLabel',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct>
      distinctByRevisionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'revisionCount');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct>
      distinctBySillyMistakes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sillyMistakes');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct> distinctBySubjectName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct>
      distinctBySyllabusSource({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syllabusSource',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct>
      distinctByTestAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'testAccuracy');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct>
      distinctByTestAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'testAttempts');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct>
      distinctByTestCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'testCorrect');
    });
  }

  QueryBuilder<ChapterSchema, ChapterSchema, QDistinct> distinctByWeightage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightage');
    });
  }
}

extension ChapterSchemaQueryProperty
    on QueryBuilder<ChapterSchema, ChapterSchema, QQueryProperty> {
  QueryBuilder<ChapterSchema, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ChapterSchema, int, QQueryOperations>
      calculationMistakesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calculationMistakes');
    });
  }

  QueryBuilder<ChapterSchema, int, QQueryOperations> classLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'classLevel');
    });
  }

  QueryBuilder<ChapterSchema, int, QQueryOperations>
      conceptualMistakesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conceptualMistakes');
    });
  }

  QueryBuilder<ChapterSchema, int, QQueryOperations> difficultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'difficulty');
    });
  }

  QueryBuilder<ChapterSchema, double, QQueryOperations>
      estimatedHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estimatedHours');
    });
  }

  QueryBuilder<ChapterSchema, DateTime?, QQueryOperations>
      firstLearnedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstLearnedDate');
    });
  }

  QueryBuilder<ChapterSchema, double, QQueryOperations> hoursSpentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hoursSpent');
    });
  }

  QueryBuilder<ChapterSchema, bool, QQueryOperations>
      isPriorityRevisionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPriorityRevision');
    });
  }

  QueryBuilder<ChapterSchema, bool, QQueryOperations> isWeakChapterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isWeakChapter');
    });
  }

  QueryBuilder<ChapterSchema, DateTime?, QQueryOperations>
      lastStudiedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastStudiedDate');
    });
  }

  QueryBuilder<ChapterSchema, String, QQueryOperations> masteryLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'masteryLabel');
    });
  }

  QueryBuilder<ChapterSchema, int, QQueryOperations> masteryLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'masteryLevel');
    });
  }

  QueryBuilder<ChapterSchema, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<ChapterSchema, double, QQueryOperations>
      progressFractionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progressFraction');
    });
  }

  QueryBuilder<ChapterSchema, int, QQueryOperations> pyqCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pyqCount');
    });
  }

  QueryBuilder<ChapterSchema, int, QQueryOperations> pyqProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pyqProgress');
    });
  }

  QueryBuilder<ChapterSchema, String, QQueryOperations>
      pyqProgressLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pyqProgressLabel');
    });
  }

  QueryBuilder<ChapterSchema, int, QQueryOperations> revisionCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'revisionCount');
    });
  }

  QueryBuilder<ChapterSchema, int, QQueryOperations> sillyMistakesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sillyMistakes');
    });
  }

  QueryBuilder<ChapterSchema, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<ChapterSchema, String, QQueryOperations> subjectNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectName');
    });
  }

  QueryBuilder<ChapterSchema, String, QQueryOperations>
      syllabusSourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syllabusSource');
    });
  }

  QueryBuilder<ChapterSchema, List<String>, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<ChapterSchema, double, QQueryOperations> testAccuracyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'testAccuracy');
    });
  }

  QueryBuilder<ChapterSchema, int, QQueryOperations> testAttemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'testAttempts');
    });
  }

  QueryBuilder<ChapterSchema, int, QQueryOperations> testCorrectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'testCorrect');
    });
  }

  QueryBuilder<ChapterSchema, double, QQueryOperations> weightageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightage');
    });
  }
}
