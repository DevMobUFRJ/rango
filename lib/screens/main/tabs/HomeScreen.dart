import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/dadosMarretados.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/screens/main/home/OrdersHistory.dart';
import 'package:rango/widgets/home/NoOrdersWidget.dart';
import 'package:rango/widgets/home/OrderContainer.dart';

class HomeScreen extends StatefulWidget {
  final Seller usuario;

  HomeScreen(this.usuario);
  static const String name = 'homeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var orders = pedidos;
  var ordersClosed = pedidosConcluidos;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final String assetName = 'assets/imgs/curva_principal.svg';
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        height: 1.hp - 56,
        child: orders.length < 1 && ordersClosed.length < 1
            ? NoOrdersWidget(assetName: assetName, widget: widget)
            : Stack(
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 0.7.wp,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0.04.wp, vertical: 0.01.hp),
                              child: AutoSizeText(
                                'Olá,\n${widget.usuario.name}!',
                                maxLines: 2,
                                textAlign: TextAlign.start,
                                style: GoogleFonts.montserrat(
                                  color: Colors.deepOrange[300],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 60.nsp,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 50, bottom: 10),
                              padding: EdgeInsets.only(
                                  top: 3, bottom: 3, right: 4, left: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  ScreenUtil().setSp(30),
                                ),
                                color: Theme.of(context).accentColor,
                              ),
                              child: GestureDetector(
                                onTap: () => pushNewScreen(
                                  context,
                                  screen: OrdersHistory(widget.usuario),
                                  withNavBar: false,
                                ),
                                child: Icon(
                                  Icons.history,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 0.1.wp,
                            right: 0.1.wp,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: ordersClosed.length > 1 &&
                                        orders.length < 1
                                    ? Text('')
                                    : AutoSizeText(
                                        "Pedidos do dia",
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color:
                                                Theme.of(context).accentColor,
                                            fontSize: 29.nsp,
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            child: ordersClosed.length > 1 && orders.length < 1
                                ? Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 20,
                                    ),
                                    child: AutoSizeText(
                                      'Você não tem mais pedidos em abertos hoje! Para verificar os pedidos já fechados, clique acima no ícone de histórico.',
                                      style: GoogleFonts.montserrat(
                                        color: Theme.of(context).accentColor,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 36.nsp,
                                      ),
                                    ),
                                  )
                                : AnimatedList(
                                    key: _listKey,
                                    initialItemCount: orders.length,
                                    itemBuilder: (ctx, index, animation) =>
                                        OrderContainer(
                                      orders[index],
                                      ({bool value}) {
                                        setState(() =>
                                            orders[index].reservada = value);
                                      },
                                      ({bool value}) {
                                        var removedItem;
                                        setState(
                                          () => {
                                            orders[index].vendida = value,
                                            removedItem =
                                                orders.removeAt(index),
                                          },
                                        );
                                        _listKey.currentState.removeItem(
                                          index,
                                          (context, animation) =>
                                              SlideTransition(
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
