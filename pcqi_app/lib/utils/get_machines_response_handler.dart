import 'dart:convert';

import 'package:pcqi_app/models/machine_model.dart';

class GetMachinesResponseHandler {
  static Future<List<MachineModel>?> handleGetMachinesResponse(
    response,
    context,
  ) async {
    try {
      List<dynamic> machineModelList = jsonDecode(response.body);
      if (machineModelList.isNotEmpty) {
        List<MachineModel> sectors = [];
        for (var machine in machineModelList) {
          sectors.add(MachineModel.fromJson(machine));
        }
        return sectors;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
