import 'package:flutter/material.dart';

class ChoiceToSelectTitleWidget extends StatelessWidget {

  final ChoiceToSelect school;
  final bool isSelected;
  final ValueChanged<ChoiceToSelect> onSelectedSchool;

  const ChoiceToSelectTitleWidget({
    required this.school,
    required this.isSelected,
    required this.onSelectedSchool,
  });


  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).primaryColor;

    return ListTile(
      onTap: () => onSelectedSchool(school),
      title: Text(
        school.name
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: selectedColor, size: 26,)
          : null,
    );
  }
}

class ChoiceToSelect {
  final String name;
  ChoiceToSelect({
    required this.name
  });
}
