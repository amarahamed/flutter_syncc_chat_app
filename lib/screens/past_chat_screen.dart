import 'package:flutter/material.dart';
import 'package:syncc_chat_app/screens/helper.dart';
import 'package:syncc_chat_app/services/authentication.dart';

class PastChatsScreen extends StatefulWidget {
  const PastChatsScreen({super.key});

  @override
  State<PastChatsScreen> createState() => _PastChatsScreenState();
}

class _PastChatsScreenState extends State<PastChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.chat_bubble,
          color: Theme.of(context).colorScheme.secondary,
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const PeopleLookUpScreen();
          }));
        },
      ),
      appBar: AppBar(
        title: const Text('Syncc'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                await Authentication().signOutUser();
              },
              icon: const Icon(Icons.exit_to_app_rounded)),
        ],
      ),
      body: const Center(child: Text('No Chats')),
    );
  }
}
