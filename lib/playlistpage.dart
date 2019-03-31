import 'package:flutter/material.dart';
import 'musicplayer.dart' as musicplayer;
import 'playingpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

String img = "images/noimage.png";

class PlaylistPage extends StatefulWidget {
  PlaylistPageState createState() => PlaylistPageState();
}

class PlaylistPageState extends State<PlaylistPage> {
  String _name;
  final TextEditingController controller = TextEditingController();
  int counter = 0;
  int playlistLength = 0;
  final key = GlobalKey<ScaffoldState>();

  void savePlaylistNames(String name, playlistNames) async {
    if (name != null) {
      playlistNames.add(name);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("playlistNames", playlistNames);
  }

  void createPlaylist() {
    _name = null;
    AlertDialog dialog = AlertDialog(
        title: Text("test"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Playlist name'),
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
                if (_name != null) {
                  setState(() {
                    controller.text = "";
                  });
                  musicplayer.savePlaylist(
                      _name, [], null); // saves playlist to shared preferences
                  if (musicplayer.playlistNames != null) {
                    savePlaylistNames(_name, musicplayer.playlistNames);
                  } else {
                    List<String> lst = [];
                    savePlaylistNames(_name, lst);
                  }
                  musicplayer.getPlayListNames().then((l) {
                    musicplayer.playlistNames = l;
                  });
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => ShowPlaylist(
                            name: _name,
                            tracklist: [],
                          )));
                } else {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                  key.currentState.showSnackBar(SnackBar(content: Text("Playlist name can't be empty.")));
                }
              },
            )
          ],
        ));
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  @override
  void initState() {
    super.initState();
    // print("playlist names are " + musicplayer.playlistNames.toString());
    musicplayer.loadPlaylistData();
    print(musicplayer.playlistNames);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
        floatingActionButton: FloatingActionButton(
          child: Center(
            child: Text(
              "+",
              style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.w300),
            ),
          ),
          onPressed: () {
            createPlaylist();
          },
        ),
        appBar: AppBar(
          title: Text("Playlists"),
        ),
        drawer: musicplayer.AppDrawer(),
        body: musicplayer.playlistNames != null ? FutureBuilder(
          future: musicplayer.loadPlaylistData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            try {
              var data = Map();
              List tempData = snapshot.data;
              if (tempData == null) {
                return Container(
                  child: Text("Loading..."),
                );
              } else {
                for (var i in List<int>.generate(
                    tempData.length, (n) => n + 1)) {
                  data[musicplayer.playlistNames[i - 1]] =
                      tempData[i - 1];
                }
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          final playlistName =
                              musicplayer.playlistNames[index];
                          return Dismissible(
                            key: Key(musicplayer.playlistNames[index]),
                            background: Container(
                            padding: EdgeInsets.only(left: 10.0),
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            child: Icon(Icons.delete),
                            ),
                            secondaryBackground: Container(
                            padding: EdgeInsets.only(right: 10.0),
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.delete),
                            ),
                            onDismissed: (direction) {
                              musicplayer.playlistNames.remove(playlistName);
                              savePlaylistNames(null, musicplayer.playlistNames);
                              data.remove(playlistName);
                              print(musicplayer.playlistNames);
                            },
                            child: ListTile(
                              title: Text(playlistName),
                              trailing: Text(data[playlistName].length.toString() +" Tracks"),
                              onTap: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (BuildContext context) =>
                                            ShowPlaylist(
                                              name: playlistName,
                                              tracklist: data[playlistName],
                                            )));
                              }));
                          }),
                    )
                  ],
                );
              }
            } catch (e) {
              return Text("loading...");
            }
          })
        : Center(
            child: Text("You haven't added any playlists yet."),
          ));
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

  @override
  void initState() {
    super.initState();
    for (var track in widget.tracklist) {
      int i;
      String path;
      for (var x in musicplayer.allMetaData) {
        if (x[0] == track) {
          i = musicplayer.allMetaData.indexOf(x);
          path = musicplayer.allFilePaths[i];
          playlistFilePaths.add(path);
          playlistMetaData.add([
            musicplayer.allMetaData[i][0],
            musicplayer.allMetaData[i][1],
            musicplayer.allMetaData[i][2]
          ]);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: widget.name != null ? Text(widget.name) : Text("aaa"),
        ),
        body: widget.tracklist.length == 0
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Center(
                      child: Text(
                          "This playlist is empty. Start adding some tracks!"),
                    ),
                  ),
                  RaisedButton(
                      child: Text("Add Tracks"),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => TrackSelection(
                                  name: widget.name,
                                )));
                      })
                ],
              )
            : ListView.builder(
                itemCount: playlistMetaData.length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                      key: Key(playlistMetaData[index][0]),
                      background: Container(
                        padding: EdgeInsets.only(left: 10.0),
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.delete),
                      ),
                      secondaryBackground: Container(
                        padding: EdgeInsets.only(right: 10.0),
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.delete),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          playlistMetaData.removeAt(index);
                          widget.tracklist.removeAt(index);
                          musicplayer.savePlaylist(
                              widget.name, widget.tracklist, null);
                          Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text("Track removed.")));
                        });
                      },
                      child: ListTile(
                        leading: musicplayer.getImage(playlistMetaData[index][2], context),
                        title: Text(playlistMetaData[index][0]),
                        subtitle: Text(playlistMetaData[index][1]),
                        trailing: Text((index + 1).toString()),
                        onTap: () {
                          // TRACK GETS PLAYED, PLAYLIST FILEPATHS AND METADATA GET ADDED TO PLAYQUEUE
                          musicplayer.queueFileList = playlistFilePaths;
                          musicplayer.queueMetaData = playlistMetaData;
                          musicplayer.currTrack = index;
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => PlayingPage(
                                  filePath: playlistFilePaths[index],
                                  fileMetaData: playlistMetaData[index][0] !=
                                          null
                                      ? playlistMetaData[index]
                                      : [playlistMetaData[index][0], "unknown"],
                                  backPage: "playlistPage")));
                        },
                      ));
                }));
  }
}

class TrackSelection extends StatefulWidget {
  String name;

  TrackSelection({Key key, this.name}) : super(key: key);

  TrackSelectionState createState() => TrackSelectionState();
}

class TrackSelectionState extends State<TrackSelection> {
  List<String> checkedTracks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add tracks to playlist"),
        actions: <Widget>[
          InkWell(
            customBorder: CircleBorder(),
            child: Container(
              width: 50.0,
              child: Icon(Icons.check),
            ),
            onTap: () {
              musicplayer.savePlaylist(widget.name, [], checkedTracks);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext) => PlaylistPage()));
            },
          )
        ],
      ),
      body: ListView.builder(
          shrinkWrap: true,
          itemCount: musicplayer.allFilePaths.length,
          itemBuilder: (BuildContext context, int index) => ListTile(
                leading: musicplayer.getImage(musicplayer.allMetaData[index][2], context),
                title: Text(musicplayer.allMetaData[index][0]),
                subtitle: Text(musicplayer.allMetaData[index][1]),
                trailing:
                    checkedTracks.contains(musicplayer.allMetaData[index][0]) ==
                            true
                        ? Icon(Icons.check_box)
                        : Icon(Icons.check_box_outline_blank),
                onTap: () {
                  setState(() {
                    if (checkedTracks
                            .contains(musicplayer.allMetaData[index][0]) ==
                        true) {
                      checkedTracks.remove(musicplayer.allMetaData[index][0]);
                    } else {
                      checkedTracks.add(musicplayer.allMetaData[index][0]);
                    }
                  });
                },
              )),
    );
  }
}