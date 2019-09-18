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
          mainAxisAlignment: MainAxisAlignment.start,
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
                ])
          ]),
    );
  }

  Widget myPointWidget() {
    _getPoin();
    return Text(
      myPoint,
      style: TextStyle(
          fontSize: 29.0,
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
      width: 50.0,
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
