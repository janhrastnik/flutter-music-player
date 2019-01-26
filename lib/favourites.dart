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
    for (var track in audioplayer.favList) {
      favListMetaData.add(audioplayer.allMetaData[audioplayer.allFilePaths.indexOf(track)]);
    }
  }

  getImage(i) {
    if (favListMetaData[i][2] != "") {
      return Image.memory(favListMetaData[i][2], width: MediaQuery.of(context).size.width/7,);
    } else {
      return Image.asset(img, width: MediaQuery.of(context).size.width/7);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
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
                      musicFiles: audioplayer.allFilePaths,
                      metadata: audioplayer.allMetaData,
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
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Favourites"),
        leading: InkWell(
          child: Icon(Icons.arrow_back),
            onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) =>
              HomePage()
            ));}
      )),
      body: ListView.builder(
        itemCount: audioplayer.favList.length,
        itemBuilder: (BuildContext context, int index) {
          var track_metadata = favListMetaData[index];
          return ListTile(
            leading: getImage(index),
            title: Text(track_metadata[0]),
            subtitle: Text(track_metadata[1]),
            onTap: () {
              audioplayer.fileList = audioplayer.favList;
              audioplayer.metaData = favListMetaData;
              audioplayer.currTrack = index;
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (BuildContext context) => new PlayingPage(
                        filePath: audioplayer.favList[index],
                        image: track_metadata[2],
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
      ),
    );
  }
}