import 'package:flutter/material.dart';

/// Stateful Widget for bottom navigation bar.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Discover',
    ),
    Text(
      'Index 1: Events',
    ),
    Text(
      'Index 2: Chat',
    ),
    Text(
      'Index 3: Profile',
    ),
  ];
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
          return Container(
            child: Card(
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  print('Card tapped.');
                },
                child: Container(
                  width: 300,
                  height: 100,
                  child: Center(child: Text(entries[index].toString())),
                ),
              ),
            ),
          );
        });
  }
}
/*

Container(
            height: 50,
            color: Colors.grey,
            child: Center(child: Text(entries[index].toString())),
          );

          Center(
      child: Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            print('Card tapped.');
          },
          child: const SizedBox(
            width: 300,
            height: 100,
            child: Text('A card that can be tapped'),
          ),
        ),
      ),
    );
 */
