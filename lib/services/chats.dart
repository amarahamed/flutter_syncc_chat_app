import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncc_chat_app/models/receiver.dart';

class ChatService {
  Future<void> sendChat(
      {required String sentUser,
      required ReceiverData receiverData,
      required String message,
      dynamic senderData}) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(sentUser)
        .collection('chats')
        .doc(receiverData.uid)
        .collection('messages')
        .doc("${DateTime.now()}")
        .set({
      'text': message,
      'sentTime': DateTime.now(),
      'sentUser': sentUser,
      'senderUsername': senderData['username'],
      'senderPfp': senderData['pfp_url'],
      'receiver': receiverData.uid,
      'receiverUsername': receiverData.username,
      'receiverPfp': receiverData.pfpUrl,
      'fcm_token': receiverData.fcmToken,
    });

    // create a copy for the receiver in their collection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverData.uid)
        .collection('chats')
        .doc(sentUser)
        .collection('messages')
        .doc("${DateTime.now()}")
        .set({
      'text': message,
      'sentTime': DateTime.now(),
      'sentUser': sentUser,
      'senderUsername': senderData['username'],
      'senderPfp': senderData['pfp_url'],
      'receiver': receiverData.uid,
      'receiverUsername': receiverData.username,
      'receiverPfp': receiverData.pfpUrl,
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(sentUser)
        .collection('chatted_people')
        .doc(receiverData.uid)
        .set({});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverData.uid)
        .collection('chatted_people')
        .doc(sentUser)
        .set({});
  }

  Future<dynamic> getLastChat(
      String currentUserId, String receiverUserId) async {
    print("-------> Last start search started");
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .get();

    print("-------> Last start search ended $snapshot");

    if (snapshot.docs.isEmpty) {
      print("-------> EMPTY!");
      return null;
    }

    return snapshot.docs.last.data();
  }
}
