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
        favoriteSellers = List<String>.from(json['favoriteSellers']),
        notificationSettings = json['notificationSettings'] == null
            ? null
            : UserNotificationSettings.fromJson(json['notificationSettings']),
        phone = json['phone'];
}
