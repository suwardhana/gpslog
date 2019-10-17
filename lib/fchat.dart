import 'dart:async';
import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

final reference = FirebaseDatabase.instance.reference().child('messages');
final reference2 = FirebaseDatabase.instance.reference().child('userlocations');

@override
class ChatMessage extends StatelessWidget {
  ChatMessage({this.snapshot, this.animation});
  final DataSnapshot snapshot;
  final Animation animation;
  Widget _gambar(String poin) {
    int poin2 = int.parse(poin);
    var level;
    level = poin2 / 10;
    level = level.toInt();
    if (level < 1) {
      level = 1;
    }
    if (level > 9) {
      level = 9;
    }
    return Image.asset(
      'badge/lvl' + level.toString() + '.png',
      width: 20.0,
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
            CircleAvatar(
                backgroundImage:
                    NetworkImage(snapshot.value['senderPhotoUrl'])),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _gambar(snapshot.value['currentPoint'].toString()),
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
  StreamSubscription<Position> _positionStreamSubscription;
  final List<Position> _positions = <Position>[];

  void _toggleListening() {
    debugPrint("button pushed");

    if (_positionStreamSubscription == null) {
      debugPrint("location listening");
      const LocationOptions locationOptions =
          LocationOptions(accuracy: LocationAccuracy.best, distanceFilter: 10);
      final Stream<Position> positionStream =
          Geolocator().getPositionStream(locationOptions);
      _positionStreamSubscription = positionStream.listen((Position position) {
        setState(() {
          _positions.add(position);
        });
        _pushLocation(position);
        debugPrint("location harusnya sudah push");
        debugPrint(
            position.latitude.toString() + "," + position.longitude.toString());
        debugPrint("xx");
      });
      _positionStreamSubscription.pause();
    }
    debugPrint("location harusnya sudah listening");

    setState(() {
      if (_positionStreamSubscription.isPaused) {
        _positionStreamSubscription.resume();
      } else {
        _positionStreamSubscription.pause();
      }
    });
  }

  Future<Null> _pushLocation(Position _position) async {
    List titik = [
      [-2.9900519, 104.7217054, "rumahku"],
      [-2.986844, 104.732186, "Gerbang Unsri Palembang"],
      [-2.989663, 104.735224, "Simpang Padang Selasa"],
      [-2.992716, 104.726864, "Simpang SMA 10"],
      [-2.986910, 104.721923, "Jalan Parameswara"],
      [-3.017649, 104.720889, "Jembatan Musi II"],
      [-3.047131, 104.744160, "Simpang Kertapati"],
      [-3.089733, 104.725442, "Simpang Pemulutan"],
      [-3.179613, 104.678130, "Gerbang Indralaya"],
      [-3.200429, 104.656830, "Simpang Timbangan"],
      [-3.210573, 104.648692, "Gerbang Unsri Indralaya"],
      [-3.2200783, 104.6512259, "Fasilkom Indralaya"],
    ];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _username = prefs.getString('username').toString() ?? "";

    for (var i = 0; i < titik.length; i++) {
      double distanceInMeters = await Geolocator().distanceBetween(
          titik[i][0], titik[i][1], _position.latitude, _position.longitude);
      if (distanceInMeters < 150) {
        reference2.push().set({
          'time': _position.timestamp.toLocal().toString(),
          'username': _username,
          'nearestradius': titik[i][2],
          'latitude': _position.latitude,
          'longitude': _position.longitude,
        });
        _poinPlus(howMuch: 5);
      }
    }
    // debugPrint("pushlocationfun");
  }

  getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _username = prefs.getString('username').toString() ?? "";
    return _username;
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription.cancel();
      _positionStreamSubscription = null;
    }
    super.dispose();
  }

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
      RaisedButton(
        child: _buildButtonText(),
        color: _determineButtonColor(),
        padding: const EdgeInsets.all(8.0),
        onPressed: _toggleListening,
      ),
      Divider(height: 1.0),
      Container(
        decoration: BoxDecoration(color: Theme.of(context).cardColor),
        child: _buildTextComposer(),
      ),
    ]));
  }

  bool _isListening() => !(_positionStreamSubscription == null ||
      _positionStreamSubscription.isPaused);

  Widget _buildButtonText() {
    return Text(_isListening() ? 'Stop listening' : 'Start listening');
  }

  Color _determineButtonColor() {
    return _isListening() ? Colors.red : Colors.green;
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
    _poinPlus(howMuch: 1);
    _sendMessage(text: text);
  }

  _sendMessage({String text}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username');
    String foto = prefs.getString('foto');
    int pointBefore = prefs.getInt('point') ?? 0;
    reference.push().set({
      'currentPoint': pointBefore,
      'text': text,
      'senderName': username,
      'senderPhotoUrl': foto
    });
  }

  _poinPlus({int howMuch = 1}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int pointBefore = prefs.getInt('point') ?? 0;
    int currentPoint = pointBefore += howMuch;
    await prefs.setInt('point', currentPoint);
  }
}
