import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pcqi_app/models/machine_model.dart';
//import 'package:logger/logger.dart';
import 'package:pcqi_app/services/http_request.dart';
import 'package:pcqi_app/models/user_model.dart';
import 'package:pcqi_app/utils/forgot_password_response_handler.dart';
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

  Future<void> forgotPasswordRequest(String email) async {
    try {
      UserModel userRequest = UserModel(email: email);
      final response = await HttpRequest.post(
        "auth/forgot-password",
        userRequest.toJson(),
      );
      if (!context.mounted) return;
      await ForgotPasswordResponseHandler.handleForgotPasswordResponse(
        response,
        context,
      );
    } catch (e) {
      if (!context.mounted) return;
      SimpleAwesomeDialog.error(
        "Falha na conexão. Por favor, tente novamente.",
        context,
      );
    }
  }

  Future<List<MachineModel>?> getMachineList() async {
    try {
      final response = await HttpRequest.getWithAuthorization("machines");
      // if response is sucessfull, do >>>
      List<Map<String, dynamic>> machinesListTest = [
        {
          'name': 'Máquinaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
          'id': 0,
          'owner_id': 0,
          'current_speed_ppm': 0,
        },
        {'name': 'Máquina 2', 'id': 0, 'owner_id': 0, 'current_speed_ppm': 0},
        {'name': 'Máquina 3', 'id': 0, 'owner_id': 0, 'current_speed_ppm': 0},
        {'name': 'Máquina 4', 'id': 0, 'owner_id': 0, 'current_speed_ppm': 0},
      ];

      List<Map<String, dynamic>> machinesListEmpty = [];

      List<MachineModel> machines = [];
      for (var machine in machinesListTest) {
        machines.add(MachineModel.fromJson(machine));
      }
      return machines;
    } catch (e) {
      print(e);
    }
  }
}
