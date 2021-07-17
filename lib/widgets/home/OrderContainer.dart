import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/order.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/main/home/ClientProfile.dart';
import 'package:rango/utils/constants.dart';
import 'package:rango/utils/string_formatters.dart';
import 'package:http/http.dart' as http;

class OrderContainer extends StatefulWidget {
  final Order pedido;
  final void Function() undoSellOrderCallback;

  OrderContainer(this.pedido, this.undoSellOrderCallback);

  @override
  _OrderContainerState createState() => _OrderContainerState();
}

class _OrderContainerState extends State<OrderContainer>
    with TickerProviderStateMixin {
  Client _client;
  AnimationController swipeRightController;
  AnimationController swipeLeftController;
  Animatable swipeAnimatable;

  @override
  void initState() {
    super.initState();
    _getClient(widget.pedido.sellerId);
    swipeRightController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    swipeLeftController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    swipeAnimatable = Tween<Offset>(begin: Offset.zero, end: Offset(1, 0))
        .chain(CurveTween(curve: Curves.easeIn));
  }

  @override
  Widget build(BuildContext context) {
    swipeRightController.reset();
    swipeLeftController.reset();
    return SlideTransition(
      position: swipeRightController.drive(swipeAnimatable),
      textDirection: TextDirection.ltr,
      child: SlideTransition(
        position: swipeLeftController.drive(swipeAnimatable),
        textDirection: TextDirection.rtl,
        child: Container(
          child: Center(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: widget.pedido.status == 'sold'
                      ? Colors.grey
                      : Color(0xFFF9B152),
                  child: ConstrainedBox(
                    constraints: new BoxConstraints(
                      minWidth: 0.85.wp,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 0.4.wp,
                          margin: EdgeInsets.only(left: 12, top: 8, bottom: 8),
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => pushNewScreen(
                                  context,
                                  screen: ClientProfile(widget.pedido.clientId),
                                  withNavBar: false,
                                ),
                                child: AutoSizeText(
                                  widget.pedido.clientName,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 29.nsp,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              AutoSizeText(
                                '${widget.pedido.quantity}x ${widget.pedido.mealName}',
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26.nsp,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2),
                              AutoSizeText(
                                'Valor total: ${intToCurrency(widget.pedido.quantity * widget.pedido.price)}',
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26.nsp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 0.06.wp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Theme(
                                    data: ThemeData(
                                        unselectedWidgetColor: Colors.white),
                                    child: SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        checkColor:
                                            widget.pedido.status == 'sold'
                                                ? Colors.grey
                                                : Color(0xFFF9B152),
                                        activeColor: Colors.white,
                                        value: widget.pedido.status ==
                                                'reserved' ||
                                            widget.pedido.status == 'sold',
                                        onChanged: (reserved) async {
                                          try {
                                            if (reserved &&
                                                widget.pedido.status ==
                                                    'requested') {
                                              await Repository.instance
                                                  .reserveOrderTransaction(
                                                      widget.pedido);
                                              _showOrderUpdateNotification(
                                                  'reservated');
                                            } else if (!reserved &&
                                                widget.pedido.status ==
                                                    'reserved') {
                                              await Repository.instance
                                                  .undoReserveOrderTransaction(
                                                      widget.pedido);
                                              _showOrderUpdateNotification(
                                                  'undoReservate');
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  e.toString(),
                                                  textAlign: TextAlign.center,
                                                ),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .errorColor,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Reservado",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.018.hp),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Theme(
                                    data: ThemeData(
                                        unselectedWidgetColor: Colors.white),
                                    child: SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        checkColor:
                                            widget.pedido.status == 'sold'
                                                ? Colors.grey
                                                : Color(0xFFF9B152),
                                        activeColor: Colors.white,
                                        value: widget.pedido.status == 'sold',
                                        onChanged: (sold) async {
                                          if (sold &&
                                              widget.pedido.status ==
                                                  'requested') {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Confirme a reserva antes de marca-lá como vendida.",
                                                  textAlign: TextAlign.center,
                                                ),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .errorColor,
                                              ),
                                            );
                                            return;
                                          }
                                          try {
                                            if (sold &&
                                                widget.pedido.status ==
                                                    'reserved') {
                                              swipeRightController
                                                  .forward()
                                                  .then((_) async {
                                                await Repository.instance
                                                    .sellOrder(
                                                        widget.pedido.id);

                                                _showOrderUpdateNotification(
                                                    'sold');
                                              });
                                            } else if (!sold &&
                                                widget.pedido.status ==
                                                    'sold') {
                                              swipeLeftController
                                                  .forward()
                                                  .then((_) async {
                                                await Repository.instance
                                                    .undoSellOrder(
                                                        widget.pedido.id);
                                                widget.undoSellOrderCallback();

                                                _showOrderUpdateNotification(
                                                    'undoSold');
                                              });
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Ocorreu um erro.',
                                                  textAlign: TextAlign.center,
                                                ),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .errorColor,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Vendido",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.pedido.status != 'sold') ...{
                  GestureDetector(
                    onTap: () => _cancelOrder(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.red[400],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                },
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getClient(String sellerId) async {
    Client client = await Repository.instance.clientsRef
        .doc(widget.pedido.clientId)
        .get()
        .then((value) => value.data());
    setState(() => _client = client);
  }

  void _showOrderUpdateNotification(String update) async {
    String titleMessage;
    String descriptionMessage;
    String sellerName = FirebaseAuth.instance.currentUser.displayName;
    String mealName = widget.pedido.mealName;
    switch (update) {
      case 'reservated':
        titleMessage = 'Sua reserva foi confirmada!';
        descriptionMessage = '$sellerName confirmou sua reserva de $mealName';
        break;
      case 'sold':
        titleMessage = 'Sua reserva foi finalizada!';
        descriptionMessage =
            '$sellerName marcou sua reserva de $mealName como vendida!';
        break;
      case 'undoReservate':
        titleMessage = 'Sua reserva foi desconfirmada!';
        descriptionMessage =
            '$sellerName desconfirmou sua reserva de $mealName';
        break;
      case 'undoSold':
        titleMessage = 'Sua reserva foi marcada como não vendida!';
        descriptionMessage =
            '$sellerName desmarcou que sua reserva de $mealName foi vendida';
        break;
      case 'cancelled':
        titleMessage = 'Sua reserva foi cancelada!';
        descriptionMessage = '$sellerName cancelou sua reserva de $mealName';
        break;
      default:
        titleMessage = 'Sua reserva teve atualização!';
        descriptionMessage =
            '$sellerName atualizou o estado da sua reserva de $mealName';
        break;
    }
    try {
      var data = (<String, String>{
        'id': '2',
        'channelId': '2',
        'channelName': 'Pedidos',
        'channelDescription': 'Canal usado para notificações de pedidos',
        'status': 'done',
        'description': descriptionMessage,
        'payload': 'orders',
        'title': titleMessage,
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
          'to': _client.deviceToken,
        }),
      );
    } catch (error) {
      print(error);
    }
  }

  void _cancelOrder() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Voltar',
              style: GoogleFonts.montserrat(
                decoration: TextDecoration.underline,
                color: Colors.white,
                fontSize: 34.nsp,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await Repository.instance.cancelOrder(widget.pedido);
                _showOrderUpdateNotification('cancelled');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 2),
                    content: Text(
                      'Ocorreu um erro ao cancelar o pedido.',
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: Theme.of(context).errorColor,
                  ),
                );
              }
            },
            child: Text(
              'Cancelar',
              style: GoogleFonts.montserrat(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 34.nsp,
              ),
            ),
          ),
        ],
        title: Text(
          'Cancelando reserva',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 38.ssp,
          ),
        ),
        content: Text(
          'Deseja realmente cancelar esta reserva?',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 28.nsp,
          ),
        ),
      ),
    );
  }
}
