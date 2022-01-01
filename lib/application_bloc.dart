import 'package:flutter/cupertino.dart';
import 'package:project_meetup/place_search.dart';
import 'package:project_meetup/places_service.dart';

class ApplicationBloc with ChangeNotifier {
  final placesService = PlacesService();

  late List<PlaceSearch> searchResults;
  searchPlaces(String searchTerm) async {
    searchResults = await placesService.getAutoComplete(searchTerm);
    notifyListeners();
  }
}
