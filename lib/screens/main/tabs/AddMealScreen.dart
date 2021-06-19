import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/dadosMarretados.dart';
import 'package:rango/models/seller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/screens/main/meals/ManageOrder.dart';
import 'package:rango/screens/main/meals/MealsHistory.dart';
import 'package:rango/widgets/home/GridHorizontal.dart';

class AddMealScreen extends StatefulWidget {
  final Seller usuario;

  AddMealScreen(this.usuario);

  @override
  _AddMealScreenState createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    final String assetName = 'assets/imgs/curva_principal.svg';
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        child: pedidos.length < 1
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      SvgPicture.asset(
                        assetName,
                        semanticsLabel: 'curvaHome',
                        width: 1.wp,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(
                              left: 0.02.wp, top: 0.07.hp, bottom: 0.01.hp),
                          width: 0.6.wp,
                          child: AutoSizeText(
                            "E aí, o que tem pra hoje?",
                            maxLines: 2,
                            textAlign: TextAlign.start,
                            style: GoogleFonts.montserrat(
                              color: Colors.deepOrange[300],
                              fontWeight: FontWeight.w500,
                              fontSize: 60.nsp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    flex: 4,
                    child: Container(
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 0.03.wp),
                              child: AutoSizeText(
                                "Cardápio do dia",
                                style: GoogleFonts.montserrat(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 30.ssp,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            child: AutoSizeText(
                                'Você ainda não configurou o cardápio do dia!\nClique nos botões abaixo para fazer isso:',
                                style: GoogleFonts.montserrat(
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 36.nsp,
                                )),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    margin: EdgeInsets.only(right: 0.05.wp),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () => pushNewScreen(context,
                                          screen: ManageOrder()),
                                      child: AutoSizeText(
                                        "Adicionar",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 32.nsp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () => pushNewScreen(
                                        context,
                                        screen: MealsHistory(orders: pedidos),
                                      ),
                                      child: AutoSizeText(
                                        "Histórico",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 32.nsp,
                                        ),
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
                  ),
                  Flexible(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AutoSizeText(
                          "Adicionar pratos já cadastrados:",
                          style: GoogleFonts.montserrat(
                            color: Theme.of(context).accentColor,
                            fontSize: 32.nsp,
                          ),
                        ),
                        Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: AutoSizeText(
                              'Aqui irão aparecer quentinhas antigas para serem adicionadas rapidamente ao cardápio do dia!',
                              style: GoogleFonts.montserrat(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 36.nsp,
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      SvgPicture.asset(
                        assetName,
                        semanticsLabel: 'curvaHome',
                        width: 1.wp,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(
                              left: 0.02.wp, top: 0.07.hp, bottom: 0.01.hp),
                          width: 0.6.wp,
                          child: AutoSizeText(
                            "E aí, o que tem pra hoje?",
                            maxLines: 2,
                            textAlign: TextAlign.start,
                            style: GoogleFonts.montserrat(
                              color: Colors.deepOrange[300],
                              fontWeight: FontWeight.w500,
                              fontSize: 60.nsp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    flex: 4,
                    child: Container(
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 0.03.wp),
                              child: AutoSizeText(
                                "Cardápio do dia",
                                style: GoogleFonts.montserrat(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 30.ssp,
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: pedidos.length > 6 ? 3 : 1,
                            child: Container(
                              child: GridHorizontal(
                                orders: pedidos,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      margin: EdgeInsets.only(right: 0.05.wp),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () => pushNewScreen(context,
                                            screen: ManageOrder()),
                                        child: AutoSizeText(
                                          "Adicionar",
                                          style: GoogleFonts.montserrat(
                                            fontSize: 32.nsp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () => pushNewScreen(
                                          context,
                                          screen: MealsHistory(orders: pedidos),
                                        ),
                                        child: AutoSizeText(
                                          "Histórico",
                                          style: GoogleFonts.montserrat(
                                            fontSize: 32.nsp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Column(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.center,
                            child: AutoSizeText(
                              "Adicionar pratos já cadastrados:",
                              style: GoogleFonts.montserrat(
                                color: Theme.of(context).accentColor,
                                fontSize: 32.nsp,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 9,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0.2.wp),
                            child: Container(
                              child: ListView.builder(
                                padding: EdgeInsets.all(0),
                                itemCount: pedidos.length,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemBuilder: (ctx, index) => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      constraints:
                                          BoxConstraints(maxWidth: 0.5.wp),
                                      child: GestureDetector(
                                        onTap: () => {},
                                        child: AutoSizeText(
                                          pedidos[index]
                                              .quentinhas[0]
                                              .quentinha
                                              .name,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            color: Color(0xFFF9B152),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 28.ssp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.add_circle,
                                      color: Color(0xFFF9B152),
                                    ),
                                  ],
                                ),
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
