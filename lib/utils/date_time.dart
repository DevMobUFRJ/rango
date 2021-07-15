DateTime startOfDay() {
  var now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime endOfDay() {
  var now = DateTime.now();
  return DateTime(now.year, now.month, now.day, 23, 59, 59);
}