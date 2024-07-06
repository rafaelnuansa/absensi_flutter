class Presence {
  final int id;
  final int employeeId;
  final String date;
  final String? timeIn;
  final String? timeOut;
  final String? pictureIn;
  final String? pictureOut;
  final String? latitudeLongitudeIn;
  final String? latitudeLongitudeOut;
  final String status;
  final String? information;
  final String createdAt;
  final String updatedAt;

  Presence({
    required this.id,
    required this.employeeId,
    required this.date,
    this.timeIn,
    this.timeOut,
    this.pictureIn,
    this.pictureOut,
    this.latitudeLongitudeIn,
    this.latitudeLongitudeOut,
    required this.status,
    this.information,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Presence.fromJson(Map<String, dynamic> json) {
    return Presence(
      id: json['id'],
      employeeId: json['employee_id'],
      date: json['date'],
      timeIn: json['time_in'],
      timeOut: json['time_out'],
      pictureIn: json['picture_in'],
      pictureOut: json['picture_out'],
      latitudeLongitudeIn: json['latitude_longitude_in'],
      latitudeLongitudeOut: json['latitude_longitude_out'],
      status: json['status'],
      information: json['information'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
