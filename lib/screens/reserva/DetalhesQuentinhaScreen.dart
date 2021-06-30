import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/meals.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/order.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/main/tabs/OrderHistory.dart';
import 'package:rango/screens/seller/SellerProfile.dart';
import 'package:rango/utils/string_formatters.dart';

class DetalhesQuentinhaScreen extends StatelessWidget {
  final Meal marmita;
  final Seller seller;
  final double tagM;

  DetalhesQuentinhaScreen({
    @required this.marmita,
    @required this.seller,
    this.tagM,
  });

  static const routeName = '/detalhes-reserva-quentinha';
  @override
  Widget build(BuildContext context) {
    String price = intToCurrency(marmita.price);
    if (price.length == 6 && price.contains(',')) price = '${price}0';
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => pushNewScreen(
            context,
            withNavBar: false,
            screen: SellerProfile(seller.id, seller.name),
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          ),
          child: AutoSizeText(
            seller.name,
            style: GoogleFonts.montserrat(
              color: Theme.of(context).accentColor,
              fontSize: 40.nsp,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 0,
            child: Card(
              margin: EdgeInsets.only(top: 10),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 0.4.hp,
                  maxWidth: 0.8.wp,
                ),
                child: Hero(
                  tag: marmita.hashCode * tagM,
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/imgs/quentinha_placeholder.png',
                    image: marmita.picture,
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 0,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 25, horizontal: 0.1.wp),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    flex: 0,
                    child: Container(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: AutoSizeText(
                          marmita.name,
                          maxLines: 1,
                          style: GoogleFonts.montserratTextTheme(
                                  Theme.of(context).textTheme)
                              .headline2
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 0,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: AutoSizeText(
                              'Descrição:',
                              maxLines: 4,
                              style: GoogleFonts.montserratTextTheme(
                                      Theme.of(context).textTheme)
                                  .headline2,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: AutoSizeText(
                              marmita.description,
                              maxLines: 4,
                              style: GoogleFonts.montserratTextTheme(
                                      Theme.of(context).textTheme)
                                  .headline2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: AutoSizeText(
                          price,
                          style: GoogleFonts.montserratTextTheme(
                                  Theme.of(context).textTheme)
                              .headline2
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildReservate(context)
        ],
      ),
    );
  }

  Widget _buildReservate(context) {
    if (seller.canReservate) {
      return Flexible(
        flex: 3,
        child: Container(
          width: 0.6.wp,
          child: ElevatedButton(
            onPressed: () => _showOrderDialog(context, marmita.quantity),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0.05.wp),
              child: AutoSizeText(
                'Reservar',
                maxLines: 1,
                style:
                    GoogleFonts.montserratTextTheme(Theme.of(context).textTheme)
                        .button,
              ),
            ),
          ),
        ),
      );
    } else {
      return Flexible(
        flex: 3,
        child: Container(
          width: 0.6.wp,
          child: AutoSizeText(
            "Esse vendedor não está trabalhando com reservas, mas você ainda pode ver o cardápio do momento.",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme)
                .headline2
                .copyWith(fontWeight: FontWeight.bold, fontSize: 32.nsp),
          ),
        ),
      );
    }
  }

  void _showOrderDialog(context, maxQuantity) async {
    await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        int _quantity = 1;
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 0.1.wp),
              backgroundColor: Color(0xFFF9B152),
              actionsPadding: EdgeInsets.all(10),
              contentPadding: EdgeInsets.only(
                top: 20,
                left: 24,
                right: 24,
                bottom: 0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Confirmar Reserva',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 42.ssp,
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Quantas deseja reservar?',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 28.nsp,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              if (_quantity > 1) {
                                _quantity -= 1;
                              }
                            });
                          },
                          child: Icon(Icons.remove, color: Colors.black),
                          backgroundColor: Colors.white,
                        ),
                        Text(
                          '$_quantity',
                          style: GoogleFonts.montserrat(
                            fontSize: 80.nsp,
                          ),
                        ),
                        FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              if (_quantity < maxQuantity) {
                                _quantity += 1;
                              }
                            });
                          },
                          child: Icon(
                            Icons.add,
                            color: Colors.black,
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.montserrat(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontSize: 34.nsp,
                    ),
                  ),
                ),
                TextButton(
                  child: Text(
                    'Confirmar',
                    style: GoogleFonts.montserrat(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontSize: 34.nsp,
                    ),
                  ),
                  onPressed: () async {
                    final FirebaseUser user =
                        await Repository.instance.getCurrentUser();

                    Order order = Order(
                      clientId: user.uid,
                      clientName: user.displayName,
                      sellerId: seller.id,
                      sellerName: seller.name,
                      mealId: marmita.id,
                      mealName: marmita.name,
                      price: marmita.price,
                      quantity: _quantity,
                      requestedAt: Timestamp.now(),
                      status: "requested",
                    );
                    try {
                      await Repository.instance.addOrder(order);
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Theme.of(ctx).accentColor,
                          content: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "Reserva feita com sucesso.",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );

                      pushNewScreen(
                        context,
                        screen: OrderHistoryScreen(),
                        withNavBar: true,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    } catch (e) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              e.toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          backgroundColor: Theme.of(context).errorColor,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
