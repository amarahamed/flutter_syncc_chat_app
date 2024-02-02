import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncc_chat_app/models/receiver.dart';
import 'package:syncc_chat_app/screens/chat_screen.dart';
import 'package:async/async.dart';
import 'package:syncc_chat_app/services/authentication.dart';
import 'package:syncc_chat_app/services/helper.dart';

class PastChatsScreen extends StatefulWidget {
  const PastChatsScreen({super.key});

  @override
  State<PastChatsScreen> createState() => _PastChatsScreenState();
}

class _PastChatsScreenState extends State<PastChatsScreen> {
  List<dynamic> allChatData = [];

  // Future<List> checkPastChats() async {
  //   String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  //   List<Stream<QuerySnapshot<Map<String, dynamic>>>> snapshots = [];
  //
  //   // get the past chat list from the user collection
  //   var previousChatsPeople = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(currentUserId)
  //       .collection('chat')
  //       .get();
  //
  //   final List previousChatsData =
  //       previousChatsPeople.docs.map((doc) => doc).toList();
  //
  //   for (var pastChatUserId in previousChatsData) {
  //     var listMessages = await FirebaseFirestore.instance
  //         .collection('chats')
  //         .doc('$currentUserId-${pastChatUserId.id}')
  //         .collection('messages')
  //         .get();
  //
  //     Stream<QuerySnapshot<Map<String, dynamic>>> x = FirebaseFirestore.instance
  //         .collection('chats')
  //         .doc('$currentUserId-${pastChatUserId.id}')
  //         .collection('messages')
  //         .snapshots();
  //
  //     snapshots.add(x);
  //
  //     // for (var element in listMessages.docs) {
  //     //   print("-----> ${element.data()}");
  //     // }
  //
  //     // for (var element in listMessages.docs) {
  //     //   setState(() {
  //     //     allChatData.add(element.data());
  //     //   });
  //     // }
  //   }
  //
  //   return snapshots;
  // }
//Future<List<QuerySnapshot<Object>>>

  void getSnapshots() async {
    List<Stream<QuerySnapshot<Map<String, dynamic>>>> streams = [];

    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    var previousChatsPeople = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('chat')
        .get();
    print("###");
    final List previousChatsData =
        previousChatsPeople.docs.map((doc) => doc).toList();
    // loop through previousChatData and the element.id will give the id

    for (var element in previousChatsData) {
      // print(element.id);
      var chatDocumentId = await Helper()
          .checkChatDocument(senderId: currentUserId, receiverId: element.id);
      print(chatDocumentId);

      streams.add(FirebaseFirestore.instance
          .collection('chats')
          .doc(chatDocumentId)
          .collection('messages')
          .snapshots());
    }
  }

  late Future<List> futureData;

  @override
  void initState() {
    getSnapshots();
    super.initState();
    // futureData = checkPastChats();
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
          getSnapshots();
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return const PeopleLookUpScreen();
          // }));
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
            icon: const Icon(Icons.exit_to_app_rounded),
          ),
        ],
      ),
      body: allChatData.isEmpty
          ? const Center(
              child: Text('No Chats'),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance.collection('chats').doc(),
              builder: (context, snapshot) {
                return ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        title: Text(allChatData[index]['receiverUsername']),
                        leading: CircleAvatar(
                          foregroundImage:
                              NetworkImage(allChatData[index]['receiverPfp']),
                          radius: 50,
                        ),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            print("----------->");
                            print(allChatData[index]);
                            return ChatScreen(
                                receiverData: ReceiverData(
                                    uid: allChatData[index]['receiver'],
                                    pfpUrl: allChatData[index]['receiverPfp'],
                                    username: allChatData[index]
                                        ['receiverUsername']));
                          }));
                        },
                      ),
                    );
                  },
                  itemCount: allChatData.length,
                );
              }),
    );
  }
}
