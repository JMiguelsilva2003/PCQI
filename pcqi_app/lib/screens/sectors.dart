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
  bool loading = true;

  @override
  void initState() {
    super.initState();
    requestMethods = RequestMethods(context: context);
    _loadData(); // ✅ carrega automaticamente ao entrar na tela
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator()) // ✅ tela de loading
          : RefreshIndicator(
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

                    // ✅ Criar máquina
                    onCreateMachine: (machineName) async {
                      await requestMethods.createMachine(
                        sector.id!.toString(),
                        machineName,
                      );
                      await _loadData(); // ✅ agora atualiza a lista
                    },

                    // ✅ Deletar máquina
                    onDeleteMachine: (machineId) async {
                      await requestMethods.deleteMachine(machineId);
                      await _loadData(); // ✅ atualiza a lista
                    },
                  );
                }).toList(),
              ),
            ),
    );
  }

  Future<void> _loadData() async {
    setState(() => loading = true);

    sectorList = await requestMethods.getSectorList() ?? [];
    machineList = await requestMethods.getMachineList() ?? [];

    if (!mounted) return;
    setState(() => loading = false); // ✅ reconstrução correta da tela
  }
}
