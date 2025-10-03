import 'dart:convert';

import 'package:pcqi_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static late SharedPreferences preferences;

  static Future init() async =>
      preferences = await SharedPreferences.getInstance();

  static Future setId(String id) async => await preferences.setString("id", id);

  static String? getId() => preferences.getString("id");

  static Future setAccessToken(String accessToken) async =>
      await preferences.setString("access_token", accessToken);

  static String? getAccessToken() => preferences.getString("access_token");

  static Future setRefreshToken(String refreshToken) async =>
      await preferences.setString("refresh_token", refreshToken);

  static String? getRefreshToken() => preferences.getString("refresh_token");

  static Future setUserModel(UserModel userModel) async =>
      preferences.setString("user", jsonEncode(userModel));

  static getUserModel(String key) {
    final userModel = preferences.getString("user");
    if (userModel != null) {
      return jsonDecode(userModel);
    }
  }

  static Future saveObject(String key, value) async =>
      await preferences.setString(key, jsonEncode(value));

  static getObject(String key) {
    final object = preferences.getString(key);
    if (object != null) {
      return jsonDecode(object);
    }
  }
}
