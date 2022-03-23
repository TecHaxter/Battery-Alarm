import 'package:binod/ui/views/battery_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:binod/ui/widgets/battery_view.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
