import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncc_chat_app/models/receiver.dart';
import 'package:syncc_chat_app/screens/chat_message.dart';
import 'package:syncc_chat_app/screens/new_message.dart';
import 'package:syncc_chat_app/services/authentication.dart';

class ChatScreen extends StatefulWidget {
  final ReceiverData receiverData;

  const ChatScreen({super.key, required this.receiverData});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // late ReceiverData receiverData;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
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
        actions: [
          IconButton(
              onPressed: () async {
                await Authentication().signOutUser(context);
              },
              icon: const Icon(Icons.exit_to_app_rounded)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Show the current messages for this chat
            Expanded(
              child: ChatMessages(
                receiverData: widget.receiverData,
              ),
            ),
            NewMessage(
              receiverData: widget.receiverData,
            ),
          ],
        ),
      ),
    );
  }
}
