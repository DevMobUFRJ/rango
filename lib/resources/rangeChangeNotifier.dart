import 'package:flutter/foundation.dart';

class RangeChangeNotifier extends ChangeNotifier {
  void triggerRefresh() {
    notifyListeners();
  }
}