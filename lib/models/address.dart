import 'package:flutter/foundation.dart';

class Address {
  final String street;
  final String number;
  final String complement;
  final String reference;
  final String district;
  final String city;
  final String state;
  final String zipCode;

  Address({
    this.street,
    this.number,
    this.complement,
    this.reference,
    this.district,
    this.city,
    this.state,
    this.zipCode,
  });

  Address.fromJson(Map<String, dynamic> json)
      : street = json['street'],
        number = json['number'],
        complement = json['complement'],
        reference = json['reference'],
        district = json['district'],
        city = json['city'],
        state = json['state'],
        zipCode = json['zipCode'];
}