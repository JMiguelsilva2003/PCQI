import 'dart:convert';

import 'package:pcqi_app/models/admin_machine_command_model.dart';
import 'package:pcqi_app/models/app_enums.dart';

class AdminMachineResponseHandler {
  static Future<RequestStatusAdminMachineControl> handleGetSectorsResponse(
    response,
    context,
  ) async {
    // return types: null means request fail, true means request sucess, false means that the user is not an admin
    try {
      AdminMachineCommandModel responseModel =
          AdminMachineCommandModel.fromJson(jsonDecode(response.body));
      if (responseModel.detail!.startsWith("The user")) {
        return RequestStatusAdminMachineControl.userNotAdmin;
      } else if (responseModel.message!.startsWith("Comando")) {
        return RequestStatusAdminMachineControl.sucess;
      } else {
        return RequestStatusAdminMachineControl.fail;
      }
    } catch (e) {
      return RequestStatusAdminMachineControl.fail;
    }
  }
}
