import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:project_meetup/application_bloc.dart';
import 'package:project_meetup/place_model.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'dart:async';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({Key? key}) : super(key: key);
  @override
  _GoogleMapsScreenState createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  CollectionReference events = FirebaseFirestore.instance.collection('Events');

  // Controller for Google Maps
  final Completer<GoogleMapController> _controller = Completer();
  late StreamSubscription locationSubscription;

  // String for saving placeid
  String placeId = "";

  @override
  void initState() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    locationSubscription =
        applicationBloc.selectedLocation.stream.listen((place) {
      _goToPlace(place);
    });
    super.initState();
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void dispose() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    applicationBloc.dispose();
    locationSubscription.cancel();
    super.dispose();
  }

  Marker marker = Marker(markerId: MarkerId("chosen"));

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.teal,
        body: Stack(
          children: <Widget>[
            Container(
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: <Marker>{marker},
                onTap: (latLng) {
                  setState(() {
                    marker = Marker(
                      flat: true,
                      markerId: MarkerId("chosen"),
                      position: latLng,
                      infoWindow: InfoWindow(
                          title: "Choose location",
                          onTap: () {
                            applicationBloc.setApprovedLocation(latLng);
                            Navigator.pop(context, 'Yep!');
                          }),
                    );
                  });
                },
              ),
            ),
            FloatingSearchBar(
              hint: 'Search...',
              scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
              transitionDuration: const Duration(milliseconds: 800),
              transitionCurve: Curves.easeInOut,
              physics: const BouncingScrollPhysics(),
              axisAlignment: isPortrait ? 0.0 : -1.0,
              openAxisAlignment: 0.0,
              width: isPortrait ? 600 : 500,
              debounceDelay: const Duration(milliseconds: 100),
              onQueryChanged: (query) {
                // Call your model, bloc, controller here.
                applicationBloc.searchPlaces(query);
              },
              // Specify a custom transition to be used for
              // animating between opened and closed stated.
              transition: CircularFloatingSearchBarTransition(),
              actions: [
                FloatingSearchBarAction(
                  showIfOpened: false,
                  child: CircularButton(
                    icon: const Icon(Icons.place),
                    onPressed: () {},
                  ),
                ),
                FloatingSearchBarAction.searchToClear(
                  showIfClosed: false,
                ),
              ],
              builder: (context, transition) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Material(
                    color: Colors.white,
                    elevation: 4.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: applicationBloc.searchResults.map((result) {
                        return Container(
                          height: 40,
                          child: Row(
                            children: [
                              Text(result.description),
                              IconButton(
                                  onPressed: () {
                                    applicationBloc
                                        .setSelectedLocation(result.placeId);
                                  },
                                  icon: Icon(Icons.search))
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            )
          ],
        ));
  }

  Future<void> _goToPlace(PlaceModel place) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(place.geometry.location.lat, place.geometry.location.lng),
        zoom: 14)));
  }
}
