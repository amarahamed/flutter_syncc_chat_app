import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncc_chat_app/models/receiver.dart';
import 'package:syncc_chat_app/shared/message_bubble.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key, required this.receiverData});

  final ReceiverData receiverData;

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  String? chatDocument;
  String? currentUser;

  @override
  void initState() {
    currentUser = FirebaseAuth.instance.currentUser!.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser)
                  .collection('chats')
                  .doc(widget.receiverData.uid)
                  .collection('messages')
                  .snapshots(),
              builder: (context, snapshots) {
                if (snapshots.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No messages found!!'),
                  );
                }

                if (snapshots.hasError) {
                  return const Center(
                    child: Text('something went wrong... : ('),
                  );
                }

                var messages = snapshots.data!.docs;
                DateFormat dateFormat = DateFormat('HH:mm');

                return ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    DateTime time =
                        DateTime.parse(messages[index].id.toString());

                    return MessageBubble(
                      message: messages[index].data()['text'],
                      dateTime: dateFormat.format(time),
                      isPrimaryUser:
                          currentUser! == messages[index].data()['sentUser']
                              ? true
                              : false,
                      time: time,
                    );
                  },
                  itemCount: messages.length,
                );
              }),
        ),
      ],
    );
  }
}
