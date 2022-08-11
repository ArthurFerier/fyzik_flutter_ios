import 'dart:typed_data';
import 'dart:ui';

import 'package:stimulusep/assets/strings.dart';
import 'package:stimulusep/model/exercise.dart';
import 'package:stimulusep/model/report.dart';
import 'package:stimulusep/model/user.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


class XYData {
  final String? exName;
  final DateTime? rapportDate;
  final double? score;
  final int? quantile;
  XYData(this.rapportDate, this.score, this.quantile, this.exName);
}
List<String> exerciseNames = [];

int getIndex(String exName){
  switch (exName) {
    case Strings.height: return 0;
    case Strings.waist: return 1;
    case Strings.weight: return 2;
    case Strings.lucLeger: return 3;
    case Strings.handGrip: return 4;
    case Strings.suspension: return 5;
    case Strings.sitUp: return 6;
    case Strings.trunkFlexion: return 7;
    case Strings.hittingPlates: return 8;
    case Strings.shuttleRace: return 9;
    case Strings.flamingoBalance: return 10;
    case Strings.jumpWOMom: return 11;
    default: {
      return -1;
    }
  }
}

int getIndex2(String exName){
  for (int i = 0; i < exerciseNames.length; i++){
    if (exerciseNames[i] == exName){
      return i;
    }
  }
  return -1;
}

List<List<XYData>> getChartDatas() {
  final List<List<XYData>> chartDataXY = [];
  // exercise -> list of results of reports -> list with date, score and quantile
  if (UserC().reports.isEmpty) {
    return chartDataXY;
  }
  exerciseNames = [];
  for (Report report in UserC().reports){
    if (report.exercises.isNotEmpty){
      for (Exercise exercise in report.exercises){
        if (getIndex2(exercise.name) == -1){ // rentre jamais ici alors qu'il faut
          chartDataXY.add([XYData(
              report.date,
              exercise.score,
              exercise.percentile,
              exercise.name
          )]);
          exerciseNames.add(exercise.name);
        } else {
          if (exercise.score >0){
            chartDataXY[getIndex2(exercise.name)].add(XYData( // vide
                report.date,
                exercise.score,
                exercise.percentile,
                exercise.name
            ));
          }
        }
      }
    }
  }
  return chartDataXY;
}

void createCompletePDF(List<Uint8List> images, List<String> exNames) async {
  PdfDocument document = PdfDocument();
  var page = document.pages.add();

  page.graphics.drawString("welcome", PdfStandardFont(PdfFontFamily.helvetica, 30));
  int cPerPage = 2;
  for (int i = 0; i < (images.length/cPerPage); i++){
    for (int j = 0; j < cPerPage; j++){
      if (i*cPerPage+j == images.length){
        break;
      }
      page.graphics.drawString(
          "Exercice : " + exNames[i*cPerPage+j],
          PdfStandardFont(PdfFontFamily.helvetica, 20),
          bounds: Rect.fromLTWH(30, 30 + j*320, 400, 30)
      );
      page.graphics.drawImage(PdfBitmap(images[i*cPerPage+j]), Rect.fromLTWH(30, 50 + j*330, 400, 300));
    }
    page = document.pages.add();
  }

  // transform the graphics to image
  //page.graphics.drawImage(PdfBitmap(await _readImageData("abdos.png")), Rect.fromLTWH(10, 20, 60, 70));

  List<int> bytes = await document.save();
  final String path = (await getExternalStorageDirectory())!.path;
  final String completePath = '$path/report.pdf';
  final file = File(completePath);
  await file.writeAsBytes(bytes, flush: true);
  //OpenFile.open(completePath);
  await Share.shareFiles([completePath]);
  document.dispose();
  //file.delete();
}