import 'package:chat_app/screens/auth/sign_in.dart';
import 'package:chat_app/services/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/auth/authenticate.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:chat_app/providers/newMessageProvider.dart';

class HomeBuilder extends StatelessWidget {
  @override
  HomeBuilder();
  // final String? uid;
  // final String? displayName;

  Widget build(BuildContext context) {
    //final User firebaseUser = Provider.of<User>(context);
    FirebaseAuth _auth = FirebaseAuth.instance;
    print(_auth.currentUser!.displayName);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
        automaticallyImplyLeading: false,
          title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
              onPressed: () {
                showDialog(context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Text("Sign Out?"),
                    actions: [
                      TextButton(
                        child: Text("Proceed"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _auth.signOut().then((res) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Authenticate()),
                            (Route<dynamic> route) => false);
                          });
                        },
                      ),
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
              },
              icon: Icon(Icons.arrow_back, size: 30)),
          showDisplayName(),
          IconButton(
              onPressed: () => createNewConvo(context),
              icon: Icon(Icons.add, size: 30))
        ],
      )),
      body: Column(children: <Widget>[]),
    );
  }

  void createNewConvo(BuildContext context) {
    Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => Search()));
  }
  Future<String> displayName() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();
    return docSnap.get('display_name');
  }
  Widget showDisplayName() {
    return FutureBuilder(
      future: displayName(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Center (
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo)));
          } else {
            return Text(snapshot.data.toString(), style: TextStyle(fontSize: 18));
          }
        },
    );
  }
}

