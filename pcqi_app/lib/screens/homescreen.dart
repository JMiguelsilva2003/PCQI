import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_styles.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Usuário logado",
          style: AppStyles.textStyleTituloSecundario,
        ),
      ),
    );
  }
}
