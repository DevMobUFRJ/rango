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
import 'package:rango/widgets/home/OrderContainer.dart';

class HomeScreen extends StatefulWidget {
  final Seller usuario;
  final PersistentTabController controller;

  HomeScreen(this.usuario, this.controller, {Key key}) : super(key: key);
  static const String name = 'homeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String assetName = 'assets/imgs/curva_principal.svg';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        height: 1.hp - 56,
        child: StreamBuilder(
          stream: Repository.instance.getOpenOrdersFromSeller(widget.usuario.id),
          builder: (context, AsyncSnapshot<List<QueryDocumentSnapshot<Order>>> openOrdersSnapshot) {
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
                      fontSize: 45.nsp, color: Theme.of(context).accentColor),
                ),
              );
            }

            return StreamBuilder(
              stream: Repository.instance
                  .getClosedOrdersFromSeller(widget.usuario.id),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Order>> closedOrdersSnapshot) {
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

                return Column(
                  children: [
                    _buildHeader(assetName, closedOrdersSnapshot.data.docs),
                    if (!widget.usuario.active || !widget.usuario.canReservate) ...{
                      Container(
                        height: 0.6.hp - 56,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () => widget.controller.jumpToTab(2),
                          child: Material(
                            color: Theme.of(context).accentColor,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AutoSizeText(
                                    !widget.usuario.active
                                        ? 'Sua loja está fechada. Para receber pedidos, marque ela como aberta!'
                                        : 'Você não está permitindo reservas. Para receber pedidos, ative a opção "Permitir reservas" nas configurações do perfil.',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 35.nsp,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    child: AutoSizeText(
                                      'Ir para o perfil',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 35.nsp,
                                        color: Colors.white,
                                        decoration: TextDecoration.underline,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    } else if (openOrdersSnapshot.data.isEmpty && closedOrdersSnapshot.data.docs.isEmpty)...{
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(
                          vertical: 0.2.hp,
                          horizontal: 0.05.wp,
                        ),
                        child: AutoSizeText(
                          'Você ainda não recebeu pedidos hoje!\n\nAproveite para gerenciar suas quentinhas e o cardápio de hoje na aba de quentinhas ou configurar horário de funcionamento, localização e outras opções na aba de perfil!',
                          style: GoogleFonts.montserrat(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 36.nsp,
                          ),
                        ),
                      )
                    } else ...{
                      if (closedOrdersSnapshot.data.docs.isNotEmpty &&
                          openOrdersSnapshot.data.isEmpty)
                        Container(
                          margin: EdgeInsets.only(
                            left: 0.1.wp,
                            right: 0.1.wp,
                          ),
                          alignment: Alignment.topLeft,
                          child: AutoSizeText(
                            "Pedidos do dia",
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 29.nsp,
                              ),
                            ),
                          ),
                        ),
                      if (widget.usuario.active)
                        Flexible(
                          flex: 1,
                          child: Container(
                            child: closedOrdersSnapshot.data.docs.isNotEmpty &&
                                    openOrdersSnapshot.data.isEmpty
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
                                    padding: EdgeInsets.only(top: 0),
                                    physics: ClampingScrollPhysics(),
                                    itemCount:
                                        openOrdersSnapshot.data.length,
                                    itemBuilder: (ctx, index) {
                                      return OrderContainer(
                                          openOrdersSnapshot.data[index]
                                              .data(),
                                          null);
                                    },
                                  ),
                          ),
                        ),
                    }
                  ],
                );
              },
            );
          },
        ),
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
          margin: EdgeInsets.only(top: 0.06.hp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 0.7.wp,
                    padding: EdgeInsets.only(
                        left: 0.04.wp, right: 0.04.wp, bottom: 0.01.hp),
                    child: AutoSizeText(
                      'Olá,\n${widget.usuario.name}!',
                      maxLines: 3,
                      textAlign: TextAlign.start,
                      minFontSize: 28,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        color: Colors.deepOrange[300],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => pushNewScreen(
                      context,
                      screen: OrdersHistory(widget.usuario, closedOrders),
                      withNavBar: false,
                    ),
                    child: Container(
                      margin: EdgeInsets.only(left: 50, bottom: 10),
                      padding:
                          EdgeInsets.only(top: 3, bottom: 3, right: 4, left: 3),
                      decoration: ShapeDecoration(
                        shape: CircleBorder(),
                        color: Theme.of(context).accentColor,
                      ),
                      child: Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
