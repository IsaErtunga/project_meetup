import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:project_meetup/place_model.dart';
import 'package:project_meetup/place_search.dart';
import 'package:project_meetup/places_service.dart';

class ApplicationBloc with ChangeNotifier {
  final placesService = PlacesService();

  List<PlaceSearch> searchResults = [];
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

  @override
  void dispose() {
    selectedLocation.close();
    super.dispose();
  }
}
