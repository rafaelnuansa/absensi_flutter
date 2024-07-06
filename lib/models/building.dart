class Building {
  final int id;
  final String code;
  final String name;
  final String address;
  final String? scanner;

  Building({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    this.scanner,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      address: json['address'],
      scanner: json['scanner'],
    );
  }
}
