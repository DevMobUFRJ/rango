import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/order.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/seller/SellerProfile.dart';
import 'package:rango/utils/string_formatters.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

class OrderHistoryScreen extends StatelessWidget {
  OrderHistoryScreen();

  Widget buildTrailing(context, Order order, String orderUid) {
    if (order.status != 'sold' && order.status != 'canceled') {
      return IconButton(
          onPressed: () => _showCancelDialog(context, order, orderUid),
          icon: Icon(Icons.highlight_remove),
          color: Colors.red
      );
    }

    return null;
  }

  Widget buildOrderStatus(Order order) {
    IconData icon;
    MaterialColor color;
    String text;

    switch (order.status){
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

  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    return Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
              'Histórico',
              style: GoogleFonts.montserrat(
                  color: Theme.of(context).accentColor, fontSize: 40.nsp)
          ),
        ),
        body: Container(
          child: FutureBuilder(
            future: auth.currentUser(),
            builder: (context, AsyncSnapshot<FirebaseUser> authSnapshot) {
              if (!authSnapshot.hasData) {
                return CircularProgressIndicator();
              }
              if (authSnapshot.hasError) {
                return Text(authSnapshot.error.toString());
              }

              return StreamBuilder(
                stream: Repository.instance.getOrdersFromClient(authSnapshot.data.uid),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }

                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      Order order = Order.fromJson(snapshot.data.documents[index].data);
                      return Card(
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => pushNewScreen(
                                  context,
                                  screen: SellerProfile(order.sellerId, order.sellerName),
                                  withNavBar: true,
                                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                ),
                                child: Text(order.sellerName),
                              ),
                              SizedBox(height: 10),
                              buildOrderStatus(order),
                              SizedBox(height: 10),
                              Text('${order.quantity} x ${order.mealName}'),
                              SizedBox(height: 10),
                              Text('Total: ${intToCurrency(order.price*order.quantity)}'),
                              SizedBox(height: 10),
                            ],
                          ),
                          trailing: buildTrailing(context, order, snapshot.data.documents[index].documentID),
                          subtitle: order.requestedAt != null
                              ? Text('${order.requestedAt?.toDate()?.day}/${order.requestedAt?.toDate()?.month}/${order.requestedAt?.toDate()?.year}')
                              : null,
                        ),
                      );
                    },
                  );
                },
              );
            },
          )
        )
    );
  }

  void _showCancelDialog(context, order, orderUid) async {
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
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
              'Cancelar Reserva',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 38.ssp,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tem certeza?',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 28.nsp,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        'Não',
                        style: GoogleFonts.montserrat(
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                          fontSize: 34.nsp,
                        ),
                      ),
                    ),
                    FlatButton(
                      onPressed: () async {
                        try {
                          await Repository.instance.cancelOrder(orderUid);
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text("Reserva cancelada com sucesso."),
                            ),
                          ));
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
                        'Sim',
                        style: GoogleFonts.montserrat(
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                          fontSize: 34.nsp,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }
    );
  }
}