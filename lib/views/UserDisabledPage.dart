import 'package:flutter/material.dart';
import 'package:stimulusep/views/generic_widgets/text_container.dart';
import 'package:stimulusep/assets/strings.dart';
import 'package:stimulusep/views/signin.dart';

class UserDisabledPage extends StatefulWidget {
  final String _email;
  const UserDisabledPage(this._email);

  @override
  State<UserDisabledPage> createState() => _UserDisabledPageState();
}

class _UserDisabledPageState extends State<UserDisabledPage> {

  Future<bool> _onWillPop() async {
    Navigator
        .of(context)
        .pushReplacement(
        MaterialPageRoute(
            builder: (context) => SigninPage()
        )
    );
    return true;
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: Container(
            child: textContainer(
                Strings.userDisabledFirst +
                    widget._email +
                    Strings.userDisabledSec
            ),
            alignment: Alignment.center,
          ),
        ),
        onWillPop: _onWillPop,
    );
  }
}
