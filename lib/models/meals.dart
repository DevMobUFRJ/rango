import 'package:flutter/material.dart';

class Meal {
  final String description;
  final bool featured;
  final String name;
  final String picture;
  final double price;
  final String sellerName;
  final String sellerId;
  final int quantidadeDisponivel;

  Meal({
    @required this.description,
    this.featured,
    @required this.name,
    this.picture,
    @required this.price,
    @required this.sellerId,
    @required this.sellerName,
    this.quantidadeDisponivel = 1,
  });
}
