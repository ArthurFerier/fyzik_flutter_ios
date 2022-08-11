import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stimulusep/assets/colors.dart';
import 'package:stimulusep/assets/strings.dart';
import 'package:stimulusep/db/firestore_db.dart';
import 'package:stimulusep/model/authentication_service.dart';
import 'package:stimulusep/views/forgot_password.dart';
import 'package:stimulusep/views/generic_widgets/form.dart';
import 'package:stimulusep/views/generic_widgets/text_container.dart';
import 'package:stimulusep/views/tabs.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'UserDisabledPage.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _combNotOK = false;

  final emailCon = new TextEditingController();
  final pass1Con = new TextEditingController();
  bool isPasswordVisible = true;
  bool loading = false;
  bool isButtonIgnored = false;

  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    return FormWidget(
        loading: loading,
        formKey: _formKey,
        children: inputs()
    );
  }

  List<Widget> inputs() {
    return [
      Container(),

      textContainer(Strings.enterMail),

      Container(
        child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: emailCon,
          autofocus: false,
          onChanged: (newValue) {
            _email = emailCon.text.toLowerCase();
          },
          decoration: InputDecoration(
              focusColor: colorPrimaryLight,
              hintText: Strings.exampleMail,
              errorMaxLines: 2,
              contentPadding: EdgeInsets.fromLTRB(
                  20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(32.0),
              )
          ),
          validator: (String? value) {
            String? _errorLog = emailVerification(value);
            if (_errorLog != null) {
              return _errorLog;
            } else if (_combNotOK) {
              return Strings.wrongComb;
            }
            _email = emailCon.text.toLowerCase();
            return null;
          },
        ),
      ),

      Container(),

      textContainer(Strings.myPassword),

      Column(
        children: [Container(
          child: TextFormField(
            keyboardType: TextInputType.text,
            controller: pass1Con,
            autofocus: false,
            obscureText: isPasswordVisible,
            decoration: InputDecoration(
                focusColor: colorPrimaryLight,
                hintText: Strings.egPassword,
                suffixIcon: IconButton(
                  icon: isPasswordVisible ?
                  Icon(Icons.visibility_off) : Icon(Icons.visibility),
                  onPressed: () => setState(() =>
                  isPasswordVisible = !isPasswordVisible),
                ),
                contentPadding: EdgeInsets.fromLTRB(
                    20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(32.0),
                )
            ),
            validator: (String? value) {
              if (value == null) {
                return Strings.enterPass;
              } else if (value.length < 6) {
                return Strings.passLengthSignin;
              } else if (_combNotOK) {
                return Strings.wrongComb;
              }
              _password = pass1Con.text;
              return null;
            },
            onSaved: (String? value) async {
              if (_formKey.currentState!.validate()) {
                FocusScope.of(context).unfocus();
                ConnectivityResult connectivity = await Connectivity()
                    .checkConnectivity();
                if (connectivity != ConnectivityResult.mobile
                    && connectivity != ConnectivityResult.wifi) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(Strings.wifiRequirement),
                          backgroundColor: Colors.red)
                  );
                  return;
                }
                setState(() {
                  isButtonIgnored = true;
                  loading = true;
                });
                try {
                  AuthenticationService authServ = AuthenticationService(
                      FirebaseAuth.instance);
                  String? signedIn = await authServ.signIn(email: _email!,
                      password: _password!);
                  if (signedIn == "Signed in") {
                    _warning();
                  } else {
                    _combNotOK = true;
                    _formKey.currentState!.validate();
                  }
                } on FirebaseAuthException catch (e) {
                  print(e);
                  if (e.code == "user-disabled") {
                    Navigator
                        .of(context)
                        .pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => UserDisabledPage(_email!)
                        )
                    );
                  } else {
                    _combNotOK = true;
                    _formKey.currentState!.validate();
                  }
                } finally {
                  setState(() {
                    isButtonIgnored = false;
                    loading = false;
                  });
                }
              }
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //forgotPassWidget(context, emailCon.text),
            TextButton(
              onPressed: () => onPress(emailCon.text.toLowerCase(), context),
              child: Text(
                Strings.forgotPass,
                style: TextStyle(
                    color: colorPrimary),
              ),
            )
          ],
        )
      ]),

      SizedBox(
          height: 40,
          child: IgnorePointer(
            ignoring: isButtonIgnored,
            child: ElevatedButton(
              onPressed: () async {
                _combNotOK = false;
                _formKey.currentState!.save();
              },
              child: const Text(
                  Strings.auth,
                  style: TextStyle(fontSize: 22)),
            ),
          )
      ),
    ];
  }

  Future<void> _warning() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(Strings.rules),
            content: const Text(Strings.warning),
            actions: <Widget>[
              TextButton(
                  onPressed: () async {
                    await getDataFromExternal(_email!, _password!);
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString("dateLastLogin", DateTime.now().toString());
                    Navigator.pop(context);
                    Navigator.of(this.context).pop();
                    Navigator
                        .of(context)
                        .pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => TabsPage()
                        )
                    );
                  },
                  child: Text("Ok"))
            ]);
      });
  }
}
