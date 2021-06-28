import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class Contact {
  final String name;
  final String phone;

  Contact({
    this.name,
    @required this.phone,
  });

  Contact.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        phone = json['phone'];
}
