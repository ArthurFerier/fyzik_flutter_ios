import 'package:flutter/material.dart';
import 'package:stimulusep/db/database.dart';
import 'package:stimulusep/views/choiceToSelect_page.dart';
import 'package:stimulusep/views/tabs.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../assets/colors.dart';
import '../assets/strings.dart';
import '../db/firestore_db.dart';
import '../model/user.dart';
import 'SchoolTitleWidget.dart';
import 'generic_widgets/form.dart';
import 'generic_widgets/text_container.dart';



class ModifyAccountPage extends StatefulWidget {
  const ModifyAccountPage({Key? key}) : super(key: key);

  @override
  State<ModifyAccountPage> createState() => _ModifyAccountPageState();
}

class _ModifyAccountPageState extends State<ModifyAccountPage> {
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

  int _selectedSex = UserC().sex! == 1 ? 0 : 1; // because it's switched on the view, but not in the db
  int selectedDay = UserC().birthDay!.day;
  int selectedMonth = UserC().birthDay!.month;
  int selectedYear = UserC().birthDay!.year;
  String _firstName = UserC().firstName!;
  String _lastName = UserC().lastName!;
  String _selectedSchool = UserC().school!;
  //String _selectedCountry = UserC().country!;

  bool isButtonIgnored = false;
  bool loading = false;


  final firstNameCon = new TextEditingController()..text = UserC().firstName!;
  final lastNameCon = new TextEditingController()..text = UserC().lastName!;




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
            child: const Text(Strings.save,
                style: TextStyle(fontSize: 22)),
            onPressed: () async {
              if(_formKey.currentState!.validate()) {
                _validateChanges();
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

    return buildListTile(
        title: _selectedSchool,
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

    return buildListTile(
        title: _selectedCountry,
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

  Future<void> _validateChanges() async {
    int sexFinish;
    if (_selectedSex == 1) {
      sexFinish = 0;
    } else {
      sexFinish = 1;
    }

    UserC().sex = sexFinish;
    UserC().school = _selectedSchool;
    //UserC().country = _selectedCountry;
    UserC().lastName = _lastName;
    UserC().firstName = _firstName;
    UserC().birthDay = DateTime(selectedYear, selectedMonth, selectedDay);

    await FDatabase.instance.updateUser();
    setUserToExternal(null);

    await UserC().updatePercentiles();

    Navigator.of(context).pop();
    Navigator
        .of(context)
        .pushReplacement(
        MaterialPageRoute(
            builder: (context) => TabsPage()
        )
    );

    return;
  }

}
