import 'package:flutter/material.dart';

class Weekday {
  int openingTime;
  int closingTime;
  bool open;

  Weekday({
    this.openingTime,
    this.closingTime,
    @required this.open
  });

  Weekday.fromJson(Map<String, dynamic> json)
      : openingTime = json['openingTime'] != null? json['openingTime']: null,
        closingTime = json['closingTime'] != null? json['closingTime']: null,
        open = json['open'] != null? json['open']: null;

  Map<String, dynamic> toJson() => {
    'openingTime': openingTime,
    'closingTime': closingTime,
    'open': open
  };
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

  Weekday operator [](String weekday) {
    return Weekday.fromJson(this.toJson()[weekday]);
  }

  Shift.fromJson(Map<String, dynamic> json)
      : sunday = Weekday.fromJson(json['sunday']),
        monday = Weekday.fromJson(json['monday']),
        tuesday = Weekday.fromJson(json['tuesday']),
        wednesday = Weekday.fromJson(json['wednesday']),
        thursday = Weekday.fromJson(json['thursday']),
        friday = Weekday.fromJson(json['friday']),
        saturday = Weekday.fromJson(json['saturday']);

  Map<String, dynamic> toJson() => {
    'sunday': sunday != null? sunday.toJson(): null,
    'monday': monday != null? monday.toJson(): null,
    'tuesday': tuesday != null? tuesday.toJson(): null,
    'wednesday': wednesday != null? wednesday.toJson(): null,
    'thursday': thursday != null? thursday.toJson(): null,
    'friday': friday != null? friday.toJson(): null,
    'saturday': saturday != null? saturday.toJson(): null
  };
}