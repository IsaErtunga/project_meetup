import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Stateful Widget for bottom navigation bar.
class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  // Events firestore reference
  CollectionReference events = FirebaseFirestore.instance.collection('Events');

  // Controller for Google Maps
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  final Marker marker = Marker(
      markerId: MarkerId("ds"),
      position: LatLng(37.42796133580664, -122.085749655962));

  final Marker marker2 = Marker(
      markerId: MarkerId("ds"),
      position: LatLng(38.42796133580664, -122.085749655962));

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      panel: Container(
        decoration: const BoxDecoration(
          color: const Color(0xFFF3F5F7),
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
                padding: const EdgeInsets.only(top: 50.0),
                child: FutureBuilder<QuerySnapshot>(
                    future: events.get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      // If something went wrong
                      if (snapshot.hasError) {
                        return const Text("Something went wrong");
                      }
                      if (snapshot.connectionState == ConnectionState.done) {
                        return ListView(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children: snapshot.data!.docs.map((doc) {
                            return SizedBox(
                              height: 80,
                              child: Card(
                                semanticContainer: true,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                elevation: 5,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 7, horizontal: 5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Center(
                                  child: Text(
                                    (doc.data() as Map<String, dynamic>)[
                                            "eventName"]
                                        .toString(),
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
      collapsed: Container(
        decoration: const BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        //color: Colors.blueGrey,
        child: Column(
          children: [
            const FaIcon(FontAwesomeIcons.chevronUp),
            const Center(
              child: Text(
                "Slide up for events",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: GoogleMap(
          markers: <Marker>{marker, marker2},
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
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
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
