import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String myPoint = "0";

class MyPoin extends StatefulWidget {
  @override
  _MyPoinState createState() => _MyPoinState();
}

class _MyPoinState extends State<MyPoin> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Poin saya",
                    style: TextStyle(
                        fontSize: 46.0,
                        color: const Color(0xFF000000),
                        fontWeight: FontWeight.w500,
                        fontFamily: "Roboto"),
                  )
                ]),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _gambar(myPoint),
                ]),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  myPointWidget(),
                ]),
            Column(
              children: <Widget>[
                _badgeImage2(1),
                _badgeImage2(2),
                _badgeImage2(3),
                _badgeImage2(4),
                _badgeImage2(5),
                _badgeImage2(6),
                _badgeImage2(7),
                _badgeImage2(8),
                _badgeImage2(9),
              ],
            ),
          ]),
    );
  }

  Widget myPointWidget() {
    _getPoin();
    return Text(
      myPoint,
      style: TextStyle(
          fontSize: 40.0,
          color: const Color(0xFF000000),
          fontWeight: FontWeight.w200,
          fontFamily: "Roboto"),
    );
  }

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
      width: 25.0,
    );
  }

  _getPoin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int _point = prefs.getInt('point') ?? 1;
    setState(() {
      myPoint = _point.toString();
    });
  }
}

Widget _badgeImage2(int level) {
  var v = ((level) * 10);
  var v2 = v + 9;
  String v3 = v.toString() + " - " + v2.toString();
  if (level < 2) {
    v3 = "1 - 19";
  }
  if (level > 8) {
    v3 = "    > 90";
  }
  return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'badge/lvl' + level.toString() + '.png',
          width: 25.0,
        ),
        Text("Level $level"),
        Text(v3),
      ]);
}
