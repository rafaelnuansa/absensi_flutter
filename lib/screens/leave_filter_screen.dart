import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:absensi/providers/leave_provider.dart';

class LeaveFilterScreen extends StatefulWidget {
  const LeaveFilterScreen({super.key});

  @override
  LeaveFilterScreenState createState() => LeaveFilterScreenState();
}

class LeaveFilterScreenState extends State<LeaveFilterScreen> {
  late LeaveProvider _leaveProvider;

  @override
  void initState() {
    super.initState();
    _leaveProvider = Provider.of<LeaveProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Filter Leaves',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _clearFilter,
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelector('Tanggal Awal', true),
            const SizedBox(height: 20),
            _buildDateSelector('Tanggal Akhir', false),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilter,
                  child: const Text(
                    'Apply Filter',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(String label, bool isStartDate) {
    final DateTime? currentDate =
        isStartDate ? _leaveProvider.startDate : _leaveProvider.endDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, isStartDate),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(currentDate),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final LeaveProvider leaveProvider =
        Provider.of<LeaveProvider>(context, listen: false);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? leaveProvider.startDate ?? DateTime.now()
          : leaveProvider.endDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          leaveProvider.setStartDate(picked);
        } else {
          leaveProvider.setEndDate(picked);
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Select Date';
  }

  void _clearFilter() {
    _leaveProvider.clearFilter();
    Navigator.pop(context);
  }

  void _applyFilter() {
    _leaveProvider.applyFilter();
    Navigator.pop(context);
  }
}
