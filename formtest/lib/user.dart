// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_database/firebase_database.dart';

// class User {
//   String email;
//   String id;
//   String photoUrl;
//   String username;
//   String displayName;
//   String bio;
//   Map followers;
//   Map following;

//   User(this.email, this.id, this.photoUrl,this.username,this.displayName,this.bio,this.followers,this.following);

//   User.fromSnapshot(DataSnapshot snapshot) :
//     email = snapshot.value["email"],
//     id = snapshot.value["id"],
//     photoUrl = snapshot.value["photoUrl"],
//     username = snapshot.value["username"],
//     displayName = snapshot.value["displayName"],
//     bio = snapshot.value["bio"],
//     followers = snapshot.value["followers"],
//     following = snapshot.value["following"];

//   toJson() {
//     return {
//       "email": email,
//       "id": id,
//       "photoUrl": photoUrl,
//       "username":username,
//       "displayName":displayName,
//       "bio": bio,
//       "followers":followers,
//       "following":following,
//     };
//   }

//   factory User.fromDocument(DocumentSnapshot document) {
//     return User(
//       email: document['email'],
//       username: document['username'],
//       photoUrl: document['photoUrl'],
//       id: document.documentID,
//       displayName: document['displayName'],
//       bio: document['bio'],
//       followers: document['followers'],
//       following: document['following'],
//     );

// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class User {
  final String email;
  final String id;
  final String photoUrl;
  final String username;
  final String displayName;
  final String bio;
  final Map followers;
  final Map following;

  const User( 
      {this.username,
      this.id,
      this.photoUrl,
      this.email,
      this.displayName,
      this.bio,
      this.followers,
      this.following});

 toJson() {
    return {
      "email": email,
      "id": id,
      "photoUrl": photoUrl,
      "username":username,
      "displayName":displayName,
      "bio": bio,
      "followers":followers,
      "following":following,
    };
  }
  User.fromSnapshot(DataSnapshot snapshot) :
    email = snapshot.value["email"],
    id = snapshot.value["id"],
    photoUrl = snapshot.value["photoUrl"],
    username = snapshot.value["username"],
    displayName = snapshot.value["displayName"],
    bio = snapshot.value["bio"],
    followers = snapshot.value["followers"],
    following = snapshot.value["following"];
    
  factory User.fromDocument(DocumentSnapshot document) {
    // return User(
    //   email: document['email'],
    //   username: document['username'],
    //   photoUrl: document['photoUrl'],
    //   id: document.documentID,
    //   displayName: document['displayName'],
    //   bio: document['bio'],
    //   followers: document['followers'],
    //   following: document['following'],
    // );
    return User(
      email:'dfskjhfs',
      username: 'skfjhfg',
      photoUrl:null,
      id: document.documentID,
      displayName:'sdjhfg',
      bio: 'dshfghsdf',
     // followers:'asd',
     // following:"asd",
    );
  }
}
