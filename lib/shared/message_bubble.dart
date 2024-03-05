import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.dateTime,
    required this.isPrimaryUser,
    required this.time,
    required this.id,
    required this.userId,
    required this.receiverId,
  });

  final String message;
  final String dateTime;
  final bool isPrimaryUser;
  final DateTime time;
  final String id;
  final String userId;
  final String receiverId;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment:
          isPrimaryUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onLongPress: () {
            Alert(
              context: context,
              type: AlertType.none,
              title: "Delete Message?",
              desc: "Message will be deleted only for you",
              style: AlertStyle(
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                titleStyle: const TextStyle(color: Colors.white),
                descStyle: const TextStyle(color: Colors.white),
              ),
              closeIcon: const Icon(
                Icons.close,
                size: 26,
                color: Colors.white,
              ),
              buttons: [
                DialogButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('chats')
                        .doc(receiverId)
                        .collection('messages')
                        .doc(id)
                        .delete();
                    if (context.mounted) {
                      Alert(context: context).dismiss();
                    }
                  },
                  width: 120,
                  color: Colors.red,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('delete'),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(Icons.delete),
                    ],
                  ),
                ),
              ],
            ).show();
          },
          child: Container(
            constraints: BoxConstraints(
              maxWidth: screenWidth / 3 * 2.5,
            ),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: isPrimaryUser ? Colors.grey[700] : Colors.grey[800],
              borderRadius: BorderRadius.only(
                bottomLeft: const Radius.circular(15),
                bottomRight: const Radius.circular(15),
                topLeft: isPrimaryUser
                    ? const Radius.circular(20)
                    : const Radius.circular(0),
                topRight: isPrimaryUser
                    ? const Radius.circular(0)
                    : const Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style:
                        const TextStyle(fontSize: 14, fontFamily: 'Montserrat'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateTime,
                    style:
                        const TextStyle(fontSize: 12, fontFamily: 'Montserrat'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
