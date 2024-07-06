// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:absensi/providers/patrol_photos_provider.dart';

class PatrolCameraScreen extends StatefulWidget {
  final CameraDescription camera;
  const PatrolCameraScreen({super.key, required this.camera});

  @override
  PatrolCameraScreenState createState() => PatrolCameraScreenState();
}

class PatrolCameraScreenState extends State<PatrolCameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isPhotoTaken = false;
  XFile? _capturedPhoto;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.veryHigh,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCamera() async {
    final cameras = await availableCameras();
    CameraDescription newCameraDescription;
    if (_controller.description.lensDirection == CameraLensDirection.back) {
      newCameraDescription = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } else {
      newCameraDescription = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
    }

    await _controller.dispose();
    _controller = CameraController(
      newCameraDescription,
      ResolutionPreset.veryHigh,
    );
    await _controller.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take Photo')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildCameraPreview(context);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

Widget _buildCameraPreview(BuildContext context) {
  // Calculate the aspect ratio of the camera preview
  final size = MediaQuery.of(context).size;
  final double aspectRatio = _controller.value.aspectRatio;

  // Calculate the height of the camera preview to maintain aspect ratio
  double cameraHeight = size.width / aspectRatio;

  // Check if the calculated height exceeds the screen height
  if (cameraHeight > size.height) {
    cameraHeight = size.height;
  }

  return Stack(
    alignment: Alignment.bottomCenter,
    children: [
      ClipRect(
        child: OverflowBox(
          maxHeight: size.height,
          maxWidth: size.width,
          child: CameraPreview(_controller),
        ),
      ),
      if (_isPhotoTaken && _capturedPhoto != null) // Check _capturedPhoto
        Image.file(
          File(_capturedPhoto!.path),
          fit: BoxFit.cover,
          width: size.width,
          height: size.height,
        ),
      if (!_isPhotoTaken)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FloatingActionButton(
            onPressed: () => _capturePhoto(context),
            child: const Icon(Icons.camera),
          ),
        ),
      if (_isPhotoTaken)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                onPressed: () => _retakePhoto(),
                child: const Icon(Icons.refresh),
              ),
              FloatingActionButton(
                onPressed: () => _savePhoto(context),
                child: const Icon(Icons.save),
              ),
              FloatingActionButton(
                onPressed: () => _deletePhoto(context),
                child: const Icon(Icons.delete),
              ),
            ],
          ),
        ),
      if (!_isPhotoTaken)
        Positioned(
          bottom: 100, // Adjust button position as needed
          child: FloatingActionButton(
            onPressed: _toggleCamera,
            child: const Icon(Icons.switch_camera),
          ),
        ),
    ],
  );
}


  void _capturePhoto(BuildContext context) async {
    try {
      final XFile photo = await _controller.takePicture();
      setState(() {
        _isPhotoTaken = true;
        _capturedPhoto = photo; // Menyimpan XFile yang diambil
      });
    } catch (e) {
      _showErrorDialog(context, 'Error capturing photo: $e');
    }
  }

  void _retakePhoto() {
    setState(() {
      _isPhotoTaken = false;
      _capturedPhoto = null;
    });
  }

  void _savePhoto(BuildContext context) {
    if (_capturedPhoto != null) {
      final patrolPhotosProvider =
          Provider.of<PatrolPhotosProvider>(context, listen: false);
      // Generate unique file name (e.g., using timestamp)
      String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      patrolPhotosProvider.addPhoto(uniqueFileName, _capturedPhoto!.path);
      Navigator.pop(context);
    } else {
      _showErrorDialog(context, 'No photo captured');
    }
  }

  void _deletePhoto(BuildContext context) {
    if (_capturedPhoto != null) {
      final patrolPhotosProvider =
          Provider.of<PatrolPhotosProvider>(context, listen: false);
      patrolPhotosProvider
          .removePhoto(_capturedPhoto!.path); // Assuming path is a string
      setState(() {
        _isPhotoTaken = false;
        _capturedPhoto = null;
      });
    } else {
      _showErrorDialog(context, 'No photo to delete');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
