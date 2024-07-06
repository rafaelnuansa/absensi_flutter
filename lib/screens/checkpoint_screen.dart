import 'package:absensi/api/patrol_api.dart';
import 'package:absensi/screens/checkpoint_detail_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:absensi/models/checkpoint.dart';
import 'package:absensi/models/patrol.dart';

class CheckpointScreen extends StatefulWidget {
  const CheckpointScreen({super.key});

  @override
  CheckpointScreenState createState() => CheckpointScreenState();
}

class CheckpointScreenState extends State<CheckpointScreen> {
  List<Checkpoint> checkpoints = [];
  List<Patrol> patrols = [];

  @override
  void initState() {
    super.initState();
    fetchCheckpoints();
  }

void fetchCheckpoints() async {
  try {
    Map<String, dynamic> checkpointData = await PatrolApi().getCheckpoints();
    List<dynamic> checkpointList = checkpointData['checkpoints'];
    if (checkpointList.isEmpty) {
      setState(() {
        checkpoints = [];
        patrols = [];
      });
      return;
    }

    setState(() {
      checkpoints = List<Checkpoint>.from(
        checkpointList.map(
          (checkpoint) => Checkpoint.fromJson(checkpoint),
        ),
      );
      // Update patrols list separately
      patrols = checkpoints
          .map((checkpoint) => checkpoint.patrols)
          .expand((patrols) => patrols)
          .toList();
    });
  } catch (error) {
    if (kDebugMode) {
      print('Error fetching data: $error');
    }
    // Handle error accordingly
  }
}

  Future<void> _refreshData() async {
    fetchCheckpoints();
  }

  void _viewCheckpointDetail(int checkpointId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CheckpointDetailScreen(checkpointId: checkpointId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: checkpoints.isEmpty
              ? const Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning,
                          size: 48,
                          color: Colors.orange,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada checkpoint yang tersedia',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: checkpoints.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    Checkpoint checkpoint = checkpoints[index];
                    Patrol patrol = patrols.firstWhere(
                      (patrol) => patrol.checkpointId == checkpoint.id,
                      orElse: () => Patrol(
                        id: -1,
                        checkpointId: checkpoint.id,
                        status: 'not_found', // Placeholder status for not found
                      ),
                    );
                    return Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    checkpoint.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                      '${checkpoint.code} - ${checkpoint.building.name}'),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getPatrolStatusText(patrol),
                                    style: TextStyle(
                                      color: _getPatrolStatusColor(patrol),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () {
                                _viewCheckpointDetail(checkpoint.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

String _getPatrolStatusText(Patrol? patrol) {
  if (patrol == null || patrol.status == 'not_found') {
    return 'Belum ada patroli';
  }

  switch (patrol.status) {
    case 'completed':
      return 'Patroli selesai';
    case 'pending':
      return 'Sedang Patroli';
    default:
      return 'Status tidak valid';
  }
}

Color _getPatrolStatusColor(Patrol? patrol) {
  if (patrol == null || patrol.status == 'not_found') {
    return Colors.red;
  }

  switch (patrol.status) {
    case 'completed':
      return Colors.green;
    case 'pending':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}
