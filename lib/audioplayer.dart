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

Future play(url) async {
  await audioPlayer.play(url, isLocal: true);
}

Future pause() async {
  await audioPlayer.pause();
}

Future stop() async {
  await audioPlayer.stop();
}