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
//        backgroundColor: Colors.transparent,
        backgroundColor: const Color(0xFFF3F5F7),
        elevation: 0,
        title: Text(""),
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
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
                Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 0, top: 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image(
                            height: 150,
                            width: 150,
                            image: NetworkImage(data["eventPicture"])),
                      ),
                    ),
                    Text(
                      data["eventName"],
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                );
              }
              return Center(child: const CircularProgressIndicator());
            }),
      ),
    );
  }
}
