import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncc_chat_app/screens/auth_screen.dart';
import 'package:syncc_chat_app/screens/past_chat_screen.dart';
import 'package:syncc_chat_app/shared/loading_screen.dart';

class AuthStateScreen extends StatelessWidget {
  const AuthStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
        });
  }
}
