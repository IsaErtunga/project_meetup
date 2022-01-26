import 'dart:collection';

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

  final _socialLevelsText = [
    "Couch potatoe ",
    "Dancing Queen",
    "Social Butterfly",
    "Nieves"
  ];

  final _stepCircleRadius = 12.0;

  final _socialProgressViewHeight = 100.0;

  Color _activeColor = Colors.amber;

  Color _inactiveColor = Color(0xFFD6D6D6);

  TextStyle _headerStyle =
      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);

  TextStyle _stepStyle = TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold);

  late Size _safeAreaSize;

  int _socialProgressIndex = 3;

  socialProgressView _getStepProgress() {
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
      decoration: BoxDecoration(color: Colors.white),
      padding: EdgeInsets.only(
        top: 16.0,
        left: 5.0,
        right: 25.0,
      ),
    );
  }

  List<String> allInterestsList = [
    "Music/Dance/Club",
    "Sports & Fitness",
    "Travel & Outdoors",
    "Science & Tech"
  ];
  List<String> selectedInterestsList = [];

  Future<void> addInterests() {
    return users
        .doc(auth.currentUser!.uid)
        .update({'myInterests': selectedInterestsList});
  }

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

          return Scaffold(
            backgroundColor: Colors.white, //const Color(0xffF8F8FA),
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverAppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
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
                            left: 50.0,
                            right: 30.0,
                            top: 8 * SizeConfig.heightMultiplier),
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
                                              data["university"],
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
                                ),
                              ],
                            ),
                            SizedBox(height: 2 * SizeConfig.widthMultiplier),
                            Container(height: 50, child: _getStepProgress()),
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
                    // physics: const BouncingScrollPhysics(),
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
                                  "My Interests",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      fontSize: 3 * SizeConfig.textMultiplier),
                                ),
                                Spacer(),
                                OutlinedButton(
                                    onPressed: _openInterestsFilterDialog,
                                    style: ButtonStyle(),
                                    child: const Text('edit',
                                        style: TextStyle(color: Colors.black))),
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
                                      return Chip(
                                        backgroundColor: Colors.black,
                                        side: BorderSide(
                                            color: Colors.white, width: 4),
                                        label: Text(
                                          interest.toString(),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      );
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
                                : const Text("   No interests chosen yet",
                                    style: TextStyle(fontSize: 15)),
                          ),
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
                                                            color: HexColor(
                                                                '#F8FAFB'),
                                                            borderRadius:
                                                                const BorderRadius
                                                                        .all(
                                                                    Radius.circular(
                                                                        16.0)),
                                                          ),
                                                          child: Row(
                                                            children: <Widget>[
                                                              const SizedBox(
                                                                width:
                                                                    48 + 24.0,
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  child: Column(
                                                                    children: <
                                                                        Widget>[
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(top: 10),
                                                                          child:
                                                                              Text(
                                                                            (DateFormat.MMMEd().add_Hm().format(attendedEvent["eventTime"].toDate()).toString()),

                                                                            //  maxLines: 1,
                                                                            //overflow: TextOverflow.ellipsis,
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                            style:
                                                                                TextStyle(
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
                                                                          padding:
                                                                              const EdgeInsets.only(top: 2),
                                                                          child:
                                                                              Text(
                                                                            attendedEvent["eventName"].toString(),
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                            style:
                                                                                TextStyle(
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
                                                                          padding:
                                                                              const EdgeInsets.only(top: 5),
                                                                          child:
                                                                              Row(
                                                                            //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            //  crossAxisAlignment: CrossAxisAlignment.center,
                                                                            children: <Widget>[
                                                                              Expanded(
                                                                                child: Text(
                                                                                  'by ${attendedEvent["hostingGroup"].toString()}',
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
                                                                          padding: const EdgeInsets.only(
                                                                              right: 10,
                                                                              bottom: 10),
                                                                          child:
                                                                              Column(
                                                                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            //crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: <Widget>[
                                                                              Container(
                                                                                child: Text(
                                                                                  '${attendedEvent["participantsCount"].toString()} going',
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
                                                                  Radius
                                                                      .circular(
                                                                          16.0)),
                                                          child: AspectRatio(
                                                            aspectRatio: 1.0,
                                                            child: Image(
                                                              fit: BoxFit.fill,
                                                              image:
                                                                  NetworkImage(
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
                                          .map<Widget>((myGroups) {
                                        return InkWell(
                                          splashColor: Colors.transparent,
                                          //onTap: callback,
                                          child: GestureDetector(
                                            child: Hero(
                                              tag: myGroups["id"],
                                              child: SizedBox(
                                                height: 280,
                                                child: Stack(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .bottomCenter,
                                                  children: <Widget>[
                                                    Container(
                                                      child: Column(
                                                        children: <Widget>[
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
                                                                // border: new Border.all(
                                                                //     color: DesignCourseAppTheme.notWhite),
                                                              ),
                                                              child: Column(
                                                                children: <
                                                                    Widget>[
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      child:
                                                                          Column(
                                                                        children: <
                                                                            Widget>[
                                                                          //  Expanded(
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.centerLeft,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                                                                              child: Text(
                                                                                myGroups["groupName"].toString(),
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
                                                                            padding: const EdgeInsets.only(
                                                                                top: 8,
                                                                                left: 16,
                                                                                right: 16,
                                                                                bottom: 8),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: <Widget>[
                                                                                Text(
                                                                                  '${myGroups['membersCount'].toString()} members',
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
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 24,
                                                                right: 16,
                                                                left: 16),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                const BorderRadius
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
                                                                  offset:
                                                                      const Offset(
                                                                          0.0,
                                                                          0.0),
                                                                  blurRadius:
                                                                      6.0),
                                                            ],
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
                                                                fit:
                                                                    BoxFit.fill,
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
                                            onTap: () => {
                                              Navigator.of(context)
                                                  .push(_createRoute(Group(
                                                myGroups["id"],
                                              )))
                                            },
                                          ),
                                        );
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
    this.lineHeight = 7.0,
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
            message: 'couch potato ',
            triggerMode: TooltipTriggerMode.tap,
            child: CircleAvatar(
              backgroundImage: AssetImage('images/CouchPotatoe.png'),
              backgroundColor: circleColor,
              radius: _dotRadius,
            )));
      } else if (i == 1) {
        wids.add(Tooltip(
            message: 'dancing queen',
            triggerMode: TooltipTriggerMode.tap,
            child: CircleAvatar(
              backgroundImage: AssetImage('images/dancingQueen.png'),
              backgroundColor: circleColor,
              radius: _dotRadius,
            )));
      } else if (i == 2) {
        wids.add(Tooltip(
            message: 'social butterfly',
            triggerMode: TooltipTriggerMode.tap,
            child: CircleAvatar(
              backgroundImage: AssetImage('images/SocialButterfly.png'),
              backgroundColor: circleColor,
              radius: _dotRadius,
            )));
      } else if (i == 3) {
        wids.add(Tooltip(
            message: 'Nieves',
            triggerMode: TooltipTriggerMode.tap,
            child: CircleAvatar(
              backgroundImage: AssetImage('images/BNOC.png'),
              backgroundColor: circleColor,
              radius: _dotRadius,
            )));
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

/*
 ElevatedButton(
          onPressed: () {
            context.read<UserAuthentication>().signOut();
          },
          child: const Text("Sign out"),
        ),
 */
