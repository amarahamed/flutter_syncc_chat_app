import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncc_chat_app/shared/shared_widgets.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

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

    // clear message and unfocus text-field
    FocusScope.of(context).unfocus();
    _messageController.clear();

    final sentUser = FirebaseAuth.instance.currentUser!;
    final senderData = await FirebaseFirestore.instance
        .collection('users')
        .doc(sentUser.uid)
        .get();

    // send message to other user
    FirebaseFirestore.instance.collection('chats').add({
      'text': message,
      'sentTime': Timestamp.now(),
      'sentUser': sentUser.uid,
      'senderUsername': senderData.data()!['username'],
      'senderPfp': senderData.data()!['pfp_url'],
    });
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
          decoration:
              primaryInputDecoration.copyWith(labelText: 'Type message'),
        )),
        IconButton(
          onPressed: _submitMessage,
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }
}
