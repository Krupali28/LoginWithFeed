import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';

class User {
  String userId;
  String name;
  String email;
  int postCount;
  Image profileImg;


  User(this.userId, this.name, this.email,this.postCount,this.profileImg);

  User.fromSnapshot(DataSnapshot snapshot) :
    userId = snapshot.value["userId"],
    name = snapshot.value["name"],
    email = snapshot.value["email"],
    postCount = snapshot.value["postCount"],
    profileImg = snapshot.value["profileImg"];

  toJson() {
    return {
      "userId": userId,
      "name": name,
      "email": email,
      "postCount":postCount,
      "profileImg":profileImg
    };
  }

}