import 'package:flutter/material.dart';
import 'package:rango/models/meals.dart';

class DetalhesQuentinhaScreen extends StatelessWidget {
  static const routeName = '/detalhes-reserva-quentinha';
  @override
  Widget build(BuildContext context) {
    final Meal marmita = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.greenAccent),
        title: Text(
          marmita.sellerName,
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.1),
            child: Column(
              children: <Widget>[
                Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/imgs/quentinha_placeholder.png',
                      image: marmita.picture,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    marmita.name,
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(marmita.description),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    marmita.price.toString(),
                  ),
                ),
                RaisedButton(
                  onPressed: () {},
                  child: Text('Confirmar Reserva'),
                )
              ],
            )),
      ),
    );
  }
}
