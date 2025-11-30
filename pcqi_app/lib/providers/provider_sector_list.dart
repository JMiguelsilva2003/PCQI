import 'package:flutter/material.dart';
import 'package:pcqi_app/models/machine_model.dart';
import 'package:pcqi_app/models/sector_model.dart';

class ProviderSectorList extends ChangeNotifier {
  List<SectorModel>? sectorList;

  List<SectorModel>? get getSectorList => sectorList;

  void setSectorList(List<SectorModel>? newSectorList) {
    sectorList = newSectorList;
    notifyListeners();
  }

  SectorModel? getSingleSector(int sectorID) {
    // The list still doesn't exists
    if (sectorList == null) return null;

    // Searches for the specified sector and returns it (if it exists)
    for (var sector in sectorList!) {
      if (sector.id == sectorID) {
        return sector;
      }
    }
    return null;
  }

  List<MachineModel>? getMachineListFromSector(int sectorID) {
    // The list still doesn't exists
    if (sectorList == null) return null;

    // Searches for the specified sector and returns the machine list
    for (var sector in sectorList!) {
      if (sector.id == sectorID) {
        return sector.machines;
      }
    }
    return null;
  }

  MachineModel? getSingleMachineFromSpecifiedSector(
    int machineID,
    int sectorID,
  ) {
    // The list still doesn't exists
    if (sectorList == null) return null;

    // Searches for the specified sector
    for (var sector in sectorList!) {
      if (sector.id == sectorID) {
        // Searches for the specified machine in the sector
        for (var machine in sector.machines) {
          if (machine.id == machineID) {
            return machine;
          }
        }
        return null;
      }
    }
    return null;
  }

  MachineModel? getSingleMachineFromSector(int machineID) {
    // The list still doesn't exists
    if (sectorList == null) return null;

    // Searches for the specified sector
    for (var sector in sectorList!) {
      for (var machine in sector.machines) {
        if (machine.id == machineID) {
          return machine;
        }
      }
    }
    return null;
  }
}
