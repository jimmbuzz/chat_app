import 'package:chat_app/screens/auth/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/screens/auth/authenticate.dart';
import 'package:chat_app/screens/home/home_view.dart';

class Home extends StatefulWidget {
  //final String? uid;
  //final String? displayName;
  //{required this.uid}
  Home();
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  //final String? uid;
  //final String? displayName;
  
  @override
  HomeState();Widget build(BuildContext context) {
    
    //final User? firebaseUser = FirebaseAuth.instance.currentUser;
    //print("debug: "+displayName!);
    //print("debug: "+firebaseUser!.uid.toString());
    return Scaffold(
        body: (_auth.currentUser != null)
            ? HomeBuilder()//uid: firebaseUser.uid, displayName: firebaseUser.displayName)
            : SignIn());
  }
}