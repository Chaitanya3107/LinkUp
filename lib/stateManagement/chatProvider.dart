import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:link_up/Controllers/appwrite_controllers.dart';
import 'package:link_up/models/chatDataModel.dart';
import 'package:link_up/models/messageModel.dart';
import 'package:link_up/models/userDataModel.dart';

class ChatProvider extends ChangeNotifier {
  Map<String, List<ChatDataModel>> _chats = {};

  // gets all users chats
  Map<String, List<ChatDataModel>> get getAllChats => _chats;

  bool _isLoading = true;

  // Check if data is loading
  bool get isLoading => _isLoading;

  // Load chats for the current user
  void loadChats(String currentUser) async {
    print("Current user id is");
    print(currentUser);

    // Set loading state to true when data is being fetched
    // _isLoading = true;
    // notifyListeners();

    try {
      Map<String, List<ChatDataModel>>? loadedChats =
          await currentUserChats(currentUser);
      if (loadedChats != null) {
        print("Loaded chats are");
        print(currentUser);
        _chats = loadedChats;
        _chats.forEach((key, value) {
          value.sort(
              (a, b) => a.message.timestamp.compareTo(b.message.timestamp));
        });
        print("Chats updated in provider");
      }
    } catch (e) {
      print("Error loading chats: $e");
    } finally {
      // Set loading state to false when data loading is complete
      _isLoading = false;
      notifyListeners();
    }
  }

  // add the chats message when user send a message to someone else
  void addMessage(
      MessageModel message, String currentUser, List<UserData> users) {
    try {
      if (message.sender == currentUser) {
        // user is starting first time chat
        if (_chats[message.receiver] == null) {
          _chats[message.receiver] = [];
        }
        _chats[message.receiver]!
            .add(ChatDataModel(message: message, users: users));
      } else {
        // current user is the receiver
        if (_chats[message.sender] == null) {
          _chats[message.sender] = [];
        }
        _chats[message.sender]!
            .add(ChatDataModel(message: message, users: users));
      }
      notifyListeners();
    } catch (e) {
      print("error in chatProvider on message adding");
    }
  }

  // delete message from the chats data
//   void deleteMessage(
//       MessageModel message, String currentUser, String? imageId) async {
//     try {
//       // user is deleting the message
//       if (message.sender == currentUser) {
//         _chats[message.receiver]!
//             .removeWhere((element) => element.message == message);
//         if (imageId != null) {
//           deleteImagefromBucket(oldImageId: imageId);
//           print("image deleted from bucket");
//         }
//         //chatId is inside message.messageId
//         deleteCurrentUserChat(chatId: message.messageId!);
//       } else {
//         // current user is receiver, only delete message from list
//         _chats[message.sender]!
//             .removeWhere((element) => element.message == message);
//         print("message deleted");
//       }
//     } catch (e) {
//       print("error in chatProvider on message deleting $e");
//     }
//   }
// }

  Future<void> deleteMessage(MessageModel message, String currentUser) async {
    try {
      // Check if the sender is the current user
      if (message.sender == currentUser) {
        // Fetch the messageId based on the message (use appropriate filters if needed)
        var messageId = await _fetchMessageId(
            message.sender, message.receiver, message.message);

        if (messageId != null) {
          // Proceed to delete the message using the fetched messageId
          _chats[message.receiver]
              ?.removeWhere((element) => element.message == message);

          // If there's an image to delete, delete it from the bucket
          if (message.isImage == true) {
            await deleteImagefromBucket(oldImageId: message.message);
            notifyListeners();
            print("image deleted from bucket");
          }

          // Delete the message from the database using messageId
          await deleteCurrentUserChat(chatId: messageId);
          notifyListeners();
        } else {
          print("Message not found for deletion");
        }
      } else {
        // If the current user is the receiver, only delete from the chat list
        _chats[message.sender]
            ?.removeWhere((element) => element.message == message);
        print("message deleted from receiver's chat");
        notifyListeners();
      }
    } catch (e) {
      print("Error in chatProvider on message deleting $e");
    }
  }

  Future<String?> _fetchMessageId(
      String senderId, String receiverId, String message) async {
    try {
      // Fetch the messageId based on the senderId, receiverId, and message content
      final response = await databases.listDocuments(
        databaseId: db,
        collectionId: chatCollection,
        queries: [
          Query.equal('senderId', senderId),
          Query.equal('receiverId', receiverId),
          Query.equal('message', message), // Adding message content as a filter
        ],
      );

      // Log the response to verify what documents are returned
      print("Documents fetched: ${response.documents}");

      // If the response contains a message document, return its ID
      if (response.documents.isNotEmpty) {
        String mess = response.documents.first.$id;
        print("Message id is $mess");
        return response.documents.first.$id; // Returning the messageId
      }

      return null; // If no documents found
    } catch (e) {
      print("Failed to fetch messageId: $e");
      return null;
    }
  }

  Future<void> deleteCurrentUserChat({required String chatId}) async {
    try {
      await databases.deleteDocument(
        databaseId: db,
        collectionId: chatCollection,
        documentId: chatId,
      );
      print("Chat deleted from database with messageId: $chatId");
    } catch (e) {
      print("Error deleting chat: $e");
    }
  }
}
