import 'package:flutter/material.dart';
import 'package:absensi/models/presence.dart';
import 'package:absensi/utils/constants.dart';

class PresenceDetailScreen extends StatelessWidget {
  final Presence presence;

  const PresenceDetailScreen({super.key, required this.presence});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Detail Absensi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          ListTile(
            title: const Text('Tanggal'),
            subtitle: Text(presence.date),
          ),
          ListTile(
            title: const Text('Status'),
            subtitle: Text(presence.status),
          ),
          ListTile(
            title: const Text('Time In'),
            subtitle: Text(presence.timeIn ?? '-'),
          ),
          ListTile(
            title: const Text('Time Out'),
            subtitle: Text(presence.timeOut ?? '-'),
          ),
          const SizedBox(height: 16.0),
          Center(
            child: Column(
              children: [
                const Text('Picture In', style: TextStyle(fontSize: 18.0)),
                const SizedBox(height: 8.0),
                GestureDetector(
                  onTap: () {
                    _viewImage(
                        context, '${Constants.baseUrl}/${presence.pictureIn}');
                  },
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(10.0), // Set border radius
                    child: Image.network(
                      '${Constants.baseUrl}/${presence.pictureIn}',
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text('Gambar tidak tersedia');
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text('Picture Out', style: TextStyle(fontSize: 18.0)),
                const SizedBox(height: 8.0),
                GestureDetector(
                  onTap: () {
                    _viewImage(
                        context, '${Constants.baseUrl}/${presence.pictureOut}');
                  },
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(10.0), // Set border radius
                    child: Image.network(
                      '${Constants.baseUrl}/${presence.pictureOut}',
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text('Gambar tidak tersedia');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _viewImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.blue,
            centerTitle: true,
            title: const Text(
              'Detail Absensi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: Image.network(
              imageUrl,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
        ),
      ),
    );
  }
}
