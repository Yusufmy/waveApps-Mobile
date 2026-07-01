import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:wive_app/app/common/get.dart';

class Api {
  static const String baseUrl = 'http://192.168.0.101:8080/api/';
  static const String publicUrl = 'http://192.168.0.101:8080/';

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
  static const String readMessagesUrl = '${baseUrl}read';
  static const String deliveredMessagesUrl = '${baseUrl}messages-delivered';

  ///USER (STORY)
  static const String storiesUrl = '${baseUrl}stories';

  ///USER (CALL)
  static const String callUrl = '${baseUrl}calls';

  ///TOKEN FCM
  static const String fcmUrl = '${baseUrl}save-fcm-token';

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

  static Future<http.Response> postFcm(var body) async {
    final token = await getToken();

    final request = http.post(
      Uri.parse(fcmUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
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

  static Future<http.Response> getSearchUser(var param) async {
    final token = await getToken();
    final finalParam = param ?? "";

    final request = http.get(
      Uri.parse("$userAllUrl?search=$finalParam"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final response = await request;

    return response;
  }

  static Future<http.Response> getConversations() async {
    final token = await getToken();

    final request = http.get(
      Uri.parse(conversationsUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final response = await request;

    return response;
  }

  static Future<http.Response> postConversations(var body) async {
    final token = await getToken();

    final request = http.post(
      Uri.parse(conversationsUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final response = await request;

    return response;
  }

  static Future<http.StreamedResponse> sendMessage({
    required String conversationId,
    required String messageType,

    String message = "",
    File? file,
    int? duration,
  }) async {
    final token = await getToken();

    final request = http.MultipartRequest("POST", Uri.parse(messagesUrl));

    request.headers["Authorization"] = "Bearer $token";

    request.fields["conversation_id"] = conversationId;
    request.fields["message_type"] = messageType;
    request.fields["message"] = message;

    if (duration != null) {
      request.fields["duration"] = duration.toString();
    }

    if (file != null) {
      request.files.add(
        await http.MultipartFile.fromPath("attachment_url", file.path),
      );
    }
    print("FILE EXISTS = ${await file?.exists()}");
    print("FILE PATH   = ${file?.path}");
    print("FILE SIZE   = ${await file?.length()}");

    return request.send();
  }

  static Future<http.Response> readMessage(var conversationId) async {
    final token = await getToken();
    final finalConversationUrl = conversationId ?? "";

    final request = http.post(
      Uri.parse("$readMessagesUrl/$finalConversationUrl"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final response = await request;

    return response;
  }

  static Future<http.Response> deliveredMessage(var body) async {
    final token = await getToken();

    final request = http.post(
      Uri.parse(deliveredMessagesUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final response = await request;

    return response;
  }

  static Future<http.Response> startCallUrl(var body) async {
    final token = await getToken();

    final request = http.post(
      Uri.parse("$callUrl/start"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    final response = await request;

    return response;
  }

  static Future<http.Response> acceptCallUrl(var id) async {
    final token = await getToken();

    final request = http.post(
      Uri.parse("$callUrl/$id/accept"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final response = await request;

    return response;
  }

  static Future<http.Response> rejectCallUrl(var id) async {
    final token = await getToken();

    final request = http.post(
      Uri.parse("$callUrl/$id/reject"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final response = await request;

    return response;
  }

  static Future<http.Response> endCallUrl(var id) async {
    final token = await getToken();

    final request = http.post(
      Uri.parse("$callUrl/$id/end"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final response = await request;

    return response;
  }

  static Future<http.Response> getHistoryCallUrl() async {
    final token = await getToken();

    final request = http.get(
      Uri.parse("$callUrl/history"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final response = await request;

    return response;
  }

  static Future<http.StreamedResponse> postStory({
    required File file,
    String? caption,
  }) async {
    final token = await getToken();

    var request = http.MultipartRequest('POST', Uri.parse(storiesUrl));

    request.headers.addAll({'Authorization': 'Bearer $token'});

    request.fields['caption'] = caption ?? '';

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    return await request.send();
  }

  static Future<http.Response> getListStory() async {
    final token = await getToken();

    final request = http.get(
      Uri.parse(storiesUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final response = await request;

    return response;
  }

  static Future<http.Response> getDetailStory(var id) async {
    final token = await getToken();
    final idStory = id ?? "";

    final request = http.get(
      Uri.parse("$storiesUrl/$idStory"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final response = await request;

    return response;
  }

  static Future<http.Response> deleteDetailStory(var id) async {
    final token = await getToken();
    final idStory = id ?? "";

    final request = http.delete(
      Uri.parse("$storiesUrl/$idStory"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final response = await request;

    return response;
  }

  static Future<http.Response> getMeStory() async {
    final token = await getToken();

    final request = http.get(
      Uri.parse("$storiesUrl/me"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final response = await request;

    return response;
  }
}
