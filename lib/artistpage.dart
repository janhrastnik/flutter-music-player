import 'package:flutter/material.dart';
import 'audioplayer.dart' as audioplayer;

class ArtistPage extends StatefulWidget {
  ArtistPageState createState() => ArtistPageState();
}

class ArtistPageState extends State<ArtistPage> {
  Map<String, List> artists = Map();

  List artistsNames;

  @override
  void initState() {
    for (var track in audioplayer.allMetaData) {
      if (artists.containsKey(track[1]) == false) {
        print("eyyyyy");
        artists[track[1]] = [track[0]];
      } else {
        var l = artists[track[1]];
        l.add(track[0]);
        artists.update(track[1], (value) => l);
      }
    }
    artistsNames = artists.keys.toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: artists.length,
          itemBuilder: (BuildContext context, int index) => ListTile(
            title: Text(artistsNames[index]),
          )),
    );
  }
}
