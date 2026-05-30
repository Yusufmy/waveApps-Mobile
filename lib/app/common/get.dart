import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<String?> getFirebaseUid() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('firebase_uid');
}
Future<int?> getId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('id');
}

Future<String?> getName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('name');
}

Future<String?> getEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('email');
}

Future<String?> getPhotoProfile() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('photo_profile');
}

Future<String?> getBio() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('bio');
}

Future<int?> getIsOnline() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('is_online');
}

Future<String?> getLastSeen() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('last_seen');
}

Future<String?> getFcmToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('fcm_token');
}
