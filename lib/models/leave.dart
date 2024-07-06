class Leave {
  final int? id;
  final int? employeeId;
  final String? startDate;
  final String? endDate;
  final String dateWork;
  final int? total;
  final String? image; // Menambahkan atribut image
  final String? type; // Menambahkan atribut type
  final String reason;
  final String? status;
  final String? comment;

  Leave({
    this.id,
    this.employeeId,
    this.startDate,
    this.endDate,
    required this.dateWork,
    required this.total,
    this.image,
    this.type,
    required this.reason,
    this.status,
    this.comment,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'] ?? 0,
      employeeId: json['employee_id'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      dateWork: json['date_work'] ?? '',
      total: json['total'] ?? 0,
      image: json['image'] ?? '', // Mendapatkan atribut image dari JSON
      type: json['type'] ?? '', // Mendapatkan atribut type dari JSON
      reason: json['reason'] ?? '',
      status: _getStatusFromJson(json['status'] ?? ''),
      comment: json['comment'] ?? '',
    );
  }

  static String _getStatusFromJson(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Menunggu Persetujuan';
    }
  }
}
