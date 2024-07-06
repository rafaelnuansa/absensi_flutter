import 'package:absensi/models/building.dart';
import 'package:absensi/models/patrol.dart'; // Import the Patrol model

class Checkpoint {
  int id;
  String name;
  String? code;
  String? description;
  int? buildingId;
  String? qrcode;
  final Building building;
  List<Patrol> patrols; // List of Patrols associated with this Checkpoint

  Checkpoint({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.buildingId,
    this.qrcode,
    required this.building,
    required this.patrols, // Initialize patrols list in the constructor
  });

  factory Checkpoint.fromJson(Map<String, dynamic> json) {
    // Extract patrols from the JSON data
    List<dynamic> patrolList = json['patrols'] ?? [];
    List<Patrol> patrols = patrolList.map((patrolJson) => Patrol.fromJson(patrolJson)).toList();

    return Checkpoint(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      buildingId: json['building_id'],
      qrcode: json['qrcode'],
      building: Building.fromJson(json['building']),
      patrols: patrols, // Assign the parsed patrols list
    );
  }
}
