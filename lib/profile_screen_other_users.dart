import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:project_meetup/theme_profile_screen.dart';
import 'package:project_meetup/user_authentication.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart'; //to convert timestamp to a date in ddmmyy format
import 'group_details_screen.dart';
import 'discover_screen.dart';
import 'package:filter_list/filter_list.dart';
import 'package:project_meetup/event_details_screen.dart';
import 'profile_screen.dart'; //for sizeconfig fun

class ProfileScreenOtherUsers extends StatefulWidget {
  final String userId;
  const ProfileScreenOtherUsers(this.userId, {Key? key}) : super(key: key);

  @override
  State<ProfileScreenOtherUsers> createState() =>
      _ProfileScreenOtherUsersState();
}

class _ProfileScreenOtherUsersState extends State<ProfileScreenOtherUsers> {
  // User collection reference
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference groups = FirebaseFirestore.instance.collection('Groups');
  CollectionReference events = FirebaseFirestore.instance.collection('Events');

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

  @override
  Widget build(BuildContext context) {
    // CollectionReference users = FirebaseFirestore.instance.collection('users');
    var mediaQD = MediaQuery.of(context);
    _safeAreaSize = mediaQD.size;
    //  calculateSocialProgressIndex();
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(widget.userId).get(),
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
            backgroundColor: Colors.black, //const Color(0xffF8F8FA),
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverAppBar(
                  leading: BackButton(color: Colors.white),
                  backgroundColor: Colors.black, //const Color(0xffF8F8FA),
                  forceElevated: false,
                  expandedHeight: 180,
                  collapsedHeight: 180,
                  pinned: true,

                  flexibleSpace: FlexibleSpaceBar(
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
                                Container(
                                  child: Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(right: 5),
                                          child: AutoSizeText(
                                            '${data["firstName"]} ${data["lastName"]}',
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 3 *
                                                    SizeConfig.textMultiplier,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5),
                                          ),
                                        ),
                                        AutoSizeText('@${data["userName"]}',
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 2 *
                                                    SizeConfig.textMultiplier)),
                                        SizedBox(
                                          height:
                                              2 * SizeConfig.heightMultiplier,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                AutoSizeText(
                                                  data["university"],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 1.5 *
                                                        SizeConfig
                                                            .textMultiplier,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
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
                ),
                SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              left: 10.0, top: 3 * SizeConfig.heightMultiplier),
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
                                  }).toList(),
                                )
                              : const Text("   No interests chosen yet",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.white)),
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
                                                      decoration: BoxDecoration(
                                                        color: Colors.deepPurple
                                                            .withOpacity(0.4),
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
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
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              10),
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
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              2),
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
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        children: <
                                                                            Widget>[
                                                                          Expanded(
                                                                            child:
                                                                                Text(
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
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          right:
                                                                              10,
                                                                          bottom:
                                                                              10),
                                                                      child:
                                                                          Column(
                                                                        children: <
                                                                            Widget>[
                                                                          Container(
                                                                            child:
                                                                                Text(
                                                                              '9 going',
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
                                                padding: const EdgeInsets.only(
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
                                  "No groups",
                                  style: TextStyle(fontSize: 24),
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
            child: Container(height: lineHeight, color: lineColor),
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
