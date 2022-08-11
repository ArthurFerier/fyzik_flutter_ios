import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stimulusep/model/exercise.dart';
import 'package:stimulusep/model/exercise_enum.dart';
import 'package:stimulusep/views/generic_widgets/exercise_card.dart';
import 'package:stimulusep/views/filter_chips.dart';

class EvolutionListPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return new EvolutionListPageState();
  }
}

class EvolutionListPageState extends State<EvolutionListPage> {
  List<Exercise> fullList = NameList.instance.graphList();

  late List<Exercise> _filtered;
  int _value = -1;

  @override
  void initState() {
    fullList.sort();
    _filtered = fullList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          FilterChips(_filter),
          Expanded(child: Center(
            child: ListView(
              children: <Widget>[
                ..._filtered.map((exercise) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    GestureDetector(
                      child: ExerciseCard(exercise, -1),
                    ),
                  ],
                ))
              ],
            ),
          ))
        ]
    );
  }

  _filter(int newValue){
    setState(() {
      _value = newValue;
      _filtered = (_value == -1)?fullList:
      fullList.where((element) => element.type.compareTo(exerciseType[_value])==0).toList();
    });
  }
}
