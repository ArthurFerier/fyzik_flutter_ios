final String tableStat = "statistics";

class StatsFields {
  static final String idStat = "id";
  static final String exerciseStat = "exercise";
  static final String sexStat = "sex";
  static final String ageStat = "age";
  static final String p10Stat = "P10";
  static final String p25Stat = "P25";
  static final String p40Stat = "P40";
  static final String p50Stat = "P50";
  static final String p60Stat = "P60";
  static final String p75Stat = "P75";
  static final String p90Stat = "P90";

  static final List<String> values = [
    p10Stat, p25Stat, p40Stat, p50Stat, p60Stat, p75Stat, p90Stat
  ];
}

class Statistic {
  final String exercise;
  final int sex, age;
  final double p10, p25, p40, p50, p60, p75, p90;

  const Statistic({
    required this.exercise,
    required this.sex,
    required this.age,
    required this.p10,
    required this.p25,
    required this.p40,
    required this.p50,
    required this.p60,
    required this.p75,
    required this.p90
  });

  Map<String, Object?> toJson() => {
    StatsFields.exerciseStat: exercise,
    StatsFields.sexStat: sex,
    StatsFields.ageStat: age,
    StatsFields.p10Stat: p10,
    StatsFields.p25Stat: p25,
    StatsFields.p40Stat: p40,
    StatsFields.p50Stat: p50,
    StatsFields.p60Stat: p60,
    StatsFields.p75Stat: p75,
    StatsFields.p90Stat: p90
  };

  static Statistic fromJson(String exercise, int sex, int age, Map<String, Object?> json) => Statistic(
      exercise: exercise,
      sex: sex,
      age: age,
      p10: json[StatsFields.p10Stat] as double,
      p25: json[StatsFields.p25Stat] as double,
      p40: json[StatsFields.p40Stat] as double,
      p50: json[StatsFields.p50Stat] as double,
      p60: json[StatsFields.p60Stat] as double,
      p75: json[StatsFields.p75Stat] as double,
      p90: json[StatsFields.p90Stat] as double
  );

  List<double> list(){
    return [p10, p25, p40, p50, p60, p75, p90];
  }

}