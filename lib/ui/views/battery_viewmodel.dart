import 'dart:async';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:battery/battery.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:stacked/stacked.dart';

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
    alarmController();
  }

  void deactivateAlarm() {
    toggleAlarm();
    this._activate = false;
    notifyListeners();
    alarmController();
  }

  toggleAlarm() {
    if (_playing) {
      FlutterRingtonePlayer.stop();
      this._playing = false;
    } else {
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

  alarmController() {
    Timer.periodic(Duration(seconds: 2), (timer) async {
      if (_activate &&
          _playing == false &&
          _batteryLevel == 100 &&
          (_batteryStatus == 'Charging' || _batteryStatus == 'Full')) {
        _scheduleAlarm(DateTime.now());
        toggleAlarm(); //play alarm
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
            const Duration(minutes: 1), 0, alarmController())
        : await AndroidAlarmManager.cancel(0);
  }

  void _scheduleAlarm(DateTime scheduledNotificationDateTime) async {
    // var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    //   'alarm_notif',
    //   'alarm_notif',
    //   'Channel for Alarm notification',
    //   icon: 'codex_logo',
    //   sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
    //   largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
    // );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    var platformChannelSpecifics = NotificationDetails();
    // platformChannelSpecifics.android = androidPlatformChannelSpecifics;
    // platfro
    await flutterLocalNotificationsPlugin.show(0, 'Office',
        'Good morning! Time for office.', platformChannelSpecifics);
  }
}
