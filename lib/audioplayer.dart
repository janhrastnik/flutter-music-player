library musicplayer2.audioplayer;
import 'package:audioplayer/audioplayer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'playlistpage.dart';
import 'favourites.dart';
import 'library.dart';

// for playlists
List fileList;
int currTrack;
List metaData;
// data of all tracks on device
List allMetaData;
List allFilePaths;

// for favourites
List<String> favList = [];

// all playlist names
List<String> playlistNames;

enum PlayerState { stopped, playing, paused }
AudioPlayer audioPlayer;
PlayerState playerState;
Duration duration;
Duration position;

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
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => PlaylistPage(
                  )
              )
              );
            },
          ),
        ],
      ),
    );
  }
}