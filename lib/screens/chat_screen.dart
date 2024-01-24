import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncc_chat_app/screens/chat_message.dart';
import 'package:syncc_chat_app/screens/new_message.dart';
import 'package:syncc_chat_app/services/authentication.dart';
import 'package:syncc_chat_app/shared/shared_widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> _searchPeople(String username) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // print("--> ${querySnapshot.docs[0].get('username')}");
      return querySnapshot.docs[0].id;
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextField(
              controller: _searchController,
              decoration: primaryInputDecoration.copyWith(
                labelText: 'Search people',
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchPeople(_searchController.text);
                  },
                  icon: const Icon(
                    Icons.search,
                    size: 28,
                  ),
                ),
              ),
            ),
            // const Expanded(child: ChatMessages()),
            const NewMessage(),
          ],
        ),
      ),
    );
  }
}
