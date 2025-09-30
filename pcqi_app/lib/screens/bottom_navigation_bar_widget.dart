import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pcqi_app/screens/homepage.dart';
import 'package:pcqi_app/screens/lista_maquinas.dart';
import 'package:pcqi_app/screens/perfil.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  List<PersistentTabConfig> _tabs() => [
    PersistentTabConfig(
      screen: Homepage(),
      item: ItemConfig(
        icon: const Icon(Icons.home_rounded),
        title: "Início",
        iconSize: 30,
      ),
    ),
    PersistentTabConfig(
      screen: ListaMaquinas(),
      item: ItemConfig(
        icon: const Icon(Icons.computer_rounded),
        title: "Máquinas",
        iconSize: 30,
      ),
    ),
    PersistentTabConfig(
      screen: Perfil(),
      item: ItemConfig(
        icon: const Icon(Icons.person_rounded),
        title: "Perfil",
        iconSize: 30,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    return PersistentTabView(
      tabs: _tabs(),
      //gestureNavigationEnabled: true,
      navBarBuilder: (navBarConfig) => Style2BottomNavBar(
        navBarConfig: navBarConfig,
        height: 60,
        itemPadding: EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}
