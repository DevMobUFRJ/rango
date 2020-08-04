import 'package:flutter/material.dart';
import 'package:rango/models/meals.dart';

class DetalhesQuentinhaScreen extends StatelessWidget {
  static const routeName = '/detalhes-reserva-quentinha';
  @override
  Widget build(BuildContext context) {
    final Meal marmita = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(marmita.name),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Container(
            child: Column(
          children: <Widget>[
            Image.network(marmita.picture),
            Text(marmita.description),
            Text(marmita.price.toString()),
          ],
        )),
      ),
    );
  }
}
