import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stimulusep/assets/colors.dart';

import 'loading_widget.dart';

class FormWidget extends StatefulWidget {
  final Widget? topButton;
  final bool loading;
  final GlobalKey formKey;
  final List<Widget> children;

  FormWidget({
    Key? key,
    this.topButton,
    required this.loading,
    required this.formKey,
    required this.children
  }) : super(key: key);

  @override
  _FormWidgetState createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Stack(
      children: [
        buildScaffold(),
        Visibility(
          visible: widget.loading,
          child: Loading(),
        )
      ],
    );
  }

  Widget buildScaffold() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            topScreen(),
            buildInteractions()
          ],
        ),
      ),
    );
  }

  Widget topScreen() {
    return Stack(
      children: [
        Align(
          child: Text(
            "FYZIK",
            style: TextStyle(
                color: colorPrimary, fontSize: 50
            ),
          ),
        ),
        widget.topButton ?? SizedBox()
      ],
    );
  }

  Widget buildInteractions() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
      child: Container(
        height: MediaQuery.of(context).size.height - 105,
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: new ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.dstATop),
            image: AssetImage(
              'lib/assets/images/background.png',
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: buildUserInputs()
      )
    );
  }

  Widget buildUserInputs() {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 10),
      child: Form(
        key: widget.formKey,
        child: Column(
            children: inputs()
        )
      )
    );
  }

  List<Widget> inputs(){
    final int length = widget.children.length;
    List<Widget> list = List.empty(growable: true);
    for(int i=0; i<length; i++){
      list.add(Spacer());
      list.add(widget.children[i]);
    }
    list.add(Spacer());
    return list;
  }
}