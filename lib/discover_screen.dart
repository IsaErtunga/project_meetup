import 'package:flutter/material.dart';

/// Stateful Widget for bottom navigation bar.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final List<String> entries = <String>[
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J'
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              borderRadius: BorderRadius.circular(3),
              onTap: () {
                print('Card tapped.');
              },
              child: Container(
                width: 300,
                height: 100,
                child: Center(
                    child: Row(
                  children: const <Widget>[
                    Expanded(
                      child: Text('Card', textAlign: TextAlign.center),
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.contain, // otherwise the logo will be tiny
                        child: FlutterLogo(),
                      ),
                    ),
                  ],
                )),
              ),
            ),
          );
        });
  }
}
