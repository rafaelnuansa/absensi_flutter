import 'package:flutter/foundation.dart';

class FilterModel extends ChangeNotifier {
  String? _search;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _status;
  String? _paymentMethod;

  String? get search => _search;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  String? get status => _status;
  String? get paymentMethod => _paymentMethod;

  bool get isFilterApplied =>
      _search != null ||
      _fromDate != null ||
      _toDate != null ||
      _status != null ||
      _paymentMethod != null;

  void setSearch(String? value) {
    _search = value;
    notifyListeners();
  }

  void setFromDate(DateTime? value) {
    _fromDate = value;
    notifyListeners();
  }

  void setToDate(DateTime? value) {
    _toDate = value;
    notifyListeners();
  }

  void setStatus(String? value) {
    _status = value;
    notifyListeners();
  }

  void setPaymentMethod(String? value) {
    _paymentMethod = value;
    notifyListeners();
  }

  void setFilters({
    String? search,
    DateTime? fromDate,
    DateTime? toDate,
    String? status,
    String? paymentMethod,
  }) {
    _search = search;
    _fromDate = fromDate;
    _toDate = toDate;
    _status = status;
    _paymentMethod = paymentMethod;
    notifyListeners();
  }

  void clearFilters() {
    _search = null;
    _fromDate = null;
    _toDate = null;
    _status = null;
    _paymentMethod = null;
    notifyListeners();
  }
}
