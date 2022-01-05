import 'package:http/http.dart' as http;
import 'package:project_meetup/place_model.dart';
import 'dart:convert' as convert;

import 'package:project_meetup/place_search.dart';

class PlacesService {
  final key = "AIzaSyC28P1QptUML8HEnuD4nqrZ7YyD1SQLaL8";

  Future<List<PlaceSearch>> getAutoComplete(String search) async {
    var url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=geocode&key=$key";
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json["predictions"] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  Future<PlaceModel> getPlace(String placeId) async {
    var url =
        "https://maps.googleapis.com/maps/api/place/details/json?key=$key&place_id=$placeId";
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResult = json["result"] as Map<String, dynamic>;
    return PlaceModel.fromJson(jsonResult);
  }
}
