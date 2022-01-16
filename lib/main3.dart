// import 'dart:isolate';
// import 'dart:ui';

// import 'package:analog_alarm/infrastructure/prefs.dart';
// import 'package:analog_alarm/utils.dart';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'app_widget.dart';
// import 'package:timezone/data/latest.dart' as tz;

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// final ReceivePort port = ReceivePort();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await GetStorage.init();
//   tz.initializeTimeZones();
//   await initializeNotification();
//   await initializeIsolate();
//   runApp(const MyApp());
// }

// Future<void> initializeIsolate() async {
//   var _box = GetStorage();
//   IsolateNameServer.registerPortWithName(
//     port.sendPort,
//     Utils.isolateName,
//   );
//   if (!_box.hasData(Utils.countKey)) {
//     await _box.write(Utils.countKey, 1);
//   }
// }

// void printHello() {
//   final DateTime now = DateTime.now();
//   final int isolateId = Isolate.current.hashCode;
//   print("[$now] Hello, world! isolate=${isolateId} function='$printHello'");
// }

// Future<void> initializeNotification() async {
//   var initializationSettingsAndroid = AndroidInitializationSettings('logo');
//   var initializationSettingsIOS = IOSInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//       onDidReceiveLocalNotification:
//           (int id, String? title, String? body, String? payload) async {});
//   var initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//     iOS: initializationSettingsIOS,
//   );
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onSelectNotification: (String? payload) async {
//     if (payload != null) {
//       debugPrint('notification payload: ' + payload);
//     }
//   });
// }

// Future<void> initializeAlarm() async {
//   await AndroidAlarmManager.initialize();
//   final int helloAlarmID = 0;
//   await AndroidAlarmManager.periodic(
//       const Duration(seconds: 2), helloAlarmID, printHello);
// }
