import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:syncc_chat_app/models/receiver.dart';
import 'package:syncc_chat_app/screens/chat_screen.dart';
import 'package:syncc_chat_app/services/authentication.dart';
import 'package:syncc_chat_app/services/chats.dart';
import 'package:syncc_chat_app/services/helper.dart';
import 'package:syncc_chat_app/shared/shared_widgets.dart';

class PeopleLookUpScreen extends StatefulWidget {
  const PeopleLookUpScreen({super.key});

  @override
  State<PeopleLookUpScreen> createState() => _PeopleLookUpScreenState();
}

class _PeopleLookUpScreenState extends State<PeopleLookUpScreen> {
  final _searchController = TextEditingController();
  dynamic foundUserLastChat;

  ReceiverData? receiverData;
  bool loading = false;
  bool showUserNotFoundText = false;

  void _submitInput() async {
    setState(() {
      loading = true;
    });

    ReceiverData? fetchData =
        await Helper().searchPeople(_searchController.text);
    dynamic lastChat;

    if (fetchData != null) {
      lastChat = await ChatService()
          .getLastChat(FirebaseAuth.instance.currentUser!.uid, fetchData.uid);
    }

    setState(() {
      loading = false;
      if (fetchData == null) {
        showUserNotFoundText = true;
        receiverData = null;
      } else {
        showUserNotFoundText = false;
        receiverData = fetchData;
        foundUserLastChat = lastChat;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                await Authentication().signOutUser(context);
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
              onSubmitted: (value) {
                _submitInput();
              },
              decoration: primaryInputDecoration.copyWith(
                labelText: 'Search people',
                suffixIcon: IconButton(
                  onPressed: _submitInput,
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
                  onTap: () {
                    if (receiverData != null) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ChatScreen(receiverData: receiverData!);
                      }));
                    }
                  },
                  splashColor: Colors.grey[850],
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundImage: NetworkImage(receiverData!.pfpUrl),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${receiverData!.username.substring(0, 1).toUpperCase()}${receiverData!.username.substring(1, receiverData!.username.length).toLowerCase()}',
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
                            child: Text(
                              foundUserLastChat['text'],
                              style: smallTextStyle,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          Text(
                            '10:06 PM',
                            style: smallTextStyle.copyWith(height: 2),
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
