import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/auth/authenticate.dart';

class ChatRoom extends StatelessWidget {
  @override 
  ChatRoom({this.uid});
  final String? uid;
//   _ChatRoomState createState() => _ChatRoomState();
// }

// class _ChatRoomState extends State<ChatRoom> {
//   //Stream chatRooms;

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
        //.orderBy('timeStamp', descending: true)
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
                //DocumentSnapshot lastMessage = FirebaseFirestore.instance.collection('messages').get(data.get('last_message'));
                return ConversationBox(
                  chatRoomName: data.get('conversation_name'),
                  //chatRoomLastMessage: lastMessage(snapshot.data),
                );
              },
              
              itemCount: snapshot.data!.docs.length,
              reverse: false,
            );
          }
        },
    );
  }
  // Future<String> lastMessage(QuerySnapshot<Object?>? data) async {
  //   final string conversationId = ;
    
  // }
}
class ConversationBox extends StatelessWidget {
  //final String userName;
  final String chatRoomName;
  //final String chatRoomLastMessage;

  ConversationBox({required this.chatRoomName});//, required this.chatRoomLastMessage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (context) => Chat(
        //     chatRoomId: chatRoomId,
        //   )
        // ));
        //print (chatRoomLastMessage);
      },
      child: Container(
        //color: Colors.indigo[200],
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        //decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        
        child: Row(
          children: [
            Container(
              //height: 30,
              //width: 30,
              // decoration: BoxDecoration(
              //     color: Colors.amberAccent,
              //     borderRadius: BorderRadius.circular(30)),
              child: Text(chatRoomName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'OverpassRegular',
                      fontWeight: FontWeight.w300)),
            ),
            // SizedBox(width: 12,height: 20,),
            // Container(child: Text("\""+chatRoomLastMessage+"\"",
            //       //textAlign: TextAlign.center,
            //       style: TextStyle(
            //           color: Colors.black,
            //           fontSize: 16,
            //           fontFamily: 'OverpassRegular',
            //           fontWeight: FontWeight.w300)))
            // SizedBox(
            //   width: 12,
            // ),
            // Text(userName,
            //     textAlign: TextAlign.start,
            //     style: TextStyle(
            //         color: Colors.white,
            //         fontSize: 16,
            //         fontFamily: 'OverpassRegular',
            //         fontWeight: FontWeight.w300))
          ],
        ),
      ),
    );
  }
}
//class 

