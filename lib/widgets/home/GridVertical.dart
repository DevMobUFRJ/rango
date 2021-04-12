import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/meals.dart';
import 'package:flutter/foundation.dart';
import 'package:rango/screens/reserva/DetalhesQuentinhaScreen.dart';
import 'package:rango/utils/string_formatters.dart';

class GridVertical extends StatelessWidget {
  final double tagM;
  final String title;
  final List<Meal> meals;

  GridVertical({
    @required this.tagM,
    @required this.title,
    @required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0.04.hp),
          child: AutoSizeText(
            title,
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 28.nsp,
            ),
          ),
        ),
        SizedBox(height: 0.01.hp),
        Container(
          height: 0.46.hp,
          padding: EdgeInsets.symmetric(horizontal: 0.02.hp),
          width: double.infinity,
          child: StaggeredGridView.countBuilder(
            shrinkWrap: true,
            crossAxisCount: 2,
            itemCount: meals.length,
            itemBuilder: (ctx, index) => GestureDetector(
              onTap: () => pushNewScreen(context,
                  screen: DetalhesQuentinhaScreen(
                      marmita: meals[index], tagM: tagM),
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
                        tag: meals[index].hashCode * tagM,
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/imgs/quentinha_placeholder.png',
                          image: meals[index].picture,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      Container(
                        child: Column(
                          children: <Widget>[
                            AutoSizeText(
                              meals[index].name,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(fontSize: 28.nsp),
                            ),
                            AutoSizeText(
                              intToCurrency(meals[index].price),
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
