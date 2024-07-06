import 'package:absensi/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:absensi/api/patrol_api.dart';

class PatrolDetailCompletedScreen extends StatelessWidget {
  final int patrolId;

  const PatrolDetailCompletedScreen({super.key, required this.patrolId});

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
      body: FutureBuilder(
        future: PatrolApi().getReport(patrolId),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data!;
            if (data['success'] == true) {
              final patrol = data['patrol'];
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informasi',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(
                      '${patrol['information']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    const Text('Patrol Photos',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (patrol['photos'] != null &&
                        (patrol['photos'] as List).isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: patrol['photos'].length,
                          itemBuilder: (context, index) {
                            final photo = patrol['photos'][index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  '${Constants.baseUrl}/' + photo['file_path'],
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (patrol['photos'] == null ||
                        (patrol['photos'] as List).isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('Belum ada foto yang diambil.',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                  ],
                ),
              );
            } else {
              return Center(
                  child: Text(
                      'Failed to load patrol details: ${data['message']}'));
            }
          }
        },
      ),
    );
  }
}
