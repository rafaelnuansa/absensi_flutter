// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:absensi/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class RegisterAPI {
  // Method to register a new user
  static Future<Map<String, dynamic>> register({
    required String code,
    required String name,
    required String email,
    required String password,
    required int positionId,
    required int buildingId,
    required File avatar,
  }) async {
    try {
      // Construct multipart request for avatar upload
      final Uri registerUrl = Uri.parse(Constants.registerUrl);
      final request = http.MultipartRequest('POST', registerUrl);
      request.files.add(http.MultipartFile(
        'avatar',
        avatar.readAsBytes().asStream(),
        avatar.lengthSync(),
        filename: path.basename(avatar.path),
      ));

      // Add other registration parameters
      request.fields['code'] = code;
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['position_id'] = positionId.toString();
      request.fields['building_id'] = buildingId.toString();

      // Send combined avatar upload and registration request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Parse response
      final Map<String, dynamic> registerResult = json.decode(response.body);

      if (response.statusCode == 201) {
        // Registration successful
        return {'success': true, 'message': 'Registration successful'};
      } else {
        // Registration failed
        return {'success': false, 'message': registerResult['message']};
      }
    } catch (e) {
      // Error occurred
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Method to fetch positions from the server
  static Future<List<dynamic>> fetchPositions() async {
    final Uri url = Uri.parse(Constants.fetchPositionsUrl);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Successful response
        final data = json.decode(response.body);
        return data['positions'];
      } else {
        // Request failed
        return [];
      }
    } catch (e) {
      // Error occurred
      print('Error fetching positions: $e');
      return [];
    }
  }

  // Method to fetch buildings from the server
  static Future<List<dynamic>> fetchBuildings() async {
    final Uri url = Uri.parse(Constants.fetchBuildingsUrl);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Successful response
        final data = json.decode(response.body);
        return data['buildings'];
      } else {
        // Request failed
        return [];
      }
    } catch (e) {
      // Error occurred
      print('Error fetching buildings: $e');
      return [];
    }
  }

}
