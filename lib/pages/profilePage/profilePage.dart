import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:link_up/Constant/colors.dart';
import 'package:link_up/Controllers/appwrite_controllers.dart';
import 'package:link_up/Controllers/localSavedData.dart';
import 'package:link_up/stateManagement/userDataProvider.dart';
import 'package:provider/provider.dart';

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        title: const Text("Profile"),
      ),
      body: Consumer<UserDataProvider>(
        builder: (context, value, child) {
          final userProfilePic = value.getUserProfilePic;
          final userName = value.getUserName;
          final userPhone = value.getUserPhoneNumber;
          final isProfilePicAvailable =
              userProfilePic != null && userProfilePic.isNotEmpty;
          return ListView(
            children: [
              ListTile(
                onTap: () => Navigator.pushNamed(context, "/update",
                    arguments: {"title": "edit"}),
                leading: CircleAvatar(
                  backgroundImage: isProfilePicAvailable
                      ? CachedNetworkImageProvider(
                          "https://cloud.appwrite.io/v1/storage/buckets/673f8b5b0012443f5422/files/$userProfilePic/view?project=673f893e0039487ed031&project=673f893e0039487ed031&mode=admin",
                        )
                      : const AssetImage("assets/user.png")
                          as ImageProvider<Object>,
                ),
                title: Text("$userName"),
                subtitle: Text("$userPhone"),
                trailing: const Icon(Icons.edit_outlined),
              ),
              const Divider(),
              ListTile(
                onTap: () async {
                  await LocalSavedData.clearAllData();
                  await logoutUser();
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/login", (route) => false);
                },
                leading: const Icon(Icons.logout_outlined),
                title: const Text("Logout"),
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text("About"),
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
