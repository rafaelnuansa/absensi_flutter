import 'dart:io';

import 'package:absensi/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:absensi/api/leave_api.dart';
import 'package:absensi/models/leave.dart';
import 'package:absensi/providers/leave_provider.dart';

class LeaveEditScreen extends StatefulWidget {
  final Leave leave;

  const LeaveEditScreen({super.key, required this.leave});

  @override
  LeaveEditScreenState createState() => LeaveEditScreenState();
}

class LeaveEditScreenState extends State<LeaveEditScreen> {
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _startWorkingDateController;
  late TextEditingController _totalDaysController;
  late TextEditingController _reasonController;
  String? _selectedType;
  String? _selectedImagePath;
  String? _urlImagePath;

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController(text: widget.leave.startDate);
    _endDateController = TextEditingController(text: widget.leave.endDate);
    _startWorkingDateController =
        TextEditingController(text: widget.leave.dateWork);
    _totalDaysController =
        TextEditingController(text: widget.leave.total.toString());
    _reasonController = TextEditingController(text: widget.leave.reason);
    _selectedType = widget.leave.type;
    _selectedImagePath;
    _urlImagePath = widget.leave.image;
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImagePath = pickedImage.path;
      });
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
          'Edit Request',
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
              'Tanggal Mulai',
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
                  _startDateController.text = _formatDate(picked);
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: _startDateController,
                  decoration: const InputDecoration(
                    hintText: 'Tanggal Mulai Cuti',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tanggal Selesai',
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
                  _endDateController.text = _formatDate(picked);
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: _endDateController,
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
                  _startWorkingDateController.text = _formatDate(picked);
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: _startWorkingDateController,
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
              controller: _totalDaysController,
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
                  child: RadioListTile<String>(
                    title: const Text('Sick'),
                    value: 'sick',
                    groupValue: _selectedType,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Izin/Cuti'),
                    value: 'leave',
                    groupValue: _selectedType,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Alasan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: 'Alasan',
              ),
              maxLength: 250,
            ),
            const SizedBox(height: 20),
            if (_urlImagePath != null && _urlImagePath!.isNotEmpty) ...[
              const Text('Gambar Sebelumnya:'),
              Image.network(
                '${Constants.baseUrl}/$_urlImagePath',
                height: 100,
              ),
              const SizedBox(height: 20),
            ] else ...[
              const Text('Tidak ada file/gambar'),
              const SizedBox(height: 20),
            ],
            const SizedBox(height: 20),
            if (_selectedImagePath != null &&
                _selectedImagePath!.isNotEmpty) ...[
              Image.file(
                File(_selectedImagePath!),
                height: 100,
              ),
              const SizedBox(height: 20),
            ] else ...[
              const Text('Pilih Gambar/Screenshoot'),
              const SizedBox(height: 20),
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
                    id: widget.leave.id,
                    startDate: _startDateController.text,
                    endDate: _endDateController.text,
                    dateWork: _startWorkingDateController.text,
                    total:
                        int.parse(_totalDaysController.text), // Convert to int
                    reason: _reasonController.text,
                    type: _selectedType,
                    image: _selectedImagePath,
                  );

                  // Panggil metode updateLeave dari LeaveApi
                  try {
                    final Uint8List imageBytes = _selectedImagePath != null
                        ? await File(_selectedImagePath!).readAsBytes()
                        : Uint8List(0);

                    await LeaveApi.updateLeave(
                        widget.leave.id!, leave, imageBytes);

                    // Ambil kembali daftar leaves setelah pembaruan berhasil
                    List<Leave> updatedLeaves = await LeaveApi.fetchLeaves();

                    // Setelah pembaruan berhasil, beritahu provider bahwa data telah diperbarui
                    Provider.of<LeaveProvider>(context, listen: false)
                        .setLeaves(updatedLeaves);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Leave updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update leave: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Update'),
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
