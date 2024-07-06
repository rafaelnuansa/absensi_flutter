class Patrol {
  int? id;
  int? employeeId;
  int? checkpointId;
  DateTime? date;
  String? time;
  String? information;
  String? latitude;
  String? longitude;
  String? status;

  Patrol({
    this.id,
    this.employeeId,
    this.checkpointId,
    this.date,
    this.time,
    this.information,
    this.latitude,
    this.longitude,
    this.status,
  });

  factory Patrol.fromJson(Map<String, dynamic> json) {
    return Patrol(
      id: json['id'],
      employeeId: json['employee_id'],
      checkpointId: json['checkpoint_id'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      information: json['information'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      status: json['status'],
    );
  }
}
