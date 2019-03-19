library musicplayer2.musicplayer;
import 'package:audioplayer/audioplayer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'playlistpage.dart';
import 'favourites.dart';
import 'library.dart';
import 'package:random_color/random_color.dart';
import 'artistpage.dart';
import 'package:flutter/services.dart';
String img = "images/noimage.png";
// for playlists, play queue
List queueFileList;
int currTrack;
String currTrackName;
List queueMetaData;
// data of all tracks on device
List allMetaData;
List allFilePaths;
// for favourites
List<String> favList = [];

// all playlist names
List<String> playlistNames;

RandomColor randomColor = RandomColor();
String appPath;
bool onPlayingPage = false;

enum PlayerState { stopped, playing, paused }
AudioPlayer audioPlayer;
PlayerState playerState;
Duration duration;
Duration position;

void hideAppBar() {
  SystemChrome.setEnabledSystemUIOverlays([]);
}

Future clearPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}

Future getFavTrackList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> trackList = prefs.getStringList("favTracks");
  return trackList;
}

Future getPlayListNames() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> playListNames = prefs.getStringList("playlistNames");
  return playListNames;
}

Future getPlayList(name) async {
  // print("getting playlist " + name.toString());
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> playList = prefs.getStringList(name);
  // print("playlist contains " + playList.toString());
  return playList;
}

Future<List> loadPlaylistData() async {
  List playlistTracks = [];
  if (playlistNames != null) {
    for (String name in playlistNames) { // we get tracks from all playlists from shared preferences
      getPlayList(name).then((l) {
        // print("l is " + l.toString());
        playlistTracks.add(l);
      });
    }
  }
  return playlistTracks;
}

void savePlaylist(String name, List<String> CurrTrackList, List<String> trackList) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // print("playlist name is " + name.toString());
  if (trackList != null) {
    // print("tracklist is " + trackList.toString());
    for (var track in trackList) {
      CurrTrackList.add(track);
    }
  }
  // print("final tracklist is " + CurrTrackList.toString());
  prefs.setStringList(name, CurrTrackList);
}

Future play(url) async {
  await audioPlayer.play(url, isLocal: true);
}

Future pause() async {
  await audioPlayer.pause();
}

Future stop() async {
  await audioPlayer.stop();
}

getImage(imageHash, context) {
  if (imageHash != null) {
    var imageData = appPath + "/" + imageHash;
    return Image.asset(imageData, width: MediaQuery.of(context).size.width/7,);
  } else {
    return Image.asset(img, width: MediaQuery.of(context).size.width/7);
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          InkWell(
            child: ListTile(
              title: Text("Home"),
            ),
            onTap: () {
              onPlayingPage = false;
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => HomePage()
              )
              );
            },
          ),
          InkWell(
            child: ListTile(
              title: Text("Library"),
            ),
            onTap: () {
              onPlayingPage = false;
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => Library(
                    musicFiles: allFilePaths,
                    metadata: allMetaData,
                  )
              )
              );
            },
          ),
          InkWell(
            child: ListTile(
              title: Text("Favourites"),
            ),
            onTap: () {
              onPlayingPage = false;
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => FavouritesPage()
              )
              );
            },
          ),
          InkWell(
            child: ListTile(
              title: Text("Playlists"),
            ),
            onTap: () {
              onPlayingPage = false;
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => PlaylistPage(
                  )
              )
              );
            },
          ),
          InkWell(
            child: ListTile(
              title: Text("Artists"),
            ),
            onTap: () {
              onPlayingPage = false;
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => ArtistPage(
                  )
              )
              );
            },
          )
        ],
      ),
    );
  }
}