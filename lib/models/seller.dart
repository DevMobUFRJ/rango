import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rango/models/contact.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/shift.dart';
import 'package:flutter/foundation.dart';

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
}

class Seller {
  final Contact contact;
  final Shift shift;
  final String name;
  final bool active;
  final String logo;
  final Location location;
  final String picture;
  List<Meal> currentMeals;
  List<Meal> meals;

  Seller({
    this.contact,
    @required this.shift,
    @required this.name,
    @required this.active,
    this.logo,
    @required this.location,
    this.picture,
    this.meals,
    this.currentMeals,
  });

  Seller.fromJson(Map<String, dynamic> json)
      : contact = Contact.fromJson(json['contact']),
        shift = Shift.fromJson(json['shift']),
        name = json['name'],
        active = json['active'],
        logo = json['logo'],
        location = Location.fromJson(json['location']),
        picture = json['picture'],
        //currentMeals = (json['currentMeals'] as List).map((i) => Meal.fromJson(i)).toList(),
        currentMeals = [],
        meals = [];

  /*
  factory Seller.fromJson(Map<String, dynamic> json){
    print(json['meals']);
    return Seller(
        contact: Contact.fromJson(json['contact']),
        shift: Shift.fromJson(json['shift']),
        name: json['name'],
        active: json['active'],
        logo: json['logo'],
        location: Location.fromJson(json['location']),
        picture: json['picture'],
        meals: [],
        currentMeals: []
    );
  }

   */

  Map<String, dynamic> toJson() => {
    'name': name,
    'meals': meals,
    'currentMeals': currentMeals,
    'sunday': shift.sunday,
    'monday': shift.monday,
    'tuesday': shift.tuesday,
    'wednesday': shift.wednesday,
    'thursday': shift.thursday,
    'friday': shift.friday,
    'saturday': shift.saturday
  };
}
