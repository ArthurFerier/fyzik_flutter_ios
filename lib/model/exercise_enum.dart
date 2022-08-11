import 'dart:collection';

import 'exercise.dart';

final List<String> exerciseType = [
  'Morphologie',
  'Endurance',
  'Force',
  'Souplesse',
  'Vitesse',
  'Équilibre',
  'Explosivité'
];

final List<String> basicExercise = [
  'Taille',
  'Tour de taille',
  'Poids',
  'Luc leger',
  'Hand grip',
  'Suspension',
  'Redressement assis',
  'Flexion du tronc',
  'Saut sans élan',
  'Course navette',
  'Frappe des plaques',
  'Équilibre flamingo'
];

final List<String> otherExercise = [
  'Chaise',
  'Gainage',
  'Pompages',
  'Tractions'
];


class NameList {
  static final NameList _instance = NameList._nameList();

  static NameList get instance => _instance;

  HashSet<String> _names= HashSet();
  HashSet<String> _graphList = HashSet();
  HashMap<String, int> _times = HashMap();
  HashMap<String, String> _units = HashMap();
  HashMap<String, String> _types = HashMap();

  NameList._nameList(){
    basicExercise.forEach((element) {
      _names.add(element);
      switch (element) {
        case 'Taille':
          _addElement(element, 1, 'm', 'Morphologie');
          break;
        case 'Tour de taille':
          _addElement(element, 0, 'cm', 'Morphologie');
          break;
        case 'Poids':
          _addElement(element, 1, 'Kg', 'Morphologie');
          break;
        case 'Luc leger':
          _addElement(element, 1, 'palier(s)', 'Endurance');
          break;
        case 'Hand grip':
          _addElement(element, 1, 'Kg', 'Force');
          break;
        case 'Suspension':
          _addElement(element, 1, 's', 'Force');
          break;
        case 'Redressement assis':
          _addElement(element, 1, 'Rep(s)', 'Force');
          break;
        case 'Flexion du tronc':
          _addElement(element, 1, 'cm', 'Souplesse');
          break;
        case 'Saut sans élan':
          _addElement(element, 1, 'm', 'Explosivité');
          break;
        case 'Course navette':
        case 'Frappe des plaques':
          _addElement(element, 0, 's', 'Vitesse');
          break;
        case 'Équilibre flamingo':
          _addElement(element, 0, 'déséquilibre(s)', 'Équilibre');
          break;
      }
    });
    otherExercise.forEach((element) {
      _names.add(element);
      switch (element) {
        case 'Chaise':
        case 'Gainage':
          _addElement(element, 1, 's', 'Endurance');
          break;
        case 'Tractions':
        case 'Pompages' :
          _addElement(element, 1, 'Rep(s)', 'Force');
          break;
      }
    });
  }

  void _addElement(String name, int time, String unit, String type){
    _times.putIfAbsent(name, () => time);
    _units.putIfAbsent(name, () => unit);
    _types.putIfAbsent(name, () => type);
  }

  void testExercise(Exercise exercise){
    String temp = exercise.name;
    if(!_names.contains(temp)){
      _names.add(temp);
      _addElement(temp, exercise.time, exercise.unit, exercise.type);
    }
    if (!_graphList.contains(temp)) {
      _graphList.add(temp);
    }
  }

  String? searchType(String? name){
    return _types[name];
  }

  String? searchUnit(String? name){
    return _units[name];
  }

  List<String> getNames(){
    return _names.toList(growable: false);
  }

  List<String> getTypes(){
    return _types.values.toSet().toList(growable: false);
  }

  List<Exercise> basicList(){
    return _getList(basicExercise);
  }

  List<Exercise> fullList(){
    return _getList(_names.toList(growable: false));
  }

  List<Exercise> graphList() {
    return _getList(_graphList.toList(growable: false));
  }

  List<Exercise> _getList(List list){
    return List.generate(list.length, (index) =>
      Exercise(name: list.elementAt(index),
        type: _types[list.elementAt(index)]!,
        unit: _units[list.elementAt(index)]!,
        time: _times[list.elementAt(index)]!,
    ));
  }

  List<String> getNameSuggestions(String query) {
    return getSuggestions(query, _names.toList(growable: false));
  }

  List<String> getTypeSuggestions(String query) {
    return getSuggestions(query, getTypes());
  }

  List<String> getSuggestions(String query, List<String> list) {
    List<String> res = list.where((element) {
      return element.toLowerCase().contains(query.toLowerCase());
    }).toList();

    //if (res.length>3) return res.sublist(0, 3);
    return res;
  }
}