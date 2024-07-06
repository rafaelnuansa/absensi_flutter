import 'package:flutter/material.dart';

// Model untuk menyimpan informasi foto patroli
class PatrolPhoto {
  final String fileName; // Nama file unik
  final String path; // Path lokasi file foto

  PatrolPhoto(this.fileName, this.path);
}

class PatrolPhotosProvider with ChangeNotifier {
  final List<PatrolPhoto> _patrolPhotos = []; // Daftar foto patroli

  // Getter untuk mengambil daftar foto patroli
  List<PatrolPhoto> get patrolPhotos => [..._patrolPhotos];

  // Method untuk menambahkan foto patroli ke dalam daftar
  void addPhoto(String fileName, String path) {
    _patrolPhotos.add(PatrolPhoto(fileName, path));
    notifyListeners(); // Memberitahukan perubahan data kepada listener
  }

  // Method untuk menghapus foto patroli dari daftar berdasarkan path
  void removePhoto(String path) {
    _patrolPhotos.removeWhere((photo) => photo.path == path);
    notifyListeners(); // Memberitahukan perubahan data kepada listener
  }

  // Method untuk membersihkan daftar foto patroli
  void clearPhotos() {
    _patrolPhotos.clear();
    notifyListeners(); // Memberitahukan perubahan data kepada listener
  }
}
