import 'dart:convert';

import 'package:rango/models/address.dart';
import 'package:rango/models/contact.dart';
import 'package:rango/models/location.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/shift.dart';
import 'package:flutter/foundation.dart';
import 'package:rango/models/user_notification_settings.dart';

class Seller {
  final String id;
  final String email;
  final Contact contact;
  final Shift shift;
  final String name;
  final bool active;
  final bool canReservate;
  final String logo;
  final Location location;
  final Address address;
  final String picture;
  final String description;
  final String paymentMethods;
  Map<String, CurrentMeal> currentMeals;
  List<Meal> meals;
  final UserNotificationSettings notificationSettings;

  Seller({
    this.id,
    this.email,
    this.contact,
    this.shift,
    @required this.name,
    @required this.active,
    @required this.canReservate,
    this.logo,
    this.location,
    this.address,
    this.picture,
    this.description,
    this.paymentMethods,
    this.meals,
    this.currentMeals,
    this.notificationSettings,
  });

  Seller.fromJson(Map<String, dynamic> json, {String id})
      : id = id,
        email = json['email'],
        contact = json['contact'] == null? null: Contact.fromJson(json['contact']),
        shift = json['shift'] == null? null: Shift.fromJson(json['shift']),
        name = json['name'],
        active = json['active'],
        canReservate = json['canReservate'],
        logo = json['logo'],
        location = json['location'] == null? null: Location.fromJson(json['location']),
        address = json['address'] == null? null: Address.fromJson(json['address']),
        picture = json['picture'],
        description = json['description'],
        paymentMethods = json['paymentMethods'],
        currentMeals = json['currentMeals'] == null? null: buildCurrentMeals(json['currentMeals']),
        notificationSettings = json['notificationSettings'] == null
            ? null
            : UserNotificationSettings.fromJson(json['notificationSettings']),
        meals = [];

  Map<String, dynamic> toJson() => {
    'name': name,
  };
}

Map<String, CurrentMeal> buildCurrentMeals(Map<String, dynamic> json) {
  Map<String, CurrentMeal> newMap = json.map((key, value) => MapEntry(key, CurrentMeal.fromJson(value)));
  return newMap;
}