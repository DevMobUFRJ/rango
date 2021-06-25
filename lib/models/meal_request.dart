import 'package:flutter/foundation.dart';
import 'package:rango/models/seller.dart';

class MealRequest {
  final String mealId;
  final Seller seller;

  MealRequest({
    @required this.mealId,
    @required this.seller,
  });
}