import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:link_up/main.dart';
import 'package:link_up/models/userDataModel.dart';
import 'package:link_up/stateManagement/userDataProvider.dart';
import 'package:provider/provider.dart';

Client client =
    Client().setProject('673f893e0039487ed031').setSelfSigned(status: true);

const String db = "673f89d6003467f7148c";
const String userCollection = "673f89fa0024f67a7ae5";
const String storageBucket = "673f8b5b0012443f5422";

// initialise our database and account and storage
Account account = Account(client);
final Databases databases = Databases(client);
final Storage storage = Storage(client);

// save phone number to database (while creating a new account)
Future<bool> savePhonetoDb(
    {required String phoneNo, required String userId}) async {
  try {
    final response = await databases.createDocument(
        databaseId: db,
        collectionId: userCollection,
        documentId: userId,
        data: {"phone_no": phoneNo, "userId": userId});
    print(response);
    return true;
  } on AppwriteException catch (e) {
    print("Cannot save to user database :$e");
    return false;
  }
}

// check whether phone number exist in database or not
Future<String> checkPhoneNumber({required String phoneNo}) async {
  try {
    // DocumentList from appwrite
    final DocumentList matchUser = await databases.listDocuments(
        databaseId: db,
        collectionId: userCollection,
        queries: [Query.equal("phone_no", phoneNo)]);
    if (matchUser.total > 0) {
      // add first phoneNo to user variable
      final Document user = matchUser.documents[0];
      // additional check to see if phoneNo is not null
      if (user.data["phone_no"] != null || user.data["phone_no"] != "") {
        // return userId of the current user
        return user.data["userId"];
      } else {
        print("No user exist in database");
        return "user_not_exist";
      }
    } else {
      print("No user exist in database");
      return "user_not_exist";
    }
  } on AppwriteException catch (e) {
    print("Error on reading database: $e");
    return "user_not_exist";
  }
}

// create a phone session, send otp to phone number
Future<String> createPhoneSession({required String phone}) async {
  try {
    final userId = await checkPhoneNumber(phoneNo: phone);
    if (userId == "user_not_exist") {
      // creating a unique ID for user
      // creating a new account
      final Token data =
          await account.createPhoneToken(userId: ID.unique(), phone: phone);
      // save new user userId to our database
      savePhonetoDb(phoneNo: phone, userId: data.userId);
      return data.userId;
    }
    // if user is existing user
    else {
      // create phone token for existing user
      final Token data =
          await account.createPhoneToken(userId: userId, phone: phone);
      return data.userId;
    }
  } on AppwriteException catch (e) {
    print("Error on creating a phone session: $e");
    return "login_error";
  }
}

// login with otp
Future<bool> loginWithOtp({required String otp, required String userId}) async {
  try {
    final Session session =
        await account.updatePhoneSession(userId: userId, secret: otp);
    print(session.userId);
    return true;
  } on AppwriteException catch (e) {
    print("Error on login with otp: $e");
    return false;
  }
}

// to check whether a session exist or not
Future<bool> checkSession() async {
  try {
    final Session session = await account.getSession(sessionId: "current");
    print("Session exist ${session.$id}");
    return true;
  } catch (e) {
    print("Session does not exist please logina $e");
    return false;
  }
}

// logout user and delete session
Future logoutUser() async {
  await account.deleteSession(sessionId: "current");
}

// load user data
Future<UserData?> getUserDetails({required String userId}) async {
  try {
    final response = await databases.getDocument(
        databaseId: db, collectionId: userCollection, documentId: userId);
    // data is inside this response
    print("Getting user data");
    print(response.data);
    return UserData.toMap(response.data);
  } catch (e) {
    print("Error in getting user data: $e");
    return null;
  }
}

// update user data
Future<bool> updateUserData(String pic,
    {required String name, required String userId}) async {
  try {
    final data = await databases.updateDocument(
        databaseId: db,
        collectionId: userCollection,
        documentId: userId,
        data: {"name": name, "profile_pic": pic});
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setName(name);
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setProfilePic(pic);
    print(data);
    return true;
  } on AppwriteException catch (e) {
    print("Cannot save to db $e");
    return false;
  }
}

// upload and save image to storage bucket (create new image)
Future<String?> saveImageBucket({required InputFile image}) async {
  try {
    final response = await storage.createFile(
        bucketId: storageBucket, fileId: ID.unique(), file: image);
    print("the response after image is saved to bucket $response");
    return response.$id;
  } catch (e) {
    print("Error on saving image on bucket $e");
    return null;
  }
}

// update and image in bucket: first delete then create new image
Future<String?> updateImageOnBucket(
    {required String oldImageId, required InputFile image}) async {
  try {
    // to delete old image
    deleteImagefromBucket(oldImageId: oldImageId);
    // create new image using above function
    final newImage = saveImageBucket(image: image);
    // newImage return image ID otherwise null
    return newImage;
  } catch (e) {
    print("Cannot update image / delete image: $e");
    return null;
  }
}

// function to only delete image
Future<bool> deleteImagefromBucket({required String oldImageId}) async {
  try {
    // to delete old image
    await storage.deleteFile(bucketId: storageBucket, fileId: oldImageId);
    // create new image using above function
    return true;
  } catch (e) {
    print("Cannot delete image: $e");
    return false;
  }
}

// // to search all users from database, ? means it can be null
Future<DocumentList> searchUsers({
  required String searchItem,
  required String userId,
}) async {
  try {
    // Check if searchItem is empty
    if (searchItem.trim().isEmpty) {
      return DocumentList(total: 0, documents: []); // Return empty list
    }
    // Perform the search query
    final users = await databases.listDocuments(
      databaseId: db,
      collectionId: userCollection,
      queries: [
        Query.or([
          Query.search("phone_no", searchItem),
          Query.search("name", searchItem),
        ]),
        Query.notEqual("userId", userId),
      ],
    );
    return users;
  } catch (e) {
    print("Error searching users: $e");
    return DocumentList(total: 0, documents: []); // Return empty list on error
  }
}
