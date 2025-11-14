import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pcqi_app/services/http_request.dart';

class StatsService {
  static Future<Map<String, dynamic>> getStats() async {
    final response = await HttpRequest.getWithAuthorization("stats");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erro ao buscar estatísticas");
    }
  }
}
