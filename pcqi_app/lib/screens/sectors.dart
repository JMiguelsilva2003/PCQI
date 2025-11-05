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
  List<MachineModel> machineList = [];
  late RequestMethods requestMethods;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    requestMethods = RequestMethods(context: context);
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return FutureBuilder(
        future: _loadData(),
        builder: (context, snapshot) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

return Scaffold(
  body: RefreshIndicator(
    onRefresh: _loadData,
    child: ListView(
      children: sectorList.map((sector) {
       final machines = machineList
    .where((m) => m.sectorId.toString() == sector.id.toString())
    .toList();

        return CustomSectorViewCard(
          name: sector.name ?? "",
          description: sector.description ?? "",
          machines: machines,
            onDeleteMachine: (machineId) async {
              await requestMethods.deleteMachine(machineId);
              await _loadData().then((_) => setState(() {}));
            },
          onCreateMachine: (machineName) async {
            await requestMethods.createMachine(
              sector.id!.toString(), // ⇦ converte para String
              machineName,
            );
            await _loadData().then((_) => setState(() {}));

          },
        );
      }).toList(),
    ),
  ),
);

  }
  

 Future<void> _loadData() async {
  sectorList = await requestMethods.getSectorList() ?? [];
  machineList = await requestMethods.getMachineList() ?? [];

 if (!mounted) return;
setState(() {
  loaded = true;
});
 }

}
