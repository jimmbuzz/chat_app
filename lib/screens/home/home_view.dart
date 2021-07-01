import 'package:chat_app/screens/chat/chat.dart';
import 'package:chat_app/screens/search/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/auth/authenticate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeBuilder extends StatelessWidget {
  @override
  HomeBuilder();

  Widget build(BuildContext context) {

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
              icon: Icon(Icons.arrow_back, size: 30)
            ),
            showDisplayName(),
            IconButton(
                onPressed: () => createNewConvo(context),
                icon: Icon(Icons.add, size: 30)
            )
          ],
      )
    ),
    body: Container(child: convoList()),
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
  Widget convoList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore
        .instance
        .collection('conversations')
        .where('user_list', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Center (
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo)));
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index){
                DocumentSnapshot data = snapshot.data!.docs[index];
                return ChatRoomsTile(convId: data.id, convName: data.get('conversation_name'), convLastMessage: data.get('last_message'),);
              },
              itemCount: snapshot.data!.docs.length,
            );
          }
        },
    );
  }
}
class ChatRoomsTile extends StatelessWidget {
  final String convId;
  final String convName;
  final String convLastMessage;

  ChatRoomsTile({required this.convId, required this.convName, required this.convLastMessage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => Chat(
            convId: convId,
            convName: convName,
          )
        ));
      },
      child: Container (
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20), 
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 12,
                ),
                Text(convName,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'OverpassRegular',
                        fontWeight: FontWeight.w400
                      )
                    ),
              ],
            ),
            Row(children: [
              SizedBox(
                width: 16,
              ),
              showLastMessage(convLastMessage),
            ],)
          ],
        ),
      ),
    );
  }
  Future<String> displayMessage(String messageId) async {
    final DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection('messages').doc(messageId).get();
    return docSnap.get('content');
  }
  Widget showLastMessage(String messageId) {
    return FutureBuilder(
      future: displayMessage(messageId),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Container();
          } else {
            if (snapshot.data.toString().length > 30) {
              return Text("\""+snapshot.data.toString().substring(0, 25)+"...\"", style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'OverpassRegular',
                fontWeight: FontWeight.w300
              ));
            } else {
              return Text("\""+snapshot.data.toString()+"\"", style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'OverpassRegular',
                fontWeight: FontWeight.w300
              ));
            }
          }
        },
    );
  }
}