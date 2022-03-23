import 'dart:async';

import 'package:battery/battery.dart';
import 'package:binod/size_config.dart';
import 'package:flutter/material.dart';
// import 'package:binod/ui/views/home/home_view.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:stacked/stacked.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var initializationSettingAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings =
      InitializationSettings(android: initializationSettingAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  });
  await AndroidAlarmManager.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'B I N O D', home: HomeView());
  }
}

class HomeView extends StatelessWidget {
  final BatteryViewModel batteryViewModel = BatteryViewModel();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.maxFinite,
      height: double.maxFinite,
      decoration: BoxDecoration(color: Colors.white),
      child: BatteryView(
        batteryViewModel,
      ),
    ));
  }
}

class BatteryViewModel extends BaseViewModel {
  Battery battery = new Battery();

  int _batteryLevel;
  int get batteryLevel => _batteryLevel;
  bool _broadcastBattery = false;

  int _batteryStatusIndex;
  String _batteryStatus = 'Loading';
  String get batteryStatus => _batteryStatus;

  bool _activate = false;
  bool _playing = false;
  bool get activate => _activate;

  Future broadcastBatteryLevel() async {
    _broadcastBattery = true;
    while (_broadcastBattery) {
      this._batteryLevel = await battery.batteryLevel;
      await Future.delayed(Duration(seconds: 2));
      notifyListeners();
    }
  }

  void stopBroadcastBatteryLevel() {
    _broadcastBattery = false;
  }

  void updateBatteryStatus() {
    battery.onBatteryStateChanged.listen((BatteryState state) {
      this._batteryStatusIndex = state.index;
      switch (_batteryStatusIndex) {
        case 0:
          this._batteryStatus = 'Full';
          break;
        case 1:
          this._batteryStatus = 'Charging';
          break;
        case 2:
          this._batteryStatus = 'Discharging';
          break;
        default:
          this._batteryStatus = 'Loading';
          break;
      }
      if (_batteryStatusIndex.runtimeType != int)
        this._batteryStatus = 'Loading';
      notifyListeners();
    });
  }

  void activateAlarm() async {
    this._activate = true;
    notifyListeners();
    _alarmController();
  }

  void deactivateAlarm() {
    this._activate = false;
    notifyListeners();
    _toggleAlarm(); //stop alarm
  }

  _toggleAlarm() {
    if (_playing == true && _activate == false) {
      FlutterRingtonePlayer.stop();
      this._playing = false;
    } else if (_playing == false && _activate == true) {
      FlutterRingtonePlayer.play(
        android: AndroidSounds.alarm,
        ios: IosSounds.alarm,
        looping: false, // Android only - API >= 28
        volume: 1.0, // Android only - API >= 28
        asAlarm: true, // Android only - all APIs
      );
      this._playing = true;
    }
  }

  _alarmController() {
    Timer.periodic(Duration(seconds: 2), (timer) async {
      if (_activate &&
          _playing == false &&
          _batteryLevel == 100 &&
          (_batteryStatus == 'Charging' || _batteryStatus == 'Full')) {
        _notifyAlarm();
        _toggleAlarm(); //play alarm
      }
      if (_playing && (_batteryLevel < 100 || _batteryStatus != 'Charging')) {
        deactivateAlarm();
        timer.cancel();
      }
      if (_activate == false) {
        timer.cancel();
      }
    });
  }

  void runInBackgroung() async {
    _activate
        ? await AndroidAlarmManager.periodic(
            const Duration(minutes: 1), 0, _alarmController())
        : await AndroidAlarmManager.cancel(0);
  }

  void _notifyAlarm() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      'Channel for Alarm notification',
      priority: Priority.high,
      importance: Importance.max,
      playSound: false,
      styleInformation: DefaultStyleInformation(true, true),
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'Battery Fully Charged',
        'Turn off the power supply!!', platformChannelSpecifics);
  }
}

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
