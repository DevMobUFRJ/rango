import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/order.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/widgets/home/OrderContainer.dart';

class OrdersHistory extends StatefulWidget {
  final Seller usuario;

  OrdersHistory(this.usuario);
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
                        horizontal: 0.04.wp, vertical: 0.01.hp),
                    child: AutoSizeText(
                      'Histórico de pedidos',
                      maxLines: 2,
                      textAlign: TextAlign.start,
                      style: GoogleFonts.montserrat(
                        color: Colors.deepOrange[300],
                        fontWeight: FontWeight.w500,
                        fontSize: 60.nsp,
                      ),
                    ),
                  ),
                  StreamBuilder(
                    stream: Repository.instance.getOrdersFromSeller(widget.usuario.id),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.connectionState == ConnectionState.waiting) {
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

                      if (snapshot.hasError) {
                        return Container(
                          height: 0.6.hp - 56,
                          alignment: Alignment.center,
                          child: AutoSizeText(
                            snapshot.error.toString(),
                            style: GoogleFonts.montserrat(
                                fontSize: 45.nsp,
                                color: Theme.of(context).accentColor),
                          ),
                        );
                      }

                      if (snapshot.data.documents.isEmpty) {
                        return Flexible(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                'Você ainda não possui pedidos finalizados!',
                                style: GoogleFonts.montserrat(
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 52.nsp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return Flexible(
                        flex: 1,
                        child: Container(
                          child: AnimatedList(
                            key: _listKey,
                            initialItemCount: snapshot.data.documents.length,
                            itemBuilder: (ctx, index, animation) {
                              Order order = Order.fromJson(snapshot.data.documents[index].data);
                              return OrderContainer(
                                order,
                                ({String value}) {
                                  setState(() => order.status = value);
                                  //TODO Atualizar no firebase
                                },
                                ({String value}) {
                                  var removedItem;
                                  setState(() => {
                                    order.status = value,
                                    //TODO Atualizar no firebase
                                    removedItem = snapshot.data.documents.removeAt(index),
                                  });
                                  _listKey.currentState.removeItem(
                                    index,
                                    (context, animation) => SlideTransition(
                                      position: animation.drive(
                                        Tween<Offset>(
                                          begin: Offset(1, 0),
                                          end: Offset.zero,
                                        ),
                                      ),
                                      child: OrderContainer(
                                        removedItem,
                                        ({String value}) => {},
                                        ({String value}) => {},
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          ),
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
