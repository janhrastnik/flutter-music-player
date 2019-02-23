import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'permissions.dart';

void main() => runApp(new MyApp());

void hideAppBar() {
  SystemChrome.setEnabledSystemUIOverlays([]);
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    hideAppBar();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GetPermissions(),
    );
  }
}