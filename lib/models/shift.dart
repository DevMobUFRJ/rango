import 'package:flutter/material.dart';
import 'package:rango/models/dayShift.dart';

class Shift {
  DayShift friday;
  DayShift monday;
  DayShift saturday;
  DayShift sunday;
  DayShift thursday;
  DayShift tuesday;
  DayShift wednesday;

  Shift({
    @required this.friday,
    @required this.monday,
    @required this.saturday,
    @required this.sunday,
    @required this.thursday,
    @required this.tuesday,
    @required this.wednesday,
  });
}
