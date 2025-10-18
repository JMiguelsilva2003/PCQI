import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';

class SimpleAwesomeDialog {
  static void info(String description, BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.topSlide,
      title: "Info",
      titleTextStyle: AppStyles.textStyleAwesomeDialogTitle,
      descTextStyle: AppStyles.textStyleAwesomeDialogDescription,
      buttonsTextStyle: AppStyles.textStyleAwesomeDialogButton,
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
      titleTextStyle: AppStyles.textStyleAwesomeDialogTitle,
      descTextStyle: AppStyles.textStyleAwesomeDialogDescription,
      buttonsTextStyle: AppStyles.textStyleAwesomeDialogButton,
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
      titleTextStyle: AppStyles.textStyleAwesomeDialogTitle,
      descTextStyle: AppStyles.textStyleAwesomeDialogDescription,
      buttonsTextStyle: AppStyles.textStyleAwesomeDialogButton,
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
