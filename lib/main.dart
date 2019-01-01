import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayer/audioplayer.dart';
import 'dart:io';
import 'package:mp3_meta_data/mp3_meta_data.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

void main() => runApp(new MyApp());

enum PlayerState { stopped, playing, paused }
AudioPlayer audioPlayer;
PlayerState playerState;

Future play(url) async {
  await audioPlayer.play(url, isLocal: true);
}

Future pause() async {
  await audioPlayer.pause();
}

Future stop() async {
  await audioPlayer.stop();
}

void hideAppBar() {
  SystemChrome.setEnabledSystemUIOverlays([]);
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    hideAppBar();
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
  Directory extDir2;
  String kUrl;
  Uint8List image1;

  List musicFiles = [];

  @override
  bool get wantKeepAlive => true;

  _requestExtDirectory() {
    var dir = getExternalStorageDirectory();
    return dir;
  }
  
  _getExtDirectory() async {
    await getExternalStorageDirectory().then((dir) {
      setState(() {
        extDir2 = dir;
        print("extdir2 is " + extDir2.toString());
      });
    });
  }

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
  }
  // gets the music files
  
  void getFiles() {
    if (musicFiles.isEmpty == true) {
      var mainDir = Directory(extDir2.path);
      List contents = mainDir.listSync(recursive: true);
      for (var fileOrDir in contents) {
        if (fileOrDir.path.toString().endsWith(".mp3")) {
          musicFiles.add(fileOrDir.path);
        }
      }
    } else {

    }
    print(musicFiles);
  }

  @override
  void initState() {
    super.initState();
    extDir = _requestExtDirectory();
    initAudioPlayer();
    _getExtDirectory();
  }

  @override
  Widget build(BuildContext context) {
    getFiles();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("musicplayer2")),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: musicFiles.length,
                itemBuilder: (BuildContext context, int index) {
                  var missingImg = AssetImage("assets/noimage.png");
                  return new ListTile(
                    leading: Image(image: missingImg, width: 60.0, height: 60.0,),
                    title: Text(musicFiles[index]),
                    onTap: () async {
                      try {
                        image1 = await Mp3MetaData.getAlbumArt(musicFiles[index]);
                      } catch(e) {

                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) => new PlayingPage(
                            filePath: musicFiles[index],
                            image: image1,
                          )
                        )
                      );
                    },
                  );
                }
              )
            )
          ]
        )
      )
    );
  }
}

class PlayingPage extends StatefulWidget {
  var filePath;
  var image;

  PlayingPage({Key key, @required String this.filePath, this.image}) : super(key: key);

  PlayingPageState createState() => PlayingPageState();
}

class PlayingPageState extends State<PlayingPage> {
  var _metaData;
  static const platform = const MethodChannel('demo.janhrastnik.com/info');
  @override
  void initState() {
    super.initState();
    stop();
    play(widget.filePath);
    playerState = PlayerState.playing;
    _getMetaData().then((String data) {
      setState(() {
        _metaData = data;
      });
    });
  }

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  getIcon() {
    if (isPlaying == true) {
      return Icon(Icons.pause);
    } else {
      return Icon(Icons.play_arrow);
    }
  }

  @override
  Widget build(BuildContext context) {
    var missingImg = AssetImage("assets/noimage.png");
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: <Widget>[
            widget.image != null ? Image.memory(widget.image) : Image(image: missingImg,),
            Text("song name placeholder"),
            InkWell(
              child: getIcon(),
              onTap: () {
                if (isPlaying == true) {
                  pause();
                  setState(() {
                    playerState = PlayerState.paused;
                  });
                } else {
                  stop();
                  play(widget.filePath);
                  setState(() {
                    playerState = PlayerState.playing;
                  });
                }
              },
            ),
            Text(_metaData)
          ],
        )
      ),
    );
  }

  Future<String> _getMetaData() async {
    String value;
    try {
      value = await platform.invokeMethod("getMetaData", <String, dynamic>{
        'filepath': widget.filePath
      });
    } catch(e) {
      print(e);
    }
    return value;
  }
}