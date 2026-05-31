import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wive_app/app/common/get.dart';

class Api {
  static const String baseUrl = 'http://192.168.0.105:8080/api/';
  static const String publicUrl = 'http://192.168.0.105:8080/';

  ///AUTH
  static const String loginUrl = '${baseUrl}login';
  static const String registerUrl = '${baseUrl}register';
  static const String logoutUrl = '${baseUrl}logout';

  ///USER (PROFILE)
  static const String profileUrl = '${baseUrl}profile';
  static const String userAllUrl = '${baseUrl}users';

  ///USER (CHAT)
  static const String conversationsUrl = '${baseUrl}conversations';
  static const String messagesUrl = '${baseUrl}messages';

  ///USER (STORY)
  static const String storiesUrl = '${baseUrl}/stories';

  ///USER (CALL)
  static const String callUrl = '${baseUrl}calls/start';

  static Future<http.Response> login(var body) async {
    final request = http.post(
      Uri.parse(loginUrl),
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $token'
      },
      body: jsonEncode(body),
    );

    final response = await request;

    return response;
  }

  static Future<http.Response> logout() async {
    final token = await getToken();
    final request = http.post(
      Uri.parse(logoutUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final response = await request;

    return response;
  }

  static Future<http.Response> register(var body) async {
    // final token = await getToken();
    final request = http.post(
      Uri.parse(registerUrl),
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final response = await request;

    return response;
  }

  static Future<http.Response> getProfile() async {
    final token = await getToken();

    final request = http.get(
      Uri.parse(profileUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final response = await request;

    return response;
  }

  static Future<http.Response> updateProfile(var body) async {
    final token = await getToken();

    final request = http.patch(
      Uri.parse(profileUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final response = await request;

    return response;
  }

  static Future<http.StreamedResponse> uploadProfile(String imagePath) async {
    final token = await getToken();

    var request = http.MultipartRequest('POST', Uri.parse("$profileUrl/photo"));

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(await http.MultipartFile.fromPath('photo', imagePath));

    return await request.send();
  }
}
