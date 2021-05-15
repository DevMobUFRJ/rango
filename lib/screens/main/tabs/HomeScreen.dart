import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/dadosMarretados.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/screens/main/OrdersHistory.dart';
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

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    final String assetName = 'assets/imgs/curva_principal.svg';
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        height: 1.hp - 56,
        child: orders.length < 1 && ordersClosed.length < 1
            ? SingleChildScrollView(
                child: Stack(
                  children: <Widget>[
                    SvgPicture.asset(
                      assetName,
                      semanticsLabel: 'curvaHome',
                      width: 1.wp,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 0.03.hp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 0.01.hp),
                          Container(
                            width: 0.7.wp,
                            padding: EdgeInsets.symmetric(
                                horizontal: 0.04.wp, vertical: 0.01.hp),
                            child: AutoSizeText(
                              'Olá,\n${widget.usuario.name}!',
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
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(
                        vertical: 0.2.hp,
                        horizontal: 0.05.wp,
                      ),
                      child: AutoSizeText(
                        'Você ainda não recebeu pedidos hoje! Aproveite para gerenciar suas quentinhas e o cardápio de hoje na aba de quentinhas ou configurar horário de funcionamento, localização e outras coisas na aba de perfil!',
                        style: GoogleFonts.montserrat(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 36.nsp,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
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
                          Flexible(
                            flex: 1,
                            child: Container(
                              width: 0.7.wp,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0.04.wp, vertical: 0.01.hp),
                              child: AutoSizeText(
                                'Olá,\n${widget.usuario.name}!',
                                maxLines: 2,
                                textAlign: TextAlign.start,
                                style: GoogleFonts.montserratTextTheme(
                                        Theme.of(context).textTheme)
                                    .headline1,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.only(
                                left: 0.1.wp,
                                right: 0.1.wp,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
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
                                  Container(
                                    margin: EdgeInsets.only(
                                        right: 0.02.wp, bottom: 2),
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
                                      ),
                                      child: Icon(
                                        Icons.history,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            child: Container(
                              constraints: BoxConstraints(maxHeight: 0.68.hp),
                              child: ordersClosed.length > 1 &&
                                      orders.length < 1
                                  ? Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 0.1.wp,
                                        vertical: 8,
                                      ),
                                      child: AutoSizeText(
                                        'Você não tem mais pedidos em abertos hoje!\nPara verificar os pedidos já fechados, clique acima no ícone de histórico.',
                                        style: GoogleFonts.montserrat(
                                          color: Theme.of(context).accentColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 36.nsp,
                                        ),
                                      ),
                                    )
                                  : StaggeredGridView.countBuilder(
                                      padding: EdgeInsets.all(0),
                                      crossAxisCount: 1,
                                      shrinkWrap: true,
                                      itemCount: orders.length,
                                      itemBuilder: (ctx, index) =>
                                          OrderContainer(
                                        orders[index],
                                        ({bool value}) {
                                          setState(() =>
                                              orders[index].reservada = value);
                                        },
                                        ({bool value}) {
                                          setState(() => {
                                                orders[index].vendida = value,
                                                orders.removeAt(index),
                                              });
                                        },
                                      ),
                                      staggeredTileBuilder: (index) =>
                                          StaggeredTile.fit(1),
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
