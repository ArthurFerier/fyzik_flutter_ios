import 'dart:collection';
import 'package:contextualactionbar/actions/action_mode.dart';
import 'package:contextualactionbar/widgets/contextual_action_widget.dart';
import 'package:flutter/material.dart';
import 'package:stimulusep/model/exercise_enum.dart';
import 'package:stimulusep/assets/strings.dart';
import 'package:stimulusep/model/image.dart';
import 'package:stimulusep/model/report.dart';
import 'package:stimulusep/model/user.dart';
import 'package:stimulusep/views/report_fragment.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'exercise_list.dart';
import 'dart:io';

class ReportCard extends StatefulWidget{
  final ValueChanged<int> parentAction;
  final dynamic change;
  final ValueChanged<BuildContext> parentContext;
  const ReportCard(this.parentAction, this.change, this.parentContext);

  @override
  State<StatefulWidget> createState() {
    return new _ReportCardState();
  }
}

class _ReportCardState extends State<ReportCard>{
  HashMap<int, Future<XFile?>?> imageFiles = HashMap();
  bool modify = false;

  @override
  void initState() {
    super.initState();
    UserC().reports.sort();
    widget.parentContext(context);
  }

  @override
  Widget build(BuildContext context) {
    ActionMode.enabledStream<Report>(context).listen((event) {
      widget.parentAction((event)?2:3);
    });
    imageFiles.removeWhere((key, value) => UserC().reportIndex(key)==-1);
    UserC().reports.forEach((element) {imageFiles.putIfAbsent(element.id, () => null);});
    return Center(
      child: (UserC().reports.isEmpty)?Text(Strings.firstReport):_listView()
    );
  }

  Widget _listView(){
    return ListView(
      children: <Widget>[
        ...UserC().reports.map((report) =>
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ContextualActionWidget(
                  selectedWidget: _checkIcon(true),
                  unselectedWidget: _checkIcon(false),
                  selectedColor: Colors.lightBlue,
                  data: report,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ExerciseListPage(UserC().reportIndex(report.id))),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      clipBehavior: Clip.antiAlias,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                          height: report.isExpanded?400:110,
                          color: Colors.white,
                          child: Column(
                            children: [
                              Container(height:110,child:Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  prePhoto(report),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: Text(Strings.year_exList + report.year.toString()),
                                          subtitle: Text(Strings.date_exList + DateFormat('dd/MM/yyyy').format(report.date)),
                                        ),
                                        (!report.isExpanded)?_medal(report):SizedBox(height: 29),
                                      ],
                                    ),
                                    flex: 4,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      alignment: Alignment.bottomRight,
                                      child: TextButton(
                                        child: report.isExpanded?Icon(Icons.expand_less):Icon(Icons.expand_more),
                                        onPressed: (){
                                          setState(() {
                                            report.isExpanded = !report.isExpanded;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                              if(report.isExpanded) Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: _medal(report)
                              )
                            ],
                          )
                      ),
                    ),
                  ),
                ),
              ],
            )
        )
      ],
    );
  }

  Widget prePhoto(Report report){
    if(report.image != null && !modify) return _image(report.image!, report.id);
    return photo(report);
  }

  Widget photo(Report report){
    return FutureBuilder<XFile?>(
      future: imageFiles[report.id],
      builder: (BuildContext context, AsyncSnapshot<XFile?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          modify = false;
          if(snapshot.data != null){
            String _temp = Utility.base64String((File(snapshot.data!.path).readAsBytesSync()));
            report.addImage(_temp);
            //report.image = Utility.imageFromBase64String(_temp);
            return _image(Image.file(File(snapshot.data!.path)), report.id);
          }else{
            //BACK
            if(report.image != null) return _image(report.image!, report.id);
            return _photoIcon(report.id);
          }
        } else if (snapshot.hasError) {
          //print('Error Picking Image');
          return _photoIcon(report.id);
        }
        //print('No Image Selected');
        return _photoIcon(report.id);
      },
    );
  }

  Widget _image(Widget widget, int id){
    return GestureDetector(
      onTap: ((){
        setState(() {
          modify = true;
          imageFiles[id] = takePhoto();
        });
      }),
      child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LimitedBox(
              maxWidth: 90,
              child: Container(
                child: widget,
                height: 110,
                alignment: Alignment.centerLeft
              )
            ),
          )
      ),
    );
  }

  Widget _photoIcon(int id){
    return Expanded(
      flex: 2,
      child: Center(
        child: IconButton(
          icon: Icon(Icons.add_a_photo),
          onPressed: ((){
            setState(() {
              imageFiles[id] = takePhoto();
            });
          }),
        ),
      )
    );
  }

  Future<XFile?>? takePhoto(){
    return ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: 200
    );
  }

  Widget _checkIcon(bool isChecked){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20),
          child: (isChecked)?Icon(Icons.check_circle, color: Colors.lightBlue):
          Icon(Icons.radio_button_unchecked, color: Colors.lightBlue),//check_circle_outlined
        ),
      ],
    );
  }

  Widget _medal(Report report) {
    List<Widget> _list = List.empty(growable: true);

    Icon _icon = Icon(Icons.block);
    AssetImage? _assetImage;
    Widget? _value;

    for (var i = -1; i < exerciseType.length; i++) {
      late String _text;
      late double _temp;
      _value = null;
      _assetImage = null;
      if(i==-1){
        _temp = report.getBMI();
        _text = Strings.imc;
        _value = getData(report, i, _temp);
      } else if(i==0){
        _temp = report.getHeightWaistRatio();
        _text = Strings.bodyRatio;
        _assetImage = getData(report, i, _temp);
      } else{
        _text = exerciseType[i];
        _temp = report.averages.putIfAbsent(exerciseType[i], () => 0);
        _assetImage = getData(report, i, _temp);
      }

      Widget? x = sendData(report, _text, _assetImage, _icon, _value);
      if(x!=null) _list.add(Padding(
          padding: EdgeInsets.only(right: 5),
          child:x)
      );
    }
    return report.isExpanded
        ? Column(children: _list)
        : Padding(
          padding: EdgeInsets.only(bottom: 5),
          child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: _list)
          )
    );
  }

  getData(Report report, int index, double temp){
    if(index==-1) {
      return FutureBuilder(
          future: getBmiText(report, temp),
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            if(snapshot.hasData && snapshot.data!.isNotEmpty) {
              return RichText(
                  text: TextSpan(
                      text: snapshot.data,
                      style: TextStyle(color: getColor(snapshot.data!))
                  )
              );
            } else if (snapshot.hasError) {
              return Text('Error');
            } else return Text('-');
          }
      );
    } else if(index==0){
      if(temp>0.5){
        return AssetImage('lib/assets/images/gros.png');
      }else if(temp>0){
        return AssetImage('lib/assets/images/fin.png');
      }
    }else if(temp>=90){
      return AssetImage('lib/assets/images/medaille_or.png');
    }else if(temp>=75){
      return AssetImage('lib/assets/images/medaille_argent.png');
    }else if(temp>=60){
      return AssetImage('lib/assets/images/medaille_bronze.png');
    }else {
      return null;
    }
  }

  Widget? sendData(Report report, String string, AssetImage? image, Icon icon, Widget? value){
    if(report.isExpanded){
      if(value!=null) return myRow(string, value);
      else if(image!=null) return myRow(string, Image(image: image, height: 25));
      else return myRow(string, icon);
    }else if(value!=null) {
      return null;
    }else if(image!=null) {
      return Image(image: image, height: 25);
    }
    return null;
  }

  Future<String> getBmiText(Report report, double temp) async {
    if(temp==0) return "-";

    int q = await report.findPercentile('BMI', temp);
    switch(q){
      case 50:
        return Strings.UnderWeight;
      case 60:
        return Strings.NormalWeight;
      case 75:
        return Strings.OverWeight;
      case 90:
        return Strings.Obesity;
      default:
        return "-";
    }
  }

  Color getColor(String string){
    switch(string){
      case Strings.UnderWeight:
        return Colors.lightBlueAccent;
      case Strings.NormalWeight:
        return Colors.green;
      case Strings.OverWeight:
        return Colors.orange;
      case Strings.Obesity:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Widget myRow(String text, Widget widget){
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Padding(padding: EdgeInsets.only(left: 10), child: Text(text)),
            Spacer(),
            widget
          ],
        )
    );
  }
}

class MyStack2 extends StatefulWidget{
  final ValueChanged<int> parentWillPop;
  final ValueChanged<BuildContext> parentContext;
  final dynamic parentSetState;
  MyStack2(this.parentWillPop, this.parentContext, this.parentSetState);

  @override
  State<StatefulWidget> createState() => new MyStackState2();
}

class MyStackState2 extends State<MyStack2>{
  bool _forceStack = false;
  bool _visible = false;
  Report _report = Report(date: DateTime.now(), exercises: [], year: 0, mail: '');

  @override
  Widget build(BuildContext context) {
    return Stack(children: myList());
  }

  List<Widget> myList(){
    List<Widget> _temp = List.empty(growable: true);
    _temp.add(ReportCard(widget.parentWillPop, _change, widget.parentContext));
    if(_forceStack){
      widget.parentWillPop(1);
      _temp.add(_modal());
      _temp.add(Center(child: ReportFragment(_report, _change)));
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
            backgroundColor: Color(0xFF2596be),
            onPressed: _change
        )
    );
  }

  _change([bool force = true]){
    _forceStack = force;
    if(_visible) _report = Report(date: DateTime.now(), exercises: [], year: 0, mail: '');
    _visible = !_visible;
    if(force==false) {
      widget.parentSetState();
    } else setState(() {});
  }
}