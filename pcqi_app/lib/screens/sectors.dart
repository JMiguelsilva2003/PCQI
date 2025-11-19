import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/models/machine_model.dart';
import 'package:pcqi_app/models/sector_model.dart';
import 'package:pcqi_app/providers/provider_sector_list.dart';
import 'package:pcqi_app/services/request_methods.dart';
import 'package:pcqi_app/widgets/custom_list_view_card.dart';
import 'package:provider/provider.dart';

class Sectors extends StatefulWidget {
  const Sectors({super.key});

  @override
  State<Sectors> createState() => _SectorsState();
}

class _SectorsState extends State<Sectors> {
  late RequestMethods requestMethods;

  late final ProviderSectorList providerSectorList;
  late Future<void> futureSectorList;

  bool gotInfoFromServer = false;

  TextEditingController controllerSearchBar = TextEditingController();
  List<SectorModel>? filteredList;

  @override
  void initState() {
    super.initState();
    requestMethods = RequestMethods(context: context);
    providerSectorList = context.read<ProviderSectorList>();
    futureSectorList = getSectorList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderSectorList>(
      builder: (context, value, child) {
        if (!gotInfoFromServer) {
          return Scaffold(
            backgroundColor: AppColors.branco,
            body: FutureBuilder<void>(
              future: futureSectorList,
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
          if (providerSectorList.getSectorList == null) {
            return Scaffold(
              backgroundColor: AppColors.branco,
              body: Center(
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
                              futureSectorList = getSectorList();
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
              ),
            );
          } else {
            if (providerSectorList.getSectorList!.isEmpty) {
              return Scaffold(
                body: RefreshIndicator(
                  backgroundColor: AppColors.branco,
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
                ),
              );
            } else {
              return Scaffold(
                backgroundColor: AppColors.branco,
                body: Column(
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: controllerSearchBar,
                          builder: (context, value, child) {
                            return SearchBar(
                              controller: controllerSearchBar,
                              hintText: 'Pesquisar...',

                              hintStyle: WidgetStateProperty.all(
                                TextStyle(color: AppColors.cinzaEscuro),
                              ),
                              textStyle: WidgetStateProperty.all(
                                TextStyle(color: AppColors.preto, fontSize: 16),
                              ),
                              backgroundColor: WidgetStateProperty.all(
                                AppColors.branco,
                              ),
                              surfaceTintColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                              elevation: WidgetStateProperty.all(0),
                              shadowColor: WidgetStateProperty.all(
                                Colors.black12,
                              ),
                              side: WidgetStateProperty.all(
                                BorderSide(
                                  color: AppColors.azulEscuro,
                                  width: 1,
                                ),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              padding: WidgetStateProperty.all(
                                EdgeInsets.symmetric(horizontal: 16),
                              ),

                              leading: Icon(Icons.search),
                              trailing: [
                                /*// Filter button
                                IconButton(
                                  icon: Icon(Icons.filter_list),
                                  onPressed: () {},
                                ),*/

                                // Clear button
                                if (value.text.isNotEmpty)
                                  IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      controllerSearchBar.clear();
                                      filteredList =
                                          providerSectorList.getSectorList!;
                                      setState(() {});
                                    },
                                  ),
                              ],
                              onChanged: (value) {
                                if (value.trim().isNotEmpty) {
                                  filteredList = [];
                                  for (var sector
                                      in providerSectorList.getSectorList!) {
                                    if (sector.name!
                                        .trim()
                                        .toLowerCase()
                                        .contains(value.trim().toLowerCase())) {
                                      filteredList!.add(sector);
                                    }
                                  }
                                } else {
                                  filteredList =
                                      providerSectorList.getSectorList!;
                                }
                                setState(() {});
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: getSectorList,
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: /*providerSectorList.getSectorList!.map(*/
                              filteredList!.map((sector) {
                                return CustomSectorViewCard(
                                  name: sector.name!,
                                  description: sector.description!,
                                  machines: sector.machines,

                                  onCreateMachine: (machineName) async {
                                    var maquinaCriada = await requestMethods
                                        .createMachine(
                                          sector.id!.toString(),
                                          machineName,
                                        );
                                    if (maquinaCriada != null) {
                                      MachineModel novaMaquina =
                                          MachineModel.fromJson(
                                            jsonDecode(maquinaCriada),
                                          );
                                      for (var setor
                                          in providerSectorList
                                              .getSectorList!) {
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
                                    Navigator.pushNamed(
                                      context,
                                      '/machine-edit',
                                      arguments: machineId,
                                    );
                                  },

                                  onDeleteMachine: (machineId) async {
                                    var maquinaApagando = await requestMethods
                                        .deleteMachine(machineId);
                                    try {
                                      if (maquinaApagando != null) {
                                        MachineModel antigaMaquina =
                                            MachineModel.fromJson(
                                              jsonDecode(maquinaApagando),
                                            );
                                        if (antigaMaquina.id.toString() ==
                                            machineId) {
                                          for (var setor
                                              in providerSectorList
                                                  .getSectorList!) {
                                            if (setor.id.toString() ==
                                                antigaMaquina.sectorId
                                                    .toString()) {
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
                    ),
                  ],
                ),
              );
            }
          }
        }
      },
    );
  }

  Future<void> getSectorList() async {
    try {
      setState(() => gotInfoFromServer = false);
      List<SectorModel>? sectorList = await requestMethods.getSectorList();
      if (!mounted) return;
      providerSectorList.setSectorList(sectorList);
      // May remove later the following line:
      filteredList = sectorList;

      if (!mounted) return;
      setState(() => gotInfoFromServer = true);
    } catch (e) {
      providerSectorList.setSectorList(null);
      if (!mounted) return;
      setState(() => gotInfoFromServer = true);
    }
  }
}
