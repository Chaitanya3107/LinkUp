import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:link_up/Constant/colors.dart';
import 'package:link_up/Constant/formatDate.dart';
import 'package:link_up/models/messageModel.dart';

/// ChatMessage widget displays individual chat messages with message bubble,
/// timestamp, and read status. It adjusts alignment based on the sender.
class ChatMessage extends StatefulWidget {
  final MessageModel
      msg; // Message data containing text, sender, timestamp, etc.
  final String currentUser; // ID of the current user for alignment purposes
  final bool
      isImage; // Determines if the message is an image or text (not implemented in this code)

  const ChatMessage({
    super.key,
    required this.msg,
    required this.currentUser,
    required this.isImage,
  });

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context)
        .size
        .width; // Screen width for responsive padding and layout

    return widget.isImage
        ? Row(
            mainAxisAlignment: widget.msg.sender == widget.currentUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(
                        imageUrl:
                            "https://cloud.appwrite.io/v1/storage/buckets/673f8b5b0012443f5422/files/${widget.msg.message}/view?project=673f893e0039487ed031&project=673f893e0039487ed031&mode=admin",
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // Display timestamp below message
                      Container(
                        padding: EdgeInsets.fromLTRB(
                          screenWidth * 0.00,
                          screenWidth * 0.000,
                          screenWidth * 0.000,
                          0,
                        ),
                        child: Text(
                          formatDate(
                              widget.msg.timestamp), // Formatted timestamp
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      // Read Status Indicator (Check Icon) for current user's sent messages
                      widget.msg.sender == widget.currentUser
                          ? widget.msg.isSeenByReceiver
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      right: screenWidth * 0.00),
                                  child: const Icon(
                                    Icons.check,
                                    size: 20,
                                    color: kPrimaryColor, // Seen message color
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.only(
                                      right: screenWidth * 0.00),
                                  child: const Icon(
                                    Icons.check,
                                    size: 20,
                                    color:
                                        kPrimaryColor1, // Unseen message color
                                  ),
                                )
                          : const SizedBox(), // Empty widget for messages from other users
                    ],
                  ),
                ],
              )
            ],
          )
        : Container(
            // Align message bubble based on whether the current user is the sender
            child: Row(
              mainAxisAlignment: widget.msg.sender == widget.currentUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: widget.msg.sender == widget.currentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // Message Bubble with Padding
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.025,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(screenWidth * 0.025),
                            decoration: BoxDecoration(
                              color: widget.msg.sender == widget.currentUser
                                  ? kPrimaryColor // Primary color for current user's messages
                                  : kPrimaryColor1, // Different color for received messages
                              borderRadius: BorderRadius.circular(
                                  20), // Rounded corners for message bubble
                            ),
                            constraints: BoxConstraints(
                                maxWidth:
                                    screenWidth * 0.75), // Max width for bubble
                            child: Text(
                              widget.msg.message, // Message text display
                              style: TextStyle(
                                color: widget.msg.sender == widget.currentUser
                                    ? kBackgroundColor // Text color for current user's messages
                                    : Colors
                                        .black, // Text color for received messages
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Timestamp and Read Status Row
                    Row(
                      children: [
                        // Display timestamp below message
                        Container(
                          padding: EdgeInsets.fromLTRB(
                            screenWidth * 0.04,
                            screenWidth * 0.005,
                            screenWidth * 0.005,
                            0,
                          ),
                          child: Text(
                            formatDate(
                                widget.msg.timestamp), // Formatted timestamp
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                        // Read Status Indicator (Check Icon) for current user's sent messages
                        widget.msg.sender == widget.currentUser
                            ? widget.msg.isSeenByReceiver
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        right: screenWidth * 0.02),
                                    child: const Icon(
                                      Icons.check,
                                      size: 20,
                                      color:
                                          kPrimaryColor, // Seen message color
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                        right: screenWidth * 0.02),
                                    child: const Icon(
                                      Icons.check,
                                      size: 20,
                                      color:
                                          kPrimaryColor1, // Unseen message color
                                    ),
                                  )
                            : const SizedBox(), // Empty widget for messages from other users
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
