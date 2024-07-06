import 'position.dart';
import 'building.dart';

class Profile {
  final String id;
  final String code;
  final String email;
  final String name;
  final Position position;
  final Building building;
  final String avatarUrl;

  Profile({
    required this.id,
    required this.code,
    required this.email,
    required this.name,
    required this.position,
    required this.building,
    required this.avatarUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      code: json['code'],
      email: json['email'],
      name: json['name'],
      position: Position.fromJson(json['position']),
      building: Building.fromJson(json['building']),
      avatarUrl: json['avatar_url'],
    );
  }
}
