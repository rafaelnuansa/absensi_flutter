// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:absensi/api/presence_api.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PresenceScreen extends StatefulWidget {
  const PresenceScreen({super.key});

  @override
  PresenceScreenState createState() => PresenceScreenState();
}

class PresenceScreenState extends State<PresenceScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  Position? _currentPosition;

  bool _isCameraReady = false;
  bool _isPhotoTaken = false;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final permissions = await [
      Permission.camera,
      Permission.location,
    ].request();

    if (permissions[Permission.camera] == PermissionStatus.granted) {
      await _initializeCamera();
    } else {
      _showPermissionDeniedDialog(context, 'Camera');
      _showErrorSnackbar('Camera permission denied');
    }

    if (permissions[Permission.location] == PermissionStatus.granted) {
      await _getCurrentLocation();
    } else {
      print('Location permission not granted');
      _showErrorSnackbar('Location permission denied');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller.initialize().then((_) {
      setState(() {
        _isCameraReady = true;
      });
    });
  }

  void _showPermissionDeniedDialog(BuildContext context, String permission) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content:
              Text('$permission permission is required to use this feature.'),
          actions: [
            TextButton(
              onPressed: () {
                if (!mounted) {
                  return; // Pengecekan lagi sebelum memanggil Navigator
                }
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Camera Absensi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Kembali ke layar sebelumnya
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Stack(
        children: [
          _isCameraReady
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: CameraPreview(_controller),
                )
              : const Center(child: CircularProgressIndicator()),
          if (_isPhotoTaken)
            Positioned.fill(
              child: Image.file(
                File(_imageFile!.path),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
              ),
            ),
          if (_currentPosition != null)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Lat: ${_currentPosition!.latitude}, Long: ${_currentPosition!.longitude}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!_isPhotoTaken)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: IconButton(
                      onPressed:
                          _isCameraReady ? _onCaptureButtonPressed : null,
                      icon: const Icon(Icons.camera_alt),
                    ),
                  ),
                if (_isPhotoTaken)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: IconButton(
                      onPressed: _isPhotoTaken ? _onAbsenButtonPressed : null,
                      icon: const Icon(Icons.assignment_turned_in),
                    ),
                  ),
                if (_isPhotoTaken)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: IconButton(
                      onPressed: _isPhotoTaken ? _onRetakeButtonPressed : null,
                      icon: const Icon(Icons.refresh),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onCaptureButtonPressed() async {
    try {
      await _initializeControllerFuture;
      final XFile file = await _controller.takePicture();

      setState(() {
        _isPhotoTaken = true;
        _imageFile = file;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void _onRetakeButtonPressed() {
    setState(() {
      _isPhotoTaken = false;
      _imageFile = null;
    });
  }

  void _onAbsenButtonPressed() async {
    try {
      if (_currentPosition != null && _imageFile != null) {
        final latitudeLongitude =
            '${_currentPosition!.latitude},${_currentPosition!.longitude}';

        final imageBytes = await File(_imageFile!.path).readAsBytes();
        final resultCapture = base64Encode(imageBytes);
        final response = await PresenceService.submitPresence(
            latitudeLongitude, resultCapture);

        // Cek apakah respons memiliki kunci 'success' dan 'message'
        if (response.containsKey('success') &&
            response.containsKey('message')) {
          // Tampilkan pesan respons dalam snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']),
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.of(context).pop();
        } else {
          // Tampilkan pesan default jika respons tidak sesuai format
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Format respons tidak valid'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        setState(() {
          _isPhotoTaken = false;
          _imageFile = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokasi atau gambar tidak didapatkan'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
