import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<void> addUserInfo(userData) async {
    FirebaseFirestore.instance.collection("users").add(userData).catchError((e) {
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
}