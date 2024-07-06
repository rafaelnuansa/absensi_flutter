import 'dart:convert';
import 'package:absensi/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PresenceService {
  static Future<Map<String, dynamic>> getPresence() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('auth_token') ?? '';

    final Uri uri =
        Uri.parse(Constants.presenceUrl); // Ganti dengan URL API Anda

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load presence data');
    }
  }

  static Future<Map<String, dynamic>> submitPresence(
      String latitudeLongitude, String resultCapture) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('auth_token') ?? '';

    final Uri uri = Uri.parse(Constants.presenceUrl);

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Accept': 'application/json',
      },
      body: {
        'latitude_longitude': latitudeLongitude,
        'resultCapture': resultCapture,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      // Jika respon status code 400, artinya ada kesalahan pada permintaan
      return (json.decode(response.body));
    } else {
      return (json.decode(response.body));
    }
  }

  static Future<Map<String, dynamic>> getHistory(
      {String? startDate, String? endDate}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('auth_token') ?? '';

    // Tentukan URL berdasarkan apakah filter tanggal disediakan
    String url = Constants.historyPresenceUrl;
    if (startDate != null && endDate != null) {
      url += '?startDate=$startDate&endDate=$endDate';
    }

    final Uri uri = Uri.parse(url);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load presence data');
    }
  }
}
