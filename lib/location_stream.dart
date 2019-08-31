import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

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
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[Text(snapshot.value['username'],
                      style: Theme.of(context).textTheme.subhead),
                    Text(tglIndo(snapshot.value['time']))
                  ],),
                  Text(snapshot.value['nearestradius'],
                      style: Theme.of(context).textTheme.subhead),

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: <Widget>[
      Flexible(
        child: FirebaseAnimatedList(
          query: reference,
          sort: (a, b) => b.key.compareTo(a.key),
          padding: EdgeInsets.all(8.0),
          reverse: false,
          itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation,
              int index) {
            return LocationRow(snapshot: snapshot, animation: animation);
          },
        ),
      ),
      Divider(height: 1.0),
    ]));
  }
}

String tglIndo(String datetime){

  var month = ['Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'];
  var onlydate = datetime.split(" ");
  var tanggalIndo = onlydate[0].split("-");
  var tanggalIndoRes = tanggalIndo[2]+" "+month[int.parse(tanggalIndo[1])-1]+" "+tanggalIndo[0]+"   "+onlydate[1].substring(0,5);
  return tanggalIndoRes;
}
