import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:syncc_chat_app/models/receiver.dart';
import 'package:syncc_chat_app/screens/chat_screen.dart';
import 'package:syncc_chat_app/screens/search_people.dart';
import 'package:syncc_chat_app/services/authentication.dart';

class PastChatsScreen extends StatefulWidget {
  const PastChatsScreen({super.key});

  @override
  State<PastChatsScreen> createState() => _PastChatsScreenState();
}

class _PastChatsScreenState extends State<PastChatsScreen> {
  final _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final _controller = StreamController();
  var fcmSnack;
  Stream get stream => _controller.stream;

  /* Notification Setup - ONLY for logged users */
  void setupPushNotification() async {
    final fcm = FirebaseMessaging.instance;
    fcm.onTokenRefresh.listen((fcmToken) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .update({
        "fcm_token": fcmToken,
        "fcm_token_reg_time": DateTime.now(),
      });
    });

    NotificationSettings permission = await fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (permission.authorizationStatus == AuthorizationStatus.authorized) {
      await handleNotification();
    }
  }

  Future<void> handleNotification() async {
    // terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      setSnackBar(initialMessage);
    }

    // background state
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      if (event.notification != null) {
        setSnackBar(event);
      }
    });
  }

  void setSnackBar(RemoteMessage message) {
    setState(() {
      fcmSnack = SnackBar(
        elevation: 1.0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Messaged from ${message.data['SenderUsername']}',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ChatScreen(
                      receiverData: ReceiverData(
                          uid: message.data['SentBy'],
                          pfpUrl: message.data['senderPfpUrl'],
                          username: message.data['SenderUsername']));
                }));
              },
              child: Text(
                'Open',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          ],
        ),
      );

      _controller.sink.add(fcmSnack);
    });
  }

  @override
  void initState() {
    super.initState();
    setupPushNotification();

    // listen to the stream - if notification received from background or terminated state of the app returns a snack bar to open chat message
    stream.listen((event) {
      if (fcmSnack != null) {
        WidgetsFlutterBinding.ensureInitialized();
        ScaffoldMessenger.of(context).showSnackBar(fcmSnack);
      }
    });
  }

  Future<List> userChatData(List<QueryDocumentSnapshot> chats) async {
    List peopleChatData = [];
    for (var element in chats) {
      peopleChatData.add(await FirebaseFirestore.instance
          .collection('users')
          .doc(element.id)
          .get());
    }

    return peopleChatData;
  }

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
        title: const Text('Chats'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await Authentication().signOutUser(context);
            },
            icon: const Icon(Icons.exit_to_app_rounded),
          ),
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUserId)
              .collection('chatted_people')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No chats!!'),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('something went wrong... : ('),
              );
            }

            var chats = snapshot.data!.docs;

            return FutureBuilder(
                future: userChatData(chats),
                builder: (context, userDataSnapshots) {
                  if (userDataSnapshots.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (userDataSnapshots.hasError) {
                    return const Center(
                      child: Text('Failed to fetch user chat data'),
                    );
                  }

                  var pastChatUsers = userDataSnapshots.data;

                  return ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: ListTile(
                          title: Text(
                            "${pastChatUsers![index]['username']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          leading: CircleAvatar(
                            foregroundImage:
                                NetworkImage(pastChatUsers[index]['pfp_url']),
                            radius: 50,
                          ),
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (cxt) {
                              return ChatScreen(
                                receiverData: ReceiverData(
                                    uid: chats[index].id,
                                    pfpUrl: pastChatUsers[index]['pfp_url'],
                                    username: pastChatUsers[index]['username'],
                                    fcmToken: pastChatUsers[index]
                                        ['fcm_token']),
                              );
                            }));
                          },
                        ),
                      );
                    },
                    itemCount: chats.length,
                  );
                });
          }),
    );
  }
}
