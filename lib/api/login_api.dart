import 'dart:convert';
import 'package:absensi/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final Uri uri = Uri.parse(Constants.loginUrl);
    final response = await http.post(
      uri,
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final token = responseData['token'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('auth_token', token);
      
      return responseData;
    } else {
      final responseData = json.decode(response.body);
      return responseData;
    }
  }
}
