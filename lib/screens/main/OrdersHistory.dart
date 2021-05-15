import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/dadosMarretados.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/widgets/home/OrderContainer.dart';

class OrdersHistory extends StatefulWidget {
  final Seller usuario;

  OrdersHistory(this.usuario);
  static const String name = 'OrdersHistory';

  @override
  _OrdersHistoryState createState() => _OrdersHistoryState();
}

class _OrdersHistoryState extends State<OrdersHistory> {
  var orders = pedidosConcluidos;
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
        child: SingleChildScrollView(
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 0.01.hp),
                          Container(
                            width: 0.7.wp,
                            padding: EdgeInsets.symmetric(
                                horizontal: 0.04.wp, vertical: 0.01.hp),
                            child: AutoSizeText(
                              'Histórico de pedidos',
                              maxLines: 2,
                              textAlign: TextAlign.start,
                              style: GoogleFonts.montserratTextTheme(
                                      Theme.of(context).textTheme)
                                  .headline1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    orders.length == 0
                        ? Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 0.05.wp,
                            ),
                            child: AutoSizeText(
                              'Você ainda não possui pedidos finalizados hoje!',
                              style: GoogleFonts.montserrat(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 36.nsp,
                              ),
                            ),
                          )
                        : Container(
                            constraints: BoxConstraints(maxHeight: 0.7.hp),
                            child: AnimatedList(
                              key: _listKey,
                              initialItemCount: orders.length,
                              itemBuilder: (ctx, index, animation) =>
                                  OrderContainer(
                                orders[index],
                                ({bool value}) {
                                  setState(
                                      () => orders[index].reservada = value);
                                },
                                ({bool value}) {
                                  var removedItem;
                                  setState(
                                    () => {
                                      removedItem = orders.removeAt(index),
                                    },
                                  );
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
                                        ({bool value}) => {},
                                        ({bool value}) => {},
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
