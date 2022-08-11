import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stimulusep/assets/strings.dart';
import 'package:stimulusep/model/user.dart';

Future<void>? onPress(String email, BuildContext context) async {
  if (email != ""){
    FocusScope.of(context).unfocus();
    ConnectivityResult connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.mobile
        && connectivity != ConnectivityResult.wifi) {
      snackBar(context, Strings.wifiRequirement, Colors.red);
      return null;
    }
    final auth = FirebaseAuth.instance;
    try {
      auth.setLanguageCode('fr');
      if (UserC().email != null) {
        await auth.sendPasswordResetEmail(email: UserC().email!);
      } else {
        await auth.sendPasswordResetEmail(email: email);
      }

      snackBar(context, Strings.emailSent, Colors.greenAccent);
    } catch(e) {
      print(e);
      snackBar(context, Strings.sureGoodEmail, Colors.deepOrangeAccent);
    }
  } else {
    snackBar(context, Strings.sureGoodEmail, Colors.deepOrangeAccent);
  }
}

void snackBar(BuildContext context, String text, Color color){
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(text),
          backgroundColor: color)
  );
}

String? emailVerification(String? value) {
  if (value == null || value.isEmpty) {
    return Strings.enterMail1;
  }else if(!value.contains('@')){
    return Strings.enterMail2;
  }else if(value.contains(' ')){
    return Strings.enterMail3;
  }return null;
}