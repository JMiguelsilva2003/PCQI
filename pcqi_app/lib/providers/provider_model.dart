import 'package:flutter/material.dart';
import 'package:pcqi_app/models/user_model.dart';

class ProviderModel extends ChangeNotifier {
  UserModel userData = UserModel();

  UserModel get getUserData => userData;

  void setUser(UserModel user) {
    userData = user;
    notifyListeners();
  }

  void setUsername(String newName) {
    userData.name = newName;
    notifyListeners();
  }
}
