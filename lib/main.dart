import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayer/audioplayer.dart';
import 'dart:io';
import 'package:mp3_meta_data/mp3_meta_data.dart';
import 'dart:typed_data';

void main() => runApp(new MyApp());

enum PlayerState { stopped, playing, paused }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}

class HomePage extends StatelessWidget {
  Permission permission = Permission.ReadExternalStorage;

  _requestExtStorage(p) async {
    final r = await SimplePermissions.requestPermission(p);
    print("permission is " + r.toString());
  }

  @override
  Widget build(BuildContext context) {
    _requestExtStorage(permission);
    return Home();
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin<Home> {
  Future<Directory> extDir;
  String kUrl;

  List musicFiles = [];

  @override
  bool get wantKeepAlive => true;

  _requestExtDirectory() {
    var dir = getExternalStorageDirectory();
    return dir;
  }
  
  _getExtDirectory() {
    var dir = getExternalStorageDirectory().then((actualDir) {
      return actualDir;
    }
    );
  }

  AudioPlayer audioPlayer;
  PlayerState playerState;

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
  }
  Widget _buildDirectory(BuildContext context, AsyncSnapshot<Directory> snapshot) {
    Text text = const Text('');
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        text = new Text('Error: ${snapshot.error}');
      } else if (snapshot.hasData) {
        text = new Text('path: ${snapshot.data.path}');
      } else {
        text = const Text('path unavailable');
      }
    }

    if (musicFiles.isEmpty == true) {
      var mainDir = Directory(snapshot.data.path);
      List contents = mainDir.listSync(recursive: true);
      for (var fileOrDir in contents) {
        if (fileOrDir.path.toString().endsWith(".mp3")) {
          musicFiles.add(fileOrDir.path);
        }
      }
    } else {

    }

    print(musicFiles);
    return new ListView.builder(
        itemCount: musicFiles.length,
        itemBuilder: (BuildContext context, int index) {
          var missingImg = AssetImage("assets/noimage.png");
          return new ListTile(
            leading: Image(image: missingImg, width: 60.0, height: 60.0,),
            title: Text(musicFiles[index]),
            onTap: () {
              play();
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (BuildContext context) => new PlayingPage()
                  )
              );
          },
          );
        }
    );
  }

  @override
  void initState() {
    super.initState();
    extDir = _requestExtDirectory();
    initAudioPlayer();
    Directory extDir2 = _getExtDirectory();
    print(extDir2);
  }

  Future play() async {
    kUrl = '/storage/emulated/0/Epicano - Ocean.mp3';
    await audioPlayer.play(kUrl, isLocal: true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("musicplayer2")),
        body: Column(
          children: <Widget>[
            Expanded(
              child: FutureBuilder<Directory>(
                builder: _buildDirectory,
                future: extDir,
              )
            )
          ],
        ),
      ),
    );
  }
}

class PlayingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Text("yeet"),
      ),
    );
  }
}