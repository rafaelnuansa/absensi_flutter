import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtil {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }


  static Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  static Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

   static Future<bool> isAdmin() async {
    final userDataString = _prefs.getString('user_data');
    if (userDataString != null) {
      final userData = json.decode(userDataString);
      return userData['is_admin'] == 1;
    } else {
      // If user_data is not yet stored, return false
      return false;
    }
  }

  static Future<void> saveUserData(String key, Map<String, dynamic> userData) async {
  final userDataString = json.encode(userData);
  await _prefs.setString(key, userDataString);
}


static Future<Map<String, dynamic>?> getUserData(String key) async {
  final userDataString = _prefs.getString(key);
  if (userDataString != null) {
    return json.decode(userDataString);
  } else {
    return null;
  }
}

 static Future<String?> getAuthToken() async {
    return _prefs.getString('auth_token');
  }

}
