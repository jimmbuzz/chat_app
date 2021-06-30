import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/screens/home/home.dart';


class ProviderInit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      value: FirebaseAuth.instance.authStateChanges(), 
      //initialData: null,
      initialData: null,
      child: MaterialApp(
        title: 'Chat Application',
        debugShowCheckedModeBanner: false,
        home: Home(),
      )
    );
  }
}