import 'package:rango/models/seller.dart';
import 'package:rango/models/user_notification_settings.dart';
import 'package:flutter/foundation.dart';

class Client {
  String email;
  String name;
  String picture;
  List<Seller> favoriteSellers;
  UserNotificationSettings notificationSettings;
  String phone;

  Client({
    @required this.email,
    @required this.name,
    this.picture,
    this.favoriteSellers,
    this.notificationSettings,
    this.phone,
  });
}
