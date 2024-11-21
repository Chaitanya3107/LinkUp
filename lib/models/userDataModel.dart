class UserData {
  final String? name;
  final String phone;
  final String userId;
  final String? profilePic;
  final String? deviceToken;
  final bool? isOnline;

  UserData(
      {this.name,
      required this.phone,
      required this.userId,
      this.profilePic,
      this.deviceToken,
      this.isOnline});

  // convert document data to userData
  factory UserData.toMap(Map<String, dynamic> map) {
    return UserData(
        phone: map["phone_no"] ?? "",
        userId: map["userId"] ?? "",
        name: map["name"] ?? "",
        profilePic: map["profile_pic"] ?? "",
        deviceToken: map["device_token"] ?? "",
        isOnline: map["isOnline"] ?? false);
  }
}
