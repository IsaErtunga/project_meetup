import 'dart:collection';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:project_meetup/attended_events_all.dart';
import 'package:project_meetup/theme_profile_screen.dart';
import 'package:project_meetup/user_authentication.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; //to convert timestamp to a date in ddmmyy format
import 'group_details_screen.dart';
import 'discover_screen.dart';
import 'package:filter_list/filter_list.dart';
import 'event_details_screen.dart';
import 'editable_profile_screen.dart';
// import 'choose_interests.dart';
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

  Future _refreshInterests(BuildContext context) async {
    return users.get();
  }

  final _socialLevelsText = [
    "Couch potatoe ",
    "Dancing Queen",
    "Social Butterfly",
    "BNOC"
  ];

  final _stepCircleRadius = 12.0;

  final _socialProgressViewHeight = 100.0;

  Color _activeColor = Colors.amber;

  Color _inactiveColor = Color(0xFF303030); //0xFF424242

  TextStyle _headerStyle =
      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);

  TextStyle _stepStyle = TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold);

  late Size _safeAreaSize;

  socialProgressView _getStepProgress(Map<String, dynamic> data) {
    int _socialProgressIndex = 0;
    int attendedEventsAmount = data["attendedEvents"].length;

    if (attendedEventsAmount >= 0) {
      if (attendedEventsAmount <= 5) {
        _socialProgressIndex = 1;
      }
      if (attendedEventsAmount <= 10 && attendedEventsAmount > 5) {
        _socialProgressIndex = 2;
      }
      if (attendedEventsAmount <= 20 && attendedEventsAmount > 10) {
        _socialProgressIndex = 3;
      }
      if (attendedEventsAmount > 20) {
        _socialProgressIndex = 4;
      }
    }

    return socialProgressView(
      _socialLevelsText,
      _socialProgressIndex,
      _socialProgressViewHeight,
      _safeAreaSize.width,
      _stepCircleRadius,
      _activeColor,
      _inactiveColor,
      _headerStyle,
      _stepStyle,
      decoration: BoxDecoration(color: Colors.black),
      padding: EdgeInsets.only(
        top: 16.0,
        left: 5.0,
        right: 25.0,
      ),
    );
  }

/*
  List<String> allInterestsList = [
    "Music/Dance/Club",
    "Sports & Fitness",
    "Travel & Outdoors",
    "Science & Tech"
  ];  */

  static List<String> selectedInterestsList = [];

  Future<void> addInterests() {
    return users
        .doc(auth.currentUser!.uid)
        .update({'myInterests': selectedInterestsList});
  }
  /*
  void _openInterestsFilterDialog() async {
    await FilterListDialog.display<String>(context,
        backgroundColor: Colors.white,
        applyButonTextBackgroundColor: Colors.black,
        controlButtonTextStyle:
            TextStyle(color: Colors.black, backgroundColor: Colors.white),
        listData: allInterestsList,
        selectedListData: selectedInterestsList,
        height: 480,
        headlineText: "Choose your Interests",
        hideHeaderText: true,
        hideSelectedTextCount: true,
        searchFieldHintText: "Search Here", choiceChipLabel: (item) {
      return item;
    }, validateSelectedItem: (list, val) {
      return list!.contains(val);
    }, onItemSearch: (list, text) {
      if (list!.any(
          (element) => element.toLowerCase().contains(text.toLowerCase()))) {
        return list
            .where(
                (element) => element.toLowerCase().contains(text.toLowerCase()))
            .toList();
      } else {
        return [];
      }
    }, onApplyButtonClick: (list) {
      if (list != null) {
        setState(
          () {
            selectedInterestsList = List.from(list);
            addInterests();
          },
        );
      }
      Navigator.pop(context);
    });
  }
  */

  _showInterestsDialog() async {
    await Future.delayed(
      Duration(microseconds: 1),
    );
    selectedInterestsList.clear();
    showDialog(
        barrierColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return BackdropFilter(
              child: Dialog(
                //insetPadding: EdgeInsets.all(0),
                backgroundColor: Colors.transparent,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 250,
                        minWidth: double.infinity,
                        maxHeight: double.infinity,
                      ),
                      padding: EdgeInsets.only(right: 8, left: 8, bottom: 15),
                      width: double.infinity,
                      //height: 300,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white60),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 10, top: 10),
                                child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        addInterests();
                                      });

                                      Navigator.pop(context);
                                      // _refreshInterests(context);
                                    },

                                    // _openInterestsFilterDialog,
                                    style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        primary: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15))),
                                    child: const Text('APPLY',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold))),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              child: Wrap(
                                spacing: 5.0,
                                runSpacing: 3.0,
                                children: <Widget>[
                                  filterChipWidget(
                                      chipName: 'Music/Dance/Club'),
                                  filterChipWidget(
                                      chipName: 'Sports & Fitness'),
                                  filterChipWidget(
                                      chipName: 'Travel & Outdoors'),
                                  filterChipWidget(chipName: 'Science & Tech'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        top: -100,
                        child: Image(
                            image: ExactAssetImage(
                                'images/InterestsSelection.png'),
                            width: 150,
                            height: 150)),
                  ],
                ),
              ),
              filter: ImageFilter.blur(
                sigmaX: 6,
                sigmaY: 6,
              ));
        });
  }

  void _navigateAndDisplay(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(builder: (context) => const EditableProfileScreen()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // CollectionReference users = FirebaseFirestore.instance.collection('users');
    var mediaQD = MediaQuery.of(context);
    _safeAreaSize = mediaQD.size;

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

          /*  var test = data['attendedEvents'].toList(); //.values.toList();
          print(test);

          test.sort((a, b) {
            b.value['eventTime'].compareTo(a.value['eventTime']);
          });
          print(test);
           var test2 = test.map((a) => {a.key: a.value}).toList();
          print(test2); */

          return Scaffold(
            backgroundColor: Colors.black,
            //const Color(0xffF8F8FA),
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverAppBar(
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      onPressed: () => {_navigateAndDisplay(context)},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        context.read<UserAuthentication>().signOut();
                      },
                    ),
                  ],
                  leading: BackButton(color: Colors.white
                      // icon: Icon(Icons.arrow_back, color: Colors.black),
                      // onPressed: () => Navigator.of(context).pop(),
                      ),
                  backgroundColor: Colors.black, //const Color(0xffF8F8FA),
                  forceElevated: false,
                  expandedHeight: 200,
                  collapsedHeight: 200,
                  pinned: true,
                  /*  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(30))),*/
                  flexibleSpace: FlexibleSpaceBar(
                    /*centerTitle: false,
                     titlePadding:
                        EdgeInsetsDirectional.only(start: 5, bottom: 20),
                    title: Column(
                      children: <Widget>[*/
                    background: Container(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 50.0,
                            right: 30.0,
                            top: 8 * SizeConfig.heightMultiplier),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Hero(
                                  tag: 'tag',
                                  child: Container(
                                    height: 11 * SizeConfig.heightMultiplier,
                                    width: 21 * SizeConfig.widthMultiplier,
                                    decoration: BoxDecoration(
                                        color: Colors.white24,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(30),
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                                data["imageUrl"]))),
                                  ),
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
                                          color: Colors.white,
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
                                              data["university"],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 1.5 *
                                                    SizeConfig.textMultiplier,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 2 * SizeConfig.widthMultiplier),
                            Expanded(
                              child: Container(
                                  height: 50, child: _getStepProgress(data)),
                            )
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
                  // child: SingleChildScrollView(
                  // physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            left: 10.0,
                          ),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "MY INTERESTS",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    fontSize: 3 * SizeConfig.textMultiplier),
                              ),
                              Spacer(),
                              ElevatedButton(
                                  onPressed: _showInterestsDialog,
                                  // _openInterestsFilterDialog,
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15))),
                                  child: const Text('EDIT',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 1.5 * SizeConfig.heightMultiplier,
                        ),
                        Container(
                          height: 40,
                          width: double.infinity,
                          child: data["myInterests"].isNotEmpty
                              ? ListView(
                                  scrollDirection: Axis.horizontal,
                                  physics: BouncingScrollPhysics(),
                                  padding: const EdgeInsets.only(
                                      top: 0, bottom: 0, right: 16, left: 13),
                                  children: data["myInterests"]
                                      .map<Widget>((interest) {
                                    //    SizedBox(width: 10);
                                    return Container(
                                        padding: EdgeInsets.only(right: 12),
                                        child: Chip(
                                          backgroundColor: Colors.black,
                                          side: BorderSide(
                                              color: Colors.white, width: 1),
                                          label: Text(
                                            interest.toString(),
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ));

                                    /*Align(
                                        child: DecoratedBox(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 4),
                                                color: Colors.black,
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(16.0))),
                                            child: TextButton(
                                              onPressed: () {},
                                              child: Text(
                                                interest.toString(),
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )),
                                      );*/
                                  }).toList(),
                                )
                              : const Text("No interests chosen yet",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white30)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 10.0, top: 3 * SizeConfig.heightMultiplier),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "ATTENDED EVENTS",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    fontSize: 3 * SizeConfig.textMultiplier),
                              ),
                              /*      Spacer(),
                                OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AttendedEventsScreen()),
                                      );
                                    },
                                    style: ButtonStyle(),
                                    child: const Text('view all',
                                        style: TextStyle(color: Colors.black))),*/
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
                                      top: 0, bottom: 0, right: 16, left: 13),
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  children: data["attendedEvents"]
                                      .map<Widget>((attendedEvent) {
                                    return GestureDetector(
                                      onTap: () => {
                                        Navigator.of(context).push(
                                            _createRouteEvents(
                                                Event(attendedEvent["id"])))
                                      },
                                      child: Hero(
                                        tag: attendedEvent["id"],
                                        child: SizedBox(
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
                                                          color: Colors
                                                              .deepPurple
                                                              .withOpacity(0.4),
                                                          /*    border: Border.all(
                                                                color: Colors
                                                                    .greenAccent,
                                                                width: 1.5),*/
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          16.0)),
                                                        ),
                                                        child: Row(
                                                          children: <Widget>[
                                                            const SizedBox(
                                                              width: 48 + 24.0,
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                child: Column(
                                                                  children: <
                                                                      Widget>[
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(top: 10),
                                                                        child:
                                                                            Text(
                                                                          (DateFormat.MMMEd()
                                                                              .add_Hm()
                                                                              .format(attendedEvent["eventTime"].toDate())
                                                                              .toString()),

                                                                          //  maxLines: 1,
                                                                          //overflow: TextOverflow.ellipsis,
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            fontSize:
                                                                                14,
                                                                            letterSpacing:
                                                                                0.27,
                                                                            color:
                                                                                Colors.greenAccent,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(top: 2),
                                                                        child:
                                                                            Text(
                                                                          attendedEvent["eventName"]
                                                                              .toString(),
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontSize:
                                                                                16,
                                                                            letterSpacing:
                                                                                0.27,
                                                                            color:
                                                                                HexColor('#F8FAFB'),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(top: 5),
                                                                        child:
                                                                            Row(
                                                                          //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          //  crossAxisAlignment: CrossAxisAlignment.center,
                                                                          children: <
                                                                              Widget>[
                                                                            Expanded(
                                                                              child: Text(
                                                                                'by ${attendedEvent["hostingGroup"].toString()}',
                                                                                textAlign: TextAlign.left,
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.w300,
                                                                                  fontSize: 12,
                                                                                  letterSpacing: 0.27,
                                                                                  color: HexColor('#F8FAFB'),
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
                                                                          Alignment
                                                                              .centerRight,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            right:
                                                                                10,
                                                                            bottom:
                                                                                10),
                                                                        child:
                                                                            Column(
                                                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          //crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: <
                                                                              Widget>[
                                                                            Container(
                                                                              child: Text(
                                                                                '7 going',
                                                                                //  textAlign: TextAlign.right,
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.w300,
                                                                                  fontSize: 12,
                                                                                  letterSpacing: 0.27,
                                                                                  color: HexColor('#F8FAFB'),
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
                                                      const EdgeInsets.only(
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
                                                        child: AspectRatio(
                                                          aspectRatio: 1.0,
                                                          child: Image(
                                                            fit: BoxFit.fill,
                                                            image: NetworkImage(
                                                              attendedEvent[
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
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              : const Text("No events attended yet",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white30)),
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
                                "MY GROUPS",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    fontSize: 3 * SizeConfig.textMultiplier),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 1.5 * SizeConfig.heightMultiplier,
                        ),
                        Container(
                          child: data["myGroups"].isNotEmpty
                              ? GridView(
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 32.0,
                                    crossAxisSpacing: 32.0,
                                    childAspectRatio: 0.8,
                                  ),
                                  scrollDirection: Axis.vertical,
                                  padding: const EdgeInsets.all(8),
                                  physics: NeverScrollableScrollPhysics(),
                                  children:
                                      data["myGroups"].map<Widget>((myGroups) {
                                    return Container(
                                      //onTap: callback,
                                      child: GestureDetector(
                                        onTap: () => {
                                          Navigator.of(context)
                                              .push(_createRoute(Group(
                                            myGroups["id"],
                                          )))
                                        },
                                        child: SizedBox(
                                          height: 280,
                                          child: Stack(
                                            alignment: AlignmentDirectional
                                                .bottomCenter,
                                            children: <Widget>[
                                              Container(
                                                child: Column(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.grey
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          16.0)),
                                                          // border: new Border.all(
                                                          //     color: DesignCourseAppTheme.notWhite),
                                                        ),
                                                        child: Column(
                                                          children: <Widget>[
                                                            Expanded(
                                                              child: Container(
                                                                child: Column(
                                                                  children: <
                                                                      Widget>[
                                                                    //  Expanded(
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                16,
                                                                            left:
                                                                                16,
                                                                            right:
                                                                                16),
                                                                        child:
                                                                            Text(
                                                                          myGroups["groupName"]
                                                                              .toString(),
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 16,
                                                                              letterSpacing: 0.27,
                                                                              color: Colors.white),
                                                                        ),
                                                                      ),
                                                                    ),

                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              8,
                                                                          left:
                                                                              16,
                                                                          right:
                                                                              16,
                                                                          bottom:
                                                                              8),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                            '${myGroups['membersCount'].toString()} members',
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                            style:
                                                                                TextStyle(
                                                                              fontWeight: FontWeight.w300,
                                                                              fontSize: 12,
                                                                              letterSpacing: 0.27,
                                                                              color: Colors.red[600],
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
                                                              width: 48,
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
                                                      const EdgeInsets.only(
                                                          top: 24,
                                                          right: 16,
                                                          left: 16),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  16.0)),
                                                      /*  boxShadow: <
                                                                BoxShadow>[
                                                              BoxShadow(
                                                                  color: ProfileTheme
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.8),
                                                                  offset:
                                                                      const Offset(
                                                                          0.0,
                                                                          0.0),
                                                                  blurRadius:
                                                                      6.0),
                                                            ],*/
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  16.0)),
                                                      child: AspectRatio(
                                                        aspectRatio: 1.28,
                                                        child: Image(
                                                          fit: BoxFit.fill,
                                                          image: NetworkImage(
                                                              myGroups[
                                                                      'groupPicture']
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
                                      ),
                                    );
                                  }).toList(),
                                )
                              : const Text(
                                  "Not a member of any groups",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white30),
                                ),
                        ),
                      ],
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

class socialProgressView extends StatelessWidget {
  const socialProgressView(
    List<String> stepsText,
    int curStep,
    double height,
    double width,
    double dotRadius,
    Color activeColor,
    Color inactiveColor,
    TextStyle headerStyle,
    TextStyle stepsStyle, {
    //Key key,
    required this.decoration,
    required this.padding,
    this.lineHeight = 25.0,
  })  : _stepsText = stepsText,
        _curStep = curStep,
        _height = height,
        _width = width,
        _dotRadius = dotRadius,
        _activeColor = activeColor,
        _inactiveColor = inactiveColor,
        _headerStyle = headerStyle,
        _stepStyle = stepsStyle,
        assert(curStep > 0 == true && curStep <= stepsText.length),
        assert(width > 0),
        assert(height >= 2 * dotRadius),
        assert(width >= dotRadius * 2 * stepsText.length);
  //super(key: key);

  //height of the container
  final double _height;
  //width of the container
  final double _width;
  //container decoration
  final BoxDecoration decoration;
  //list of texts to be shown for each step
  final List<String> _stepsText;
  //cur step identifier
  final int _curStep;
  //active color
  final Color _activeColor;
  //in-active color
  final Color _inactiveColor;
  //dot radius
  final double _dotRadius;
  //container padding
  final EdgeInsets padding;
  //line height
  final double lineHeight;
  //header textstyle
  final TextStyle _headerStyle;
  //steps text
  final TextStyle _stepStyle;

  List<Widget> _buildDots() {
    var wids = <Widget>[];

    _stepsText.asMap().forEach((i, text) {
      var circleColor =
          (i == 0 || _curStep > i) ? _activeColor : _inactiveColor;

      var lineColor = _curStep > i + 1 ? _activeColor : _inactiveColor;

      if (i == 0) {
        wids.add(Tooltip(
            message: 'COUCH POTATO ',
            triggerMode: TooltipTriggerMode.tap,
            child: Container(
                height: lineHeight,
                decoration: BoxDecoration(
                    color: circleColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        topLeft: Radius.circular(20))),
                child: CircleAvatar(
                  backgroundImage: AssetImage('images/CouchPotatoe.png'),
                  backgroundColor: circleColor,
                  radius: _dotRadius,
                ))));
      } else if (i == 1) {
        wids.add(Tooltip(
            message: 'DANCING QUEEN',
            triggerMode: TooltipTriggerMode.tap,
            child: Container(
                height: lineHeight,
                color: lineColor,
                child: CircleAvatar(
                  backgroundImage: AssetImage('images/dancingQueen.png'),
                  backgroundColor: circleColor,
                  radius: _dotRadius,
                ))));
      } else if (i == 2) {
        wids.add(Tooltip(
            message: 'SOCIAL BUTTERFLY',
            triggerMode: TooltipTriggerMode.tap,
            child: Container(
                height: lineHeight,
                color: lineColor,
                child: CircleAvatar(
                  backgroundImage: AssetImage('images/SocialButterfly.png'),
                  backgroundColor: circleColor,
                  radius: _dotRadius,
                ))));
      } else if (i == 3) {
        wids.add(Tooltip(
            message: 'BNOC',
            triggerMode: TooltipTriggerMode.tap,
            child: Container(
                height: lineHeight,
                decoration: BoxDecoration(
                    color: circleColor,
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: CircleAvatar(
                  backgroundImage: AssetImage('images/BNOC.png'),
                  backgroundColor: circleColor,
                  radius: _dotRadius,
                ))));
      }

      //add a line separator
      //0-------0--------0
      if (i != _stepsText.length - 1) {
        wids.add(
          Expanded(
            child: Container(
              height: lineHeight,
              color: lineColor,
            ),
          ),
        );
      }
    });

    return wids;
  }
/*
  List<Widget> _buildText() {
    var wids = <Widget>[];
    _stepsText.asMap().forEach((i, text) {
      wids.add(Text(text, style: _stepStyle));
    });

    return wids;
  }
  */

  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      height: this._height,
      width: this._width,
      decoration: this.decoration,
      child: Column(
        children: <Widget>[
          /*
          Container(
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: (_curStep).toString(),
                      style: _headerStyle.copyWith(
                        color: _activeColor, //this is always going to be active
                      ),
                    ),
                    TextSpan(
                      text: " / " + _stepsText.length.toString(),
                      style: _headerStyle.copyWith(
                        color: _curStep == _stepsText.length
                            ? _activeColor
                            : _inactiveColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          */
          Row(
            children: _buildDots(),
          ),
          SizedBox(
            height: 10,
          ),
          /*
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildText(),
          )*/
        ],
      ),
    );
  }
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

Route _createRouteEvents(eventId) {
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

Route _createRouteToEdit() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        EditableProfileScreen(),
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

class filterChipWidget extends StatefulWidget {
  final String chipName;

  filterChipWidget({required this.chipName});

  @override
  _filterChipWidgetState createState() => _filterChipWidgetState();
}

class _filterChipWidgetState extends State<filterChipWidget> {
  var _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
        label: Text(widget.chipName),
        labelStyle: TextStyle(
            color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
        selected: _isSelected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        backgroundColor: Colors.grey[900], //Color(0xffededed),
        onSelected: (isSelected) {
          setState(() {
            _isSelected = isSelected;
            if (_isSelected == true) {
              _ProfileScreenState.selectedInterestsList.add(widget.chipName);
            } else if (_isSelected == false) {
              _ProfileScreenState.selectedInterestsList.remove(widget.chipName);
            }
          });
        },
        selectedColor: Colors.red[600] //Color(0xffeadffd),
        );
  }
}
