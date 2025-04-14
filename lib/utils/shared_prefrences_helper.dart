import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShPH {
  static SharedPreferences? sharedPreferences;

  static init() async => sharedPreferences = await SharedPreferences.getInstance();

  static dynamic getData({required String key}) => sharedPreferences?.get(key);

  static Future<dynamic> saveData({required String key, required dynamic value}) async {
    if (kDebugMode) {
      print('Saving data - Key: $key, Value: $value');
    }

    if (value is String) {
      return await sharedPreferences?.setString(key, value);
    } else if (value is int) {
      return await sharedPreferences?.setInt(key, value);
    } else if (value is bool) {
      return await sharedPreferences?.setBool(key, value);
    } else if (value == double) {
      return await sharedPreferences?.setDouble(key, value);
    }
    else {
      throw Exception('Saving Failed - Key: $key, Value: $value');
    }
  }

  static Future<bool?> removeData({required String key}) async {
    return await sharedPreferences?.remove(key);
  }

  static Future<bool?> clearData() async {
    return await sharedPreferences?.clear();
  }
}
