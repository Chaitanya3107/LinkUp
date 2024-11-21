import 'package:flutter/material.dart';
import 'package:link_up/Constant/chatMessage.dart';
import 'package:link_up/Constant/colors.dart';
import 'package:link_up/models/messageModel.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List messages = [
    MessageModel(
        message: "Hello",
        sender: "101",
        receiver: "202",
        timestamp: DateTime(2024, 11, 1),
        isSeenByReceiver: true,
        isImage: false),
    MessageModel(
        message: "Hi",
        sender: "202",
        receiver: "101",
        timestamp: DateTime(2024, 11, 1),
        isSeenByReceiver: true,
        isImage: false),
    MessageModel(
        message: "Kaisa hai bhai",
        sender: "101",
        receiver: "202",
        timestamp: DateTime(2024, 11, 1),
        isSeenByReceiver: true,
        isImage: false),
    MessageModel(
        message: "Mai thik, tu kaisa hai",
        sender: "202",
        receiver: "101",
        timestamp: DateTime(2024, 11, 1),
        isSeenByReceiver: true,
        isImage: false),
    MessageModel(
        message:
            "Bas mast yarr, aur bata kya chalra aaj kal,phone wagera ni karta",
        sender: "101",
        receiver: "202",
        timestamp: DateTime(2024, 11, 1),
        isSeenByReceiver: true,
        isImage: false),
    MessageModel(
        message: "kuch ni chalra bhai",
        sender: "202",
        receiver: "101",
        timestamp: DateTime(2024, 11, 1),
        isSeenByReceiver: true,
        isImage: false),
    MessageModel(
        message: "Thik hai bhai chala le phir kuch aur photo bej",
        sender: "101",
        receiver: "202",
        timestamp: DateTime(2024, 11, 1),
        isSeenByReceiver: false,
        isImage: true),
    MessageModel(
        message: "le bhai",
        sender: "202",
        receiver: "101",
        timestamp: DateTime(2024, 11, 1),
        isSeenByReceiver: true,
        isImage: true),
  ];

  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        leadingWidth: screenWidth * 0.12,
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: kBackgroundColor,
        title: Row(
          children: [
            const CircleAvatar(),
            SizedBox(
              width: screenWidth * 0.04,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Other User",
                  style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  "Online",
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
                itemCount: messages.length,
                itemBuilder: (context, index) => ChatMessage(
                  msg: messages[index],
                  currentUser: "101",
                  isImage: messages[index].isImage,
                ),
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
                    child: TextFormField(
                  controller: messageController,
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: "Type a message..."),
                )),
                IconButton(onPressed: () {}, icon: const Icon(Icons.image)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
