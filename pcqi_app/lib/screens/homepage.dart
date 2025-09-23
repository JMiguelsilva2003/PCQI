import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_styles.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
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
