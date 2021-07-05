import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/order.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
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
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final String assetName = 'assets/imgs/curva_principal.svg';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        height: 1.hp - 56,
        child: StreamBuilder(
          stream: Repository.instance.getOpenOrdersFromSeller(widget.usuario.id),
          builder: (context, AsyncSnapshot<QuerySnapshot> openOrdersSnapshot) {
            if (!openOrdersSnapshot.hasData ||
                openOrdersSnapshot.connectionState == ConnectionState.waiting) {
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

            if (openOrdersSnapshot.hasError) {
              return Container(
                height: 0.6.hp - 56,
                alignment: Alignment.center,
                child: AutoSizeText(
                  openOrdersSnapshot.error.toString(),
                  style: GoogleFonts.montserrat(
                      fontSize: 45.nsp,
                      color: Theme.of(context).accentColor),
                ),
              );
            }

            return StreamBuilder(
              stream: Repository.instance.getClosedOrdersFromSeller(widget.usuario.id),
              builder: (context, AsyncSnapshot<QuerySnapshot> closedOrdersSnapshot) {
                if (!closedOrdersSnapshot.hasData) {
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

                if (closedOrdersSnapshot.hasError) {
                  return Container(
                    height: 0.6.hp - 56,
                    alignment: Alignment.center,
                    child: AutoSizeText(
                      closedOrdersSnapshot.error.toString(),
                      style: GoogleFonts.montserrat(
                          fontSize: 45.nsp,
                          color: Theme.of(context).accentColor),
                    ),
                  );
                }
                
                if (openOrdersSnapshot.data.documents.isEmpty && closedOrdersSnapshot.data.documents.isEmpty) {
                  return NoOrdersWidget(assetName: assetName, widget: widget);
                }
                
                return Column(
                  children: [
                    _buildHeader(assetName, closedOrdersSnapshot.data.documents),
                    Container(
                      margin: EdgeInsets.only(
                        left: 0.1.wp,
                        right: 0.1.wp,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: closedOrdersSnapshot.data.documents.isEmpty && openOrdersSnapshot.data.documents.isEmpty
                                ? SizedBox()
                                : AutoSizeText(
                              "Pedidos do dia",
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: Theme.of(context).accentColor,
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
                        child: closedOrdersSnapshot.data.documents.isNotEmpty && openOrdersSnapshot.data.documents.isEmpty
                            ? Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 20,
                                ),
                                child: AutoSizeText(
                                  'Você não tem mais pedidos em aberto hoje! Para verificar os pedidos já fechados, clique acima no ícone de histórico.',
                                  style: GoogleFonts.montserrat(
                                    color: Theme.of(context).accentColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 36.nsp,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                physics: ClampingScrollPhysics(),
                                key: _listKey,
                                itemCount: openOrdersSnapshot.data.documents.length,
                                itemBuilder: (ctx, index) {
                                  Order order = Order.fromJson(
                                      openOrdersSnapshot.data.documents[index].data,
                                      id: openOrdersSnapshot.data.documents[index].documentID
                                  );
                                  return OrderContainer(order);
                                },
                            ),
                      ),
                    ),
                  ],
                );
              }
            );
          }
        )
      ),
    );
  }

  Widget _buildHeader(String assetName, List<DocumentSnapshot> closedOrders) {
    return Stack(
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
                        screen: OrdersHistory(widget.usuario, closedOrders),
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
            ],
          ),
        ),
      ],
    );
  }
}
