import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:syncc_chat_app/services/authentication.dart';
import 'package:syncc_chat_app/services/helper.dart';
import 'package:syncc_chat_app/shared/shared_widgets.dart';
import 'package:syncc_chat_app/shared/user_image_picker.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = Authentication();

  bool obscureTextPwd = true;
  bool _isLogin = true;

  var _validatedEmail = '';
  var _validatedPassword = '';
  var _validatedUsername = "";
  File? _selectedPicture;
  var _isAuthenticating = false;

  final _form = GlobalKey<FormState>();

  // get all userData to check if other users have the same username
  // *username here is unique
  Future<bool> checkUsernameAvailable(String username) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('usernames').get();

    final List allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    for (var name in allData) {
      if (name['username'].toString().toLowerCase() == username.toLowerCase()) {
        return false;
      }
    }

    return true;
  }

  void _submitForm() async {
    if (_form.currentState == null) {
      return;
    }

    final valid = _form.currentState!.validate();

    // not valid so close the function
    if (!valid || !_isLogin && _selectedPicture == null) {
      // show error
      return;
    }

    _form.currentState!.save();

    try {
      if (_isLogin) {
        setState(() {
          _isAuthenticating = true;
        });
        // login user
        final userCredential =
            await _auth.signInWithEmailPwd(_validatedEmail, _validatedPassword);
        if (userCredential.user == null) {
          return;
        }
      } else {
        // register user
        // check if the username already exist in the db
        if (!await checkUsernameAvailable(_validatedUsername)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Username already exist')));
          }
          return;
        }

        final userCredential = await _auth.registerWithEmailPwd(
            _validatedEmail, _validatedPassword);

        // upload user image to Firebase

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpg');

        await storageRef.putFile(_selectedPicture!);
        final pictureUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          "email": _validatedEmail,
          "username": Helper().stringCapitalize(_validatedUsername),
          "pfp_url": pictureUrl,
        });

        // add username to the username list collection
        await FirebaseFirestore.instance
            .collection('usernames')
            .doc()
            .set({"username": Helper().stringCapitalize(_validatedUsername)});
      }
    } on FirebaseAuthException catch (err) {
      setState(() {
        _isAuthenticating = false;
      });
      if (err.code == 'email-already-in-use') {}
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication Failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text(
          'Syncc',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 24),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (_isLogin)
                Container(
                  padding: const EdgeInsets.all(10),
                  width: 200,
                  child: Image.asset('assets/img/home.png'),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                child: Form(
                  key: _form,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isLogin)
                          UserImagePicker(
                            onPickPicture: (pickedImage) {
                              _selectedPicture = pickedImage;
                            },
                          ),
                        TextFormField(
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          keyboardType: TextInputType.emailAddress,
                          decoration: primaryInputDecoration.copyWith(
                              labelText: 'Email'),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains("@")) {
                              return "Enter a valid email address";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _validatedEmail = value!;
                          },
                        ),
                        if (!_isLogin)
                          const SizedBox(
                            height: 20,
                          ),
                        if (!_isLogin)
                          TextFormField(
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            // validator: ,
                            decoration: primaryInputDecoration.copyWith(
                                labelText: 'Username'),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.trim().length < 4 &&
                                      value.trim().length > 10) {
                                return "Valid username should contain 4-10 characters ";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _validatedUsername = value!;
                            },
                          ),
                        const SizedBox(height: 20),
                        TextFormField(
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: obscureTextPwd,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return "A valid password should contain at least 6 characters";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _validatedPassword = value!;
                          },
                          decoration: primaryInputDecoration.copyWith(
                            suffixIconColor:
                                const Color(0xFF8E8E93).withOpacity(0.7),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  // pwd visible
                                  setState(() {
                                    obscureTextPwd = !obscureTextPwd;
                                  });
                                },
                                icon: const Icon(
                                  Icons.remove_red_eye,
                                  size: 28,
                                )),
                            labelText: 'Password',
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (_isAuthenticating)
                          CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        if (!_isAuthenticating)
                          ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 10),
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              elevation: 0,
                            ),
                            child:
                                Text(_isLogin == false ? 'Sign Up' : 'Sign In'),
                          ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (!_isAuthenticating)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin == false
                                  ? 'Already have an account'
                                  : 'Create an account',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
