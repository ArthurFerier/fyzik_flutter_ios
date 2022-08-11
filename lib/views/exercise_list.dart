import 'package:flutter/material.dart';
import 'package:stimulusep/assets/colors.dart';
import 'package:stimulusep/model/exercise_enum.dart';
import 'package:stimulusep/model/exercise.dart';
import 'package:stimulusep/assets/strings.dart';
import 'package:contextualactionbar/contextualactionbar.dart';
import 'package:stimulusep/model/user.dart';
import 'package:stimulusep/views/exercise_fragment.dart';
import 'package:stimulusep/views/filter_chips.dart';
import 'package:stimulusep/views/report_fragment.dart';
import 'package:intl/intl.dart';
import 'generic_widgets/exercise_card.dart';

class ExerciseListPage extends StatefulWidget{
  final int _index;
  const ExerciseListPage(this._index);

  @override
  State<StatefulWidget> createState() {
    return _ExerciseListPageState();
  }
}

class _ExerciseListPageState extends State<ExerciseListPage>{
  int willPop = 0;
  int _editor = 0; //true => edit report
  BuildContext? _context;
  List<Exercise> _toDelete = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: ContextualScaffold<Exercise>(
          appBar: AppBar(
            title: _appBarText(UserC().reports[widget._index].year),
            actions: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    if(willPop==0) setState(() { _editor=(_editor+1)%2;});
                  },
                ),
              )
            ],
          ),
          body: MyStack(_callBackPop, _editor, _callbackContext, widget._index, _callBackSetState),
          contextualAppBar: ContextualAppBar(
            elevation: 0.0,
            counterBuilder: (itemsCount) => (itemsCount>1)?Text("$itemsCount ${Strings.selected}"):Text("$itemsCount ${Strings.selected}"),
            closeIcon: Icons.arrow_back,
            contextualActions: [
              ContextualAction(
                itemsHandler: (List<Exercise> items) => {
                  _toDelete.addAll(items),
                  _showDialog(context)
                },
                child: Icon(Icons.delete),
              ),
            ],
          ),
        )
      ),
      onWillPop: () async{
        switch(willPop){
          case 1:
            setState(() {});
            return false;
          case 2:
            ActionMode.disable<Exercise>(_context!);
            return false;
          default:
            return true;
        }
      }
    );
  }

  Widget _appBarText(int year){
    String _text1 = Strings.ReviewSpace+year.toString();
    String _text2 = ' (' + DateFormat('dd/MM/yyyy').format(UserC().reports[widget._index].date)+')';

    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 20),
        children: [
          TextSpan(text: _text1),
          WidgetSpan(
            child: Transform.translate(
              offset: const Offset(0.0, -7.0),
              child: Text((year==1)?'ère':'ème', style: TextStyle(fontSize: 11),
              ),
            ),
          ),
          TextSpan(text: _text2)
        ],
      ),
    );
  }

  _callbackContext(BuildContext context){
    _context = context;
  }

  //0 can pop, 1 stack on, 2 appbar on, 4 stack off, 3 appbar off
  _callBackPop(int newWillPop){
    if(newWillPop==0) return;
    else if(willPop==0 && newWillPop<3) willPop = newWillPop;
    else if(willPop+newWillPop==5) willPop = 0;
  }

  _callBackSetState(){
    setState(() {});
  }

  _showDialog(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(Strings.dialog),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await UserC().reports[widget._index].removeExercises(_toDelete);
                _toDelete.clear();
                setState(() {});
                Navigator.of(context).pop();
              },
              child: Text(Strings.Yes)),
            TextButton(
              onPressed: () {
                _toDelete.clear();
                Navigator.of(context).pop();
              },
              child: Text(Strings.No))
          ]
        );
      }
    );
  }
}

class MyStack extends StatefulWidget{
  final ValueChanged<int> parentWillPop;
  final int parentEditor;
  final ValueChanged<BuildContext> parentContext;
  final int _index;
  final dynamic parentSetState;
  MyStack(this.parentWillPop, this.parentEditor, this.parentContext, this._index, this.parentSetState);

  @override
  State<StatefulWidget> createState() => new MyStackState();
}

class MyStackState extends State<MyStack>{
  int _editor = 0;
  bool _forceStack = false;
  bool _visible = false;
  Exercise _exercise = Exercise(type: 'Morphologie', unit: '', time: 0, name: '');

  @override
  Widget build(BuildContext context) {
    return Stack(children: myList());
  }

  List<Widget> myList(){
    List<Widget> _temp = List.empty(growable: true);
    _temp.add(ExerciseList(widget.parentWillPop, _exchange, widget.parentContext, widget._index));
    if(widget.parentEditor!=_editor){
      widget.parentWillPop(1);
      _temp.add(_modal());
      _temp.add(Center(child: ReportFragment(UserC().reports[widget._index], _change)));
      _forceStack = false;
      _editor = (_editor+1)%2;
    } else if(_forceStack){
      widget.parentWillPop(1);
      _temp.add(_modal());
      _temp.add(Center(child: ExerciseFragment(_exercise, _change, widget._index)));
      _forceStack = false;
    } else {
      widget.parentWillPop(4);
      _temp.add(_button());
    }
    return _temp;
  }

  Widget _modal(){
    return Opacity(
      opacity: 0.8,
      child: ModalBarrier(
        dismissible: true,
        color: Colors.grey
      )
    );
  }

  Widget _button(){
    return Positioned(
      bottom: 15,
      right: 15,
      child: FloatingActionButton(
        elevation: 0.0,
        child: Icon(Icons.add),
        backgroundColor: colorPrimaryDark,
        onPressed: _change
      )
    );
  }

  _change([bool force = true]){
    _forceStack = force;
    _visible = !_visible;
    if(force==false) {
      _exercise = Exercise(type: 'Morphologie', unit: '', time: 0, name: '');
      widget.parentSetState();
    } else setState(() {});
  }

  _exchange(Exercise exercise){
    _exercise = exercise;
    _change();
  }
}

class ExerciseList extends StatefulWidget{
  final ValueChanged<int> parentAction;
  final ValueChanged<Exercise> exchange;
  final ValueChanged<BuildContext> parentContext;
  final int _index;
  const ExerciseList(this.parentAction, this.exchange, this.parentContext, this._index);

  @override
  State<StatefulWidget> createState() {
    return new ExerciseListState();
  }
}

class ExerciseListState extends State<ExerciseList>{
  List<Exercise> _filtered = List<Exercise>.empty(growable: true);
  int _value = -1;

  @override
  void initState() {
    super.initState();
    widget.parentContext(context);
  }

  @override
  Widget build(BuildContext context) {
    ActionMode.enabledStream<Exercise>(context).listen((event) {
      widget.parentAction((event) ? 2 : 3);
    });

    sortList();

    return Center(
        child: (_filtered.isEmpty)?Text(Strings.firstExercise):_listView()
    );
  }

  Widget _listView(){
    return Column(
      children: [
        FilterChips(_filter),
        Expanded(child: Center(
          child: ListView(
            children: <Widget>[
              ..._filtered.map((exercise) => Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ContextualActionWidget(
                    selectedWidget: _checkIcon(true),
                    unselectedWidget: _checkIcon(false),
                    selectedColor: colorPrimary,
                    data: exercise,
                    child: GestureDetector(
                      onTap: (){
                        widget.exchange(exercise);
                      },
                      child: ExerciseCard(exercise, widget._index),
                    ),
                  ),
                ],
              ))
            ],
          ),
        ))
      ]
    );
  }

  Widget _checkIcon(bool isChecked){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20),
          child: (isChecked)?Icon(Icons.check_circle, color: colorPrimary):
          Icon(Icons.radio_button_unchecked, color: colorPrimary),//check_circle_outlined
        ),
      ],
    );
  }

  _filter(int newValue){
    setState(() {
      _value = newValue;
      sortList();
    });
  }

  sortList(){
    _filtered.clear();
    if(_value == -1) UserC().reports[widget._index].exercises.forEach((element) { _filtered.add(element.copy()); });
    else UserC().reports[widget._index].exercises
        .where((element) => element.type == exerciseType[_value])
        .toList()
        .forEach((element) { _filtered.add(element.copy()); });
    _filtered.sort();
  }
}