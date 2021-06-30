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
  String status; // requested, reserved, sold, canceled
  final Timestamp requestedAt;
  final Timestamp reservedAt;
  final Timestamp soldAt;
  final Timestamp canceledAt;

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
    this.requestedAt,
    this.reservedAt,
    this.soldAt,
    this.canceledAt
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
        requestedAt = json['requestedAt'],
        reservedAt = json['reservedAt'],
        canceledAt = json['canceledAt'],
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
    'requestedAt': requestedAt,
    'reservedAt': reservedAt,
    'canceledAt': canceledAt,
    'soldAt': soldAt
  };
}