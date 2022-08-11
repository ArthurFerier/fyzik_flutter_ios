import 'package:flutter/material.dart';
import 'package:stimulusep/assets/strings.dart';
import 'package:stimulusep/model/report.dart';
import 'package:stimulusep/model/screen_size.dart';
import 'package:stimulusep/model/user.dart';
import 'package:stimulusep/views/generic_widgets/fragment.dart';

import 'exercise_list.dart';

class ReportFragment extends StatefulWidget{
  final Report report;
  final dynamic change;
  const ReportFragment(this.report, this.change);

  @override
  State<StatefulWidget> createState() {
    return new ReportFragmentState();
  }
}

class ReportFragmentState extends State<ReportFragment>{
  DateTime selectedDate = DateTime.now();
  List<bool> _selections = List.generate(6, (_) => false);

  @override
  void initState() {
    if(widget.report.id!=-1) {
      selectedDate = widget.report.date;
      _selections[widget.report.year-1] = true;
    }else _selections[0] = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Fragment(
      children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text(Strings.SchoolYear)),
        _buttons(),
        LimitedBox(
          maxHeight: screenHeightExcludingToolbar(context, dividedBy: 2),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: DateTime(selectedDate.year-1),
              lastDate: DateTime(selectedDate.year+1),
              onDateChanged: (DateTime dateTime) {
                setState((){
                  selectedDate = dateTime;
                });
              }
            )
          )
        ),
        Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(onPressed: (){widget.change(false);}, child: Text(Strings.Cancel)),
            TextButton(
              onPressed: () async {
                late bool test = UserC().reports.any((element) => element.date.compareTo(selectedDate)==0);

                if(widget.report.id==-1){
                  if(test){
                    _snackBar();
                    return;
                  }
                  await UserC().addReport(
                    new Report(date: selectedDate, year: _selections.indexOf(true)+1, exercises: [], mail: ''))
                      .then((value) => { widget.change(false),
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ExerciseListPage(UserC().reportIndex(value))))
                      }
                  );
                } else {
                  if(test && !(selectedDate.compareTo(widget.report.date)==0)){
                    _snackBar();
                    return;
                  }
                  widget.report.year = _selections.indexOf(true)+1;
                  widget.report.date = selectedDate;
                  await UserC().editReport(widget.report);
                  widget.change(false);
                }
              },
              child: Text('OK')
            )
          ],
        )
      ],
    );
  }

  Widget _buttons(){
    return ToggleButtons(
      children: List<Widget>.generate(6, (index) => Text((index+1).toString())),
      isSelected: _selections,
      onPressed: (int index) {
        setState((){
          _selections.fillRange(0, _selections.length, false);
          _selections[index] = true;
        });
      },
      constraints: BoxConstraints.tight(Size.square(screenWidth(context, reducedBy: 30, dividedBy: 8))),
    );
  }

  void _snackBar(){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(Strings.reportError),
            backgroundColor: Colors.red)
    );
  }
}