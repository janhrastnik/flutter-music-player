import 'package:flutter/material.dart';
import 'dart:io';
import 'package:mp3_meta_data/mp3_meta_data.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'audioplayer.dart' as audioplayer;
import 'home.dart';
import 'dart:convert';

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
  List _metaData = [];
  static const platform = const MethodChannel('demo.janhrastnik.com/info');
  List _musicFiles = [];
  RegExp exp = RegExp(r"^([^\/]+)");
  Map mapMetaData = Map();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/filesmetadata.json');
  }

  Future<File> writeStoredMetaData(Map fileMetaData) async {
    final file = await _localFile;
    var jsonData = jsonEncode(fileMetaData);
    // Write the file
    return file.writeAsString(jsonData);
  }


  Future readStoredMetaData() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();
      return jsonDecode(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  void wrap() async {
    await getFiles();
    await _getAllMetaData();
    for (var i = 0; i < _musicFiles.length; i++) {
      if (_metaData[i][0] == null) {
        String s = _musicFiles[i];
        for (var n = s.length; n > 0; n--) {
          if (s.substring(n - 2, n - 1) == "/") {
            _metaData[i][0] = s.substring(n-1, s.length - 4);
            break;
          }
        }
        if (_metaData[i][1] == null) {
          _metaData[i][1] = "Unknown Artist";
        }
        if (_metaData[i][3] == null) {
          _metaData[i][3] = "Unknown Album";
        }
      }
      if (_metaData[i][4] != null) {
        Iterable<Match> matches = exp.allMatches(_metaData[i][4]);
        for (Match match in matches) {
          _metaData[i][4] = match.group(0);
        }
      } else {
        _metaData[i][4] = "0";
      }
    }

    for (var i = 0; i < _musicFiles.length; i++) {
      mapMetaData[_musicFiles[i]] = _metaData[i];
    }
    writeStoredMetaData(mapMetaData);
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
          } // tries to find external sd card
            var extSdDir = Directory('/mnt/m_external_sd/download');
            List sdContents = extSdDir.listSync(recursive: true);
            for (var fileOrDir in sdContents) {
              if (fileOrDir.path.toString().endsWith(".mp3")) {
                _musicFiles.add(fileOrDir.path);
              }
            }
        } else {
        }
      });
    });
  }

  Future _getAllMetaData() async {
    for (var track in _musicFiles) {
      var data = await _getFileMetaData(track);
      _metaData.add(data);
    }
  }

  Future _getFileMetaData(track) async {
    print(track);
    var value;
      try { // some tracks crash PlatformException(error, setDataSource failed: status = 0xFFFFFFED, null)
        if (mapMetaData[track] == null) {
          print("this is bad");
          value = await platform.invokeMethod("getMetaData", <String, dynamic>{
            'filepath': track
          });
        } else {
          print("this is what we want to see");
          value = mapMetaData[track];
        }
      } catch(e) {

      }
    return value;
  }

  onDoneLoading() async {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  void initState() {
    super.initState();
    readStoredMetaData().then((data) {
      if (data != 0) {
        mapMetaData = data;
      }
      wrap();
    });
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

/*
Future _getMetaData() async {
    var value;
    try {
      value = await platform.invokeMethod("getMetaData", <String, dynamic>{
        'filepaths': _musicFiles
      });
    } catch(e) {
    }
    return value;
  }
 */