import 'package:flutter/material.dart';
//import 'package:logger/logger.dart';
import 'package:pcqi_app/services/http_request.dart';
import 'package:pcqi_app/models/user_model.dart';
import 'package:pcqi_app/utils/login_response_handler.dart';
import 'package:pcqi_app/utils/register_response_handler.dart';
import 'package:pcqi_app/widgets/simple_awesome_dialog.dart';

class RequestMethods {
  final BuildContext context;
  //Logger logger = Logger();

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
      if (!context.mounted) return;
      await RegisterResponseHandler.handleRegisterResponse(response, context);
    } catch (e) {
      if (!context.mounted) return;
      SimpleAwesomeDialog.error(
        "Falha na conexão. Por favor, tente novamente.",
        context,
      );
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final requestData = {"username": email, "password": password};

      final response = await HttpRequest.postFormUrlEncoded(
        'auth/login',
        requestData,
      );
      if (!context.mounted) return;
      await LoginResponseHandler.handleLoginResponse(response, context);
    } catch (e) {
      if (!context.mounted) return;
      SimpleAwesomeDialog.error(
        "Falha na conexão. Por favor, tente novamente.",
        context,
      );
    }
  }
}

void getMachineList() {}
