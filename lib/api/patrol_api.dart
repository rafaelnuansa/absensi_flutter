import 'dart:convert';
import 'dart:io';
import 'package:absensi/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PatrolApi {
  Future<Map<String, dynamic>> getCheckpoints() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('auth_token') ?? '';
    final response = await http.get(Uri.parse(Constants.patrolUrl), headers: {
      'Authorization': 'Bearer $authToken',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load checkpoints');
    }
  }

  Future<Map<String, dynamic>> getCheckpointDetails(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('auth_token') ?? '';
    final response =
        await http.get(Uri.parse('${Constants.patrolUrl}/$id'), headers: {
      'Authorization': 'Bearer $authToken',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load checkpoint details');
    }
  }

  Future<Map<String, dynamic>> createPatrol(
      String checkpointCode, int patrolId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('auth_token') ?? '';
    final response = await http.post(Uri.parse(Constants.patrolUrl), headers: {
      'Authorization': 'Bearer $authToken',
    }, body: {
      'checkpoint_code': checkpointCode,
      'patrol_id': patrolId.toString(),
    });

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create patrol');
    }
  }

  Future<Map<String, dynamic>> savePatrolReport(
    int patrolId,
    String information,
    List<File>? patrolPhotos, // Perubahan pada parameter
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken = prefs.getString('auth_token') ?? '';

      // Membuat request body
      Map<String, dynamic> requestBody = {
        'information': information,
      };

      // Jika ada foto patroli, tambahkan ke request body
      if (patrolPhotos != null && patrolPhotos.isNotEmpty) {
        List<String> base64Images = [];
        for (File photo in patrolPhotos) {
          List<int> imageBytes = photo.readAsBytesSync();
          String base64Image = base64Encode(imageBytes);
          base64Images.add(base64Image);
        }
        requestBody['patrol_photos'] = base64Images;
      }

      var response = await http.post(
        Uri.parse('${Constants.patrolUrl}/report/$patrolId'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $authToken',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Respons JSON yang sukses
        return json.decode(response.body);
      } else {
        // Respons JSON yang gagal
        throw Exception('Failed to update patrol report');
      }
    } catch (error) {
      throw Exception('Failed to update patrol report: $error');
    }
  }

  Future<Map<String, dynamic>> checkQR(
      String checkpointCode, String longitude, String latitude) async {
    try {
      // Kirim permintaan HTTP POST untuk memeriksa QR Code
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken = prefs.getString('auth_token') ?? '';
      final response = await http.post(
        Uri.parse(Constants.checkQRUrl),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
        body: {
          'checkpoint_code': checkpointCode,
          'longitude': longitude,
          'latitude': latitude,
        },
      );

      if (response.statusCode == 200) {
        // QR Code valid, kembalikan respons JSON
        return json.decode(response.body);
      } else if (response.statusCode == 409) {
        return json.decode(response.body);
      } else {
        // QR Code tidak valid, lempar exception dengan pesan kesalahan
        throw Exception('Failed to check QR Code: ${response.reasonPhrase}');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getReport(int patrolId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken = prefs.getString('auth_token') ?? '';

      final response = await http.get(
        Uri.parse('${Constants.patrolUrl}/report/$patrolId'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        return json.decode(response.body);
      } else {
        // If the server returns an error response, throw an exception
        throw Exception('Failed to get patrol report');
      }
    } catch (error) {
      // If an error occurs during the HTTP request, throw an exception
      throw Exception('Failed to get patrol report: $error');
    }
  }
}
