import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncc_chat_app/models/receiver.dart';

class Helper {
  Future<ReceiverData?> searchPeople(String username) async {
    username = stringCapitalize(username);
    ReceiverData receiverData;

    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      receiverData = ReceiverData(
          uid: querySnapshot.docs[0].id,
          pfpUrl: querySnapshot.docs[0].data()['pfp_url'],
          username: querySnapshot.docs[0].data()['username']);

      var currentUser = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (receiverData.username == currentUser.data()!['username']) {
        return null;
      }

      return receiverData;
    } else {
      return null;
    }
  }

  Future<String> checkChatDocument(
      {required String senderId, required String receiverId}) async {
    var document = await FirebaseFirestore.instance
        .collection('chats')
        .doc("$senderId-$receiverId")
        .collection('messages')
        .get();

    if (document.docs.isNotEmpty) {
      // chatDocument = "$senderId-$receiverId";
      return "$senderId-$receiverId";
    } else {
      document = await FirebaseFirestore.instance
          .collection('chats')
          .doc("$receiverId-$senderId")
          .collection('messages')
          .get();
      if (document.docs.isNotEmpty) {
        // chatDocument = "$receiverId-$senderId";
        return "$receiverId-$senderId";
      } else {
        return "$senderId-$receiverId";
      }
    }
  }

  String stringCapitalize(String value) {
    return value.substring(0, 1).toUpperCase() +
        value.substring(1).toLowerCase();
  }
}
