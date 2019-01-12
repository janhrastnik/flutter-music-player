import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'audioplayer.dart' as audioplayer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayer/audioplayer.dart';

String img = "images/noimage.png";

Future<bool> saveFavTrack(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("name", name);
}

Future getFavTrackList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String name = prefs.getString("name");
  return name;
}

class Library extends StatefulWidget {
  List metadata;
  List musicFiles;

  Library({Key key, @required this.musicFiles, this.metadata}) : super(key: key);

  @override
  _LibraryState createState() => new _LibraryState();
}

class _LibraryState extends State<Library>{
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  static const platform = const MethodChannel('demo.janhrastnik.com/info');

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

  void onComplete() {
    // setState(() => audioplayer.playerState = PlayerState.stopped);
  }

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
    print("in library, playerstate is ${audioplayer.playerState.toString()}");
  }

  getTitle(i) {
    if (widget.metadata[i][0] != null) {
      return Text(widget.metadata[i][0]);
    } else {
      String s = widget.musicFiles[i];
      for (var i = s.length; i > 0; i--) {
        if (s.substring(i-2, i-1) == "/") {
          return Text(s.substring(i-1, s.length-4));
        }
      }
    }
  }

  getSubTitle(i) {
    if (widget.metadata[i][1] != null) {
      return Text(widget.metadata[i][1]);
    } else {
      return Text("unknown");
    }
  }

  getImage(i) {
    if (widget.metadata[i][2]!= "") {
      return Image.memory(widget.metadata[i][2], width: MediaQuery.of(context).size.width/7,);
    } else {
      return Image.asset(img, width: MediaQuery.of(context).size.width/7);
    }
  }

  PlayerInfo() {
    if (audioplayer.playerState == audioplayer.PlayerState.playing || audioplayer.playerState == audioplayer.PlayerState.paused) {
      return
        Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(
                offset: Offset(5.0, 5.0),
                spreadRadius: 5.0,
                blurRadius: 15.0,
                color: Colors.grey
              )]
            ),
            padding: EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Row(children: <Widget>[
                    Text("Now playing: ",
                      style: TextStyle(
                          color: Colors.blueGrey
                      ),
                    ),
                    Expanded(
                      child: Text("${
                          widget.metadata[audioplayer.currTrack][0] != null
                              ? widget.metadata[audioplayer.currTrack][0]
                              : widget.musicFiles[audioplayer.currTrack]
                      } by ${
                          widget.metadata[audioplayer.currTrack][1] != null
                              ? widget.metadata[audioplayer.currTrack][1]
                              : "unknown"
                      }",
                        style: TextStyle(
                            fontSize: 12.0
                        ),
                      ),
                    ),
                    getIcon()
                  ],
                  ),
                  audioplayer.duration == null
                      ? Container()
                      : Slider(
                      value: audioplayer.position?.inMilliseconds?.toDouble() ?? 0.0,
                      onChanged: (double value) {
                        audioplayer.play(widget.musicFiles[audioplayer.currTrack]);
                        audioplayer.playerState = audioplayer.PlayerState.playing;
                        audioplayer.audioPlayer.seek((value / 1000).roundToDouble());
                      },
                      min: 0.0,
                      max: audioplayer.duration.inMilliseconds.toDouble()),
                ],
              ),
      );
    } else {
      return Container(
        color: Colors.yellow,
      );
    }
  }

  getIcon() {
    if (audioplayer.playerState == audioplayer.PlayerState.playing) {
      return InkWell(
            child: Icon(Icons.pause, size: 30.0,),
            onTap: () {
              audioplayer.pause();
              setState(() {
                audioplayer.playerState = audioplayer.PlayerState.paused;
              });

            }
        );
    } else if (audioplayer.playerState == audioplayer.PlayerState.paused) {
      return InkWell(
            child: Icon(Icons.play_arrow, size: 30.0,),
            onTap: () {
              audioplayer.play(widget.musicFiles[audioplayer.currTrack]);
              setState(() {
                audioplayer.playerState = audioplayer.PlayerState.playing;
              });

            }
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: Text("Library")),
            body: Column(
                children: <Widget>[
                  Expanded(
                      child: ListView.builder(
                          itemCount: widget.musicFiles.length,
                          itemBuilder: (BuildContext context, int index) {
                            return new ListTile(
                              leading: getImage(index),
                              title: getTitle(index),
                              subtitle: getSubTitle(index),
                              onTap: () {
                                audioplayer.fileList = widget.musicFiles;
                                audioplayer.currTrack = index;
                                audioplayer.metaData = widget.metadata;
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) => new PlayingPage(
                                          filePath: widget.musicFiles[index],
                                          image: widget.metadata[index][2],
                                          fileMetaData: widget.metadata[index][0] != null ? widget.metadata[index] : [widget.musicFiles[index], "unknown"] ,
                                        )
                                    )
                                );
                              },
                            );
                          }
                      )
                  ),
                  PlayerInfo()
                ]
            )
        )
    );
  }
}

class PlayingPage extends StatefulWidget {
  var filePath;
  var image;
  var fileMetaData;

  PlayingPage({Key key, @required this.filePath, this.image, this.fileMetaData}) : super(key: key);

  PlayingPageState createState() => PlayingPageState();
}

class PlayingPageState extends State<PlayingPage> {
  String _name;
  var missingImg = AssetImage("images/noimage.png");
  @override
  void initState() {
    super.initState();
    audioplayer.duration = new Duration(seconds: 0);
    audioplayer.position = new Duration(seconds: 0);
    audioplayer.stop();
    audioplayer.play(widget.filePath);
    audioplayer.playerState = audioplayer.PlayerState.playing;
    getFavTrackList().then((name) {
      this._name = name;
    });
  }

  get isPlaying => audioplayer.playerState == audioplayer.PlayerState.playing;
  get isPaused => audioplayer.playerState == audioplayer.PlayerState.paused;
  get durationText =>
      audioplayer.duration != null ? audioplayer.duration.toString().split('.').first : '';
  get positionText =>
      audioplayer.position != null ? audioplayer.position.toString().split('.').first : '';

  getIcon() {
    if (isPlaying == true || audioplayer.playerState == audioplayer.PlayerState.stopped) {
      return Padding(
        child: InkWell(
            child: Icon(Icons.pause, size: 50.0,),
            onTap: () {
              audioplayer.pause();
              setState(() {
                audioplayer.playerState = audioplayer.PlayerState.paused;
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
              audioplayer.play(widget.filePath);
              setState(() {
                audioplayer.playerState = audioplayer.PlayerState.playing;
              });

            }
        ),
        padding: EdgeInsets.only(top: 30.0),
      );
    }
  }

  getImage() {
    try {
      return Image.memory(widget.image);
    } catch(e) {
      return Image(image: missingImg,);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: InkWell(
            child: Icon(Icons.arrow_back),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => Library(
                      musicFiles: audioplayer.fileList,
                      metadata: audioplayer.metaData,
                  )
              ));
            },
          ),
          toolbarOpacity: 1.0,
          backgroundColor: Colors.white,
          elevation: 0.0,
          iconTheme: IconThemeData(
              color: Colors.black54
          ),),
        body: Column(
          children: <Widget>[
            Padding(
                child: getImage(),
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width/6,
                  bottom: MediaQuery.of(context).size.width/6,
                  right: MediaQuery.of(context).size.width/6,
                )
            ),
            Padding(
              padding: EdgeInsets.only(left: 30.0, right: 30.0),
              child: Text(widget.fileMetaData[0], style: TextStyle(fontSize: 20.0)),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text(widget.fileMetaData[1], style: TextStyle(fontSize: 18.0,)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: InkWell(
                    child: Icon(Icons.skip_previous, size: 30.0, color: Colors.blueGrey,),
                    onTap: () {
                      if (audioplayer.currTrack != 0) {
                        audioplayer.currTrack--;
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => PlayingPage(
                                filePath: audioplayer.fileList[audioplayer.currTrack],
                                image: audioplayer.metaData[audioplayer.currTrack][2],
                                fileMetaData: audioplayer.metaData[audioplayer.currTrack][0] != null
                                  ? audioplayer.metaData[audioplayer.currTrack] : [audioplayer.fileList[audioplayer.currTrack], "unknown"],
                            )
                        )
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: InkWell(
                    child: Icon(Icons.history, size: 50.0),
                    onTap: () {
                      setState(() {
                        audioplayer.audioPlayer.seek(0.0);
                        audioplayer.play(widget.filePath);
                        audioplayer.playerState = audioplayer.PlayerState.playing;
                      });
                    },
                  ),
                ),
                getIcon(),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: InkWell(
                    child: Icon(Icons.skip_next, size: 30.0, color: Colors.blueGrey,),
                    onTap: () {
                      if (audioplayer.currTrack != audioplayer.fileList.length-1) {
                        audioplayer.currTrack++;
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => PlayingPage(
                              filePath: audioplayer.fileList[audioplayer.currTrack],
                              image: audioplayer.metaData[audioplayer.currTrack][2],
                              fileMetaData: audioplayer.metaData[audioplayer.currTrack][0] != null
                                  ? audioplayer.metaData[audioplayer.currTrack] : [audioplayer.fileList[audioplayer.currTrack], "unknown"],
                            )
                        )
                        );
                      }
                    },
                  ),
                ),
            ],
            ),
            audioplayer.duration == null
                ? Container()
                : Slider(
                value: audioplayer.position?.inMilliseconds?.toDouble() ?? 0.0,
                onChanged: (double value) {
                  audioplayer.play(widget.filePath);
                  audioplayer.playerState = audioplayer.PlayerState.playing;
                  audioplayer.audioPlayer.seek((value / 1000).roundToDouble());
                },
                min: 0.0,
                max: audioplayer.duration.inMilliseconds.toDouble()),
                new Text(
                audioplayer.position != null
                    ? "${positionText ?? ''} / ${durationText ?? ''}"
                    : audioplayer.duration != null ? durationText : '',
                style: new TextStyle(fontSize: 24.0)),
          ],
        )
    );
  }
}