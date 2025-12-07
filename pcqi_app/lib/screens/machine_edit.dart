import 'dart:async';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/models/app_enums.dart';
import 'package:pcqi_app/models/machine_model.dart';
import 'package:pcqi_app/providers/provider_sector_list.dart';
import 'package:pcqi_app/services/request_methods.dart';
import 'package:pcqi_app/widgets/custom_admin_machine_request_widget.dart';
import 'package:provider/provider.dart';

class MachineEdit extends StatefulWidget {
  const MachineEdit({super.key});

  @override
  State<MachineEdit> createState() => _MachineEditState();
}

class _MachineEditState extends State<MachineEdit> {
  late String machineID;
  late RequestMethods requestMethods;

  RequestTypeAdminMachineControl currentAdminMachineRequestType =
      RequestTypeAdminMachineControl.none;
  RequestStatusAdminMachineControl currentAdminMachineRequestStatus =
      RequestStatusAdminMachineControl.none;
  bool isAdminMachineCommandEnabled = true;

  @override
  void initState() {
    super.initState();
    requestMethods = RequestMethods(context: context);
  }

  @override
  Widget build(BuildContext context) {
    machineID = ModalRoute.of(context)!.settings.arguments as String;
    return Consumer<ProviderSectorList>(
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: AppColors.branco,
          appBar: AppBar(
            backgroundColor: AppColors.branco,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("Editar máquina"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: [
                buildGoToCameraScreenButton(),

                SizedBox(height: 10),

                buildCameraOptions(),

                SizedBox(height: 10),

                buildAdminOptions(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildGoToCameraScreenButton() => SizedBox(
    height: 60,
    child: ElevatedButton(
      onPressed: () {
        final provider = context.read<ProviderSectorList>();

        int? machineIDInt = int.tryParse(machineID);
        if (machineIDInt != null) {
          MachineModel? machine = provider.getSingleMachineFromSector(
            machineIDInt,
          );

          if (machine != null) {
            int sectorID = machine.sectorId!;

            Navigator.of(context, rootNavigator: true).pushNamed(
              '/camera',
              arguments: {'sectorID': sectorID, 'machineID': machineID},
            );
          }
        }
      },
      style: AppStyles.buttonStyleElevatedButton,
      child: Text("Abrir câmera", style: AppStyles.textStyleElevatedButton),
    ),
  );

  Widget buildAdminOptions() => Container(
    padding: EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppColors.branco,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.azulEscuro, width: 2),
    ),

    child: ExpandablePanel(
      header: Center(
        child: ListTile(
          title: Text(
            "Opções de administrador",
            textAlign: TextAlign.center,
            style: AppStyles.textStyleOptionsTab,
          ),
        ),
      ),
      collapsed: SizedBox(width: 1),
      expanded: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSendingAdminRequestStatus(),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: isAdminMachineCommandEnabled
                    ? () async {
                        await sendAdminRequest(
                          RequestTypeAdminMachineControl.resume,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      currentAdminMachineRequestType ==
                          RequestTypeAdminMachineControl.resume
                      ? AppColors.cinzaEscuro
                      : AppColors.branco,

                  disabledBackgroundColor:
                      currentAdminMachineRequestType ==
                          RequestTypeAdminMachineControl.resume
                      ? AppColors.azulBebe
                      : AppColors.cinzaClaro,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.azulEscuro,
                ),
              ),

              ElevatedButton(
                onPressed: isAdminMachineCommandEnabled
                    ? () async {
                        await sendAdminRequest(
                          RequestTypeAdminMachineControl.pause,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      currentAdminMachineRequestType ==
                          RequestTypeAdminMachineControl.pause
                      ? AppColors.cinzaEscuro
                      : AppColors.branco,

                  disabledBackgroundColor:
                      currentAdminMachineRequestType ==
                          RequestTypeAdminMachineControl.pause
                      ? AppColors.azulBebe
                      : AppColors.cinzaClaro,
                ),
                child: Icon(Icons.pause_rounded, color: AppColors.azulEscuro),
              ),

              ElevatedButton(
                onPressed: isAdminMachineCommandEnabled
                    ? () async {
                        await sendAdminRequest(
                          RequestTypeAdminMachineControl.ejectManual,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      currentAdminMachineRequestType ==
                          RequestTypeAdminMachineControl.ejectManual
                      ? AppColors.cinzaEscuro
                      : AppColors.branco,

                  disabledBackgroundColor:
                      currentAdminMachineRequestType ==
                          RequestTypeAdminMachineControl.ejectManual
                      ? AppColors.azulBebe
                      : AppColors.cinzaClaro,
                ),
                child: Icon(Icons.eject, color: AppColors.azulEscuro),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget buildCameraOptions() => Container(
    padding: EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppColors.branco,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.azulEscuro, width: 2),
    ),

    child: ExpandablePanel(
      header: Center(
        child: ListTile(
          title: Text(
            "Opções da máquina",
            textAlign: TextAlign.center,
            style: AppStyles.textStyleOptionsTab,
          ),
        ),
      ),
      collapsed: SizedBox(width: 1),
      expanded: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ID da máquina: $machineID',
            style: AppStyles.textStyleSectorSubtextTitleCard,
          ),
        ],
      ),
    ),
  );

  Future<void> sendAdminRequest(RequestTypeAdminMachineControl request) async {
    try {
      // Disables clicking on all buttons and resets the request status to default
      setState(() {
        isAdminMachineCommandEnabled = false;
        currentAdminMachineRequestStatus =
            RequestStatusAdminMachineControl.none;
      });

      // Chooses request command
      String command;

      if (request == RequestTypeAdminMachineControl.resume) {
        setState(() {
          currentAdminMachineRequestType =
              RequestTypeAdminMachineControl.resume;
        });
        command = 'RESUME';
      } else if (request == RequestTypeAdminMachineControl.pause) {
        setState(() {
          currentAdminMachineRequestType = RequestTypeAdminMachineControl.pause;
        });
        command = 'PAUSE';
      } else {
        setState(() {
          currentAdminMachineRequestType =
              RequestTypeAdminMachineControl.ejectManual;
        });
        command = 'EJECT_MANUAL';
      }

      // Sends the request command
      currentAdminMachineRequestStatus = await requestMethods
          .sendAdminMachineRequest(machineID, command);

      if (currentAdminMachineRequestStatus ==
          RequestStatusAdminMachineControl.userNotAdmin) {}

      setState(() {
        currentAdminMachineRequestType = RequestTypeAdminMachineControl.none;
        isAdminMachineCommandEnabled = true;
      });
    } catch (e) {
      setState(() {
        currentAdminMachineRequestType = RequestTypeAdminMachineControl.none;
        isAdminMachineCommandEnabled = true;
      });
    }
  }

  Widget buildSendingAdminRequestStatus() {
    if (currentAdminMachineRequestStatus !=
        RequestStatusAdminMachineControl.none) {
      switch (currentAdminMachineRequestStatus) {
        case RequestStatusAdminMachineControl.sucess:
          removeRequestStatusFromUI();
          return CustomAdminMachineRequestWidget(
            text: 'Sucesso!',
            requestType: currentAdminMachineRequestType,
            requestStatus: currentAdminMachineRequestStatus,
            backgroundColor: AppColors.verde,
            circularProgressIndicatorColor: AppColors.preto,
          );
        case RequestStatusAdminMachineControl.fail:
          removeRequestStatusFromUI();
          return CustomAdminMachineRequestWidget(
            text: 'Falha',
            requestType: currentAdminMachineRequestType,
            requestStatus: currentAdminMachineRequestStatus,
            backgroundColor: AppColors.vermelho,
            circularProgressIndicatorColor: AppColors.preto,
          );

        case RequestStatusAdminMachineControl.userNotAdmin:
          /*Future.microtask(() {
            if (!mounted) return;
            AwesomeDialog(
              context: context,
              dialogType: DialogType.warning,
              animType: AnimType.topSlide,
              titleTextStyle: AppStyles.textStyleAwesomeDialogTitle,
              descTextStyle: AppStyles.textStyleAwesomeDialogDescription,
              buttonsTextStyle: AppStyles.textStyleAwesomeDialogButton,
              title: "Aviso",
              desc:
                  "Você não possui permissões de administrador para executar esta ação.",
              btnOkColor: AppColors.azulEscuro,
              btnOkText: "OK",
              btnOkOnPress: () {
                Navigator.pop(context);
              },
              dismissOnTouchOutside: false,
              dismissOnBackKeyPress: false,
            ).show();
          });*/

          setState(() {
            isAdminMachineCommandEnabled = false;
          });
          return CustomAdminMachineRequestWidget(
            text: 'Sem permissões de administrador',
            requestType: currentAdminMachineRequestType,
            requestStatus: currentAdminMachineRequestStatus,
            backgroundColor: AppColors.amarelo,
            circularProgressIndicatorColor: AppColors.preto,
          );

        default:
      }
    } else {
      if (currentAdminMachineRequestType ==
          RequestTypeAdminMachineControl.pause) {
        return CustomAdminMachineRequestWidget(
          text: 'Pausando...',
          requestType: currentAdminMachineRequestType,
          requestStatus: currentAdminMachineRequestStatus,
          backgroundColor: AppColors.amarelo,
          circularProgressIndicatorColor: AppColors.preto,
        );
      } else if (currentAdminMachineRequestType ==
          RequestTypeAdminMachineControl.resume) {
        return CustomAdminMachineRequestWidget(
          text: 'Retomando...',
          requestType: currentAdminMachineRequestType,
          requestStatus: currentAdminMachineRequestStatus,
          backgroundColor: AppColors.amarelo,
          circularProgressIndicatorColor: AppColors.preto,
        );
      } else if (currentAdminMachineRequestType ==
          RequestTypeAdminMachineControl.ejectManual) {
        return CustomAdminMachineRequestWidget(
          text: 'Ejetando...',
          requestType: currentAdminMachineRequestType,
          requestStatus: currentAdminMachineRequestStatus,
          backgroundColor: AppColors.amarelo,
          circularProgressIndicatorColor: AppColors.preto,
        );
      }
    }
    return SizedBox(width: 1);
  }

  void removeRequestStatusFromUI() {
    Future.delayed(Duration(seconds: 2), () {
      // Checks if there is any request being sent before removing
      if (currentAdminMachineRequestType ==
          RequestTypeAdminMachineControl.none) {
        setState(() {
          currentAdminMachineRequestStatus =
              RequestStatusAdminMachineControl.none;
        });
      }
    });
  }
}
