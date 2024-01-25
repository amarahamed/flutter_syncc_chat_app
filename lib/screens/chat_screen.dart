import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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

  var _userFound = false;
  var _usernameRec;
  var receiverData;

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
      setState(() {
        _userFound = true;
      });
      return querySnapshot.docs[0].id;
    } else {
      setState(() {
        _userFound = false;
      });
      return "";
    }
  }

  Future<dynamic> _userDataFetch(String uId) async {
    var data =
        await FirebaseFirestore.instance.collection('users').doc(uId).get();
    return data.data();
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
              decoration: primaryInputDecoration.copyWith(
                labelText: 'Search people',
                suffixIcon: IconButton(
                  onPressed: () async {
                    var id = await _searchPeople(_searchController.text);
                    var recData = await _userDataFetch(id);
                    setState(() {
                      _usernameRec = id;
                      receiverData = recData;
                      if (_usernameRec == "" || _usernameRec == null) {
                        _usernameRec = "";
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.search,
                    size: 28,
                  ),
                ),
              ),
            ),
            if (_userFound && _usernameRec != null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: InkWell(
                  onTap: () {},
                  splashColor: Colors.grey[850],
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 38,
                        backgroundImage: NetworkImage(
                            'https://img.freepik.com/free-vector/404-error-with-person-looking-concept-illustration_114360-7912.jpg?w=1380&t=st=1698894274~exp=1698894874~hmac=6a69fb5708cf041b94fce103ff93e7664983f688aaad53137d4dc5ba2a61e883'),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kav' ?? receiverData['username'],
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
            if (!_userFound && _usernameRec == null)
              const Expanded(
                flex: 4,
                child: Center(
                  child: Text(
                    'No users found',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            const Expanded(
                child: Align(
                    alignment: Alignment.bottomCenter, child: NewMessage())),
          ],
        ),
      ),
    );
  }
}

/*
* Column(
                children: [
                  /*ListTile(
                    // receiverData['pfp_url']
                    leading: Image.network(
                      'https://img.freepik.com/free-vector/404-error-with-person-looking-concept-illustration_114360-7912.jpg?w=1380&t=st=1698894274~exp=1698894874~hmac=6a69fb5708cf041b94fce103ff93e7664983f688aaad53137d4dc5ba2a61e883',
                    ),
                    title: Text(
                      _usernameRec.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  )*/
                ],
              ),
* */
