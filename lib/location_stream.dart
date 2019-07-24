import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './elements/placeholder_widget.dart';

final reference = FirebaseDatabase.instance.reference().child('userlocations');

@override
class LocationRow extends StatelessWidget {
  LocationRow({this.snapshot, this.animation});
  final DataSnapshot snapshot;
  final Animation animation;

  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(snapshot.value['username'],
                      style: Theme.of(context).textTheme.subhead),
                  Text(snapshot.value['nearestradius'],
                      style: Theme.of(context).textTheme.subhead),
                  Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: Text(snapshot.value['time']),
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

class LocationScreen extends StatefulWidget {
  @override
  State createState() => LocationScreenState();
}

class LocationScreenState extends State<LocationScreen> {
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
    ];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _username = prefs.getString('username').toString() ?? "";

    for (var i = 0; i < titik.length; i++) {
      double distanceInMeters = await Geolocator().distanceBetween(
          titik[i][0], titik[i][1], _position.latitude, _position.longitude);
      if (distanceInMeters < 300) {
        reference.push().set({
          'time': _position.timestamp.toLocal().toString(),
          'username': _username,
          'nearestradius': titik[i][2],
          'latitude': _position.latitude,
          'longitude': _position.longitude,
        });
      }
    }
    debugPrint("pushlocationfun");
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
            return LocationRow(snapshot: snapshot, animation: animation);
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
}

class LocationStreamWidget extends StatefulWidget {
  @override
  State<LocationStreamWidget> createState() => LocationStreamState();
}

class LocationStreamState extends State<LocationStreamWidget> {
  StreamSubscription<Position> _positionStreamSubscription;
  final List<Position> _positions = <Position>[];

  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      const LocationOptions locationOptions =
          LocationOptions(accuracy: LocationAccuracy.best, distanceFilter: 10);
      final Stream<Position> positionStream =
          Geolocator().getPositionStream(locationOptions);
      _positionStreamSubscription = positionStream.listen((Position position) {
        setState(() {
          _positions.add(position);
        });
        _pushLocation(position);
      });
      _positionStreamSubscription.pause();
    }

    setState(() {
      if (_positionStreamSubscription.isPaused) {
        _positionStreamSubscription.resume();
      } else {
        _positionStreamSubscription.pause();
      }
    });
  }

//  getUsername() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String _username = prefs.getString('username').toString() ?? "";
//     return _username.toString();
//   }

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
    return FutureBuilder<GeolocationStatus>(
        future: Geolocator().checkGeolocationPermissionStatus(),
        builder:
            (BuildContext context, AsyncSnapshot<GeolocationStatus> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == GeolocationStatus.denied) {
            return const PlaceholderWidget('Location services disabled',
                'Enable location services for this App using the device settings.');
          }

          return _buildListView();
        });
  }

  Widget _buildListView() {
    final List<Widget> listItems = <Widget>[
      ListTile(
        title: RaisedButton(
          child: _buildButtonText(),
          color: _determineButtonColor(),
          padding: const EdgeInsets.all(8.0),
          onPressed: _toggleListening,
        ),
      ),
    ];

    listItems.addAll(_positions
        .map((Position position) => PositionListItem(position))
        .toList());

    return ListView(
      children: listItems,
    );
  }

  bool _isListening() => !(_positionStreamSubscription == null ||
      _positionStreamSubscription.isPaused);

  Widget _buildButtonText() {
    return Text(_isListening() ? 'Stop listening' : 'Start listening');
  }

  Color _determineButtonColor() {
    return _isListening() ? Colors.red : Colors.green;
  }

  Future<Null> _pushLocation(Position position) async {
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
    ];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _username = prefs.getString('username').toString() ?? "";

    for (var i = 0; i < titik.length; i++) {
      double distanceInMeters = await Geolocator().distanceBetween(
          titik[i][0], titik[i][1], position.latitude, position.longitude);
      if (distanceInMeters < 300) {
        reference.push().set({
          'time': position.timestamp.toLocal().toString(),
          'username': _username,
          'nearestradius': titik[i][2],
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      }
    }
  }
}

class PositionListItem extends StatefulWidget {
  const PositionListItem(this._position);

  final Position _position;

  @override
  State<PositionListItem> createState() => PositionListItemState(_position);
}

class PositionListItemState extends State<PositionListItem> {
  PositionListItemState(this._position);

  final Position _position;

  @override
  Widget build(BuildContext context) {
    final Row row = Row(
      children: <Widget>[
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                'Lat: ${_position.latitude}',
                style: const TextStyle(fontSize: 16.0, color: Colors.black),
              ),
              Text(
                'Lon: ${_position.longitude}',
                style: const TextStyle(fontSize: 16.0, color: Colors.black),
              ),
            ]),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  _position.timestamp.toLocal().toString(),
                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                )
              ]),
        ),
      ],
    );

    return ListTile(title: row);
  }
}
