import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_meetup/create_event_screen.dart';
import 'package:project_meetup/event_details_screen.dart';
import 'package:project_meetup/chat_screen.dart';
import 'package:project_meetup/profile_screen_other_users.dart';
import 'package:firebase_auth/firebase_auth.dart' as fireauth;
import 'profile_screen.dart'; //for sizeconfig fun
import 'package:intl/intl.dart'; //to convert timestamp to a date in ddmmyy format

import 'discover_screen.dart';
import 'create_event_screen.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Group group;
  const GroupDetailsScreen(this.group, {Key? key}) : super(key: key);

  @override
  _GroupDetailsScreenState createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final fireauth.FirebaseAuth auth = fireauth.FirebaseAuth.instance;
  CollectionReference groups = FirebaseFirestore.instance.collection('Groups');
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final members = [
    "https://picsum.photos/200",
    "https://picsum.photos/200",
    "https://picsum.photos/200",
  ];

  void _addUserToGroup() async {
    var groupName = "";
    var groupPicture = "";
    List groupMembersList = [];

    var docSnapshot2 = await groups.doc(widget.group.id).get();
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
          'id': widget.group.id,
          'groupName': groupName,
          'groupPicture': groupPicture,
          'membersCount': groupMembersList.length
        }
      ])
    });
    //add user to group doc as member
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: groups.doc(widget.group.id).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return Text("Document does not exist");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> groupdata =
                snapshot.data!.data() as Map<String, dynamic>;
            return Scaffold(
                floatingActionButton: Container(
                  margin: const EdgeInsets.only(
                    left: 35,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton.extended(
                        backgroundColor: Colors.white,
                        icon: Icon(Icons.add_circle, color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CreateEventScreen(widget.group)));
                        },
                        label: const Text(
                          "Add event",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FloatingActionButton.extended(
                        backgroundColor: Colors.white,
                        icon: const FaIcon(FontAwesomeIcons.comments,
                            color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ChatScreen()));
                        },
                        label: const Text("Chat",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ],
                  ),
                ),
                body: CustomScrollView(
                    physics: BouncingScrollPhysics(),
                    slivers: <Widget>[
                      SliverAppBar(
                        backgroundColor: Colors
                            .black54, //Theme.of(context).colorScheme.primary,
                        forceElevated: true,
                        expandedHeight: 200,
                        pinned: true,
                        /*  shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30.0),
                            bottomRight: Radius.circular(30.0))),*/
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(left: 0, top: 0),
                            child: CircleAvatar(
                              radius: 80,
                              backgroundImage:
                                  NetworkImage(groupdata["groupPicture"]),
                            ),
                          ),
                          centerTitle: true,
                          titlePadding: EdgeInsets.only(top: 5.0),
                          title: AutoSizeText(
                            groupdata["groupName"],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            maxLines: 1,
                          ),
                        ),
                      ),
                      SliverFillRemaining(
                          hasScrollBody: false,
                          child: Container(
                              child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10),
                                  child: Column(children: [
                                    SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        width: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          border: Border.all(color: Colors.red),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: EdgeInsets.all(5),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(Icons.group_rounded,
                                                  color: Colors.red),
                                              SizedBox(width: 10),
                                              Text(
                                                  '${groupdata["members"].length.toString()} MEMBERS',
                                                  style: TextStyle(
                                                      color: Colors.red))
                                            ]),
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            2 * SizeConfig.heightMultiplier),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          "About",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                              fontSize: 3 *
                                                  SizeConfig.textMultiplier),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            1.5 * SizeConfig.heightMultiplier),
                                    Container(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            groupdata["groupDescription"],
                                            textAlign: TextAlign.left,
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            5 * SizeConfig.heightMultiplier),
                                    Row(children: <Widget>[
                                      Text(
                                        "Events",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            fontSize:
                                                3 * SizeConfig.textMultiplier),
                                      )
                                    ]),
                                    SizedBox(
                                      height: 1.5 * SizeConfig.heightMultiplier,
                                    ),
                                    Container(
                                      height: 134,
                                      width: double.infinity,
                                      child: groupdata["events"].isNotEmpty
                                          ? ListView(
                                              padding: const EdgeInsets.only(
                                                  top: 0,
                                                  bottom: 0,
                                                  right: 16,
                                                  left: 13),
                                              scrollDirection: Axis.horizontal,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              children: groupdata["events"]
                                                  .map<Widget>((hostedEvent) {
                                                return GestureDetector(
                                                  onTap: () => {
                                                    Navigator.of(context).push(
                                                        _createRoute(Event(
                                                            hostedEvent["id"])))
                                                  },
                                                  child: Hero(
                                                    tag: hostedEvent["id"],
                                                    child: SizedBox(
                                                      width: 280,
                                                      child: Stack(
                                                        children: <Widget>[
                                                          Container(
                                                            child: Row(
                                                              children: <
                                                                  Widget>[
                                                                const SizedBox(
                                                                  width: 48,
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .deepPurple
                                                                          .withOpacity(
                                                                              0.4),
                                                                      /*    border: Border.all(
                                                                color: Colors
                                                                    .greenAccent,
                                                                width: 1.5),*/
                                                                      borderRadius: const BorderRadius
                                                                              .all(
                                                                          Radius.circular(
                                                                              16.0)),
                                                                    ),
                                                                    child: Row(
                                                                      children: <
                                                                          Widget>[
                                                                        const SizedBox(
                                                                          width:
                                                                              48 + 24.0,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                Column(
                                                                              children: <Widget>[
                                                                                Align(
                                                                                  alignment: Alignment.centerLeft,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(top: 10),
                                                                                    child: Text(
                                                                                      (DateFormat.MMMEd().add_Hm().format(hostedEvent["eventTime"].toDate()).toString()),

                                                                                      //  maxLines: 1,
                                                                                      //overflow: TextOverflow.ellipsis,
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(
                                                                                        fontWeight: FontWeight.w400,
                                                                                        fontSize: 14,
                                                                                        letterSpacing: 0.27,
                                                                                        color: Colors.greenAccent,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Align(
                                                                                  alignment: Alignment.centerLeft,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(top: 2),
                                                                                    child: Text(
                                                                                      hostedEvent["eventName"].toString(),
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.27, color: Colors.white //const Color(0xF8FAFB),
                                                                                          ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Align(
                                                                                  alignment: Alignment.centerLeft,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(top: 5),
                                                                                    child: Row(
                                                                                      //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      //  crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: <Widget>[
                                                                                        Expanded(
                                                                                          child: Text(
                                                                                            '7 going',
                                                                                            textAlign: TextAlign.left,
                                                                                            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12, letterSpacing: 0.27, color: Colors.white //Color(0xF8FAFB),
                                                                                                ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 24,
                                                                      bottom:
                                                                          24,
                                                                      left: 16),
                                                              child: Row(
                                                                children: <
                                                                    Widget>[
                                                                  ClipRRect(
                                                                    borderRadius: const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            16.0)),
                                                                    child:
                                                                        AspectRatio(
                                                                      aspectRatio:
                                                                          1.0,
                                                                      child:
                                                                          Image(
                                                                        fit: BoxFit
                                                                            .fill,
                                                                        image:
                                                                            NetworkImage(
                                                                          hostedEvent["eventPicture"]
                                                                              .toString(),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            )
                                          : const Text(
                                              "No events hosted yet",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white30),
                                            ),
                                    ),
                                    SizedBox(
                                      height: 5 * SizeConfig.heightMultiplier,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          "Members",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                              fontSize: 3 *
                                                  SizeConfig.textMultiplier),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 3 * SizeConfig.heightMultiplier,
                                    ),
                                    Expanded(
                                      child: Container(
                                        height:
                                            50 * SizeConfig.heightMultiplier,
                                        child: groupdata["members"].isNotEmpty
                                            ? GridView(
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2,
                                                        mainAxisSpacing: 15,
                                                        crossAxisSpacing: 15,
                                                        childAspectRatio: 2.2),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                scrollDirection: Axis.vertical,
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                children: groupdata["members"]
                                                    .map<Widget>((member) {
                                                  return GestureDetector(
                                                    onTap: () => {
                                                      Navigator.of(context).push(
                                                          _createRouteToUser(
                                                              member["userId"]))
                                                    },
                                                    child: Card(
                                                      elevation: 0,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15.0)),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
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
                                                                color: Color(
                                                                    0xFF212121)
                                                                // Color(0xF8FAFB),
                                                                ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(5)),
                                                            Hero(
                                                              tag: member[
                                                                  "userId"],
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
                                                                        BorderRadius.circular(
                                                                            15),
                                                                    image: DecorationImage(
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        image: NetworkImage(
                                                                            member["profilePicture"]))),
                                                              ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              '${member["firstName"]} ${member["lastName"]}',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              )
                                            : const Text("No members",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white30)),
                                      ),
                                    ),
                                  ])))),
                    ]));
          }

          // TODO loading indicator
          return const Text("");
        });
  }
}

Route _createRoute(eventId) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        EventDetailsScreen(eventId),
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

class Event {
  final String eventId;

  const Event(this.eventId);
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
