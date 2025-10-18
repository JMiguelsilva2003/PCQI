import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class CameraImageConverter {
  /*Future<Uint8List?> convertYUV420ToUint8List(CameraImage image) async {
    final Uint8List yPlane = image.planes[0].bytes;
    final Uint8List uPlane = image.planes[1].bytes;
    final Uint8List vPlane = image.planes[2].bytes;
    final Uint8List combinedBytes = Uint8List(
      yPlane.length + uPlane.length + vPlane.length,
    );

    combinedBytes.setAll(0, yPlane);

    combinedBytes.setAll(yPlane.length, uPlane);
    combinedBytes.setAll(yPlane.length + uPlane.length, vPlane);

    return combinedBytes;
  }*/

  Future<Uint8List?> convertYUV420ToUint8List(CameraImage image) async {
    try {
      final width = image.width;
      final height = image.height;

      final yPlane = image.planes[0];
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      final yBytes = yPlane.bytes;
      final uBytes = uPlane.bytes;
      final vBytes = vPlane.bytes;

      final nv21 = Uint8List(width * height + uBytes.length + vBytes.length);

      // Copia Y
      nv21.setRange(0, yBytes.length, yBytes);

      // Intercala VU
      int offset = yBytes.length;
      for (int i = 0; i < uBytes.length; i++) {
        nv21[offset++] = vBytes[i]; // V
        nv21[offset++] = uBytes[i]; // U
      }

      return nv21;
    } catch (e) {
      print("Erro na conversão NV21: $e");
      return null;
    }
  }

  Future<Uint8List?> convertImage(CameraImage cameraImage) async {
    try {
      final image = convertCameraImage(cameraImage);

      final resizedImage = img.copyResize(
        image,
        width: 640,
        height: 480,
        maintainAspect: true,
      );

      final jpegBytes = img.encodeJpg(resizedImage, quality: 70);

      return jpegBytes;
    } catch (e) {
      print('Error while processing image: $e');
      return null;
    }
  }

  img.Image convertCameraImage(CameraImage cameraImage) {
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420ToImage(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      return _convertBGRA8888ToImage(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.jpeg) {
      return img.decodeImage(cameraImage.planes[0].bytes)!;
    }
    throw Exception('Image type not supported');
  }

  // YUV420 to image converter (Android)
  img.Image _convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final yPlane = cameraImage.planes[0];
    final uPlane = cameraImage.planes[1];
    final vPlane = cameraImage.planes[2];

    final image = img.Image(width: width, height: height);

    final effectiveHeight = (yPlane.bytes.length / yPlane.bytesPerRow)
        .floor()
        .clamp(0, height);
    final effectiveWidth = (yPlane.bytesPerRow).clamp(0, width);

    for (var y = 0; y < effectiveHeight; y++) {
      for (var x = 0; x < effectiveWidth; x++) {
        final yIndex = y * yPlane.bytesPerRow + x;
        final uvX = x ~/ 2;
        final uvY = y ~/ 2;
        final uvIndex = uvY * uPlane.bytesPerRow + uvX;

        final yValue = yPlane.bytes[yIndex].toDouble();
        final uValue = uPlane.bytes[uvIndex].toDouble() - 128;
        final vValue = vPlane.bytes[uvIndex].toDouble() - 128;

        final r = (yValue + 1.402 * vValue).clamp(0, 255).toInt();
        final g = (yValue - 0.344136 * uValue - 0.714136 * vValue)
            .clamp(0, 255)
            .toInt();
        final b = (yValue + 1.772 * uValue).clamp(0, 255).toInt();

        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return image;
  }

  /* // Testing conversion
  img.Image _convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final yPlane = cameraImage.planes[0];
    final uPlane = cameraImage.planes[1];
    final vPlane = cameraImage.planes[2];

    final image = img.Image(width: width, height: height);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final yIndex = (y * yPlane.bytesPerRow) + x;
        final uvX = x ~/ 2;
        final uvY = y ~/ 2;
        final uvIndex = (uvY * uPlane.bytesPerRow) + uvX;

        
        if (yIndex >= yPlane.bytes.length ||
            uvIndex >= uPlane.bytes.length ||
            uvIndex >= vPlane.bytes.length) {
          continue; 
        }

        final yPixel = yPlane.bytes[yIndex].toDouble();
        final uPixel = uPlane.bytes[uvIndex].toDouble() - 128.0;
        final vPixel = vPlane.bytes[uvIndex].toDouble() - 128.0;

        final r = (yPixel + 1.370705 * vPixel).clamp(0, 255).toInt();
        final g = (yPixel - 0.337633 * uPixel - 0.698001 * vPixel)
            .clamp(0, 255)
            .toInt();
        final b = (yPixel + 1.732446 * uPixel).clamp(0, 255).toInt();

        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return image;
  }*/

  // BGRA8888 to image converter (iOS)
  img.Image _convertBGRA8888ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;
    final bytes = cameraImage.planes[0].bytes;

    final image = img.Image(width: width, height: height);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final index = (y * width + x) * 4;
        final b = bytes[index];
        final g = bytes[index + 1];
        final r = bytes[index + 2];
        final a = bytes[index + 3];

        image.setPixelRgba(x, y, r, g, b, a);
      }
    }

    return image;
  }
}
