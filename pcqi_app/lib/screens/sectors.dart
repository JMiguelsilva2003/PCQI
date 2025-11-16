import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
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
  List<SectorModel>? sectorList;
  late RequestMethods requestMethods;

  bool gotInfoFromServer = false;

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
        body: FutureBuilder<void>(
          future: getSectorList(),
          builder: (context, snapshot) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.azulEscuro),
                  SizedBox(height: 20),
                  Text(
                    "Carregando...",
                    style: AppStyles.textStyleTituloSecundario,
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else {
      if (sectorList == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 50,
                color: AppColors.azulEscuro,
              ),
              SizedBox(height: 10),
              Text(
                "Falha ao obter informações. Por favor, tente novamente.",
                style: AppStyles.textStyleTituloSecundario,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: LoadingButton(
                    type: ButtonType.elevated,
                    style: AppStyles.loadingButtonStyle,
                    successDuration: Duration(seconds: 0),
                    onPressed: () async {
                      setState(() {
                        gotInfoFromServer = false;
                      });
                    },
                    child: Text(
                      "Tentar novamente",
                      style: AppStyles.loadingButtonTextStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        if (sectorList!.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              await getSectorList();
            },
            child: Stack(
              children: [
                ListView(children: [
                        ],
                      ),
                Align(
                  alignment: Alignment.center,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sentiment_dissatisfied_rounded,
                          size: 50,
                          color: AppColors.azulEscuro,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Não foram encontrados setores cadastrados em seu usuário",
                          style: AppStyles.textStyleTituloSecundario,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            body: RefreshIndicator(
              onRefresh: getSectorList,
              child: ListView(
                children: sectorList!.map((sector) {
                  return CustomSectorViewCard(
                    name: sector.name!,
                    description: sector.description!,
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
                        for (var setor in sectorList!) {
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
                            for (var setor in sectorList!) {
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
                      } catch (e) {
                        return null;
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> getSectorList() async {
    setState(() => gotInfoFromServer = false);
    sectorList = await requestMethods.getSectorList();
    if (!mounted) return;
    setState(() => gotInfoFromServer = true);
  }
}
