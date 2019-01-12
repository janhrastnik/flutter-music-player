library musicplayer2.audioplayer;
import 'package:audioplayer/audioplayer.dart';
List fileList;
int currTrack;
List metaData;
enum PlayerState { stopped, playing, paused }
AudioPlayer audioPlayer;
PlayerState playerState;
Duration duration;
Duration position;

Future play(url) async {
  await audioPlayer.play(url, isLocal: true);
}

Future pause() async {
  await audioPlayer.pause();
}

Future stop() async {
  await audioPlayer.stop();
}