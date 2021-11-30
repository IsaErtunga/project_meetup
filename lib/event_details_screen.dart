import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  const EventDetailsScreen(this.eventId, {Key? key}) : super(key: key);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  CollectionReference events = FirebaseFirestore.instance.collection('Events');

  Future _refreshEvent(BuildContext context) async {
    return events.doc(widget.eventId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("hej"),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return _refreshEvent(context);
        },
        child: FutureBuilder<DocumentSnapshot>(
            future: events.doc(widget.eventId).get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong");
              }
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          print(snapshot.data!["eventName"]);
                        },
                        child: Text("Hej")),
                    Text("hej"),
                  ],
                );
              }
              return Center(child: const CircularProgressIndicator());
            }),
      ),
    );
  }
}
