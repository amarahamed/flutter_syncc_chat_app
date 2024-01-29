import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncc_chat_app/screens/past_chat_screen.dart';
import 'package:syncc_chat_app/screens/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:syncc_chat_app/shared/loading_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }

            if (snapshot.hasData) {
              return const PastChatsScreen();
            } else {
              return const AuthScreen();
            }
          }),
    );
  }
}
