import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pcqi_app/models/user_model.dart';
import 'package:pcqi_app/services/shared_preferences_helper.dart';

class AutoLoginResponseHandler {
  static Future<void> handleAutoLoginResponse(response, context) async {
    try {
      UserModel userModelResponse = UserModel.fromJson(
        jsonDecode(response.body),
      );
      //logger.d(response.body);
      if (userModelResponse.accessToken!.isNotEmpty) {
        await SharedPreferencesHelper.setAccessToken(
          userModelResponse.accessToken!,
        );
        await SharedPreferencesHelper.setRefreshToken(
          userModelResponse.refreshToken!,
        );
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, '/homepage');
        return;
      }
    } catch (e) {
      Navigator.pushReplacementNamed(context, '/landingpage');
      return;
    }
  }
}
