import 'package:flutter/material.dart';

class CurrentMeal {
  final bool featured;

  CurrentMeal({
    this.featured
  });

  CurrentMeal.fromJson(Map<String, dynamic> json):
        featured = json['featured'];
}

class Meal {
  String id;
  final String description;
  final bool featured;
  final String name;
  final String picture;
  final int price;
  String sellerName;
  String sellerId;
  int quantity;

  Meal({
    this.id,
    @required this.description,
    this.featured,
    @required this.name,
    this.picture,
    @required this.price,
    @required this.sellerId,
    @required this.sellerName,
    this.quantity
  });

  Meal.fromJson(Map<String, dynamic> json, {String id})
      : id = id,
        name = json['name'],
        description = json['description'],
        featured = json['featured'],
        picture = json['picture'],
        price = json['price'],
        sellerName = json['sellerName'],
        sellerId = json['sellerId'],
        quantity = json['quantity'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'featured': featured,
    'picture': picture,
    'price': price,
    'sellerName': sellerName,
    'sellerId': sellerId,
    'quantity': quantity,
  };
}