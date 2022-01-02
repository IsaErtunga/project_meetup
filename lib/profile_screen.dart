import 'package:flutter/material.dart';
import 'package:project_meetup/theme_profile_screen.dart';
import 'package:project_meetup/user_authentication.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'group_details_screen.dart';
import 'discover_screen.dart';
//import 'theme_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  // User collection reference
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference groups = FirebaseFirestore.instance.collection('Groups');
  CollectionReference events = FirebaseFirestore.instance.collection('Events');

  Future _refreshGroups(BuildContext context) async {
    return groups.get();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(auth.currentUser!.uid).get(),
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

          return Scaffold(
            backgroundColor: Colors.white, //const Color(0xffF8F8FA),
            body: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.white, //const Color(0xffF8F8FA),
                  forceElevated: true,
                  expandedHeight: 200,
                  //s  collapsedHeight: 70,
                  pinned: false,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(30))),
                  flexibleSpace: FlexibleSpaceBar(
                    /*centerTitle: false,
                     titlePadding:
                        EdgeInsetsDirectional.only(start: 5, bottom: 20),
                    title: Column(
                      children: <Widget>[*/
                    background: Container(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 40.0,
                            right: 30.0,
                            top: 10 * SizeConfig.heightMultiplier),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  height: 11 * SizeConfig.heightMultiplier,
                                  width: 21 * SizeConfig.widthMultiplier,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(30),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image:
                                              NetworkImage(data["imageUrl"]))),
                                ),
                                SizedBox(
                                  width: 5 * SizeConfig.widthMultiplier,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${data["firstName"]} ${data["lastName"]}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              3 * SizeConfig.textMultiplier,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5),
                                    ),
                                    Text('@${data["userName"]}',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize:
                                                2 * SizeConfig.textMultiplier)),
                                    SizedBox(
                                      height: 2 * SizeConfig.heightMultiplier,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              data["University"],
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 1.5 *
                                                    SizeConfig.textMultiplier,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  /*  ],
                    ),
                  ),*/
                ),
                SliverFillRemaining(
                  child: Container(
                    //    SingleChildScrollView(
                    //physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                                left: 10.0,
                                top: 3 * SizeConfig.heightMultiplier),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Attended events",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      fontSize: 3 * SizeConfig.textMultiplier),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 3 * SizeConfig.heightMultiplier,
                          ),
                          Container(
                            height: 134,
                            width: double.infinity,
                            child: data["attendedEvents"].isNotEmpty
                                ? ListView(
                                    padding: const EdgeInsets.only(
                                        top: 0, bottom: 0, right: 16, left: 16),
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    children: data["attendedEvents"]
                                        .map<Widget>((document) {
                                      return FutureBuilder<DocumentSnapshot>(
                                          future: events.doc(document).get(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<DocumentSnapshot>
                                                  snapshot) {
                                            if (snapshot.hasError) {
                                              return Text(
                                                  "Something went wrong");
                                            }

                                            if (snapshot.hasData &&
                                                !snapshot.data!.exists) {
                                              return Text(
                                                  "Document does not exist");
                                            }

                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              Map<String, dynamic> eventData =
                                                  snapshot.data!.data()
                                                      as Map<String, dynamic>;
                                              return SizedBox(
                                                width: 280,
                                                child: Stack(
                                                  children: <Widget>[
                                                    Container(
                                                      child: Row(
                                                        children: <Widget>[
                                                          const SizedBox(
                                                            width: 48,
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: HexColor(
                                                                    '#F8FAFB'),
                                                                borderRadius:
                                                                    const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            16.0)),
                                                              ),
                                                              child: Row(
                                                                children: <
                                                                    Widget>[
                                                                  const SizedBox(
                                                                    width: 48 +
                                                                        24.0,
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      child:
                                                                          Column(
                                                                        children: <
                                                                            Widget>[
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.centerLeft,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(top: 10),
                                                                              child: Text(
                                                                                (DateFormat.MMMEd().add_Hm().format(eventData["Date_Time"].toDate()).toString()),

                                                                                //  maxLines: 1,
                                                                                //overflow: TextOverflow.ellipsis,
                                                                                textAlign: TextAlign.left,
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.w400,
                                                                                  fontSize: 14,
                                                                                  letterSpacing: 0.27,
                                                                                  color: Colors.red[900],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.centerLeft,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(top: 2),
                                                                              child: Text(
                                                                                eventData["eventName"].toString(),
                                                                                textAlign: TextAlign.left,
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontSize: 16,
                                                                                  letterSpacing: 0.27,
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.centerLeft,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(top: 5),
                                                                              child: Row(
                                                                                //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                //  crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: <Widget>[
                                                                                  Expanded(
                                                                                    child: Text(
                                                                                      'by ${eventData["hostingGroup"].toString()}',
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(
                                                                                        fontWeight: FontWeight.w300,
                                                                                        fontSize: 12,
                                                                                        letterSpacing: 0.27,
                                                                                        color: Colors.blueGrey[700],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const Expanded(
                                                                            child:
                                                                                SizedBox(),
                                                                          ),
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.centerRight,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(right: 10, bottom: 10),
                                                                              child: Column(
                                                                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                //crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: <Widget>[
                                                                                  Container(
                                                                                    child: Text(
                                                                                      '${eventData["attendants_count"].toString()} going',
                                                                                      //  textAlign: TextAlign.right,
                                                                                      style: TextStyle(
                                                                                        fontWeight: FontWeight.w300,
                                                                                        fontSize: 12,
                                                                                        letterSpacing: 0.27,
                                                                                        color: Colors.blueGrey[600],
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
                                                                bottom: 24,
                                                                left: 16),
                                                        child: Row(
                                                          children: <Widget>[
                                                            ClipRRect(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                          .all(
                                                                      Radius.circular(
                                                                          16.0)),
                                                              child:
                                                                  AspectRatio(
                                                                aspectRatio:
                                                                    1.0,
                                                                child: Image(
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  image:
                                                                      NetworkImage(
                                                                    eventData[
                                                                            "eventPicture"]
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
                                              );
                                            }
                                            return Text("loading");
                                          });
                                    }).toList(),
                                  )
                                : const Text(
                                    "No attended events",
                                    style: TextStyle(fontSize: 24),
                                  ),
                          ),
                          SizedBox(
                            width: 10 * SizeConfig.widthMultiplier,
                          ),
                          SizedBox(
                            height: 3 * SizeConfig.heightMultiplier,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0, right: 30.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "My Groups",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      fontSize: 3 * SizeConfig.textMultiplier),
                                ),
                                Spacer(),
                                Text(
                                  "View All",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize:
                                          1.7 * SizeConfig.textMultiplier),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 1.5 * SizeConfig.heightMultiplier,
                          ),
                          Expanded(
                            child: Container(
                              height: 300 * SizeConfig.heightMultiplier,
                              child: data["myGroups"].isNotEmpty
                                  ? GridView(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 32.0,
                                        crossAxisSpacing: 32.0,
                                        childAspectRatio: 0.8,
                                      ),
                                      scrollDirection: Axis.vertical,
                                      padding: const EdgeInsets.all(8),
                                      physics: const BouncingScrollPhysics(),
                                      children: data["myGroups"]
                                          .map<Widget>((document) {
                                        return FutureBuilder<DocumentSnapshot>(
                                            future: groups.doc(document).get(),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<DocumentSnapshot>
                                                    snapshot) {
                                              if (snapshot.hasError) {
                                                return Text(
                                                    "Something went wrong");
                                              }

                                              if (snapshot.hasData &&
                                                  !snapshot.data!.exists) {
                                                return Text(
                                                    "Document does not exist");
                                              }

                                              if (snapshot.connectionState ==
                                                  ConnectionState.done) {
                                                Map<String, dynamic> groupData =
                                                    snapshot.data!.data()
                                                        as Map<String, dynamic>;

                                                return Flexible(
                                                    child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  //onTap: callback,
                                                  child: GestureDetector(
                                                    child: SizedBox(
                                                      height: 280,
                                                      child: Stack(
                                                        alignment:
                                                            AlignmentDirectional
                                                                .bottomCenter,
                                                        children: <Widget>[
                                                          Container(
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: HexColor(
                                                                          '#F8FAFB'),
                                                                      borderRadius: const BorderRadius
                                                                              .all(
                                                                          Radius.circular(
                                                                              16.0)),
                                                                      // border: new Border.all(
                                                                      //     color: DesignCourseAppTheme.notWhite),
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      children: <
                                                                          Widget>[
                                                                        Expanded(
                                                                          child:
                                                                              Container(
                                                                            child:
                                                                                Column(
                                                                              children: <Widget>[
                                                                                //  Expanded(
                                                                                Align(
                                                                                  alignment: Alignment.centerLeft,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                                                                                    child: Text(
                                                                                      groupData["groupName"].toString(),
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontSize: 16,
                                                                                        letterSpacing: 0.27,
                                                                                        color: ProfileTheme.darkerText,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),

                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: <Widget>[
                                                                                      Text(
                                                                                        '${groupData['memberAmount'].toString()} members',
                                                                                        textAlign: TextAlign.left,
                                                                                        style: TextStyle(
                                                                                          fontWeight: FontWeight.w300,
                                                                                          fontSize: 12,
                                                                                          letterSpacing: 0.27,
                                                                                          color: Colors.blueGrey[700],
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              48,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 48,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 24,
                                                                      right: 16,
                                                                      left: 16),
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius: const BorderRadius
                                                                          .all(
                                                                      Radius.circular(
                                                                          16.0)),
                                                                  boxShadow: <
                                                                      BoxShadow>[
                                                                    BoxShadow(
                                                                        color: ProfileTheme
                                                                            .grey
                                                                            .withOpacity(
                                                                                0.8),
                                                                        offset: const Offset(
                                                                            0.0,
                                                                            0.0),
                                                                        blurRadius:
                                                                            6.0),
                                                                  ],
                                                                ),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius: const BorderRadius
                                                                          .all(
                                                                      Radius.circular(
                                                                          16.0)),
                                                                  child:
                                                                      AspectRatio(
                                                                    aspectRatio:
                                                                        1.28,
                                                                    child:
                                                                        Image(
                                                                      fit: BoxFit
                                                                          .fill,
                                                                      image: NetworkImage(
                                                                          groupData['groupPicture']
                                                                              .toString()),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    onTap: () => {
                                                      Navigator.of(context).push(
                                                          _createRoute(Group(
                                                              document,
                                                              snapshot.data!
                                                                      .data()
                                                                  as Map<String,
                                                                      dynamic>)))
                                                    },
                                                  ),
                                                ));
                                              }
                                              return Text("loading");
                                            });
                                      }).toList(),
                                    )
                                  : const Text(
                                      "No groups",
                                      style: TextStyle(fontSize: 24),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //  ),
              ],
            ),
          );
        }
        return Text("loading");
      },
    );
  }
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

_eventsAttendedCard(String asset1, String asset2, String asset3, String asset4,
    String more, String name) {
  return Padding(
    padding: const EdgeInsets.only(left: 20.0),
    child: Card(
      elevation: 12,
      child: Container(
        height: 2.3 * SizeConfig.imageSizeMultiplier,
        width: 60 * SizeConfig.widthMultiplier,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.grey, width: 0.2)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        asset1,
                        height: 27 * SizeConfig.imageSizeMultiplier,
                        width: 27 * SizeConfig.imageSizeMultiplier,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Spacer(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        asset2,
                        height: 27 * SizeConfig.imageSizeMultiplier,
                        width: 27 * SizeConfig.imageSizeMultiplier,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 1 * SizeConfig.heightMultiplier,
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        asset3,
                        height: 27 * SizeConfig.imageSizeMultiplier,
                        width: 27 * SizeConfig.imageSizeMultiplier,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Spacer(),
                    Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            asset4,
                            height: 27 * SizeConfig.imageSizeMultiplier,
                            width: 27 * SizeConfig.imageSizeMultiplier,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          child: Container(
                            height: 27 * SizeConfig.imageSizeMultiplier,
                            width: 27 * SizeConfig.imageSizeMultiplier,
                            decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Center(
                              child: Text(
                                more,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 2.5 * SizeConfig.textMultiplier,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 10.0, top: 2 * SizeConfig.heightMultiplier),
                child: Text(
                  name,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 2 * SizeConfig.textMultiplier,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

myGroupsCard(var groupimage, var groupName) {
  return <Widget>[
    Card(
      child: Container(
        height: 2.3 * SizeConfig.imageSizeMultiplier,
        width: 40 * SizeConfig.widthMultiplier,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          //border: Border.all(color: Colors.grey, width: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        groupimage,
                        height: 30 * SizeConfig.imageSizeMultiplier,
                        width: 35 * SizeConfig.imageSizeMultiplier,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 10.0, top: 2 * SizeConfig.heightMultiplier),
                child: Text(
                  groupName,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 2 * SizeConfig.textMultiplier,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ];
}

/*return Padding(
    padding: const EdgeInsets.only(left: 20.0),
    child: Card(
      child: Container(
        height: 2.3 * SizeConfig.imageSizeMultiplier,
        width: 40 * SizeConfig.widthMultiplier,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          //border: Border.all(color: Colors.grey, width: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        groupimage,
                        height: 30 * SizeConfig.imageSizeMultiplier,
                        width: 35 * SizeConfig.imageSizeMultiplier,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 10.0, top: 2 * SizeConfig.heightMultiplier),
                child: Text(
                  groupName,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 2 * SizeConfig.textMultiplier,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}*/

class SizeConfig {
  static double _screenWidth = 1;
  static double _screenHeight = 1;
  static double _blockSizeHorizontal = 0;
  static double _blockSizeVertical = 0;

  static double textMultiplier = 1;
  static double imageSizeMultiplier = 1;
  static double heightMultiplier = 1;
  static double widthMultiplier = 1;
  static bool isPortrait = true;
  static bool isMobilePortrait = false;

  void init(BoxConstraints constraints, Orientation orientation) {
    if (orientation == Orientation.portrait) {
      _screenWidth = constraints.maxWidth;
      _screenHeight = constraints.maxHeight;
      isPortrait = true;
      if (_screenWidth < 450) {
        isMobilePortrait = true;
      }
    } else {
      _screenWidth = constraints.maxHeight;
      _screenHeight = constraints.maxWidth;
      isPortrait = false;
      isMobilePortrait = false;
    }

    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _screenHeight / 100;

    textMultiplier = _blockSizeVertical;
    imageSizeMultiplier = _blockSizeHorizontal;
    heightMultiplier = _blockSizeVertical;
    widthMultiplier = _blockSizeHorizontal;

    print(_blockSizeHorizontal);
    print(_blockSizeVertical);
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

/*
 ElevatedButton(
          onPressed: () {
            context.read<UserAuthentication>().signOut();
          },
          child: const Text("Sign out"),
        ),
 */
