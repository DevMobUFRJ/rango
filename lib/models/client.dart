import 'package:rango/models/user_notification_settings.dart';
import 'package:flutter/foundation.dart';

class Client {
  final String id;
  String email;
  String name;
  String picture;
  List<String> favoriteSellers;
  UserNotificationSettings notificationSettings;
  String phone;
  String deviceToken;

  Client({
    this.id,
    @required this.email,
    @required this.name,
    this.picture,
    this.favoriteSellers,
    this.notificationSettings,
    this.phone,
  });

  Client.fromJson(Map<String, dynamic> json, {String id})
      : id = id,
        email = json['email'],
        name = json['name'],
        picture = json['picture'],
        favoriteSellers = json['favoriteSellers'] != null
            ? List<String>.from(json['favoriteSellers'])
            : null,
        notificationSettings = json['notifications'] == null
            ? null
            : UserNotificationSettings.fromJson(json['notifications']),
        phone = json['phone'],
        deviceToken = json['deviceToken'];

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'picture': picture,
    'favoriteSellers': favoriteSellers,
    'notifications': notificationSettings,
    'deviceToken': deviceToken,
    'phone': phone
  };
}
