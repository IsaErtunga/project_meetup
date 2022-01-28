//import 'dart:html';
import 'dart:async';
import 'dart:ffi';
import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart'; //for timestamp to date and time conversion
import 'package:geocoding/geocoding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_meetup/discover_screen.dart';
import 'package:project_meetup/profile_screen.dart';
import 'package:uuid/uuid.dart';
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

  Color _iconColor = Colors.white;

  Future _refreshEvent(BuildContext context) async {
    return events.doc(widget.event.eventId).get();
  }

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  // final AsyncMemoizer _memoizer = AsyncMemoizer();

  String _eventAddress = "";
  String _eventAddressSecondLine = "";

  //Future<void> getEventAddress (Position position)
  //  List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude)

  Widget getTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0, right: 8.0, top: 20.0),
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
  void _testtest() {}

  void _addUserToGroup() async {
    var hostingGroupID = "";
    var groupName = "";
    var groupPicture = "";
    List groupMembersList = [];
    var docSnapshot = await events.doc(widget.event.eventId).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? eventdata =
          docSnapshot.data() as Map<String, dynamic>;
      hostingGroupID = eventdata['hostingGroup']['groupId'];
    }
    setState(() {
      _hostingGroupID = hostingGroupID;
      print(_hostingGroupID);

      //to do: refresh the profile screen
    });

    var docSnapshot2 = await groups.doc(_hostingGroupID).get();
    if (docSnapshot2.exists) {
      Map<String, dynamic>? groupsData =
          docSnapshot2.data() as Map<String, dynamic>;

      groupName = groupsData['groupName'];
      groupPicture = groupsData["groupPicture"];
      groupMembersList = groupsData["members"];
    }

    return users.doc(auth.currentUser!.uid).update({
      'myGroups': FieldValue.arrayUnion([
        {
          'id': _hostingGroupID,
          'groupName': groupName,
          'groupPicture': groupPicture,
          'membersCount': groupMembersList.length
        }
      ])
    });
    //add user to group doc as member
  }

  //bool _joinHasBeenPressed = false;

  Future<void> joinEventBatch() async {
    // Get user
    final userDataSnapshot = await users.doc(auth.currentUser!.uid).get();
    final userData = userDataSnapshot.data() as Map<String, dynamic>;

    // Get event
    final eventDataSnapshot = await events.doc(widget.event.eventId).get();
    final eventData = eventDataSnapshot.data() as Map<String, dynamic>;

    WriteBatch batch = FirebaseFirestore.instance.batch();

    // event document reference
    DocumentReference eventRef = FirebaseFirestore.instance
        .collection('Events')
        .doc(widget.event.eventId);
    batch.update(eventRef, {
      "participants": FieldValue.arrayUnion([
        {
          "firstName": userData["firstName"],
          "lastName": userData["lastName"],
          "profilePicture": userData["imageUrl"],
          "userId": userDataSnapshot.id
        }
      ])
    });

    DocumentReference newEventForUser = FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid);
    batch.update(newEventForUser, {
      "attendedEvents": FieldValue.arrayUnion([
        {
          "eventName": eventData["eventName"],
          "eventPicture": eventData["eventPicture"],
          "eventTime": eventData["dateTime"],
          "hostingGroup": eventData["hostingGroup"],
          "id": eventDataSnapshot.id,
          "participantsCount": eventData["participants"].length + 1
        }
      ])
    });

    return batch.commit();
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
              backgroundColor: Colors.black,
              body: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverAppBar(
                      backgroundColor:
                          Colors.black54, //Colors.deepPurple.withOpacity(0.6),
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
                                  right: 10,
                                  top: 3 * SizeConfig.heightMultiplier),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Flexible(
                                    child: Text(
                                      eventData["eventName"].toString(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          fontSize:
                                              3 * SizeConfig.heightMultiplier),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[800],
                                    child: IconButton(
                                      // disabledColor: Colors.white,

                                      //  padding: EdgeInsets.all(20),
                                      iconSize: 25,
                                      icon: Icon(Icons.favorite,
                                          color: _iconColor),
                                      onPressed: () {
                                        joinEventBatch();
                                        setState(() {
                                          if (_iconColor == Colors.white) {
                                            _iconColor = Colors.purple;
                                          } else {
                                            _iconColor = Colors.white;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 1.5 * SizeConfig.heightMultiplier),
                            Container(
                              height: 100,
                              // width: 200,
                              child: eventData["hostingGroup"].isNotEmpty
                                  ? SizedBox.expand(
                                      child: GestureDetector(
                                        onTap: () => {
                                          Navigator.of(context)
                                              .push(_createRouteToGroup(Group(
                                            eventData["hostingGroup"]
                                                ["groupId"],
                                          )))
                                        },
                                        child: SizedBox(
                                            height: 100,
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Hero(
                                                    tag: eventData[
                                                                'hostingGroup']
                                                            ['groupId']
                                                        .toString(),
                                                    child: CircleAvatar(
                                                      radius: 30,
                                                      backgroundImage:
                                                          NetworkImage(eventData[
                                                                      'hostingGroup']
                                                                  [
                                                                  'groupPicture']
                                                              .toString()),
                                                    ),
                                                  ),
                                                  SizedBox(width: 15),
                                                  SizedBox(
                                                    child: Text(
                                                        eventData['hostingGroup']
                                                                ['groupName']
                                                            .toString(),
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ),
                                                  SizedBox(width: 20),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            25)),
                                                            primary: Colors.red[
                                                                600], // Colors.white.withOpacity(0),
                                                            side: BorderSide(
                                                                color: Color(
                                                                    0xFFE53935),
                                                                width: 1.5)),
                                                    onPressed: () =>
                                                        {_addUserToGroup()},
                                                    child: const Text('JOIN',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  )
                                                ])),
                                      ),
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
                                              color: Colors.greenAccent,
                                              size: 20),
                                          SizedBox(width: 10),
                                          Text(
                                              (DateFormat.yMMMEd().format(
                                                      eventData["dateTime"]
                                                          .toDate()))
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.greenAccent)),
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
                                                  eventData["dateTime"]
                                                      .toDate()))
                                              .toString(),
                                          style: TextStyle(
                                              color: Colors.greenAccent),
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
                                        Icon(Icons.groups_rounded,
                                            color: Colors.greenAccent,
                                            size: 20),
                                        SizedBox(width: 10),
                                        Text(
                                            '${eventData["participants"].length.toString()} going',
                                            style: TextStyle(
                                                color: Colors.greenAccent))
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
                                        color: Colors.white,
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
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(eventData["description"],
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Colors.white)),
                                ),
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
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        fontSize:
                                            3 * SizeConfig.textMultiplier),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 3 * SizeConfig.heightMultiplier),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: SizedBox(
                                height: 300,
                                child: GoogleMap(
                                  myLocationEnabled: false,
                                  zoomGesturesEnabled: false,
                                  myLocationButtonEnabled: false,
                                  scrollGesturesEnabled: false,
                                  mapType: MapType.normal,
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                        eventData["location"].latitude,
                                        eventData["location"].longitude),
                                    zoom: 14.4746,
                                  ),
                                ),
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
                                        color: Colors.white,
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
                                child: eventData["participants"].isNotEmpty
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
                                        children: eventData["participants"]
                                            .map<Widget>((participant) {
                                          return GestureDetector(
                                            onTap: () => {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfileScreenOtherUsers(
                                                              participant[
                                                                  "userId"])))
                                            },
                                            child: Card(
                                              elevation: 0,
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
                                                  color: HexColor('#F8FAFB'),
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
                                                      tag:
                                                          participant["userId"],
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
                                                                        "profilePicture"]))),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      '${participant["firstName"]} ${participant["lastName"]}',
                                                      style: TextStyle(
                                                          color: Colors.black,
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

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
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
