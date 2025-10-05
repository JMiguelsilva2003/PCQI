import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:pcqi_app/models/image_request_response_model.dart';

class HttpImageRequest {
  Future<ImageRequestResponseModel?> sendImage(
    Uint8List imageBytes,
    String ip,
  ) async {
    try {
      final finalUrl = "$ip/predict";
      final request = http.MultipartRequest('POST', Uri.parse(finalUrl));

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'frame_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final Map<String, dynamic> jsonMap = jsonDecode(responseString);
        try {
          ImageRequestResponseModel responseModel =
              ImageRequestResponseModel.fromJson(jsonMap);
          return responseModel;
        } catch (e) {
          return null;
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
