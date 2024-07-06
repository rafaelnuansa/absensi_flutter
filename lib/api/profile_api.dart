import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absensi/utils/constants.dart';

class ProfileApi {
  static Future<Map<String, dynamic>> getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('auth_token') ?? '';

    final Uri uri =
        Uri.parse(Constants.profileUrl); // Ganti dengan URL API profil Anda

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
      throw Exception('Failed to load profile data');
    }
  }

  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profileData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('auth_token') ?? '';

    final Uri uri = Uri.parse(
        Constants.updateProfileUrl); // Ganti dengan URL API update profil Anda

    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(profileData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update profile');
    }
  }

  static Future<Map<String, dynamic>> updateAvatar(
      String avatarFilePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('auth_token') ?? '';

    final Uri uri = Uri.parse(
        Constants.updateAvatarUrl); // Ganti dengan URL API update avatar Anda

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Accept': 'application/json',
      },
      body: {
        'avatar': avatarFilePath,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update avatar');
    }
  }
}
