import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/services/http_request.dart';
import 'package:pcqi_app/models/user_model.dart';
import 'package:pcqi_app/services/shared_preferences_helper.dart';

class RequestMethods {
  final BuildContext context;

  RequestMethods({required this.context});

  Future<void> register(String name, String email, String password) async {
    try {
      UserModel request = UserModel(
        name: name,
        email: email,
        password: password,
      );

      final response = await HttpRequest.post(
        'auth/register',
        request.toJson(),
      );

      try {
        UserModel userModelResponse = UserModel.fromJson(
          jsonDecode(response.body),
        );

        if (userModelResponse.detail!.startsWith("Email already")) {
          awesomeDialogWarning(
            "Este endereço de e-mail já está associado à uma conta. Por favor, tente outro endereço de e-mail.",
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
              Navigator.popAndPushNamed(context, '/');
            },
            dismissOnTouchOutside: false,
            dismissOnBackKeyPress: false,
          ).show();
        }
      } catch (e) {}
      return response;
    } catch (e) {}
  }

  Future<void> login(String email, String password) async {
    try {
      final requestData = {"username": email, "password": password};

      final response = await HttpRequest.postFormUrlEncoded(
        'auth/login',
        requestData,
      );

      try {
        UserModel userModelResponse = UserModel.fromJson(
          jsonDecode(response.body),
        );
        if (userModelResponse.accessToken!.isNotEmpty) {
          await SharedPreferencesHelper.setAccessToken(
            userModelResponse.accessToken!,
          );
          await SharedPreferencesHelper.setRefreshToken(
            userModelResponse.refreshToken!,
          );
          Navigator.popAndPushNamed(context, '/homepage');
        } else if (userModelResponse.detail!.startsWith("Incorrect")) {
          awesomeDialogError(
            "O usuário não foi encontrado ou a senha é inválida",
          );
        } else if (userModelResponse.detail!.startsWith("Email has not")) {
          awesomeDialogInfo(
            "Conta ainda não verificada. Por favor, verifique-a através do link enviado à sua caixa de entrada.",
          );
        }
      } catch (e) {}
      return response;
    } catch (e) {}
  }

  void awesomeDialogInfo(String description) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.topSlide,
      title: "Info",
      desc: description,
      btnOkColor: AppColors.azulEscuro,
      btnOkText: "OK",
      btnOkOnPress: () {},
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  void awesomeDialogError(String description) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.topSlide,
      title: "Erro",
      desc: description,
      btnOkColor: AppColors.vermelho,
      btnOkText: "OK",
      btnOkOnPress: () {},
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  void awesomeDialogWarning(String description) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.topSlide,
      title: "Aviso",
      desc: description,
      btnOkColor: AppColors.azulEscuro,
      btnOkText: "OK",
      btnOkOnPress: () {},
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }
}
