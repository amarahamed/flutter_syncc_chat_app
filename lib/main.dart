import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:syncc_chat_app/models/push_notification.dart';
import 'package:syncc_chat_app/models/receiver.dart';
import 'package:syncc_chat_app/screens/auth_state.dart';
import 'package:syncc_chat_app/screens/chat_screen.dart';
import 'package:syncc_chat_app/screens/past_chat_screen.dart';
import 'package:syncc_chat_app/screens/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:syncc_chat_app/screens/search_people.dart';
import 'firebase_options.dart';

/*
* TO:DOs
* Update notification UI - add profile picture
* Handle notification in all 3 stages of an app - terminated, background, foreground
* Send images as messages
* try to enable chat read/unread
*
* Delete unused packages
* Clean code
*
*
* Make UI nicer
* Make text fields onSubmit()
* */

Future _firebaseBackgroundMessage(RemoteMessage remoteMessage) async {
  if (remoteMessage.notification != null) {
    print("Some notification Reac");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // on back
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
    if (remoteMessage.notification != null) {
      print("---> Background Notification tapped");
    }
  });

  // await FirebaseMessaging.instance.requestPermission();
  PushNotification pushNotification = PushNotification();
  pushNotification.init();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AuthStateScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF101815),
          brightness: Brightness.dark,
          primary: const Color(0xFF101815),
          secondary: const Color(0xFFF4F4F4),
          primaryContainer: const Color(0xFF303030),
          secondaryContainer: const Color(0xFF192621),
        ),
        textTheme: const TextTheme(
          bodySmall: TextStyle(fontFamily: 'Montserrat'),
          bodyMedium: TextStyle(fontFamily: 'Montserrat'),
          bodyLarge: TextStyle(fontFamily: 'Montserrat'),
        ),
      ),
    );
  }
}
