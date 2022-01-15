import 'package:get_storage/get_storage.dart';

class Prefs {
  final box = GetStorage();

  Future<void> saveCurrentTime(DateTime time) async {
    await box.write('time', time.toIso8601String());
  }

  DateTime getCurrentTime() {
    try {
      String? _data = box.read('time');
      var formatted = DateTime.parse(_data!);
      print(formatted);
      return formatted;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

}
