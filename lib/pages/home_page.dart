import '../utils/sharedP.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  // const HomePage({Key key}) : super(key: key);
  final String routeName = 'home';
  final prefs = new SharedP();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('POZOS'),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.settings),
                // icon: const Icon(Icons.settings, color: Theme.of(context).primaryColor),
                tooltip: 'Ajustes',
                onPressed: () => Navigator.pushNamed(context, 'ajustes')),
          ],
        ),
        // drawer: MenuWidget(),
        body: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              margin: EdgeInsets.symmetric(vertical: 24.0, horizontal: 48.0),
              child: overlapped(),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
            ),
            Center(
              child: RaisedButton(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                color: Theme.of(context).buttonColor,
                onPressed: () => Navigator.pushNamed(context, 'registro'),
                child: Text("NUEVO REGISTRO"),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: Colors.pink,
              elevation: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.album, size: 70),
                    title: Text('Heart Shaker',
                        style: TextStyle(color: Colors.white)),
                    subtitle:
                        Text('TWICE', style: TextStyle(color: Colors.white)),
                  ),
                  // ButtonTheme.bar(
                  //   child: ButtonBar(
                  //     children: <Widget>[
                  //       FlatButton(
                  //         child: const Text('Edit',
                  //             style: TextStyle(color: Colors.white)),
                  //         onPressed: () {},
                  //       ),
                  //       FlatButton(
                  //         child: const Text('Delete',
                  //             style: TextStyle(color: Colors.white)),
                  //         onPressed: () {},
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            )
          ],
        ));
  }

  Widget overlapped() {
    final items = [
      Image.asset('assets/cam0.png'),
      Image.asset('assets/cam${prefs.nivelCamion}.png'),
    ];

    List<Widget> stackLayers = List<Widget>.generate(items.length, (index) {
      return Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: items[index],
      );
    });

    return Stack(children: stackLayers);
  }
}
