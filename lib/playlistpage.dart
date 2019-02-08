import 'package:flutter/material.dart';
import 'audioplayer.dart' as audioplayer;
import 'library.dart';
import 'home.dart';
import 'favourites.dart';
import 'playingpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

String img = "images/noimage.png";

class PlaylistPage extends StatefulWidget {
  PlaylistPageState createState() => PlaylistPageState();
}

class PlaylistPageState extends State<PlaylistPage> {
  String _name;
  final TextEditingController controller = TextEditingController();

  void savePlaylistNames(String name, playlistNames) async {
    playlistNames.add(name);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("playlistNames", playlistNames);
  }

  void createPlaylist() {
    AlertDialog dialog  = AlertDialog(
      title: Text("test"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
        TextField(
          decoration: InputDecoration(
              labelText: 'Playlist name'
          ),
          onChanged: (input) {
            setState(() {
              _name = input;
            });
          },
          controller: controller,
        ),
        FlatButton(
          child: Text("Create playlist"),
          onPressed: () {
            setState(() {
              controller.text = "";
            });
            audioplayer.savePlaylist(_name, [], null); // saves playlist to shared preferences
            if (audioplayer.playlistNames != null) {
              savePlaylistNames(_name, audioplayer.playlistNames);
            } else {
              List<String> lst = [];
              savePlaylistNames(_name, lst);
            }
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ShowPlaylist(
              name: _name,
              tracklist: [],
            )
            ));
          },
        )
      ],)
    );
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  Future<List> loadData() async {
    List playlistTracks = [];
    if (audioplayer.playlistNames != null) {
      for (String name in audioplayer.playlistNames) { // we get tracks from all playlists from shared preferences
        audioplayer.getPlayList(name).then((l) {
          // print("l is " + l.toString());
          playlistTracks.add(l);
        });
      }
    }
    return playlistTracks;
  }

  @override
  void initState() {
    super.initState();
    // print("playlist names are " + audioplayer.playlistNames.toString());
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Center(child: Text("+", style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.w300),),),
          onPressed: () {
            createPlaylist();
          },
        ),
        appBar: AppBar(title: Text("Playlists"),),
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
        ),
        body: FutureBuilder(
            future: loadData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(
                  child: Text("Loading..."),
                );
              } else {
                return Column(
                  children: <Widget>[
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) => ListTile(
                            title: Text(audioplayer.playlistNames[index]),
                            trailing: Text(
                              snapshot.data[index].length.toString() + " Tracks"
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ShowPlaylist(
                                name: audioplayer.playlistNames[index],
                                tracklist: snapshot.data[index],
                              )
                              ));
                            }
                        )
                    )
                  ],
                );
              }
            }
        )
      );
    }
}

class ShowPlaylist extends StatefulWidget {
  String name;
  List tracklist;

  ShowPlaylist({Key key, this.name, this.tracklist}) : super(key: key);

  ShowPlaylistState createState() => ShowPlaylistState();
}

class ShowPlaylistState extends State<ShowPlaylist> {
  List playlistMetaData = [];
  List playlistFilePaths = [];

  getImage(i) {
    if (playlistMetaData[i][2] != "") {
      return Image.memory(playlistMetaData[i][2], width: MediaQuery.of(context).size.width/7,);
    } else {
      return Image.asset(img, width: MediaQuery.of(context).size.width/7);
    }
  }

  @override
  void initState() {
    super.initState();
    for (var track in widget.tracklist) {
      int i;
      String path;
      for (var x in audioplayer.allMetaData) {
        if (x[0] == track) {
          i = audioplayer.allMetaData.indexOf(x);
          path = audioplayer.allFilePaths[i];
          playlistFilePaths.add(path);
          playlistMetaData.add([audioplayer.allMetaData[i][0], audioplayer.allMetaData[i][1], audioplayer.allMetaData[i][2]]);
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: widget.name != null ? Text(widget.name) : Text("aaa"),),
      body: widget.tracklist.length == 0 ?
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("This playlist is currently empty. Start adding some tracks!"),
          RaisedButton(
              child: Text("Add Tracks"),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => TrackSelection(
                      name: widget.name,
                    )
                ));
              }
          )
        ],
      ) :
      ListView.builder(
          itemCount: playlistMetaData.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: getImage(index),
              title: Text(playlistMetaData[index][0]),
              subtitle: Text(playlistMetaData[index][1]),
              trailing: Text((index+1).toString()),
              onTap: () {
                // TRACK GETS PLAYED, PLAYLIST FILEPATHS AND METADATA GET ADDED TO PLAYQUEUE
                // YOU NEED PLAYLIST METADATA
                print("FILEPATHS ARE " + playlistFilePaths.toString());
                audioplayer.fileList = playlistFilePaths;
                audioplayer.metaData = playlistMetaData;
                audioplayer.currTrack = index;
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (BuildContext context) => PlayingPage(
                          filePath: playlistFilePaths[index],
                          image: playlistMetaData[index][2],
                          fileMetaData: playlistMetaData[index][0] != null ?
                          playlistMetaData[index] :
                          [playlistMetaData[index][0], "unknown"],
                          backPage: "playlistPage"
                      )
                  )
                );
              },
            );
          }
      )
    );
  }
}

class TrackSelection extends StatefulWidget {
  String name;

  TrackSelection({Key key, this.name}) : super(key: key);

  TrackSelectionState createState() => TrackSelectionState();
}

class TrackSelectionState extends State<TrackSelection> {
  List<String> checkedTracks = [];

  getImage(i) {
    if (audioplayer.allMetaData[i][2] != "") {
      return Image.memory(audioplayer.allMetaData[i][2], width: MediaQuery.of(context).size.width/7,);
    } else {
      return Image.asset(img, width: MediaQuery.of(context).size.width/7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add tracks to playlist"),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: InkWell(
              child: Icon(Icons.check),
              onTap: () {
                audioplayer.savePlaylist(widget.name, [], checkedTracks);
              },
            ),
          )
        ],
      ),
      body: ListView.builder(
          shrinkWrap: true,
          itemCount: audioplayer.allFilePaths.length,
          itemBuilder: (BuildContext context, int index) => ListTile(
            leading: getImage(index),
            title: Text(audioplayer.allMetaData[index][0]),
            subtitle: Text(audioplayer.allMetaData[index][1]),
            trailing:
              checkedTracks.contains(audioplayer.allMetaData[index][0]) == true ? Icon(Icons.check_box)
                  : Icon(Icons.check_box_outline_blank),
            onTap: () {
              setState(() {
                if (checkedTracks.contains(audioplayer.allMetaData[index][0]) == true) {
                  checkedTracks.remove(audioplayer.allMetaData[index][0]);
                } else {
                  checkedTracks.add(audioplayer.allMetaData[index][0]);
                }
              });
            },
            )
            ),
          );
  }
}

/*
Column(
          children: <Widget>[
            ListView.builder(
                shrinkWrap: true,
                itemCount: playlistTracks.length,
                itemBuilder: (BuildContext context, int index) => ListTile(
                    title: Text(audioplayer.playlistNames[index]),
                    trailing: Text(
                        playlistTracks[index].length.toString() + " Tracks"
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ShowPlaylist(
                        name: audioplayer.playlistNames[index],
                        tracklist: playlistTracks[index],
                      )
                      ));
                    }
                )
            )
          ],
        ),
 */