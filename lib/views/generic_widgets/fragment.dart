import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stimulusep/model/screen_size.dart';

class Fragment extends StatelessWidget{
  final List<Widget> children;

  Fragment({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxHeight: screenHeightExcludingToolbar(context, dividedBy: 1.2),
      child: Wrap(children:[ Center(
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: children,
          )
        )
      )])
    );
  }
}