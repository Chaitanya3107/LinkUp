import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:link_up/Constant/colors.dart';
import 'package:link_up/Constant/formatDate.dart';
import 'package:link_up/Controllers/appwrite_controllers.dart';
import 'package:link_up/models/chatDataModel.dart';
import 'package:link_up/models/userDataModel.dart';
import 'package:link_up/stateManagement/chatProvider.dart';
import 'package:link_up/stateManagement/userDataProvider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String currentUserId = "";

  @override
  void initState() {
    super.initState();
    currentUserId =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    Provider.of<ChatProvider>(context, listen: false).loadChats(currentUserId);
    // when user load home screen, status turns true
    updateOnlineStatus(status: true, userId: currentUserId);
    susbscribeToRealtime(userId: currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: kBackgroundColor,
        title: const Text(
          "Chats",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.05),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, "/profile"),
              child: Consumer<UserDataProvider>(
                builder: (context, value, child) {
                  final userProfilePic = value.getUserProfilePic;
                  final isProfilePicAvailable =
                      userProfilePic != null && userProfilePic.isNotEmpty;
                  return CircleAvatar(
                    backgroundImage: isProfilePicAvailable
                        ? CachedNetworkImageProvider(
                            "https://cloud.appwrite.io/v1/storage/buckets/673f8b5b0012443f5422/files/$userProfilePic/view?project=673f893e0039487ed031&project=673f893e0039487ed031&mode=admin",
                          )
                        : const AssetImage("assets/user.png")
                            as ImageProvider<Object>,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ChatProvider>(builder: (context, value, child) {
        if (value.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (value.getAllChats.isEmpty) {
          return const Center(
            child: Text("No chats"),
          );
        } else {
          List otherUsers = value.getAllChats.keys.toList();
          return ListView.builder(
            itemCount: otherUsers.length,
            itemBuilder: (context, index) {
              List<ChatDataModel> chatData =
                  value.getAllChats[otherUsers[index]]!;
              int totalChats = chatData.length;

              if (totalChats > 0) {
                UserData otherUser = chatData[0].users.length > 1 &&
                        chatData[0].users[0].userId == currentUserId
                    ? chatData[0].users[1]
                    : chatData[0].users[0];

                // Calculate unread messages
                int unreadMsg = chatData
                    .where((chat) =>
                        chat.message.sender != currentUserId &&
                        !chat.message.isSeenByReceiver)
                    .length;

                return ListTile(
                  onTap: () => Navigator.pushNamed(context, "/chat",
                      arguments: otherUser),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: otherUser.profilePic == null
                            ? const AssetImage("assets/user.png")
                                as ImageProvider<Object>
                            : CachedNetworkImageProvider(
                                "https://cloud.appwrite.io/v1/storage/buckets/673f8b5b0012443f5422/files/${otherUser.profilePic}/view?project=673f893e0039487ed031&project=673f893e0039487ed031&mode=admin",
                              ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          // storing user data in otheUser
                          backgroundColor: otherUser.isOnline == true
                              ? Colors.green
                              : Colors.grey.shade600,
                          radius: screenWidth * 0.013,
                        ),
                      ),
                    ],
                  ),
                  title: Text(otherUser.name!),
                  subtitle: Text(
                    "${chatData[totalChats - 1].message.sender == currentUserId ? "You : " : ""}${chatData[totalChats - 1].message.isImage == true ? "Sent an image" : chatData[totalChats - 1].message.message}",
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      unreadMsg > 0
                          ? CircleAvatar(
                              backgroundColor: kPrimaryColor,
                              radius: screenWidth * 0.025,
                              child: Text(
                                unreadMsg.toString(),
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white),
                              ),
                            )
                          : const SizedBox(),
                      SizedBox(height: screenWidth * 0.02),
                      Text(formatDate(
                          chatData[totalChats - 1].message.timestamp)),
                    ],
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kBackgroundColor,
        onPressed: () {
          Navigator.pushNamed(context, "/search");
        },
        child: const Icon(
          Icons.add,
          color: kPrimaryColor,
        ),
      ),
    );
  }
}
