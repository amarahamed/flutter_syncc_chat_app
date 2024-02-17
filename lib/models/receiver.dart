class ReceiverData {
  String uid;
  String pfpUrl;
  String username;
  String? fcmToken;

  ReceiverData(
      {required this.uid,
      required this.pfpUrl,
      required this.username,
      this.fcmToken});
}
