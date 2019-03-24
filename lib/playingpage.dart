import 'package:flutter/material.dart';
import 'dart:async';
import 'musicplayer.dart' as musicplayer;
import 'package:shared_preferences/shared_preferences.dart';
import 'library.dart';
import 'favourites.dart';
import 'home.dart';
import 'package:audioplayer/audioplayer.dart';
import 'playlistpage.dart';
import 'package:random_color/random_color.dart';
import 'artistpage.dart';

class PlayingPage extends StatefulWidget {
  var filePath;
  var fileMetaData;
  var backPage;

  PlayingPage({Key key, @required this.filePath, this.fileMetaData, @required this.backPage}) : super(key: key);

  PlayingPageState createState() => PlayingPageState();
}

class PlayingPageState extends State<PlayingPage> {
  Color pageColor = musicplayer.randomColor.randomColor(colorBrightness: ColorBrightness.custom(Range(80, 83)));
  bool isFavorited;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  var missingImg = AssetImage("images/noimage.png");
  final key = GlobalKey<ScaffoldState>();
  var img;

  @override
  void initState() {
    initAudioPlayer();
    super.initState();
    if (musicplayer.currTrackName != widget.filePath) {
      musicplayer.duration = new Duration(seconds: 0);
      musicplayer.position = new Duration(seconds: 0);
      musicplayer.stop();
      musicplayer.play(widget.filePath);
    } else {
      musicplayer.play(widget.filePath);
    }
    musicplayer.playerState = musicplayer.PlayerState.playing;
    musicplayer.getFavTrackList().then((l) {
      if (musicplayer.favList != null) {
        if (musicplayer.favList.contains(widget.filePath) == true) {
          isFavorited = true;
        } else {
          isFavorited = false;
        }
      } else {
        isFavorited = false;
      }
    });
    musicplayer.getFavTrackList().then((l) {
      musicplayer.favList = l;
    });
    musicplayer.currTrackName = widget.filePath;
    if (widget.fileMetaData[2] != null) {
      var imageData = musicplayer.appPath + "/" + widget.fileMetaData[2];
      img = Image.asset(imageData, width: 300.0);
    } else {
      img = Image(image: missingImg,);
    }
    musicplayer.onPlayingPage = true;
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    musicplayer.stop();
    super.dispose();
  }

  void initAudioPlayer() {
    musicplayer.audioPlayer = new AudioPlayer();
    _positionSubscription = musicplayer.audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => musicplayer.position = p));
    _audioPlayerStateSubscription =
        musicplayer.audioPlayer.onPlayerStateChanged.listen((s) {
          musicplayer.hideAppBarAgain();
          if (s == AudioPlayerState.PLAYING) {
            setState(() =>
            musicplayer.duration = musicplayer.audioPlayer.duration);
          } else if (s == AudioPlayerState.COMPLETED) {
            print("aiiight");
            if (musicplayer.onPlayingPage == true) {
              if (musicplayer.currTrack != musicplayer.queueFileList.length - 1) {
                musicplayer.currTrack++;
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        PlayingPage(
                          filePath: musicplayer.queueFileList[musicplayer
                              .currTrack],
                          fileMetaData: musicplayer.queueMetaData[musicplayer
                              .currTrack][0] != null
                              ? musicplayer.queueMetaData[musicplayer.currTrack]
                              : [
                            musicplayer.queueFileList[musicplayer.currTrack],
                            "unknown"
                          ],
                          backPage: widget.backPage,
                        )
                )
                );
              }
            } else {
              if (musicplayer.currTrack != musicplayer.queueFileList.length - 1) {
                musicplayer.currTrack++;
                musicplayer.duration = new Duration(seconds: 0);
                musicplayer.position = new Duration(seconds: 0);
                musicplayer.play(musicplayer.queueFileList[musicplayer.currTrack]);
              }
            }
          }
        }, onError: (msg) {
          setState(() {
            // musicplayer.playerState = PlayerState.stopped;
            musicplayer.duration = new Duration(seconds: 0);
            musicplayer.position = new Duration(seconds: 0);
          });
        });
  }

  get isPlaying => musicplayer.playerState == musicplayer.PlayerState.playing;
  get isPaused => musicplayer.playerState == musicplayer.PlayerState.paused;
  get durationText {
    var minutes = musicplayer.duration.inMinutes.toString();
    var seconds = (musicplayer.duration.inSeconds % 60).toString();
    if (seconds.length == 1) {
      seconds = "0" + seconds;
    }
    return minutes + ":" + seconds;
  }
  get positionText {
    var minutes = musicplayer.position.inMinutes.toString();
    var seconds = (musicplayer.position.inSeconds % 60).toString();
    if (seconds.length == 1) {
      seconds = "0" + seconds;
    }
    return minutes + ":" + seconds;
  }
  void saveFavTrack(String track, List trackList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (track != "") {
      try {
        trackList.add(track);
      } catch(e) {
        prefs.setStringList("favTracks", [track]);
        return null;
      }
    }
    prefs.setStringList("favTracks", trackList);
  }

  getIcon() {
    if (isPlaying == true || musicplayer.playerState == musicplayer.PlayerState.stopped) {
      return IconButton(
          icon: Icon(Icons.pause),
          iconSize: 50.0,
          tooltip: "Pause Track",
          onPressed: () {
            musicplayer.pause();
            setState(() {
              musicplayer.playerState = musicplayer.PlayerState.paused;
            });

          }
      );
    } else if (isPlaying == false) {
      return IconButton(
          icon: Icon(Icons.play_arrow),
          iconSize: 50.0,
          tooltip: "Play Track",
          onPressed: () {
            musicplayer.play(widget.filePath);
            setState(() {
              musicplayer.playerState = musicplayer.PlayerState.playing;
            });

          }
      );
    }
  }

  void addToPlaylist() {
    List playlistTracks;
    musicplayer.loadPlaylistData().then((data) {
      playlistTracks = data;
      AlertDialog dialog  = AlertDialog(
          title: Text("Add track to playlist"),
          content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  musicplayer.playlistNames != null ?
                      Expanded(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: musicplayer.playlistNames.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  child: ListTile(
                                    title: Text(musicplayer.playlistNames[index]),
                                    trailing: Text("${playlistTracks[index].length} Tracks"),
                                    onTap: () {
                                      musicplayer.savePlaylist(musicplayer.playlistNames[index], playlistTracks[index], [widget.fileMetaData[0]]);
                                      Navigator.pop(context);
                                      key.currentState.showSnackBar(SnackBar(content: Text("Track has been added to playlist")));
                                    },
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.black54))
                                  )
                                );
                              }
                          )
                      ) : Text("You haven't created any playlists yet."),
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
        drawer: musicplayer.AppDrawer(),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (widget.backPage == "libraryPage") {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        Library(
                          musicFiles: musicplayer.allFilePaths,
                          metadata: musicplayer.allMetaData,
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
              } else if (widget.backPage == "artistPage") {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ArtistPage()
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
            IconButton(
              icon: Icon(Icons.library_add),
              onPressed: () {
                addToPlaylist();
              },
            ),
            IconButton(
              icon: isFavorited == true ? Icon(Icons.favorite, size: 32.0)
                  : Icon(Icons.favorite_border, size: 32.0,),
                onPressed: () {
                  if (isFavorited == true) {
                    setState(() {
                      musicplayer.favList.remove(widget.filePath);
                      saveFavTrack("", musicplayer.favList);
                      isFavorited = false;
                    });
                  } else {
                    setState(() {
                      saveFavTrack(widget.filePath, musicplayer.favList);
                      isFavorited = true;
                    });
                  }
                }
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
          color: pageColor,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Column( // IMAGE PORTION OF PLAYINGPAGE
                children: <Widget>[
                  Container(
                      color: Colors.white,
                      child: img,
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
                ],
              ),
              Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Tooltip(
                        message: widget.fileMetaData[0],
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width/20,
                            right: MediaQuery.of(context).size.width/20
                          ),
                          child: Text(
                            widget.fileMetaData[0],
                            style: TextStyle(fontSize: 24.0),
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ),
                      Text(
                        widget.fileMetaData[1],
                        style: TextStyle(fontSize: 18.0, color: Colors.black54),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                      ),
                      Row( // BUTTONS
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.skip_previous, color: Colors.blueGrey,),
                            iconSize: 30.0,
                            tooltip: "Previous Track",
                            onPressed: () {
                              if (musicplayer.currTrack != 0) {
                                musicplayer.currTrack--;
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) => PlayingPage(
                                      filePath: musicplayer.queueFileList[musicplayer.currTrack],
                                      fileMetaData: musicplayer.queueMetaData[musicplayer.currTrack][0] != null
                                          ? musicplayer.queueMetaData[musicplayer.currTrack] : [musicplayer.queueFileList[musicplayer.currTrack], "unknown"],
                                      backPage: widget.backPage,
                                    )
                                )
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.history),
                            iconSize: 50.0,
                            tooltip: "Replay Track",
                            onPressed: () {
                              setState(() {
                                musicplayer.audioPlayer.seek(0.0);
                                musicplayer.play(widget.filePath);
                                musicplayer.playerState = musicplayer.PlayerState.playing;
                              });
                            },
                          ),
                          getIcon(), // PLAY BUTTON / PAUSE BUTTON
                          IconButton(
                            icon: Icon(Icons.skip_next, color: Colors.blueGrey,),
                            iconSize: 30.0,
                            tooltip: "Next Track",
                            onPressed: () {
                              if (musicplayer.currTrack != musicplayer.queueFileList.length-1) {
                                musicplayer.currTrack++;
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) => PlayingPage(
                                      filePath: musicplayer.queueFileList[musicplayer.currTrack],
                                      fileMetaData: musicplayer.queueMetaData[musicplayer.currTrack][0] != null
                                          ? musicplayer.queueMetaData[musicplayer.currTrack] : [musicplayer.queueFileList[musicplayer.currTrack], "unknown"],
                                      backPage: widget.backPage,
                                    )
                                )
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          musicplayer.duration == null
                              ? Container()
                              : Slider(
                              value: musicplayer.position?.inMilliseconds?.toDouble() ?? 0.0,
                              onChanged: (double value) {
                                musicplayer.play(widget.filePath);
                                musicplayer.playerState = musicplayer.PlayerState.playing;
                                musicplayer.audioPlayer.seek((value / 1000).roundToDouble());
                              },
                              min: 0.0,
                              max: musicplayer.duration.inMilliseconds.toDouble()),
                          Wrap(
                            direction: Axis.horizontal,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(left: 14.0),
                                    child: Text(positionText, style: TextStyle(fontSize: 24.0)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 14.0),
                                    child: Text(durationText, style: TextStyle(fontSize: 24.0)),
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
              ),
            ],
          ),
        )
    );
  }
}