import 'dart:async';
import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'package:shared_preferences/shared_preferences.dart';

final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

final reference = FirebaseDatabase.instance.reference().child('messages');

@override
class ChatMessage extends StatelessWidget {
  ChatMessage({this.snapshot, this.animation});
  final DataSnapshot snapshot;
  final Animation animation;
  Widget _gambar(String poin) {
    int poin2 = int.parse(poin);
    var level;
    level = poin2 / 10;
    // debugPrint("level awal = " + level.toString());
    level = level.toInt();
    if (level < 1) {
      level = 1;
    }
    if (level > 9) {
      level = 9;
    }
    // debugPrint('badge/lvl' + level.toString() + '.png');
    return Image.asset(
      'badge/lvl' + level.toString() + '.png',
      width: 25.0,
    );
  }

  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(alignment: AlignmentDirectional.bottomEnd, children: <Widget>[
              CircleAvatar(
                  backgroundImage:
                      NetworkImage(snapshot.value['senderPhotoUrl'])),
              _gambar(snapshot.value['currentPoint'].toString()),
            ]),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(snapshot.value['senderName'],
                          style: Theme.of(context).textTheme.subhead),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: Text(snapshot.value['text']),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: <Widget>[
      Flexible(
        child: FirebaseAnimatedList(
          query: reference,
          sort: (a, b) => b.key.compareTo(a.key),
          padding: EdgeInsets.all(8.0),
          reverse: true,
          itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation,
              int index) {
            return ChatMessage(snapshot: snapshot, animation: animation);
          },
        ),
      ),
      Divider(height: 1.0),
      Container(
        decoration: BoxDecoration(color: Theme.of(context).cardColor),
        child: _buildTextComposer(),
      ),
    ]));
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(children: <Widget>[
          Flexible(
            child: TextField(
              controller: _textController,
              onChanged: (String text) {
                setState(() {
                  _isComposing = text.length > 0;
                });
              },
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration.collapsed(hintText: "Send a message"),
            ),
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: _isComposing
                    ? () => _handleSubmitted(_textController.text)
                    : null,
              )),
        ]),
      ),
    );
  }

  Future<Null> _handleSubmitted(String text) async {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    // GoogleSignInAccount user = _googleSignIn.currentUser;
    // if (user == null) {
    //   await _handleSignIn();
    // }
    _sendMessage(text: text);
  }

  void _sendMessage({String text}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username');
    String foto = prefs.getString('foto');

    reference.push().set({
      'currentPoint': 10,
      'text': text,
      'senderName': username,
      'senderPhotoUrl': foto
    });
  }
}
