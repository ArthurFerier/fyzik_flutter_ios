import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stimulusep/assets/colors.dart';
import 'package:stimulusep/assets/strings.dart';
import 'package:stimulusep/db/firestore_db.dart';
import 'package:stimulusep/model/authentication_service.dart';
import 'package:stimulusep/views/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stimulusep/views/verify_email_page.dart';
import 'forgot_password.dart';
import 'generic_widgets/form.dart';
import 'generic_widgets/text_container.dart';



class SignupPage extends StatefulWidget {
  SignupPage();
  @override
  State<StatefulWidget> createState() {
    return new SignupPageState();
  }
}

class SignupPageState extends State<SignupPage> {
  SignupPageState();
  final _formKey = GlobalKey<FormState>();

  bool _usernameTaken = false;
  bool _codeNotOK = false;

  String? _email;
  String? _password1;
  String? _code;
  bool isPasswordVisible = true;
  bool isButtonIgnored = false;
  bool loading = false;

  final emailCon = new TextEditingController();
  final pass1Con = new TextEditingController();
  final pass2Con = new TextEditingController();
  final codeCon = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FormWidget(
        topButton: topButton(),
        loading: loading,
        formKey: _formKey,
        children: inputs()
    );
  }

  Widget topButton() {
    return Positioned(
      child: TextButton(
        child: Text(
          Strings.alreadyAccount,
          style: TextStyle(
              color: colorPrimary),
          textAlign: TextAlign.center,
        ),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SigninPage()
            )
        ),
      ),
      right: 5,
    );
  }

  List<Widget> inputs() {
    return [
      textContainer(Strings.enterMail),

      TextFormField(
        keyboardType: TextInputType.emailAddress,
        controller: emailCon,
        decoration: InputDecoration(
            focusColor: colorPrimaryLight,
            hintText: Strings.exampleMail,
            errorMaxLines: 2,
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
            )
        ),
        validator: (String? value) {
          String? _errorLog = emailVerification(value);
          if (_errorLog!=null){
            return _errorLog;
          }else if(_usernameTaken){
            return Strings.emailUsed;
          }
          _email = emailCon.text.toLowerCase();
          return null;
        },
      ),

      textContainer(Strings.myPassword),

      TextFormField(
        keyboardType: TextInputType.text,
        controller: pass1Con,
        obscureText: isPasswordVisible,
        decoration: InputDecoration(
            focusColor: colorPrimaryLight,
            hintText: Strings.firstPassword,
            errorMaxLines: 2,
            suffixIcon: IconButton(
              icon: isPasswordVisible ?
              Icon(Icons.visibility_off) : Icon(Icons.visibility),
              onPressed: () => setState(()
              => isPasswordVisible = !isPasswordVisible),
            ),
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
            )
        ),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return Strings.enterPass;
          }else if (value.length < 6) {
            return Strings.passLength;
          }else if(value.contains(' ')){
            return Strings.passSpace;
          }
          _password1 = pass1Con.text;
          return null;
        },
      ),

      TextFormField(
        keyboardType: TextInputType.text,
        controller: pass2Con,
        obscureText: isPasswordVisible,
        decoration: InputDecoration(
            focusColor: colorPrimaryLight,
            hintText: Strings.confirmPassword,
            errorMaxLines: 2,
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
            )
        ),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return Strings.enterPass;
          }else if (_password1 != value) {
            return Strings.notTheSamepass;
          }
          return null;
        },
      ),

      textContainer(Strings.codeText),

      TextFormField(
        keyboardType: TextInputType.text,
        controller: codeCon,
        decoration: InputDecoration(
            focusColor: colorPrimaryLight,
            hintText: Strings.codeInBook,
            errorMaxLines: 2,
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
            )
        ),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return Strings.enterCode;
          }else if (value.replaceAll("-", "").length != 7) {
            return Strings.errorCode;
          }else if(_codeNotOK){
            return Strings.errorCode;
          }
          _code = codeCon.text;
          return null;
        },
        onSaved: (String? value) async{
          if(_formKey.currentState!.validate()) {
            ConnectivityResult connectivity = await Connectivity().checkConnectivity();
            if (connectivity != ConnectivityResult.mobile
                && connectivity != ConnectivityResult.wifi) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(Strings.wifiRequirement),
                      backgroundColor: Colors.red)
              );
              return;
            }
            await verifyCodeInExt(value!).then((value) async {
              _codeNotOK = value == false;
              if (_formKey.currentState!.validate()){
                setState(() {
                  isButtonIgnored = true;
                  loading = true;
                });

                try {
                  AuthenticationService authServ = AuthenticationService(FirebaseAuth.instance);
                  //returns UserCredential?;
                  await authServ.signUp(email: _email!, password: _password1!, context: context);
                  await toPref(_email!, _password1!, _code!);
                  //deleteCodeInExt(_code!);
                } on FirebaseAuthException catch(e) {
                  print(e);
                  _usernameTaken = true;
                  _formKey.currentState!.validate();
                  return;
                }finally{
                  setState(() {
                    isButtonIgnored = false;
                    loading = false;
                  });
                }
                Navigator
                    .of(context)
                    .pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                        //SignupPage2(_email!, _password1!, _code!)
                        VerifyEmailPage(_email!, _password1!, _code!)
                    )
                );
              }
            });
          }
        }
      ),

      SizedBox(
        height: 40,
        child: IgnorePointer(
          ignoring: isButtonIgnored,
          child: ElevatedButton(
            child: const Text(Strings.next,
                style: TextStyle(fontSize: 22)),
            onPressed: () async {
              FocusScope.of(context).unfocus();
              _usernameTaken = false;
              _codeNotOK = false;
              _formKey.currentState!.save();
            },
            style: ElevatedButton.styleFrom(
                primary: colorPrimary),
          ),
        ),
      ),
     ];
  }

  static Future<bool> toPref(String email, String pass, String code) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("info", email+' '+pass+' '+code);
  }

}