import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_meetup/users_page.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:project_meetup/chat_screen.dart';

import 'discover_screen.dart';

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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        icon: const FaIcon(FontAwesomeIcons.comments),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const UsersPage()));
        },
        label: const Text("Chat"),
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
                  tag: widget.group.groupData["groupName"],
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
              title: Text(
                widget.group.groupData["groupName"],
                style: const TextStyle(color: Colors.white, fontSize: 16),
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
                                onTap: () {},
                                child: Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  elevation: 5,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: const Text("hej"),
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
                            children: data["members"].map<Widget>((doc) {
                              return GestureDetector(
                                onTap: () {},
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

// Widgets used

/*
FutureBuilder<DocumentSnapshot>(
        future: groups.doc(widget.groupId).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return Text("Document does not exist");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;

            return Column(
              children: [
                ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: data["members"] != null
                        ? (data["members"].map<Widget>((member) {
                            return FutureBuilder<DocumentSnapshot>(
                              future: users.doc(member).get(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<DocumentSnapshot>
                                      userSnapshot) {
                                if (userSnapshot.hasError) {
                                  return Text("Something went wrong");
                                }

                                if (userSnapshot.hasData &&
                                    !userSnapshot.data!.exists) {
                                  return Text("Document does not exist");
                                }

                                if (userSnapshot.connectionState ==
                                    ConnectionState.done) {
                                  Map<String, dynamic> userData =
                                      userSnapshot.data!.data()
                                          as Map<String, dynamic>;
                                  return ListTile(
                                    title: Text(userData["firstName"]),
                                  );
                                }

                                return Text("Loading");
                              },
                            );
                          }).toList())
                        : ([])),
                Center(
                  child: Row(
                    children: [
                      Expanded(
                        /*1*/
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /*2*/
                            Container(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: const Text(
                                'Isa',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              'Sweden',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      /*3*/
                      Icon(
                        Icons.star,
                        color: Colors.red[500],
                      ),
                      const Text('41'),
                    ],
                  ),
                )
              ],
            );
          }

          return Text("loading");
        },
      ),
 */
