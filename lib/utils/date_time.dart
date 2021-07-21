import 'package:flutter/material.dart';

DateTime startOfDay() {
  var now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime endOfDay() {
  var now = DateTime.now();
  return DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
}

TimeOfDay intTimeToTimeOfDay(int time) {
  if (time == null) return TimeOfDay.now();
  var string = time.toString().padLeft(4, '0');
  var hours = int.tryParse(string.substring(0, 2));
  var minutes = int.tryParse(string.substring(2, 4));
  if (hours == null || minutes == null) {
    return TimeOfDay.now();
  }
  return TimeOfDay(hour: hours, minute: minutes);
}