import 'package:flutter/material.dart';
import 'package:rango/models/meals.dart';
import 'package:google_fonts/google_fonts.dart';

class DetalhesQuentinhaScreen extends StatelessWidget {
  static const routeName = '/detalhes-reserva-quentinha';
  @override
  Widget build(BuildContext context) {
    final Meal marmita = ModalRoute.of(context).settings.arguments;
    String price = 'R\$${marmita.price.toString().replaceAll('.', ',')}';
    if (price.length == 6 && price.contains(',')) price = '${price}0';
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.greenAccent),
        title: Text(
          marmita.sellerName,
          style: GoogleFonts.montserrat(color: Theme.of(context).accentColor),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.1),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Card(
                  margin: EdgeInsets.only(top: 10),
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
              ),
              Flexible(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 25),
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          marmita.name,
                          style: GoogleFonts.montserratTextTheme(
                                  Theme.of(context).textTheme)
                              .headline2
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 3),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          marmita.description,
                          style: GoogleFonts.montserratTextTheme(
                                  Theme.of(context).textTheme)
                              .headline2
                              .copyWith(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 3),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          price,
                          style: GoogleFonts.montserratTextTheme(
                                  Theme.of(context).textTheme)
                              .headline2
                              .copyWith(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () {},
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Confirmar Reserva',
                        style: GoogleFonts.montserratTextTheme(
                                Theme.of(context).textTheme)
                            .button),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
