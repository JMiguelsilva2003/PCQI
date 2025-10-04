import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class CameraImageConverter {
  Future<Uint8List?> convertImage(CameraImage cameraImage) async {
    try {
      final image = convertCameraImage(cameraImage);

      // Redimensiona e comprime
      final resizedImage = img.copyResize(
        image,
        width: 640,
        height: 480,
        maintainAspect: true,
      );

      // Converte para JPEG em memória
      final jpegBytes = img.encodeJpg(resizedImage, quality: 70);

      return jpegBytes;
    } catch (e) {
      print('Erro ao processar imagem: $e');
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

  // Conversão para YUV420 (formato comum em Android)
  img.Image _convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final yPlane = cameraImage.planes[0];
    final uPlane = cameraImage.planes[1];
    final vPlane = cameraImage.planes[2];

    final image = img.Image(width: width, height: height);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final yIndex = y * yPlane.bytesPerRow + x;
        final uvIndex = (y ~/ 2) * uPlane.bytesPerRow + (x ~/ 2) * 2;

        final yValue = yPlane.bytes[yIndex].toDouble();
        final uValue = uPlane.bytes[uvIndex].toDouble() - 128;
        final vValue = vPlane.bytes[uvIndex + 1].toDouble() - 128;

        // Conversão YUV para RGB
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

  // Conversão para BGRA8888 (formato comum em iOS)
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
