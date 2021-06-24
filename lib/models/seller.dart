import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
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
  final String id;
  final Contact contact;
  final Shift shift;
  final String name;
  final bool active;
  final String logo;
  final Location location;
  final String picture;
  Map<String, dynamic> currentMeals;
  List<Meal> meals;

  Seller({
    this.id,
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

  Seller.fromJson(Map<String, dynamic> json, {String id})
      : id = id,
        contact = Contact.fromJson(json['contact']),
        shift = Shift.fromJson(json['shift']),
        name = json['name'],
        active = json['active'],
        logo = json['logo'],
        location = Location.fromJson(json['location']),
        picture = json['picture'],
        currentMeals = json['currentMeals'],
        meals = [];

  Map<String, dynamic> toJson() => {
    'name': name,
  };
}
