import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Random random = Random();
List names = [
  "Ling Waldner",
  "Gricelda Barrera",
  "Lenard Milton",
  "Bryant Marley",
  "Rosalva Sadberry",
  "Guadalupe Ratledge",
  "Brandy Gazda",
  "Kurt Toms",
  "Rosario Gathright",
  "Kim Delph",
  "Stacy Christensen",
];
List posts = List.generate(13, (index)=>{
    "name": names[random.nextInt(10)],
    "dp": 'assets/cm${random.nextInt(10)}.jpeg',
    "time": "${random.nextInt(50)} min ago",
    "img": 'assets/cm${random.nextInt(10)}.jpeg'
});



class Post {
  String userId;
  String name;
  String dp;
  TimeOfDay time;
  Image img;


  Post(this.userId, this.name, this.dp,this.time,this.img);

  Post.fromSnapshot(DataSnapshot snapshot) :
    userId = snapshot.value["userId"],
    name = snapshot.value["name"],
    dp = snapshot.value["dp"],
    time = snapshot.value["time"],
    img = snapshot.value["img"];

  toJson() {
    return {
      "userId": userId,
      "name": name,
      "dp": dp,
      "time":time,
      "img":img
    };
  }

}