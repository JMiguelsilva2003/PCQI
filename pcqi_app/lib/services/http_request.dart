import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pcqi_app/services/shared_preferences_helper.dart';

class HttpRequest {
  static const String url = "https://pcqi-api.onrender.com/api/v1";
  static final timeoutSeconds = Duration(seconds: 20);

  static post(String endpoint, Map<String, dynamic> jsonBody) async {
    var urlSend = Uri.parse("$url/$endpoint");
    return http
        .post(
          urlSend,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(jsonBody),
        )
        .timeout(timeoutSeconds);
  }

  static postWithAuthorization(String method, [String? additionalInfo]) async {
    var urlSend = Uri.parse("$url/$method");

    final token = SharedPreferencesHelper.getAccessToken();

    var response = await http
        .post(urlSend, headers: {"Authorization": "Bearer $token"})
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

    return http
        .post(
          urlSend,
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: encodedBody,
        )
        .timeout(timeoutSeconds);
  }

  /// ✅ GET com token (sectors / machines)
  static Future getWithAuthorization(String endpoint) async {
    final token = SharedPreferencesHelper.getAccessToken();

    var urlSend = Uri.parse("$url/$endpoint/");
    return http
        .get(urlSend, headers: {"Authorization": "Bearer $token"})
        .timeout(timeoutSeconds);
  }

  /// ✅ POST com token (create machine)
  static Future postWithAuthorizationJson(
    String endpoint,
    Map<String, dynamic> jsonBody,
  ) async {
    final token = SharedPreferencesHelper.getAccessToken();

    var urlSend = Uri.parse("$url/$endpoint");
    return http
        .post(
          urlSend,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(jsonBody),
        )
        .timeout(timeoutSeconds);
  }

  /// ✅ DELETE com token (delete machine)
  static Future deleteWithAuthorization(String endpoint) async {
    final token = SharedPreferencesHelper.getAccessToken();

    var urlSend = Uri.parse("$url/$endpoint");
    return http
        .delete(urlSend, headers: {"Authorization": "Bearer $token"})
        .timeout(timeoutSeconds);
  }
}
