package com.example.pcqi_app

import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.pcqi_app/yuv_converter"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "convertYuvToJpeg" -> {
                    try {
                        val jpegBytes = convertYuvToJpeg(call)
                        result.success(jpegBytes)
                    } catch (e: Exception) {
                        result.error("CONVERSION_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun convertYuvToJpeg(call: MethodCall): ByteArray {
        val width = call.argument<Int>("width")!!
        val height = call.argument<Int>("height")!!
        val quality = call.argument<Int>("quality") ?: 100
        
        val yBytes = call.argument<ByteArray>("yBytes")!!
        val uBytes = call.argument<ByteArray>("uBytes")!!
        val vBytes = call.argument<ByteArray>("vBytes")!!
        
        val yRowStride = call.argument<Int>("yRowStride")!!
        val yPixelStride = call.argument<Int>("yPixelStride")!!
        val uvRowStride = call.argument<Int>("uvRowStride")!!
        val uvPixelStride = call.argument<Int>("uvPixelStride")!!
        
        val nv21 = yuv420ToNV21(
            yBytes, uBytes, vBytes,
            width, height,
            yRowStride, yPixelStride,
            uvRowStride, uvPixelStride
        )
        
        val yuvImage = YuvImage(nv21, ImageFormat.NV21, width, height, null)
        val out = ByteArrayOutputStream()
        yuvImage.compressToJpeg(Rect(0, 0, width, height), quality, out)
        
        return out.toByteArray()
    }

    private fun yuv420ToNV21(
        yBytes: ByteArray,
        uBytes: ByteArray,
        vBytes: ByteArray,
        width: Int,
        height: Int,
        yRowStride: Int,
        yPixelStride: Int,
        uvRowStride: Int,
        uvPixelStride: Int
    ): ByteArray {
        val nv21 = ByteArray(width * height * 3 / 2)
        
        var index = 0
        for (y in 0 until height) {
            for (x in 0 until width) {
                nv21[index++] = yBytes[y * yRowStride + x * yPixelStride]
            }
        }
        
        val uvHeight = height / 2
        val uvWidth = width / 2
        
        for (y in 0 until uvHeight) {
            for (x in 0 until uvWidth) {
                val uvIndex = y * uvRowStride + x * uvPixelStride
                nv21[index++] = vBytes[uvIndex]
                nv21[index++] = uBytes[uvIndex]
            }
        }
        
        return nv21
    }
}