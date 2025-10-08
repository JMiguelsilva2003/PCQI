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
          future: getSectorsAndMachinesList(),
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
      if (sectorList.isNotEmpty) {
        return RefreshIndicator(
          onRefresh: () async {
            await getSectorsAndMachinesList();
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
        );
      } else {
        return RefreshIndicator(
          onRefresh: () async {
            await getSectorsAndMachinesList();
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
      }
    }
  }

  Future<void> refreshScreen() async {
    await getSectorsAndMachinesList();
  }

  Future<void> getSectorsAndMachinesList() async {
    List<SectorModel>? sectors = await requestMethods.getSectorList();
    List<MachineModel>? machines = await requestMethods.getMachineList();
    if (sectors != null) {
      setState(() {
        sectorList = sectors;
        machinesList = machines;
      });
    }
    setState(() {
      gotInfoFromServer = true;
    });
  }
}
