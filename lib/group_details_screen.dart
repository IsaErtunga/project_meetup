import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_meetup/chat_screen.dart';
import 'package:project_meetup/users_page.dart';

import 'discover_screen.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Group group;
  const GroupDetailsScreen(this.group, {Key? key}) : super(key: key);

  @override
  _GroupDetailsScreenState createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  CollectionReference groups = FirebaseFirestore.instance.collection('Groups');
  CollectionReference users = FirebaseFirestore.instance.collection('Users');

  final members = [
    "https://picsum.photos/200",
    "https://picsum.photos/200",
    "https://picsum.photos/200",
    "https://picsum.photos/200",
    "https://picsum.photos/200",
    "https://picsum.photos/200"
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
              background: Row(
                  children: members.map((member) {
                return Expanded(
                    child: CircleAvatar(
                  backgroundImage: NetworkImage(member),
                ));
              }).toList()),
              title: Text(
                widget.group.groupData["groupName"],
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          SliverFillRemaining(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(left: 10, top: 10),
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
                SizedBox(
                  height: 400,
                  width: 400,
                  child: Container(
                    margin: const EdgeInsets.all(40.0),
                    color: Colors.teal,
                  ),
                )
              ],
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
