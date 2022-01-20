import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_meetup/application_bloc.dart';
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
  // Events firestore reference
  CollectionReference events = FirebaseFirestore.instance.collection('Events');

  // Controller for Google Maps
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Set markerSet = <Marker>{};

  void initState() {
    events.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        GeoPoint pos = doc["location"];
        var marker = Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(pos.latitude, pos.longitude));
        markerSet.add(marker);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
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
                              child: GestureDetector(
                                onTap: () {
                                  print("hej");
                                },
                                child: Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  elevation: 5,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 7, horizontal: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          (doc.data() as Map<String, dynamic>)[
                                                  "eventName"]
                                              .toString(),
                                        ),
                                        ElevatedButton(
                                            onPressed: () {},
                                            child: Icon(Icons.search))
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
          markers: markerSet as Set<Marker>,
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

  Future<void> _goToPlace(PlaceModel place) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(place.geometry.location.lat, place.geometry.location.lng),
        zoom: 14)));
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
