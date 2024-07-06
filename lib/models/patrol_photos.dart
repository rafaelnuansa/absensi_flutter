import 'package:camera/camera.dart';

class PatrolPhotos {
  List<XFile> photos;

  PatrolPhotos({required this.photos});

  void add(XFile photo) {
    photos.add(photo);
  }

  void removePhoto(int index) {
    photos.removeAt(index);
  }

  void clearPhotos() {
    photos.clear();
  }
}
