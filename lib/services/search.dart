import 'package:chat_app/models/user.dart';
import 'package:chat_app/screens/home/home.dart';
import 'package:chat_app/services/database.dart';
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
        return userTile(
          searchResultSnapshot.docs[index].id,
          searchResultSnapshot.docs[index].get('display_name'),
          searchResultSnapshot.docs[index].get('email'),
        );
        }) : Container();
  }
  createChat(String uid){
    CollectionReference _firestore = FirebaseFirestore.instance.collection('conversations');
    List<String> users = [FirebaseAuth.instance.currentUser!.uid, uid];
    return showDialog(context: context, 
      builder: (context){
        TextEditingController _textFieldController = TextEditingController();
          return AlertDialog(
            title: Text('Name your conversation'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter a name..."),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                  _textFieldController.clear();
                },
              ),
              TextButton(
                child: Text('Confirm'),
                onPressed: () {
                  _firestore
                  .doc().set({
                    'user_list': users,
                    'conversation_name': _textFieldController.text,
                    'last_message': ''
                  });
                  print(_textFieldController.text);
                  Navigator.pop(context);
                  _textFieldController.clear();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                },
              ),
            ],
          );
      }
    );
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
              createChat(uid);
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

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    bool isEmail = false;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
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
                        hintText: "search username or email...",
                        hintStyle: TextStyle(
                          color: Colors.white,
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
