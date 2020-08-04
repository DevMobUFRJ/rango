import 'package:flutter/material.dart';

class Shift {
  final String opening;
  final String closing;
  final bool friday;
  final bool monday;
  final bool saturday;
  final bool sunday;
  final bool thursday;
  final bool tuesday;
  final bool wednesday;

  Shift({
    @required this.closing,
    @required this.friday,
    @required this.monday,
    @required this.opening,
    @required this.saturday,
    @required this.sunday,
    @required this.thursday,
    @required this.tuesday,
    @required this.wednesday,
  });
}
