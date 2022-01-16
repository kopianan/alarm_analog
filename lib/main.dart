// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:developer' as developer;
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:analog_clock/analog_clock.dart';

import 'package:analog_clock/analog_clock_painter.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'domain/am_pm_model.dart';

/// The [SharedPreferences] key to access the alarm fire count.
const String countKey = 'count';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

/// Global [SharedPreferences] object.
late SharedPreferences prefs;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotification() async {
  var initializationSettingsAndroid = AndroidInitializationSettings('logo');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {});
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register the UI isolate's SendPort to allow for communication from the
  // background isolate.
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );
  prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(countKey)) {
    await prefs.setInt(countKey, 0);
  }
  runApp(AlarmManagerExampleApp());
}

/// Example app for Espresso plugin.
class AlarmManagerExampleApp extends StatelessWidget {
  const AlarmManagerExampleApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: _AlarmHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class _AlarmHomePage extends StatefulWidget {
  const _AlarmHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _AlarmHomePageState createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<_AlarmHomePage> {
  int _counter = 0;
  int min = 0;
  int hours = 0;

  int selectedHour = 0;

  List<AmPmModel> _amPm = [
    AmPmModel(label: "PM", isActive: true),
    AmPmModel(label: "AM", isActive: false),
  ];
  DateTime currDate = DateTime.now();

  // The background
  static SendPort? uiSendPort;
  @override
  void initState() {
    super.initState();
    AndroidAlarmManager.initialize();

    // Register for events from the background isolate. These messages will
    // always coincide with an alarm firing.
    port.listen((_) async => await _incrementCounter());
  }

  Future<void> _incrementCounter() async {
    developer.log('Increment counter!');
    // Ensure we've loaded the updated count from the background isolate.
    await prefs.reload();

    setState(() {
      _counter++;
    });
  }

  // The callback for our alarm
  static Future<void> callback() async {
    developer.log('Alarm fired!');
    // Get the previous cached count and increment it.
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(countKey);
    await prefs.setInt(countKey, currentCount! + 1);

    // This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);

    scheduleAlarm(DateTime.now()); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onPressed: () async {
          int hourInt;

          if (currDate.hour > 12) {
            hourInt = currDate.hour - 12;
          } else {
            hourInt = currDate.hour;
          }

          // convert to date
          final f = new DateFormat('yyyy HH:mm a');

          var _newDateTime = f.parse(
              "${currDate.year} ${hourInt}:${currDate.minute} ${_amPm.firstWhere((element) => element.isActive == true).label}");

          // Prefs().saveCurrentTime(_newDateTime);

          await AndroidAlarmManager.periodic(
            const Duration(seconds: 5),
            // _newDateTime,
            // Ensure we have a unique alarm ID.
            Random().nextInt(30),
            callback,
            // startAt: _newDateTime,
            exact: true,
            wakeup: true,
          );
        },
        child: Icon(Icons.alarm),
      ),
      body: Container(
          alignment: Alignment.center,
          color: Color(0xFFB081D6),
          // child: AnalogClock(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "  ${(currDate.hour > 12) ? (currDate.hour - 12).toString().padLeft(2, '0') : currDate.hour.toString().padLeft(2, '0')} : ${currDate.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: _amPm
                        .map((e) => InkWell(
                              onTap: () {
                                _amPm.forEach((element) {
                                  element.isActive = false;
                                });
                                _amPm.forEach((element) {
                                  if (element.label == e.label) {
                                    element.isActive = true;
                                  }
                                });
                                setState(() {});
                              },
                              child: pmAmWidget(
                                amPmModel: e,
                              ),
                            ))
                        .toList(),
                  )
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                width: 300,
                height: 300,
                child: GestureDetector(
                  onHorizontalDragEnd: (e) {},
                  onVerticalDragEnd: (e) {},
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0) {
                      // swiping in right direction
                      if (hours++ == 5) {
                        hours = 0;
                        setState(() {
                          currDate = currDate.add(Duration(hours: 1));
                        });
                      }
                    } else {
                      if (hours++ == 5) {
                        hours = 0;
                        setState(() {
                          currDate = currDate.add(Duration(hours: -1));
                        });
                      }
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 0) {
                      // swiping in right direction
                      if (min++ == 5) {
                        min = 0;
                        setState(() {
                          currDate = currDate.add(Duration(minutes: 1));
                        });
                      }
                    } else {
                      if (min++ == 5) {
                        min = 0;
                        setState(() {
                          currDate = currDate.add(Duration(minutes: -1));
                        });
                      }
                    }
                  },
                  child: CustomPaint(
                    painter: AnalogClockPainter(
                      useMilitaryTime: false,
                      datetime: currDate,
                      numberColor: Colors.white,
                      textScaleFactor: 1.4,
                      tickColor: Colors.black,
                      showNumbers: true,
                      hourHandColor: Colors.white,
                      showSecondHand: false,
                      showDigitalClock: false,
                    ),
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.all(20),
                elevation: 7,
                color: Colors.deepPurple,
                child: Container(
                  height: 80,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(),
                  child: Row(
                    children: [
                      Text(
                        "12:20",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Spacer(),
                      Text(
                        "Active",
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }

  static void scheduleAlarm(DateTime date) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      channelDescription: 'Channel for Alarm notification',
      icon: 'logo',
      sound: RawResourceAndroidNotificationSound('alarm'),
      largeIcon: DrawableResourceAndroidBitmap('logo'),
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        sound: 'alarm.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Office',
      "Title",
      platformChannelSpecifics,
      // RepeatInterval.daily,
      // platformChannelSpecifics,
      // androidAllowWhileIdle: true,
    );
  }
}

class pmAmWidget extends StatelessWidget {
  const pmAmWidget({Key? key, required this.amPmModel}) : super(key: key);
  final AmPmModel amPmModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),
      decoration: amPmModel.isActive
          ? BoxDecoration(
              color: Colors.white.withAlpha(180),
              borderRadius: BorderRadius.circular(6))
          : null,
      child: Text(
        amPmModel.label,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
