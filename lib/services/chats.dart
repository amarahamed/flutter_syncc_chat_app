import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncc_chat_app/models/receiver.dart';
import 'package:syncc_chat_app/services/helper.dart';

class ChatService {
  Future<void> sendChat(
      {required String sentUser,
      required ReceiverData receiverData,
      required String message,
      dynamic senderData}) async {
    var chatDocument = await Helper().checkChatDocument(
        senderId: FirebaseAuth.instance.currentUser!.uid,
        receiverId: receiverData.uid);

    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatDocument)
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
// add the receiver user id as a previous chat
    await FirebaseFirestore.instance
        .collection('users')
        .doc(sentUser)
        .collection('chat')
        .doc(receiverData.uid)
        .set({});
  }
}
