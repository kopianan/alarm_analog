import 'package:analog_alarm/infrastructure/prefs.dart';
import 'package:analog_alarm/main.dart';
import 'package:analog_clock/analog_clock_painter.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/standalone.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int min = 0;
  int hours = 0;

  DateTime currDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          scheduleAlarm(currDate);
          Prefs().saveCurrentTime(currDate);
        },
        child: Icon(Icons.alarm),
      ),
      bottomSheet: BottomSheet(
        enableDrag: false,
        onClosing: () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        builder: (context) {
          return Container(
            width: double.infinity,
            color: Colors.transparent,
            child: ListTile(
              leading: Text(
                "${Prefs().getCurrentTime().hour}:\n${Prefs().getCurrentTime().minute}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                "On Progress",
                style: TextStyle(color: Colors.green),
              ),
              subtitle: Text("Current Alarm Time"),
              title: Text(
                "${Prefs().getCurrentTime().day} ${Prefs().getCurrentTime().month}",
              ),
            ),
          );
        },
      ),
      body: Container(
          alignment: Alignment.center,
          color: Color(0xFFB081D6),
          // child: AnalogClock(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${currDate.hour} : ${currDate.minute}",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
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
                    print(details.primaryDelta);
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
                        useMilitaryTime: true,
                        datetime: currDate,
                        numberColor: Colors.white,
                        textScaleFactor: 1.4,
                        tickColor: Colors.black,
                        showNumbers: true,
                        hourHandColor: Colors.white,
                        showSecondHand: false,
                        showDigitalClock: false),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  void scheduleAlarm(DateTime scheduledNotificationDateTime) async {
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
    final detroit = getLocation("Asia/Tokyo");

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Office',
        "Title",
        TZDateTime.now(detroit).add(Duration(seconds: 10)),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
}
