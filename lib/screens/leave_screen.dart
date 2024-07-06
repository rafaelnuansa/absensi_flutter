import 'package:absensi/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:absensi/api/leave_api.dart';
import 'package:absensi/models/leave.dart';
import 'package:absensi/providers/leave_provider.dart';
import 'package:absensi/screens/leave_filter_screen.dart';
import 'package:absensi/screens/leave_request_screen.dart';
import 'package:absensi/screens/leave_edit_screen.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:intl/intl.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  LeaveScreenState createState() => LeaveScreenState();
}

class LeaveScreenState extends State<LeaveScreen> {
  final String _appBarTitle = 'Leave Requests';

  @override
  void initState() {
    super.initState();
    // Tambahkan listener untuk memperbarui data cuti
    Provider.of<LeaveProvider>(context, listen: false)
        .addListener(_fetchLeaveRequests);
    // Ambil data cuti saat inisialisasi
    _fetchLeaveRequests();
  }

  void _fetchLeaveRequests() {
    final leaveProvider = Provider.of<LeaveProvider>(context, listen: false);
    final startDate = leaveProvider.startDate;
    final endDate = leaveProvider.endDate;

    LeaveApi.fetchLeaves(
      startDate: _formatDateWithoutTime(startDate),
      endDate: _formatDateWithoutTime(endDate),
    ).then((leaves) {
      // Perbarui data cuti di LeaveProvider
      leaveProvider.setLeaves(leaves);
    }).catchError((error) {
      print('Error fetching leaves: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          _appBarTitle,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.blue),
        actions: [
          IconButton(
            onPressed: () => _showFilterSheet(context),
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const LeaveRequestScreen()),
            ),
            icon: const Icon(FluentIcons.add_48_filled),
          ),
        ],
      ),
      body: Consumer<LeaveProvider>(
        builder: (context, leaveProvider, _) {
          final leaveRequests = leaveProvider.filteredLeaves;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildLeaveRequestList(leaveRequests),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeaveRequestList(List<Leave> leaveRequests) {
    if (leaveRequests.isEmpty) {
      return const Center(
        child: Text(
          'No leave requests found',
          style: TextStyle(fontSize: 16),
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: leaveRequests.length,
        itemBuilder: (context, index) {
          final leave = leaveRequests[index];
          return _buildLeaveRequestItem(leave);
        },
      );
    }
  }

  Widget _buildLeaveRequestItem(Leave leave) {
    final startDate = DateTime.parse(leave.startDate!);
    final endDate = DateTime.parse(leave.endDate!);
    final dateWork = DateTime.parse(leave.dateWork);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.grey, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () => _editLeaveRequest(context, leave),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusIcon(leave.status.toString()),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${leave.type}'.capitalize(),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        leave.status.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(leave.status.toString()),
                        ),
                      ),
                      Text(
                        '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Work starts on ${_formatDate(dateWork)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData iconData = FluentIcons.hourglass_24_regular;
    Color iconColor = Colors.grey;

    if (status == 'Menunggu Persetujuan') {
      iconData = FluentIcons.clock_28_regular;
      iconColor = Colors.blue;
    } else if (status == 'Disetujui') {
      iconData = FluentIcons.checkmark_underline_circle_24_regular;
      iconColor = Colors.green;
    } else if (status == 'Ditolak') {
      iconData = FluentIcons.info_48_regular;
      iconColor = Colors.red;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 24,
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Menunggu Persetujuan') {
      return Colors.blue;
    } else if (status == 'Disetujui') {
      return Colors.green;
    } else if (status == 'Ditolak') {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const LeaveFilterScreen();
      },
    );
    _fetchLeaveRequests();
  }

  void _editLeaveRequest(BuildContext context, Leave leave) {
    if (leave.status == 'Menunggu Persetujuan') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LeaveEditScreen(leave: leave)),
      );
    } else {
      // Jika sudah disetujui, tampilkan pesan atau lakukan tindakan yang sesuai
    }
  }

  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('dd/MM/yyyy').format(date) : '';
  }

  String _formatDateWithoutTime(DateTime? date) {
    return date != null ? DateFormat('yyyy-MM-dd').format(date) : '';
  }
}
