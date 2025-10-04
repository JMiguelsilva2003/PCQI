import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/models/user_model.dart';
import 'package:pcqi_app/widgets/simple_awesome_dialog.dart';

class ForgotPasswordResponseHandler {
  static Future<void> handleForgotPasswordResponse(
    response,
    BuildContext context,
  ) async {
    try {
      UserModel userModelResponse = UserModel.fromJson(
        jsonDecode(response.body),
      );
      if (!context.mounted) return;
      if (userModelResponse.message!.startsWith("Se um usu")) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          animType: AnimType.topSlide,
          title: "Info",
          desc:
              "Se existir um usuário associado ao endereço de e-mail, um link de redefinição foi enviado.",
          btnOkColor: AppColors.azulEscuro,
          btnOkText: "OK",
          btnOkOnPress: () {
            Navigator.pop(context);
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
      if (!context.mounted) return;
      SimpleAwesomeDialog.error(
        "Falha na conexão. Por favor, tente novamente.",
        context,
      );
    }
  }
}
