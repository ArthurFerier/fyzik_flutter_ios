import 'package:flutter/material.dart';

import 'SchoolTitleWidget.dart';
import 'generic_widgets/search_widget.dart';

class ChoiceToSelectPage extends StatefulWidget {
  final List<String> choiceToSelect;
  final String title;
  final String searchWords;
  const ChoiceToSelectPage(
    this.choiceToSelect,
    this.title,
    this.searchWords,
    {Key? key}
  ) : super(key: key);

  @override
  State<ChoiceToSelectPage> createState() => _ChoiceToSelectPageState();
}

class _ChoiceToSelectPageState extends State<ChoiceToSelectPage> {
  String text = '';

  bool containsSearchText(String firstLetters) {
    String textLower = text.toLowerCase();
    final schoolLower = firstLetters.toLowerCase();
    return schoolLower.contains(textLower);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> allPossibilities = widget.choiceToSelect;
    final List<String> remainingPoss = allPossibilities.where(containsSearchText).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: SearchWidget(
            text: text,
            hintText : widget.searchWords,
            onChanged: (text) => setState(() => this.text = text),
          ),
        ),
      ),
      body: ListView(
        children: remainingPoss.map((school) {
          return ChoiceToSelectTitleWidget(
            school: new ChoiceToSelect(name: school),
            isSelected: false,
            onSelectedSchool: selectThis,
          );
        }).toList(),
      ),
    );
  }

  void selectThis(ChoiceToSelect selected) {
    Navigator.pop(context, selected);
  }
}
