import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncc_chat_app/models/receiver.dart';

class Helper {
  Future<ReceiverData?> searchPeople(String username) async {
    username = stringCapitalize(username);
    ReceiverData receiverData;

    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      receiverData = ReceiverData(
        uid: querySnapshot.docs[0].id,
        pfpUrl: querySnapshot.docs[0].data()['pfp_url'],
        username: querySnapshot.docs[0].data()['username'],
        fcmToken: querySnapshot.docs[0].data()['fcm_token'],
      );

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

  String stringCapitalize(String value) {
    return value.substring(0, 1).toUpperCase() +
        value.substring(1).toLowerCase();
  }
}
