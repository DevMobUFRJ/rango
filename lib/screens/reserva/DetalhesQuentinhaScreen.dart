import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/meals.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/screens/seller/SellerProfile.dart';

class DetalhesQuentinhaScreen extends StatelessWidget {
  final Meal marmita;
  final double tagM;

  DetalhesQuentinhaScreen({
    this.marmita,
    this.tagM,
  });

  static const routeName = '/detalhes-reserva-quentinha';
  @override
  Widget build(BuildContext context) {
    String price = 'R\$${marmita.price.toString().replaceAll('.', ',')}';
    ScreenUtil.init(context, width: 750, height: 1334);
    if (price.length == 6 && price.contains(',')) price = '${price}0';
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => pushNewScreen(
            context,
            screen: SellerProfile(marmita.sellerName),
            withNavBar: true,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          ),
          child: AutoSizeText(
            marmita.sellerName,
            style: GoogleFonts.montserrat(
                color: Theme.of(context).accentColor, fontSize: 40.nsp),
          ),
        ),
      ),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 0.1.hp),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Card(
                  margin: EdgeInsets.only(top: 10),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 0.4.hp,
                      maxWidth: 0.8.wp,
                    ),
                    child: Hero(
                      tag: marmita.hashCode * tagM,
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/imgs/quentinha_placeholder.png',
                        image: marmita.picture,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 25),
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Container(
                          height: 50.h,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: AutoSizeText(
                              marmita.name,
                              maxLines: 1,
                              style: GoogleFonts.montserratTextTheme(
                                      Theme.of(context).textTheme)
                                  .headline2
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Container(
                          height: 120.h,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: AutoSizeText(
                              marmita.description,
                              maxLines: 4,
                              style: GoogleFonts.montserratTextTheme(
                                      Theme.of(context).textTheme)
                                  .headline2,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          height: 40.h,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: AutoSizeText(
                              price,
                              style: GoogleFonts.montserratTextTheme(
                                      Theme.of(context).textTheme)
                                  .headline2
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: Container(
                  width: 0.6.wp,
                  child: RaisedButton(
                    onPressed: () {},
                    padding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 0.05.wp),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AutoSizeText('Confirmar Reserva',
                        maxLines: 1,
                        style: GoogleFonts.montserratTextTheme(
                                Theme.of(context).textTheme)
                            .button),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
