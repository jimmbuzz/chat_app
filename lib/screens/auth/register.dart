import 'package:chat_app/screens/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/screens/chat/chat_list.dart';

class EmailSignUp extends StatefulWidget {
  //const EmailSignUp { Key? key }) : super(key: key);

  @override
  _EmailSignUpState createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State <EmailSignUp>  {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference _firestore = FirebaseFirestore.instance.collection('users');
  //DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("Users");
  TextEditingController emailController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  //TextEditingController lastNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
        backgroundColor: Colors.indigo[400],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextFormField(
                controller: displayNameController,
                decoration: InputDecoration(
                  labelText: "Enter Display Name",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter Your First Name';
                  } 
                  return null;
                },
              )
            ),
            //  Padding(
            //   padding: EdgeInsets.all(20.0),
            //   child: TextFormField(
            //     controller: lastNameController,
            //     decoration: InputDecoration(
            //       labelText: "Enter Last Name",
            //       enabledBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(10.0),
            //       ),
            //     ),
            //     // The validator receives the text that the user has entered.
            //     validator: (value) {
            //       if (value!.isEmpty) {
            //         return 'Enter Your Last Name';
            //       } 
            //       return null;
            //     },
            //   )
            // ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Enter Email Address",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter Email Address';
                  } else if (!value.contains('@')) {
                    return 'Please enter a valid email address!';
                  }
                  return null;
                },
              )
            ),
            Padding(
                padding: EdgeInsets.all(20.0),
                child: TextFormField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Enter Password",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Password';
                    } else if (value.length < 6) {
                      return 'Password must be atleast 6 characters!';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });
                        sendToFB();
                      }
                    },
                    child: Text('Submit'),
                  ),
              )
          ],)
        )
      )
    );
  }
  void sendToFB() {
    _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
        
    ).then((result) async { 
      _auth.currentUser!.updateDisplayName(displayNameController.text);
      _firestore
      .doc(_auth.currentUser!.uid).set({
        //'uid' : _auth.currentUser!.uid,
        'email' : emailController.text,
        'display_name': displayNameController.text,
        //'lastname': lastNameController.text,
        //'isAdmin': false, 
        'regDateTime' : DateTime.now(),
      }).then((res) {
        isLoading = false;
        Navigator.pushReplacement (
          context,
          MaterialPageRoute(builder: (context) => Home()),//(uid: result.user!.uid)),
        );
      });
      

    }).catchError((err) {
      showDialog(context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(err.message),
          actions: [
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ]
        );
      });
    });
  }
  @override 
  void dispose() {
    super.dispose();
    emailController.dispose();
    displayNameController.dispose();
    //lastNameController.dispose();
    passwordController.dispose();
  }
}