import 'dart:io';
import 'package:absensi/screens/main_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absensi/providers/patrol_photos_provider.dart';
import 'package:absensi/api/patrol_api.dart';
import 'package:absensi/screens/patrol_camera_screen.dart';

class PatrolDetailScreen extends StatefulWidget {
  final int patrolId;

  const PatrolDetailScreen({super.key, required this.patrolId});

  @override
  PatrolDetailScreenState createState() => PatrolDetailScreenState();
}

class PatrolDetailScreenState extends State<PatrolDetailScreen> {
  final TextEditingController _informationController = TextEditingController();
  String _patrolStatus = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatrolDetails();
  }

  Future<void> _loadPatrolDetails() async {
    try {
      final response = await PatrolApi().getReport(widget.patrolId);
      if (response['success'] == true) {
        setState(() {
          _patrolStatus = response['patrol']['status'];
          _informationController.text = response['patrol']['information'] ?? '';
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Unknown error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load patrol details: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Data Patroli',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _informationController,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Informasi',
                      labelStyle: TextStyle(
                        color: Colors.blue,
                        fontSize: 18.0,
                      ),
                      hintText: 'Masukkan informasi disini',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildPatrolPhotos(context),
                  const SizedBox(height: 16),
                  if (_patrolStatus != 'completed')
                    TextButton(
                      onPressed: _savePatrolReport,
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all<Color>(Colors.lightBlue),
                        minimumSize: WidgetStateProperty.all<Size>(
                            const Size(double.infinity, 50)),
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildPatrolPhotos(BuildContext context) {
    final patrolPhotosProvider = Provider.of<PatrolPhotosProvider>(context);
    final patrolPhotos = patrolPhotosProvider.patrolPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Foto Patroli',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (patrolPhotos.isNotEmpty)
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: patrolPhotos.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(patrolPhotos[index].path),
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            (context, index);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.red,
                            ),
                            child: const Text(
                              'Hapus',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        if (patrolPhotos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Belum ada foto yang diambil.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () async {
            final cameras = await availableCameras();
            if (cameras.isNotEmpty) {
              final camera = cameras.first;
              if (patrolPhotos.length < 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatrolCameraScreen(camera: camera),
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Maksimal 2 Foto'),
                    content: const Text(
                        'Anda hanya dapat mengambil maksimal 2 foto.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Kamera tidak terdeteksi'),
                  content: const Text('Tidak ada kamera yang tersedia.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Colors.lightBlue),
            minimumSize: WidgetStateProperty.all<Size>(
                const Size(double.infinity, 50)),
          ),
          child: const Text(
            'Ambil Foto',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _savePatrolReport() async {
    final String information = _informationController.text.trim();
    if (information.isNotEmpty) {
      try {
        final patrolPhotosProvider =
            Provider.of<PatrolPhotosProvider>(context, listen: false);
        List<File> patrolPhotos = patrolPhotosProvider.patrolPhotos
            .map((photo) => File(photo.path))
            .toList();

        final response = await PatrolApi()
            .savePatrolReport(widget.patrolId, information, patrolPhotos);

        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']),
              backgroundColor: Colors.green,
            ),
          );
          patrolPhotosProvider.clearPhotos();
          Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(selectedIndex: 3), // Assuming index 3 is PatrolScreen
          ),
          (route) => false, // Clear all routes in the stack
        );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan laporan patroli'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informasi tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
