import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:stimulusep/assets/colors.dart';
import 'package:stimulusep/assets/strings.dart';
import 'package:stimulusep/model/screen_size.dart';

double value = 0;

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Container(
      color: colorPrimaryDark,
      child: Center(
        child: SpinKitWave(
          color: Colors.white,
          size: 50.0,
        ),
      ),
    );
  }
}

class LoadingWithIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: colorPrimaryDark,
        child: Center(
            child: Column(
              children: [
                Spacer(),
                SpinKitWave(
                  color: Colors.white,
                  size: 50.0,
                ),
                SizedBox(height: 25,),
                SizedBox(
                    height: 40,
                    width: screenWidth(context),
                    child: Center(
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                Strings.wait1,
                                style: new TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                Strings.wait2,
                                style: new TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        )
                    )
                ),
                SizedBox(height: 20,),
                SizedBox(
                  width: screenWidth(context, dividedBy: 1.7),
                  child: LinearProgressIndicator(
                    color: Colors.white,
                    value: value,
                  ),
                ),
                Spacer(),
              ],
            )
        ),
      ),
    );
  }
}