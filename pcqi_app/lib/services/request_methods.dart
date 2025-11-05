import 'package:flutter/material.dart';
import 'package:pcqi_app/models/machine_model.dart';
import 'package:pcqi_app/models/sector_model.dart';
import 'package:pcqi_app/models/user_model.dart';
import 'package:pcqi_app/services/http_request.dart';
import 'package:pcqi_app/utils/forgot_password_response_handler.dart';
import 'package:pcqi_app/utils/get_machines_response_handler.dart';
import 'package:pcqi_app/utils/get_sectors_response_handler.dart';
import 'package:pcqi_app/utils/login_response_handler.dart';
import 'package:pcqi_app/utils/register_response_handler.dart';

class RequestMethods {
  final BuildContext context;

  RequestMethods({required this.context});

  Future<void> login(String email, String password) async {
    final data = {"username": email, "password": password};
    final response = await HttpRequest.postFormUrlEncoded("auth/login", data);
    await LoginResponseHandler.handleLoginResponse(response, context);
  }

  Future<void> register(String name, String email, String password) async {
    final user = UserModel(name: name, email: email, password: password);
    final response = await HttpRequest.post("auth/register", user.toJson());
    await RegisterResponseHandler.handleRegisterResponse(response, context);
  }

  Future<void> forgotPasswordRequest(String email) async {
    final user = UserModel(email: email);
    final response = await HttpRequest.post(
      "auth/forgot-password",
      user.toJson(),
    );
    await ForgotPasswordResponseHandler.handleForgotPasswordResponse(
      response,
      context,
    );
  }

  Future<List<SectorModel>?> getSectorList() async {
    final response = await HttpRequest.getWithAuthorization("sectors");
    return GetSectorsResponseHandler.handleGetSectorsResponse(
      response,
      context,
    );
  }

  Future<List<MachineModel>?> getMachineList() async {
    final response = await HttpRequest.getWithAuthorization("machines");
    return GetMachinesResponseHandler.handleGetMachinesResponse(
      response,
      context,
    );
  }

  Future<bool> createMachine(String sectorId, String machineName) async {
    final response = await HttpRequest.postWithAuthorization("machines", {
      "name": machineName,
      "sector_id": sectorId,
    });

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> deleteMachine(String machineId) async {
    final response = await HttpRequest.deleteWithAuthorization(
      "machines/$machineId",
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
