//import 'package:chatapp/helper/constants.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/screens/home/home.dart';
import 'package:chat_app/services/database.dart';
//import 'package:chatapp/views/chat.dart';
//import 'package:chatapp/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchEditingController = new TextEditingController();
  late QuerySnapshot searchResultSnapshot;
  //CollectionReference<Map<String, dynamic>> searchResultSnapshot = FirebaseFirestore.instance.collection('users');

  bool isLoading = false;
  bool haveUserSearched = false;

  initiateSearch(isEmail) async {
    if(searchEditingController.text.isNotEmpty){
      setState(() {
        isLoading = true;
      });
      if (!isEmail) {
        await databaseMethods.searchByName(searchEditingController.text)
          .then((snapshot){
          searchResultSnapshot = snapshot;
          print("$searchResultSnapshot");
          setState(() {
            isLoading = false;
            haveUserSearched = true;
          });
        });
      } 
      else {
        await databaseMethods.searchByEmail(searchEditingController.text)
          .then((snapshot){
          searchResultSnapshot = snapshot;
          print("$searchResultSnapshot");
          setState(() {
            isLoading = false;
            haveUserSearched = true;
          });
        });
      }
    }
  }

  Widget userList(){
    return haveUserSearched ? ListView.builder(
      shrinkWrap: true,
      itemCount: searchResultSnapshot.docs.length,
        itemBuilder: (context, index){
        print(searchResultSnapshot.docs[index].id);
        print(searchResultSnapshot.docs[index].get('display_name'));
        print(searchResultSnapshot.docs[index].get('email'));
        
        
        
        return userTile(
          


          searchResultSnapshot.docs[index].id,
          searchResultSnapshot.docs[index].get('display_name'),
          searchResultSnapshot.docs[index].get('email'),
        );
        }) : Container();
  }

  // 1.create a chatroom, send user to the chatroom, other userdetails
  sendMessage(String uid){
    CollectionReference _firestore = FirebaseFirestore.instance.collection('conversations');
    List<String> users = [FirebaseAuth.instance.currentUser!.uid, uid];

    //String chatRoomId = getChatRoomId(Constants.myName,userName);

    // Map<String, dynamic> chatRoom = {
    //   "users": users,
    //   "chatRoomId" : chatRoomId,
    // };

    //databaseMethods.addChatRoom(chatRoom, chatRoomId);
    
    _firestore.doc().set({
      'user_list': users,
      'conversation_name': 'A Conversation',
      'last_message': ''
    });
    print("Convo id:"+_firestore.doc().id);
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => Home(
        //chatRoomId: ,
      )
    ));

  }

  Widget userTile(String uid, String userName,String userEmail){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16
                ),
              ),
              Text(
                userEmail,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16
                ),
              )
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: (){
              sendMessage(uid);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(24)
              ),
              child: Text("Message",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                ),),
            ),
          )
        ],
      ),
    );
  }


  // getChatRoomId(String a, String b) {
  //   if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
  //     return "$b\_$a";
  //   } else {
  //     return "$a\_$b";
  //   }
  // }

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    bool isEmail = false;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
        //automaticallyImplyLeading: false,
      ),
      body:
       isLoading ? Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ) :  Container(
        
        child: Column(
          
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.indigo[200],//Color(0x54FFFFFF),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchEditingController,
                      //style: simpleTextStyle(),
                      decoration: InputDecoration(
                        hintText: "search username ...",
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        border: InputBorder.none
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      if(searchEditingController.text.contains('@')){
                        isEmail = true;
                      } else {
                        isEmail = false;
                      }
                      initiateSearch(isEmail);
                    },
                    child: Container(
                      height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0x36FFFFFF),
                              const Color(0x0FFFFFFF)
                            ],
                            begin: FractionalOffset.topLeft,
                            end: FractionalOffset.bottomRight
                          ),
                          borderRadius: BorderRadius.circular(40)
                        ),
                        padding: EdgeInsets.all(12),
                        child: Image.asset("assets/images/search_white.png",
                          height: 25, width: 25,)),
                  )
                ],
              ),
            ),
            userList()
          ],
        ),
      ),
    );
  }
}

