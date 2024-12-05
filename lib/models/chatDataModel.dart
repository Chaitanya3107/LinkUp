// to pass user data
import 'package:link_up/models/messageModel.dart';
import 'package:link_up/models/userDataModel.dart';

class ChatDataModel {
  final MessageModel message;
  final List<UserData> users;
  ChatDataModel({required this.message, required this.users});
}
