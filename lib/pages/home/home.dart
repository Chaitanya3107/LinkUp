import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:link_up/Constant/colors.dart';
import 'package:link_up/stateManagement/userDataProvider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // Get screen width to calculate dynamic padding/margins
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kBackgroundColor,

      // AppBar with no elevation, custom background, and an avatar in the actions
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
                })),
          ),
        ],
      ),

      // Main content: list of chat items
      body: ListView.builder(
        itemCount: 10, // Number of chat tiles
        itemBuilder: (context, index) => ListTile(
          // Opens chat page on tap
          onTap: () => Navigator.pushNamed(context, "/chat"),
          leading: Stack(
            children: [
              // User avatar
              const CircleAvatar(
                backgroundImage: AssetImage("assets/user.png"),
              ),
              // Online status indicator positioned at bottom-right
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: screenWidth * 0.013,
                ),
              ),
            ],
          ),
          // Chat item main details: title, subtitle, and trailing
          title: const Text("Other User"),
          subtitle: const Text("Hi, how are you?"),

          // Trailing widget showing unread messages count and last message time
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circle showing unread message count
              CircleAvatar(
                backgroundColor: kPrimaryColor,
                radius: screenWidth * 0.025,
                child: const Text(
                  "10",
                  style: TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
              // Space between unread count and message time
              SizedBox(height: screenWidth * 0.02),
              // Time of last message
              const Text("12:05"),
            ],
          ),
        ),
      ),

      // Floating action button for new chat
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
