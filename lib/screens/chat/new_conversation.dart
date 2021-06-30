import 'package:flutter/material.dart';
import 'package:chat_app/models/user.dart';

class NewConversationScreen extends StatelessWidget {
  const NewConversationScreen(
      {required this.uid, required this.contact});
  final String uid;
  final ChatUser contact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(automaticallyImplyLeading: true, title: Text(contact.name)),
        body: ChatScreen(uid: uid, contact: contact)); //convoID: convoID,
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {required this.uid, required this.contact}); //required this.convoID,
  final String uid; // convoID;
  final ChatUser contact;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String uid; // convoID;
  late ChatUser contact;

  @override
  void initState() {
    super.initState();
    uid = widget.uid;
    //convoID = widget.convoID;
    contact = widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              //buildMessages(),
              //buildInput(),
            ],
          ),
        ],
      ),
    );
  }
}