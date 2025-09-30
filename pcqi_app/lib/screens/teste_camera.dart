import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marquee/marquee.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:permission_handler/permission_handler.dart';

class TesteCamera extends StatefulWidget {
  const TesteCamera({super.key});

  @override
  State<TesteCamera> createState() => _TesteCameraState();
}

class _TesteCameraState extends State<TesteCamera> {
  late List<CameraDescription> allAvailableCameras = [];
  late List<CameraDescription> frontCameras = [];
  late List<CameraDescription> backCameras = [];
  late List<CameraDescription> externalCameras = [];
  late CameraController cameraController;
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  bool isCameraInitialized = false;
  ResolutionPreset resolutionPreset = ResolutionPreset.high;
  CameraDescription? selectedCamera;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    requestPermission();
  }

  @override
  void dispose() {
    cameraController.stopImageStream();
    cameraController.dispose();
    super.dispose();
  }

  Future<void> requestPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _permissionStatus = status;
    });
  }

  void _openAppSettings() {
    openAppSettings();
  }

  listAllCameras() async {
    allAvailableCameras = await availableCameras();
    if (allAvailableCameras.isEmpty) return [];

    for (var camera in allAvailableCameras) {
      if (camera.lensDirection == CameraLensDirection.back) {
        backCameras.add(camera);
      } else if (camera.lensDirection == CameraLensDirection.front) {
        frontCameras.add(camera);
      } else {
        externalCameras.add(camera);
      }
    }
    if (backCameras.isNotEmpty) {
      selectedCamera = backCameras.first;
    } else if (frontCameras.isNotEmpty) {
      selectedCamera = frontCameras.first;
    } else {
      selectedCamera = externalCameras.first;
    }
  }

  void startCamera(
    List<CameraDescription> cameraType,
    CameraDescription chosenCamera,
  ) async {
    if (cameraType.isNotEmpty) {
      cameraController = CameraController(
        chosenCamera,
        resolutionPreset,
        enableAudio: false,
      );
      try {
        await cameraController.initialize().then(
          (_) => {
            /*cameraController.startImageStream(
            (image) => print(DateTime.now().second),
          ),*/
          },
        );
        if (!mounted) return;
        setState(() {
          isCameraInitialized = true;
        });
      } catch (e) {
        print(e);
      }
    } else {}
  }

  listThenStartCamera() async {
    await listAllCameras();
    startCamera(backCameras, selectedCamera!);
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionStatus == PermissionStatus.granted) {
      if (!isCameraInitialized) {
        return Scaffold(
          body: FutureBuilder<void>(
            future: listThenStartCamera(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              } else {
                return Center(child: CameraPreview(cameraController));
              }
            },
          ),
        );
      } else {
        return Scaffold(
          backgroundColor: AppColors.azulBebe,
          body: Row(
            children: [
              Expanded(
                flex: 2,
                child: Center(child: CameraPreview(cameraController)),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    buildMachineTitle(
                      "Nome da máquina nome da máquina nome da máquina",
                    ),
                    SizedBox(height: 30),

                    Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cinzaClaro,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Opções de câmera",
                            style: AppStyles.textStyleCameraOptions,
                          ),
                          SizedBox(height: 20),
                          buildDropdownMenu(
                            getCameraListFromCurrentLensDirection(
                              selectedCamera!,
                            ),
                          ),
                          SizedBox(height: 10),
                          changeToFrontCamera(),
                        ],
                      ),
                    ),

                    Spacer(),
                    goBackButton(),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    } else {
      return cameraNotAllowed();
    }
  }

  Widget buildMachineTitle(String text) {
    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Marquee(
          text: text,
          style: AppStyles.textStyleMarqueeLib,
          blankSpace: 50,
          velocity: 60,
          pauseAfterRound: Duration(seconds: 2),
        ),
      ),
    );
  }

  Widget buildDropdownMenu(List<CameraDescription> camerasList) {
    return Row(
      children: [
        Text("Câmera:", style: AppStyles.textStyleCameraOptions),
        SizedBox(width: 10),
        DropdownButton<CameraDescription>(
          borderRadius: BorderRadius.circular(8),
          elevation: 0,
          value: selectedCamera,
          items: camerasList.map((camera) {
            return DropdownMenuItem<CameraDescription>(
              value: camera,
              child: Text(camera.name),
            );
          }).toList(),
          onChanged: (camera) {
            setState(() {
              selectedCamera = camera;
            });
          },
        ),
      ],
    );
  }

  Widget goBackButton() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
        child: ElevatedButton(
          style: AppStyles.buttonStyle(AppColors.branco, AppColors.vermelho),
          child: Text("Voltar"),
          onPressed: () => AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            animType: AnimType.scale,
            title: "Aviso",
            desc:
                "Deseja voltar a tela anterior? A transmissão será encerrada.",
            btnOkColor: AppColors.vermelho,
            btnOkText: "Voltar",
            btnCancelText: "Cancelar",
            btnCancelColor: AppColors.azulEscuro,
            btnCancelOnPress: () {},
            btnOkOnPress: () {},
          ).show(),
        ),
      ),
    );
  }

  List<CameraDescription> getCameraListFromCurrentLensDirection(
    CameraDescription cameraDescription,
  ) {
    if (cameraDescription.lensDirection == CameraLensDirection.back) {
      return backCameras;
    }
    return frontCameras;
  }

  Widget cameraNotAllowed() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Camera Permission Status: $_permissionStatus',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: requestPermission,
              child: const Text('Request Camera Permission'),
            ),
            if (_permissionStatus == PermissionStatus.permanentlyDenied)
              Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Please allow camera access to use this feature.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _openAppSettings,
                    child: const Text('Open App Settings'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget changeToFrontCamera() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            if (selectedCamera!.lensDirection == CameraLensDirection.back) {
              selectedCamera = frontCameras.first;
            } else {
              selectedCamera = backCameras.first;
            }
            startCamera(frontCameras, selectedCamera!);
          });
        },
        style: AppStyles.buttonStyle(AppColors.branco, AppColors.azulEscuro),
        child: Text("Inverter câmera"),
      ),
    );
  }
}
