import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:stimulusep/assets/colors.dart';
import 'package:stimulusep/assets/strings.dart';
import 'package:stimulusep/model/exercise.dart';
import 'package:stimulusep/model/exercise_enum.dart';
import 'package:stimulusep/model/screen_size.dart';
import 'package:stimulusep/model/user.dart';
import 'package:stimulusep/views/generic_widgets/fragment.dart';

import 'generic_widgets/fragment.dart';

class ExerciseFragment extends StatefulWidget{
  final Exercise exercise;
  final dynamic change;
  final int _index;
  const ExerciseFragment(this.exercise, this.change, this._index);

  @override
  State<StatefulWidget> createState() {
    return new ExerciseFragmentState();
  }
}

class ExerciseFragmentState extends State<ExerciseFragment>{
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final typeController = TextEditingController();
  String? eName, eScore;
  late String eUnit, eType;
  late bool newExercise;

  @override
  void initState() {
    super.initState();
    newExercise = widget.exercise.id==-1;
    eType = widget.exercise.type;
    eUnit = widget.exercise.unit;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Fragment(
        children: [
          Padding(
            padding: (newExercise)?EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10):
            EdgeInsets.symmetric(vertical: 20),
            child: _newName(newExercise),
          ),
          if(!newExercise) Divider(
            thickness: 2,
            height: 0,
            color: colorPrimary,
            indent: 20,
            endIndent: 20,
          ),
          LimitedBox(
              maxHeight: screenHeightExcludingToolbar(context, dividedBy: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  LimitedBox(
                    maxWidth: screenWidth(context, dividedBy: 2.5),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: Image(image: Exercise.exImage(widget.exercise.name)),
                    )
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Wrap(
                        children: [ Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _newType(),
                            ),
                            Row(
                              children: [
                                Container(width: 60, child: _newScore()),
                                SizedBox(width: 10),
                                Container(width: 70, child: _newUnit())
                              ],
                            )
                          ],
                        )]
                      )
                    )
                  )
                ],
              ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: (){widget.change(false);}, child: Text(Strings.Cancel)),
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()){
                    _formKey.currentState!.save();
                    bool _temp = eUnit.compareTo("Kg")==0 || eUnit.compareTo("m")==0;
                    eScore = double.parse(eScore!).toStringAsFixed(_temp?2:1);

                    if(newExercise){
                      await UserC().reports[widget._index].addExercise(new Exercise(name: eName!,
                      idRapport: 0, type: eType, unit: eUnit, time: 0, score: double.parse(eScore!)));
                    } else{
                      widget.exercise.type = eType;
                      widget.exercise.unit = eUnit;
                      widget.exercise.score = double.parse(eScore!);
                      if (widget.exercise.id==-1)
                        await UserC().reports[widget._index].addExercise(widget.exercise);
                      else
                        await UserC().reports[widget._index].editExercise(widget.exercise);
                    }
                    widget.change(false);
                  }
                },
                child: Text('Ok')
              )
            ],
          )
        ],
      )
    );
  }

  Widget _newType(){
    if(newExercise){
      return TypeAheadFormField<String?>(
        textFieldConfiguration: TextFieldConfiguration(
          controller: typeController,
          decoration: InputDecoration(
            labelText: Strings.TypeOfTheExercise,
            border: OutlineInputBorder(),
          ),
        ),
        suggestionsCallback: NameList.instance.getTypeSuggestions,
        noItemsFoundBuilder: (value) {return SizedBox();},
        itemBuilder: (context, item) => Padding(
          padding: EdgeInsets.all(10),
          child: Text(item!),
        ),
        onSuggestionSelected: (value) => setState(() {
          typeController.text = value!;
        }),
        validator: (String? value) {
          if (value == null || value.isEmpty) return 'Vide!';
          return null;
        },
        onSaved: (value) => eType = value!,
      );
    }
    return Container(height: 30, child:ChoiceChip(
      label: Text(widget.exercise.type),
      selected: false,
    ));
  }

  Widget _newName(bool isNew){
    if(isNew) {
      return TypeAheadFormField<String?>(
        autoFlipDirection: true,
        textFieldConfiguration: TextFieldConfiguration(
          controller: nameController,
          decoration: InputDecoration(
            labelText: Strings.NameOfTheExercise,
            border: OutlineInputBorder(),
          ),
        ),
        suggestionsCallback: NameList.instance.getNameSuggestions,
        noItemsFoundBuilder: (value) {return SizedBox();},
        itemBuilder: (context, item) => Padding(
          padding: EdgeInsets.all(10),
          child: Text(item!),
        ),
        getImmediateSuggestions: true,
        hideSuggestionsOnKeyboardHide: false,
        onSuggestionSelected: (value) => setState(() {
          nameController.text = value!;
          typeController.text = NameList.instance.searchType(value) ?? eType;
          eUnit = NameList.instance.searchUnit(value) ?? eUnit;
        }),
        validator: (String? value) {
          if (value == null || value.isEmpty) return Strings.EmptyExclamation;
          if (newExercise && UserC().reports[widget._index].exercises.any((element) => element.name.compareTo(value)==0))
            return Strings.alreadyUsed;
          return null;
        },
        onSaved: (value) => eName = value,
      );
    }
    return Text(
      widget.exercise.name,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.grey)
    );
  }

  Widget _newScore(){
    return TextFormField(
      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(
        hintText: (newExercise)?'Score':widget.exercise.score.toString(),
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty && newExercise) {
          return Strings.EmptyExclamation;
        }else if(value.startsWith('-')){
          return Strings.hasToBePositive;
        }
        return null;
      },
      onSaved: (value) => eScore = (value!.isNotEmpty) ?
      value.replaceAll(',', '.') :
      widget.exercise.score.toString().replaceAll(',', '.')
    );
  }

  Widget _newUnit(){
    var txt = TextEditingController();
    txt.text = eUnit;

    if(newExercise) {
      return TextFormField(
        decoration: const InputDecoration(
          hintText: Strings.Unity,
        ),
        controller: txt,
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return Strings.EmptyExclamation;
          }
          return null;
        },
        onSaved: (value) => eUnit = value!,
      );
    }
    return Text(widget.exercise.unit);
  }
}