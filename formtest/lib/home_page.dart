import 'package:flutter/material.dart';
import 'package:formtest/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:formtest/event.dart';
import 'dart:async';
import 'package:formtest/feed.dart';
import 'package:formtest/profile.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<EventData> _eventList = new List();
  List<EventData> _fullEventList = new List();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onEventAddedSubscription;
  StreamSubscription<Event> _onEventChangedSubscription;

  Query _eventQuery;

  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    _checkEmailVerification();

    _eventList = new List();
    _eventQuery = _database
        .reference()
        .child("event")
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onEventAddedSubscription = _eventQuery.onChildAdded.listen(_onEntryAdded);
    _onEventChangedSubscription =
        _eventQuery.onChildChanged.listen(_onEntryChanged);
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
              new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _onEventAddedSubscription.cancel();
    _onEventChangedSubscription.cancel();
    super.dispose();
  }

  _onEntryChanged(Event event) {
    var oldEntry = _eventList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _eventList[_eventList.indexOf(oldEntry)] =
          EventData.fromSnapshot(event.snapshot);
    });
  }

  _onEntryAdded(Event event) {
    _fullEventList.add(EventData.fromSnapshot(event.snapshot));

    setState(() {
      _eventList.add(EventData.fromSnapshot(event.snapshot));
      print(_eventList);
    });
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  _addNewEvent(String eventItem) {
    if (eventItem.length > 0) {
      EventData event =
          new EventData(eventItem.toString(), widget.userId, false);
      _database.reference().child("event").push().set(event.toJson());
    }
  }

  _updateEvent(EventData event) {
    //Toggle completed
    event.completed = !event.completed;
    if (event != null) {
      _database.reference().child("event").child(event.key).set(event.toJson());
    }
  }

  _deleteEvent(String eventId, int index) {
    _database.reference().child("event").child(eventId).remove().then((_) {
      print("Delete $eventId successful");
      setState(() {
        _eventList.removeAt(index);
      });
    });
  }

  TextEditingController editingController = TextEditingController();
  void filterSearchResults(String query) {
    List<EventData> dummySearchList = List<EventData>();
    dummySearchList = _fullEventList;
    if (query.isNotEmpty) {
      List<EventData> dummyListData = List<EventData>();
      dummySearchList.forEach((item) {
        if (item.subject.contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        _eventList.clear();
        _eventList.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        _eventList.clear();
        _eventList.addAll(dummySearchList);
      });
    }
  }

  _showDialog(BuildContext context) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new TextField(
                  controller: _textEditingController,
                  autofocus: true,
                  decoration: new InputDecoration(
                    labelText: 'Add new Event',
                  ),
                ))
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Save'),
                  onPressed: () {
                    _addNewEvent(_textEditingController.text.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Widget _showEventList() {
    print(_eventList);
    if (_eventList.length > 0) {
      return Container(
          child: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              filterSearchResults(value);
            },
            controller: editingController,
            decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)))),
          ),
        ),
        Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: _eventList.length,
                itemBuilder: (BuildContext context, int index) {
                  String eventId = _eventList[index].key;
                  String subject = _eventList[index].subject;
                  bool completed = _eventList[index].completed;
                  String userId = _eventList[index].userId;
                  return Dismissible(
                    key: Key(eventId),
                    background: Container(color: Colors.red),
                    onDismissed: (direction) async {
                      _deleteEvent(eventId, index);
                    },
                    child: new Container(
                      margin: const EdgeInsets.all(10),
                      child: FittedBox(
                        child: Material(
                          color: Colors.grey.shade100,
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 150,
                                height: 150,
                                margin: const EdgeInsets.only(left: 10.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.asset(
                                    "assets/cm0.jpeg",
                                    fit: BoxFit.fill,
                                    alignment: Alignment.topLeft,
                                  ),
                                ),
                              ),
                              Container(
                                  width: 220,
                                  height: 180,
                                  alignment: Alignment.topCenter,
                                  padding:
                                      new EdgeInsets.fromLTRB(20, 20, 10, 100),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new Text(
                                        subject,
                                        style: TextStyle(fontSize: 30),
                                      ),
                                    ],
                                  )),
                              Container(
                                width: 150,
                                height: 150,
                                child: IconButton(
                                    icon: (completed)
                                        ? Icon(
                                            Icons.done_outline,
                                            color:
                                                Color.fromRGBO(2, 55, 255, 1),
                                            size: 40.0,
                                          )
                                        : Icon(Icons.done,
                                            color: Colors.pink, size: 40.0),
                                    onPressed: () {
                                      _updateEvent(_eventList[index]);
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }))
      ]));
    } else {
      return Center(
          child:  Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              filterSearchResults(value);
            },
            controller: editingController,
            decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)))),
          ),
        ),
        Text(
        "Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      )
          ])
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Events'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: _signOut)
          ],
        ),
        body: _showEventList(),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Menu',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                decoration: BoxDecoration(
                  color: Colors.pink,
                ),
              ),
              ListTile(
                title: Text('Events'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('News Feeds'),
                onTap: () {
                  Navigator.push(context,
                      new MaterialPageRoute(builder: (context) => new Feed()));
                },
              ),
              ListTile(
                title: Text('Profile'),
                onTap: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new Profile(widget.userId)));
                },
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showDialog(context);
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ));
  }
}
