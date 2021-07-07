import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/auth/settings.dart';
import 'package:chat_app/screens/home/home.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  var currentUser = FirebaseAuth.instance.currentUser;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: Colors.indigo[400]
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
                Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;
                //lNameController.text = data['lastname'];
                //fNameController.text = data['firstname'];
                usernameController.text = data['display_name'];
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Container(
                      //   width: 200,
                      //   child: TextField(
                      //     controller: fNameController,
                      //     decoration: InputDecoration(
                      //         border: OutlineInputBorder(),
                      //         labelText: 'Enter First Name'),
                      //   ),
                      // ),
                      // Container(
                      //   width: 200,
                      //   child: TextField(
                      //     decoration: InputDecoration(
                      //         border: OutlineInputBorder(),
                      //         labelText: 'Enter Last Name'),
                      //     controller: lNameController,
                      //   ),
                      // ),
                      Container(
                        width: 200,
                        child: TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter Username'),
                          controller: usernameController,
                        ),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          String a = await updateUserInfo(data);
                          if (a.isNotEmpty) {
                            print("User values not changed");
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Error"),
                                    content: Text(a),
                                    actions: [
                                      ElevatedButton(
                                        child: Text("Ok"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                });
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Success!"),
                                    content: Text('Profile Updated'),
                                    actions: [
                                      ElevatedButton(
                                        child: Text("Ok"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                });
                          }
                        },
                        child: Text('Save', style: TextStyle(color: Colors.white)),
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
                onTap: () {},
              ),
              ListTile(
                title: Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SettingsPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  showAlertDialog(BuildContext context, String message) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          Container(margin: EdgeInsets.only(left: 5), child: Text(message)),
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
  Future<String> updateUserInfo(Map<String, dynamic> data) async {
    return await users
        .doc(currentUser!.uid)
        .set({
          'email': data['email'],
          'isAdmin': data['isAdmin'],
          //'regDateTime': DateTime.now(),
          //'firstname': fNameController.text,
          //'lastname': lNameController.text,
          'display_name': usernameController.text,
          'profile_pic': data['profile_pic']
        })
        .then((value) => '')
        .onError((error, stackTrace) => error.toString());
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
