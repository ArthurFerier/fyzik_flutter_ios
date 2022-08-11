import 'package:flutter/cupertino.dart';
import 'package:stimulusep/assets/strings.dart';

import 'exercise_enum.dart';

final String tableExercises = "Exercises";

class ExerciseFields {
  static final String idExercise = "_id";
  static final String nameExercise = "name";
  static final String typeExercise = "type";
  static final String unitExercise = "unit";
  static final String scoreExercise = "score";
  static final String percentileExercise = "percentile";
  static final String rapportIdExercise = "rapportId";
  static final String timeExercise = "time";

  static final List<String> values = [
    idExercise, nameExercise, typeExercise, unitExercise,
  scoreExercise, percentileExercise, rapportIdExercise, timeExercise];
}


class Exercise implements Comparable<Exercise>{
  int? id, idRapport;
  final String name;
  String type;
  String unit;
  double score;
  int percentile;
  final int time;

  Exercise({
    this.id = -1,
    required this.name,
    this.idRapport,
    required this.type,
    required this.unit,
    this.score = 0,
    this.percentile = 0,
    required this.time, // 1=>greater time is better, 0 smaller time is better
  });

  Map<String, Object?> toJson() => {
    ExerciseFields.idExercise : id,
    ExerciseFields.nameExercise : name,
    ExerciseFields.rapportIdExercise : idRapport,
    ExerciseFields.typeExercise : type,
    ExerciseFields.unitExercise : unit,
    ExerciseFields.scoreExercise : score,
    ExerciseFields.percentileExercise : percentile,
    ExerciseFields.timeExercise : time
  };

  static Exercise fromJson(Map<String, Object?> json) => Exercise(
    id: json[ExerciseFields.idExercise] as int,
    name: json[ExerciseFields.nameExercise] as String,
    idRapport: json[ExerciseFields.rapportIdExercise] as int,
    type: json[ExerciseFields.typeExercise] as String,
    unit: json[ExerciseFields.unitExercise] as String,
    score: json[ExerciseFields.scoreExercise] as double,
    percentile: json[ExerciseFields.percentileExercise] as int,
    time: json[ExerciseFields.timeExercise] as int
  );

  Exercise copy({ // create a copy of the Exercise object
    int? id,
    String? name,
    int? idRapport,
    String? type,
    String? unit,
    double? score,
    int? percentile,
    int? time
  }) => Exercise(
    id: id ?? this.id,
    name: name ?? this.name,
    idRapport: idRapport ?? this.idRapport,
    type: type ?? this.type,
    unit: unit ?? this.unit,
    score: score ?? this.score,
    percentile: percentile ?? this.percentile,
    time: time ?? this.time
  );

  bool hasQuantile(){
    return basicExercise.contains(name);
  }

  int compareTo(Exercise o) {
    /*int x=100, y=100;
    if(exerciseType.contains(type)) x=exerciseType.indexOf(this.type);
    if(exerciseType.contains(o.type)) y=exerciseType.indexOf(o.type);
    if(x-y!=0) return x-y;*/
    return name.compareTo(o.name);
  }

  static AssetImage exImage(String name){
    switch (name){
      case Strings.height:
        return AssetImage('lib/assets/images/taille_debout.png');
      case Strings.weight:
        return AssetImage('lib/assets/images/poid.png');
      case Strings.waist:
        return AssetImage('lib/assets/images/tape.png');
      case Strings.shuttleRace:
        return AssetImage('lib/assets/images/course.png');
      case Strings.handGrip:
        return AssetImage('lib/assets/images/force_statique.png');
      case Strings.suspension:
        return AssetImage('lib/assets/images/muscu.png');
      case Strings.sitUp:
        return AssetImage('lib/assets/images/abdos.png');
      case Strings.trunkFlexion:
        return AssetImage('lib/assets/images/souplesse.png');
      case Strings.jumpWOMom:
        return AssetImage('lib/assets/images/saut_longueur.png');
      case Strings.hittingPlates:
        return AssetImage('lib/assets/images/vitesse_membres.png');
      case Strings.flamingoBalance:
        return AssetImage('lib/assets/images/equilibre_general.png');
      case Strings.lucLeger:
        return AssetImage('lib/assets/images/luc.png');
      default:
        return AssetImage('lib/assets/images/olympics.png');
    }
  }
}