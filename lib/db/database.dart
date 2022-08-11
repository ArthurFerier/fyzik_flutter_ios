import 'dart:core';
import 'package:stimulusep/model/exercise.dart';
import 'package:stimulusep/model/data.dart';
import 'package:stimulusep/model/report.dart';
import 'package:stimulusep/model/statistic.dart';
import 'package:stimulusep/model/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class FDatabase {

  // ------------------------ init/close operations ----------------------------

  static final FDatabase instance = FDatabase._init();

  static Database? _database;

  FDatabase._init(); // private constructor

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB('database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath(); // get db path is modular from ios to android
    final path = join(dbPath, filePath); // final path

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async { // if db already existing, not created again
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final idTypeNotAuto = 'INTEGER PRIMARY KEY';
    final textType = 'TEXT NOT NULL';
    final textTypeNullable = 'TEXT';
    final integerType = 'INTEGER';
    final integerTypeN = 'INTEGER NOT NULL';
    final realType = 'REAL';
    final realTypeN = 'REAL NOT NULL';

    String query = '''
    CREATE TABLE $tableUsers (
    ${UserFields.idUser} $idType,
    ${UserFields.emailUser} $textTypeNullable, 
    ${UserFields.passwordUser} $textTypeNullable,
    ${UserFields.firstName} $textType,
    ${UserFields.lastName} $textType,
    ${UserFields.birthDayUser} $textType,
    ${UserFields.sexUser} $integerTypeN,
    ${UserFields.school} $textType
    )
    ''';
    await db.execute(query);

    query = '''
    CREATE TABLE $tableExercises (
    ${ExerciseFields.idExercise} $idTypeNotAuto,
    ${ExerciseFields.rapportIdExercise} $integerTypeN,
    ${ExerciseFields.nameExercise} $textType,
    ${ExerciseFields.typeExercise} $textType,
    ${ExerciseFields.unitExercise} $textType,
    ${ExerciseFields.scoreExercise} $realType,
    ${ExerciseFields.percentileExercise} $integerType,
    ${ExerciseFields.timeExercise} $integerTypeN
    )
    ''';
    await db.execute(query);

    query = '''
    CREATE TABLE $tableReport (
    ${ReportFields.idReport} $idTypeNotAuto,
    ${ReportFields.dateReport} $textType,
    ${ReportFields.yearReport} $integerTypeN,
    ${ReportFields.mailReport} $textType,
    ${ReportFields.imageReport} $textTypeNullable
    )
    ''';
    await db.execute(query);

    query = '''
    CREATE TABLE $tableStat (
    ${StatsFields.idStat} $idType,
    ${StatsFields.exerciseStat} $textType,
    ${StatsFields.sexStat} $integerTypeN,
    ${StatsFields.ageStat} $integerTypeN,
    ${StatsFields.p10Stat} $realTypeN,
    ${StatsFields.p25Stat} $realTypeN,
    ${StatsFields.p40Stat} $realTypeN,
    ${StatsFields.p50Stat} $realTypeN,
    ${StatsFields.p60Stat} $realTypeN,
    ${StatsFields.p75Stat} $realTypeN,
    ${StatsFields.p90Stat} $realTypeN
    )
    ''';
    await db.execute(query);

    // inserting the statistics into the database
    await db.execute(Data.sqlFillHandGrip);
    await db.execute(Data.sqlFillEquilibre);
    await db.execute(Data.sqlFillspeedM);
    await db.execute(Data.sqlFilljumpWOMomentum);
    await db.execute(Data.sqlFillSpeedCoordination);
    await db.execute(Data.sqlFillFlex);
    await db.execute(Data.sqlFillRedress);
    await db.execute(Data.sqlFillSuspension);
    await db.execute(Data.sqlFillTestShuttle);
    await db.execute(Data.sqlFillHeight);
    await db.execute(Data.sqlFillBMI);
    await db.execute(Data.sqlFillWheight);

  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // ------------------------ User operations ----------------------------------

  Future<void> createUser() async {
    final db = await instance.database;
    await db.insert(tableUsers, UserC().toJson()); // returns the id of generated exercise
  }

  Future<void> getUser() async {
    final db = await instance.database;

    final maps = await db.query(
      tableUsers,
      columns: UserFields.values,
    );

    if (maps.isNotEmpty) {
      UserC.fromJson(maps.first);
    } else {
      throw Exception('User not found');
    }
  }

  Future<bool> userExists() async {
    final db = await instance.database;

    final maps = await db.query(
      tableUsers,
      columns: UserFields.values,
    );

    if (maps.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<int> updateUser() async {
    final db = await instance.database;

    return await db.update(
        tableUsers,
        UserC().toJson(),
        where: '${UserFields.emailUser} = ?',
        whereArgs: [UserC().email]
    );
  }

  Future<bool> deleteUser() async {
    String email = UserC().email!;
    final db = await instance.database;
    bool doneReports = await deleteReports();
    if (doneReports) {
      int userDeleted = await db.delete(
          tableUsers,
          where: '${UserFields.emailUser} = ?',
          whereArgs: [email]);
      return userDeleted == 1;
    } else {
      return false;
    }
  }

  // ------------------------- Exercise operations -----------------------------

  Future<void> createExercise(Exercise exercise) async {
    try {
      final db = await instance.database;
      await db.insert(tableExercises, exercise.toJson());
    } catch (e) {
      throw new Exception(e);
    }
  }

  Future<Exercise> getExercise(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableExercises,
      columns: ExerciseFields.values,
      where: '${ExerciseFields.idExercise} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Exercise.fromJson(maps.first);
    } else {
      throw Exception('Exercise ID $id not found');
    }
  }

  Future<List<Exercise>> getAllExercisesFromReport(int reportID) async {
    final db = await instance.database;
    final result = await db.query(
        tableExercises,
      where: ExerciseFields.rapportIdExercise + " == ?",
      whereArgs: [reportID]
    );
    return result.map((json) => Exercise.fromJson(json)).toList();
  }

  Future<Exercise?> getExerciseFromReport(String exerciseName, int reportID) async {
    final db = await instance.database;
    String filter = ExerciseFields.rapportIdExercise + " == ? AND" +
    ExerciseFields.nameExercise + " == ?";
    final result = await db.query(
        tableExercises,
        where: filter,
        whereArgs: [reportID]
    );
    if (result.isNotEmpty){
      return Exercise.fromJson(result.first);
    } else {
      return null;
    }
  }

  Future<int> updateExercise(Exercise exercise) async {
    final db = await instance.database;

    return await db.update(
        tableExercises,
        exercise.toJson(),
        where: '${ExerciseFields.idExercise} = ?',
        whereArgs: [exercise.id]
    );
  }

  Future<int> deleteExercise(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableExercises,
      where: '${ExerciseFields.idExercise} = ?',
      whereArgs: [id]
    );
  }

  Future<int> deleteAllExercisesFromRapportID(int rapportID) async {
    final db = await instance.database;

    return await db.delete(
        tableExercises,
        where: '${ExerciseFields.rapportIdExercise} = ?',
        whereArgs: [rapportID]
    );
  }

  // ----------------------- report operations ---------------------------------

  Future<Report> getReport(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableReport,
      columns: ReportFields.values,
      where: '${ReportFields.idReport} = ?', // prevent sql injection attacks
      whereArgs: [id], // whereArgs will put for every '?' what's in the list here
    );

    if (maps.isNotEmpty) {
      return Report.fromJson(maps.first);
    } else {
      throw Exception('Report ID $id not found');
    }
  }

  Future<int?> getReportIDFromYearDate(Report report) async {
    final db = await instance.database;

    String filter = ReportFields.yearReport + " == ? AND" +
    ReportFields.dateReport + " == ?";

    final maps = await db.query(
      tableReport,
      columns: ReportFields.values,
      where: filter, // prevent sql injection attacks
      whereArgs: [report.year, report.date], // whereArgs will put for every '?' what's in the list here
    );

    if (maps.isNotEmpty) {
      return Report.fromJson(maps.first).id;
    }
    return null;
  }

  Future<void> createReport(Report report) async {
    try {
      final db = await instance.database;
      Map<String, Object?> jsonReport = report.toJson();
      await db.insert(tableReport, jsonReport);

    } catch (e) {
      throw new Exception(e);
    }
  }


  Future<List<Report>> getAllReports() async {
    final db = await instance.database;
    final result = await db.query(tableReport);

    return result.map((json) => Report.fromJson(json)).toList();
  }

  Future<int> updateReport(Report report) async {
    final db = await instance.database;

    return await db.update(
        tableReport,
        report.toJson(),
        where: '${ReportFields.idReport} = ?',
        whereArgs: [report.id]
    );
  }

  Future<int> deleteReport(int id) async {
    final db = await instance.database;

    int deleted = await deleteAllExercisesFromRapportID(id);
    if (deleted == -1){
      throw Exception('Error while erasing exercises of report with id : $id');
    }

    return await db.delete(
        tableReport,
        where: '${ReportFields.idReport} = ?',
        whereArgs: [id]
    );
  }

  Future<bool> deleteReports() async {
    for (Report report in UserC().reports) {
      int done = await deleteReport(report.id);
      if (done != 1) {
        return false;
      }
    }
    return true;
  }

  // ----------------------- Stats operations ----------------------------------

  Future<Statistic?>? getQuantiles(int age, String exercise, int sex) async {
    final db = await instance.database;

    String filter = StatsFields.ageStat + " == ? AND " +
    StatsFields.exerciseStat + " == ? AND " +
    StatsFields.sexStat + " == ? ";

    final maps = await db.query(
      tableStat,
      columns: StatsFields.values,
      where: filter,
      whereArgs: [age, exercise, sex]
    );

    if (maps.isNotEmpty) {
      return Statistic.fromJson(exercise, sex, age, maps.first);
    } else {
      return null;
    }
  }
}