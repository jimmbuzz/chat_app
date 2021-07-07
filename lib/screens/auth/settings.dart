import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screens/auth/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chat_app/screens/auth/authenticate.dart';
import 'package:chat_app/screens/home/home.dart';

import 'profile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  //TextEditingController propicController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? currentUser = FirebaseAuth.instance.currentUser;
  //bool anon = currentUser!.isAnonymous;
  
  @override
  Widget build(BuildContext context) {
    bool anon = currentUser!.isAnonymous;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          backgroundColor: Colors.indigo[400],
        ),
        body: FutureBuilder<DocumentSnapshot>(
            future: users.doc(currentUser!.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) { 
                return Text("Something went wrong");
              }

              if (snapshot.hasData && !snapshot.data!.exists) {
                return Text("Data does not exist");
              }
              if (snapshot.connectionState == ConnectionState.done) {
                Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                emailController.text = data['email'];
                //propicController.text = data['profile_pic'] == null ? '' : data['profile_pic'];
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      anon == false ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 200,
                            child: TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Enter Email'),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              if (data['email'] !=
                                  emailController.text.trim()) {
                                updateEmail(
                                    emailController.text.trim()).then((value) => updateUserInfo(data)).then((value) => 
                                    showDialog(context: context, 
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Success! Email Updated'),
                                          //content: Text(e.message.toString()),
                                          actions: [
                                            TextButton(
                                              child: Text("Ok"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            )
                                          ]
                                        );
                                      })
                                    );
                                // if (c.isNotEmpty) {
                                //   showAlertDialog(c);
                                //   return;
                                // } else {
                                //   showAlertDialog('Success! Email Updated');
                                // }
                              }
                              // String a = await updateUserInfo(data);
                              // if (a.isNotEmpty) {
                              //   showAlertDialog(a);
                              //   return;
                              // }
                              
                            },
                            icon: Icon(Icons.check),
                          )
                        ],
                      ) : Container(),
                      anon == false ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 200,
                            child: TextField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Enter Password'),
                              controller: pwdController,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () async {
                              String pwd = pwdController.text.trim();
                              if (pwd.isNotEmpty && pwd.length > 6) {
                                String b = await updatePassword(
                                    pwdController.text.trim());
                                if (b.isNotEmpty) {
                                  print("User values not changed");
                                  showAlertDialog(b);
                                  return;
                                }
                              } else {
                                showAlertDialog('Not a Valid Password!');
                                return;
                              }
                              showAlertDialog('Success! Password updated');
                            }
                          )
                        ],
                      ) : ElevatedButton(
                        child: Text('Register'),
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EmailSignUp()));
                        }
                      ),
                      //Unused but may be repurposed in the future...
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Container(
                      //       width: 200,
                      //       child: TextField(
                      //         decoration: InputDecoration(
                      //             border: OutlineInputBorder(),
                      //             labelText: 'Enter Profile Pic URL'),
                      //         controller: propicController,
                      //       ),
                      //     ),
                      //     IconButton(
                      //         icon: Icon(Icons.check),
                      //         onPressed: () async {
                      //           String a = await updateUserInfoPro(data);
                      //           if (a.isNotEmpty) {
                      //             showAlertDialog(a);
                      //             return;
                      //           }
                      //           showAlertDialog('Success! Profile Pic Updated');
                      //         })
                      //   ],
                      // ),
                      MaterialButton(
                        onPressed: () {
                          linkGoogle();
                        },
                        child: Text('Link Google Account', style: TextStyle(color: Colors.white)),
                        color: Colors.indigo,
                      ),
                      MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                          FirebaseAuth.instance.signOut();
                          _googleSignIn.signOut();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Authenticate()));
                        },
                        child: Text('Logout', style: TextStyle(color: Colors.white)),
                        color: Colors.indigo,
                      )
                    ],
                  ),
                );
              }

              return Center(
                  child: CircularProgressIndicator(
                semanticsLabel: 'Loading...',
              ));
            }),
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.indigo[400],
                ),
                child: profilePic()
              ),
              ListTile(
                title: Text('Chats'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Home()));
                },
              ),
              ListTile(
                title: Text('Profile'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                },
              ),
              ListTile(
                title: Text('Settings'),
                onTap: () {}, 
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<String> updateUserInfo(Map<String, dynamic> data) async {
    return await users
        .doc(currentUser!.uid)
        .set({
          'firstname': data['firstname'],
          'isAdmin': data['isAdmin'],
          'regDateTime': DateTime.now(),
          'email': emailController.text,
          'lastname': data['lastname'],
          'username': data['username'],
          //'profile_pic': data['profile_pic']
        })
        .then((value) => '')
        .onError((error, stackTrace) => error.toString());
  }
  Future<String> updateUserInfoPro(Map<String, dynamic> data) async {
    return await users
        .doc(currentUser!.uid)
        .set({
          'firstname': data['firstname'],
          'isAdmin': data['isAdmin'],
          'regDateTime': DateTime.now(),
          'email': data['email'],
          'lastname': data['lastname'],
          'username': data['username'],
          //'profile_pic': propicController.text
        })
        .then((value) => '')
        .onError((error, stackTrace) => error.toString());
  }
  Future<String> updatePassword(String pwd) async {
    return currentUser!
        .updatePassword(pwd)
        .then((value) => '')
        .onError((error, stackTrace) => error.toString());
  }
  Future<String> updateEmail(String email) async {
    return currentUser!
        .updateEmail(email)
        .then((value) => '')
        .onError((error, stackTrace) => error.toString());
  }
  showAlertDialog(String message) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          Text(message),
        ],
      ),
      actions: [okButton],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  linkGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    final AuthCredential gcredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    //now link these credentials with the existing user
    try { 
      await currentUser!.linkWithCredential(gcredential); 
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        _googleSignIn.signOut();
        showDialog(context: context, 
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(e.message.toString()),
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
      } else {
        _googleSignIn.signOut();
        showDialog(context: context, 
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(e.message.toString()),
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
      } 
    }
  }
  Future<String> profilePicURL() async {
    //String? photoURL = FirebaseAuth.instance.currentUser!.photoURL;
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();
    return docSnap.get('profile_pic');
  }
  Widget profilePic() {
    return FutureBuilder(
      future: profilePicURL(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            constraints: BoxConstraints.expand(),
            child: Icon(Icons.account_circle_outlined, size: 75, color: Colors.indigo[100],)
          );
        } else if (snapshot.data.toString().isEmpty) {
          print("Deboog: "+snapshot.data.toString().isEmpty.toString());
          String url = snapshot.data.toString();
          return Container(
            child: Icon(Icons.account_circle_outlined, size: 75, color: Colors.indigo[100],)
          );
        } else {
          String url = snapshot.data.toString();
          print("Debag: "+snapshot.data.toString());
          return Container(
            constraints: BoxConstraints.expand(),
            child: CachedNetworkImage(
              width: 75,
              height: 75,
              imageUrl: url,
              placeholder: (context,url) => Icon(Icons.account_circle_outlined, size: 75, color: Colors.indigo[100],),
              errorWidget: (context,url,error) => Icon(Icons.account_circle_outlined, size: 75, color: Colors.indigo[100],),
            )
          );
        }
      }
    );
  }
}
