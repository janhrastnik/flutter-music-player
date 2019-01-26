import 'package:flutter/material.dart';
import 'dart:io';
import 'package:mp3_meta_data/mp3_meta_data.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'audioplayer.dart' as audioplayer;
import 'home.dart';

class SplashScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  Future<Directory> extDir;
  Directory extDir2;
  String kUrl;
  Uint8List image1;
  List _metaData;
  static const platform = const MethodChannel('demo.janhrastnik.com/info');
  List _musicFiles = [];

  _requestExtDirectory() {
    var dir = getExternalStorageDirectory();
    return dir;
  }

  void wrap() async {
    await getFiles();
    _getMetaData().then((data) {
      setState(() {
        _metaData = data;
        for (var i = 0; i < _musicFiles.length; i++) {
          if (data[i][0] == null) {
            String s = _musicFiles[i];
            for (var n = s.length; n > 0; n--) {
              if (s.substring(n - 2, n - 1) == "/") {
                _metaData[i][0] = s.substring(n-1, s.length - 4);
                break;
              }
            }
            if (data[i][1] == null) {
              _metaData[i][1] = "Unknown Artist";
            }
          }
        }
      });
      print("metaData is: " + _metaData.toString());
    });
    for (var i = 0; i < _musicFiles.length; i++) {
      try {
        image1 = await Mp3MetaData.getAlbumArt(_musicFiles[i]);
        _metaData[i][2] = image1;
      } catch(e) {
      }
    }
    audioplayer.allMetaData = _metaData;
    audioplayer.allFilePaths = _musicFiles;
    onDoneLoading();
  }

  void getFiles() async {
    await getExternalStorageDirectory().then((data) {
      extDir2 = data;
      setState(() {
        if (_musicFiles.isEmpty == true) {
          var mainDir = Directory(extDir2.path);
          List contents = mainDir.listSync(recursive: true);
          for (var fileOrDir in contents) {
            if (fileOrDir.path.toString().endsWith(".mp3")) {
              _musicFiles.add(fileOrDir.path);
            }
          }
        } else {
        }
      });
    });
    // print("musicfiles are: " + musicFiles.toString());
  }

  Future _getMetaData() async {
    var value;
    try {
      value = await platform.invokeMethod("getMetaData", <String, dynamic>{
        'filepaths': _musicFiles
      });
    } catch(e) {
      // print(e);
    }
    // print("the extracted metadata is: " + value.toString());
    return value;
  }

  onDoneLoading() async {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  void initState() {
    super.initState();
    extDir = _requestExtDirectory();
    wrap();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
        ),
      ),
    );
  }
}