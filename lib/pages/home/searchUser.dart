// import 'package:appwrite/models.dart';
// import 'package:flutter/material.dart';
// import 'package:link_up/Constant/colors.dart';
// import 'package:link_up/Controllers/appwrite_controllers.dart';
// import 'package:link_up/models/userDataModel.dart';
// import 'package:link_up/stateManagement/userDataProvider.dart';
// import 'package:provider/provider.dart';

// class SearchUser extends StatefulWidget {
//   const SearchUser({super.key});

//   @override
//   State<SearchUser> createState() => _SearchUserState();
// }

// class _SearchUserState extends State<SearchUser> {
//   final TextEditingController _searchController = TextEditingController();
//   // if user list = -1 then we can say user like enter something to search, if it is 0 then no user found
//   late DocumentList searchedUsers = DocumentList(total: -1, documents: []);

//   // handle search
//   void _handleSearch() {
//     searchUsers(
//             searchItem: _searchController.text,
//             userId:
//                 Provider.of<UserDataProvider>(context, listen: false).getUserId)
//         .then((value) {
//       // value is the result we got form searchUser function
//       if (value != null) {
//         setState(() {
//           searchedUsers = value;
//         });
//       } else {
//         setState(() {
//           searchedUsers = DocumentList(total: 0, documents: []);
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: kBackgroundColor,
//         title: const Text(
//           "Search Users",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(50),
//             child: Container(
//               margin: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                   color: kPrimaryColor2,
//                   borderRadius: BorderRadius.circular(10)),
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Row(
//                 children: [
//                   Expanded(
//                       child: TextField(
//                     controller: _searchController,
//                     onSubmitted: (value) => _handleSearch(),
//                     decoration: const InputDecoration(
//                         border: InputBorder.none,
//                         hintText: "Enter phone number or name"),
//                   )),
//                   IconButton(
//                     icon: const Icon(Icons.search),
//                     onPressed: () {
//                       _handleSearch();
//                     },
//                   )
//                 ],
//               ),
//             )),
//       ),
//       body: searchedUsers.total == -1
//           ? const Center(child: Text("Use the search box to search users."))
//           : searchedUsers.total == 0
//               ? const Center(
//                   child: Text("No users found"),
//                 )
//               : ListView.builder(
//                   itemCount: searchedUsers.documents.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       onTap: () {
//                         Navigator.pushNamed(context, "/chat",
//                             arguments: UserData.toMap(
//                                 searchedUsers.documents[index].data));
//                       },
//                       leading: CircleAvatar(
//                         backgroundImage: searchedUsers
//                                         .documents[index].data["profile_pic"] !=
//                                     null &&
//                                 searchedUsers
//                                         .documents[index].data["profile_pic"] !=
//                                     ""
//                             ? NetworkImage(
//                                 "https://cloud.appwrite.io/v1/storage/buckets/673f8b5b0012443f5422/files/${searchedUsers.documents[index].data["profile_pic"]}/view?project=673f893e0039487ed031&project=673f893e0039487ed031&mode=admin")
//                             : const Image(image: AssetImage("assets/user.png"))
//                                 .image,
//                       ),
//                       title: Text(searchedUsers.documents[index].data["name"]),
//                       subtitle:
//                           Text(searchedUsers.documents[index].data["phone_no"]),
//                     );
//                   }),
//     );
//   }
// }

import 'dart:async';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:link_up/Constant/colors.dart';
import 'package:link_up/Controllers/appwrite_controllers.dart';
import 'package:link_up/models/userDataModel.dart';
import 'package:link_up/stateManagement/userDataProvider.dart';
import 'package:provider/provider.dart';

class SearchUser extends StatefulWidget {
  const SearchUser({super.key});

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  final TextEditingController _searchController = TextEditingController();
  late DocumentList searchedUsers = DocumentList(total: -1, documents: []);
  Timer? _debounce;

  @override
  void dispose() {
    _debounce
        ?.cancel(); // Cancel the debounce timer when the widget is disposed
    _searchController.dispose(); // Dispose of the text controller
    super.dispose();
  }

  void _handleSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        searchUsers(
                searchItem: query,
                userId: Provider.of<UserDataProvider>(context, listen: false)
                    .getUserId)
            .then((value) {
          if (value != null) {
            setState(() {
              searchedUsers = value;
            });
          } else {
            setState(() {
              searchedUsers = DocumentList(total: 0, documents: []);
            });
          }
        });
      } else {
        setState(() {
          searchedUsers = DocumentList(total: -1, documents: []);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        title: const Text(
          "Search Users",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: kPrimaryColor2,
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          _handleSearch(value), // Trigger search as user types
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter phone number or name"),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _handleSearch(_searchController.text),
                  ),
                ],
              ),
            )),
      ),
      body: searchedUsers.total == -1
          ? const Center(child: Text("Use the search box to search users."))
          : searchedUsers.total == 0
              ? const Center(
                  child: Text("No users found"),
                )
              : ListView.builder(
                  itemCount: searchedUsers.documents.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, "/chat",
                            arguments: UserData.toMap(
                                searchedUsers.documents[index].data));
                      },
                      leading: CircleAvatar(
                        backgroundImage: searchedUsers
                                        .documents[index].data["profile_pic"] !=
                                    null &&
                                searchedUsers
                                        .documents[index].data["profile_pic"] !=
                                    ""
                            ? NetworkImage(
                                "https://cloud.appwrite.io/v1/storage/buckets/673f8b5b0012443f5422/files/${searchedUsers.documents[index].data["profile_pic"]}/view?project=673f893e0039487ed031&project=673f893e0039487ed031&mode=admin")
                            : const Image(image: AssetImage("assets/user.png"))
                                .image,
                      ),
                      title: Text(searchedUsers.documents[index].data["name"]),
                      subtitle:
                          Text(searchedUsers.documents[index].data["phone_no"]),
                    );
                  }),
    );
  }
}
