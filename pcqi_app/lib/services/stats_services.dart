import 'dart:convert';
import 'package:http/http.dart' as http;

class StatsService {
  static const String _baseUrl = "https://pcqi-api.onrender.com/api/v1/stats";

  static Future<Map<String, dynamic>> getStats() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erro ao buscar estatísticas: ${response.statusCode}");
    }
  }
}
