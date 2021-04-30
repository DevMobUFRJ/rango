import 'package:flutter/material.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/meals.dart';

class Order {
  final Client cliente;
  final int orderId;
  bool reservada;
  bool vendida;
  final Meal quentinha;

  Order({
    @required this.cliente,
    @required this.orderId,
    this.reservada,
    this.vendida,
    @required this.quentinha,
  });
}
