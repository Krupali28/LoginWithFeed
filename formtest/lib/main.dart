import 'package:flutter/material.dart';
import 'package:formtest/root_page.dart';
import 'authentication.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Authentication Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RootPage(auth: new Auth())
    );
  }
}