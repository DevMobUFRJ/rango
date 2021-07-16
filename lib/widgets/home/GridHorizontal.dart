import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:flutter/foundation.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/screens/main/meals/ManageMeal.dart';
import 'package:rango/utils/string_formatters.dart';
import 'package:shimmer/shimmer.dart';
import 'package:transparent_image/transparent_image.dart';

class GridHorizontal extends StatelessWidget {
  final String sellerId;
  final List<Meal> currentMeals;

  GridHorizontal({
    @required this.sellerId,
    @required this.currentMeals,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
        scrollDirection: Axis.horizontal,
        crossAxisCount: currentMeals.length > 6 ? 2 : 1,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        padding: EdgeInsets.all(0),
        itemCount: currentMeals.length,
        itemBuilder: (ctx, index) {
          Meal meal = currentMeals[index];
          return GestureDetector(
            onTap: () => pushNewScreen(context,
                screen: ManageMeal(
                  sellerId,
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
                    flex: currentMeals.length > 6 ? 3 : 4,
                    child: Stack(
                      children: [
                        Shimmer.fromColors(
                          baseColor: Color.fromRGBO(255, 175, 153, 1),
                          highlightColor: Colors.white,
                          child: Container(
                            color: Colors.white,
                            child: SizedBox(
                              height: 170.h,
                              width: 0.5.wp,
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
                          height: 170.h,
                          width: 0.5.wp,
                          child: meal.picture != null
                              ? CachedNetworkImage(
                                  placeholder: (context, url) => Image(
                                      image: MemoryImage(kTransparentImage)),
                                  errorWidget: (context, url, error) => Image(
                                      image: MemoryImage(kTransparentImage)),
                                  imageUrl: meal.picture,
                                  fit: BoxFit.cover,
                                )
                              : Stack(
                                  children: [
                                    Container(
                                      color: Color.fromRGBO(255, 175, 153, 1),
                                      child: SizedBox(
                                        height: 170.h,
                                        width: 0.5.wp,
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
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
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
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  fontSize:
                                      currentMeals.length > 6 ? 25.nsp : 30.nsp,
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
                                  fontSize:
                                      currentMeals.length > 6 ? 25.nsp : 28.nsp,
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
        staggeredTileBuilder: (index) => currentMeals.length > 6
            ? StaggeredTile.count(1, 1.2)
            : StaggeredTile.count(1, 1.2));
  }
}
