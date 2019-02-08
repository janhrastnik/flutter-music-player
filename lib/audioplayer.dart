library musicplayer2.audioplayer;
import 'package:audioplayer/audioplayer.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
List<String> playlistNames = [];

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