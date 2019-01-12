import 'package:flutter/material.dart';
import 'dart:io';
import 'package:mp3_meta_data/mp3_meta_data.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'library.dart';
import 'audioplayer.dart' as audioplayer;
import 'package:audioplayer/audioplayer.dart';

class HomePage extends StatefulWidget {
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  Future<Directory> extDir;
  Directory extDir2;
  String kUrl;
  Uint8List image1;
  List _metaData;
  static const platform = const MethodChannel('demo.janhrastnik.com/info');
  List musicFiles = [];
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  void initAudioPlayer() {
    audioplayer.audioPlayer = new AudioPlayer();
    _positionSubscription = audioplayer.audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => audioplayer.position = p));
    _audioPlayerStateSubscription =
        audioplayer.audioPlayer.onPlayerStateChanged.listen((s) {
          if (s == AudioPlayerState.PLAYING) {
            setState(() =>
            audioplayer.duration = audioplayer.audioPlayer.duration);
          } else if (s == AudioPlayerState.STOPPED) {
            setState(() {
              audioplayer.position = audioplayer.duration;
            });
          }
        }, onError: (msg) {
          setState(() {
            // audioplayer.playerState = PlayerState.stopped;
            audioplayer.duration = new Duration(seconds: 0);
            audioplayer.position = new Duration(seconds: 0);
          });
        });
  }

  _requestExtDirectory() {
    var dir = getExternalStorageDirectory();
    return dir;
  }

  @override
  void initState() {
    super.initState();
    extDir = _requestExtDirectory();
    wrap();
    initAudioPlayer();
  }

  void wrap() async {
    await getFiles();
    _getMetaData().then((data) {
      setState(() {
        _metaData = data;
      });
      // print("metaData is: " + _metaData[0].toString());
    });
    for (var i = 0; i < musicFiles.length; i++) {
      try {
        image1 = await Mp3MetaData.getAlbumArt(musicFiles[i]);
        _metaData[i][2] = image1;
      } catch(e) {
      }
    }
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
    // print("musicfiles are: " + musicFiles.toString());
  }

  Future _getMetaData() async {
    var value;
    try {
      value = await platform.invokeMethod("getMetaData", <String, dynamic>{
        'filepaths': musicFiles
      });
    } catch(e) {
      // print(e);
    }
    // print("the extracted metadata is: " + value.toString());
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            children: <Widget>[
              Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey,
                                  // offset, the X,Y coordinates to offset the shadow
                                  offset: Offset(0.0, 0.0),
                                  // blurRadius, the higher the number the more smeared look
                                  blurRadius: 10.0,
                                  spreadRadius: 1.0)],
                          ),
                          child: Material(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10.0),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) => new Library(
                                        metadata: _metaData,
                                        musicFiles: musicFiles,
                                      )
                                  )
                                );
                              },
                              child: Container(
                                child: Center(
                                    child:Text("Library")),
                              ),
                            ),
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                      GridBlock(
                          route: "/PlaylistsList",
                          blockTitle: "Playlists"
                      ),
                      GridBlock(
                          route: "/FavouritesList",
                          blockTitle: "Favourites"
                      ),
                      GridBlock(
                          route: "/AlbumsList",
                          blockTitle: "Albums"
                      ),
                    ],
                  )
              )
            ]
        )
    );
  }
}

class GridBlock extends StatelessWidget {
  String route;
  String blockTitle;

  GridBlock({Key key, @required this.route, @required this.blockTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
                color: Colors.grey,
                // offset, the X,Y coordinates to offset the shadow
                offset: Offset(0.0, 0.0),
                // blurRadius, the higher the number the more smeared look
                blurRadius: 10.0,
                spreadRadius: 1.0)],
        ),
        child: Material(
          child: InkWell(
            borderRadius: BorderRadius.circular(10.0),
            onTap: () {
              Navigator.of(context).pushNamed(route);
            },
            child: Container(
              child: Center(child:Text(blockTitle)),
            ),
          ),
          color: Colors.transparent,
        ),
      ),
    );
  }
}
