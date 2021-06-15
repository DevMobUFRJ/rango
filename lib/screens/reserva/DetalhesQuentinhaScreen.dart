import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseUser;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/meals.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/order.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/history/OrderHistory.dart';
import 'package:rango/screens/seller/SellerProfile.dart';
import 'package:rango/utils/string_formatters.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

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
    String price = intToCurrency(marmita.price);
    ScreenUtil.init(context, width: 750, height: 1334);
    if (price.length == 6 && price.contains(',')) price = '${price}0';
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => pushNewScreen(
            context,
            screen: SellerProfile(marmita.sellerId, marmita.sellerName),
            withNavBar: true,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          ),
          child: AutoSizeText(
            marmita.sellerName,
            style: GoogleFonts.montserrat(
                color: Theme.of(context).accentColor, fontSize: 40.nsp),
          ),
        ),
      ),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 0.1.hp),
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
                      maxHeight: 0.4.hp,
                      maxWidth: 0.8.wp,
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
                      Flexible(
                        flex: 1,
                        child: Container(
                          height: 50.h,
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
                        flex: 2,
                        child: Container(
                          height: 120.h,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: AutoSizeText(
                              marmita.description,
                              maxLines: 4,
                              style: GoogleFonts.montserratTextTheme(
                                      Theme.of(context).textTheme)
                                  .headline2,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          height: 40.h,
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
              Flexible(
                flex: 3,
                child: Container(
                  width: 0.6.wp,
                  child: RaisedButton(
                    onPressed: () => _showOrderDialog(context, marmita.quantity),
                    padding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 0.05.wp),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AutoSizeText('Reservar',
                        maxLines: 1,
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

  void _showOrderDialog(context, maxQuantity) async {
    await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        int _quantity = 1;
        return StatefulBuilder(
            builder: (context, setState) {
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
                    fontSize: 38.ssp,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Quantos deseja reservar?',
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
                            child: Icon(
                                Icons.remove,
                                color: Colors.black
                            ),
                            backgroundColor: Colors.white,
                          ),
                          Text(
                              '$_quantity',
                              style: TextStyle(fontSize: 80.nsp)
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
                  FlatButton(
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
                  FlatButton(
                    onPressed: () async {
                      final FirebaseUser user = await auth.currentUser();

                      Order order = Order(
                          clientId: user.uid,
                          clientName: user.displayName,
                          sellerId: marmita.sellerId,
                          sellerName: marmita.sellerName,
                          mealId: marmita.id,
                          mealName: marmita.name,
                          price: marmita.price,
                          quantity: _quantity,
                          requestedAt: Timestamp.now(),
                          status: "requested"
                      );
                      try {
                        await Repository.instance.addOrder(order);
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text("Reserva feita com sucesso."),
                          ),
                        ));
                        //TODO Redirecionar para a tela de histórico

                        pushNewScreen(
                          context,
                          screen: OrderHistoryScreen(),
                          withNavBar: true,
                          pageTransitionAnimation: PageTransitionAnimation.cupertino,
                        );
                      } catch (e) {
                        print(e);
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          padding: EdgeInsets.only(bottom: 60),
                          content: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(e.toString()),
                          ),
                          backgroundColor: Theme.of(context).errorColor,
                        ));
                      }
                    },
                    child: Text(
                      'Confirmar',
                      style: GoogleFonts.montserrat(
                        decoration: TextDecoration.underline,
                        color: Colors.white,
                        fontSize: 34.nsp,
                      ),
                    ),
                  ),
                ],
              );
            }
        );
      }
    );
  }
}