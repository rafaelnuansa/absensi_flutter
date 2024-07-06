import 'package:absensi/api/profile_api.dart';
import 'package:absensi/screens/presence_history_screen.dart';
import 'package:absensi/screens/presence_screen.dart';
import 'package:absensi/utils/constants.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:absensi/api/dashboard_api.dart';
import 'package:avatar_glow/avatar_glow.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  String namaUser = 'Loading..';
  String avatarUser = 'default.png';
  String positionName = 'Loading..';
  Map<String, dynamic> _dashboardData = {};

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });

    // Panggil method untuk mengambil data dashboard ketika widget pertama kali di-load
    _fetchDashboardData();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  // Method untuk mengambil data dashboard dari API
  Future<void> _fetchDashboardData() async {
    try {
      final dashboardData = await DashboardAPI.fetchDashboardData();
      setState(() {
        _dashboardData = dashboardData;
        if (kDebugMode) {
          print(_dashboardData.toString());
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching dashboard data: $e");
      }
    }
    try {
      final profile = await ProfileApi.getProfile();
      setState(() {
        namaUser = profile['profile']['name'];
        positionName = profile['position']['name'];
        avatarUser = profile['profile']['avatar'];
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching profile data: $e");
      }
    }
  }

  Future<void> _refreshDashboardData() async {
    await _fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshDashboardData,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.all(30), // Mengatur padding ke semua sisi
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AvatarGlow(
                          startDelay: const Duration(milliseconds: 1000),
                          glowColor: Colors.blue,
                          glowRadiusFactor: 0.2, // Menambahkan efek glow
                          curve: Curves.ease,
                          child: Material(
                            elevation: 8.0,
                            shape: const CircleBorder(),
                            color: Colors.transparent,
                            child: CircleAvatar(
                              radius: 38,
                              backgroundImage: NetworkImage(
                                '${Constants.storageAvatarUrl}/$avatarUser',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Welcome Back,',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight:
                                    FontWeight.bold, // Menjadikan teks tebal
                              ),
                            ),
                            SizedBox(
                              width:
                                  230, // Mengatur lebar teks agar tidak terlalu panjang
                              child: Text(
                                namaUser.length > 40
                                    ? '${namaUser.substring(0, 40)}...'
                                    : namaUser,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              child: Text(
                                positionName.length > 40
                                    ? '${namaUser.substring(0, 40)}...'
                                    : positionName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade500, Colors.blue.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'Jam Kerja',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildShiftInfo(
                          shiftName: 'Shift 1',
                          shiftStartTime: '06:00',
                          shiftEndTime: '20:00',
                          shiftInStart: '06:00',
                          shiftInEnd: '15:00',
                          shiftOutStart: '19:00',
                          shiftOutEnd: '21:00',
                        ),
                        const SizedBox(height: 10),
                        _buildShiftInfo(
                          shiftName: 'Shift 2',
                          shiftStartTime: '18:00',
                          shiftEndTime: '09:00 (Next Day)',
                          shiftInStart: '18:00',
                          shiftInEnd: '21:00',
                          shiftOutStart: '06:00 (Next Day)',
                          shiftOutEnd: '09:00 (Next Day)',
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Jika belum "checked out", lanjutkan ke screen PresenceScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PresenceScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            backgroundColor: (_dashboardData
                                        .containsKey('presence') &&
                                    _dashboardData['presence'] != null &&
                                    _dashboardData['presence']['time_in'] !=
                                        null &&
                                    _dashboardData['presence']['time_out'] !=
                                        null)
                                ? Colors.grey
                                    .shade500 // Jika sudah "checked out", warna tombol menjadi abu-abu
                                : Colors
                                    .white, // Jika tidak, gunakan warna default
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            _dashboardData.containsKey('presence') &&
                                    _dashboardData['presence'] != null &&
                                    _dashboardData['presence']['time_in'] !=
                                        null &&
                                    _dashboardData['presence']['time_out'] ==
                                        null
                                ? 'Check out'
                                : (_dashboardData.containsKey('presence') &&
                                        _dashboardData['presence'] != null &&
                                        _dashboardData['presence']['time_in'] !=
                                            null &&
                                        _dashboardData['presence']
                                                ['time_out'] !=
                                            null
                                    ? 'Checked out'
                                    : 'Check in'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: (_dashboardData.containsKey('presence') &&
                                      _dashboardData['presence'] != null &&
                                      _dashboardData['presence']['time_in'] !=
                                          null &&
                                      _dashboardData['presence']['time_out'] !=
                                          null)
                                  ? Colors
                                      .white // Jika sudah "checked out", warna teks menjadi putih
                                  : null, // Jika tidak, gunakan warna default
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PresenceHistoryScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade500, Colors.blue.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Histori',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                              Icon(
                                FluentIcons.chevron_right_48_regular,
                                size: 40,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Text(
                                          'Absen Masuk',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _dashboardData.containsKey('presence') &&
                                              _dashboardData['presence'] !=
                                                  null &&
                                              _dashboardData['presence']
                                                      ['time_in'] !=
                                                  null
                                          ? _dashboardData['presence']
                                                  ['time_in']
                                              .toString()
                                          : '-',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Text(
                                          'Absen Keluar',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _dashboardData.containsKey('presence') &&
                                              _dashboardData['presence'] !=
                                                  null &&
                                              _dashboardData['presence']
                                                      ['time_out'] !=
                                                  null
                                          ? _dashboardData['presence']
                                                  ['time_out']
                                              .toString()
                                          : '-',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${_dashboardData.containsKey('total_present') ? _dashboardData['total_present'] : '0'} Hadir',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(
                                        Icons.info,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${_dashboardData.containsKey('total_permission') ? _dashboardData['total_permission'] : '0'} Izin',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(
                                        Icons.healing,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${_dashboardData.containsKey('total_sick') ? _dashboardData['total_sick'] : '0'} Sakit',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(
                                        Icons.access_time,
                                        color: Colors.red,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${_dashboardData.containsKey('total_late') ? '${_dashboardData['total_late']} ' : '0 '}Telat',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildShiftInfo({
  required String shiftName,
  required String shiftStartTime,
  required String shiftEndTime,
  required String shiftInStart,
  required String shiftInEnd,
  required String shiftOutStart,
  required String shiftOutEnd,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        shiftName,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 8),
      _buildShiftTimeInfo('Waktu Masuk:', '$shiftInStart - $shiftInEnd'),
      const SizedBox(height: 4),
      _buildShiftTimeInfo('Waktu Keluar:', '$shiftOutStart - $shiftOutEnd'),
      const SizedBox(height: 4),
    ],
  );
}

Widget _buildShiftTimeInfo(String title, String time) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      ),
      Text(
        time,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ],
  );
}
