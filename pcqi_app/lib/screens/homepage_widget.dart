import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/screens/homescreen.dart';
import 'package:pcqi_app/screens/sectors.dart';
import 'package:pcqi_app/screens/perfil.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class HomepageWidget extends StatelessWidget {
  const HomepageWidget({super.key});

  List<PersistentTabConfig> _tabs() => [
    PersistentTabConfig(
      screen: Homescreen(),
      item: ItemConfig(
        icon: const Icon(Icons.home_rounded),
        title: "Início",
        iconSize: 30,
        textStyle: AppStyles.textStyleBottomNavBar,
      ),
    ),
    PersistentTabConfig(
      screen: Sectors(),
      item: ItemConfig(
        icon: const Icon(Icons.factory_rounded),
        title: "Setores",
        iconSize: 30,
        textStyle: AppStyles.textStyleBottomNavBar,
      ),
    ),
    PersistentTabConfig(
      screen: Perfil(),
      item: ItemConfig(
        icon: const Icon(Icons.person_rounded),
        title: "Perfil",
        iconSize: 30,
        textStyle: AppStyles.textStyleBottomNavBar,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
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
