import 'package:flutter/material.dart';
import 'package:pcqi_app/screens/cadastro.dart';
import 'package:pcqi_app/screens/landing_page.dart';

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
