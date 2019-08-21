import 'package:flutter/material.dart';
import 'package:formtest/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:formtest/todo.dart';
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
  List<Todo> _todoList = new List();
  List<Todo> _fulltodoList = new List();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _todoQuery;

  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    _checkEmailVerification();

    _todoList = new List();
    _todoQuery = _database
        .reference()
        .child("todo")
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(_onEntryAdded);
    _onTodoChangedSubscription =
        _todoQuery.onChildChanged.listen(_onEntryChanged);
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
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  _onEntryChanged(Event event) {
    var oldEntry = _todoList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _todoList[_todoList.indexOf(oldEntry)] =
          Todo.fromSnapshot(event.snapshot);
    });
  }

  _onEntryAdded(Event event) {
    _fulltodoList.add(Todo.fromSnapshot(event.snapshot));
    // _database.reference().once().then((DataSnapshot snapshot) {
    //   _fulltodoList.add(Todo.fromSnapshot(snapshot));
    //   print('Data : ${snapshot.value}');
    //   print(_fulltodoList.length);
    // });

    setState(() {
      _todoList.add(Todo.fromSnapshot(event.snapshot));
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

  _addNewTodo(String todoItem) {
    if (todoItem.length > 0) {
      Todo todo = new Todo(todoItem.toString(), widget.userId, false);
      _database.reference().child("todo").push().set(todo.toJson());
    }
  }

  _updateTodo(Todo todo) {
    //Toggle completed
    todo.completed = !todo.completed;
    if (todo != null) {
      _database.reference().child("todo").child(todo.key).set(todo.toJson());
    }
  }

  _deleteTodo(String todoId, int index) {
    _database.reference().child("todo").child(todoId).remove().then((_) {
      print("Delete $todoId successful");
      setState(() {
        _todoList.removeAt(index);
      });
    });
  }

  TextEditingController editingController = TextEditingController();
  void filterSearchResults(String query) {
    List<Todo> dummySearchList = List<Todo>();
    dummySearchList = _fulltodoList;
    if (query.isNotEmpty) {
      List<Todo> dummyListData = List<Todo>();
      dummySearchList.forEach((item) {
        if (item.subject.contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        _todoList.clear();
        _todoList.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        _todoList.clear();
        _todoList.addAll(dummySearchList);
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
                    labelText: 'Add new todo',
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
                    _addNewTodo(_textEditingController.text.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Widget _showTodoList() {
    if (_todoList.length > 0) {
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
                itemCount: _todoList.length,
                itemBuilder: (BuildContext context, int index) {
                  String todoId = _todoList[index].key;
                  String subject = _todoList[index].subject;
                  bool completed = _todoList[index].completed;
                  String userId = _todoList[index].userId;
                  return Dismissible(
                    key: Key(todoId),
                    background: Container(color: Colors.red),
                    onDismissed: (direction) async {
                      _deleteTodo(todoId, index);
                    },
                    child: ListTile(
                      title: Text(
                        subject,
                        style: TextStyle(fontSize: 20.0),
                      ),
                      trailing: IconButton(
                          icon: (completed)
                              ? Icon(
                                  Icons.done_outline,
                                  color: Color.fromRGBO(2, 55, 255, 1),
                                  size: 20.0,
                                )
                              : Icon(Icons.done,
                                  color: Colors.pink,
                                  size: 20.0),
                          onPressed: () {
                            _updateTodo(_todoList[index]);
                          }),
                    ),
                  );
                }))
      ]));
    } else {
      return Center(
          child: Text(
        "Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
      ));
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
        body: _showTodoList(),
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
                          builder: (context) => new Profile()));
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
