import 'package:flutter/material.dart';
import 'dart:async';
import 'library.dart';
import 'audioplayer.dart' as audioplayer;
import 'package:audioplayer/audioplayer.dart';
import 'favourites.dart';
import 'playingpage.dart';
import 'playlistpage.dart';

class HomePage extends StatefulWidget {
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  ScrollController _scrollController;

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

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioplayer.audioPlayer.stop();
    super.dispose();
  }

  scrollQueue() { // scrolls to current track
    try {
      _scrollController.jumpTo(audioplayer.currTrack * 108.0);
    } catch(e) {

    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    initAudioPlayer();
    audioplayer.getFavTrackList().then((l) {
      audioplayer.favList = l;
    });
    audioplayer.getPlayListNames().then((l) {
      audioplayer.playlistNames = l;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollQueue());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: audioplayer.AppDrawer(),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: RichText(text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                      TextSpan(text: "Your Queue \n", style: TextStyle(fontSize: 22.0, height: 0.4)),
                      TextSpan(text: "_________________", style: TextStyle(fontSize: 22.0, height: 0.4, color: Color.fromRGBO(200, 200, 200, 1.0))),
                  ]), textAlign: TextAlign.center,),
                ),
                Expanded(
                  child: audioplayer.metaData != null ? ListView.builder( // play queue
                    itemCount: audioplayer.metaData.length,
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 40.0, top: 10.0),
                        child: Card(
                          child: Material(
                            color: index == audioplayer.currTrack ? Colors.limeAccent : Colors.lightBlueAccent,
                            child: InkWell(
                              child: Column(
                                children: <Widget>[
                                  audioplayer.metaData[index][2] != "" ? Padding(padding: EdgeInsets.all(8.0), child: Image.memory(audioplayer.metaData[index][2], width: 75.0,))
                                     : Container(),
                                  Container(
                                    padding: EdgeInsets.only(left: 5.0, right: 5.0),
                                    width: 100.0,
                                    child: Center(child: Text(
                                      audioplayer.metaData[index][0],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                  ),
                                ],
                              ),
                              onTap: () {
                                audioplayer.currTrack = index;
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) => new PlayingPage(
                                          filePath: audioplayer.fileList[index],
                                          image: audioplayer.metaData[index][2],
                                          fileMetaData: audioplayer.metaData[index][0] != null ?
                                          audioplayer.metaData[index] :
                                          [audioplayer.metaData[index], "unknown"],
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
                GridView.count(
                  shrinkWrap: true,
                    crossAxisCount: 2,
                    children: <Widget>[
                      Material(
                        color: Colors.deepOrangeAccent,
                        child: InkWell(
                          child: Center(child: Text("Library"),),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => Library(
                              musicFiles: audioplayer.allFilePaths,
                              metadata: audioplayer.allMetaData,
                            ),));
                          },
                        ),
                      ),
                      Material(
                        color: Colors.cyanAccent,
                        child: InkWell(
                          child: Center(child: Text("Favourites"),),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => FavouritesPage(),));
                          },
                        ),
                      ),
                      Material(
                        color: Colors.greenAccent,
                        child: InkWell(
                          child: Center(child: Text("Playlists"),),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => PlaylistPage(
                            ),));
                          },
                        ),
                      ),
                      Container(
                        color: Colors.amberAccent,
                      )
                    ],
                  ),
            ],
                  ),
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

/*
audioplayer.metaData != null ? ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: audioplayer.metaData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text("aaa"),
                    );
                  }
                  ) : Container(child: null,),
 */