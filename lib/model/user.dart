import 'package:stimulusep/db/database.dart';
import 'package:stimulusep/db/firestore_db.dart';
import 'package:stimulusep/model/report.dart';

final String tableUsers = "Users";

class UserFields {
  static final String idUser = "_id";
  static final String emailUser = "email";
  static final String passwordUser = "password";
  static final String birthDayUser = "birthday";
  static final String sexUser = "sex";
  static final String reports = "reports";
  static final String firstName = "firstName";
  static final String lastName = "lastName";
  static final String code = "code";
  static final String school = "school";
  //static final String country = "country";

  static final List<String> values = [
    emailUser, passwordUser, birthDayUser, sexUser, firstName, lastName, school];
}

class UserC {
  static UserC? _instance;
  UserC._internal();

  factory UserC({DateTime? birthDay, int? sex,
    String? email, String? password, String? firstName,
    String? lastName, String? school}){
    if (_instance == null) {
      _instance = UserC._internal();
      _instance!.birthDay = birthDay;
      _instance!.sex = sex;
      _instance!.email = email;
      _instance!.password = password;
      _instance!.firstName = firstName;
      _instance!.lastName = lastName;
      _instance!.school = school;
      //_instance!.country = country;
    }
    return _instance!;
  }

  String? email;
  String? password;
  String? firstName;
  String? lastName;
  DateTime? birthDay;
  int? sex; // 1 : boy, 0 : girl
  List<Report> reports = List.empty(growable: true);
  String? school;
  //String? country;

  int getAge(DateTime date){
    int age = (date.difference(birthDay!).inDays/365).floor();
    if (age > 18) return 18;
    if (age < 12) return 12;
    return age;
  }

  int reportIndex(int id){
    return reports.indexWhere((element) => element.id==id);
  }

  Future<int> addReport(Report theReport, [bool fromDB = false, bool setToExt = true]) async {
    late int i;
    for(i=0; i<reports.length; i++){
      if(reports[i].compareTo(theReport)>=0) break;
    }
    theReport.mail = UserC().email!;
    if (!fromDB){
      if (theReport.id == -1) {
        // true new report
        theReport.id = createId();
      }
      await FDatabase.instance.createReport(theReport);
      if (setToExt){
        setReportToExternal(theReport);
      }
    }else{
      theReport.setAverages();
    }
    reports.insert(i, theReport);

    return(theReport.id);
  }

  Future<int> editReport(Report theReport, [bool setToExt = true]) async {
    int index = reports.indexWhere((element) => element.id==theReport.id);

    reports[index].year = theReport.year;
    reports[index].date = theReport.date;
    if (setToExt) setReportToExternal(theReport);
    await FDatabase.instance.updateReport(reports[index]);

    return(theReport.id);
  }

  Future<int> updatePercentiles() async {
    reports.forEach((report) {
      report.exercises.forEach((exercise) async {
        exercise.percentile = await report.findPercentile(exercise.name, exercise.score);
        await FDatabase.instance.updateExercise(exercise);
      });
    });
    return 1;
  }


  int createId(){
    int nonUsedId = findNonUsedId();
    return nonUsedId;
  }

  int findNonUsedId(){
    if(reports.length == 0){
      return 0;
    }
    if(reports.length == 1){
      return reports[0].id + 1;
    }
    reports.sort((el1, el2) => el1.id.compareTo(el2.id));
    for (int i = 0; i < reports.length; i++){
      if (reports[i].id != i){
        return i;
      }
    }
    return reports.length;
  }

  Future<void> removeReports(List<Report> list) async {
    for(Report element in list) {
      await FDatabase.instance.deleteReport(element.id);
      deleteReportExternal(element.id);
      reports.removeWhere((element2) => element2.id == element.id);
    }
  }

  Map<String, Object?> toJson() => {
    UserFields.emailUser: email,
    UserFields.passwordUser: password,
    UserFields.birthDayUser: birthDay!.toIso8601String(),
    UserFields.sexUser: sex,
    UserFields.firstName: firstName!,
    UserFields.lastName: lastName!,
    UserFields.school: school,
    //UserFields.country: country
  };

  static void fromJson(Map<String, Object?> json){
    UserC(birthDay: DateTime.parse(json[UserFields.birthDayUser] as String),
      sex: json[UserFields.sexUser] as int,
      firstName: json[UserFields.firstName] as String,
      lastName: json[UserFields.lastName] as String,
      school: json[UserFields.school] as String,
      //country: json[UserFields.country] as String
    );
    _instance!.email = json[UserFields.emailUser] as String?;
    _instance!.password = json[UserFields.passwordUser] as String?;
  }

  static void fromJsonExt(Map<dynamic, dynamic> json){
    var bd = json[UserFields.birthDayUser];

    UserC(birthDay: DateTime.parse(bd as String),
        sex: json[UserFields.sexUser] as int,
        firstName: json[UserFields.firstName] as String,
        lastName: json[UserFields.lastName] as String,
        school: json[UserFields.school] as String
    );
  }



  void deleteUser(){
    _instance = null;
  }
}