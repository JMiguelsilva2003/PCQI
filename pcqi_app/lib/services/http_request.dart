import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pcqi_app/services/shared_preferences_helper.dart';

class HttpRequest {
  static final url = "https://pcqi-api.onrender.com/api/v1";
  static final timeoutSeconds = Duration(seconds: 20);

  static post(String method, jsonBody) async {
    var urlSend = Uri.parse("$url/$method");

    var response = await http
        .post(
          urlSend,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(jsonBody),
        )
        .timeout(timeoutSeconds);

    return response;
  }

  static postFormUrlEncoded(
    String method,
    Map<String, String> requestData,
  ) async {
    var urlSend = Uri.parse("$url/$method");
    String encodedBody = requestData.keys
        .map((key) => "$key=${requestData[key]}")
        .join('&');

    var response = await http
        .post(
          urlSend,
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: encodedBody,
        )
        .timeout(timeoutSeconds);

    return response;
  }

  static getWithAuthorization(String method) async {
    var urlSend = Uri.parse("$url/$method");
    final token = SharedPreferencesHelper.getAccessToken();

    var response = await http
        .get(urlSend, headers: {"Authorization": "Bearer $token"})
        .timeout(timeoutSeconds);

    return response;
  }

  static get(String method, String additionalInfo) async {
    var urlSend = Uri.parse("$url/$method/$additionalInfo");
    var response = await http.get(urlSend).timeout(timeoutSeconds);
    return response;
  }
}
