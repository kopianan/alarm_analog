import 'dart:isolate';

import 'dart:developer' as developer;

import 'dart:math';
import 'dart:ui';
import 'package:analog_alarm/domain/am_pm_model.dart';
import 'package:analog_clock/analog_clock_painter.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'widgets/pm_am_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  int _counter = 0;
  int min = 0;
  int hours = 0;

  int selectedHour = 0;

  List<AmPmModel> _amPm = [
    AmPmModel(label: "PM", isActive: true),
    AmPmModel(label: "AM", isActive: false),
  ];
  DateTime currDate = DateTime.now();
  DateTime? savedDate = DateTime.now();

  // The background
  static SendPort? uiSendPort;
  @override
  void initState() {
    checkSavedTime();
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

  void checkSavedTime() {
    try {
      var _time = prefs.getString(timeKey);
      savedDate = DateTime.parse(_time!);
    } catch (e) {
      savedDate = null;
    }
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

    scheduleAlarm();
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
          final f = new DateFormat('yyyy-dd-MM HH:mm a');
          var _newDateTime = f.parse(
              "${currDate.year}-${currDate.day}-${currDate.month} ${hourInt}:${currDate.minute} ${_amPm.firstWhere((element) => element.isActive == true).label}");

          // Prefs().saveCurrentTime(_newDateTime);
          await prefs.setString(timeKey, _newDateTime.toIso8601String());
          savedDate = _newDateTime;
          setState(() {});
          await AndroidAlarmManager.oneShotAt(
            _newDateTime,
            Random().nextInt(30),
            callback,
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
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                            child: pmAmWidget(amPmModel: e)))
                        .toList())
              ]),
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
                      if (hours++ == 8) {
                        hours = 0;
                        setState(() {
                          currDate = currDate.add(Duration(hours: 1));
                        });
                      }
                    } else {
                      if (hours++ == 8) {
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
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                switchInCurve: Curves.ease,
                switchOutCurve: Curves.easeInOutCirc,
                child: (savedDate != null)
                    ? TimeCard(
                        date: savedDate!,
                        onRemove: () async {
                          await prefs.remove(timeKey);
                          savedDate = null;
                          setState(() {});
                        },
                      )
                    : SizedBox(),
              ),
            ],
          )),
    );
  }

  static void scheduleAlarm() async {
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

class TimeCard extends StatelessWidget {
  const TimeCard({Key? key, required this.date, required this.onRemove})
      : super(key: key);
  final DateTime date;
  final Function onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
                  DateFormat('hh:mm a').format(date),
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
        ),
        Positioned(
          top: 10,
          right: 10,
          child: InkWell(
            onTap: () => onRemove(),
            child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 15,
                child: Icon(
                  Icons.remove_circle_outline_outlined,
                  color: Colors.red,
                )),
          ),
        )
      ],
    );
  }
}
