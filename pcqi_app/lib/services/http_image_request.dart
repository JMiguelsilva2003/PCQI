import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:pcqi_app/models/image_request_response_model.dart';

class HttpImageRequest {
  final urlCameraRequest = "https://miguel15468-pcqi-ai-api.hf.space/predict";

  Future<ImageRequestResponseModel?> sendImage(
    Uint8List imageBytes /*
    int height,
    int width,*/,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(urlCameraRequest),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'frame_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpg'),
        ),
      );

      //request.fields['width'] = width.toString();
      //request.fields['height'] = height.toString();

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final Map<String, dynamic> jsonMap = jsonDecode(responseString);
        try {
          ImageRequestResponseModel responseModel =
              ImageRequestResponseModel.fromJson(jsonMap);
          return responseModel;
        } catch (e) {
          print(e);
          return null;
        }
      }
    } catch (e) {
      print(e);
      return null;
    }
    return null;
  }
}
