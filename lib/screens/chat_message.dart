import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncc_chat_app/models/receiver.dart';
import 'package:syncc_chat_app/services/helper.dart';

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
    setState(() {
      currentUser = FirebaseAuth.instance.currentUser!.uid;
      setChatDocument();
    });
    super.initState();
  }

  void setChatDocument() async {
    var chats = await Helper().checkChatDocument(
        senderId: currentUser!, receiverId: widget.receiverData.uid);
    setState(() {
      chatDocument = chats;
    });
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
                  .collection('chats')
                  .doc(chatDocument)
                  .collection('messages')
                  .snapshots(),
              // stream: FirebaseFirestore.instance.collection('chats').where(FirebaseAuth.instance.currentUser!.uid,isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
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

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.dateTime,
    required this.isPrimaryUser,
  });

  final String message;
  final String dateTime;
  final bool isPrimaryUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 100,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: isPrimaryUser ? Colors.grey[700] : Colors.grey[800],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(15),
          topRight: const Radius.circular(15),
          bottomLeft: isPrimaryUser
              ? const Radius.circular(15)
              : const Radius.circular(0),
          bottomRight: isPrimaryUser
              ? const Radius.circular(0)
              : const Radius.circular(15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(message),
          Text(dateTime),
        ],
      ),
    );
  }
}

/*
*
 return ListTile(
                      title: Text(messages[index].data()['text']),
                      trailing: Text(dateFormat.format(time)),
                    );
* */
