import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../fchat.dart';
import '../mypoint.dart';
import '../location_stream.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
final _auth = FirebaseAuth.instance;
GoogleSignInAccount user = _googleSignIn.currentUser;

Future<FirebaseUser> handleSignIn() async {
  poinLogin();
  if (user == null) user = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth = await user.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final FirebaseUser user2 = await _auth.signInWithCredential(credential);
  print("signed in " + user2.displayName);
  await setUsername(user2.displayName);
  await setUserfoto(user2.photoUrl);
  return user2;
}

setUsername(String _username) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', _username);
}

setUserfoto(String _foto) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('foto', _foto);
}

getUsername() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('username').toString();
}

class BottomWidget extends StatefulWidget {
  BottomWidget({Key key}) : super(key: key);

  @override
  _BottomWidgetState createState() {
    return _BottomWidgetState();
  }
}

class _BottomWidgetState extends State<BottomWidget> {
  int _selectedIndex = 0;

  @override
  initState() {
    super.initState();
    handleSignIn();
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  List<Widget> _widgetOptions = <Widget>[
    ChatScreen(),
    LocationScreen(),
    MyPoin(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Log PALINDRA'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            title: Text('Chat Room'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            title: Text('Location History'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            title: Text('Help'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class TesWidget extends StatefulWidget {
  TesWidget({Key key}) : super(key: key);

  @override
  _TesWidgetState createState() => _TesWidgetState();
}

class _TesWidgetState extends State<TesWidget> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'You have pushed the button this many times:',
          ),
          Text(
            '$_counter',
            style: Theme.of(context).textTheme.display1,
          ),
          RaisedButton(
            onPressed: () async {
              poinLogin();
            },
            child: const Text('cek login'),
          ),
          RaisedButton(
            onPressed: () async {
              _incrementCounter();
            },
            child: const Text('+1'),
          ),
        ],
      ),
    );
  }
}

poinLogin() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var dateToday = DateTime.now();
  var dateFromPref =
      DateTime.parse(prefs.getString('lastlogin').toString() ?? dateToday);
  // var dateFromPref = DateTime.parse("2019-07-20 20:18:04Z");
  var selisih = dateFromPref.difference(dateToday).inDays;
  if (selisih == 1) {
    _poinPlus(howMuch: 5);
  }
  print(
      'selisih : $selisih ------- datetoday :  $dateToday ----- lastlogin : $dateFromPref .');
  await prefs.setString('lastlogin', dateToday.toString());
}

_poinPlus({int howMuch = 1}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int pointBefore = prefs.getInt('point') ?? 0;
  int currentPoint = pointBefore += howMuch;
  await prefs.setInt('point', currentPoint);
}
