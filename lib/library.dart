import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayer/audioplayer.dart';
import 'dart:io';
import 'package:mp3_meta_data/mp3_meta_data.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:async';
import 'playlist.dart' as playlist;

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

var missImg = "https://upload.wikimedia.org/wikipedia/commons/2/26/512pxIcon-sunset_photo_not_found.png";

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
            // playerState = PlayerState.stopped;
            duration = new Duration(seconds: 0);
            position = new Duration(seconds: 0);
          });
        });

  }

  void onComplete() {
    // setState(() => playerState = PlayerState.stopped);
  }


  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
    print("in library, playerstate is ${playerState.toString()}");
  }

  getTitle(i) {
    try {
      return Text(widget.metadata[i][0]);
    } catch(e) {
      String s = widget.musicFiles[i];
      for (var i = s.length; i > 0; i--) {
        if (s.substring(i-2, i-1) == "/") {
          return Text(s.substring(i-1, s.length-4));
        }
      }
    }
  }

  getSubTitle(i) {
    try {
      return Text(widget.metadata[i][1]);
    } catch(e) {
      return Text("unknown");
    }
  }

  getImage(i) {
    try {
      return Image.memory(widget.metadata[i][2], width: MediaQuery.of(context).size.width/7,);
    } catch(e) {
      return Image.network(missImg, width: MediaQuery.of(context).size.width/7,);
    }
  }

  PlayerInfo() {
    if (playerState == PlayerState.playing || playerState == PlayerState.paused) {
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
                          widget.metadata[playlist.currTrack][0] != null
                              ? widget.metadata[playlist.currTrack][0]
                              : widget.musicFiles[playlist.currTrack]
                      } by ${
                          widget.metadata[playlist.currTrack][1] != null
                              ? widget.metadata[playlist.currTrack][1]
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
                  duration == null
                      ? Container()
                      : Slider(
                      value: position?.inMilliseconds?.toDouble() ?? 0.0,
                      onChanged: (double value) {
                        play(widget.musicFiles[playlist.currTrack]);
                        playerState = PlayerState.playing;
                        audioPlayer.seek((value / 1000).roundToDouble());
                      },
                      min: 0.0,
                      max: duration.inMilliseconds.toDouble()),
                ],
              ),
      );
    } else {
      return Container();
    }
  }

  getIcon() {
    if (playerState == PlayerState.playing) {
      return InkWell(
            child: Icon(Icons.pause, size: 30.0,),
            onTap: () {
              pause();
              setState(() {
                playerState = PlayerState.paused;
              });

            }
        );
    } else if (playerState == PlayerState.paused) {
      return InkWell(
            child: Icon(Icons.play_arrow, size: 30.0,),
            onTap: () {
              play(widget.musicFiles[playlist.currTrack]);
              setState(() {
                playerState = PlayerState.playing;
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
                                playlist.fileList = widget.musicFiles;
                                playlist.currTrack = index;
                                playlist.metaData = widget.metadata;
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

  PlayingPage({Key key, @required String this.filePath, this.image, this.fileMetaData}) : super(key: key);

  PlayingPageState createState() => PlayingPageState();
}

class PlayingPageState extends State<PlayingPage> {
  var missingImg = AssetImage("assets/noimage.png");
  @override
  void initState() {
    super.initState();
    duration = new Duration(seconds: 0);
    position = new Duration(seconds: 0);
    print("playerstate is ${playerState.toString()}");
    stop();
    play(widget.filePath);
    playerState = PlayerState.playing;
    print("on playing page, playerstate is ${playerState.toString()}");
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
                      musicFiles: playlist.fileList,
                      metadata: playlist.metaData,
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
                      if (playlist.currTrack != 0) {
                        playlist.currTrack--;
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => PlayingPage(
                                filePath: playlist.fileList[playlist.currTrack],
                                image: playlist.metaData[playlist.currTrack][2],
                                fileMetaData: playlist.metaData[playlist.currTrack][0] != null
                                  ? playlist.metaData[playlist.currTrack] : [playlist.fileList[playlist.currTrack], "unknown"],
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
                        audioPlayer.seek(0.0);
                        play(widget.filePath);
                        playerState = PlayerState.playing;
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
                      if (playlist.currTrack != playlist.fileList.length-1) {
                        playlist.currTrack++;
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => PlayingPage(
                              filePath: playlist.fileList[playlist.currTrack],
                              image: playlist.metaData[playlist.currTrack][2],
                              fileMetaData: playlist.metaData[playlist.currTrack][0] != null
                                  ? playlist.metaData[playlist.currTrack] : [playlist.fileList[playlist.currTrack], "unknown"],
                            )
                        )
                        );
                      }
                    },
                  ),
                ),
            ],
            ),
            duration == null
                ? Container()
                : Slider(
                value: position?.inMilliseconds?.toDouble() ?? 0.0,
                onChanged: (double value) {
                  play(widget.filePath);
                  playerState = PlayerState.playing;
                  audioPlayer.seek((value / 1000).roundToDouble());
                },
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