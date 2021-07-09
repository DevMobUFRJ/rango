import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/order.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/widgets/home/OrderContainer.dart';

class OrdersHistory extends StatefulWidget {
  final Seller usuario;
  List <DocumentSnapshot<Order>> closedOrders;

  OrdersHistory(this.usuario, this.closedOrders);
  static const String name = 'OrdersHistory';

  @override
  _OrdersHistoryState createState() => _OrdersHistoryState();
}

class _OrdersHistoryState extends State<OrdersHistory> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final String assetName = 'assets/imgs/curva_principal.svg';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        child: Stack(
          children: <Widget>[
            SvgPicture.asset(
              assetName,
              semanticsLabel: 'curvaHome',
              width: 1.wp,
            ),
            Container(
              margin: EdgeInsets.only(top: 0.07.hp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 0.7.wp,
                    padding: EdgeInsets.symmetric(
                        horizontal: 0.04.wp, vertical: 0.024.hp),
                    child: AutoSizeText(
                      'Pedidos concluídos do dia',
                      maxLines: 2,
                      textAlign: TextAlign.start,
                      style: GoogleFonts.montserrat(
                        color: Colors.deepOrange[300],
                        fontWeight: FontWeight.w500,
                        fontSize: 60.nsp,
                      ),
                    ),
                  ),
                  if (widget.closedOrders.isEmpty) ...{
                    Flexible(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText(
                            'Você ainda não possui pedidos concluídos!',
                            style: GoogleFonts.montserrat(
                              color: Theme
                                  .of(context)
                                  .accentColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 52.nsp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  } else ...{
                    Flexible(
                      flex: 1,
                      child: Container(
                        child: ListView.builder(
                            padding: EdgeInsets.only(top: 20),
                            itemCount: widget.closedOrders.length,
                            itemBuilder: (ctx, index) {
                              return OrderContainer(
                                  widget.closedOrders[index].data(),
                                  () {
                                    widget.closedOrders.removeAt(index);
                                    setState(() {});
                                  }
                              );
                            }
                        ),
                      ),
                    )
                  }
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
