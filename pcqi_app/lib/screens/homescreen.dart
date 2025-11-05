import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/screens/teste_camera.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart'
    as PersistentBottomNavBarV2;

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      body: Stack(
        children: [
          Center(
            child: Text("Bem vindo", style: AppStyles.textStyleForgotPassword),
          ),
          Positioned(
            top: 30,
            right: 30,
            child: FloatingActionButton.extended(
              onPressed: () {
                PersistentBottomNavBarV2.pushWithoutNavBar(
                  context,
                  MaterialPageRoute(builder: (context) => const TesteCamera()),
                );
              },
              icon: const Icon(Icons.camera_alt), // ícone
              label: const Text(
                "Câmera",
                style: TextStyle(fontFamily: 'Poppins-Regular'),
              ),
              backgroundColor: AppColors.azulEscuro,
              foregroundColor: AppColors.branco,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
