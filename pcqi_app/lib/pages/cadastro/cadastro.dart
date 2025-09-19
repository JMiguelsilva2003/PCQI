import 'package:flutter/material.dart';
import 'package:pcqi_app/styles/app_styles.dart';

class Cadastro extends StatelessWidget {
  const Cadastro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título e subtítulo
                  Text("Cadastro", style: AppStyles.textStyleTitulo),
                  Text(
                    "Titulo secundario",
                    style: AppStyles.textStyleTituloSecundario,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 35, left: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back_ios_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
