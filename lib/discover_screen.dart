import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'group_details_screen.dart';
import 'create_group_screen.dart';

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
    return groups.get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: FloatingActionButton.extended(
          heroTag: "btn1",
          backgroundColor: Colors.white,
          icon: Icon(Icons.add_circle,
              color: Colors.black), //const FaIcon(FontAwesomeIcons.plus),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateGroupScreen()));
          },
          label: const Text("Create group",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ))),
      body: RefreshIndicator(
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
                    return Hero(
                        tag: doc.id,
                        child: Card(
                          semanticContainer: true,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 7),
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
                                    child: Image(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(
                                        (doc.data() as Map<String, dynamic>)[
                                                "groupPicture"]
                                            .toString(),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: AutoSizeText(
                                      (doc.data() as Map<String, dynamic>)[
                                              "groupName"]
                                          .toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => {
                              /*
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) {
                                    return const OpenContainerTransformDemo();
                                  },
                                ),
                              )*/

                              Navigator.of(context).push(_createRoute(Group(
                                doc.id,
                                groupName: (doc.data()
                                    as Map<String, dynamic>)["groupName"],
                                groupPicture: (doc.data()
                                    as Map<String, dynamic>)["groupPicture"],
                              )))
                            },
                          ),
                        ));
                  }).toList(),
                );
              }
              return const CircularProgressIndicator();
            }),
      ),
    );
  }
}

Route _createRoute(data) {
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

// Group Data class

class Group {
  final String id;
  final String groupName;
  final String groupPicture;
  const Group(this.id, {this.groupName = "0", this.groupPicture = "0"});
}

class _SmallerCard extends StatelessWidget {
  const _SmallerCard({
    required this.openContainer,
    required this.subtitle,
  });

  final VoidCallback openContainer;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _InkWellOverlay(
      openContainer: openContainer,
      height: 225,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            color: Colors.black38,
            height: 150,
            child: Center(
              child: Image.asset(
                'assets/placeholder_image.png',
                width: 80,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Title',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InkWellOverlay extends StatelessWidget {
  const _InkWellOverlay({
    this.openContainer,
    this.width,
    this.height,
    this.child,
  });

  final VoidCallback? openContainer;
  final double? width;
  final double? height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: InkWell(
        onTap: openContainer,
        child: child,
      ),
    );
  }
}
