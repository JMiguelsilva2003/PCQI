import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:camera/camera.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marquee/marquee.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/models/image_request_response_model.dart';
import 'package:pcqi_app/models/validation_result.dart';
import 'package:pcqi_app/services/camera_image_converter.dart';
import 'package:pcqi_app/services/http_image_request.dart';
import 'package:pcqi_app/utils/validators.dart';
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
  List<ResolutionPreset> resolutionPresetList = [
    ResolutionPreset.low,
    ResolutionPreset.medium,
    ResolutionPreset.high,
  ];
  late CameraController cameraController;
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  bool isCameraInitializationComplete = false;
  ResolutionPreset currentResolution = ResolutionPreset.low;
  CameraDescription? selectedCamera;
  CameraImageConverter cameraImageConverter = CameraImageConverter();
  HttpImageRequest httpImageRequest = HttpImageRequest();
  bool isStreamRunning = false;
  bool isCurrentlySendingImage = false;

  final GlobalKey<FormState> formKeyServerAddress = GlobalKey<FormState>();
  final TextEditingController inputIp = TextEditingController();
  final FocusNode focusNodeIp = FocusNode();
  bool showFormValidationError = false;

  String resultTextPrediction = "";
  String resultTextConfidence = "";

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
    if (isStreamRunning) {
      cameraController.stopImageStream();
    }
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
    } else /*if (frontCameras.isNotEmpty)*/ {
      selectedCamera = frontCameras.first;
    } /*else {
      selectedCamera = externalCameras.first;
    }*/
  }

  startCamera(CameraDescription? chosenCamera) async {
    if (chosenCamera != null) {
      cameraController = CameraController(
        chosenCamera,
        currentResolution,
        enableAudio: false,
      );
      try {
        await cameraController.initialize();
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
                      style: TextStyle(
                        fontSize: 40,
                        fontFamily: 'Poppins-Regular',
                      ),
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
              onPopInvokedWithResult: (bool didPop, Object? result) async {
                if (isStreamRunning) {
                  await cameraController.stopImageStream();
                }
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitDown,
                  DeviceOrientation.portraitUp,
                ]);
                if (!didPop) {
                  Navigator.pop(context);
                }
              },
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(child: CameraPreview(cameraController)),
                  ),
                  Expanded(
                    flex: 1,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        SizedBox(height: 20),
                        buildMachineTitle(
                          "Nome da máquina nome da máquina nome da máquina",
                        ),
                        SizedBox(height: 30),

                        Column(
                          children: [
                            buildCameraOptions(),
                            buildStreamingOptions(),
                          ],
                        ),

                        SizedBox(height: 30),
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

  Widget buildCameraOptions() => Container(
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
            "Opções de câmera",
            textAlign: TextAlign.center,
            style: AppStyles.textStyleOptionsTab,
          ),
        ),
      ),
      collapsed: SizedBox(width: 1),
      expanded: Column(
        children: [
          buildCameraSelectionDropdownMenu(
            getCameraListFromCurrentLensDirection(selectedCamera!),
          ),
          SizedBox(height: 10),
          buildResolutionSelectionDropdownMenu(resolutionPresetList),
          SizedBox(height: 10),
          if (backCameras.isNotEmpty && frontCameras.isNotEmpty)
            buildChangeCameraFacingButton(),
        ],
      ),
    ),
  );

  Widget buildStreamingOptions() => Container(
    padding: EdgeInsets.all(5),
    margin: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: AppColors.cinzaClaro,
      borderRadius: BorderRadius.circular(10),
    ),

    child: ExpandablePanel(
      header: Center(
        child: ListTile(
          title: Text(
            "Opções de transmissão",
            textAlign: TextAlign.center,
            style: AppStyles.textStyleOptionsTab,
          ),
        ),
      ),
      collapsed: buildStreamingStatus(),
      expanded: Column(
        children: [
          buildStreamingStatus(),
          SizedBox(height: 10),
          //Form(key: formKeyServerAddress, child: buildTextFormServerAddress()),
          SizedBox(height: 10),
          buildRequestResults(),
          SizedBox(height: 10),
          buildStartStopStreamButton(),
        ],
      ),
    ),
  );

  Widget buildStreamingStatus() {
    if (isStreamRunning) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.verde,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.task_alt_rounded),
            SizedBox(width: 5),
            Text(
              "Status: transmitindo frames",
              style: AppStyles.textStyleStreamingState,
            ),
          ],
        ),
      );
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.amarelo,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.pause_circle_outline_rounded),
          SizedBox(width: 5),
          Text(
            "Status: não está transmitindo",
            style: AppStyles.textStyleStreamingState,
          ),
        ],
      ),
    );
  }

  Widget buildTextFormServerAddress() => Padding(
    padding: EdgeInsets.all(8.0),
    child: TextFormField(
      controller: inputIp,
      focusNode: focusNodeIp,
      autofillHints: [AutofillHints.url],
      keyboardType: TextInputType.url,
      enabled: !isStreamRunning,
      buildCounter:
          (
            BuildContext context, {
            int? currentLength,
            int? maxLength,
            bool? isFocused,
          }) => null,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      style: AppStyles.textFieldTextStyle,
      decoration: AppStyles.textFieldDecoration("Endereço do servidor")
          .copyWith(
            fillColor: isStreamRunning ? AppColors.cinza : AppColors.cinzaClaro,
          ),
      textInputAction: TextInputAction.done,
      validator: (value) {
        ValidationResult serverIpValidation =
            Validators.checkServerAddressField(value);
        if (serverIpValidation.shouldThrowValidationError &&
            !showFormValidationError) {
          setState(() {
            showFormValidationError = true;
          });
        }
        return serverIpValidation.message;
      },
      onChanged: onChangedForm,
    ),
  );

  void onChangedForm(String value) {
    if (showFormValidationError) {
      formKeyServerAddress.currentState!.validate();
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

  Widget buildCameraSelectionDropdownMenu(List<CameraDescription> camerasList) {
    return Row(
      children: [
        Text("Câmera:", style: AppStyles.textStyleOptionsTab),
        SizedBox(width: 10),
        DropdownButton<CameraDescription>(
          borderRadius: BorderRadius.circular(8),
          elevation: 0,
          value: selectedCamera,
          items: camerasList.map((camera) {
            return DropdownMenuItem<CameraDescription>(
              value: camera,
              child: Text(camera.name, style: AppStyles.textStyleDropdownItem),
            );
          }).toList(),
          onChanged: (camera) async {
            if (camera != null && camera.name != selectedCamera!.name) {
              if (isStreamRunning) {
                await cameraController.stopImageStream();
              }

              setState(() {
                isStreamRunning = false;
                selectedCamera = camera;
              });
              await startCamera(selectedCamera);
            }
          },
        ),
      ],
    );
  }

  Widget buildResolutionSelectionDropdownMenu(
    List<ResolutionPreset> resolutionPresetList,
  ) {
    return Row(
      children: [
        Text("Resolução:", style: AppStyles.textStyleOptionsTab),
        SizedBox(width: 10),
        DropdownButton<ResolutionPreset>(
          borderRadius: BorderRadius.circular(8),
          elevation: 0,
          value: currentResolution,
          items: resolutionPresetList.map((resolution) {
            return DropdownMenuItem<ResolutionPreset>(
              value: resolution,
              child: Text(
                resolution.name,
                style: AppStyles.textStyleDropdownItem,
              ),
            );
          }).toList(),
          onChanged: (resolution) async {
            if (resolution != null && resolution != currentResolution) {
              if (isStreamRunning) {
                await cameraController.stopImageStream();
              }
              setState(() {
                isStreamRunning = false;
                currentResolution = resolution;
              });
              await startCamera(selectedCamera);
            }
          },
        ),
      ],
    );
  }

  Widget buildStartStopStreamButton() {
    if (!isStreamRunning) {
      return SizedBox(
        height: 50,
        width: double.infinity,
        child: Container(
          margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
          child: ElevatedButton(
            style: AppStyles.buttonStyle(
              AppColors.branco,
              AppColors.azulEscuro,
            ),
            child: Text("Iniciar transmissão"),
            onPressed: () async {
              //bool isValid = checkFormFieldValidation(formKeyServerAddress);
              /*if (isValid) {*/
              sendImageStream();
              setState(() {
                isStreamRunning = true;
              });
            },
            /*}*/
          ),
        ),
      );
    }
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
        child: ElevatedButton(
          style: AppStyles.buttonStyle(AppColors.branco, AppColors.azulEscuro),
          child: Text("Parar transmissão"),
          onPressed: () async {
            if (isStreamRunning) {
              setState(() {
                isStreamRunning = false;
              });
              await cameraController.stopImageStream();
            }
          },
        ),
      ),
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
          onPressed: () async {
            /*closeScreen()*/
            if (isStreamRunning) {
              await cameraController.stopImageStream();
            }
            await SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitDown,
              DeviceOrientation.portraitUp,
            ]);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  bool checkFormFieldValidation(formKey) {
    return formKey.currentState!.validate();
  }

  sendImageStream() async {
    await cameraController.startImageStream((image) async {
      if (isCurrentlySendingImage) return;
      isCurrentlySendingImage = true;
      var convertedImage = await cameraImageConverter.convertImage(image);
      //var convertedImage = await cameraImageConverter.convertCameraImage(image);

      if (convertedImage != null) {
        ImageRequestResponseModel? responseFromServer = await httpImageRequest
            .sendImage(convertedImage /*image.height, image.width*/);
        if (responseFromServer != null) {
          setState(() {
            resultTextPrediction = responseFromServer.prediction!;
            resultTextConfidence = responseFromServer.confidence!;
          });
        }
      }
      isCurrentlySendingImage = false;
    });
  }

  Widget buildRequestResults() => Container(
    margin: EdgeInsets.symmetric(horizontal: 8),
    padding: EdgeInsets.all(4),
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.preto, width: 1),
    ),

    child: Column(
      children: [
        Text("Resultado", style: AppStyles.textStyleOptionsTab),
        Text(
          "prediction: $resultTextPrediction",
          style: AppStyles.textStyleDropdownItem,
        ),
        Text(
          "confidence: $resultTextConfidence",
          style: AppStyles.textStyleDropdownItem,
        ),
      ],
    ),
  );

  /*void closeScreen() {
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
      autoDismiss: true,
      btnOkOnPress: () async {
        if (isStreamRunning) {
          await cameraController.stopImageStream();
        }
        Future.delayed(const Duration(milliseconds: 150), () {
          Navigator.of(context).pop();
        });
      },
    ).show();
  }*/

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
              style: AppStyles.textStyleCameraPermissionScreen.copyWith(
                fontSize: 25,
              ),
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
                  style: AppStyles.textStyleCameraPermissionScreen.copyWith(
                    fontSize: 20,
                  ),
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
                style: AppStyles.textStyleCameraPermissionScreen.copyWith(
                  fontSize: 25,
                ),
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
                      style: AppStyles.textStyleCameraPermissionScreen.copyWith(
                        fontSize: 20,
                      ),
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
                      style: AppStyles.textStyleCameraPermissionScreen.copyWith(
                        fontSize: 20,
                      ),
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
              style: AppStyles.textStyleCameraPermissionScreen.copyWith(
                fontSize: 25,
              ),
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
                  style: AppStyles.textStyleCameraPermissionScreen.copyWith(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChangeCameraFacingButton() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (isStreamRunning) {
            await cameraController.stopImageStream();
          }

          setState(() {
            isStreamRunning = false;
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
