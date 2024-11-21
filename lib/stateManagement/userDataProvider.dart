import 'package:flutter/material.dart';
import 'package:link_up/Controllers/appwrite_controllers.dart';
import 'package:link_up/Controllers/localSavedData.dart';
import 'package:link_up/models/userDataModel.dart';

class UserDataProvider extends ChangeNotifier {
  String _userId = "";
  String _userName = "";
  String _userProfilePic = "";
  String _userPhoneNumber = "";
  String _userDeviceToken = "";

  String get getUserId => _userId;
  String get getUserName => _userName;
  String get getUserProfilePic => _userProfilePic;
  String get getUserPhoneNumber => _userPhoneNumber;
  String get getUserDeviceToken => _userDeviceToken;

  // to load data from the device(local storage)
  Future<void> loadDataFromLocal() async {
    _userId = LocalSavedData.getUserId();
    _userName = LocalSavedData.getName();
    _userProfilePic = LocalSavedData.getProfile();
    _userPhoneNumber = LocalSavedData.getPhone();
    print("Data loaded from local $_userId, $_userPhoneNumber $_userName");
    notifyListeners();
  }

  // load data from our appwrite database user collection
  Future<void> loadUserDataAppwrite(String userId) async {
    UserData? userData = await getUserDetails(userId: userId);
    if (userData != null) {
      _userName = userData.name ?? "";
      _userProfilePic = userData.profilePic ?? "";
      print("Data loaded from Appwrite $_userName, $_userProfilePic");
    }
  }

  // set userID
  void setUserId(String id) {
    _userId = id;
    LocalSavedData.saveUserId(id);
    notifyListeners();
  }

  // set user name
  void setName(String name) {
    _userName = name;
    LocalSavedData.saveName(name);
    notifyListeners();
  }

  // set user phone number
  void setPhone(String phone) {
    _userPhoneNumber = phone;
    LocalSavedData.savePhone(phone);
    notifyListeners();
  }

  // set user profile pic
  void setProfilePic(String profile) {
    _userProfilePic = profile;
    LocalSavedData.saveProfile(profile);
    notifyListeners();
  }

  void setDeviceToken(String token) {
    _userDeviceToken = token;
    notifyListeners();
  }

  void dataFromLocal() {}
}
