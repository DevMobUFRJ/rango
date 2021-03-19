import 'package:flutter/material.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/seller.dart';

class AddMealScreen extends StatefulWidget {
  final Seller usuario;

  AddMealScreen(this.usuario);

  @override
  _AddMealScreenState createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Text('oi'),
      ),
    );
  }
}
