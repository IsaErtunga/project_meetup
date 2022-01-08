//import 'dart:html';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_meetup/discover_screen.dart';
import 'package:project_meetup/profile_screen.dart';
import 'group_details_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  const EventDetailsScreen(this.event, {Key? key}) : super(key: key);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  CollectionReference events = FirebaseFirestore.instance.collection('Events');
  CollectionReference groups = FirebaseFirestore.instance.collection('Groups');

  Future _refreshEvent(BuildContext context) async {
    return events.doc(widget.event.eventId).get();
  }

  Widget getTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 20.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  //bool _joinHasBeenPressed = false;

  //void _getEventAdress(Coordinates eventCoordinates) {}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: events.doc(widget.event.eventId).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return Text("Document does not exist");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> eventData =
                snapshot.data!.data() as Map<String, dynamic>;
            return Scaffold(
                backgroundColor: Colors.white,
                body: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: <Widget>[
                      SliverAppBar(
                          backgroundColor: Colors.black54,
                          expandedHeight: 200,
                          collapsedHeight: 60,
                          pinned: true,

                          //shape: Rectangle,
                          flexibleSpace: LayoutBuilder(
                            builder: (context, c) {
                              final settings =
                                  context.dependOnInheritedWidgetOfExactType<
                                      FlexibleSpaceBarSettings>();
                              final deltaExtent =
                                  settings!.maxExtent - settings.minExtent;
                              final t = (1.0 -
                                      (settings.currentExtent -
                                              settings.minExtent) /
                                          deltaExtent)
                                  .clamp(0.0, 1.0) as double;
                              final fadeStart = math.max(
                                  0.0, 1.0 - kToolbarHeight / deltaExtent);
                              const fadeEnd = 1.0;
                              final opacity = 1.0 -
                                  Interval(fadeStart, fadeEnd).transform(t);

                              return Stack(
                                children: [
                                  Center(
                                    child: Opacity(
                                        opacity: 1 - opacity,
                                        child: getTitle(
                                          eventData["eventName"].toString(),
                                        )),
                                  ),
                                  Opacity(
                                    opacity: opacity,
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        Hero(
                                          tag: widget.event.eventId,
                                          child: Container(
                                            width: double.infinity,
                                            child: Image(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                  eventData["eventPicture"]
                                                      .toString(),
                                                )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          )),
                      SliverFillRemaining(
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 10,
                                      top: 3 * SizeConfig.heightMultiplier),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        eventData["eventName"].toString(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            fontSize: 3 *
                                                SizeConfig.heightMultiplier),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: 1.5 * SizeConfig.heightMultiplier),
                                Container(
                                    alignment: Alignment.center,
                                    height: 100,
                                    // width: 400,
                                    child:
                                        eventData["hostingGroupID"].isNotEmpty
                                            ? ListView(
                                                padding: const EdgeInsets.only(
                                                    top: 5,
                                                    bottom: 0,
                                                    right: 13,
                                                    left: 50),
                                                scrollDirection:
                                                    Axis.horizontal,
                                                children:
                                                    eventData["hostingGroupID"]
                                                        .map<Widget>(
                                                            (document) {
                                                  return FutureBuilder<
                                                          DocumentSnapshot>(
                                                      future: groups
                                                          .doc(document)
                                                          .get(),
                                                      builder: (BuildContext
                                                              context,
                                                          AsyncSnapshot<
                                                                  DocumentSnapshot>
                                                              snapshot) {
                                                        if (snapshot.hasError) {
                                                          return Text(
                                                              "Something went wrong");
                                                        }

                                                        if (snapshot.hasData &&
                                                            !snapshot
                                                                .data!.exists) {
                                                          return Text(
                                                              "Document does not exist");
                                                        }

                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .done) {
                                                          Map<String, dynamic>
                                                              groupData =
                                                              snapshot.data!
                                                                      .data()
                                                                  as Map<String,
                                                                      dynamic>;
                                                          return GestureDetector(
                                                              onTap:
                                                                  () => {
                                                                        Navigator.of(context).push(_createRouteToGroup(Group(
                                                                            document,
                                                                            groupData)))
                                                                      },
                                                              child: Hero(
                                                                  tag: document,
                                                                  child:
                                                                      SizedBox(
                                                                          height:
                                                                              100,
                                                                          child:
                                                                              Row(children: <Widget>[
                                                                            CircleAvatar(
                                                                              backgroundImage: NetworkImage(groupData["groupPicture"].toString()),
                                                                            ),
                                                                            SizedBox(width: 20), //edit join button: color change after group is joined, write function that checks if user is already group member; base the button color on this info
                                                                            Text(groupData["groupName"].toString()),
                                                                            SizedBox(width: 50),
                                                                            OutlinedButton(
                                                                                onPressed: () => {},
                                                                                child: const Text('JOIN', style: TextStyle(color: Colors.black))),
                                                                          ]))));
                                                        }
                                                        return Text("loading");
                                                      });
                                                }).toList(),
                                              )
                                            : const Text("No group",
                                                style:
                                                    TextStyle(fontSize: 24))),
                                SizedBox(
                                    height: 3 * SizeConfig.heightMultiplier),
                                Container(
                                  height: 300,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Column(
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            children: <Widget>[
                                              Icon(Icons.calendar_today,
                                                  color: Colors.black,
                                                  size: 20),
                                              SizedBox(width: 5),
                                              Text(
                                                (DateFormat.MMMEd()
                                                    .add_Hm()
                                                    .format(
                                                        eventData["Date_Time"]
                                                            .toDate())
                                                    .toString()),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(children: <Widget>[
                                          Icon(Icons.location_on,
                                              color: Colors.black, size: 20),
                                          SizedBox(width: 5),
                                          Text("hallo")
                                        ])
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]));
          }
          return Center(child: const CircularProgressIndicator());
        });
  }
}

Route _createRouteToGroup(data) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        GroupDetailsScreen(data),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}



/*
class _MyCustomAppBar extends StatelessWidget {
  const _MyCustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final settings = context
            .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
        final deltaExtent = settings!.maxExtent - settings.minExtent;
        final t =
            (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
                .clamp(0.0, 1.0) as double;
        final fadeStart = math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
        const fadeEnd = 1.0;
        final opacity = 1.0 - Interval(fadeStart, fadeEnd).transform(t);

        return Stack(
          children: [
            Center(
              child: Opacity(
                  opacity: 1 - opacity,
                  child: getTitle(
                    'Collapsed Title',
                  )),
            ),
            Opacity(
              opacity: opacity,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  getImage(),
                  getTitle(
                    'Expended Title',
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget getImage() {
    return Container(
      width: double.infinity,
      child: Image.network(
        'https://source.unsplash.com/daily?code',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget getTitle(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 26.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} */
