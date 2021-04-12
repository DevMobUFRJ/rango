import 'package:flutter/material.dart';

class Meal {
  final String description;
  final bool featured;
  final String name;
  final String picture;
  final int price;
  String sellerName;
  String sellerId;

  Meal({
    @required this.description,
    this.featured,
    @required this.name,
    this.picture,
    @required this.price,
    @required this.sellerId,
    @required this.sellerName,
  });

  Meal.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        description = json['description'],
        featured = json['featured'],
        picture = json['picture'],
        price = json['price'],
        sellerName = json['sellerName'],
        sellerId = json['sellerId'];
}
