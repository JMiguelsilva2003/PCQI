import 'package:flutter/material.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:pcqi_app/config/app_colors.dart';

class AppStyles {
  /* ----- Títulos ----- */
  static final TextStyle textStyleTitulo = TextStyle(
    fontSize: 40,
    color: AppColors.azulEscuro,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle textStyleTituloSecundario = TextStyle(
    fontSize: 20,
    color: AppColors.cinza,
  );

  static final TextStyle textStyleMarqueeLib = TextStyle(
    fontSize: 30,
    color: AppColors.preto,
  );

  static final TextStyle textStyleCustomListViewCard = TextStyle(fontSize: 20);

  static final TextStyle textStyleForgotPassword = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: AppColors.azulEscuro,
  );

  /* ----- Campos de texto ----- */
  static const TextStyle textFieldTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
  );

  static InputDecoration textFieldDecoration(String hintText) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.azulEscuro, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.vermelho, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.vermelho, width: 2),
      ),
      filled: true,
      fillColor: AppColors.cinzaClaro,
      hintText: hintText,
      hintStyle: TextStyle(color: AppColors.cinzaEscuro),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
    );
  }

  static ButtonStyle buttonStyle(Color textColor, Color backgroundColor) {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  static final TextStyle textStyleCameraOptions = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );

  static final TextStyle textStyleStreamingState = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: AppColors.preto,
  );

  /* ----- Estilos específicos para a biblioteca LoadingIconButton ----- */
  static final LoadingButtonStyle loadingButtonStyle = LoadingButtonStyle(
    backgroundColor: AppColors.azulEscuro,
    foregroundColor: AppColors.azulEscuro,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    borderRadius: 15,
    elevation: 0,
  );

  // A propriedade "textstyle" do objeto LoadingButtonStyle não parece funcionar, então o estilo do texto do botão é definido logo abaixo.
  static final TextStyle loadingButtonTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.branco,
  );
}
