import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  final String geohash;
  final GeoPoint geopoint;

  Location({
    this.geohash,
    this.geopoint
  });

  Location.fromJson(Map<String, dynamic> json)
      : geohash = json['geohash'],
        geopoint = json['geopoint'];

  Map<String, dynamic> toJson() => {
    'geohash': geohash,
    'geopoint': geopoint
  };
}