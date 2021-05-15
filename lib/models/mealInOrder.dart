import 'package:flutter/material.dart';
import 'package:rango/models/meals.dart';

class MealInOrder {
  final Meal quentinha;
  final int quantidade;

  MealInOrder({
    @required this.quentinha,
    this.quantidade = 1,
  });
}
