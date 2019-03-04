import 'package:flutter/material.dart';
import 'audioplayer.dart' as audioplayer;
import 'playingpage.dart';
import 'home.dart';
import 'library.dart';

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
    if (audioplayer.favList != null) {
      for (var track in audioplayer.favList) {
        favListMetaData.add(audioplayer.allMetaData[audioplayer.allFilePaths.indexOf(track)]);
      }
    } else {

    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: audioplayer.AppDrawer(),
      appBar: AppBar(
        title: Text("Favourites"),
        ),
      body: audioplayer.favList != null ?
      ListView.builder(
      itemCount: audioplayer.favList.length,
      itemBuilder: (BuildContext context, int index) {
        var track_metadata = favListMetaData[index];
        return ListTile(
          leading: audioplayer.getImage(index, track_metadata[2], context),
          title: Text(track_metadata[0]),
          subtitle: Text(track_metadata[1]),
          onTap: () {
            audioplayer.queueFileList = audioplayer.favList;
            audioplayer.queueMetaData = favListMetaData;
            audioplayer.currTrack = index;
            Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (BuildContext context) => new PlayingPage(
                      filePath: audioplayer.favList[index],
                      fileMetaData: track_metadata[0] != null ?
                      track_metadata :
                      [audioplayer.favList[index], "unknown"] ,
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