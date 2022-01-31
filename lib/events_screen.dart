import 'dart:ui';
import 'package:intl/intl.dart'; //to convert timestamp to a date in ddmmyy format

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_meetup/application_bloc.dart';
import 'package:project_meetup/event_details_screen.dart';
import 'package:project_meetup/group_details_screen.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_meetup/place_model.dart';

/// Stateful Widget for bottom navigation bar.
class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  // Events firestore reference - only Events that lie in the future
  DateTime now = new DateTime.now();
  CollectionReference events = FirebaseFirestore.instance.collection('Events');

  final PanelController _pc = new PanelController();
  // Controller for Google Maps
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void initState() {
    super.initState();

    events.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        GeoPoint pos = doc["location"];

        var marker = Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(pos.latitude, pos.longitude));
        markers[MarkerId(doc.id)] = marker;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
              onPressed: () {
                if (_pc.isPanelClosed == true) {
                  _pc.open();
                } else {
                  _pc.close();
                }
              },
              label: Text("Events")),
          SizedBox(
            height: 100,
          )
        ],
      ),
      body: SlidingUpPanel(
        color: Colors.transparent,
        minHeight: 0,
        controller: _pc,
        panel: Container(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: const BoxDecoration(
                  //color: Colors.black54, //const Color(0xFFF3F5F7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                ),
                child: Column(
                  children: [
                    const FaIcon(FontAwesomeIcons.chevronDown),
                    Expanded(
                      child: Container(
                        padding:
                            const EdgeInsets.only(top: 20.0, right: 5, left: 5),
                        child: FutureBuilder<QuerySnapshot>(
                            future: events
                                .where("isPrivate", isEqualTo: false)
                                .get(), //events.get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              // If something went wrong
                              if (snapshot.hasError) {
                                return const Text("Something went wrong");
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return ListView(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  children: snapshot.data!.docs.map((doc) {
                                    Map<String, dynamic> docData =
                                        doc.data() as Map<String, dynamic>;
                                    return SizedBox(
                                      //height: 80,
                                      child: GestureDetector(
                                        onTap: () {
                                          _pc.close();
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EventDetailsScreen(
                                                          Event(doc.id))));
                                        },
                                        child: Card(
                                          color: Colors.black54,
                                          semanticContainer: true,
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          //elevation: 5,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 7, horizontal: 5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.all(
                                                13), //EdgeInsets.symmetric(horizontal: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  child: Flexible(
                                                    child: Column(
                                                      children: [
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    bottom: 10),
                                                            child: Text(
                                                              (DateFormat
                                                                      .MMMEd()
                                                                  .add_Hm()
                                                                  .format(docData[
                                                                          "dateTime"]
                                                                      .toDate())
                                                                  .toString()),

                                                              //  maxLines: 1,
                                                              //overflow: TextOverflow.ellipsis,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                letterSpacing:
                                                                    0.27,
                                                                color: Colors
                                                                    .greenAccent,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              right: 8,
                                                            ),
                                                            child: AutoSizeText(
                                                                docData["eventName"]
                                                                    .toString(),
                                                                maxLines: 2,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                        ),
                                                        Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(top: 5),
                                                              child: Text(
                                                                'by ${docData["hostingGroup"]["groupName"].toString()}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  fontSize: 12,
                                                                  letterSpacing:
                                                                      0.27,
                                                                  color: HexColor(
                                                                      '#F8FAFB'),
                                                                ),
                                                              ),
                                                            ))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    final loc = LatLng(
                                                        docData["location"]
                                                            .latitude,
                                                        docData["location"]
                                                            .longitude);
                                                    _goToPlace(loc);
                                                    _pc.close();
                                                  },
                                                  icon: Icon(
                                                      Icons
                                                          .travel_explore_rounded,
                                                      color: Colors.white),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }
                              return const CircularProgressIndicator();
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Center(
          child: GoogleMap(
            zoomControlsEnabled: false,
            markers: Set<Marker>.of(markers.values),
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ),
        header: Align(
          alignment: Alignment.center,
          child: Text(""),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
    );
  }

  Future<void> _goToPlace(LatLng goToPos) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: goToPos, zoom: 14)));
  }
}

_eventCard(String s) {
  return Padding(
    padding: const EdgeInsets.only(left: 0.0),
    child: Card(
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.0),
        child: Text(s),
      ),
    ),
  );
}
