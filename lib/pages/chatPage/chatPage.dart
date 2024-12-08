import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:link_up/Constant/chatMessage.dart';
import 'package:link_up/Constant/colors.dart';
import 'package:link_up/Controllers/appwrite_controllers.dart';
import 'package:link_up/models/messageModel.dart';
import 'package:link_up/models/userDataModel.dart';
import 'package:link_up/stateManagement/chatProvider.dart';
import 'package:link_up/stateManagement/userDataProvider.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  TextEditingController editMessageController = TextEditingController();
  late String currentUserId;
  late String currentUserName;
  FilePickerResult? _filePickerResult;

  @override
  void initState() {
    currentUserId =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    currentUserName =
        Provider.of<UserDataProvider>(context, listen: false).getUserName;
    Provider.of<ChatProvider>(context, listen: false).loadChats(currentUserId);
    super.initState();
  }

  // to open file picker
  void _openFilePicker(UserData receiver) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);
    setState(() {
      _filePickerResult = result;
      uploadAllImage(receiver);
    });
  }

  // to upload files to our storage bucket and our database
  void uploadAllImage(UserData receiver) async {
    if (_filePickerResult != null) {
      // loop for multiple files
      _filePickerResult!.paths.forEach((path) {
        if (path != null) {
          var file = File(path);
          final fileByte = file.readAsBytesSync();
          final inputFile = InputFile.fromBytes(
              bytes: fileByte, filename: file.path.split("/").last);

          // saving image to our storage bucket
          saveImageBucket(image: inputFile).then((imageId) {
            if (imageId != null) {
              createNewChat(
                      message: imageId,
                      senderId: currentUserId,
                      receiverId: receiver.userId,
                      isImage: true)
                  .then((value) {
                // after new chat is created , updating it in provider
                if (value != null) {
                  // message will be in the form of message model
                  Provider.of<ChatProvider>(context, listen: false).addMessage(
                      MessageModel(
                          message: imageId,
                          sender: currentUserId,
                          receiver: receiver.userId,
                          timestamp: DateTime.now(),
                          isImage: true,
                          isSeenByReceiver: false),
                      currentUserId,
                      [UserData(phone: "", userId: currentUserId), receiver]);
                }
              });
            }
          });
        }
      });
    } else {
      print("File pick cancel by user");
    }
  }

  void _sendMessage({required UserData receiver}) {
    if (messageController.text.isNotEmpty) {
      setState(() {
        createNewChat(
          message: messageController.text,
          senderId: currentUserId,
          receiverId: receiver.userId,
          isImage: false,
        ).then((messageId) {
          if (messageId != null) {
            // Create the message model with the messageId
            Provider.of<ChatProvider>(context, listen: false).addMessage(
              MessageModel(
                message: messageController.text,
                sender: currentUserId,
                receiver: receiver.userId,
                timestamp: DateTime.now(),
                isSeenByReceiver: false,
                messageId: messageId, // Use the returned messageId here
              ),
              currentUserId,
              [UserData(phone: "", userId: currentUserId), receiver],
            );
            // Clear the message input field after sending
            messageController.clear();
            print("Message id is $messageId");
          } else {
            print("Error: Message could not be sent.");
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Handle arguments safely
    UserData? receiver =
        ModalRoute.of(context)?.settings.arguments as UserData?;
    if (receiver == null) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          title: const Text("Chat"),
        ),
        body: const Center(child: Text("Invalid user data")),
      );
    }

    return Consumer<ChatProvider>(
      builder: (context, value, child) {
        // getAllChats return map of user name, receiver name and list of chats(receiver.userId)
        final userAndOtherChats = value.getAllChats[receiver.userId] ?? [];

        bool? otherUserOnline = userAndOtherChats.isNotEmpty
            ? userAndOtherChats[0].users[0].userId == receiver.userId
                ? userAndOtherChats[0].users[0].isOnline
                : userAndOtherChats[0].users[1].isOnline
            : false;

        // list of message received to current user
        List<String> receiveMsgList = [];
        for (var chat in userAndOtherChats) {
          // current user is receiver
          if (chat.message.receiver == currentUserId) {
            if (chat.message.isSeenByReceiver == false) {
              receiveMsgList.add(chat.message.messageId!);
            }
          }
        }

        updateIsSeen(chatIds: receiveMsgList);

        return Scaffold(
          backgroundColor: kBackgroundColor,
          appBar: AppBar(
            leadingWidth: screenWidth * 0.12,
            scrolledUnderElevation: 0,
            elevation: 0,
            backgroundColor: kBackgroundColor,
            title: Row(
              children: [
                CircleAvatar(
                    backgroundImage: receiver.profilePic == "" ||
                            receiver.profilePic == null
                        ? const AssetImage("assets/user.png") as ImageProvider
                        : CachedNetworkImageProvider(
                            "https://cloud.appwrite.io/v1/storage/buckets/673f8b5b0012443f5422/files/${receiver.profilePic}/view?project=673f893e0039487ed031&project=673f893e0039487ed031&mode=admin")),
                SizedBox(
                  width: screenWidth * 0.04,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receiver.name ?? "Unknown User",
                      style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      otherUserOnline == true ? "Online" : "Offline",
                      style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: ListView.builder(
                    reverse: true,
                    itemCount: userAndOtherChats.length,
                    itemBuilder: (context, index) {
                      // extracting details from userAndOtherChats
                      final msg = userAndOtherChats[
                              userAndOtherChats.length - 1 - index]
                          .message;
                      print(userAndOtherChats.length);
                      return GestureDetector(
                        onLongPress: () {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: msg.isImage == true
                                        ? const Text(
                                            "Choose what you want to do with this image")
                                        : Text(
                                            "${msg.message.length > 20 ? msg.message.substring(0, 20) : msg.message}..."),
                                    content: msg.isImage == true
                                        ? Text(msg.sender == currentUserId
                                            ? "Delete this image"
                                            : "This image can't be deleted")
                                        : Text(msg.sender == currentUserId
                                            ? "Choose what you want to do with this message"
                                            : "This image can't be modified"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Cancel")),
                                      msg.sender == currentUserId
                                          ? TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                editMessageController.text =
                                                    msg.message;
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                          title: const Text(
                                                              "Edit this message"),
                                                          content: TextFormField(
                                                              controller:
                                                                  editMessageController,
                                                              maxLines: 10),
                                                          actions: [
                                                            TextButton(
                                                                onPressed: () {
                                                                  editChat(
                                                                      chatId: msg
                                                                          .messageId!,
                                                                      message:
                                                                          editMessageController
                                                                              .text);
                                                                  Navigator.pop(
                                                                      context);
                                                                  editMessageController
                                                                      .text = "";
                                                                },
                                                                child:
                                                                    const Text(
                                                                        "Ok")),
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: const Text(
                                                                    "Cancel"))
                                                          ],
                                                        ));
                                              },
                                              child: const Text("Edit"))
                                          : const SizedBox(),
                                      msg.sender == currentUserId
                                          ? TextButton(
                                              onPressed: () {
                                                print(
                                                    "Message id is ${msg.messageId} ");
                                                Provider.of<ChatProvider>(
                                                        context,
                                                        listen: false)
                                                    .deleteMessage(
                                                        msg, currentUserId);
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Delete"))
                                          : const SizedBox(),
                                    ],
                                  ));
                        },
                        child: ChatMessage(
                          isImage: msg.isImage ?? false,
                          msg: msg,
                          currentUser: currentUserId,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color.fromARGB(50, 155, 147, 147),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      onSubmitted: (value) {
                        _sendMessage(receiver: receiver);
                      },
                      controller: messageController,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type a message..."),
                    )),
                    IconButton(
                        onPressed: () {
                          _openFilePicker(receiver);
                        },
                        icon: const Icon(Icons.image)),
                    IconButton(
                        onPressed: () {
                          _sendMessage(receiver: receiver);
                        },
                        icon: const Icon(Icons.send)),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
