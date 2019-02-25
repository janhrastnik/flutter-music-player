import 'package:flutter/material.dart';
import 'dart:async';
import 'audioplayer.dart' as audioplayer;
import 'package:shared_preferences/shared_preferences.dart';
import 'library.dart';
import 'favourites.dart';
import 'home.dart';
import 'package:audioplayer/audioplayer.dart';
import 'playlistpage.dart';
import 'package:random_color/random_color.dart';

class PlayingPage extends StatefulWidget {
  var filePath;
  var fileMetaData;
  var backPage;

  PlayingPage({Key key, @required this.filePath, this.fileMetaData, @required this.backPage}) : super(key: key);

  PlayingPageState createState() => PlayingPageState();
}

class PlayingPageState extends State<PlayingPage> {
  String img = "images/noimage.png";
  Color pageColor = audioplayer.randomColor.randomColor(colorBrightness: ColorBrightness.custom(Range(80, 83)));
  bool isFavorited;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  var missingImg = AssetImage("images/noimage.png");
  final key = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    initAudioPlayer();
    super.initState();
    if (audioplayer.currTrackName != widget.filePath) {
      audioplayer.duration = new Duration(seconds: 0);
      audioplayer.position = new Duration(seconds: 0);
      audioplayer.stop();
      audioplayer.play(widget.filePath);
    } else {
      audioplayer.play(widget.filePath);
    }
    audioplayer.playerState = audioplayer.PlayerState.playing;
    audioplayer.getFavTrackList().then((l) {
      if (audioplayer.favList != null) {
        if (audioplayer.favList.contains(widget.filePath) == true) {
          isFavorited = true;
        } else {
          isFavorited = false;
        }
      } else {
        isFavorited = false;
      }
    });
    audioplayer.getFavTrackList().then((l) {
      audioplayer.favList = l;
    });
    audioplayer.currTrackName = widget.filePath;
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

  get isPlaying => audioplayer.playerState == audioplayer.PlayerState.playing;
  get isPaused => audioplayer.playerState == audioplayer.PlayerState.paused;
  get durationText =>
      audioplayer.duration != null ? audioplayer.duration.toString().split('.').first : '';
  get positionText =>
      audioplayer.position != null ? audioplayer.position.toString().split('.').first : '';

  void saveFavTrack(String track, List trackList) async {
    print("TRACKLISSSSSSSSSSSST: " + trackList.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (track != "") {
      try {
        trackList.add(track);
      } catch(e) {
        print("YOYOYOYOOYOYO");
        prefs.setStringList("favTracks", [track]);
        return null;
      }
    }
    prefs.setStringList("favTracks", trackList);
  }

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
      return Image.memory(widget.fileMetaData[2]);
    } catch(e) {
      return Image(image: missingImg,);
    }
  }

  void addToPlaylist() {
    List playlistTracks;
    audioplayer.loadPlaylistData().then((data) {
      playlistTracks = data;
      AlertDialog dialog  = AlertDialog(
          title: Text("Add track to playlist"),
          content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                      child: audioplayer.playlistNames != null ?
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: audioplayer.playlistNames.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              child: ListTile(
                                title: Text(audioplayer.playlistNames[index]),
                                onTap: () {
                                  audioplayer.savePlaylist(audioplayer.playlistNames[index], playlistTracks[index], [widget.fileMetaData[0]]);
                                  Navigator.pop(context);
                                  key.currentState.showSnackBar(SnackBar(content: Text("Track has been added to playlist")));
                                },
                              ),
                            );
                          }
                      ) : Text("You haven't created any playlists yet."),
                  )
                ],
              )
      );
      showDialog(context: context, builder: (BuildContext context) => dialog);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        drawer: audioplayer.AppDrawer(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: InkWell(
            child: Icon(Icons.arrow_back),
            onTap: () {
              if (widget.backPage == "libraryPage") {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        Library(
                          musicFiles: audioplayer.allFilePaths,
                          metadata: audioplayer.allMetaData,
                        )
                ));
              } else if (widget.backPage == "favouritesPage") {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        FavouritesPage()
                ));
              } else if (widget.backPage == "playlistPage") {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        PlaylistPage()
                ));
              } else {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        HomePage()
                ));
              }
            },
          ),
          actions: <Widget>[
            InkWell(
              customBorder: CircleBorder(),
              child: Container(
                width: 50.0,
                child: Icon(Icons.library_add),
              ),
              onTap: () {
                addToPlaylist();
              },
            ),
            InkWell(
              customBorder: CircleBorder(),
              child: Container(
                width: 50.0,
                child: isFavorited == true ? Icon(Icons.favorite, size: 32.0)
                    : Icon(Icons.favorite_border, size: 32.0,),

              ),
              onTap: () {
                if (isFavorited == true) {
                  setState(() {
                    audioplayer.favList.remove(widget.filePath);
                    saveFavTrack("", audioplayer.favList);
                    isFavorited = false;
                  });
                } else {
                  setState(() {
                    saveFavTrack(widget.filePath, audioplayer.favList);
                    isFavorited = true;
                  });
                }
              },
            )
          ],
          toolbarOpacity: 1.0,
          backgroundColor: Colors.white,
          elevation: 0.0,
          iconTheme: IconThemeData(
              color: Colors.black54
          ),
        ),
        body: Material(
          shadowColor: Colors.black54,
          elevation: 20.0,
          color: pageColor,
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                  child: getImage(),
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width/6,
                    right: MediaQuery.of(context).size.width/6,
                  )
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width/6,),
                child: null,
              ),
              Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
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
                                      filePath: audioplayer.queueFileList[audioplayer.currTrack],
                                      fileMetaData: audioplayer.queueMetaData[audioplayer.currTrack][0] != null
                                          ? audioplayer.queueMetaData[audioplayer.currTrack] : [audioplayer.queueFileList[audioplayer.currTrack], "unknown"],
                                      backPage: widget.backPage,
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
                              if (audioplayer.currTrack != audioplayer.queueFileList.length-1) {
                                audioplayer.currTrack++;
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) => PlayingPage(
                                      filePath: audioplayer.queueFileList[audioplayer.currTrack],
                                      fileMetaData: audioplayer.queueMetaData[audioplayer.currTrack][0] != null
                                          ? audioplayer.queueMetaData[audioplayer.currTrack] : [audioplayer.queueFileList[audioplayer.currTrack], "unknown"],
                                      backPage: widget.backPage,
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
                ),
            ],
          ),
        )
    );
  }
}