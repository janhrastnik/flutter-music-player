import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:flutter/services.dart';
import 'home.dart';

void main() => runApp(new MyApp());

void hideAppBar() {
  SystemChrome.setEnabledSystemUIOverlays([]);
}

class MyApp extends StatelessWidget {
  Permission permission = Permission.ReadExternalStorage;
  _requestExtStorage(p) async {
    final r = await SimplePermissions.requestPermission(p);
    print("permission is " + r.toString());
  }

  @override
  Widget build(BuildContext context) {
    _requestExtStorage(permission);
    hideAppBar();
    return MaterialApp(
      home: HomePage(),
    );
  }
}