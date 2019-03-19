import 'package:flutter/material.dart';
import 'musicplayer.dart' as musicplayer;
import 'playingpage.dart';

String img = "images/noimage.png";

class FavouritesPage extends StatefulWidget {
  @override
  FavouritesPageState createState() => FavouritesPageState();
}

class FavouritesPageState extends State<FavouritesPage>{
  List favListMetaData = [];
  @override
  void initState() {
    super.initState();
    if (musicplayer.favList != null) {
      print("favlist is " + musicplayer.favList.toString());
      for (var track in musicplayer.favList) {
        favListMetaData.add(musicplayer.allMetaData[musicplayer.allFilePaths.indexOf(track)]);
      }
    } else {

    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: musicplayer.AppDrawer(),
      appBar: AppBar(
        title: Text("Favourites"),
        ),
      body: musicplayer.favList != null ?
      ListView.builder(
      itemCount: musicplayer.favList.length,
      itemBuilder: (BuildContext context, int index) {
        var track_metadata = favListMetaData[index];
        return ListTile(
          leading: musicplayer.getImage(track_metadata[2], context),
          title: Text(track_metadata[0]),
          subtitle: Text(track_metadata[1]),
          onTap: () {
            musicplayer.queueFileList = musicplayer.favList;
            musicplayer.queueMetaData = favListMetaData;
            musicplayer.currTrack = index;
            Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (BuildContext context) => new PlayingPage(
                      filePath: musicplayer.favList[index],
                      fileMetaData: track_metadata[0] != null ?
                      track_metadata :
                      [musicplayer.favList[index], "unknown"] ,
                      backPage: "favouritesPage",
                    )
                )
            );
          },
        );
      },
    ) : Center(child: Text("You haven't favourited any tracks yet."),)
    );
  }
}