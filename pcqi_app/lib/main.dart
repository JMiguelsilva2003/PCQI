import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pcqi_app/providers/provider_model.dart';
import 'package:pcqi_app/providers/provider_sector_list.dart';
import 'package:pcqi_app/screens/forgot_password.dart';
import 'package:pcqi_app/screens/homepage_widget.dart';
import 'package:pcqi_app/screens/machine_edit.dart';
import 'package:pcqi_app/screens/register.dart';
import 'package:pcqi_app/screens/landing_page.dart';
import 'package:pcqi_app/screens/login.dart';
import 'package:pcqi_app/screens/splash_screen.dart';
import 'package:pcqi_app/screens/camera.dart';
import 'package:pcqi_app/services/shared_preferences_helper.dart';
import 'package:provider/provider.dart';

Future main() async {
  // Configuring SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesHelper.init();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProviderModel()),
        ChangeNotifierProvider(create: (context) => ProviderSectorList()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      routes: {
        '/landingpage': (context) => LandingPage(),
        '/login': (context) => Login(),
        '/forgot-password': (context) => ForgotPassword(),
        '/cadastro': (context) => Register(),
        '/homepage': (context) => HomepageWidget(),
        '/camera': (context) => Camera(),
        '/machine-edit': (context) => MachineEdit(),
      },
    );
  }
}
