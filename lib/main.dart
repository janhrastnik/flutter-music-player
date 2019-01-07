import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:flutter/services.dart';
import 'library.dart';
import 'home.dart';

void main() => runApp(new MyApp());



void hideAppBar() {
  SystemChrome.setEnabledSystemUIOverlays([]);
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    hideAppBar();
    return MaterialApp(
      home: HomePage(),
      routes: <String, WidgetBuilder>{
        "/Library": (BuildContext context) => Library()
    },
    );
  }
}