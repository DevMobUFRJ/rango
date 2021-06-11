import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/models/order.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/utils/string_formatters.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

class OrderHistoryScreen extends StatelessWidget {
  OrderHistoryScreen();

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
                              Text(order.sellerName),
                              buildOrderStatus(order),
                              Text('${order.quantity} x ${order.mealName}'),
                              Text('${intToCurrency(order.price*order.quantity)}')
                            ],
                          ),
                          subtitle: Text('${order.requestedAt?.toDate()?.day}/${order.requestedAt?.toDate()?.month}/${order.requestedAt?.toDate()?.year}'),
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
}