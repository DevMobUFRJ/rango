import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:flutter/foundation.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/screens/main/meals/ManageMeal.dart';
import 'package:rango/utils/string_formatters.dart';
import 'package:shimmer/shimmer.dart';
import 'package:transparent_image/transparent_image.dart';

class GridHorizontal extends StatefulWidget {
  final Seller seller;
  final List<Meal> currentMeals;

  GridHorizontal({
    @required this.seller,
    @required this.currentMeals,
  });

  @override
  _GridHorizontalState createState() => _GridHorizontalState();
}

class _GridHorizontalState extends State<GridHorizontal> {
  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
        scrollDirection: Axis.horizontal,
        crossAxisCount: 1,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        padding: EdgeInsets.all(0),
        itemCount: widget.currentMeals.length,
        itemBuilder: (ctx, index) {
          Meal meal = widget.currentMeals[index];
          return GestureDetector(
            onTap: () => pushNewScreen(context,
                screen: ManageMeal(
                  widget.seller,
                  meal: meal,
                ),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino),
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Stack(
                      children: [
                        if (meal.picture != null) ...{
                          Shimmer.fromColors(
                            baseColor: Color.fromRGBO(255, 175, 153, 1),
                            highlightColor: Colors.white,
                            child: Container(
                              color: Colors.white,
                              child: SizedBox(
                                height: 190.h,
                                width: 0.6.wp,
                              ),
                            ),
                          ),
                          Center(
                            child: Icon(
                              Icons.local_dining,
                              size: 55,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            height: 190.h,
                            width: 0.6.wp,
                            child: CachedNetworkImage(
                              placeholder: (context, url) =>
                                  Image(image: MemoryImage(kTransparentImage)),
                              errorWidget: (context, url, error) =>
                                  Image(image: MemoryImage(kTransparentImage)),
                              imageUrl: meal.picture,
                              fit: BoxFit.cover,
                            ),
                          ),
                        } else ...{
                          Container(
                            height: 190.h,
                            width: 0.6.wp,
                            child: Stack(
                              children: [
                                Container(
                                  color: Theme.of(context).accentColor,
                                  child: SizedBox(
                                    height: 190.h,
                                    width: 0.6.wp,
                                  ),
                                ),
                                Center(
                                  child: Icon(
                                    Icons.local_dining,
                                    size: 55,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        }
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: AutoSizeText(
                                meal.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                minFontSize: 16,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                intToCurrency(meal.price),
                                style: GoogleFonts.montserrat(
                                  fontSize: 32.nsp,
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
          );
        },
        staggeredTileBuilder: (index) => StaggeredTile.count(1, 1.2));
  }
}
