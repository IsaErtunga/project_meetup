import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_meetup/create_event_screen.dart';
import 'package:project_meetup/event_details_screen.dart';
import 'package:project_meetup/users_page.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:project_meetup/chat_screen.dart';

import 'discover_screen.dart';
import 'create_event_screen.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Group group;
  const GroupDetailsScreen(this.group, {Key? key}) : super(key: key);

  @override
  _GroupDetailsScreenState createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  CollectionReference groups = FirebaseFirestore.instance.collection('Groups');
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final members = [
    "https://picsum.photos/200",
    "https://picsum.photos/200",
    "https://picsum.photos/200",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        margin: const EdgeInsets.only(
          left: 35,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              heroTag: "btn1",
              backgroundColor: Colors.black,
              icon: const FaIcon(FontAwesomeIcons.plus),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateEventScreen(widget.group)));
              },
              label: const Text("Add event"),
            ),
            FloatingActionButton.extended(
              heroTag: "btn2",
              backgroundColor: Colors.black,
              icon: const FaIcon(FontAwesomeIcons.comments),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChatScreen()));
              },
              label: const Text("Chat"),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            forceElevated: true,
            expandedHeight: 200,
            pinned: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(left: 0, top: 0),
                child: Hero(
                  tag: widget.group.id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image(
                        height: 150,
                        width: 150,
                        image: NetworkImage(
                            widget.group.groupData["groupPicture"])),
                  ),
                ),
              ),
              centerTitle: true,
              title: AutoSizeText(
                widget.group.groupData["groupName"],
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 1,
              ),
            ),
          ),
          SliverFillRemaining(
            child: FutureBuilder<DocumentSnapshot>(
              future: groups.doc(widget.group.id).get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                // If something went wrong
                if (snapshot.hasError) {
                  return const Text("Something went wrong");
                }

                // If document doesn't exist
                if (snapshot.hasData && !snapshot.data!.exists) {
                  return const Text("Document does not exist");
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;

                  // Return actual list
                  return Column(children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: const Text(
                        "Events",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    data["events"].isNotEmpty
                        ? GridView.count(
                            padding: const EdgeInsets.only(top: 0),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            children: data["events"].map<Widget>((doc) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .push(_createRoute(doc["id"]));
                                },
                                child: Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  elevation: 5,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: AspectRatio(
                                          aspectRatio: 16 / 12,
                                          child: Image(
                                            fit: BoxFit.fill,
                                            image: NetworkImage(doc["image"]),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          child: Center(
                                              child: Text(
                                        doc["eventName"],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ))),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : const Text(
                            "No events",
                            style: TextStyle(fontSize: 24),
                          ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: const Text(
                        "Members",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    data["members"].isNotEmpty
                        ? ListView(
                            padding: const EdgeInsets.only(top: 0),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: data["members"].map<Widget>((document) {
                              return GestureDetector(
                                onTap: () {
                                  print(document);
                                  users
                                      .doc(document)
                                      .get()
                                      .then((value) => print(value.data()));
                                },
                                child: SizedBox(
                                  height: 80,
                                  child: Card(
                                    semanticContainer: true,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    elevation: 5,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 7),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 15.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: const [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                "https://i.picsum.photos/id/555/200/200.jpg?hmac=SPdHg_AxaDTFgZCoJymemxudcniLOiP2P5k6T8Eb-kc"),
                                          ),
                                          Text('Isa Ertunga'),
                                          FaIcon(FontAwesomeIcons.arrowRight),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : const Text(
                            "No members",
                            style: TextStyle(fontSize: 24),
                          )
                  ]);
                }

                // TODO loading indicator
                return const Text("loading");
              },
            ),
          )
        ],
      ),
    );
  }
}

Route _createRoute(String eventId) {
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
