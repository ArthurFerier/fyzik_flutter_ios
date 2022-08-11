import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stimulusep/assets/strings.dart';
import 'package:stimulusep/views/generic_widgets/text_container.dart';
import 'package:stimulusep/views/signup.dart';
import 'package:stimulusep/views/signup2.dart';

class VerifyEmailPage extends StatefulWidget {
  final String _email, _password1, _code;
  const VerifyEmailPage(this._email, this._password1, this._code);

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool showErrorMessage = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        Duration(seconds: 3),
          (_) => checkEmailVerified(),
      );
    }
  }

  Future checkEmailVerified() async {
    // call after email verification
    await FirebaseAuth.instance.currentUser!.reload(); // todo : error here, we have to send back the user to the signup screen

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    // cancelling the timer if the email is verified
    if (isEmailVerified) timer?.cancel();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user!.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      final snackBar = SnackBar(
        content: Text(Strings.cantSendEmail),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? SignupPage2(widget._email, widget._password1, widget._code)
      : Scaffold(
        appBar: AppBar(
          title: Text(Strings.verifyEmail),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              textContainer(Strings.emailVerifSent + widget._email),
              SizedBox(height: 24,),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                ),
                icon: Icon(Icons.email, size: 32),
                label: Text(
                  Strings.resendEmail,
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: canResendEmail
                    ? sendVerificationEmail
                    : null
              ),

              SizedBox(height: 8,),
              TextButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                ),
                child: Text(
                  Strings.cancel,
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.currentUser!.delete();
                  } catch(e) {
                    // we must reauthenticate the user
                    await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(
                      EmailAuthProvider.credential(email: widget._email, password: widget._password1)
                    );
                    await FirebaseAuth.instance.currentUser!.delete();
                  }
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  bool deleted = await prefs.remove("info");
                  if (deleted) {
                    Navigator
                        .of(context)
                        .pushReplacement(
                        MaterialPageRoute(
                            builder: (context) =>
                                SignupPage()
                        )
                    );
                  } else {
                    print("shared prefs not deleted");
                  }
                },
              ),
            ],
          ),
        ),
      );
}
