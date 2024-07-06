class Shift {
  final int id;
  final String name;
  final String timeIn;
  final String timeOut;

  Shift({
    required this.id,
    required this.name,
    required this.timeIn,
    required this.timeOut,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'],
      name: json['name'],
      timeIn: json['time_in'],
      timeOut: json['time_out'],
    );
  }
}
