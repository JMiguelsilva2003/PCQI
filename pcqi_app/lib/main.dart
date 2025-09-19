import 'package:flutter/material.dart';
import 'package:pcqi_app/pages/cadastro/cadastro.dart';
import 'package:pcqi_app/pages/landing_page/landing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LandingPage(),
      routes: {
        // '/': (context) => LandingPage(),
        // '/login': (context) => Login(),
        '/cadastro': (context) => Cadastro(),
      },
    );
  }
}
