import 'package:flutter/material.dart';

class DayShift {
  bool open;
  String openingTime;
  String closingTime;

  DayShift({
    @required this.open,
    this.openingTime,
    this.closingTime,
  });
}
