import 'dart:convert';

import 'package:pcqi_app/models/admin_machine_command_model.dart';

class AdminMachineResponseHandler {
  static Future<bool?> handleGetSectorsResponse(response, context) async {
    // return types: null means request fail, true means request sucess, false means that the user is not an admin
    try {
      AdminMachineCommandModel responseModel =
          AdminMachineCommandModel.fromJson(jsonDecode(response.body));
      if (responseModel.detail!.startsWith("The user")) {
        return false;
      } else if (responseModel.message!.startsWith("Comando")) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
