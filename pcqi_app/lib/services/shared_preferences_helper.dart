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
}
