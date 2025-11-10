import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pcqi_app/models/user_model.dart';
import 'package:pcqi_app/services/shared_preferences_helper.dart';
import 'package:pcqi_app/widgets/simple_awesome_dialog.dart';

class LoginResponseHandler {
  static Future<void> handleLoginResponse(response, context) async {
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
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/homepage',
          (route) => false,
        );
        return;
      }

      if (!context.mounted) {
        return;
      } else if (userModelResponse.detail!.startsWith("Incorrect")) {
        SimpleAwesomeDialog.error(
          "O usuário não foi encontrado ou a senha é inválida",
          context,
        );
      } else if (userModelResponse.detail!.startsWith("Email has not")) {
        SimpleAwesomeDialog.info(
          "Conta ainda não verificada. Por favor, verifique-a através do link enviado à sua caixa de entrada.",
          context,
        );
      } else {
        SimpleAwesomeDialog.error(
          "Falha na conexão. Por favor, tente novamente.",
          context,
        );
      }
    } catch (e) {
      SimpleAwesomeDialog.error(
        "Falha na conexão. Por favor, tente novamente.",
        context,
      );
    }
  }
}
