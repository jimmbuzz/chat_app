import 'dart:async';
import 'package:chat_app/screens/chat/chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeBuilder extends StatelessWidget {

  Widget build(BuildContext context) {

    FirebaseAuth _auth = FirebaseAuth.instance;
    
    print(_auth.currentUser!.displayName);
    return Scaffold(
    body: Container(child: convoList()),
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
      key: Key(convName),
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