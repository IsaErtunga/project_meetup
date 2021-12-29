import 'package:flutter/material.dart';
import 'package:project_meetup/user_authentication.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'group_details_screen.dart';

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

  dynamic myGroups1;
  /*Object?*/ //dynamic groups1;
  //final groupList = [];
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
            backgroundColor: const Color(0xffF8F8FA),
            body: Stack(
              clipBehavior: Clip.none, //overflow: Overflow.visible,
              // Stack(
              children: <Widget>[
                Container(
                  //height: 35 * SizeConfig.heightMultiplier,
                  //decoration: BoxDecoration(
                  height: 35 * SizeConfig.heightMultiplier,
                  decoration: BoxDecoration(
                    color: Colors.white,

                    // shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(40.0),
                      bottomLeft: Radius.circular(40.0),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 50.0,
                        right: 30.0,
                        top: 10 * SizeConfig.heightMultiplier),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              height: 11 * SizeConfig.heightMultiplier,
                              width: 22 * SizeConfig.widthMultiplier,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(data["imageUrl"]))),
                            ),
                            SizedBox(
                              width: 5 * SizeConfig.widthMultiplier,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  data["firstName"],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 3 * SizeConfig.textMultiplier,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 1 * SizeConfig.heightMultiplier,
                                ),
                                Row(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Image.network(
                                          "https://tethys.pnnl.gov/sites/default/files/styles/captioned_400xauto/public/taxonomy-images/Milan-Logo.png?itok=orAi9niZ",
                                          height:
                                              5 * SizeConfig.heightMultiplier,
                                          width: 5 * SizeConfig.widthMultiplier,
                                        ),
                                        SizedBox(
                                          width: 2 * SizeConfig.widthMultiplier,
                                        ),
                                        Text(
                                          "PoliMi",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                1.5 * SizeConfig.textMultiplier,
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
                //  ],
                // ),
                //),

                Padding(
                  padding:
                      EdgeInsets.only(top: 36.5 * SizeConfig.heightMultiplier),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    /*decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30.0),
                          topLeft: Radius.circular(30.0),
                        )),*/
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 30.0,
                                  top: 3 * SizeConfig.heightMultiplier),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    "Attended events",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            3 * SizeConfig.textMultiplier),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 3 * SizeConfig.heightMultiplier,
                            ),
                            Container(
                              height: 37 * SizeConfig.heightMultiplier,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                  _eventsAttendedCard(
                                      "https://github.com/slackvishal/flutter_traveler_profile_app/blob/master/assets/travelfive.png?raw=true",
                                      "https://github.com/slackvishal/flutter_traveler_profile_app/blob/master/assets/travelthree.png?raw=true",
                                      "https://github.com/slackvishal/flutter_traveler_profile_app/blob/master/assets/traveltwo.png?raw=true",
                                      "https://github.com/slackvishal/flutter_traveler_profile_app/blob/master/assets/travelsix.png?raw=true",
                                      "+18",
                                      "dsf"),
                                  _eventsAttendedCard(
                                      "https://github.com/slackvishal/flutter_traveler_profile_app/blob/master/assets/travelthree.png?raw=true",
                                      "https://github.com/slackvishal/flutter_traveler_profile_app/blob/master/assets/traveltwo.png?raw=true",
                                      "https://images.theconversation.com/files/271810/original/file-20190430-136810-yhoyzj.jpg?ixlib=rb-1.1.0&q=45&auto=format&w=754&fit=clip",
                                      "https://travel.usnews.com/static-travel/images/destinations/73/gettyimages-462922955_445x280.jpg",
                                      "+248",
                                      "Oh hell naw"),
                                  _eventsAttendedCard(
                                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzq5OMXCKBCkIYtC8O5J-GYSGH06IGapK0fQ&usqp=CAU",
                                      "https://mydivinevacation.com/wp-content/uploads/2019/01/Romantic-Travel.jpg",
                                      "https://images.theconversation.com/files/271810/original/file-20190430-136810-yhoyzj.jpg?ixlib=rb-1.1.0&q=45&auto=format&w=754&fit=clip",
                                      "https://travel.usnews.com/static-travel/images/destinations/73/gettyimages-462922955_445x280.jpg",
                                      "+118",
                                      "lel"),
                                  SizedBox(
                                    width: 10 * SizeConfig.widthMultiplier,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 3 * SizeConfig.heightMultiplier,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 30.0, right: 30.0),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    "My Groups",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            3 * SizeConfig.textMultiplier),
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
                              height: 4 * SizeConfig.heightMultiplier,
                            ),
                            Container(
                              height: 25 * SizeConfig.heightMultiplier,
                              child: FutureBuilder<QuerySnapshot>(
                                  future: users.get(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasError) {
                                      return const Text("Something went wrong");
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return GridView.count(
                                        scrollDirection: Axis.horizontal,
                                        crossAxisCount: 1,
                                        children: data["myGroups"]
                                            .map<Widget>((document) {
                                          print(document);
                                          groups.doc(document).get().then(
                                              (result) =>
                                                  myGroups1 = result.data());
                                          (groups.doc(document)).get().then(
                                              (result) => print(result.data()));
                                          /* print(myGroups1);*/

                                          // print(value.data()));

                                          // snapshot.data!.docs.map((doc) {
                                          return Hero(
                                              tag: groups.doc(document).id,
                                              child: Card(
                                                semanticContainer: true,
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                elevation: 5,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 7),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
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
                                                              // (document.data() as Map<
                                                              (myGroups1 as Map<
                                                                          String,
                                                                          dynamic>)[
                                                                      "groupPicture"]
                                                                  .toString(),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                              (myGroups1 as Map<
                                                                          String,
                                                                          dynamic>)[
                                                                      "groupName"]
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  onTap: () => {
                                                    Navigator.of(context).push(
                                                        _createRoute(Group(
                                                            document.id,
                                                            (document.data()
                                                                as Map<String,
                                                                    dynamic>))))
                                                  },
                                                ),
                                              ));
                                        }).toList(),
                                      );
                                    }
                                    return const CircularProgressIndicator();
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Text("loading");
      },
    );
  }
}

/*

                                         /* snapshot.data!.docs.map((doc),
                                          padding: const EdgeInsets.all(8),
                                          itemCount: groupList.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            return */
                                           
                                    children: snapshot.data!.docs.map((doc)

                                      data["myGroups"].map<Widget>((document) {
                                    return ListView(
                                        scrollDirection: Axis.horizontal,
                                        children:
                                            /*GestureDetector(onTap: () {
                                          print(document);
                                          users.doc(document).get().then(
                                              (value) => print(value.data()));
                                          child:*/
                                            /*<Widget>[
                                          Expanded(
                                              child:*/

                                            //groups.doc(document).get().then(
                                            //  (value) => print(value.data()));

                                            <Widget>[
                                          myGroupsCard(
                                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmiNYJz_0aKz92YhqV2mckEi_TktSVJtI_VQ&usqp=CAU",
                                              "oi"
                                              /* Text((document.data() as Map<
                                                          String,
                                                          dynamic>)["firstName"]
                                                      .toString())*/
                                              )
                                        ]);
                                    // ];
                                  }).toList(),
                                  // }).toList(),
                                  /*_myGroupsCard(
                                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShg0PCdhfH4L7qOHiCruP81hDrF80pIHFRwA&usqp=CAU",
                                      "Oh hell naw");
                                  _myGroupsCard(
                                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTBIIFXubuk_u_QPIMY4VmTAaupePAm54SwvA&usqp=CAU",
                                      "lel");}*/
                                  /* SizedBox(
                                            width:
                                                10 * SizeConfig.widthMultiplier,
                                          )
                                        ],*/
                                ),
                                SizedBox(
                                  height: 3 * SizeConfig.heightMultiplier,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ]));
        }
        return Text("loading");
      },
    );
  }*/

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
            borderRadius: BorderRadius.circular(2.0),
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

class Group {
  final String id;
  final Map groupData;

  const Group(this.id, this.groupData);
}


/*
 ElevatedButton(
          onPressed: () {
            context.read<UserAuthentication>().signOut();
          },
          child: const Text("Sign out"),
        ),
 */
