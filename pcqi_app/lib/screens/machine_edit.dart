import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/models/app_enums.dart';
import 'package:pcqi_app/services/request_methods.dart';

class MachineEdit extends StatefulWidget {
  const MachineEdit({super.key});

  @override
  State<MachineEdit> createState() => _MachineEditState();
}

class _MachineEditState extends State<MachineEdit> {
  late String machineID;
  late RequestMethods requestMethods;

  SendingRequest lastRequest = SendingRequest.none;
  bool isAdminMachineCommandEnabled = true;

  @override
  void initState() {
    super.initState();
    requestMethods = RequestMethods(context: context);
  }

  @override
  Widget build(BuildContext context) {
    machineID = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Editar máquina"),
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cinzaClaro,
              borderRadius: BorderRadius.circular(10),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: isAdminMachineCommandEnabled
                            ? () async {
                                await sendAdminRequest(SendingRequest.resume);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lastRequest == SendingRequest.resume
                              ? AppColors.cinzaEscuro
                              : AppColors.branco,

                          disabledBackgroundColor:
                              lastRequest == SendingRequest.resume
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
                                await sendAdminRequest(SendingRequest.pause);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lastRequest == SendingRequest.pause
                              ? AppColors.cinzaEscuro
                              : AppColors.branco,

                          disabledBackgroundColor:
                              lastRequest == SendingRequest.pause
                              ? AppColors.azulBebe
                              : AppColors.cinzaClaro,
                        ),
                        child: Icon(
                          Icons.pause_rounded,
                          color: AppColors.azulEscuro,
                        ),
                      ),

                      ElevatedButton(
                        onPressed: isAdminMachineCommandEnabled
                            ? () async {
                                await sendAdminRequest(
                                  SendingRequest.ejectManual,
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              lastRequest == SendingRequest.ejectManual
                              ? AppColors.cinzaEscuro
                              : AppColors.branco,

                          disabledBackgroundColor:
                              lastRequest == SendingRequest.ejectManual
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
          ),
        ],
      ),
    );
  }

  Future<void> sendAdminRequest(SendingRequest request) async {
    try {
      setState(() {
        isAdminMachineCommandEnabled = false;
      });

      if (request == SendingRequest.resume) {
        setState(() {
          lastRequest = SendingRequest.resume;
        });
        bool? isRequestSucessfull = await requestMethods
            .sendAdminMachineRequest(machineID, 'RESUME');
      } else if (request == SendingRequest.pause) {
        setState(() {
          lastRequest = SendingRequest.pause;
        });
        bool? isRequestSucessfull = await requestMethods
            .sendAdminMachineRequest(machineID, 'PAUSE');
      } else if (request == SendingRequest.ejectManual) {
        setState(() {
          lastRequest = SendingRequest.ejectManual;
        });
        bool? isRequestSucessfull = await requestMethods
            .sendAdminMachineRequest(machineID, 'EJECT_MANUAL');
      }

      setState(() {
        lastRequest = SendingRequest.none;
        isAdminMachineCommandEnabled = true;
      });
    } catch (e) {
      setState(() {
        lastRequest = SendingRequest.none;
        isAdminMachineCommandEnabled = true;
      });
    }
  }
}
