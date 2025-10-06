import 'package:flutter/material.dart';
import 'package:pcqi_app/models/machine_model.dart';
import 'package:pcqi_app/models/sector_model.dart';
import 'package:pcqi_app/services/request_methods.dart';
import 'package:pcqi_app/widgets/custom_list_view_card.dart';

class Sectors extends StatefulWidget {
  const Sectors({super.key});

  @override
  State<Sectors> createState() => _SectorsState();
}

class _SectorsState extends State<Sectors> {
  List<SectorModel> sectorList = [];
  List<MachineModel>? machinesList = [];
  late RequestMethods requestMethods;

  @override
  void initState() {
    super.initState();
    requestMethods = RequestMethods(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          List<SectorModel>? sectors = await requestMethods.getSectorList();
          List<MachineModel>? machines = await requestMethods.getMachineList();
          if (sectors != null) {
            setState(() {
              sectorList = sectors;
              machinesList = machines;
            });
          }
        },
        child: Center(
          child: ListView.builder(
            itemCount: sectorList.length,
            itemBuilder: (BuildContext context, int index) {
              return CustomSectorViewCard(
                name: sectorList[index].name!,
                description: sectorList[index].description!,
                machines: [],
              );
            },
          ),
        ),
      ),
    );
  }
}
