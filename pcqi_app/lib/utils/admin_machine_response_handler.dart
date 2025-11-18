import 'dart:convert';

import 'package:pcqi_app/models/admin_machine_command_model.dart';

class AdminMachineResponseHandler {
  static Future<bool> handleGetSectorsResponse(response, context) async {
    try {
      AdminMachineCommandModel responseModel =
          AdminMachineCommandModel.fromJson(jsonDecode(response.body));
      if (responseModel.message!.startsWith("Comando")) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
