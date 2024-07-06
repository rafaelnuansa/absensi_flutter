import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:absensi/screens/login_screen.dart';
import 'package:absensi/screens/main_screen.dart';
import 'package:absensi/utils/constants.dart';
import 'package:absensi/utils/shared.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkInternetConnectivity();
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkInternetConnectivity() async {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        // No internet connection, show Snackbar
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No internet connection'),
          backgroundColor: Colors.red,
        ));
      }
    });
  }

  Future<void> _navigateToNextScreen() async {
    // Delay for splash screen display
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Check if the user is logged in
    final token = await SharedPrefsUtil.getAuthToken();
    setState(() {});

    if (token != null && token.isNotEmpty) {
      // Validate the token
      final isValidToken = await validateToken(token);
      if (isValidToken) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(selectedIndex: 0),
          ),
        );
      } else {
        // Token is invalid, navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      // Token is not available, navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<bool> validateToken(String token) async {
    try {
      // Send request to the server to validate the token
      final response = await http.post(
        Uri.parse(Constants.validateTokenUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // Check the response status code
      if (response.statusCode == 200) {
        // If the response is successful, the token is still valid
        return true;
      } else {
        // If the response is not successful, the token is invalid
        return false;
      }
    } catch (e) {
      // Handle errors if they occur
      print('Error validating token: $e');
      return false; // For example, if there is a network error
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mengubah FlutterLogo dengan gambar dari assets
            Image(
              image: AssetImage('assets/images/logo.png'),
              width: 140,
              height: 140,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
