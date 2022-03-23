import 'package:flutter/material.dart';
import 'package:binod/size_config.dart';
import 'package:binod/ui/views/battery_viewmodel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stacked/stacked.dart';

class BatteryView extends StatelessWidget {
  BatteryView(this.batteryViewModel);
  final BatteryViewModel batteryViewModel;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ViewModelBuilder<BatteryViewModel>.reactive(
      builder: (context, model, child) => Stack(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Positioned(
            bottom: 0.0,
            child: Container(
              color: Colors.lightBlue[200],
              width: SizeConfig.screenWidth,
              height: model.batteryLevel == null
                  ? 0.0
                  : SizeConfig.screenHeight *
                      model.batteryLevel.toDouble() *
                      0.01,
            ),
          ),
          Positioned(
              bottom: 0.0,
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    model.batteryLevel.toString() + "%",
                    style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal * 20.0,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 1.0,
                  ),
                  Text(
                    model.batteryStatus,
                    style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal * 6.0,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 6.0,
                  ),
                  FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    color: Colors.black54,
                    textColor: Colors.white,
                    onPressed: () {
                      model.activate
                          ? model.deactivateAlarm()
                          : model.activateAlarm();
                    },
                    child: model.activate
                        ? Text("Deactivate Alarm")
                        : Text("Activate Alarm"),
                  ),
                ],
              )),
          // FlatButton(
          //       onPressed: () {
          //         model.activate
          //             ? model.deactivateAlarm()
          //             : model.activateAlarm();
          //         // model.activateAlarm();
          //       },
          //       child: model.activate
          //           ? Text("Deactivate Alarm")
          //           : Text("Activate Alarm"),
          //     ),

          // Center(
          //   child: SleekCircularSlider(
          //       initialValue: model.batteryLevel == null
          //           ? 0.0
          //           : model.batteryLevel.toDouble(),
          //       appearance: CircularSliderAppearance(
          //           startAngle: 170,
          //           angleRange: 200,
          //           infoProperties: InfoProperties(
          //             mainLabelStyle: TextStyle(
          //               color: Colors.red[50],
          //               fontSize: 48,
          //               fontWeight: FontWeight.w300,
          //             ),
          //           ),
          //           customWidths:
          //               CustomSliderWidths(shadowWidth: 50, trackWidth: 1),
          //           size: 220,
          //           customColors: CustomSliderColors(
          //               shadowMaxOpacity: 0.1,
          //               shadowStep: 10,
          //               shadowColor: Colors.white54,
          //               trackColor: Colors.white54,
          //               progressBarColors: [
          //                 Colors.white,
          //                 Colors.orange[100],
          //                 Colors.red[100].withOpacity(0.5)
          //               ])),
          //       onChange: (double value) {
          //         // print(value);
          //       }),
          // ),
          // Center(
          //   child: Text(
          //     model.batteryStatus.toString(),
          //     style: TextStyle(
          //       color: Colors.red[50],
          //       fontSize: 24,
          //       // fontWeight: FontWeight.w300,
          //     ),
          //   ),
          // ),
        ],
      ),
      viewModelBuilder: () => batteryViewModel,
      onModelReady: (model) {
        model.broadcastBatteryLevel();
        model.updateBatteryStatus();
        model.runInBackgroung();
      },
    );
  }
}
