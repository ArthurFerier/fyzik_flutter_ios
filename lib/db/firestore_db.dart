import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:stimulusep/db/database.dart';
import 'package:stimulusep/model/authentication_service.dart';
import 'package:stimulusep/model/exercise.dart';
import 'package:stimulusep/model/report.dart';
import 'package:stimulusep/model/user.dart';

// ---------------------------- getters ----------------------------------------

Future<void> getDataFromExternal(String email, String password) async {
  // user retrieve
  CollectionReference collectionReferenceUser = FirebaseFirestore.instance.collection("users");
  DocumentSnapshot snapshotUser = await collectionReferenceUser.doc(email).get();
  var dataUser = snapshotUser.data() as Map;
  UserC().deleteUser();
  UserC.fromJsonExt(dataUser);
  UserC().email = email;
  UserC().password = password;
  await FDatabase.instance.createUser();
  await getReportsFromExternal(collectionReferenceUser, email);

}

Future<void> getReportsFromExternal(CollectionReference theCollection, String email) async {
  CollectionReference collectionReferenceReport = theCollection.doc(email).collection("reports");
  QuerySnapshot snapshotReport = await collectionReferenceReport.get();
  List<QueryDocumentSnapshot> data = snapshotReport.docs;
  var dataReports1 = data.map((doc) => doc.data());
  List dataReports = dataReports1.toList();
  for (int i = 0; i < dataReports.length; i++){
    Report theReport = Report.fromJson(dataReports[i]);
    await getExercisesFromExternal(collectionReferenceReport, theReport);
    await UserC().addReport(theReport, false, false);

  }
}

Future<void> getExercisesFromExternal(CollectionReference theCollection, Report theReport) async {
  CollectionReference collectionReferenceExercise = theCollection.doc(theReport.id.toString()).collection("exercises");
  QuerySnapshot snapshotExercise = await collectionReferenceExercise.get();
  List<QueryDocumentSnapshot> data = snapshotExercise.docs;
  var dataExercises = data.map((doc) => doc.data());
  List dataExercisesList = dataExercises.toList();
  for (int i = 0; i < dataExercisesList.length; i++){
    Exercise theExercise = Exercise.fromJson(dataExercisesList[i]);
    theReport.addExercise(theExercise, false, false);
  }
}

Future<List<String>> getSchoolsFromExternal() async {
  CollectionReference collectionReference =  FirebaseFirestore.instance.collection("schools");
  QuerySnapshot snapshot = await collectionReference.get();
  List<QueryDocumentSnapshot> data = snapshot.docs;
  return data.map((doc) => doc.id).toList();
}
/*
Future<List<String>> getCountriesFromExternal() async {
  CollectionReference collectionReference =  FirebaseFirestore.instance.collection("countries");
  QuerySnapshot snapshot = await collectionReference.get();
  List<QueryDocumentSnapshot> data = snapshot.docs;
  return data.map((doc) => doc.id).toList();
}*/

// ------------------------------ setters --------------------------------------

void setUserToExternal(String? code) {
  Map<String,dynamic> userData = (code != null) ?
  {
    UserFields.birthDayUser : UserC().birthDay!.toIso8601String(),
    UserFields.sexUser : UserC().sex,
    UserFields.code : code,
    UserFields.firstName : UserC().firstName,
    UserFields.lastName : UserC().lastName,
    UserFields.school : UserC().school,
    //UserFields.country : UserC().country
  }
  :
  {
    UserFields.birthDayUser : UserC().birthDay!.toIso8601String(),
    UserFields.sexUser : UserC().sex,
    UserFields.firstName : UserC().firstName,
    UserFields.lastName : UserC().lastName,
    UserFields.school : UserC().school,
    //UserFields.country : UserC().country
  };
  CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  userCollection.doc(UserC().email).set(userData);
}

void setReportToExternal(Report theReport) {
  Map reportData = theReport.toJson();
  CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  CollectionReference reportCollection = userCollection.doc(UserC().email).collection("reports");
  reportCollection.doc(theReport.id.toString()).set(reportData);
}

void setExerciseToExternal(Exercise theExercise) {
  Map exerciseData = theExercise.toJson();
  CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  CollectionReference reportCollection = userCollection.doc(UserC().email).collection("reports");
  CollectionReference exerciseCollection = reportCollection.doc(theExercise.idRapport.toString()).collection("exercises");
  exerciseCollection.doc(theExercise.id.toString()).set(exerciseData);
}

// ----------------------------- deleters --------------------------------------

Future<void> deleteUserExternal(BuildContext context) async {
  CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  userCollection.doc(UserC().email).collection("reports").get().then(
        (snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            deleteReportExternal(int.parse(ds.id));
          }
        }
  );
  AuthenticationService authServ = AuthenticationService(FirebaseAuth.instance);
  String? signedIn = await authServ.signIn(email: UserC().email!, password: UserC().password!);
  if (signedIn == "Signed in") {
    userCollection.doc(UserC().email).delete();
    await FirebaseAuth.instance.currentUser!.delete();
  } else {
    throw Exception("could not delete the user auth ...");
  }
}

void deleteReportExternal(int reportId) {
  CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  CollectionReference reportCollection = userCollection.doc(UserC().email).collection("reports");
  reportCollection.doc(reportId.toString()).collection("exercises").get().then(
        (snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            ds.reference.delete();
          }
        }
  );
  reportCollection.doc(reportId.toString()).delete();
}

void deleteExerciseExternal(int exerciseId, int reportId) {
  CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  CollectionReference reportCollection = userCollection.doc(UserC().email).collection("reports");
  CollectionReference exerciseCollection = reportCollection.doc(reportId.toString()).collection("exercises");
  exerciseCollection.doc(exerciseId.toString()).delete();
}

// -------------------------------- code ---------------------------------------

Future<int> addCodesInExt(List<String> codes) async {
  try {
    CollectionReference codeReference = FirebaseFirestore.instance.collection("codes");
    int countCodesAdded = 0;
    for (int i = 0; i < codes.length; i++) {
      Map<String, dynamic> map = {};
      codeReference.doc(codes[i]).set(map);
      countCodesAdded ++;
    }
    return countCodesAdded;
  } catch(e) {
    throw e;
  }
}

Future<bool> verifyCodeInExt(String code) async {
  try {
    CollectionReference codeReference = FirebaseFirestore.instance.collection("codes");
    var doc = await codeReference.doc(code).get();
    return doc.exists;
  } catch(e) {
    throw e;
  }
}

void deleteCodeInExt(String code){
  CollectionReference codeCollection = FirebaseFirestore.instance.collection("codes");
  codeCollection.doc(code).delete();
}
