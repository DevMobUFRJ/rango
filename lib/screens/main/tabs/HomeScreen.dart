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

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    final String assetName = 'assets/imgs/curva_principal.svg';
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        height: 1.hp - 56,
        child: SingleChildScrollView(
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
                margin:
                    EdgeInsets.only(top: 0.2.hp, left: 0.1.wp, right: 0.1.wp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      margin: EdgeInsets.only(right: 0.02.wp),
                      child: GestureDetector(
                        onTap: () => pushNewScreen(
                          context,
                          screen: OrdersHistory(widget.usuario),
                        ),
                        child: Icon(
                          Icons.history,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 0.23.hp),
                height: 0.68.hp,
                child: StaggeredGridView.countBuilder(
                  padding: EdgeInsets.all(0),
                  crossAxisCount: 1,
                  shrinkWrap: true,
                  itemCount: orders.length,
                  itemBuilder: (ctx, index) => OrderContainer(
                    orders[index],
                    ({bool value}) {
                      setState(() => orders[index].reservada = value);
                    },
                    ({bool value}) {
                      setState(() => {
                            orders[index].vendida = value,
                            orders.removeAt(index),
                          });
                    },
                  ),
                  staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
