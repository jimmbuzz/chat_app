import 'package:chat_app/screens/auth/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/home/home_view.dart';

class Home extends StatefulWidget {
  Home();
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  
  @override
  HomeState();Widget build(BuildContext context) {
    
    return Scaffold(
        body: (_auth.currentUser != null)
            ? HomeBuilder()//uid: firebaseUser.uid, displayName: firebaseUser.displayName)
            : SignIn());
  }
}