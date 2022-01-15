import 'package:analog_alarm/main.dart';
import 'package:flutter/material.dart';
import 'dart:math';

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
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          scheduleAlarm(DateTime.now( ));
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
              height: 100,
            );
          }),
      body: Container(
          alignment: Alignment.center,
          color: Color(0xFFB081D6),
          // child: AnalogClock(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${currDate.hour} : ${currDate.minute}"),
              Container(
                width: 300,
                height: 300,
                child: GestureDetector(
                  // onHorizontalDragEnd: (e) {
                  //   min = 0;
                  // },
                  // onVerticalDragEnd: (e) {
                  //   hours = 0;
                  // },

                  // onPanDown: (_) {},
                  // onPanStart: (_) {},
                  // onPanEnd: (_) {},
                  // onPanCancel: () {},
                  // onPanUpdate: (details) {
                  //   if (details.delta.dy > 0) {
                  //     // swiping in right direction
                  //     if (hours++ == 5) {
                  //       hours = 0;
                  //       setState(() {
                  //         currDate = currDate.add(Duration(hours: 1));
                  //       });
                  //     }
                  //   } else {
                  //     if (hours++ == 5) {
                  //       hours = 0;
                  //       setState(() {
                  //         currDate = currDate.add(Duration(hours: -1));
                  //       });
                  //     }
                  //   }

                  //   if (details.delta.dx > 0) {
                  //     // swiping in right direction
                  //     if (min++ == 5) {
                  //       min = 0;
                  //       setState(() {
                  //         currDate = currDate.add(Duration(minutes: 1));
                  //       });
                  //     }
                  //   } else {
                  //     if (min++ == 5) {
                  //       min = 0;
                  //       setState(() {
                  //         currDate = currDate.add(Duration(minutes: -1));
                  //       });
                  //     }
                  //   }
                  // },

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
                    if (details.delta.dx >= 1) {
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
                        showSecondHand: false,
                        showDigitalClock: false),
                  ),
                  // child: Transform.rotate(
                  //   angle: -pi / 2,
                  //   child: CustomPaint(
                  //     painter: AnalogClockPainter(datetime: currDate),
                  //   ),
                  // ),
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
        TZDateTime.now(detroit).add(Duration(seconds: 5)),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
}

class AnalogClockPainter extends CustomPainter {
  DateTime datetime;
  final bool showDigitalClock;
  final bool showTicks;
  final bool showNumbers;
  final bool showAllNumbers;
  final bool showSecondHand;
  final bool useMilitaryTime;
  final Color hourHandColor;
  final Color minuteHandColor;
  final Color secondHandColor;
  final Color tickColor;
  final Color digitalClockColor;
  final Color numberColor;
  final double textScaleFactor;

  static const double BASE_SIZE = 320.0;
  static const double MINUTES_IN_HOUR = 60.0;
  static const double SECONDS_IN_MINUTE = 60.0;
  static const double HOURS_IN_CLOCK = 12.0;
  static const double HAND_PIN_HOLE_SIZE = 8.0;
  static const double STROKE_WIDTH = 3.0;

  AnalogClockPainter(
      {required this.datetime,
      this.showDigitalClock = true,
      this.showTicks = true,
      this.showNumbers = true,
      this.showSecondHand = true,
      this.hourHandColor = Colors.black,
      this.minuteHandColor = Colors.black,
      this.secondHandColor = Colors.redAccent,
      this.tickColor = Colors.grey,
      this.digitalClockColor = Colors.black,
      this.numberColor = Colors.black,
      this.showAllNumbers = false,
      this.textScaleFactor = 1.0,
      this.useMilitaryTime = true});

  @override
  void paint(Canvas canvas, Size size) {
    double scaleFactor = size.shortestSide / BASE_SIZE;

    if (showTicks) _paintTickMarks(canvas, size, scaleFactor);
    if (showNumbers) {
      _drawIndicators(canvas, size, scaleFactor, showAllNumbers);
    }

    if (showDigitalClock)
      _paintDigitalClock(canvas, size, scaleFactor, useMilitaryTime);

    _paintClockHands(canvas, size, scaleFactor);
    _paintPinHole(canvas, size, scaleFactor);
  }

  @override
  bool shouldRepaint(AnalogClockPainter oldDelegate) {
    return oldDelegate.datetime.isBefore(datetime);
  }

  _paintPinHole(canvas, size, scaleFactor) {
    Paint midPointStrokePainter = Paint()
      ..color = showSecondHand ? secondHandColor : minuteHandColor
      ..strokeWidth = STROKE_WIDTH * scaleFactor
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero),
        HAND_PIN_HOLE_SIZE * scaleFactor, midPointStrokePainter);
  }

  void _drawIndicators(
      Canvas canvas, Size size, double scaleFactor, bool showAllNumbers) {
    TextStyle style = TextStyle(
        color: numberColor,
        fontWeight: FontWeight.bold,
        fontSize: 18.0 * scaleFactor * textScaleFactor);
    double p = 12.0;
    if (showTicks) p += 24.0;

    double r = size.shortestSide / 2;
    double longHandLength = r - (p * scaleFactor);

    for (var h = 1; h <= 12; h++) {
      if (!showAllNumbers && h % 3 != 0) continue;
      double angle = (h * pi / 6) - pi / 2; //+ pi / 2;
      Offset offset =
          Offset(longHandLength * cos(angle), longHandLength * sin(angle));
      TextSpan span = new TextSpan(style: style, text: h.toString());
      TextPainter tp = new TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, size.center(offset - tp.size.center(Offset.zero)));
    }
  }

  Offset _getHandOffset(double percentage, double length) {
    final radians = 2 * pi * percentage;
    final angle = -pi / 2.0 + radians;

    return new Offset(length * cos(angle), length * sin(angle));
  }

  // ref: https://www.codenameone.com/blog/codename-one-graphics-part-2-drawing-an-analog-clock.html
  void _paintTickMarks(Canvas canvas, Size size, double scaleFactor) {
    double r = size.shortestSide / 2;
    double tick = 5 * scaleFactor,
        mediumTick = 2.0 * tick,
        longTick = 3.0 * tick;
    double p = longTick + 4 * scaleFactor;
    Paint tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 2.0 * scaleFactor;

    for (int i = 1; i <= 60; i++) {
      // default tick length is short
      double len = tick;
      if (i % 15 == 0) {
        // Longest tick on quarters (every 15 ticks)
        len = longTick;
      } else if (i % 5 == 0) {
        // Medium ticks on the '5's (every 5 ticks)
        len = mediumTick;
      }
      // Get the angle from 12 O'Clock to this tick (radians)
      double angleFrom12 = i / 60.0 * 2.0 * pi;

      // Get the angle from 3 O'Clock to this tick
      // Note: 3 O'Clock corresponds with zero angle in unit circle
      // Makes it easier to do the math.
      double angleFrom3 = pi / 2.0 - angleFrom12;

      canvas.drawLine(
          size.center(Offset(cos(angleFrom3) * (r + len - p),
              sin(angleFrom3) * (r + len - p))),
          size.center(
              Offset(cos(angleFrom3) * (r - p), sin(angleFrom3) * (r - p))),
          tickPaint);
    }
  }

  void _paintClockHands(Canvas canvas, Size size, double scaleFactor) {
    double r = size.shortestSide / 2;
    double p = 0.0;
    if (showTicks) p += 28.0;
    if (showNumbers) p += 24.0;
    if (showAllNumbers) p += 24.0;
    double longHandLength = r - (p * scaleFactor);
    double shortHandLength = r - (p + 36.0) * scaleFactor;

    Paint handPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.bevel
      ..strokeWidth = STROKE_WIDTH * scaleFactor;
    double seconds = datetime.second / SECONDS_IN_MINUTE;
    double minutes = (datetime.minute + seconds) / MINUTES_IN_HOUR;
    double hour = (datetime.hour + minutes) / HOURS_IN_CLOCK;

    canvas.drawLine(
        size.center(_getHandOffset(hour, HAND_PIN_HOLE_SIZE * scaleFactor)),
        size.center(_getHandOffset(hour, shortHandLength)),
        handPaint..color = hourHandColor);

    canvas.drawLine(
        size.center(_getHandOffset(minutes, HAND_PIN_HOLE_SIZE * scaleFactor)),
        size.center(_getHandOffset(minutes, longHandLength)),
        handPaint..color = minuteHandColor);
    if (showSecondHand)
      canvas.drawLine(
          size.center(
              _getHandOffset(seconds, HAND_PIN_HOLE_SIZE * scaleFactor)),
          size.center(_getHandOffset(seconds, longHandLength)),
          handPaint..color = secondHandColor);
  }

  void _paintDigitalClock(
      Canvas canvas, Size size, double scaleFactor, bool useMilitaryTime) {
    int hourInt = datetime.hour;
    String meridiem = '';
    if (!useMilitaryTime) {
      if (hourInt > 12) {
        hourInt = hourInt - 12;
        meridiem = ' PM';
      } else {
        meridiem = ' AM';
      }
    }
    String hour = hourInt.toString().padLeft(2, "0");
    String minute = datetime.minute.toString().padLeft(2, "0");
    String second = datetime.second.toString().padLeft(2, "0");
    TextSpan digitalClockSpan = new TextSpan(
        style: TextStyle(
            color: digitalClockColor,
            fontSize: 50 * scaleFactor * textScaleFactor),
        text: "$hour:$minute");
    TextPainter digitalClockTP = new TextPainter(
        text: digitalClockSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    digitalClockTP.layout();
    digitalClockTP.paint(
        canvas, size.center(-digitalClockTP.size.center(Offset(0.0, 280))));
  }
}

class ClockPainter extends CustomPainter {
  ClockPainter(this.dateTime);
  final DateTime dateTime;

  //60 sec - 360, 1 sec - 6degree
  //12 hours  - 360, 1 hour - 30degrees, 1 min - 0.5degrees

  @override
  void paint(Canvas canvas, Size size) {
    var centerX = size.width / 2;
    var centerY = size.height / 2;
    var center = Offset(centerX, centerY);
    var radius = min(centerX, centerY);

    var fillBrush = Paint()..color = Color(0xFF444974);

    var outlineBrush = Paint()
      ..color = Color(0xFFEAECFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;

    var centerFillBrush = Paint()..color = Color(0xFFEAECFF);

    var secHandBrush = Paint()
      ..color = Colors.orange[300]!
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;

    var minHandBrush = Paint()
      ..shader = RadialGradient(colors: [Color(0xFF748EF6), Color(0xFF77DDFF)])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;

    var hourHandBrush = Paint()
      ..shader = RadialGradient(colors: [Color(0xFFEA74AB), Color(0xFFC279FB)])
          .createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    var dashBrush = Paint()
      ..color = Color(0xFFEAECFF)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius - 40, fillBrush);
    canvas.drawCircle(center, radius - 40, outlineBrush);

    var hourHandX = centerX +
        60 * cos((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180);
    var hourHandY = centerX +
        60 * sin((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180);
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandBrush);

    var minHandX = centerX + 80 * cos(dateTime.minute * 6 * pi / 180);
    var minHandY = centerX + 80 * sin(dateTime.minute * 6 * pi / 180);
    canvas.drawLine(center, Offset(minHandX, minHandY), minHandBrush);

    var secHandX = centerX + 80 * cos(dateTime.second * 6 * pi / 180);
    var secHandY = centerX + 80 * sin(dateTime.second * 6 * pi / 180);
    canvas.drawLine(center, Offset(secHandX, secHandY), secHandBrush);

    canvas.drawCircle(center, 16, centerFillBrush);

    var outerCircleRadius = radius;
    var innerCircleRadius = radius - 14;
    var innerCircleRadius2 = radius + 20;
    for (double i = 0; i < 360; i += 30) {
      var x1 = centerX + outerCircleRadius * cos(i * pi / 180);
      var y1 = centerX + outerCircleRadius * sin(i * pi / 180);

      var x2 = centerX + innerCircleRadius2 * cos(i * pi / 180);
      var y2 = centerX + innerCircleRadius2 * sin(i * pi / 180);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashBrush);
    }
    for (double i = 0; i < 360; i += 5) {
      var x1 = centerX + outerCircleRadius * cos(i * pi / 180);
      var y1 = centerX + outerCircleRadius * sin(i * pi / 180);

      var x2 = centerX + innerCircleRadius * cos(i * pi / 180);
      var y2 = centerX + innerCircleRadius * sin(i * pi / 180);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashBrush);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
