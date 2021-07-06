import 'dart:async';

import 'package:chat_app/screens/auth/register.dart';
import 'package:chat_app/screens/auth/sign_in.dart';
import 'package:chat_app/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authenticate extends StatefulWidget {

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
 
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference _firestore = FirebaseFirestore.instance.collection('users'); 

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register Or Login"),
        backgroundColor: Colors.indigo[400],
      ),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children : <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text("Chat App",
                style: TextStyle (
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                )  
              ) 
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
                child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EmailSignUp()),
                      );
                    },
                    child: Text('Sign Up'),
                  ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo)),
                    onPressed: () {
                      signInWithGoogle();
                    },
                    child: Text('Sign in with Google'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
                child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignIn()),
                      );
                    },
                    child: Text('Sign in with Email'),
                  ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
                child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo)),
                    onPressed: () {
                      signInAnon();
                    },
                    child: Text('Sign in Anonymously'),
                  ),
            ),
          ]),
      )
    );
  } 
  void signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    _auth.signInWithCredential(credential).then((result) {
      //check if user has data in firestore and if not create it
        _firestore.doc(_auth.currentUser!.uid).get()
          .then((DocumentSnapshot docSnapshot) {
            if(docSnapshot.exists) {
               print("User has data!");
               Navigator.pushReplacement (
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
            } else {
              print("Creating user data");
              _firestore.doc(_auth.currentUser!.uid).set({
                'email' : _auth.currentUser!.email,
                'display_name' : _auth.currentUser!.displayName,
                'regDateTime' : DateTime.now(),
                'profile_pic' : _auth.currentUser!.photoURL,
              }).then((value) => Navigator.pushReplacement (
                context,
                MaterialPageRoute(builder: (context) => Home()),
              ));
            }
          }
        );
        //print(result.user!.uid);
      //Timer(Duration(milliseconds: 500), () =>
     //);
    });
  }
  void signInAnon() async {
    _auth.signInAnonymously().then((result) {
      _firestore.doc(_auth.currentUser!.uid).set({
        'email' : '',
        'display_name': 'Anon',
        'regDateTime' : DateTime.now(),
        'profile_pic' : '',
      }).then((value) => Navigator.pushReplacement (
        context,
        MaterialPageRoute(builder: (context) => Home()),
      ));
    });
  }
}