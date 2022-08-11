import 'package:flutter/material.dart';
import 'package:stimulusep/assets/strings.dart';
import 'package:stimulusep/model/exercise_enum.dart';

class FilterChips extends StatefulWidget{
  final ValueChanged<int> parentValue;
  const FilterChips(this.parentValue);

  @override
  State<StatefulWidget> createState() {
    return new _FilterChipsState();
  }
}

class _FilterChipsState extends State<FilterChips>{
  int _value = -1;
  late List<String> _types;

  @override
  void initState() {
    super.initState();
    _types = NameList.instance.getTypes();
    _types.sort();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 35,
        margin: EdgeInsets.all(5),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: _chips()),
        )
    );
  }

  List<Widget> _chips(){
    List<Widget> _list = List<Widget>.generate(
      _types.length,
          (int index) {return _chip(index);},
    ).toList();

    _list.insert(0, _chip(-1));
    return _list;
  }

  Widget _chip(int index){
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5), child: FilterChip(
      label: index==-1?Text(Strings.Every):Text(_types[index]),
      selected: _value == index,
      onSelected: (bool selected) {
        if(_value!=index) {
          _value = index;
          widget.parentValue(_value);
        }
      },
    )
    );
  }
}