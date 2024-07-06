// ignore_for_file: avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // Meminta izin untuk menerima notifikasi
    await _firebaseMessaging.requestPermission();

    // Mendapatkan FCM token
    final fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token : $fcmToken');

    // Mendengarkan pesan masuk saat aplikasi sedang di background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Mendengarkan pesan masuk saat aplikasi berjalan di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.title}');
      // Tampilkan notifikasi jika aplikasi sedang berjalan
      // Gunakan library lain untuk menampilkan notifikasi jika aplikasi tidak berjalan
    });

    // Mendengarkan pesan yang tiba saat aplikasi di foreground
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened app: ${message.notification?.title}');
      // Navigasi ke halaman yang sesuai berdasarkan payload notifikasi jika perlu
    });
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
    // Lakukan penanganan pesan di sini, seperti menyimpan data ke local storage
  }
}
