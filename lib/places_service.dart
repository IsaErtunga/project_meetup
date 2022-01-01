import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:project_meetup/place_search.dart';

class PlacesService {
  Future<List<PlaceSearch>> getAutoComplete(String search) async {
    const key = "AIzaSyC28P1QptUML8HEnuD4nqrZ7YyD1SQLaL8";
    var url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=(cities)&key=$key";
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var jsonResults = json["predictions"] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }
}
