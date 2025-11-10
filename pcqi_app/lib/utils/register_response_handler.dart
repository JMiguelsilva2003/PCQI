import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/models/user_model.dart';
import 'package:pcqi_app/widgets/simple_awesome_dialog.dart';

class RegisterResponseHandler {
  static Future<void> handleRegisterResponse(response, context) async {
    try {
      UserModel userModelResponse = UserModel.fromJson(
        jsonDecode(response.body),
      );

      if (userModelResponse.detail!.startsWith("Email already")) {
        SimpleAwesomeDialog.warning(
          "Este endereço de e-mail já está associado à uma conta. Por favor, tente outro endereço de e-mail.",
          context,
        );
      } else if (userModelResponse.createdAt!.isNotEmpty) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          animType: AnimType.topSlide,
          title: "Info",
          desc:
              "Sua conta foi criada com sucesso. Por favor, verifique o link enviado à caixa de entrada para a verificação de e-mail.",
          btnOkColor: AppColors.azulEscuro,
          btnOkText: "OK",
          btnOkOnPress: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
        ).show();
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
