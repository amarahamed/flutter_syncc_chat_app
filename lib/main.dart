import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:syncc_chat_app/screens/auth_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/*
* TO:DOs
*
* Make text fields onSubmit()
* Delete unused packages
* Clean code
*
* Make UI nicer
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firebaseMessaging = FirebaseMessaging.instance;

  await firebaseMessaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

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
