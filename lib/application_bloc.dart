import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_meetup/place_model.dart';
import 'package:project_meetup/place_search.dart';
import 'package:project_meetup/places_service.dart';

class ApplicationBloc with ChangeNotifier {
  final placesService = PlacesService();

  List<PlaceSearch> searchResults = [];
  LatLng approvedLocation = LatLng(0.00, 0.00);
  StreamController<PlaceModel> selectedLocation =
      StreamController<PlaceModel>.broadcast();

  searchPlaces(String searchTerm) async {
    searchResults = await placesService.getAutoComplete(searchTerm);
    notifyListeners();
  }

  setSelectedLocation(String placeId) async {
    selectedLocation.add(await placesService.getPlace(placeId));
    notifyListeners();
  }

  setApprovedLocation(LatLng coordinates) {
    approvedLocation = coordinates;
    notifyListeners();
  }

  @override
  void dispose() {
    selectedLocation.close();
    super.dispose();
  }
}
