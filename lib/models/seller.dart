import 'package:rango/models/address.dart';
import 'package:rango/models/contact.dart';
import 'package:rango/models/location.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/seller_notifications_settings.dart';
import 'package:rango/models/shift.dart';
import 'package:flutter/foundation.dart';

class Seller {
  final String id;
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
  SellerNotificationSettings notificationSettings;
  final String paymentMethods;
  Map<String, CurrentMeal> currentMeals;
  List<Meal> meals;
  String deviceToken;

  Seller({
    this.id,
    this.contact,
    @required this.shift,
    @required this.name,
    @required this.active,
    @required this.canReservate,
    this.logo,
    @required this.location,
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
        contact = Contact.fromJson(json['contact']),
        shift = json['shift'] != null ? Shift.fromJson(json['shift']) : null,
        name = json['name'],
        active = json['active'],
        canReservate = json['canReservate'],
        logo = json['logo'],
        location = json['location'] == null
            ? null
            : Location.fromJson(json['location']),
        address =
            json['address'] == null ? null : Address.fromJson(json['address']),
        picture = json['picture'],
        notificationSettings = json['notificationSettings'] == null
            ? null
            : SellerNotificationSettings.fromJson(json['notificationSettings']),
        description = json['description'],
        paymentMethods = json['paymentMethods'],
        currentMeals = buildCurrentMeals(json['currentMeals']),
        deviceToken = json['deviceToken'],
        meals = [];

  Map<String, dynamic> toJson() => {
        'name': name,
        'meals': meals,
        'currentMeals': currentMeals,
        'sunday': shift==null ? null : shift.sunday,
        'monday': shift==null ? null : shift.monday,
        'tuesday': shift==null ? null : shift.tuesday,
        'wednesday': shift==null ? null : shift.wednesday,
        'thursday': shift==null ? null : shift.thursday,
        'friday': shift==null ? null : shift.friday,
        'saturday': shift==null ? null : shift.saturday
      };
}

Map<String, CurrentMeal> buildCurrentMeals(Map<String, dynamic> json) {
  Map<String, CurrentMeal> newMap =
      json.map((key, value) => MapEntry(key, CurrentMeal.fromJson(value)));
  return newMap;
}
