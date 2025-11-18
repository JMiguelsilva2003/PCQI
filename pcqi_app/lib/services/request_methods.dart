import 'package:flutter/material.dart';
import 'package:pcqi_app/models/admin_machine_command_model.dart';
import 'package:pcqi_app/models/machine_model.dart';
import 'package:pcqi_app/models/sector_model.dart';
import 'package:pcqi_app/models/user_model.dart';
import 'package:pcqi_app/utils/admin_machine_response_handler.dart';
import 'package:pcqi_app/utils/auto_login_response_handler.dart';
import 'package:pcqi_app/services/http_request.dart';
import 'package:pcqi_app/utils/forgot_password_response_handler.dart';
import 'package:pcqi_app/utils/get_machines_response_handler.dart';
import 'package:pcqi_app/utils/get_sectors_response_handler.dart';
import 'package:pcqi_app/utils/login_response_handler.dart';
import 'package:pcqi_app/utils/register_response_handler.dart';
import 'package:pcqi_app/widgets/simple_awesome_dialog.dart';

class RequestMethods {
  final BuildContext context;

  RequestMethods({required this.context});

  Future<void> autoLogin() async {
    try {
      final response = await HttpRequest.postWithAuthorization('auth/refresh');
      if (!context.mounted) return;
      await AutoLoginResponseHandler.handleAutoLoginResponse(response, context);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, '/landingpage');
    }
  }

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
    final user = UserModel(email: email);
    final response = await HttpRequest.post(
      "auth/forgot-password",
      user.toJson(),
    );
    if (!context.mounted) return;
    await ForgotPasswordResponseHandler.handleForgotPasswordResponse(
      response,
      context,
    );
  }

  Future<List<SectorModel>?> getSectorList() async {
    final response = await HttpRequest.getWithAuthorization("sectors");
    if (!context.mounted) return null;
    return GetSectorsResponseHandler.handleGetSectorsResponse(
      response,
      context,
    );
  }

  Future<List<MachineModel>?> getMachineList() async {
    final response = await HttpRequest.getWithAuthorization("machines");
    if (!context.mounted) return null;
    return GetMachinesResponseHandler.handleGetMachinesResponse(
      response,
      context,
    );
  }

  Future<dynamic> createMachine(String sectorId, String machineName) async {
    final response = await HttpRequest.postWithAuthorizationJson("machines/", {
      "name": machineName,
      "sector_id": sectorId,
    });

    return response.body;
  }

  Future<dynamic> deleteMachine(String machineId) async {
    final response = await HttpRequest.deleteWithAuthorization(
      "machines/$machineId",
    );
    return response.body;
  }

  Future<bool?> sendAdminMachineRequest(
    String machineID,
    String command,
  ) async {
    try {
      AdminMachineCommandModel request = AdminMachineCommandModel(
        command: command,
      );
      final response = await HttpRequest.postWithAuthorizationJson(
        "admin/machines/$machineID/control",
        request.toJson(),
      );
      if (!context.mounted) return null;
      bool? isRequestSucessfull =
          await AdminMachineResponseHandler.handleGetSectorsResponse(
            response,
            context,
          );
      return isRequestSucessfull;
      //if (!context.mounted) return;
    } catch (e) {}
    return null;
  }
}
