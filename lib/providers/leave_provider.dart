import 'package:flutter/material.dart';
import 'package:absensi/models/leave.dart';

class LeaveProvider extends ChangeNotifier {
  List<Leave> _leaves = [];
  List<Leave> _filteredLeaves = [];
  DateTime? _startDate; // Ubah menjadi nullable DateTime
  DateTime? _endDate; // Ubah menjadi nullable DateTime

  List<Leave> get leaves => _leaves;
  List<Leave> get filteredLeaves => _filteredLeaves;

  DateTime? get startDate => _startDate; // Ubah tipe pengembalian
  DateTime? get endDate => _endDate; // Ubah tipe pengembalian

  LeaveProvider() {
    _startDate = null; // Set tanggal awal menjadi null di awal
    _endDate = null; // Set tanggal akhir menjadi null di awal
  }

  void setLeaves(List<Leave> leaves) {
    _leaves = leaves;
    _filteredLeaves = _leaves;
    _applyFilter(); // Apply filter saat daftar cuti diperbarui
    notifyListeners();
  }

  void setFilter(DateTime? startDate, DateTime? endDate) {
    _startDate = startDate;
    _endDate = endDate;
    _applyFilter();
    notifyListeners();
  }

  void setStartDate(DateTime? startDate) {
    _startDate = startDate;
    notifyListeners();
  }

  void setEndDate(DateTime? endDate) {
    _endDate = endDate;
    notifyListeners();
  }

  void clearFilter() {
    _startDate = null; // Atur tanggal awal kembali ke null
    _endDate = null; // Atur tanggal akhir kembali ke null
    _applyFilter(); // Apply filter saat filter dibersihkan
    notifyListeners();
  }

  void _applyFilter() {
    _filteredLeaves = _leaves.where((leave) {
      if (_startDate == null || _endDate == null) {
        // Jika tanggal awal atau akhir adalah null, maka abaikan filter
        return true;
      }
      final leaveStartDate = DateTime.parse(leave.startDate!);
      final leaveEndDate = DateTime.parse(leave.endDate!);
      return leaveStartDate
              .isAfter(_startDate!.subtract(const Duration(days: 1))) &&
          leaveEndDate.isBefore(_endDate!.add(const Duration(days: 1)));
    }).toList();
  }

  void applyFilter() {
    _filteredLeaves = _leaves.where((leave) {
      if (_startDate == null || _endDate == null) {
        // Jika tanggal awal atau akhir adalah null, maka abaikan filter
        return true;
      }
      final leaveStartDate = DateTime.parse(leave.startDate!);
      final leaveEndDate = DateTime.parse(leave.endDate!);
      return leaveStartDate
              .isAfter(_startDate!.subtract(const Duration(days: 1))) &&
          leaveEndDate.isBefore(_endDate!.add(const Duration(days: 1)));
    }).toList();
  }
}
