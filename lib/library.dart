import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'musicplayer.dart' as musicplayer;
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
    // setState(() => musicplayer.playerState = PlayerState.stopped);
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    musicplayer.audioPlayer.stop();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  void initAudioPlayer() {
    musicplayer.audioPlayer = new AudioPlayer();
    _positionSubscription = musicplayer.audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => musicplayer.position = p));
    _audioPlayerStateSubscription =
        musicplayer.audioPlayer.onPlayerStateChanged.listen((s) {
          if (s == AudioPlayerState.PLAYING) {
            setState(() =>
            musicplayer.duration = musicplayer.audioPlayer.duration);
          } else if (s == AudioPlayerState.STOPPED) {
            setState(() {
              musicplayer.position = musicplayer.duration;
            });
          }
        }, onError: (msg) {
          setState(() {
            // musicplayer.playerState = PlayerState.stopped;
            musicplayer.duration = new Duration(seconds: 0);
            musicplayer.position = new Duration(seconds: 0);
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
                                filePath: widget.musicFiles[musicplayer.currTrack],
                                fileMetaData: widget.metadata[musicplayer.currTrack],
                                backPage: "libraryPage",
                              )
                          ));
                        },
                        child: Text("${
                            widget.metadata[musicplayer.currTrack][0] != null
                                ? widget.metadata[musicplayer.currTrack][0]
                                : widget.musicFiles[musicplayer.currTrack]
                        } by ${
                            widget.metadata[musicplayer.currTrack][1] != null
                                ? widget.metadata[musicplayer.currTrack][1]
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
    if (musicplayer.playerState == musicplayer.PlayerState.playing) {
      return InkWell(
            child: Icon(Icons.pause, size: 30.0,),
            onTap: () {
              musicplayer.pause();
              setState(() {
                musicplayer.playerState = musicplayer.PlayerState.paused;
              });

            }
        );
    } else if (musicplayer.playerState == musicplayer.PlayerState.paused) {
      return InkWell(
            child: Icon(Icons.play_arrow, size: 30.0,),
            onTap: () {
              musicplayer.play(widget.musicFiles[musicplayer.currTrack]);
              setState(() {
                musicplayer.playerState = musicplayer.PlayerState.playing;
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
            drawer: musicplayer.AppDrawer(),
            appBar: AppBar(
              title: Text("Library"),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      showSearch(
                          context: context,
                          delegate: TrackSearch(musicplayer.allMetaData)
                      );
                    }
                )
              ],
            ),
            body: Column(
                children: <Widget>[
                  Expanded(
                      child: ListView.builder(
                          itemCount: widget.musicFiles.length,
                          itemBuilder: (BuildContext context, int index) {
                            return new ListTile(
                              leading: musicplayer.getImage(widget.metadata[index][2], context),
                              title: Text(widget.metadata[index][0]),
                              subtitle: Text(widget.metadata[index][1]),
                              onTap: () {
                                musicplayer.queueFileList = widget.musicFiles;
                                musicplayer.currTrack = index;
                                musicplayer.queueMetaData = widget.metadata;
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
        (musicplayer.playerState == musicplayer.PlayerState.playing || musicplayer.playerState == musicplayer.PlayerState.paused)
            ? PlayerInfo() : Container(child: null,)
                ]
            )
        )
    );
  }
}

class TrackSearch extends SearchDelegate {
  final List tracks;

  TrackSearch(this.tracks);

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = tracks.where((track) => track[0].toLowerCase().contains(query.toLowerCase()));
    // TODO: implement buildResults
    return ListView(
        children: results.map<Widget>((track) => ListTile(
          leading: musicplayer.getImage(track[2], context),
          title: Text(track[0]),
          subtitle: Text(track[1]),
          onTap: () {
            musicplayer.queueFileList = [musicplayer.allFilePaths[tracks.indexOf(track)]];
            musicplayer.currTrack = 0;
            musicplayer.queueMetaData = [track];
            Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (BuildContext context) => new PlayingPage(
                      filePath: musicplayer.allFilePaths[tracks.indexOf(track)],
                      fileMetaData: track,
                    )
                )
            );
          },
        ),
        ).toList());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    final results = tracks.where((track) => track[0].toLowerCase().contains(query.toLowerCase()));
    return ListView(
      children: results.map<Widget>((track) => ListTile(
        leading: musicplayer.getImage(track[2], context),
        title: Text(track[0]),
        subtitle: Text(track[1]),
        onTap: () {
          musicplayer.queueFileList = [musicplayer.allFilePaths[tracks.indexOf(track)]];
          musicplayer.currTrack = 0;
          musicplayer.queueMetaData = [track];
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) => new PlayingPage(
                    filePath: musicplayer.allFilePaths[tracks.indexOf(track)],
                    fileMetaData: track,
                  )
              )
          );
        },
    ),
    ).toList());
  }

}