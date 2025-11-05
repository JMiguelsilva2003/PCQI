import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/services/request_methods.dart';
import 'package:pcqi_app/services/shared_preferences_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late RequestMethods requestMethods;

  @override
  void initState() {
    super.initState();
    requestMethods = RequestMethods(context: context);

    Future.microtask(() async {
      await checkLogin();
    });
  }

  Future<void> checkLogin() async {
    if (SharedPreferencesHelper.getRefreshToken() != null &&
        SharedPreferencesHelper.getRefreshToken()!.length > 2) {
      await requestMethods.autoLogin();
    } else {
      Navigator.pushReplacementNamed(context, '/landingpage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.azulEscuro),
            SizedBox(height: 20),
            Text("Carregando...", style: AppStyles.textStyleTituloSecundario),
          ],
        ),
      ),
    );
  }
}
