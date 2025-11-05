import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';
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
  bool gotInfoFromServer = false;
  String? deletingMachineId; // <-- controla o loading

  @override
  void initState() {
    super.initState();
    requestMethods = RequestMethods(context: context);
  }

  @override
  Widget build(BuildContext context) {
    if (!gotInfoFromServer) {
      return Scaffold(
        backgroundColor: AppColors.branco,
        body: FutureBuilder(
          future: getSectorsAndMachinesList(),
          builder: (context, snapshot) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.azulEscuro),
                  const SizedBox(height: 20),
                  Text("Carregando...", style: AppStyles.textStyleTituloSecundario),
                ],
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => await getSectorsAndMachinesList(),
      child: sectorList.isNotEmpty
          ? ListView.builder(
              itemCount: sectorList.length,
              itemBuilder: (BuildContext context, int index) {
                return CustomSectorViewCard(
                  name: sectorList[index].name!,
                  description: sectorList[index].description!,
                  machines: machinesList!
                      .where((machine) => machine.sectorId == sectorList[index].id)
                      .toList(),
                  deletingMachineId: deletingMachineId, // <-- passa o estado
                  onDeleteMachine: (machineId) async {
                    await deleteMachineFromList(machineId);
                  },
                );
              },
            )
          : Center(
              child: Text(
                "Não foram encontrados setores cadastrados",
                style: AppStyles.textStyleTituloSecundario,
              ),
            ),
    );
  }

  Future<void> deleteMachineFromList(String machineId) async {
    setState(() {
      deletingMachineId = machineId; // <-- ativa loading
    });

    bool success = await requestMethods.deleteMachine(machineId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Máquina removida com sucesso")),
      );
      await getSectorsAndMachinesList();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao remover a máquina")),
      );
    }

    setState(() {
      deletingMachineId = null; // <-- desativa loading
    });
  }

  Future<void> getSectorsAndMachinesList() async {
    List<SectorModel>? sectors = await requestMethods.getSectorList();
    List<MachineModel>? machines = await requestMethods.getMachineList();

    if (sectors != null) {
      sectorList = sectors;
      machinesList = machines;
    }

    gotInfoFromServer = true;
    setState(() {});
  }
}
