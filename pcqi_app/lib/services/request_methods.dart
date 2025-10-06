import 'package:flutter/material.dart';
import 'package:pcqi_app/models/machine_model.dart';
import 'package:pcqi_app/models/sector_model.dart';
//import 'package:logger/logger.dart';
import 'package:pcqi_app/services/http_request.dart';
import 'package:pcqi_app/models/user_model.dart';
import 'package:pcqi_app/utils/forgot_password_response_handler.dart';
import 'package:pcqi_app/utils/get_machines_response_handler.dart';
import 'package:pcqi_app/utils/get_sectors_response_handler.dart';
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

  Future<List<SectorModel>?> getSectorList() async {
    try {
      final response = await HttpRequest.getWithAuthorization("sectors");
      if (!context.mounted) return null;
      final sectorListFromServer =
          await GetSectorsResponseHandler.handleGetSectorsResponse(
            response,
            context,
          );
      return sectorListFromServer;
    } catch (e) {
      if (!context.mounted) return null;
      SimpleAwesomeDialog.error(
        "Falha na conexão. Por favor, tente novamente.",
        context,
      );
    }
    return null;
  }

  Future<List<MachineModel>?> getMachineList() async {
    try {
      final response = await HttpRequest.getWithAuthorization("machines");
      if (!context.mounted) return null;
      final machineListFromServer =
          await GetMachinesResponseHandler.handleGetMachinesResponse(
            response,
            context,
          );
      return machineListFromServer;
    } catch (e) {
      if (!context.mounted) return null;
      SimpleAwesomeDialog.error(
        "Falha na conexão. Por favor, tente novamente.",
        context,
      );
    }
    return null;
  }
}
