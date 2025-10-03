import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pcqi_app/screens/homepage_widget.dart';
import 'package:pcqi_app/screens/register.dart';
import 'package:pcqi_app/screens/homescreen.dart';
import 'package:pcqi_app/screens/landing_page.dart';
import 'package:pcqi_app/screens/login.dart';
import 'package:pcqi_app/screens/teste_camera.dart';
import 'package:pcqi_app/services/shared_preferences_helper.dart';

Future main() async {
  // Configuring SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesHelper.init();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
        //'/': (context) => LandingPage(),
        '/login': (context) => Login(),
        '/cadastro': (context) => Register(),
        //'/homepage': (context) => HomepageWidget(),
        //'/camera': (context) => TesteCamera(),
      },
    );
  }
}
