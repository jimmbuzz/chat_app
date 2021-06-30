// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:chat_app/models/user.dart';

// class Database {
//   static final FirebaseFirestore _db = FirebaseFirestore.instance;

//   // static Future<void> addUser(User user) async {
//   //   await _db.collection('users').doc(user.uid).setData(
//   //       {'id': user.uid, 'name': user.displayName, 'email': user.email});
//   // }
//    static Stream<List<ChatUser>> streamUsers() {
//     return _db
//         .collection('users')
//         .snapshots()
//         .map((QuerySnapshot list) => list.docs
//             .map((DocumentSnapshot snap) => ChatUser.fromMap(snap.data()))
//             .toList())
//         .handleError((dynamic e) {
//       print(e);
//     });
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<void> addUserInfo(userData) async {
    FirebaseFirestore.instance.collection("users").add(userData).catchError((e) {
      print(e.toString());
    });
  }

  getUserInfo(String email) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("userEmail", isEqualTo: email)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  searchByName(String searchField) {
    return FirebaseFirestore.instance
        .collection("users")
        .where('display_name', isEqualTo: searchField)
        .get();
  }
  searchByEmail(String searchField) {
    return FirebaseFirestore.instance
        .collection("users")
        .where('email', isEqualTo: searchField)
        .get();
  }
  // Future<bool> addChatRoom(chatRoom, chatRoomId) {
  //   FirebaseFirestore.instance
  //       .collection("chatRoom")
  //       .doc(chatRoomId)
  //       .set(chatRoom)
  //       .catchError((e) {
  //     print(e);
  //   });
  // }

  getChats(String chatRoomId) async{
    return FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy('time')
        .snapshots();
  }


  Future<void> addMessage(String chatRoomId, chatMessageData)async {

    FirebaseFirestore.instance.collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .add(chatMessageData).catchError((e){
          print(e.toString());
    });
  }

  getUserChats(String itIsMyName) async {
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .where('users', arrayContains: itIsMyName)
        .snapshots();
  }

}