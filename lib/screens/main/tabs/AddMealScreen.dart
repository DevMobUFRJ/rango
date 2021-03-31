import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/dadosMarretados.dart';
import 'package:rango/models/seller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/screens/seller/ManageOrder.dart';

class AddMealScreen extends StatefulWidget {
  final Seller usuario;

  AddMealScreen(this.usuario);

  @override
  _AddMealScreenState createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  @override
  Widget build(BuildContext context) {
    final String assetName = 'assets/imgs/curva_principal.svg';
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        constraints: BoxConstraints(maxWidth: 1.wp, maxHeight: 1.hp),
        child: Column(
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
                    margin: EdgeInsets.symmetric(
                        horizontal: 0.02.wp, vertical: 0.04.hp),
                    width: 0.6.wp,
                    child: AutoSizeText(
                      "E aí, o que tem pra hoje?",
                      maxLines: 2,
                      textAlign: TextAlign.start,
                      style: GoogleFonts.montserratTextTheme(
                              Theme.of(context).textTheme)
                          .headline1,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 0.04.hp,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 0.04.wp),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AutoSizeText(
                    "Cardápio do dia",
                    textAlign: TextAlign.start,
                    style: GoogleFonts.montserrat(
                      color: Theme.of(context).accentColor,
                      fontSize: 28.ssp,
                    ),
                  ),
                  SizedBox(height: 0.01.hp),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 0.8.wp,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 0.1.wp),
                        onPressed: () =>
                            pushNewScreen(context, screen: ManageOrder()),
                        child: AutoSizeText("Adicionar prato"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 0.02.hp,
            ),
            Container(
              margin:
                  EdgeInsets.symmetric(horizontal: 0.04.wp, vertical: 0.01.hp),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AutoSizeText(
                  "Adicionar pratos já cadastrados:",
                  style: GoogleFonts.montserrat(
                    color: Theme.of(context).accentColor,
                    fontSize: 28.ssp,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.2.wp),
              child: ListView.builder(
                padding: EdgeInsets.all(0),
                itemCount: pedidos.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (ctx, index) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: 0.5.wp),
                      child: AutoSizeText(
                        pedidos[index].quentinha.name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          color: Color(0xFFF9B152),
                          fontWeight: FontWeight.w500,
                          fontSize: 28.ssp,
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
          ],
        ),
      ),
    );
  }
}
