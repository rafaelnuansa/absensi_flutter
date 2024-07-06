import 'package:absensi/models/leave.dart';
import 'package:flutter/foundation.dart';

class LeaveFilterProvider extends ChangeNotifier {
  DateTime? _startDate; // Inisialisasi dengan null
  DateTime? _endDate; // Inisialisasi dengan null
  final List<Leave> _leaves = []; // Add this line
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  List<Leave> get filteredLeaves => _leaves; // Add this line

  void setStartDate(DateTime? startDate) {
    _startDate = startDate;
    notifyListeners();
  }

  void setEndDate(DateTime? endDate) {
    _endDate = endDate;
    notifyListeners();
  }

  void clearFilter() {
    _startDate = null; // Atur kembali ke null saat membersihkan filter
    _endDate = null; // Atur kembali ke null saat membersihkan filter
    notifyListeners();
  }

  void setFilter(DateTime? startDate, DateTime? endDate, List<Leave> leaves) {
    _startDate = startDate;
    _endDate = endDate;

    if (startDate != null && endDate != null) {
      _leaves.clear(); // Bersihkan daftar cuti sebelum menerapkan filter baru
      _leaves.addAll(leaves.where((leave) {
        final leaveStartDate = DateTime.parse(leave.startDate!);
        final leaveEndDate = DateTime.parse(leave.endDate!);
        return leaveStartDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            leaveEndDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList());
    }

    notifyListeners();
  }
}
