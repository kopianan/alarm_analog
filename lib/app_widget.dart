import 'package:analog_alarm/presentation/home_page.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  late SharedPreferences pref;
  final String countKey = 'count';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<bool>(builder: (context, snp) {
        if (snp.connectionState == ConnectionState.done) {
          return HomePage();
        } else {
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      }),
    );
  }

  Future<bool> initSetting() async {
    bool init = await AndroidAlarmManager.initialize();
    pref = await SharedPreferences.getInstance();
    if (!pref.containsKey(countKey)) pref.setInt(countKey, 0);
    return init;
  }
}
