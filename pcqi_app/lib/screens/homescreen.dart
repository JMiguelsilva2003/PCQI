import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/screens/teste_camera.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco, body: Stack(
        children:[
          Center(
            child:  Text("Usuário Logado"),
          ),
        Positioned(
  top: 30,
  right: 30,
  child:FloatingActionButton.extended(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TesteCamera()),
    );
  },
  icon: const Icon(Icons.camera_alt), // ícone
  label: const Text("Câmera"),        // texto ao lado
  backgroundColor: Colors.blue,       // cor do botão
  foregroundColor: Colors.white,      // cor do texto/ícone
),

),

        ],
      ),
    );
  }
}
