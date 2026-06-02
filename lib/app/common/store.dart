import 'package:shared_preferences/shared_preferences.dart';

Future<void> storeToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}

Future<void> storeTokenFCM(String tokenFCM) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('tokenFCM', tokenFCM);
}

Future<void> storeFirebaseUid(String firebaseUid) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('firebase_uid', firebaseUid);
}

Future<void> storeId(int id) async {
  print("ID INI BERHASIL DISIMPAN : $id");
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('id', id);
}

Future<void> storeName(String name) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('name', name);
}

Future<void> storeUserName(String userName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_name', userName);
}

Future<void> storeEmail(String email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('email', email);
}

Future<void> storePhotoProfile(String photoProfile) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('photo_profile', photoProfile);
}

Future<void> storeBio(String bio) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('bio', bio);
}

Future<void> storeIsOnline(int isOnline) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('is_online', isOnline);
}

Future<void> storeLastSeen(String lastSeen) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_seen', lastSeen);
}

Future<void> storeFcmToken(String fcmToken) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('fcm_token', fcmToken);
}
