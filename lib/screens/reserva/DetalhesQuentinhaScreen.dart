import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/meals.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/order.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/seller/SellerProfile.dart';
import 'package:rango/utils/constants.dart';
import 'package:rango/utils/string_formatters.dart';

class DetalhesQuentinhaScreen extends StatefulWidget {
  final Meal marmita;
  final Seller seller;
  final double tagM;
  final bool isFromSellerScreen;
  final PersistentTabController controller;

  DetalhesQuentinhaScreen({
    @required this.marmita,
    @required this.seller,
    @required this.controller,
    this.tagM,
    this.isFromSellerScreen = false,
  });

  static const routeName = '/detalhes-reserva-quentinha';

  @override
  _DetalhesQuentinhaScreenState createState() =>
      _DetalhesQuentinhaScreenState();
}

class _DetalhesQuentinhaScreenState extends State<DetalhesQuentinhaScreen> {
  bool _doingOrder = false;

  @override
  Widget build(BuildContext context) {
    String price = intToCurrency(widget.marmita.price);
    if (price.length == 6 && price.contains(',')) price = '${price}0';
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: widget.isFromSellerScreen
              ? null
              : () => pushNewScreen(
                    context,
                    withNavBar: false,
                    screen: SellerProfile(
                      widget.seller.id,
                      widget.seller.name,
                      widget.controller,
                    ),
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  ),
          child: AutoSizeText(
            widget.seller.name,
            style: GoogleFonts.montserrat(
              color: Theme.of(context).accentColor,
              fontSize: 40.nsp,
              decoration: widget.isFromSellerScreen
                  ? TextDecoration.none
                  : TextDecoration.underline,
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
                  tag: widget.marmita.hashCode * widget.tagM,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: widget.marmita.picture,
                    placeholder: (ctx, url) => Image(
                      image:
                          AssetImage('assets/imgs/quentinha_placeholder.png'),
                    ),
                    errorWidget: (ctx, url, error) => Image(
                      image:
                          AssetImage('assets/imgs/quentinha_placeholder.png'),
                    ),
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
                          widget.marmita.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserratTextTheme(
                                  Theme.of(context).textTheme)
                              .headline2
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 38.nsp,
                              ),
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
                                  .headline2
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 35.nsp,
                                  ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: AutoSizeText(
                              widget.marmita.description,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 7,
                              style: GoogleFonts.montserratTextTheme(
                                      Theme.of(context).textTheme)
                                  .headline2
                                  .copyWith(
                                    fontSize: 35.nsp,
                                    fontWeight: FontWeight.w500,
                                  ),
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
    if (widget.seller.canReservate) {
      return Flexible(
        flex: 3,
        child: Container(
          width: 0.4.wp,
          child: ElevatedButton(
            onPressed: () => _showOrderDialog(context, widget.marmita.quantity),
            child: AutoSizeText(
              'Reservar',
              maxLines: 1,
              style:
                  GoogleFonts.montserratTextTheme(Theme.of(context).textTheme)
                      .button,
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
            "Esse vendedor não está trabalhando com reservas, mas você ainda pode ver o cardápio atual.",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme)
                .headline2
                .copyWith(fontWeight: FontWeight.bold, fontSize: 32.nsp),
          ),
        ),
      );
    }
  }

  Future<void> _sendOrderNotification(
      String deviceToken, BuildContext context) async {
    try {
      var data = (<String, String>{
        'id': '1',
        'channelId': '1',
        'channelName': 'Reservas',
        'channelDescription':
            'Canal usado para notificações reservas de quentinhas',
        'status': 'done',
        'description':
            '${FirebaseAuth.instance.currentUser.displayName} fez uma reserva com você',
        'payload': 'orders',
        'title': 'Novo pedido recebido!',
      });
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Authorization': 'key=$firabaseMessagingAuthorizationKey',
          'content-type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(<String, dynamic>{
          'priority': 'high',
          'data': data,
          'to': deviceToken,
        }),
      );
    } catch (error) {
      print(error);
    }
  }

  void _showOrderDialog(context, maxQuantity) async {
    await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        int _quantity = 1;
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return _doingOrder
                ? AlertDialog(
                    insetPadding: EdgeInsets.symmetric(horizontal: 0.1.wp),
                    backgroundColor: Color(0xFFF9B152),
                    actionsPadding: EdgeInsets.all(10),
                    contentPadding: EdgeInsets.only(
                      top: 20,
                      left: 14,
                      right: 14,
                      bottom: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      'Reservando',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 42.ssp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : AlertDialog(
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
                            fontSize: 32.nsp,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                child: FloatingActionButton(
                                  onPressed: () {
                                    setState(() {
                                      if (_quantity > 1) {
                                        _quantity -= 1;
                                      }
                                    });
                                  },
                                  child:
                                      Icon(Icons.remove, color: Colors.black),
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              Text(
                                '$_quantity',
                                style: GoogleFonts.montserrat(
                                  fontSize: 80.nsp,
                                ),
                              ),
                              Container(
                                height: 50,
                                width: 50,
                                child: FloatingActionButton(
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          setState(() => _doingOrder = true);
                          final User user =
                              Repository.instance.getCurrentUser();
                          Order order = Order(
                            clientId: user.uid,
                            clientName: user.displayName,
                            sellerId: widget.seller.id,
                            sellerName: widget.seller.name,
                            mealId: widget.marmita.id,
                            mealName: widget.marmita.name,
                            price: widget.marmita.price,
                            quantity: _quantity,
                            requestedAt: Timestamp.now(),
                            status: "requested",
                          );
                          try {
                            await Repository.instance.addOrder(order);
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                                  SnackBar(
                                    backgroundColor: Theme.of(ctx).accentColor,
                                    duration: Duration(seconds: 1),
                                    content: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        "Reserva feita com sucesso.",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                )
                                .closed
                                .then((_) => Navigator.of(context)
                                    .popUntil(ModalRoute.withName("/")));

                            if (widget.seller.deviceToken != null &&
                                widget.seller.notificationSettings != null &&
                                widget.seller.notificationSettings.orders ==
                                    true) {
                              await _sendOrderNotification(
                                  widget.seller.deviceToken, ctx);
                            }

                            setState(() => widget.controller.jumpToTab(2));
                          } catch (e) {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(seconds: 2),
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
