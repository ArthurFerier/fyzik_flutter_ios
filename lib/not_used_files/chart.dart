/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stimulusep/assets/colors.dart';
import 'package:stimulusep/assets/strings.dart';
import 'package:stimulusep/model/report_generation.dart';
import 'package:stimulusep/model/user.dart';
import 'package:stimulusep/views/generic_widgets/loading_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui' as dart_ui;
import 'dart:typed_data';


class ChartPage extends StatefulWidget {
  final String exerciseName;
  static UserC user = UserC();


  ChartPage(this.exerciseName);

  @override
  State<StatefulWidget> createState() {
    final List<List<XYData>> _chartData = getChartDatas();
    return new ChartPageState(exerciseName, _chartData);
  }
}

class ChartPageState extends State<ChartPage> {

  final GlobalKey<SfCartesianChartState> _chartKey = GlobalKey();
  bool loading = false;
  final List<String> listOfNames = [
    Strings.height,
    Strings.waist,
    Strings.weight,
    Strings.lucLeger,
    Strings.handGrip,
    Strings.suspension,
    Strings.sitUp,
    Strings.trunkFlexion,
    Strings.hittingPlates,
    Strings.shuttleRace,
    Strings.flamingoBalance,
    Strings.jumpWOMom
  ];

  Future<List<Uint8List>> getChartImages({int? index}) async {
    List<Uint8List> images = [];
    bool saveValue = value;
    String saveMode = mode;
    setState(() {
      value = true;
      mode = Strings.score;
    });

    if (index == null){
      // get all images
      String saveExerciseName = exerciseName;
      for (int i = 0; i < 12; i++){
        setState(() {
          exerciseName = listOfNames[i];
          value = true;
          mode = Strings.score;
        });
        await Future.delayed(Duration(milliseconds: 1000));
        final dart_ui.Image data = await _chartKey.currentState!.toImage(pixelRatio: 3.0);
        final ByteData? bytes = await data.toByteData(format: dart_ui.ImageByteFormat.png);
        images.add(bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
      }
      setState(() {
        exerciseName = saveExerciseName;
        value = saveValue;
        mode = saveMode;
      });
      return images;
    }

    else {
      // get only the visible image
      exerciseName = listOfNames[index];
      setState(() {
        value = true;
        mode = Strings.score;
      });
      await Future.delayed(Duration(milliseconds: 400));
      final dart_ui.Image data = await _chartKey.currentState!.toImage(pixelRatio: 3.0);
      final ByteData? bytes = await data.toByteData(format: dart_ui.ImageByteFormat.png);
      images.add(bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
      setState(() {
        value = saveValue;
        mode = saveMode;
      });
      return images;
    }
  }

  bool checkPassedString(String nameExercise){
    return nameExercise == exerciseName;
  }

  bool value = true;

  String mode = Strings.score;
  changeMode() {
    if (mode == Strings.score){
      mode = Strings.quantiles;
    } else {
      mode = Strings.score;
    }
  }

  Widget buildSwitch() => Transform.scale(
    scale: 1.5,
    child: Switch.adaptive(
      activeColor: colorPrimaryDark,
      value: value,
      onChanged: (value) => setState(() => {changeMode(), this.value = value}),
    ),
  );

  ChoiceChip buildChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: checkPassedString(label),
      onSelected: (bool selected) {
        setState(() {
          selected = !selected;
          exerciseName = label;
        });
      },
    );
  }

  List<ChoiceChip> getChoiceChips(List<String> exerciseNames){
    List<ChoiceChip> choiceChips = [];
    for (String label in exerciseNames){
      choiceChips.add(buildChip(label));
    }
    return choiceChips;
  }

  String exerciseName;
  List<List<XYData>> _chartData;
  ChartPageState(this.exerciseName, this._chartData);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
    ]);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              Strings.titleChart + exerciseName,
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: colorPrimary,
            actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == Strings.shareResults){
                  // share all graphs
                  setState(() {loading = true;});
                  List<Uint8List> images = await getChartImages();
                  createCompletePDF(images, listOfNames);
                  setState(() {loading = false;});
                } else {
                  // share only this result
                  setState(() {loading = true;});
                  List<Uint8List> images = await getChartImages(index: getIndex(exerciseName));
                  createCompletePDF(images, [exerciseName]);
                  setState(() {loading = false;});
                }
              },
              itemBuilder: (BuildContext context) {
                return {Strings.shareGraph, Strings.shareResults}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                        width: 65,
                        child: Center(
                          child: Text(
                              mode
                          ),
                        )
                    ),
                    buildSwitch(),
                    SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width - 140,
                        child: Scrollbar(
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: getChoiceChips(listOfNames),
                          ),
                        )
                    )
                  ],
                ),

                Expanded(
                  child: SfCartesianChart(
                    key: _chartKey,
                    series: <ChartSeries>[
                      LineSeries<XYData, DateTime>(
                          dataSource: getIndex2(exerciseName) == -1 ? [XYData(null, null, null, null)] : _chartData[getIndex2(exerciseName)],
                          xValueMapper: (XYData data, _) => data.rapportDate,
                          yValueMapper: (XYData data,  _) {
                            if (value) {
                              return data.score;
                            } else {
                              return data.quantile;
                            }
                          }
                          )
                    ],
                    primaryXAxis: DateTimeAxis(),
                  ),
                ),
              ],
            ),
          ),
        ),

        Visibility(
          visible: loading,
          child: Loading(),
        )

      ],
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
*/