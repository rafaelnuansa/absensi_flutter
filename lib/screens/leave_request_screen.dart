import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:absensi/api/leave_api.dart';
import 'package:absensi/models/leave.dart';
import 'package:absensi/providers/leave_provider.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  LeaveRequestScreenState createState() => LeaveRequestScreenState();
}

class LeaveRequestScreenState extends State<LeaveRequestScreen> {
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController startWorkingDateController = TextEditingController();
  TextEditingController totalDaysController = TextEditingController();
  TextEditingController reasonController = TextEditingController();

  String? selectedType;
  String? imagePath;

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        imagePath = pickedImage.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Create Request',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Tanggal Mulai Cuti',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2022),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  startDateController.text = _formatDate(picked);
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: startDateController,
                  decoration: const InputDecoration(
                    hintText: 'Tanggal Mulai Cuti',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tanggal Selesai Cuti',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2022),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  endDateController.text = _formatDate(picked);
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: endDateController,
                  decoration: const InputDecoration(
                    hintText: 'Tanggal Selesai Cuti',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tanggal Mulai Bekerja Kembali',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2022),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  startWorkingDateController.text = _formatDate(picked);
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: startWorkingDateController,
                  decoration: const InputDecoration(
                    hintText: 'Tanggal Mulai Bekerja Kembali',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Total Hari Cuti',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: totalDaysController,
              decoration: const InputDecoration(
                hintText: 'Total Hari Cuti',
              ),
              keyboardType:
                  TextInputType.number, // Hanya memungkinkan input angka
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter
                    .digitsOnly // Hanya memungkinkan angka
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Jenis Cuti',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Radio<String>(
                        value: 'sick',
                        groupValue: selectedType,
                        onChanged: (value) {
                          setState(() {
                            selectedType = value;
                          });
                        },
                      ),
                      const Text('Sakit'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Radio<String>(
                        value: 'leave',
                        groupValue: selectedType,
                        onChanged: (value) {
                          setState(() {
                            selectedType = value;
                          });
                        },
                      ),
                      const Text('Izin/Cuti'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Alasan Cuti',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Alasan Cuti',
              ),
              maxLength: 250,
            ),
            const SizedBox(height: 20),
            if (imagePath != null) ...[
              Image.file(
                File(imagePath!),
                height: 100,
              ),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectImage,
                child: const Text('Browse'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final leave = Leave(
                    startDate: startDateController.text,
                    endDate: endDateController.text,
                    dateWork: startWorkingDateController.text,
                    total: int.parse(totalDaysController.text),
                    reason: reasonController.text,
                    type: selectedType,
                    image: imagePath,
                  );

                  try {
                    final imageData = imagePath != null
                        ? File(imagePath!).readAsBytesSync()
                        : null;

                    await LeaveApi.createLeave(
                        leave, imageData ?? Uint8List(0));

                    // Ambil daftar cuti terbaru setelah menyimpan
                    List<Leave> updatedLeaves = await LeaveApi.fetchLeaves();

                    // Perbarui daftar cuti yang dikelola oleh Provider
                    Provider.of<LeaveProvider>(context, listen: false)
                        .setLeaves(updatedLeaves);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Request submitted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to submit request: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}
