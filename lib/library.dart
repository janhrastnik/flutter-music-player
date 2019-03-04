import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'audioplayer.dart' as audioplayer;
import 'playingpage.dart';
import 'package:audioplayer/audioplayer.dart';

String img = "images/noimage.png";

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

  void onComplete() {
    // setState(() => audioplayer.playerState = PlayerState.stopped);
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioplayer.audioPlayer.stop();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print("in library, playerstate is ${audioplayer.playerState.toString()}");
    initAudioPlayer();
  }

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

  PlayerInfo() {
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
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => PlayingPage(
                                filePath: widget.musicFiles[audioplayer.currTrack],
                                fileMetaData: widget.metadata[audioplayer.currTrack],
                                backPage: "libraryPage",
                              )
                          ));
                        },
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
                    ),
                    getIcon()
                  ],
                  ),

                ],
              ),
      );
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
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            drawer: audioplayer.AppDrawer(),
            appBar: AppBar(title: Text("Library")),
            body: Column(
                children: <Widget>[
                  Expanded(
                      child: ListView.builder(
                          itemCount: widget.musicFiles.length,
                          itemBuilder: (BuildContext context, int index) {
                            return new ListTile(
                              leading: audioplayer.getImage(index, widget.metadata[index][2], context),
                              title: Text(widget.metadata[index][0]),
                              subtitle: Text(widget.metadata[index][1]),
                              onTap: () {
                                audioplayer.queueFileList = widget.musicFiles;
                                audioplayer.currTrack = index;
                                audioplayer.queueMetaData = widget.metadata;
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) => new PlayingPage(
                                          filePath: widget.musicFiles[index],
                                          fileMetaData: widget.metadata[index][0] != null ?
                                          widget.metadata[index] :
                                          [widget.musicFiles[index], "unknown"],
                                          backPage: "libraryPage",
                                        )
                                    )
                                );
                              },
                            );
                          }
                      )
                  ),
        (audioplayer.playerState == audioplayer.PlayerState.playing || audioplayer.playerState == audioplayer.PlayerState.paused)
            ? PlayerInfo() : Container(child: null,)
                ]
            )
        )
    );
  }
}