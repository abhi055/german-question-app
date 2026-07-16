import 'package:shared_preferences/shared_preferences.dart';

Future<void> setInt({required String key, required int value}) async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  sharedPreferences.setInt(key, value);
}

Future<int> getInt({required String key, required int defaultValue}) async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  return sharedPreferences.getInt(key) ?? defaultValue;
}

Future<void> setString({required String key, required String value}) async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  sharedPreferences.setString(key, value);
}

Future<String> getString({
  required String key,
  required String defaultValue,
}) async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  return sharedPreferences.getString(key) ?? defaultValue;
}

Future<String?> getStringNoDefault({required String key}) async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  return sharedPreferences.getString(key);
}
