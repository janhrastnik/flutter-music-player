import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayer/audioplayer.dart';
import 'dart:io';
import 'package:mp3_meta_data/mp3_meta_data.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:async';

void main() => runApp(new MyApp());

enum PlayerState { stopped, playing, paused }
AudioPlayer audioPlayer;
PlayerState playerState;
Duration duration;
Duration position;

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
    return
      Home();
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home>{
  Future<Directory> extDir;
  Directory extDir2;
  String kUrl;
  Uint8List image1;
  List _metaData;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  static const platform = const MethodChannel('demo.janhrastnik.com/info');

  List musicFiles = [];

  _requestExtDirectory() {
    var dir = getExternalStorageDirectory();
    return dir;
  }

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
          if (s == AudioPlayerState.PLAYING) {
            setState(() => duration = audioPlayer.duration);
          } else if (s == AudioPlayerState.STOPPED) {
            onComplete();
            setState(() {
              position = duration;
            });
          }
        }, onError: (msg) {
          setState(() {
            playerState = PlayerState.stopped;
            duration = new Duration(seconds: 0);
            position = new Duration(seconds: 0);
          });
        });

  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  void getFiles() async {
    await getExternalStorageDirectory().then((data) {
      extDir2 = data;
      setState(() {
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
      });
    });
    print("musicfiles are: " + musicFiles.toString());
  }

  @override
  void initState() {
    super.initState();
    extDir = _requestExtDirectory();
    initAudioPlayer();
    wrap();
  }

  void wrap() async {
    await getFiles();
    _getMetaData().then((data) {
     setState(() {
       _metaData = data;
     });
      print("metaData is: " + _metaData[0]);
    });
  }

  getTitle(i) {
    if (_metaData != null) {
      return Text(_metaData[i][0]);
  } else {
      return Text("fkthis");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    title: getTitle(index),
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
                            fileMetaData: _metaData[index],
                          )
                        )
                      );
                    },
                  );
                }
              )
            ),
          ]
        )
      )
    );
  }

  Future _getMetaData() async {
    var value;
    try {
      value = await platform.invokeMethod("getMetaData", <String, dynamic>{
        'filepaths': musicFiles
      });
    } catch(e) {
      print(e);
    }
    print("the extracted metadata is: " + value.toString());
    return value;
  }
}

class PlayingPage extends StatefulWidget {
  var filePath;
  var image;
  var fileMetaData;

  PlayingPage({Key key, @required String this.filePath, this.image, this.fileMetaData}) : super(key: key);

  PlayingPageState createState() => PlayingPageState();
}

class PlayingPageState extends State<PlayingPage> {
  @override
  void initState() {
    super.initState();
    print("playerstate is ${playerState.toString()}");
    stop();
    play(widget.filePath);
    playerState = PlayerState.playing;
  }

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;
  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  getIcon() {
    if (isPlaying == true || playerState == PlayerState.stopped) {
      return Padding(
        child: InkWell(
          child: Icon(Icons.pause, size: 50.0,),
            onTap: () {
                pause();
                setState(() {
                  playerState = PlayerState.paused;
                });

            }
        ),
        padding: EdgeInsets.only(top: 30.0),
        );
      } else if (isPlaying == false) {
      return Padding(
        child: InkWell(
          child: Icon(Icons.play_arrow, size: 50.0,),
            onTap: () {
                play(widget.filePath);
                setState(() {
                  playerState = PlayerState.playing;
                });

            }
        ),
        padding: EdgeInsets.only(top: 30.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var missingImg = AssetImage("assets/noimage.png");
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarOpacity: 1.0,
          backgroundColor: Colors.white,
          elevation: 0.0,
          iconTheme: IconThemeData(
            color: Colors.black54
          ),),
        body: Column(
          children: <Widget>[
            Padding(
              child: widget.image != null ? Image.memory(widget.image) : Image(image: missingImg,),
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width/6,
                  bottom: MediaQuery.of(context).size.width/6,
                  right: MediaQuery.of(context).size.width/6,
              )
            ),

            Text(widget.fileMetaData[0], style: TextStyle(fontSize: 20.0)),
            Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text(widget.fileMetaData[1], style: TextStyle(fontSize: 18.0,)),
            ),
            getIcon(),
            duration == null
                ? Container()
                : Slider(
                value: position?.inMilliseconds?.toDouble() ?? 0.0,
                onChanged: (double value) =>
                    audioPlayer.seek((value / 1000).roundToDouble()),
                min: 0.0,
                max: duration.inMilliseconds.toDouble()),
            new Text(
                position != null
                    ? "${positionText ?? ''} / ${durationText ?? ''}"
                    : duration != null ? durationText : '',
                style: new TextStyle(fontSize: 24.0))
            ],
        )
    );
  }
}