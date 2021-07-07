import 'package:chat_app/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserSearch extends StatefulWidget {

  final String convId;
  final String convName;

  const UserSearch({required this.convId, required this.convName});
  _UserSearchState createState() => _UserSearchState(convId: convId, convName: convName);
}

class _UserSearchState extends State<UserSearch> {
  final String convId;
  final String convName;
  _UserSearchState({required this.convId, required this.convName});

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
      padding: const EdgeInsets.only(top: 80), 
      itemCount: searchResultSnapshot.docs.length,
        itemBuilder: (context, index){
        return userTile(
          searchResultSnapshot.docs[index].id,
          searchResultSnapshot.docs[index].get('display_name'),
          searchResultSnapshot.docs[index].get('email'),
        );
        }) : Container();
  }
  AlertDialog addUser(String uid, String convId){
    FirebaseFirestore.instance.collection('conversations').doc(convId).get().then((DocumentSnapshot docSnapshot) {
      if (!docSnapshot.exists) {
        print("ERROR in fetching doc");
      } else if (docSnapshot.get('user_list').contains(uid)) {
        print("ERROR user already in conversation");
      } else {
        print("Successfully Added");
        List<dynamic> users = docSnapshot.get('user_list');
        users.add(uid);
        FirebaseFirestore.instance.collection('conversations').doc(convId).update({'user_list' : users});
      }
    });
    return AlertDialog(
      content: Text("Successfully added!"),
      actions: [
        TextButton(
          child: Text("Add Another"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Return"),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pop(context);
          },
        )
      ],
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
              showDialog(context: context,
              builder: (BuildContext context) {
                return addUser(uid, convId);
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(24)
              ),
              child: Text("Add",
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
  @override
  Widget build(BuildContext context) {
    bool isEmail = false;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add another user"),
        backgroundColor: Colors.indigo[400],
      ),
      body:
       isLoading ? Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ) :  Container(
        child: Stack(
          children: [
            userList(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.indigo[200],
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchEditingController,
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
            
          ],
        ),
      ),
    );
  }
}
