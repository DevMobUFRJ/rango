import 'package:rango/models/client_notification_settings.dart';
import 'package:flutter/foundation.dart';

class Client {
  final String id;
  String email;
  String name;
  String picture;
  List<String> favoriteSellers;
  ClientNotificationSettings clientNotificationSettings;
  String phone;
  String deviceToken;

  Client({
    this.id,
    @required this.email,
    @required this.name,
    this.picture,
    this.favoriteSellers,
    this.clientNotificationSettings,
    this.phone,
    this.deviceToken,
  });

  Client.fromJson(Map<String, dynamic> json, {String id})
      : id = id,
        email = json['email'],
        name = json['name'],
        picture = json['picture'],
        favoriteSellers = json['favoriteSellers'] == null
            ? null
            : List<String>.from(json['favoriteSellers']),
        clientNotificationSettings = json['notifications'] == null
            ? null
            : ClientNotificationSettings.fromJson(json['notifications']),
        deviceToken = json['deviceToken'],
        phone = json['phone'];

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'picture': picture,
        'favoriteSellers': favoriteSellers,
        'notifications': clientNotificationSettings,
        'deviceToken': deviceToken,
        'phone': phone
      };
}
