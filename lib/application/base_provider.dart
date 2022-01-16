import 'package:analog_alarm/utils.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class BaseProvider extends ChangeNotifier {
  final _box = GetStorage();

   listenToBox() {
    _box.listenKey('time', (value) {
      print(value);
    });
  }
}
