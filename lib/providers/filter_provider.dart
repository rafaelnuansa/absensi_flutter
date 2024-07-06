import 'package:flutter/material.dart';

class FilterProvider extends ChangeNotifier {
  late DateTime _startDate;
  late DateTime _endDate;

  FilterProvider() {
    // Set default values for start date and end date
    _startDate = DateTime.now();
    _endDate = DateTime.now();
  }

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  void setStartDate(DateTime date) {
    _startDate = date;
    notifyListeners(); // Notify listeners when the start date is updated
  }

  void setEndDate(DateTime date) {
    _endDate = date;
    notifyListeners(); // Notify listeners when the end date is updated
  }
}
