import 'package:absensi/models/presence.dart';
import 'package:flutter/material.dart';

class PresenceFilterProvider extends ChangeNotifier {
  List<Presence> _presences = [];
  List<Presence> _filteredPresences = [];
  DateTime? _startDate; // Change to nullable DateTime
  DateTime? _endDate; // Change to nullable DateTime
  List<Presence> get presences => _presences;
  List<Presence> get filteredPresences => _filteredPresences;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  PresenceFilterProvider() {
    _startDate = null; // Set initial start date to null
    _endDate = null; // Set initial end date to null
  }

  void setPresences(List<Presence> presences) {
    _presences = presences;
    _filteredPresences = _presences;
    notifyListeners();
  }

  void setFilter(DateTime? startDate, DateTime? endDate) {
    _startDate = startDate;
    _endDate = endDate;
    _filterPresences();
    notifyListeners();
  }

  void clearFilter() {
    _startDate = null; // Set start date back to null
    _endDate = null; // Set end date back to null
    _filterPresences(); // Re-filter the presence list
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

  void _filterPresences() {
    _filteredPresences = _presences.where((presence) {
      if (_startDate == null || _endDate == null) {
        // If start date or end date is null, then ignore the filter
        return true;
      }
      final presenceStartDate = DateTime.parse(presence.date);
      return presenceStartDate.isAfter(_startDate!) &&
          presenceStartDate.isBefore(_endDate!);
    }).toList();
  }
}
