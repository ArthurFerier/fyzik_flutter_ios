import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stimulusep/assets/colors.dart';
import 'package:stimulusep/assets/strings.dart';
import 'package:stimulusep/db/database.dart';
import 'package:stimulusep/db/firestore_db.dart';
import 'package:stimulusep/model/user.dart';
import 'package:stimulusep/views/SchoolTitleWidget.dart';
import 'package:stimulusep/views/generic_widgets/text_container.dart';
import 'package:stimulusep/views/choiceToSelect_page.dart';
import 'package:stimulusep/views/tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'generic_widgets/form.dart';

class SignupPage2 extends StatefulWidget {
  final String _email, _password1, _code;
  const SignupPage2(this._email, this._password1, this._code);

  @override
  State<StatefulWidget> createState() {
    return new SignupPageState2();
  }
}

class SignupPageState2 extends State<SignupPage2> {
  final _formKey = GlobalKey<FormState>();

  List<String> labels = [Strings.boy, Strings.girl];
  static final List<String> days = List<String>.generate(
    31,
    (index) {
      return (index + 1).toString();
    },
  ).toList();
  static final List<String> months = days.sublist(0, 12);
  static final List<String> years = List<String>.generate(
    20,
    (index) {
      return (DateTime.now().year - 25 + index).toString();
    },
  ).toList();

  int _selectedSex = 0; // 0 is boy, 1 girl
  int selectedDay = 1;
  int selectedMonth = 1;
  int selectedYear = int.parse(years.first);

  bool isButtonIgnored = false;
  bool loading = false;

  String? _firstName, _lastName, _selectedSchool;
  //String? _selectedCountry;

  final firstNameCon = new TextEditingController();
  final lastNameCon = new TextEditingController();

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
      Spacer(),

      textContainer(Strings.choiceSex),

      SizedBox(
        height: 35,
        child: Container(
          alignment: Alignment.center,
          child: ToggleSwitch(
            totalSwitches: 2,
            labels: labels,
            activeBgColor: [colorPrimaryDark],
            inactiveBgColor: Colors.grey,
            activeFgColor: Colors.lightBlueAccent,
            inactiveFgColor: Colors.black,
            initialLabelIndex: _selectedSex,
            onToggle: (index) => {
              //setState(() => selectedSex = index!),
              _selectedSex = index!,
            },
          ),
        ),
      ),

      textContainer(Strings.birthDate),

      SizedBox(
        height: 75,
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceEvenly,
          children: [
            buildDropdown(70, Strings.day, days),
            buildDropdown(90, Strings.month, months),
            buildDropdown(94, Strings.year, years)
          ],
        ),
      ),

      textContainer(Strings.enterFirstName),

      Container(
        child: TextFormField(
            keyboardType: TextInputType.text,
            controller: firstNameCon,
            autofocus: false,
            decoration: InputDecoration(
                focusColor: colorPrimaryLight,
                hintText: Strings.exampleFirstName,
                errorMaxLines: 2,
                contentPadding: EdgeInsets.fromLTRB(
                    20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(32.0),
                )
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return Strings.enterFirstName1;
              }
              _firstName = firstNameCon.text;
              return null;
            }
        ),
      ),

      textContainer(Strings.enterLastName),

      Container(
        child: TextFormField(
            keyboardType: TextInputType.text,
            controller: lastNameCon,
            autofocus: false,
            decoration: InputDecoration(
                focusColor: colorPrimaryLight,
                hintText: Strings.exampleLastName,
                errorMaxLines: 2,
                contentPadding: EdgeInsets.fromLTRB(
                    20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(32.0),
                )
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return Strings.enterLastName1;
              }
              _lastName = lastNameCon.text;
              return null;
            }
        ),
      ),

      textContainer(Strings.mySchool),

      Container(
        child: Card(
          child: buildSelectedSchool(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: new BorderSide(color: Colors.grey)
          ),
          color: Colors.white,
        ),
      ),

    /*
      textContainer(Strings.myCountry),

      Container(
        child: Card(
          child: buildSelectedCountry(),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: new BorderSide(color: Colors.grey)
          ),
          color: Colors.white,
        ),
      ),*/

      Spacer(flex: 8),

      SizedBox(
        height: 28,
        child: IgnorePointer(
          ignoring: isButtonIgnored,
          child: ElevatedButton(
            child: const Text(Strings.begin,
                style: TextStyle(fontSize: 22)),
            onPressed: () async {
              if(_formKey.currentState!.validate()) {
                _privacyPolicy();
              }
            },
            style: ElevatedButton.styleFrom(
                primary: colorPrimary),
          ),
        ),
      ),

      Spacer(flex: 2,)
    ];
  }

  Widget buildSelectedSchool() {
    final ontap = () async {
      List<String> schools = await getSchoolsFromExternal();
      final ChoiceToSelect? school = await Navigator.push(context, MaterialPageRoute(
          builder: (context) => ChoiceToSelectPage(schools, Strings.selectSchool, Strings.searchSchools)
      ));
      if (school == null) {
        return;
      }
      setState(() {
        _selectedSchool = school.name;
      });
    };

    return _selectedSchool == null
      ? buildListTile(title: Strings.noSchool, color: Colors.grey.shade600, ontap: ontap)
      : buildListTile(
          title: _selectedSchool!,
          color: Colors.black,
          ontap: ontap
      );
  }

  /*
  Widget buildSelectedCountry() {
    final ontap = () async {
      List<String> countries = await getCountriesFromExternal();
      final ChoiceToSelect? country = await Navigator.push(context, MaterialPageRoute(
          builder: (context) => ChoiceToSelectPage(countries, Strings.selectCountry, Strings.searchCountries)
      ));
      if (country == null) {
        return;
      }
      setState(() {
        _selectedCountry = country.name;
      });
    };

    return _selectedCountry == null
        ? buildListTile(title: Strings.noCountry, color: Colors.grey.shade600, ontap: ontap)
        : buildListTile(
        title: _selectedCountry!,
        color: Colors.black,
        ontap: ontap
    );
  }*/

  Widget buildListTile({
    required String title,
    required Color color,
    required VoidCallback ontap
  }) {
    return ListTile(
      onTap: ontap,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 18,
        ),
      ),
      trailing: Icon(Icons.arrow_drop_down, color: color),
    );
  }

  Widget buildDropdown(double width, String title, List<String> list) {
    late String temp;
    if(title.compareTo(Strings.day)==0) temp = selectedDay.toString();
    else if(title.compareTo(Strings.month)==0) temp = selectedMonth.toString();
    else temp = selectedYear.toString();

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: temp,
              items: list
                  .map((item) => DropdownMenuItem<String>(
                child: Text(
                  item,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                value: item,
              ))
                  .toList(),
              onChanged: (element) => setState(() {
                if(element==null) return;
                if(title.compareTo(Strings.day)==0) selectedDay = int.parse(element);
                else if(title.compareTo(Strings.month)==0) selectedMonth = int.parse(element);
                else selectedYear = int.parse(element);
              }),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _privacyPolicy() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Règlement général sur la protection des données"),
          content: const Text(Strings.dataPolicy),
          actions: <Widget>[
            TextButton(onPressed: (){ Navigator.pop(context); }, child: Text('Annuler')),
            TextButton(
              onPressed: () async{
                ConnectivityResult connectivity = await Connectivity().checkConnectivity();
                FocusScope.of(context).unfocus();
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

                DateTime birthDay = DateTime(selectedYear,
                    selectedMonth, selectedDay);

                int sexFinish;
                if (_selectedSex == 1) {
                  sexFinish = 0;
                } else {
                  sexFinish = 1;
                }

                new UserC(
                  birthDay: birthDay,
                  sex: sexFinish,
                  email: widget._email,
                  password: widget._password1,
                  firstName: _firstName,
                  lastName: _lastName,
                  school: _selectedSchool,
                  //country: _selectedCountry
                );
                setState(() {
                  isButtonIgnored = false;
                });
                await FDatabase.instance.createUser();
                setUserToExternal(widget._code);
                deleteCodeInExt(widget._code);
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeRight,
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.portraitDown,
                  DeviceOrientation.portraitUp
                ]);

                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString("dateLastLogin", DateTime.now().toString());
                prefs.remove("info");

                setState(() {
                  isButtonIgnored = false;
                  loading = false;
                });

                Navigator.of(context).pop();
                Navigator
                    .of(context)
                    .pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => TabsPage()
                    )
                );
              },
              child: Text("Continuer"))
          ]);
      });
  }
}
