import 'package:flutter/material.dart';
import 'musicplayer.dart' as musicplayer;
import 'playingpage.dart';

class ArtistPage extends StatefulWidget {
  ArtistPageState createState() => ArtistPageState();
}

class ArtistPageState extends State<ArtistPage> {
  Map<String, List> artists = Map();

  List artistsNames;

  @override
  void initState() {
    for (var track in musicplayer.allMetaData) {
      if (artists.containsKey(track[1]) == false) {
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
      appBar: AppBar(
        title: Text("Artists"),
      ),
      drawer: musicplayer.AppDrawer(),
      body: ListView.builder(
          itemCount: artists.length,
          itemBuilder: (BuildContext context, int index) => ListTile(
            title: Text(artistsNames[index]),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => ShowArtistAlbums(
                    artistName: artistsNames[index],
                  )));
            },
          )),
    );
  }
}

class ShowArtistAlbums extends StatefulWidget {
  String artistName;

  ShowArtistAlbums({Key key, @required this.artistName}) : super(key: key);

  ShowArtistAlbumsState createState() => ShowArtistAlbumsState();
}

class ShowArtistAlbumsState extends State<ShowArtistAlbums> {
  Map<String, List> albums = Map();

  List albumsNames;

  @override
  void initState() {
    super.initState();
    for (var track in musicplayer.allMetaData) {
      if (track[1] == widget.artistName) {
        if (albums.containsKey(track[3]) == false) {
          albums[track[3]] = [[track[0], track[4]]];
        } else {
          var l = albums[track[3]];
          l.add([track[0], track[4]]);
          albums.update(track[3], (value) => l);
        }
      }
    }
    albumsNames = albums.keys.toList();
    print("ALBUMS ARE " + albumsNames.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.artistName),
      ),
      body: ListView.builder(
        itemCount: albumsNames.length,
        itemBuilder: (BuildContext context, int index) => ListTile(
          title: albumsNames[index] != null ? Text(albumsNames[index]) : Text("Unknown Album"),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => ShowAlbum(
                  tracks: albums[albumsNames[index]],
                  albumName: albumsNames[index]
                )));
          },
      )
      ),
    );
  }
}

class ShowAlbum extends StatefulWidget {
  List<dynamic> tracks;
  String albumName;
  ShowAlbum({Key key, @required this.tracks, @required this.albumName}) : super(key: key);

  ShowAlbumState createState() => ShowAlbumState();
}

class ShowAlbumState extends State<ShowAlbum> {
  List albumMetaData = [];
  List albumFilePaths = [];
  Map trackNumbers = Map();

  List sortedAlbumMetaData  = [];
  List sortedAlbumFilePaths = [];

  @override
  void initState() {
    super.initState();
    for (var track in widget.tracks) {
      int i;
      String path;
      for (var x in musicplayer.allMetaData) {
        if (x[0] == track[0]) {
          i = musicplayer.allMetaData.indexOf(x);
          path = musicplayer.allFilePaths[i];
          albumFilePaths.add(path);
          albumMetaData.add([
            musicplayer.allMetaData[i][0],
            musicplayer.allMetaData[i][1],
            musicplayer.allMetaData[i][2]
          ]);
        }
      }
    }

    print(widget.tracks);

    int count = 0;
    for (var track in widget.tracks) {
      print("track is " + track.toString());
      if (trackNumbers[int.parse(track[1])] == null) {
        trackNumbers[int.parse(track[1])] = count;
      } else {
        trackNumbers[count+1] = count;
      }
      count += 1;
    }

    print(trackNumbers);

    var l = trackNumbers.keys.toList();
    l.sort();
    for (var num in l) {
      sortedAlbumMetaData.add(albumMetaData[trackNumbers[num]]);
      sortedAlbumFilePaths.add(albumFilePaths[trackNumbers[num]]);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.albumName != null ? Text(widget.albumName) : Text("Unknown Album"),
      ),
      body: ListView.builder(
          itemCount: widget.tracks.length,
          itemBuilder: (BuildContext context, int index) => ListTile(
            leading: musicplayer.getImage(sortedAlbumMetaData[index][2], context),
            title: Text(sortedAlbumMetaData[index][0].toString()),
            subtitle: Text(sortedAlbumMetaData[index][1].toString()),
            onTap: () {
              musicplayer.queueFileList = sortedAlbumFilePaths;
              musicplayer.queueMetaData = sortedAlbumMetaData;
              musicplayer.currTrack = index;
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => PlayingPage(
                      filePath: sortedAlbumFilePaths[index],
                      fileMetaData: sortedAlbumMetaData[index],
                      backPage: "artistPage")));
            },
          )
      ),
    );
  }
}