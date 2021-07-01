import 'package:chat_app/screens/chat/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/auth/authenticate.dart';

class ChatRoom extends StatelessWidget {
  @override 
  ChatRoom({this.uid});
  final String? uid;

  Widget build(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
        automaticallyImplyLeading: false,
        title: Text("Home"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.amber,
            ),
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
          )
        ]
      ),
      body: Container(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            conversations(),
          ],
        ),
      )  
    );
  }
  Widget conversations() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore
        .instance
        .collection('conversations')
        .snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Center (
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo)));
          } else {
            
            return ListView.separated(
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index){
                DocumentSnapshot data = snapshot.data!.docs[index];
                return ConversationBox(
                  chatRoomId: data.id,
                  chatRoomName: data.get('conversation_name'),
                  chatRoomLastMessage : data.get('last_message'),
                );
              },
              
              itemCount: snapshot.data!.docs.length,
              reverse: false,
            );
          }
        },
    );
  }
}
class ConversationBox extends StatelessWidget {
  final String chatRoomName;
  final String chatRoomLastMessage;
  final String chatRoomId;

  ConversationBox({required this.chatRoomName, required this.chatRoomLastMessage, required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => Chat(
            convId: chatRoomId, 
            convName: chatRoomName,
          )
        ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            Container(

              child: Text(chatRoomName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'OverpassRegular',
                      fontWeight: FontWeight.w300)),
            ),
            SizedBox(width: 12,height: 20,),
            showLastMessage(chatRoomLastMessage),
            SizedBox(width: 12,),
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
            return Center (
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo)));
          } else {
            return Text(snapshot.data.toString(), style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ));
          }
        },
    );
  }
}

