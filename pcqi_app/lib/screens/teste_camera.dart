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
  List<CameraDescription> allAvailableCameras = [];
  List<CameraDescription> frontCameras = [];
  List<CameraDescription> backCameras = [];
  List<CameraDescription> externalCameras = [];
  late CameraController cameraController;
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  bool isCameraInitializationComplete = false;
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

  startCamera(CameraDescription? chosenCamera) async {
    if (chosenCamera != null) {
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
      } catch (e) {
        if (!mounted) return;
        setState(() {
          isCameraInitializationComplete = true;
        });
      }
    }
    if (!mounted) return;
    setState(() {
      isCameraInitializationComplete = true;
    });
  }

  listThenStartCamera() async {
    await listAllCameras();
    await startCamera(selectedCamera);
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionStatus == PermissionStatus.granted) {
      if (!isCameraInitializationComplete) {
        return Scaffold(
          backgroundColor: AppColors.azulBebe,
          body: FutureBuilder<void>(
            future: listThenStartCamera(),
            builder: (context, snapshot) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.azulEscuro),
                    SizedBox(height: 20),
                    Text(
                      "Inicializando câmera...",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 40),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      } else {
        if (selectedCamera != null) {
          return Scaffold(
            backgroundColor: AppColors.azulBebe,
            body: PopScope(
              canPop: false,
              onPopInvokedWithResult: (bool didPop, Object? result) {
                closeScreen();
              },
              child: Row(
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
                                textAlign: TextAlign.center,
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
            ),
          );
        } else {
          return noCameraAvailable();
        }
      }
    } else {
      if (_permissionStatus == PermissionStatus.denied) {
        return cameraDenied();
      }
      return cameraPermanentlyDenied();
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
          onPressed: () => closeScreen(),
        ),
      ),
    );
  }

  void closeScreen() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: "Aviso",
      desc: "Deseja voltar a tela anterior? A transmissão será encerrada.",
      btnOkColor: AppColors.vermelho,
      btnOkText: "Voltar",
      btnCancelText: "Cancelar",
      btnCancelColor: AppColors.azulEscuro,
      btnCancelOnPress: () {},
      btnOkOnPress: () {},
    ).show();
  }

  List<CameraDescription> getCameraListFromCurrentLensDirection(
    CameraDescription cameraDescription,
  ) {
    if (cameraDescription.lensDirection == CameraLensDirection.back) {
      return backCameras;
    }
    return frontCameras;
  }

  Widget cameraDenied() {
    return Scaffold(
      backgroundColor: AppColors.azulBebe,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 150),
            SizedBox(height: 10),
            Text(
              'Por favor, permita o acesso à câmera para continuar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            SizedBox(height: 30),
            SizedBox(
              height: 50,
              width: 400,
              child: ElevatedButton(
                onPressed: requestPermission,
                style: AppStyles.buttonStyle(
                  AppColors.branco,
                  AppColors.azulEscuro,
                ),
                child: Text(
                  textAlign: TextAlign.center,
                  'Permitir acesso à câmera',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cameraPermanentlyDenied() {
    return Scaffold(
      backgroundColor: AppColors.azulBebe,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 150),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Text(
                'Por favor, permita o acesso à câmera nas configurações do aplicativo em seu dispositivo e depois tente novamente.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25),
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 300,
                  child: ElevatedButton(
                    onPressed: _openAppSettings,
                    style: AppStyles.buttonStyle(
                      AppColors.branco,
                      AppColors.azulEscuro,
                    ),
                    child: Text(
                      'Abrir configurações',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                SizedBox(width: 30),

                SizedBox(
                  height: 50,
                  width: 300,
                  child: ElevatedButton(
                    onPressed: requestPermission,
                    style: AppStyles.buttonStyle(
                      AppColors.branco,
                      AppColors.azulEscuro,
                    ),
                    child: Text(
                      'Tentar novamente',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget noCameraAvailable() {
    return Scaffold(
      backgroundColor: AppColors.azulBebe,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 150),
            SizedBox(height: 10),
            Text(
              'Não foi possível identificar câmeras disponíveis neste dispositivo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            SizedBox(height: 30),
            SizedBox(
              height: 50,
              width: 400,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: AppStyles.buttonStyle(
                  AppColors.branco,
                  AppColors.azulEscuro,
                ),
                child: Text(
                  textAlign: TextAlign.center,
                  'Voltar',
                  style: TextStyle(fontSize: 20),
                ),
              ),
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
            startCamera(selectedCamera!);
          });
        },
        style: AppStyles.buttonStyle(AppColors.branco, AppColors.azulEscuro),
        child: Text("Inverter câmera"),
      ),
    );
  }
}
