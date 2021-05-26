import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/foundation.dart';

class Order {
  final String clientId;
  final String clientName;
  final String sellerId;
  final String sellerName;
  final String mealId;
  final String mealName;
  final int price;
  final int quantity;
  final String status; // requested, reserved, sold
  final Timestamp reservedAt;
  final Timestamp soldAt;

  Order({
    @required this.clientId,
    @required this.clientName,
    @required this.sellerId,
    @required this.sellerName,
    @required this.mealId,
    @required this.mealName,
    @required this.price,
    @required this.quantity,
    @required this.status,
    this.reservedAt,
    this.soldAt,
  });

  Order.fromJson(Map<String, dynamic> json)
      : clientId = json['clientId'],
        clientName = json['clientName'],
        sellerId = json['sellerId'],
        sellerName = json['sellerName'],
        mealId = json['mealId'],
        mealName = json['mealName'],
        price = json['price'],
        quantity = json['quantity'],
        status = json['status'],
        reservedAt = json['reservedAt'],
        soldAt = json['soldAt'];

  Map<String, dynamic> toJson() => {
    'clientId': clientId,
    'clientName': clientName,
    'sellerId': sellerId,
    'sellerName': sellerName,
    'mealId': mealId,
    'mealName': mealName,
    'price': price,
    'quantity': quantity,
    'status': status,
    'reservedAt': reservedAt,
    'soldAt': soldAt
  };
}
