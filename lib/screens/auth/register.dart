import 'package:chat_app/screens/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailSignUp extends StatefulWidget {

  @override
  _EmailSignUpState createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State <EmailSignUp>  {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference _firestore = FirebaseFirestore.instance.collection('users');
  TextEditingController emailController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    bool anon = false;
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      anon = currentUser.isAnonymous;
      print("Debug 1" + anon.toString());
    } else {
      anon = false;
      print("Debug 2" + anon.toString());
    }
    

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
                        sendToFB(anon);
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
  void sendToFB(bool anon) {
    if (anon) {
      AuthCredential credential = EmailAuthProvider.credential(
          email: emailController.text,
          password: passwordController.text,
      );//.then((result) async { 
      _auth.currentUser!.linkWithCredential(credential).then((result) async {
        _auth.currentUser!.updateDisplayName(displayNameController.text);
        _firestore
        .doc(_auth.currentUser!.uid).set({
          'email' : emailController.text,
          'display_name': displayNameController.text,
          'regDateTime' : DateTime.now(),
          'profile_pic' : '',
        }).then((res) {
          isLoading = false;
          Navigator.pushReplacement (
            context,
            MaterialPageRoute(builder: (context) => Home()),
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
    } else {
      _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
          
      ).then((result) async { 
        _auth.currentUser!.updateDisplayName(displayNameController.text);
        _firestore
        .doc(_auth.currentUser!.uid).set({
          'email' : emailController.text,
          'display_name': displayNameController.text,
          'regDateTime' : DateTime.now(),
          'profile_pic' : '',
        }).then((res) {
          isLoading = false;
          Navigator.pushReplacement (
            context,
            MaterialPageRoute(builder: (context) => Home()),
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
  }
  @override 
  void dispose() {
    super.dispose();
    emailController.dispose();
    displayNameController.dispose();
    passwordController.dispose();
  }
}