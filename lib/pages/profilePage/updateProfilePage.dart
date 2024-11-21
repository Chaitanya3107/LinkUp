import 'dart:io'; // To work with file input/output
import 'package:appwrite/appwrite.dart'; // For Appwrite SDK integration
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart'; // For file picking functionality
import 'package:flutter/material.dart'; // Flutter package for UI components
import 'package:link_up/Constant/colors.dart';
import 'package:link_up/Controllers/appwrite_controllers.dart';
import 'package:link_up/stateManagement/userDataProvider.dart';
import 'package:provider/provider.dart'; // To manage state with provider

/// UpdateProfilePage widget allows users to update their profile details,
/// including profile picture and name.
class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  // Text controllers for the name and phone fields
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  // To hold the file picked by the user
  FilePickerResult? _filePickerResult;

  // To hold the image ID for user profile image and user ID
  late String imageId = "";
  late String userId = "";

  // Global key for form validation
  final _nameKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load user data from the provider on widget initialization
    Future.delayed(Duration.zero, () {
      // imageId = Provider.of<UserDataProvider>(context, listen: false)
      //     .getUserProfilePic; // Fetch image ID from the provider
      userId = Provider.of<UserDataProvider>(context, listen: false)
          .getUserId; // Fetch user ID from the provider
      final userProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      userProvider.loadUserDataAppwrite(userId); // Ensure data is loaded
      imageId = userProvider.getUserProfilePic;
      print("Loaded userId: $imageId");
      // userId = userProvider.getUserId;
      _nameController.text = userProvider.getUserName;
    });
  }

  // Function to open the file picker to select an image
  void _openFilePicker() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    setState(() {
      _filePickerResult = result; // Store the picked file
    });
  }

  // Function to upload the selected profile image
  Future uploadProfileImage() async {
    try {
      if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty) {
        PlatformFile file =
            _filePickerResult!.files.first; // Get the selected file
        final fileBytes =
            await File(file.path!).readAsBytes(); // Convert file to bytes
        final inputFile = InputFile.fromBytes(
            bytes: fileBytes,
            filename: file.name); // Create an InputFile for Appwrite

        // If the image ID exists, update the existing image in the bucket
        if (imageId != null && imageId != "") {
          await updateImageOnBucket(oldImageId: imageId, image: inputFile)
              .then((value) {
            if (value != null) {
              imageId =
                  value; // Update the image ID if the image is successfully updated
            }
          });
        }
        // If no image exists, save a new image to the bucket
        else {
          await saveImageBucket(image: inputFile).then((value) {
            if (value != null) {
              imageId = value; // Set the new image ID
            }
          });
        }
      } else {
        print("Something went wrong"); // Error handling for no file selected
      }
    } catch (e) {
      print("error on loading image $e"); // Catch and log any errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context)
        .size
        .width; // Get screen width for responsive design
    final Map<String, dynamic> datapassed =
        ModalRoute.of(context)!.settings.arguments
            as Map<String, dynamic>; // Get passed arguments (for edit or add)

    // Consumer to listen for changes in user data and rebuild the UI when data changes
    return Consumer<UserDataProvider>(builder: (context, value, child) {
      // Set initial values for the name and phone fields from the provider
      _nameController.text = value.getUserName;
      _phoneController.text = value.getUserPhoneNumber;

      return Scaffold(
        backgroundColor: kBackgroundColor, // Set background color
        appBar: AppBar(
          backgroundColor: kBackgroundColor, // Set AppBar background color
          title: Text(datapassed["title"] == "edit"
              ? "Update"
              : "Add Details"), // Change title based on action
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal:
                    screenWidth * 0.02), // Padding for responsive design
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center content
              crossAxisAlignment: CrossAxisAlignment.center, // Center content
              children: [
                const SizedBox(height: 40), // Space before profile picture

                // Profile picture with edit icon
                GestureDetector(
                  onTap: () {
                    _openFilePicker(); // Open file picker when the profile picture is tapped
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                          radius: 130,
                          backgroundColor:
                              Colors.grey[200], // Placeholder color
                          backgroundImage: _filePickerResult != null
                              ? Image(
                                      image: FileImage(File(_filePickerResult!
                                          .files.first.path!)))
                                  .image // Display selected image if available
                              : value.getUserProfilePic != "" &&
                                      value.getUserProfilePic != null
                                  ? CachedNetworkImageProvider(
                                      "https://cloud.appwrite.io/v1/storage/buckets/673f8b5b0012443f5422/files/${value.getUserProfilePic}/view?project=673f893e0039487ed031&project=673f893e0039487ed031&mode=admin")
                                  : null),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            color: kPrimaryColor, // Edit icon background color
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                    height:
                        20), // Space between profile picture and text fields

                // Name input field
                Container(
                  decoration: BoxDecoration(
                    color:
                        kPrimaryColor2, // Background color for the text field
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Form(
                    key: _nameKey, // Form key for validation
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Cannot be empty"; // Validation to ensure input is not empty
                        } else {
                          return null;
                        }
                      },
                      controller: _nameController, // Name field controller
                      enabled: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            "Enter your name", // Placeholder text for name input
                      ),
                    ),
                  ),
                ),

                // Phone number or additional info field
                Container(
                  decoration: BoxDecoration(
                    color:
                        kPrimaryColor2, // Background color for the text field
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Cannot be empty"; // Validation for phone field
                      } else {
                        return null;
                      }
                    },
                    controller: _phoneController, // Phone field controller
                    enabled:
                        false, // Disable phone field input (if no editing allowed)
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          "Phone Number", // Placeholder text for phone field
                    ),
                  ),
                ),

                const SizedBox(height: 10), // Space before the button

                // Button to update user profile
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_nameKey.currentState!.validate()) {
                        // Upload image if file is selected
                        if (_filePickerResult != null) {
                          await uploadProfileImage();
                        }

                        // Save user data to the database
                        await updateUserData(imageId ?? "",
                            name: _nameController.text, userId: userId!);

                        // Navigate to home page after updating
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/home", (route) => false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: kBackgroundColor),
                    child: Text(
                      datapassed["title"] == "edit"
                          ? "Update"
                          : "Continue", // Button text based on action
                      style: TextStyle(
                          fontSize: screenWidth *
                              0.042), // Font size based on screen width
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
