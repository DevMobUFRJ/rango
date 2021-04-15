import 'package:flutter/material.dart';

class Weekday {
  final int openingTime;
  final int closingTime;
  final bool open;
  
  Weekday({
    @required this.openingTime,
    @required this.closingTime,
    @required this.open
  });

  Weekday.fromJson(Map<String, dynamic> json)
      : openingTime = json['openingTime'],
        closingTime = json['closingTime'],
        open = json['open'];
}

class Shift {
  final Weekday sunday;
  final Weekday monday;
  final Weekday tuesday;
  final Weekday wednesday;
  final Weekday thursday;
  final Weekday friday;  
  final Weekday saturday;
  
  Shift({
    @required this.sunday,
    @required this.monday,
    @required this.tuesday,
    @required this.wednesday,
    @required this.thursday,
    @required this.friday,
    @required this.saturday,
  });

  Shift.fromJson(Map<String, dynamic> json)
      : sunday = Weekday.fromJson(json['sunday']),
        monday = Weekday.fromJson(json['monday']),
        tuesday = Weekday.fromJson(json['tuesday']),
        wednesday = Weekday.fromJson(json['wednesday']),
        thursday = Weekday.fromJson(json['thursday']),
        friday = Weekday.fromJson(json['friday']),
        saturday = Weekday.fromJson(json['saturday']);
}
