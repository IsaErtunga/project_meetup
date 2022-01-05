import 'package:project_meetup/location_model.dart';

class GeometryModel {
  final LocationModel location;

  GeometryModel({required this.location});

  factory GeometryModel.fromJson(Map<dynamic, dynamic> parsedJson) {
    return GeometryModel(
        location: LocationModel.fromJson(parsedJson["location"]));
  }
}
