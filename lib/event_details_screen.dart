//import 'dart:html';
import 'dart:ffi';
import 'dart:math' as math;
import 'package:intl/intl.dart'; //for timestamp to date and time conversion
import 'package:geocoding/geocoding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_meetup/discover_screen.dart';
import 'package:project_meetup/profile_screen.dart';
import 'group_details_screen.dart';
import 'profile_screen_other_users.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  const EventDetailsScreen(this.event, {Key? key}) : super(key: key);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference events = FirebaseFirestore.instance.collection('Events');
  CollectionReference groups = FirebaseFirestore.instance.collection('Groups');
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future _refreshEvent(BuildContext context) async {
    return events.doc(widget.event.eventId).get();
  }

  // final AsyncMemoizer _memoizer = AsyncMemoizer();

  String _eventAddress = "";
  String _eventAddressSecondLine = "";

  //Future<void> getEventAddress (Position position)
  //  List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude)

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

  String _hostingGroupID = "";

  void _addUserToGroup() async {
    var hostingGroupID = "";
    var docSnapshot = await events.doc(widget.event.eventId).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? eventdata =
          docSnapshot.data() as Map<String, dynamic>;
      hostingGroupID = eventdata['hostingGroup'][0]['id'];
      print(hostingGroupID);
    }
    setState(() {
      _hostingGroupID = hostingGroupID;
      print(_hostingGroupID);

      //to do: refresh the profile screen
    });

    /*  users.doc(auth.currentUser!.uid).get().then((DocumentSnapshot ds) {
      if (ds["myGroups"].contains(_hostingGroupID)) {
        */
    //edit this so the function checks wether there is already a map in the myGroups array that contains the hostingGroupID
    return users.doc(auth.currentUser!.uid).update({
      'myGroups': FieldValue.arrayUnion([
        {'id': _hostingGroupID}
      ])
    });
  }

  //bool _joinHasBeenPressed = false;

/*
  checkIfUserInGroup() async {
    Object blabla =
        await users.doc(auth.currentUser!.uid).get("myGroups").then((value) {
      return value.data();
    });
  }

  Future<void> _addUserToGroup() {
    dynamic blabla = users.doc(auth.currentUser!.uid).get();

    if (blabla["myGroups"].containsNot(_hostingGroupID)) {
      return Text("you are already a member");
    } else {
      return users.doc(auth.currentUser!.uid).update({
        'myGroups': FieldValue.arrayUnion([_hostingGroupID])
      });
    }
  }
*/

  //add get() doc snapshot of eventdata, then call the function after @override widget build
  void _getEventAdress(GeoPoint) async {
    var eventPlace =
        await placemarkFromCoordinates(GeoPoint.latitude, GeoPoint.longitude);

    String? name = eventPlace[0].name;
    String? locality = eventPlace[0].locality;
    String? street = eventPlace[0].street;
    String? postalCode = eventPlace[0].postalCode;

    String eventAdress = "${street} ${name} ";
    String eventAdressSecondLine = "${postalCode} ${locality}";
    //print(eventAdress);

    /*
    setState(() {
      _eventAddress = eventAdress;
      _eventAddressSecondLine = eventAdressSecondLine;
    });
    */
    print(_eventAddress);
  }

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

            // _getEventAdress(eventData["location"]);
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
                          final fadeStart =
                              math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
                          const fadeEnd = 1.0;
                          final opacity =
                              1.0 - Interval(fadeStart, fadeEnd).transform(t);

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
                    hasScrollBody: false,
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
                                        fontSize:
                                            3 * SizeConfig.heightMultiplier),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 1.5 * SizeConfig.heightMultiplier),
                            Container(
                              alignment: Alignment.center,
                              height: 100,
                              // width: 200,
                              child: eventData["hostingGroup"].isNotEmpty
                                  ? ListView(
                                      /*   gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 1),*/
                                      padding: const EdgeInsets.only(
                                          left: 40, right: 40),
                                      children: eventData["hostingGroup"]
                                          .map<Widget>((hostingGroup) {
                                        return GestureDetector(
                                          onTap: () => {
                                            Navigator.of(context)
                                                .push(_createRouteToGroup(Group(
                                              hostingGroup["id"],
                                            )))
                                          },
                                          /* child: Hero(
                                            tag: hostingGroup["id"],*/
                                          child: SizedBox(
                                            height: 100,
                                            child: Row(
                                              children: <Widget>[
                                                CircleAvatar(
                                                  radius: 30,
                                                  backgroundImage: NetworkImage(
                                                      hostingGroup[
                                                              "groupPicture"]
                                                          .toString()),
                                                ),
                                                SizedBox(width: 10),
                                                //edit join button: color change after group is joined, write function that checks if user is already group member; base the button color on this info
                                                SizedBox(
                                                  width: 150,
                                                  child: Text(
                                                      hostingGroup["groupName"]
                                                          .toString()),
                                                ),
                                                SizedBox(width: 5),
                                                OutlinedButton(
                                                    onPressed: () => {
                                                          _addUserToGroup(),
                                                          print(
                                                              'hurensohn $_hostingGroupID')
                                                        },
                                                    child: const Text('JOIN',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black))),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  : const Text("No group",
                                      style: TextStyle(fontSize: 24)),
                            ),
                            SizedBox(height: 3 * SizeConfig.heightMultiplier),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(top: 5, bottom: 5),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.calendar_today,
                                              color: Colors.black, size: 20),
                                          SizedBox(width: 10),
                                          Text((DateFormat.yMMMEd().format(
                                                  eventData["Date_Time"]
                                                      .toDate()))
                                              .toString()),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(bottom: 5, left: 30),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          (DateFormat.Hm().format(
                                                  eventData["Date_Time"]
                                                      .toDate()))
                                              .toString(),
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5, bottom: 5),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.location_on,
                                            color: Colors.black, size: 20),
                                        SizedBox(width: 10),
                                        Text(_eventAddress)
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(bottom: 5, left: 30),
                                    child: Row(
                                      children: <Widget>[
                                        Text(_eventAddressSecondLine,
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5 * SizeConfig.heightMultiplier),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    "About",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        fontSize:
                                            3 * SizeConfig.textMultiplier),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 1.5 * SizeConfig.heightMultiplier),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Container(
                                child: Text(eventData["description"]),
                              ),
                            ),
                            SizedBox(height: 5 * SizeConfig.heightMultiplier),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    "Location",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        fontSize:
                                            3 * SizeConfig.textMultiplier),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: SizedBox(
                                height: 100,
                                child: Text("enter >Google API here"),
                              ),
                            ),
                            SizedBox(height: 5 * SizeConfig.heightMultiplier),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    "Participants",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        fontSize:
                                            3 * SizeConfig.textMultiplier),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 1.5 * SizeConfig.heightMultiplier),
                            Expanded(
                              child: Container(
                                height: 50 * SizeConfig.heightMultiplier,
                                child: eventData["Participants"].isNotEmpty
                                    ? GridView(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                mainAxisSpacing: 15,
                                                crossAxisSpacing: 15,
                                                childAspectRatio: 2.2),
                                        padding: const EdgeInsets.all(8),
                                        scrollDirection: Axis.vertical,
                                        physics: const BouncingScrollPhysics(),
                                        children: eventData["Participants"]
                                            .map<Widget>((participant) {
                                          return GestureDetector(
                                            onTap: () => {
                                              Navigator.of(context).push(
                                                  _createRouteToUser(
                                                      User(participant["id"])))
                                            },
                                            child: Card(
                                              elevation: 3,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0)),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  /*   border: Border.all(
                                                              color:
                                                                  Colors.black,
                                                            ),*/
                                                  /* boxShadow: [
                                                              BoxShadow(
                                                                 color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.5),
                                                                spreadRadius: 1,
                                                                blurRadius: 5, 
                                                                offset: Offset(
                                                                    0,
                                                                    0), // changes position of shadow
                                                              ),
                                                            ],*/
                                                  color: Colors.grey[800],
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5)),
                                                    Hero(
                                                      tag: participant["id"],
                                                      child: Container(
                                                        height: 5 *
                                                            SizeConfig
                                                                .heightMultiplier,
                                                        width: 10 *
                                                            SizeConfig
                                                                .widthMultiplier,
                                                        decoration: BoxDecoration(
                                                            shape: BoxShape
                                                                .rectangle,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            image: DecorationImage(
                                                                fit: BoxFit
                                                                    .cover,
                                                                image: NetworkImage(
                                                                    participant[
                                                                        "imageUrl"]))),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      '${participant["firstName"]} ${participant["lastName"]}',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      )
                                    : const Text("No participants",
                                        style: TextStyle(fontSize: 24)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(child: const CircularProgressIndicator());
        });
  }
}

/*
class AsyncMemoizer {
  runOnce(Future<void> Function() param0) {}
}
*/

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

Route _createRouteToUser(userId) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        ProfileScreenOtherUsers(userId),
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

class User {
  final String userId;

  const User(this.userId);
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
