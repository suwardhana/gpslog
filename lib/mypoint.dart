import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                  Image.asset(
                    'badge/lvl1.png',
                    fit: BoxFit.fill,
                    width: 100.0,
                    height: 100.0,
                  )
                ]),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _getPoin(),
                    style: TextStyle(
                        fontSize: 29.0,
                        color: const Color(0xFF000000),
                        fontWeight: FontWeight.w200,
                        fontFamily: "Roboto"),
                  )
                ])
          ]),
    );
  }
}

_getPoin() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int _point = prefs.getInt('poin') ?? "";
  return _point;
}
