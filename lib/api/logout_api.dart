import 'dart:convert';
import 'package:absensi/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LogoutService {
  static Future<Map<String, dynamic>> logout() async {
    final Uri uri = Uri.parse(Constants.logoutUrl);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('auth_token');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // Hapus token autentikasi dari penyimpanan lokal
      prefs.remove('auth_token');
      return responseData;
    } else {
      final responseData = json.decode(response.body);
      return responseData;
    }
  }
}
