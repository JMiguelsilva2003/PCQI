import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class CameraImageConverter {
  // Remember to change manually the package's name above if it ever gets changed!
  static const platform = MethodChannel('com.example.pcqi_app/yuv_converter');

  Future<Uint8List?> convertImage(CameraImage cameraImage) async {
    try {
      // Android Image Conversion
      if (cameraImage.format.group == ImageFormatGroup.yuv420) {
        return await convertImageAndroid(cameraImage);
      }

      // iOS and others
      final image = convertCameraImageNotAndroidDevice(cameraImage);

      final resizedImage = img.copyResize(
        image,
        width: 640,
        height: 480,
        maintainAspect: true,
      );

      final jpegBytes = img.encodeJpg(resizedImage, quality: 70);

      return jpegBytes;
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List?> convertImageAndroid(CameraImage image) async {
    try {
      final yPlane = image.planes[0];
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      final result = await platform.invokeMethod('convertYuvToJpeg', {
        'width': image.width,
        'height': image.height,
        'yBytes': yPlane.bytes,
        'uBytes': uPlane.bytes,
        'vBytes': vPlane.bytes,
        'yRowStride': yPlane.bytesPerRow,
        'yPixelStride': yPlane.bytesPerPixel ?? 1,
        'uvRowStride': uPlane.bytesPerRow,
        'uvPixelStride': uPlane.bytesPerPixel ?? 2,
        'quality': 70,
      });

      return result as Uint8List?;
    } on PlatformException {
      return null;
    }
  }

  img.Image convertCameraImageNotAndroidDevice(CameraImage cameraImage) {
    /*if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420ToImage(cameraImage);
    } else */

    if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      return convertImageIOS(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.jpeg) {
      return img.decodeImage(cameraImage.planes[0].bytes)!;
    }
    throw Exception('Image type not supported');
  }

  // Old image convertion method for Android
  /*Uint8List? _convertYUV420ToImage(CameraImage cameraImage) {
    final image = _convertYUV420ToImage(cameraImage);
    final resizedImage = img.copyResize(
      image,
      width: 640,
      height: 480,
      maintainAspect: true,
    );
    return img.encodeJpg(resizedImage, quality: 70);
  }

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
  }*/

  // BGRA8888 to image converter (iOS, never tested before)
  img.Image convertImageIOS(CameraImage cameraImage) {
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
