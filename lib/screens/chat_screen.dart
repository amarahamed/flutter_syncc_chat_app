import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:syncc_chat_app/models/receiver.dart';
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

  ReceiverData? receiverData;
  bool loading = false;
  bool showUserNotFoundText = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPeople(String username) async {
    setState(() {
      loading = true;
    });
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    setState(() {
      loading = false;
    });

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        showUserNotFoundText = false;
        receiverData = ReceiverData(
            uid: querySnapshot.docs[0].id,
            pfpUrl: querySnapshot.docs[0].data()['pfp_url'],
            username: querySnapshot.docs[0].data()['username']);
      });
      return;
    } else {
      setState(() {
        showUserNotFoundText = true;
        receiverData = null;
      });
      return;
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onSubmitted: (value) async {
                await _searchPeople(_searchController.text);
              },
              decoration: primaryInputDecoration.copyWith(
                labelText: 'Search people',
                suffixIcon: IconButton(
                  onPressed: () async {
                    await _searchPeople(_searchController.text);
                  },
                  icon: const Icon(
                    Icons.search,
                    size: 28,
                  ),
                ),
              ),
            ),
            if (receiverData != null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: InkWell(
                  onTap: () {},
                  splashColor: Colors.grey[850],
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundImage: NetworkImage(receiverData!.pfpUrl ??
                            'https://img.freepik.com/free-vector/404-error-with-person-looking-concept-illustration_114360-7912.jpg?w=1380&t=st=1698894274~exp=1698894874~hmac=6a69fb5708cf041b94fce103ff93e7664983f688aaad53137d4dc5ba2a61e883'),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${receiverData!.username.substring(0, 1).toUpperCase()}${receiverData!.username.substring(1, receiverData!.username.length).toLowerCase()}' ??
                                'Not found',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 200,
                            ),
                            child: const Text(
                              'Hey bro!',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          const Text(
                            '10:06 PM',
                            style: TextStyle(
                              height: 2,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1,
                              fontSize: 12,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (showUserNotFoundText)
              const Expanded(
                flex: 4,
                child: Center(
                  child: Text(
                    'No users found',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            if (loading == true && !showUserNotFoundText)
              Expanded(
                child: Center(
                  child: SpinKitSquareCircle(
                    color: Theme.of(context).colorScheme.secondary,
                    size: 50.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
