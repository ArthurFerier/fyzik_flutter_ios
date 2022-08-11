import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stimulusep/assets/colors.dart';
import 'package:stimulusep/assets/strings.dart';
import 'package:stimulusep/model/exercise.dart';
import 'package:stimulusep/model/exercise_enum.dart';
import 'package:stimulusep/model/report_generation.dart';
import 'package:stimulusep/model/screen_size.dart';
import 'package:stimulusep/model/user.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../exercise_info.dart';

class ExerciseCard extends StatefulWidget{
  final Exercise _exercise;
  final int _index;
  const ExerciseCard(this._exercise, this._index);

  @override
  State<StatefulWidget> createState() {
    return new _ExerciseCardState();
  }


}

class _ExerciseCardState extends State<ExerciseCard>{
  double diff = 0;
  bool showDiff = true;
  bool data = false;
  List<List<XYData>> _chartData = getChartDatas();
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState(){
    _tooltipBehavior =  TooltipBehavior(
      enable: true,
      format: 'point.x \nrésultat : point.y',
      header: ""
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(widget._index>=0) {
      data = true;
      try{
        diff = difference();
      }catch(e){
        showDiff = false;
      }
    }
    return Card(
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
      child: Container(
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: screenWidth(context, reducedBy: 225),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.all(5),
                                child: Text(
                                  widget._exercise.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.5),
                              )),
                              Container(height: 30, child:ChoiceChip(
                                label: Text(widget._exercise.type),
                                selected: false,
                              )),
                            ]
                          )
                        ),
                        Spacer(),
                        if(widget._exercise.hasQuantile() && data)
                          IconButton(
                            padding: EdgeInsets.all(5),
                            constraints: BoxConstraints(),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ExerciseInfoPage(widget._exercise.name, Exercise.exImage(widget._exercise.name))
                                ),
                              );
                            },
                            icon: Icon(Icons.info),
                            color: colorPrimary,
                          ),
                      ],
                    ),
                    (data)? result():graph(widget._exercise.name, widget._exercise.unit),
                    if(data && basicExercise.contains(widget._exercise.name)
                        && widget._exercise.name.compareTo('Tour de taille')!=0) progressBar(),
                    ],
                )
              )
            ),
            SizedBox(
                width: 150,
                child: Image(image: Exercise.exImage(widget._exercise.name))
            )
          ],
        )
      )
    );
  }

  Widget graph(String exerciseName, String unit){
    return Expanded(
      child: getIndex2(exerciseName) == -1 ?
      Center(child: Text(Strings.notEnoughData)) :
      SfCartesianChart(
        primaryYAxis: NumericAxis(
          isVisible: true,
          labelFormat: "{value} " + unit,
          labelStyle: const TextStyle(fontSize: 0)
        ),
        plotAreaBorderColor: Colors.white,
        tooltipBehavior: _tooltipBehavior,
        series: <ChartSeries>[
          FastLineSeries<XYData, DateTime>(
            enableTooltip: true,
              dataSource: _chartData[getIndex2(exerciseName)],
              xValueMapper: (XYData data, _) => data.rapportDate,
              yValueMapper: (XYData data,  _) => data.score,
              //dataLabelSettings: DataLabelSettings(isVisible: true),
            markerSettings: MarkerSettings(isVisible: true)
          )
        ],
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat('dd MMM yyyy'),
          isVisible: true,
          labelStyle: const TextStyle(fontSize: 0)
        )
      )
    );
  }

  Widget result(){
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              text: Strings.resultsWithTwoDots+removeZero(widget._exercise.score) + ' ',
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                if(showDiff) textColor(),
                TextSpan(text: ' ' + widget._exercise.unit),
              ],
            )
          )
        ],
      )
    );
  }

  Widget progressBar(){
    return SizedBox(
      height: 40,
      width: 250,
      child: Column(
        children: [
          Stack(
            children: [
              LinearProgressIndicator(
                  value: (widget._exercise.percentile/100).toDouble()
              ),
              Center(child: Container(
                width: 0,
                height: 4,
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(width: 2, color: Colors.red)),
                ),
              ))
            ],
          ),
          Row(
            children: [
              Text('0'),
              Expanded(child: Center(child: Text(Strings.median))),
              Text('100'),
            ],
          )
        ],
      )
    );
  }

  double difference(){
    int index = UserC().reports.sublist(0, widget._index).lastIndexWhere(
            (element) => element.getExercise(widget._exercise.name)!=null
    );
    if(index!=-1) {
      return widget._exercise.score - UserC().reports[index].getExercise(widget._exercise.name)!.score;
    }
    throw Exception("No match found");
  }

  TextSpan textColor(){
    /*
    int time = widget._exercise.time;
    late Color color;
    if(diff==0) color = Colors.blueGrey;
    else color = ((time==0 && diff<0) || (time==1 && diff>0))
        ?Colors.green:Colors.red;
     */
    return TextSpan(
        text: '(' + ((diff>=0)?'+':'') + removeZero(diff) + ')',
        //style: TextStyle(color: color)
    );
  }

  String removeZero(double n) {
    String string = n.toString();
    if(string.indexOf(".")>0) {
      string = double.parse(string).toStringAsFixed(2);
      while (string.substring(string.length-1).compareTo("0")==0)
        string = string.substring(0, string.length-1);
      if (string.substring(string.length-1).compareTo(".")==0)
        string = string.substring(0, string.length-1);
    }
    return string;
  }
}