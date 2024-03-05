import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncc_chat_app/models/receiver.dart';
import 'package:syncc_chat_app/screens/new_message.dart';
import 'package:syncc_chat_app/shared/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.receiverData});

  final ReceiverData receiverData;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? chatDocument;
  String? currentUser;

  @override
  void initState() {
    currentUser = FirebaseAuth.instance.currentUser!.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundImage: NetworkImage(widget.receiverData.pfpUrl),
              radius: 24,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(widget.receiverData.username),
          ],
        ),
        centerTitle: true,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
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
                            .orderBy('sentTime', descending: true)
                            .snapshots(),
                        builder: (context, snapshots) {
                          if (snapshots.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!snapshots.hasData ||
                              snapshots.data!.docs.isEmpty) {
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
                            reverse: true,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemBuilder: (BuildContext context, int index) {
                              DateTime time =
                                  DateTime.parse(messages[index].id.toString());
                              return MessageBubble(
                                message: messages[index].data()['text'],
                                dateTime: dateFormat.format(time),
                                isPrimaryUser: currentUser! ==
                                        messages[index].data()['sentUser']
                                    ? true
                                    : false,
                                time: time,
                                id: messages[index].id,
                                userId: currentUser!,
                                receiverId: widget.receiverData.uid,
                              );
                            },
                            itemCount: messages.length,
                          );
                        }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              child: NewMessage(
                receiverData: widget.receiverData,
              ),
            )
          ],
        ),
      ),
    );
  }
}
