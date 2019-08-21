import 'package:flutter/material.dart';
import 'package:formtest/root_page.dart';
import 'authentication.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'The Solo Female Travel',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
         // primaryColor: Color.fromRGBO(224, 17, 95, 1),
          primarySwatch: Colors.pink,
        ),
        home: new RootPage(auth: new Auth()));
  }
}
