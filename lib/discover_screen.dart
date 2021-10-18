import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:project_meetup/group_details_screen.dart';

/// Stateful Widget for bottom navigation bar.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  CollectionReference groups = FirebaseFirestore.instance.collection('Groups');

  /// Groups read from database.
  final groupList = [];

  Future _refreshGroups(BuildContext context) async {
    print("hej");
    return groups.get();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refreshGroups(context),
      child: FutureBuilder<QuerySnapshot>(
          future: groups.get(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Something went wrong");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              return GridView.count(
                crossAxisCount: 2,
                children: snapshot.data!.docs.map((doc) {
                  return Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 5,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: GestureDetector(
                      child: Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: AspectRatio(
                                aspectRatio: 16 / 12,
                                child: Hero(
                                  tag: (doc.data()
                                          as Map<String, dynamic>)["groupName"]
                                      .toString(),
                                  child: Image(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(
                                      (doc.data() as Map<String, dynamic>)[
                                              "groupPicture"]
                                          .toString(),
                                    ),
                                  ),
                                )),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                  (doc.data()
                                          as Map<String, dynamic>)["groupName"]
                                      .toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GroupDetailsScreen(Group(
                                    doc.id,
                                    (doc.data() as Map<String, dynamic>))))),
                      },
                    ),
                  );
                }).toList(),
              );
            }
            return const CircularProgressIndicator();
          }),
    );
  }
}

// Group Data class

class Group {
  final String id;
  final Map groupData;

  const Group(this.id, this.groupData);
}

/*
         return ListView(
              children: snapshot.data.docs.map((doc) {
                return Card(
                  child: ListTile(
                    title: Text(doc.data()['title']),
                  ),
                );
              }).toList(),
            );

                        return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.data!.size,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: InkWell(
                      splashColor: Colors.blue.withAlpha(30),
                      borderRadius: BorderRadius.circular(3),
                      onTap: () {
                        print('Card tapped.');
                      },
                      child: Container(
                        width: 300,
                        height: 100,
                        child: Center(
                            child: Row(
                          children: const <Widget>[
                            Expanded(
                              child: Text('Card', textAlign: TextAlign.center),
                            ),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit
                                    .contain, // otherwise the logo will be tiny
                                child: FlutterLogo(),
                              ),
                            ),
                          ],
                        )),
                      ),
                    ),
                  );
                });

 */
