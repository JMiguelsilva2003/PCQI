import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';

class SimpleAwesomeDialog {
  static void info(String description, BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.topSlide,
      title: "Info",
      desc: description,
      btnOkColor: AppColors.azulEscuro,
      btnOkText: "OK",
      btnOkOnPress: () {},
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  static void error(String description, BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.topSlide,
      title: "Erro",
      desc: description,
      btnOkColor: AppColors.vermelho,
      btnOkText: "OK",
      btnOkOnPress: () {},
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  static void warning(String description, BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.topSlide,
      title: "Aviso",
      desc: description,
      btnOkColor: AppColors.azulEscuro,
      btnOkText: "OK",
      btnOkOnPress: () {},
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }
}
