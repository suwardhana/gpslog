import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../fchat.dart';

class BottomWidget extends StatefulWidget {
  BottomWidget({Key key}) : super(key: key);

  @override
  _BottomWidgetState createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<BottomWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  List<Widget> _widgetOptions = <Widget>[
    ChatScreen(),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    TesWidget(),
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
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            title: Text('Business'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            title: Text('School'),
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

  print(
      'selisih : $selisih ------- datetoday :  $dateToday ----- lastlogin : $dateFromPref .');
  await prefs.setString('lastlogin', dateToday.toString());
}
