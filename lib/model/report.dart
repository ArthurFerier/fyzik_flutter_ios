import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:stimulusep/db/database.dart';
import 'package:stimulusep/db/firestore_db.dart';
import 'package:stimulusep/model/exercise.dart';
import 'package:stimulusep/model/exercise_enum.dart';
import 'package:stimulusep/model/statistic.dart';
import 'package:stimulusep/model/user.dart';

import 'image.dart';

final String tableReport = "Reports";

class ReportFields {
  static final String idReport = "_id";
  static final String dateReport = "date";
  static final String yearReport = "year";
  static final String mailReport = "mail";
  static final String waistReport = "waist";
  static final String exploReport = "explosiveness";
  static final String enduranceReport = "endurance";
  static final String strengthReport = "strength";
  static final String flexReport = "flexibility";
  static final String speedReport = "speed";
  static final String balanceReport = "balance";
  static final String imageReport = "image";

  static final List<String> values = [idReport, dateReport, yearReport];
}

class Report implements Comparable<Report>{
  int id;
  DateTime date;
  int year;
  String mail;
  HashMap<String, double> averages  = HashMap();
  List<Exercise> exercises = List.empty(growable: true);
  bool isExpanded = false;
  Image? image;
  String? photo;

  Report({
    this.id = -1,
    required this.date,
    required this.year,
    required this.mail,
    required this.exercises,
    this.photo,
  });

  Exercise? getExercise(String name){
    int index = exercises.indexWhere((element) => element.name.compareTo(name)==0);
    return (index==-1)?null:exercises[index];
  }

  Future<int> findPercentile(String name, double score) async {
    int sex = UserC().sex!;
    int age = UserC().getAge(date);

    Statistic? stats = await FDatabase.instance.getQuantiles(age, name, sex);
    if (stats == null){
      return -1;
    } else {
      List<double> list = stats.list();
      List<int> quantiles = [0,10,25,40,50,60,75,90];
      if(list.first<list.last) {
        list = list.reversed.toList(growable: false);
        quantiles = quantiles.reversed.toList(growable: false);
      }
      assert(list.length>=7);
      int temp = 0;
      while(score < list[temp]) {
        if(++temp >= list.length)
          return quantiles.last;
      }return quantiles[temp];
    }
  }

  Future<void> addExercise(Exercise theExercise, [bool fromDB = false, bool setToExt = true]) async {
    late int i;
    for(i=0; i<exercises.length; i++){
      if(exercises[i].compareTo(theExercise)>=0) break;
    }
    if (!fromDB) {
      if (theExercise.id == -1) theExercise.id = createId();
      theExercise.idRapport = id;
      theExercise.percentile = await findPercentile(theExercise.name, theExercise.score);
      await FDatabase.instance.createExercise(theExercise);
      if (setToExt) setExerciseToExternal(theExercise);
    }
    exercises.insert(i, theExercise);
    NameList.instance.testExercise(theExercise);
    _updateAverage(theExercise);
  }

  void _updateAverage(Exercise theExercise) {
    if(theExercise.hasQuantile() && theExercise.type.compareTo('Morphologie')!=0) _setAverage(theExercise.type);
  }

  Future<void> editExercise(Exercise theExercise, [bool setToExt = true]) async {
    int index = exercises.indexWhere((element) => (element.name.compareTo(theExercise.name))==0);

    exercises[index].type = theExercise.type;
    exercises[index].unit = theExercise.unit;
    exercises[index].score = theExercise.score;
    exercises[index].percentile = await findPercentile(exercises[index].name, exercises[index].score);
    if (setToExt) setExerciseToExternal(theExercise);
    await FDatabase.instance.updateExercise(exercises[index]);

    _updateAverage(theExercise);
  }

  int createId(){
    int nonUsedId = findNonUsedId();
    return nonUsedId;
  }

  int findNonUsedId(){
    // create list of all exercises
    List<Exercise> exercisesAll = [];
    for (Report report in UserC().reports){
      for (Exercise exo in report.exercises){
        exercisesAll.add(exo);
      }
    }
    if(exercisesAll.length == 0){
      return 0;
    }
    if(exercisesAll.length == 1){
      return exercisesAll[0].id! + 1;
    }
    exercisesAll.sort((el1, el2) => el1.id!.compareTo(el2.id!));
    for (int i = 0; i < exercisesAll.length; i++){
      if (exercisesAll[i].id != i){
        return i;
      }
    }
    return exercisesAll.length;
  }

  Future<void> initialiseExercises(List<Exercise> list) async {
    list.forEach((element) async {
      NameList.instance.testExercise(element);
      await addExercise(element, true);
    });
  }

  removeExercises(List<Exercise> list) async {
    for(Exercise element in list) {
      FDatabase.instance.deleteExercise(element.id!);
      deleteExerciseExternal(element.id!, id);
      exercises.removeWhere((element2) => element2.id==element.id);
    }
  }

  Future<bool> addImage(String image) async {
    this.photo = image;
    this.image = Utility.imageFromBase64String(image);
    int done = await FDatabase.instance.updateReport(this);
    if (done != 1) {
      return false;
    }
    setReportToExternal(this);
    return true;
  }

  Map<String, Object?> toJson() => {
    ReportFields.idReport : id,
    ReportFields.dateReport : date.toIso8601String(),
    ReportFields.yearReport : year,
    ReportFields.mailReport : mail,
    ReportFields.imageReport : photo,
  };

  static Report fromJson(Map<dynamic, dynamic> json) {
    Report report = Report(
        id: json[ReportFields.idReport] as int,
        date: DateTime.parse(json[ReportFields.dateReport] as String),
        year: json[ReportFields.yearReport] as int,
        mail: json[ReportFields.mailReport] as String,
        exercises: [],
        photo: json[ReportFields.imageReport] as String?,
    );
    if (report.photo != null) {
      report.image = Utility.imageFromBase64String(report.photo!);
    }
    return report;
  }

  Report copy({
    int? id,
    DateTime? date,
    int? year,
    String? mail,
    List<double>? averages,
    int? explosiveness,
    int? endurance,
    int? strength,
    int? flexibility,
    int? speed,
    int? balance,
    String? image,
  }) => Report(
    id: id ?? this.id,
    date: date ?? this.date,
    year: year ?? this.year,
    mail: mail ?? this.mail,
    exercises: exercises,
    photo: image ?? this.photo,
  );

  int compareTo(Report o) {
    return date.compareTo(o.date);
  }

  double getHeightWaistRatio(){
    return getRatio('Tour de taille', 'Taille', false)/100;
  }

  double getBMI(){
    return getRatio('Poids', 'Taille', true);
  }

  double getRatio(String nominator, String denominator, bool square) {
    int a = exercises.indexWhere((element) => element.name.compareTo(nominator)==0);
    int b = exercises.indexWhere((element) => element.name.compareTo(denominator)==0);
    if(b==-1 || a==-1) return 0;
    double ratio = exercises[a].score/exercises[b].score;
    return (square)?ratio/exercises[b].score:ratio;
  }

  void setAverages(){
    exerciseType.sublist(1).forEach((element) {
      _setAverage(element);
    });
  }

  void _setAverage(String type){
    double temp = 0;
    Iterable<Exercise> list = exercises.where((element) => element.type.compareTo(type)==0 && element.hasQuantile());
    list.forEach((element) {temp+=element.percentile;});
    temp/=list.length;
    averages.update(type, (value) => temp, ifAbsent: () => temp);
  }
}