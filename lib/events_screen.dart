import 'package:flutter/material.dart';
import 'package:project_meetup/user_authentication.dart';
import 'package:provider/provider.dart';

/// Stateful Widget for bottom navigation bar.
class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
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

    Column _buildButtonColumn(Color color, IconData icon, String label) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: color,
              ),
            ),
          ),
        ],
      );
    }
  }
}
