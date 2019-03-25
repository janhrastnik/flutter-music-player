import 'package:flutter/material.dart';
import 'dart:async';
import 'library.dart';
import 'musicplayer.dart' as musicplayer;
import 'package:audioplayer/audioplayer.dart';
import 'favourites.dart';
import 'playingpage.dart';
import 'playlistpage.dart';
import 'artistpage.dart';

class HomePage extends StatefulWidget {
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  ScrollController _scrollController;

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

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    musicplayer.audioPlayer.stop();
    super.dispose();
  }

  scrollQueue() { // scrolls to current track
    try {
      _scrollController.jumpTo(musicplayer.currTrack * 108.0);
    } catch(e) {

    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    initAudioPlayer();
    musicplayer.getFavTrackList().then((l) {
      musicplayer.favList = l;
    });
    musicplayer.getPlayListNames().then((l) {
      musicplayer.playlistNames = l;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollQueue());
    musicplayer.hideAppBarAgain();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: musicplayer.AppDrawer(),
        body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: Column(
                      children: <Widget>[
                        Text("Your queue", style: TextStyle(fontSize: 22.0),),
                        Container(
                          padding: EdgeInsets.only(left: 70.0, right: 70.0),
                          child: Divider(color: Colors.black54,),
                        )
                      ],
                    )
                ),
                Expanded(
                    child: musicplayer.queueMetaData != null ? ListView.builder(// play queue
                      itemCount: musicplayer.queueMetaData.length,
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                            padding: EdgeInsets.only(bottom: 40.0, top: 10.0),
                            child: Card(
                              child: Material(
                                  color: index == musicplayer.currTrack ? Colors.limeAccent : Colors.lightBlueAccent,
                                  child: InkWell(
                                    child: Column(
                                      children: <Widget>[
                                        musicplayer.queueMetaData[index][2] != "" ? Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: musicplayer.getImage(
                                                musicplayer.queueMetaData[index][2],
                                                context
                                            )
                                        )
                                            : Container(),
                                        Container(
                                          padding: EdgeInsets.only(left: 5.0, right: 5.0),
                                          width: 100.0,
                                          child: Center(child: Text(
                                            musicplayer.queueMetaData[index][0],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      musicplayer.currTrack = index;
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) => new PlayingPage(
                                                filePath: musicplayer.queueFileList[index],
                                                fileMetaData: musicplayer.queueMetaData[index][0] != null ?
                                                musicplayer.queueMetaData[index] :
                                                [musicplayer.queueMetaData[index], "unknown"],
                                                backPage: "homePage",
                                              )
                                          )
                                      );
                                    },
                                  )
                              ),
                            )
                        );
                      },
                    ) : Padding(padding: EdgeInsets.all(70.0), child: Text("Your queue is empty", style: TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.grey),),
                    )
                ),
                Container(
                  decoration: BoxDecoration(
                      boxShadow: [BoxShadow(
                          offset: Offset(5.0, 5.0),
                          spreadRadius: 5.0,
                          blurRadius: 15.0,
                          color: Colors.grey
                      )]
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 1.0, bottom: 1.0),
                        child: Material(
                          child: InkWell(
                            child: Center(child: Column(
                              children: <Widget>[
                                Icon(Icons.library_music),
                                Text("Library")
                              ],
                              mainAxisSize: MainAxisSize.min,
                            ),),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => Library(
                                musicFiles: musicplayer.allFilePaths,
                                metadata: musicplayer.allMetaData,
                              ),));
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 1.0, bottom: 1.0),
                        child: Material(
                          child: InkWell(
                            child: Center(child: Column(
                              children: <Widget>[
                                Icon(Icons.favorite_border),
                                Text("Favourites")
                              ],
                              mainAxisSize: MainAxisSize.min,
                            ),),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => FavouritesPage(),));
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 1.0, right: 1.0),
                        child: Material(
                          child: InkWell(
                            child: Center(child: Column(
                              children: <Widget>[
                                Icon(Icons.list),
                                Text("Playlists")
                              ],
                              mainAxisSize: MainAxisSize.min,
                            ),),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => PlaylistPage(
                              ),));
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 1.0, top: 1.0),
                        child: Material(
                          child: InkWell(
                            child: Center(child: Column(
                              children: <Widget>[
                                Icon(Icons.account_circle),
                                Text("Artists")
                              ],
                              mainAxisSize: MainAxisSize.min,
                            ),),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) => ArtistPage()
                              ));
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
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