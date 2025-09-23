import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => {Navigator.pushNamed(context, '/login')},
              child: Text("Entrar"),
            ),
            ElevatedButton(
              onPressed: () => {Navigator.pushNamed(context, '/cadastro')},
              child: Text("Cadastrar"),
            ),
          ],
        ),
      ),
    );
  }
}
