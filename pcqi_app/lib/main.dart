import 'package:flutter/material.dart';
import 'package:pcqi_app/screens/cadastro.dart';
import 'package:pcqi_app/screens/homepage.dart';
import 'package:pcqi_app/screens/landing_page.dart';
import 'package:pcqi_app/screens/login.dart';
import 'package:pcqi_app/screens/teste_camera.dart';
import 'package:pcqi_app/services/shared_preferences_helper.dart';

Future main() async {
  // Configuring SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TesteCamera(),
      routes: {
        // '/': (context) => LandingPage(),
        '/login': (context) => Login(),
        '/cadastro': (context) => Cadastro(),
        '/homepage': (context) => Homepage(),
      },
    );
  }
}
