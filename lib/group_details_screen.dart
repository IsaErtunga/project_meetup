import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  CollectionReference users = FirebaseFirestore.instance.collection('Users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        icon: const FaIcon(FontAwesomeIcons.comments),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ChatScreen()));
        },
        label: const Text("Chat"),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.group.groupData["groupName"]),
              background: Hero(
                tag: widget.group.groupData["groupName"],
                child: Image(
                    fit: BoxFit.fill,
                    image:
                        NetworkImage(widget.group.groupData["groupPicture"])),
              ),
            ),
          ),
          SliverFillRemaining(
            child: Column(
              children: List<int>.generate(6, (index) => index)
                  .map((index) => Container(
                        height: 40,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: Text(widget.group.groupData["groupName"]),
                      ))
                  .toList(),
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
