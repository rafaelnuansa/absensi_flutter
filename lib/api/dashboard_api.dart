import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:absensi/utils/constants.dart';
import 'package:absensi/utils/shared.dart'; // Import SharedPrefsUtil untuk mendapatkan token

class DashboardAPI {
  static Future<Map<String, dynamic>> fetchDashboardData() async {
    final authToken = await SharedPrefsUtil
        .getAuthToken(); // Dapatkan token dari Shared Preferences
    final response = await http.get(
      Uri.parse(Constants.getDashboardUrl),
      headers: {
        'Authorization': 'Bearer $authToken'
      }, // Sertakan token dalam header 'Authorization'
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return jsonDecode(response.body);
    }
  }
}
