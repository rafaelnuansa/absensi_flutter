import 'package:absensi/screens/presence_filter_screen.dart';
import 'package:absensi/utils/datetime_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absensi/providers/presence_filter_provider.dart';
import 'package:absensi/models/presence.dart';
import 'package:absensi/api/presence_api.dart';
import 'package:absensi/screens/presence_detail_screen.dart';
import 'package:intl/intl.dart';

class PresenceHistoryScreen extends StatefulWidget {
  const PresenceHistoryScreen({super.key});

  @override
  PresenceHistoryScreenState createState() => PresenceHistoryScreenState();
}

class PresenceHistoryScreenState extends State<PresenceHistoryScreen> {
  List<Presence> _presenceHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchPresenceHistory();
  }

  Future<void> _fetchPresenceHistory() async {
    try {
      final filterProvider =
          Provider.of<PresenceFilterProvider>(context, listen: false);
      final startDate = _formatDateWithoutTime(filterProvider.startDate);
      final endDate = _formatDateWithoutTime(filterProvider.endDate);

      final response = await PresenceService.getHistory(
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        _presenceHistory = List<Presence>.from(response['presences']
            .map((presenceJson) => Presence.fromJson(presenceJson)));
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching presence history: $e');
      }
    }
  }

  Future<void> _refreshData() async {
    await _fetchPresenceHistory();
  }

  Future<void> _showFilterSheet() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const PresenceFilterScreen();
      },
    );
    // Panggil _fetchPresenceHistory setelah menutup bottom sheet
    _fetchPresenceHistory();
  }

  String _formatDateWithoutTime(DateTime? date) {
    // Ubah tipe parameter menjadi nullable
    return date != null
        ? DateFormat('yyyy-MM-dd').format(date)
        : ''; // Atur pesan default jika tanggal null
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Histori Absensi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Consumer<PresenceFilterProvider>(
        builder: (context, filterProvider, _) {
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: _presenceHistory.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Tidak ada data yang tersedia',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: _presenceHistory.map((presence) {
                          IconData iconData;
                          Color iconColor;

                          switch (presence.status) {
                            case 'present':
                              iconData = Icons.check_circle;
                              iconColor = Colors.green;
                              break;
                            case 'on_leave':
                              iconData = Icons.access_time;
                              iconColor = Colors.blue;
                              break;
                            case 'sick':
                              iconData = Icons.sick;
                              iconColor = Colors.orange;
                              break;
                            case 'absent':
                              iconData = Icons.cancel;
                              iconColor = Colors.red;
                              break;
                            default:
                              iconData = Icons.error;
                              iconColor = Colors.black;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                    color: Colors.grey, width: 0.5),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PresenceDetailScreen(
                                              presence: presence),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        child: Icon(iconData,
                                            color: iconColor, size: 28),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateTimeUtils.formatDate(
                                                  presence.date),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              'Masuk : ${presence.timeIn ?? ' -'}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              'Keluar : ${presence.timeOut ?? '-'}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
