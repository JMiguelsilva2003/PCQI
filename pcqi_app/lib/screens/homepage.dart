import 'package:flutter/material.dart';
import 'package:pcqi_app/services/shared_preferences_helper.dart';

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
        child: ElevatedButton(
          onPressed: () {
            print(SharedPreferencesHelper.getAccessToken());
          },
          child: Text("Access Token"),
        ),
      ),
    );
  }
}
