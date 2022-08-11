import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stimulusep/assets/strings.dart';
import 'package:stimulusep/db/database.dart';
import 'package:stimulusep/model/exercise.dart';
import 'package:stimulusep/model/report.dart';
import 'package:stimulusep/model/user.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:stimulusep/model/statistic.dart';
import 'dart:io';

class XYData {
  final String? exName;
  final DateTime? rapportDate;
  final double? score;
  final double? middleQuantile;

  XYData(this.rapportDate, this.score, this.middleQuantile, this.exName);
}

List<String> exerciseNames = [];
List<String> exerciseNamesWithType = [];
List<List<XYData>> chartData = [];

int getIndex2(String exName) {
  for (int i = 0; i < exerciseNames.length; i++) {
    if (exerciseNames[i] == exName) {
      return i;
    }
  }
  return -1;
}

Future<double> getMiddleExercise(String exName, int sex, int age, int time) async {
  Statistic? stats = await FDatabase.instance.getQuantiles(age, exName, sex);
  if (stats == null) {
    return -1;
  } else {
    return stats.p50;
  }
}

Future<void> getChartDatas() async {
  // exercise -> list of results of reports -> list with date, score and quantile
  if (UserC().reports.isEmpty) {
    return;
  }
  exerciseNames = [];
  exerciseNamesWithType = [];
  chartData = [];
  for (Report report in UserC().reports) {
    int age = (UserC().birthDay!.difference(report.date).inDays/365).floor();
    if (age > 18) {
      age = 18;
    } else if (age < 12){
      age = 12;
    }
    if (report.exercises.isNotEmpty) {
      for (Exercise exercise in report.exercises) {
        double middle = await getMiddleExercise(exercise.name, UserC().sex!, age, exercise.time);
        if (getIndex2(exercise.name) == -1) {
          chartData.add([
            XYData(report.date, exercise.score, middle,
                exercise.name)
          ]);
          exerciseNames.add(exercise.name);
          exerciseNamesWithType.add(exercise.name + " [" + exercise.type + "]");
        } else {
          if (exercise.score > 0) {
            chartData[getIndex2(exercise.name)].add(XYData(
                report.date,
                exercise.score,
                middle,
                exercise.name));
          }
        }
      }
    }
  }
}

Widget getGraphWidget(List<XYData> data) {
  if (data[0].middleQuantile == -1) {
    return MaterialApp(
        home: SizedBox(
          width: 100,
          height: 150,
          child: SfCartesianChart(
            //plotAreaBackgroundImage: assetImage,
              primaryYAxis: NumericAxis(),
              series: <ChartSeries>[
                // score
                FastLineSeries<XYData, DateTime>(
                    dataSource: data,
                    xValueMapper: (XYData dataX, _) => dataX.rapportDate,
                    yValueMapper: (XYData dataY, _) => dataY.score,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                    markerSettings: MarkerSettings(isVisible: true)
                ),
              ],
              primaryXAxis: DateTimeAxis(
                isVisible: true,
              )),
        ));
  } else {
    return MaterialApp(
        home: SizedBox(
          width: 100,
          height: 150,
          child: SfCartesianChart(
            //plotAreaBackgroundImage: assetImage,
              primaryYAxis: NumericAxis(),
              series: <ChartSeries>[
                // score
                FastLineSeries<XYData, DateTime>(
                    dataSource: data,
                    xValueMapper: (XYData dataX, _) => dataX.rapportDate,
                    yValueMapper: (XYData dataY, _) => dataY.score,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                    markerSettings: MarkerSettings(isVisible: true)
                ),

                // quantile
                FastLineSeries<XYData, DateTime>(
                    dataSource: data,
                    dashArray: <double>[5, 5],
                    xValueMapper: (XYData dataX, _) => dataX.rapportDate,
                    yValueMapper: (XYData dataY, _) => dataY.middleQuantile,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                    markerSettings: MarkerSettings(isVisible: true)
                ),
              ],
              primaryXAxis: DateTimeAxis(
                isVisible: true,
              )),
        ));
  }
}

List<String> getExNamesWithType(){
  List<String> exNames = [];
  for (int i = 0; i < chartData.length; i++){

  }
  return exNames;
}

Future<List<Uint8List>> getChartImages(List<List<XYData>> data) async {
  List<Uint8List> images = [];
  for (int i = 0; i < data.length; i++) {
    Widget graph = getGraphWidget(data[i]);
    ScreenshotController screenCont = ScreenshotController();
    Uint8List image = await screenCont.captureFromWidget(graph);
    images.add(image);
  }
  return images;
}

Future<List<int>> readImageData() async {
  final ByteData data = await rootBundle.load('lib/assets/icons/logo.png');
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

Future<String> createCompletePDF([dynamic map]) async {
  List<String> exNamesWithType = map['exNames'];
  List<Uint8List> images = map['images'];
  final String firstName = map['firstName'];
  final String lastName = map['lastName'];
  final String path = map['externalStorage'];

  PdfDocument document = PdfDocument();
  var page = document.pages.add();
  page.graphics.drawString(
      Strings.report_name + firstName + " " + lastName,
      PdfStandardFont(PdfFontFamily.helvetica, 17, multiStyle: [PdfFontStyle.bold]),
      bounds: Rect.fromLTWH(50, 0, 400, 30)
  );

  int cPerPage = 4;
  for (int i = 0; i < (images.length / cPerPage); i++) {
    if (i != 0){
      page = document.pages.add();
    }
    for (int j = 0; j < cPerPage/2; j++) {
      if (i * cPerPage + j*2 == images.length) {
        break;
      }
      page.graphics.drawString(Strings.TestWithTwoDots + exNamesWithType[i * cPerPage + j*2],
          PdfStandardFont(PdfFontFamily.helvetica, 13,
              multiStyle: [PdfFontStyle.bold, PdfFontStyle.underline]),
          // left top width height
          bounds: Rect.fromLTWH(30, 65 + j * 330, 400, 30));
      page.graphics.drawImage(PdfBitmap(images[i * cPerPage + j*2]),
          Rect.fromLTWH(20, 85 + j * 330, 200, 280));

      // right
      if (i * cPerPage + j*2 + 1 == images.length) {
        break;
      }
      page.graphics.drawString(Strings.TestWithTwoDots + exNamesWithType[i * cPerPage + j*2 + 1],
          PdfStandardFont(PdfFontFamily.helvetica, 13,
              multiStyle: [PdfFontStyle.bold, PdfFontStyle.underline]),
          // left top width height
          bounds: Rect.fromLTWH(280, 65 + j * 330, 400, 30));
      page.graphics.drawImage(PdfBitmap(images[i * cPerPage + j*2 + 1]),
          Rect.fromLTWH(260, 85 + j * 330, 200, 280));

    }
    page.graphics.drawString(Strings.infoScore,
        PdfStandardFont(PdfFontFamily.helvetica, 8),
        bounds: Rect.fromLTWH(30, 725, 400, 30),
        //pen: PdfPen(PdfColor(0, 0, 0))
    );
    page.graphics.drawString(Strings.infoMediane1,
        PdfStandardFont(PdfFontFamily.helvetica, 8),
        bounds: Rect.fromLTWH(30, 740, 400, 30),
        //pen: PdfPen(PdfColor(0, 0, 0))
    );
    page.graphics.drawString(Strings.infoMediane2,
        PdfStandardFont(PdfFontFamily.helvetica, 8),
        bounds: Rect.fromLTWH(30, 750, 400, 30),
        //pen: PdfPen(PdfColor(0, 0, 0))
    );
  }

  List<int> bytes = await document.save();

  final String completePath = '$path/FYZIK:${Strings.report}\_$lastName\_$firstName.pdf';
  final file = File(completePath);
  await file.writeAsBytes(bytes, flush: true);
  //OpenFile.open(completePath);
  document.dispose();
  //file.delete();

  return completePath;
}

bool enoughData(List<List<XYData>> _chartData) {
  if (_chartData.length == 0) {
    return false;
  }
  if (_chartData[0].length < 1) {
    return false;
  }
  return true;
}