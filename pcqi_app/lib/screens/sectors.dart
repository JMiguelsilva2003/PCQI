import 'dart:convert';

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
  late RequestMethods requestMethods;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    requestMethods = RequestMethods(context: context);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                children: sectorList.map((sector) {
                  return CustomSectorViewCard(
                    name: sector.name ?? "",
                    description: sector.description ?? "",
                    machines: sector.machines,

                    onCreateMachine: (machineName) async {
                      var maquinaCriada = await requestMethods.createMachine(
                        sector.id!.toString(),
                        machineName,
                      );
                      if (maquinaCriada != null) {
                        MachineModel novaMaquina = MachineModel.fromJson(
                          jsonDecode(maquinaCriada),
                        );
                        for (var setor in sectorList) {
                          if (setor.id.toString() ==
                              novaMaquina.sectorId.toString()) {
                            sector.machines.add(novaMaquina);
                            break;
                          }
                        }
                        setState(() {});
                      }
                    },

                    onEditMachine: (machineId) async {
                      Navigator.pushNamed(context, '/machine-edit');
                    },

                    onDeleteMachine: (machineId) async {
                      var maquinaApagando = await requestMethods.deleteMachine(
                        machineId,
                      );
                      try {
                        if (maquinaApagando != null) {
                          MachineModel antigaMaquina = MachineModel.fromJson(
                            jsonDecode(maquinaApagando),
                          );
                          if (antigaMaquina.id.toString() == machineId) {
                            for (var setor in sectorList) {
                              if (setor.id.toString() ==
                                  antigaMaquina.sectorId.toString()) {
                                sector.machines.removeWhere(
                                  (m) => m.id == antigaMaquina.id,
                                );
                                break;
                              }
                            }
                            setState(() {});
                          }
                        }
                      } catch (e) {}
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

    if (!mounted) return;
    setState(() => loading = false);
  }
}
