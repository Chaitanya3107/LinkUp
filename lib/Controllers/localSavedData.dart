import 'package:shared_preferences/shared_preferences.dart';

class LocalSavedData {
  static SharedPreferences? preferences;

  // initialize
  Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }

  // save userId
  static Future<void> saveUserId(String id) async {
    await preferences!.setString("userId", id);
  }

  // read userId
  static String getUserId() {
    return preferences!.getString("userId") ?? "";
  }

  // save user name
  static Future<void> saveName(String name) async {
    await preferences!.setString("name", name);
  }

  // read user name
  static String getName() {
    return preferences!.getString("name") ?? "";
  }

  // save user phone
  static Future<void> savePhone(String phone) async {
    await preferences!.setString("phone", phone);
  }

  // read user phone
  static String getPhone() {
    return preferences!.getString("phone") ?? "";
  }

  // save user profile picture
  static Future<void> saveProfile(String profile) async {
    await preferences!.setString("Profile", profile);
  }

  // read user profile picture
  static String getProfile() {
    return preferences!.getString("Profile") ?? "";
  }

  // clear all data when user logout
  static clearAllData() async {
    final bool data = await preferences!.clear();
    print("Cleared all data from local: $data");
  }
}
