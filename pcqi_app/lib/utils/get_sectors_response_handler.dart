import 'dart:convert';
import 'package:pcqi_app/models/sector_model.dart';

class GetSectorsResponseHandler {
  static Future<List<SectorModel>?> handleGetSectorsResponse(
    response,
    context,
  ) async {
    try {
      List<dynamic> sectorModelList = jsonDecode(response.body);
      if (sectorModelList.isNotEmpty) {
        List<SectorModel> sectors = [];
        for (var sector in sectorModelList) {
          sectors.add(SectorModel.fromJson(sector));
        }
        return sectors;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
