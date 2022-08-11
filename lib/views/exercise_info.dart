import 'package:flutter/material.dart';
import 'package:stimulusep/assets/strings.dart';

class ExerciseInfoPage extends StatelessWidget {
  final String name;
  final AssetImage _image;
  const ExerciseInfoPage(this.name, this._image);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        leading: TextButton(
          child: Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(name)
      ),
      body: ExerciseInfo(name, _image),
    );
  }
}

class ExerciseInfo extends StatelessWidget {
  final String name;
  final AssetImage _image;
  const ExerciseInfo(this.name, this._image);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPadding(Strings.descriptionTest, getTextStyle()),
          buildPadding(_exInfo()[0]),
          buildPadding(Strings.material, getTextStyle()),
          buildPadding(_exInfo()[2]),
          buildPadding(Strings.instructions, getTextStyle()),
          buildPadding(_exInfo()[1]),
          buildPadding(Strings.example, getTextStyle()),
          buildPadding(_exInfo()[3]),
          Center(child: Image(image: (name.compareTo(Strings.lucLeger)==0)?AssetImage('lib/assets/images/tableau_luc.png'):_image))
        ],
      ),
    );
  }

  Padding buildPadding(String text, [TextStyle? style]){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(text, style: style)
    );
  }

  TextStyle getTextStyle(){
    return TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold);
  }

  List<String> _exInfo(){
    List<String> _temp = List.empty(growable: true);

    switch (name){
      case Strings.height:
        _temp.add(Strings.taille_desc);
        _temp.add(Strings.taille_inst);
        _temp.add(Strings.taille_mat);
        _temp.add(Strings.taille_ex);
        break;
      case Strings.weight:
        _temp.add(Strings.poids_desc);
        _temp.add(Strings.poids_inst);
        _temp.add(Strings.poids_mat);
        _temp.add(Strings.poids_ex);
        break;
      case Strings.waist:
        _temp.add(Strings.tour_desc);
        _temp.add(Strings.tour_inst);
        _temp.add(Strings.tour_mat);
        _temp.add(Strings.tour_ex);
        break;
      case Strings.shuttleRace:
        _temp.add(Strings.course_desc);
        _temp.add(Strings.course_nav_inst);
        _temp.add(Strings.course_nav_mat);
        _temp.add(Strings.course_nav_ex);
        break;
      case Strings.handGrip:
        _temp.add(Strings.hand_grip_desc);
        _temp.add(Strings.hand_grip_inst);
        _temp.add(Strings.hand_grip_mat);
        _temp.add(Strings.hand_grip_ex);
        break;
      case Strings.suspension:
        _temp.add(Strings.suspension_desc);
        _temp.add(Strings.suspension_inst);
        _temp.add(Strings.suspension_mat);
        _temp.add(Strings.suspension_ex);
        break;
      case Strings.sitUp:
        _temp.add(Strings.redessement_desc);
        _temp.add(Strings.redressement_inst);
        _temp.add(Strings.redressement_mat);
        _temp.add(Strings.redressement_ex);
        break;
      case Strings.trunkFlexion:
        _temp.add(Strings.flex_desc);
        _temp.add(Strings.flex_inst);
        _temp.add(Strings.flex_mat);
        _temp.add(Strings.flex_ex);
        break;
      case Strings.jumpWOMom:
        _temp.add(Strings.saut_desc);
        _temp.add(Strings.saut_inst);
        _temp.add(Strings.saut_mat);
        _temp.add(Strings.saut_ex);
        break;
      case Strings.hittingPlates:
        _temp.add(Strings.frappe_desc);
        _temp.add(Strings.frappe_inst);
        _temp.add(Strings.frappe_mat);
        _temp.add(Strings.frappe_ex);
        break;
      case Strings.flamingoBalance:
        _temp.add(Strings.equilibre_desc);
        _temp.add(Strings.equilibre_inst);
        _temp.add(Strings.equilibre_mat);
        _temp.add(Strings.equilibre_ex);
        break;
      case Strings.lucLeger:
        _temp.add(Strings.luc_desc);
        _temp.add(Strings.luc_inst);
        _temp.add(Strings.luc_mat);
        _temp.add(Strings.luc_ex);
    }
    return _temp;
  }
}
