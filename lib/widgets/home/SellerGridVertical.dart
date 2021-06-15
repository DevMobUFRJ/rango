import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/meals.dart';
import 'package:flutter/foundation.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/screens/reserva/DetalhesQuentinhaScreen.dart';
import 'package:rango/screens/seller/SellerProfile.dart';
import 'package:rango/utils/string_formatters.dart';

class SellerGridVertical extends StatelessWidget {
  final double tagM;
  final String title;
  final List<Seller> sellers;
  final Position userLocation;

  SellerGridVertical({
    @required this.tagM,
    @required this.title,
    @required this.sellers,
    @required this.userLocation
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0.04.wp),
          child: AutoSizeText(
            title,
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 28.nsp,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0.02.hp),
          width: double.infinity,
          child: StaggeredGridView.countBuilder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // Desativa o scroll separado e mantem somente o da tela principal
            crossAxisCount: 2,
            itemCount: sellers.length,
            itemBuilder: (ctx, index) => GestureDetector(
              onTap: () => pushNewScreen(context,
                  screen: SellerProfile(sellers[index].id, sellers[index].name),
                  withNavBar: true,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino),
              child: Container(
                child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: <Widget>[
                      Hero(
                        tag: sellers[index].hashCode * tagM,
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/imgs/quentinha_placeholder.png',
                          image: sellers[index].logo,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: <Widget>[
                            AutoSizeText(
                              sellers[index].name,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(fontSize: 28.nsp),
                            ),
                            SizedBox(height: 4),
                            AutoSizeText(
                              distanceInKM(sellers[index], userLocation),
                              style: GoogleFonts.montserrat(fontSize: 28.nsp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            staggeredTileBuilder: (index) => StaggeredTile.fit(1),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
        ),
      ],
    );
  }
}