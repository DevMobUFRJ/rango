import 'package:rango/models/address.dart';
import 'package:rango/models/contact.dart';
import 'package:rango/models/location.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/shift.dart';
import 'package:flutter/foundation.dart';
import 'package:rango/models/user_notification_settings.dart';

class Seller {
  String id;
  final String email;
  final Contact contact;
  final Shift shift;
  final String name;
  final bool active;
  final bool canReservate;
  final String logo;
  final Location location;
  final String deviceToken;
  final Address address;
  final String description;
  final String paymentMethods;
  Map<String, CurrentMeal> currentMeals;
  final UserNotificationSettings notificationSettings;

  Seller({
    this.id,
    this.email,
    this.contact,
    this.shift,
    this.deviceToken,
    @required this.name,
    @required this.active,
    @required this.canReservate,
    this.logo,
    this.location,
    this.address,
    this.description,
    this.paymentMethods,
    this.currentMeals,
    this.notificationSettings,
  });

  Seller.fromJson(Map<String, dynamic> json, {String id})
      : id = id != null ? id : null,
        email = json['email'],
        logo = json['logo'],
        description = json['description'],
        paymentMethods = json['paymentMethods'],
        name = json['name'],
        contact =
            json['contact'] == null ? null : Contact.fromJson(json['contact']),
        canReservate = json['canReservate'],
        shift = json['shift'] == null ? null : Shift.fromJson(json['shift']),
        active = json['active'],
        location = json['location'] == null
            ? null
            : Location.fromJson(json['location']),
        address =
            json['address'] == null ? null : Address.fromJson(json['address']),
        currentMeals = json['currentMeals'] == null
            ? null
            : currentMealsFromJson(json['currentMeals']),
        deviceToken = json['deviceToken'],
        notificationSettings = json['notificationSettings'] == null
            ? null
            : UserNotificationSettings.fromJson(json['notificationSettings']);

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'active': active,
        'canReservate': canReservate,
        'logo': logo,
        'description': description,
        'paymentMethods': paymentMethods,
        'location': location != null ? location.toJson() : null,
        'contact': contact != null ? contact.toJson() : null,
        'shift': shift != null ? shift.toJson() : null,
        'address': address != null ? address.toJson() : null,
        'currentMeals':
            currentMeals != null ? currentMealsToJson(currentMeals) : null,
        'deviceToken': deviceToken,
        'notificationSettings':
            notificationSettings != null ? notificationSettings.toJson() : null,
      };
}

Map<String, dynamic> currentMealsToJson(Map<String, CurrentMeal> object) {
  Map<String, dynamic> json = {};
  object.entries.map((e) => json[e.key] = {'featured': e.value.featured});
  return json;
}

Map<String, CurrentMeal> currentMealsFromJson(Map<String, dynamic> json) {
  Map<String, CurrentMeal> newMap =
      json.map((key, value) => MapEntry(key, CurrentMeal.fromJson(value)));
  return newMap;
}
