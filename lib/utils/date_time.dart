import 'package:flutter/material.dart';

TimeOfDay intTimeToTimeOfDay(int time) {
  if (time == null) return null;
  var string = time.toString().padLeft(4, '0');
  var hours = int.tryParse(string.substring(0, 2));
  var minutes = int.tryParse(string.substring(2, 4));
  if (hours == null || minutes == null) {
    return null;
  }
  return TimeOfDay(hour: hours, minute: minutes);
}