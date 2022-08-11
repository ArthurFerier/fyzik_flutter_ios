import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stimulusep/db/database.dart';
import 'package:stimulusep/model/exercise_enum.dart';
import 'package:stimulusep/views/signup.dart';
import 'package:stimulusep/views/tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';
import 'package:stimulusep/views/verify_email_page.dart';

import 'model/exercise.dart';
import 'model/report.dart';
import 'model/user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //print(await addCodesInExt(doStuff()));


  bool _existingUser = await FDatabase.instance.userExists();
  if (_existingUser){
    // check if user account is valid or disabled
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // for later upgrades
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    prefs.setString("app_version", packageInfo.version);

    // if user is logged for more than a year
    String? date = prefs.getString("dateLastLogin");
    if (date == null) {
      prefs.setString("dateLastLogin", DateTime.now().toString());
    } else {
      DateTime dateNow = DateTime.now();
      DateTime dateBefore = DateTime.parse(date);
      if (dateNow.difference(dateBefore).inDays >= 364) {
        await databaseFactory.deleteDatabase('database.db');
        UserC().deleteUser();

        runApp(MaterialApp(
          home: SignupPage(),
          debugShowCheckedModeBanner: false,
        ));
        return;
      }
    }


    await FDatabase.instance.getUser();

    await FDatabase.instance.getAllReports().then(
            (value) => value.forEach((element) {UserC().addReport(element, true);})
    );
    for (Report report in UserC().reports){
      List<Exercise> exercises = await FDatabase.instance.getAllExercisesFromReport(report.id);
      exercises.forEach((element) {NameList.instance.testExercise(element);});
      await report.initialiseExercises(exercises);
    }

    runApp(MaterialApp(
        home: TabsPage(),
        debugShowCheckedModeBanner: false,
    ));
  } else {
    // there is no user in the database
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString("info");
    if(uid!=null){
      List<String> list = uid.split(' ');
      assert(list.length==3);
      runApp(MaterialApp(
          home: VerifyEmailPage(list[0], list[1], list[2]),
          debugShowCheckedModeBanner: false,
      ));
    }else runApp(MaterialApp(
        home: SignupPage(),
        debugShowCheckedModeBanner: false,
    ));
  }
}

// not used
Future<void> checkUserHasAllInfos() async {
  try {
    UserC().school!;
  } catch (e) {
    // signin out the user
    await databaseFactory.deleteDatabase('database.db');
    UserC().deleteUser();
    runApp(MaterialApp(
      home: SignupPage(),
      debugShowCheckedModeBanner: false,
    ));
  }
}


/*
List<String> doStuff() {
  List<String> list = text.split(' ');
  return list;
}

String text = "EB6A-N8JI-21KM-E8E1 "+
    "EB6A-JD04-FL1V-D1D1 "+
    "EB6A-IGVR-J0RE-BAC1 "+
    "EB6A-045O-NGZ9-A3B1 "+
    "EB6A-DFT1-SED8-8CA1";
 */