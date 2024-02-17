import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncc_chat_app/models/receiver.dart';
import 'package:syncc_chat_app/services/chats.dart';
import 'package:syncc_chat_app/shared/shared_widgets.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key, required this.receiverData});

  final ReceiverData receiverData;

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final message = _messageController.text;
    if (message.trim().isEmpty) {
      return;
    }

    // clear message and un focus text-field
    FocusScope.of(context).unfocus();
    _messageController.clear();

    final sentUser = FirebaseAuth.instance.currentUser!;
    final senderData = await FirebaseFirestore.instance
        .collection('users')
        .doc(sentUser.uid)
        .get();
    await ChatService().sendChat(
        receiverData: widget.receiverData,
        message: message,
        senderData: senderData.data(),
        sentUser: sentUser.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: TextField(
          controller: _messageController,
          textCapitalization: TextCapitalization.sentences,
          autocorrect: true,
          enableSuggestions: true,
          onSubmitted: (value) {
            _submitMessage;
          },
          decoration: primaryInputDecoration.copyWith(
            labelText: 'Type message',
          ),
        )),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(25),
          ),
          child: IconButton(
            onPressed: _submitMessage,
            icon: const Icon(Icons.arrow_upward_rounded),
          ),
        ),
      ],
    );
  }
}
