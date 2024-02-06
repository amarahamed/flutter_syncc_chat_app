import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.dateTime,
    required this.isPrimaryUser,
    required this.time,
  });

  final String message;
  final String dateTime;
  final bool isPrimaryUser;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment:
          isPrimaryUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
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
                const SizedBox(
                    height:
                        8), // Adjust the vertical spacing between text widgets
                Text(
                  dateTime,
                  style:
                      const TextStyle(fontSize: 12, fontFamily: 'Montserrat'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
