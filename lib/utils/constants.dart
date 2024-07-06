class Constants {
  static const String appName = 'Tisen+';
  static const String baseUrl = 'http://192.168.100.7';
  static const String apiUrl = '$baseUrl/api';

  // Auth
  static const String loginUrl = '$apiUrl/login';
  static const String registerUrl = '$apiUrl/register';
  static const String avatarUploadUrl = '$apiUrl/register/avatar';
  static const String fetchPositionsUrl = '$apiUrl/fetch-positions';
  static const String fetchBuildingsUrl = '$apiUrl/fetch-buildings';
  static const String fetchShifts = '$apiUrl/fetch-shifts';
  static const String logoutUrl = '$apiUrl/logout';
  static const String validateTokenUrl = '$apiUrl/validate-token';
  static const String getDashboardUrl = '$apiUrl/dashboard';
  static const String presenceUrl = '$apiUrl/precense';
  static const String historyPresenceUrl = '$apiUrl/history';
  static const String presenceImagePathUrl = '$baseUrl/presence_images/';
  static const String leaveUrl = '$apiUrl/leaves';

  static const String leaveImagePathUrl = '$baseUrl/leaves_images/';
  // Patrol API
  static const String patrolUrl = '$apiUrl/patrols';
  static const String reportUrl = '$apiUrl/patrols/report';
  static const String reportStoreUrl = '$apiUrl/patrols/report_store';
  static const String photoStoreUrl = '$apiUrl/patrols/photo_store';
  static const String reportUpdateUrl = '$apiUrl/patrols/report_update';
  static const String photoUpdateUrl = '$apiUrl/patrols/photo_update';
  static const String checkQRUrl = '$apiUrl/patrols/check-qr';
  static const String profileUrl = '$apiUrl/profile';
  static const String updateAvatarUrl = '$apiUrl/update-avatar';
  static const String updateProfileUrl = '$apiUrl/update';

  static const String storageAvatarUrl = '$baseUrl/storage/avatars';
}
