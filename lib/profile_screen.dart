import 'package:flutter/material.dart';
import 'package:project_meetup/user_authentication.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

  const ProfileScreen({Key? key}) : super(key: key);
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  // User collection reference
  CollectionReference users = FirebaseFirestore.instance.collection('Users');

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
              children: <Widget>[
                Container(
                  height: 35 * SizeConfig.heightMultiplier,
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                                    /*SizedBox(
                                      width: 7 * SizeConfig.widthMultiplier,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Image.network(
                                          "https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/Instagram-Icon.png/1025px-Instagram-Icon.png",
                                          height:
                                              5 * SizeConfig.heightMultiplier,
                                          width: 5 * SizeConfig.widthMultiplier,
                                        ),
                                        SizedBox(
                                          width: 2 * SizeConfig.widthMultiplier,
                                        ),
                                        Text(
                                          "Insta",
                                          style: TextStyle(
                                            color: Colors.white60,
                                            fontSize:
                                                1.5 * SizeConfig.textMultiplier,
                                          ),
                                        ),
                                      ],
                                    )*/
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                        /*SizedBox(
                          height: 3 * SizeConfig.heightMultiplier,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text(
                                  "22.2K",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 3 * SizeConfig.textMultiplier,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Followers",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 1.9 * SizeConfig.textMultiplier,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                  "1243",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 3 * SizeConfig.textMultiplier,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Following",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 1.9 * SizeConfig.textMultiplier,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white60),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "EDIG PROFILE",
                                  style: TextStyle(
                                      color: Colors.white60,
                                      fontSize:
                                          1.8 * SizeConfig.textMultiplier),
                                ),
                              ),
                            ),
                          ],
                        ),*/
                      ],
                    ),
                  ),
                ),
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
                                            2.2 * SizeConfig.textMultiplier),
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
                                  _EventsAttendedCard(
                                      "https://github.com/slackvishal/flutter_traveler_profile_app/blob/master/assets/travelfive.png?raw=true",
                                      "https://github.com/slackvishal/flutter_traveler_profile_app/blob/master/assets/travelthree.png?raw=true",
                                      "https://github.com/slackvishal/flutter_traveler_profile_app/blob/master/assets/traveltwo.png?raw=true",
                                      "https://github.com/slackvishal/flutter_traveler_profile_app/blob/master/assets/travelsix.png?raw=true",
                                      "+18",
                                      "Can't be arsed"),
                                  _EventsAttendedCard(
                                      "https://github.com/slackvishal/flutter_traveler_profile_app/blob/master/assets/travelthree.png?raw=true",
                                      "https://github.com/slackvishal/flutter_traveler_profile_app/blob/master/assets/traveltwo.png?raw=true",
                                      "https://images.theconversation.com/files/271810/original/file-20190430-136810-yhoyzj.jpg?ixlib=rb-1.1.0&q=45&auto=format&w=754&fit=clip",
                                      "https://travel.usnews.com/static-travel/images/destinations/73/gettyimages-462922955_445x280.jpg",
                                      "+248",
                                      "Oh hell naw"),
                                  _EventsAttendedCard(
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
                                            2.2 * SizeConfig.textMultiplier),
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
                              height: 3 * SizeConfig.heightMultiplier,
                            ),
                            Container(
                              height: 20 * SizeConfig.heightMultiplier,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                  _myGroupsCard(
                                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmiNYJz_0aKz92YhqV2mckEi_TktSVJtI_VQ&usqp=CAU"),
                                  _myGroupsCard(
                                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShg0PCdhfH4L7qOHiCruP81hDrF80pIHFRwA&usqp=CAU"),
                                  _myGroupsCard(
                                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTBIIFXubuk_u_QPIMY4VmTAaupePAm54SwvA&usqp=CAU"),
                                  SizedBox(
                                    width: 10 * SizeConfig.widthMultiplier,
                                  )
                                ],
                              ),
                            ),
                            /*SizedBox(
                              height: 3 * SizeConfig.heightMultiplier,
                            ),
                            SizedBox(
                              height: 3 * SizeConfig.heightMultiplier,
                            ),
                            Container(
                              height: 37 * SizeConfig.heightMultiplier,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                  _EventsAttendedCard(
                                      "https://static.toiimg.com/photo/msid-76420833,width-96,height-65.cms",
                                      "https://travel.usnews.com/static-travel/images/destinations/73/gettyimages-462922955_445x280.jpg",
                                      "https://images.theconversation.com/files/271810/original/file-20190430-136810-yhoyzj.jpg?ixlib=rb-1.1.0&q=45&auto=format&w=754&fit=clip",
                                      "https://travel.usnews.com/static-travel/images/destinations/73/gettyimages-462922955_445x280.jpg",
                                      "+18",
                                      "Location 1"),
                                  _EventsAttendedCard(
                                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHVjpMi4RjrVqjy5zgSlXB0D558-ARM7-aAg&usqp=CAU",
                                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQJcT3Klpy3YpnUc8T3A5Cu4-ikzgDWxFLfzw&usqp=CAU",
                                      "https://images.theconversation.com/files/271810/original/file-20190430-136810-yhoyzj.jpg?ixlib=rb-1.1.0&q=45&auto=format&w=754&fit=clip",
                                      "https://travel.usnews.com/static-travel/images/destinations/73/gettyimages-462922955_445x280.jpg",
                                      "+248",
                                      "Location 2"),
                                  _EventsAttendedCard(
                                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzq5OMXCKBCkIYtC8O5J-GYSGH06IGapK0fQ&usqp=CAU",
                                      "https://mydivinevacation.com/wp-content/uploads/2019/01/Romantic-Travel.jpg",
                                      "https://images.theconversation.com/files/271810/original/file-20190430-136810-yhoyzj.jpg?ixlib=rb-1.1.0&q=45&auto=format&w=754&fit=clip",
                                      "https://travel.usnews.com/static-travel/images/destinations/73/gettyimages-462922955_445x280.jpg",
                                      "+118",
                                      "Location 3"),
                                  SizedBox(
                                    width: 10 * SizeConfig.widthMultiplier,
                                  ),
                                ],
                              ),
                            ),*/
                            SizedBox(
                              height: 3 * SizeConfig.heightMultiplier,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        }
        return Text("loading");
      },
    );
  }
}

_EventsAttendedCard(String asset1, String asset2, String asset3, String asset4,
    String more, String name) {
  return Padding(
    padding: const EdgeInsets.only(left: 40.0),
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

_myGroupsCard(String s) {
  return Padding(
    padding: const EdgeInsets.only(left: 40.0),
    child: Card(
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.0),
        child: Image.network(
          s,
          height: 20 * SizeConfig.heightMultiplier,
          width: 70 * SizeConfig.widthMultiplier,
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}

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

/*
 ElevatedButton(
          onPressed: () {
            context.read<UserAuthentication>().signOut();
          },
          child: const Text("Sign out"),
        ),
 */
