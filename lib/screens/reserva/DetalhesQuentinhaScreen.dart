import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/meals.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/screens/seller/SellerProfile.dart';

class DetalhesQuentinhaScreen extends StatelessWidget {
  final Meal marmita;
  final double tagM;

  DetalhesQuentinhaScreen({
    this.marmita,
    this.tagM,
  });

  static const routeName = '/detalhes-reserva-quentinha';
  @override
  Widget build(BuildContext context) {
    String price = 'R\$${marmita.price.toString().replaceAll('.', ',')}';
    if (price.length == 6 && price.contains(',')) price = '${price}0';
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => pushNewScreen(
            context,
            screen: SellerProfile(marmita.sellerName),
            withNavBar: true,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          ),
          child: Text(
            marmita.sellerName,
            style: GoogleFonts.montserrat(color: Theme.of(context).accentColor),
          ),
        ),
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
                    child: Hero(
                      tag: marmita.hashCode * tagM,
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/imgs/quentinha_placeholder.png',
                        image: marmita.picture,
                        fit: BoxFit.cover,
                      ),
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
