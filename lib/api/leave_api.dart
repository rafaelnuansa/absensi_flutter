import 'dart:convert';
import 'dart:typed_data';
import 'package:absensi/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:absensi/models/leave.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaveApi {
  static Future<List<Leave>> fetchLeaves(
      {String? startDate, String? endDate}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken = prefs.getString('auth_token') ?? '';

      String url = Constants.leaveUrl;
      url += '?start_date=$startDate&end_date=$endDate';

      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          List<dynamic> leaveData = responseData['leaves'];
          List<Leave> leaves =
              leaveData.map((json) => Leave.fromJson(json)).toList();
          return leaves;
        } else {
          throw Exception('Failed to load leaves: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to load leaves: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load leaves: $e');
    }
  }

  static Future<void> createLeave(Leave leave, Uint8List imageBytes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('auth_token') ?? '';

    final response = await http.post(
      Uri.parse(Constants.leaveUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(<String, dynamic>{
        'start_date': leave.startDate,
        'end_date': leave.endDate,
        'date_work': leave.dateWork,
        'total': leave.total,
        'reason': leave.reason,
        'type': leave.type,
        'image':
            base64Encode(imageBytes), // Encode image bytes to base64 string
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create leave');
    }
  }

  static Future<void> updateLeave(
      int id, Leave leave, Uint8List imageBytes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('auth_token') ?? '';

    final response = await http.put(
      Uri.parse(Constants.leaveUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(<String, dynamic>{
        'id': id,
        'start_date': leave.startDate,
        'end_date': leave.endDate,
        'date_work': leave.dateWork,
        'total': leave.total,
        'reason': leave.reason,
        'type': leave.type,
        'image':
            base64Encode(imageBytes), // Encode image bytes to base64 string
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update leave');
    }
  }
}
