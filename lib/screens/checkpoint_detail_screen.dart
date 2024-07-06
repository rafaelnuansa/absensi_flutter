import 'package:absensi/screens/patrol_detail_completed_screen.dart';
import 'package:absensi/screens/patrol_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:absensi/api/patrol_api.dart';
import 'package:absensi/models/checkpoint.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:geolocator/geolocator.dart';

class CheckpointDetailScreen extends StatefulWidget {
  final int checkpointId;

  const CheckpointDetailScreen({super.key, required this.checkpointId});

  @override
  CheckpointDetailScreenState createState() => CheckpointDetailScreenState();
}

class CheckpointDetailScreenState extends State<CheckpointDetailScreen> {
  Checkpoint? _checkpoint;
  List<Map<String, dynamic>> _patrols = [];

  late QRViewController _controller;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  bool _isScanned = false;
  late Position _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchCheckpointDetails();
    _getCurrentLocation();
  }

  Future<void> _fetchCheckpointDetails() async {
    try {
      Map<String, dynamic> checkpointData =
          await PatrolApi().getCheckpointDetails(widget.checkpointId);
      setState(() {
        _checkpoint = Checkpoint.fromJson(checkpointData['checkpoint']);
        _patrols = List<Map<String, dynamic>>.from(checkpointData['patrols']);
      });
    } catch (error) {
      print('Error fetching checkpoint details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(
          '${_checkpoint?.building.name ?? ''} - ${_checkpoint?.name ?? ''}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _scanQR,
            icon: const Icon(Icons.qr_code),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_checkpoint == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (_patrols.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _patrols.length,
                  itemBuilder: (context, index) {
                    final patrol = _patrols[index];
                    IconData iconData;
                    Color iconColor;

                    // Menentukan ikon dan warna berdasarkan status
                    switch (patrol['status']) {
                      case 'completed':
                        iconData = Icons.check_circle;
                        iconColor = Colors.green;
                        break;
                      case 'pending':
                        iconData = Icons.access_time;
                        iconColor = Colors.orange;
                        break;
                      case 'cancelled':
                        iconData = Icons.cancel;
                        iconColor = Colors.red;
                        break;
                      default:
                        iconData = Icons.error_outline;
                        iconColor = Colors.grey;
                    }

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      child: InkWell(
                        onTap: () => _navigateToPatrolDetailScreen(
                            patrol['id'], patrol['status']),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                iconData,
                                color: iconColor,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Scaned QR at ${patrol['date']} ${patrol['time']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Coordinate : ${patrol['longitude']} ,  ${patrol['latitude']} ',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Status: ${patrol['status']}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (_patrols.isEmpty)
              const Text(
                'Belum melakukan patroli dilokasi ini, silahkan Scan QR',
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      );
    }
  }

  void _navigateToPatrolDetailScreen(int patrolId, String status) {
    if (status.toLowerCase() == 'completed') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatrolDetailCompletedScreen(patrolId: patrolId),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatrolDetailScreen(patrolId: patrolId),
        ),
      );
    }
  }

  void _scanQR() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      _showQRScanner();
    } else {
      if (await Permission.location.request().isGranted) {
        _showQRScanner();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Permission denied to access location'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _showQRScanner() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Scan QR Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: QRView(
                    key: _qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _controller = controller;
    });
    _controller.scannedDataStream.listen((scanData) async {
      // Memeriksa apakah QR telah dipindai sebelumnya
      if (!_isScanned) {
        _isScanned = true; // Tandai bahwa QR telah dipindai
        await _controller
            .pauseCamera(); // Hentikan kamera setelah pemindaian pertama
        _validateQRCode(scanData.code.toString());
      }
    });
  }

  void _validateQRCode(String qrCode) async {
    try {
      // Panggil method checkQR dari PatrolApi untuk memeriksa validitas QR code
      final response = await PatrolApi().checkQR(
          qrCode,
          _currentPosition.latitude.toString(),
          _currentPosition.longitude.toString());
      if (response['status_code'] == 409) {
        // Jika status code adalah 409, tampilkan pesan peringatan di bottom sheet
        _showBottomSheet(
            'SCAN QR sudah dilakukan di lokasi ini', Colors.orange);
      } else if (response['status_code'] == 200) {
        _showBottomSheet('Kode Valid', Colors.green);

        // Tutup kamera QR
        _controller.dispose();
        // Tutup bottom sheet dan navigasi ke PatrolDetailScreen
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PatrolDetailScreen(patrolId: response['patrol_id']),
          ),
        );
      } else {
        // QR code tidak valid, tampilkan pesan kesalahan di bottom sheet
        _showBottomSheet('Kode tidak valid', Colors.red);
      }
    } catch (error) {
      // Tangani kesalahan ketika memvalidasi QR code
      _showBottomSheet('Failed to validate QR code', Colors.red);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (error) {
      print('Error getting current location: $error');
    }
  }

  void _showBottomSheet(String message, Color color) {
    // Reset variabel _isScanned ke false agar QR dapat dipindai lagi
    _isScanned = false;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 100,
        color: color,
        alignment: Alignment.center,
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
