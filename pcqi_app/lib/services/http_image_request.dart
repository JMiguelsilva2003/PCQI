import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class HttpImageRequest {
  Future<void> sendImageBytes(Uint8List imageBytes, String ip) async {
    final request = http.MultipartRequest('POST', Uri.parse(ip));

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'frame_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final response = await request.send();
    print("imagem enviada");

    if (response.statusCode == 200) {
      print('Imagem enviada com sucesso - Tamanho: ${imageBytes.length} bytes');
    } else {
      print('Erro no envio: ${response.statusCode}');
    }
  }
}
