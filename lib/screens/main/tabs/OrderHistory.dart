import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/order.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/seller/SellerProfile.dart';
import 'package:rango/utils/string_formatters.dart';
import 'package:http/http.dart' as http;
import 'package:paginate_firestore/paginate_firestore.dart';

class OrderHistoryScreen extends StatefulWidget {
  final PersistentTabController controller;
  OrderHistoryScreen(this.controller);

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String userId;

  @override
  initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser.uid;
  }

  Future<void> _sendCancelOrderNotification(
      String deviceToken, BuildContext context) async {
    try {
      var data = (<String, String>{
        'id': '1',
        'channelId': '1',
        'channelName': 'Reservas',
        'channelDescription':
            'Canal usado para notificações de reservas de quentinhas',
        'status': 'done',
        'description':
            '${FirebaseAuth.instance.currentUser.displayName} cancelou uma reserva com você',
        'payload': 'orders',
        'title': 'Um pedido foi cancelado!',
      });
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Authorization': 'key=${const String.fromEnvironment('MESSAGING_KEY')}',
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText('Histórico',
            style: GoogleFonts.montserrat(
                color: Theme.of(context).accentColor, fontSize: 40.nsp)),
      ),
      body: Container(
        height: 1.hp - 56,
        child: StreamBuilder(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (context, AsyncSnapshot<User> authSnapshot) {
            if (!authSnapshot.hasData ||
                authSnapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 0.5.hp,
                alignment: Alignment.center,
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).accentColor,
                  ),
                ),
              );
            }
            if (authSnapshot.hasError) {
              return Container(
                height: 0.6.hp - 56,
                alignment: Alignment.center,
                child: AutoSizeText(
                  authSnapshot.error.toString(),
                  style: GoogleFonts.montserrat(
                      fontSize: 45.nsp, color: Theme.of(context).accentColor),
                ),
              );
            }

            return PaginateFirestore(
              query: Repository.instance.ordersRef
                  .where('clientId', isEqualTo: userId)
                  .orderBy('requestedAt', descending: true),
              isLive: true,
              itemsPerPage: 10,
              initialLoader: Center(
                child: Container(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
              emptyDisplay: Center(
                child: AutoSizeText(
                  'Pedidos já feitos serão mostrados aqui!',
                  style: GoogleFonts.montserrat(
                    fontSize: 50.nsp,
                    color: Theme.of(context).accentColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              itemBuilderType: PaginateBuilderType.listView,
              itemBuilder: (index, context, snapshot) {
                final Order order = snapshot.data();
                return Card(
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => pushNewScreen(
                            context,
                            withNavBar: false,
                            screen: SellerProfile(
                              order.sellerId,
                              order.sellerName,
                              widget.controller,
                            ),
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          ),
                          child: AutoSizeText(
                            order.sellerName,
                            style: GoogleFonts.montserrat(
                              color: Theme.of(context).accentColor,
                              decoration: TextDecoration.underline,
                              fontSize: 32.nsp,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        buildOrderStatus(order),
                        SizedBox(height: 10),
                        Text('${order.quantity} x ${order.mealName}'),
                        SizedBox(height: 10),
                        Text(
                            'Total: ${intToCurrency(order.price * order.quantity)}'),
                        SizedBox(height: 10),
                      ],
                    ),
                    trailing: buildTrailing(
                      context,
                      order,
                      snapshot.id,
                    ),
                    subtitle: order.requestedAt != null
                        ? Text(
                            '${order.requestedAt?.toDate()?.day}/${order.requestedAt?.toDate()?.month}/${order.requestedAt?.toDate()?.year}',
                          )
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildTrailing(context, Order order, String orderUid) {
    if (order.status != 'sold' && order.status != 'canceled') {
      return IconButton(
          onPressed: () => _showCancelDialog(context, order),
          icon: Icon(Icons.highlight_remove),
          color: Colors.red);
    }
    return null;
  }

  Widget buildOrderStatus(Order order) {
    IconData icon;
    MaterialColor color;
    String text;

    switch (order.status) {
      case 'requested':
        icon = Icons.pending;
        color = Colors.amber;
        text = 'Reserva solicitada';
        break;
      case 'reserved':
        icon = Icons.timelapse;
        color = Colors.green;
        text = 'Reserva confirmada';
        break;
      case 'sold':
        icon = Icons.check_circle;
        color = Colors.blue;
        text = 'Reserva concluída';
        break;
      case 'canceled':
        icon = Icons.cancel;
        color = Colors.red;
        text = 'Reserva cancelada';
        break;
    }

    return Row(
      children: [
        Icon(
          icon,
          color: color,
        ),
        Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(text),
        )
      ],
    );
  }

  void _showCancelDialog(
      BuildContext context, Order order) async {
    await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 0.1.wp),
          backgroundColor: Color(0xFFF9B152),
          actionsPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Cancelando reserva',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 35.nsp,
            ),
          ),
          content: Text(
            'Deseja realmente cancelar este reserva?',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 32.nsp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
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
              child: Text(
                'Cancelar',
                style: GoogleFonts.montserrat(
                  decoration: TextDecoration.underline,
                  color: Colors.white,
                  fontSize: 34.nsp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                try {
                  await Repository.instance.cancelOrderTransaction(order);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: Duration(seconds: 2),
                      backgroundColor: Theme.of(ctx).accentColor,
                      content: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Reserva cancelada com sucesso.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );

                  DocumentSnapshot<Seller> sellerDoc = await Repository.instance.getSellerFuture(order.sellerId);
                  if (sellerDoc.data().deviceToken != null &&
                      sellerDoc.data().notificationSettings != null &&
                      sellerDoc.data().notificationSettings.orders == true) {
                    _sendCancelOrderNotification(sellerDoc.data().deviceToken, ctx);
                  }
                } catch (e) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: Duration(seconds: 2),
                      padding: EdgeInsets.only(bottom: 60),
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
  }
}
