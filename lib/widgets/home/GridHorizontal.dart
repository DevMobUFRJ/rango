import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:flutter/foundation.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/main/meals/ManageOrder.dart';

class GridHorizontal extends StatelessWidget {
  final String sellerId;
  final List<String> currentMealsIds;

  GridHorizontal({
    @required this.sellerId,
    @required this.currentMealsIds,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
        scrollDirection: Axis.horizontal,
        crossAxisCount: currentMealsIds.length > 6 ? 2 : 1,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        padding: EdgeInsets.all(0),
        itemCount: currentMealsIds.length,
        itemBuilder: (ctx, index) => StreamBuilder(
          stream: Repository.instance.getMealFromSeller(currentMealsIds[index], sellerId),
          builder: (context, AsyncSnapshot<DocumentSnapshot> mealSnapshot) {
            //TODO Trocar para placeholder
            if (!mealSnapshot.hasData ||
                mealSnapshot.connectionState == ConnectionState.waiting) {
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

            if (mealSnapshot.hasError) {
              return Container(
                height: 0.6.hp - 56,
                alignment: Alignment.center,
                child: AutoSizeText(
                  mealSnapshot.error.toString(),
                  style: GoogleFonts.montserrat(
                      fontSize: 45.nsp,
                      color: Theme.of(context).accentColor),
                ),
              );
            }

            Meal meal = Meal.fromJson(mealSnapshot.data.data);

            return GestureDetector(
              onTap: () => pushNewScreen(context,
                  screen: ManageOrder(
                    meal: meal,
                  ),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino),
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: currentMealsIds.length > 6 ? 3 : 4,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 0.5.wp),
                        child: meal.picture !=
                            null
                            ? FadeInImage.assetNetwork(
                          placeholder:
                          'assets/imgs/quentinha_placeholder.png',
                          image: meal.picture,
                          fit: currentMealsIds.length > 6
                              ? BoxFit.fitWidth
                              : BoxFit.fitWidth,
                        )
                            : Image.asset(
                          'assets/imgs/quentinha_placeholder.png',
                          fit: BoxFit.fitHeight,
                        ),
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
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    fontSize:
                                    currentMealsIds.length > 6 ? 25.nsp : 30.nsp,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  'R\$${meal.price}',
                                  style: GoogleFonts.montserrat(
                                    fontSize:
                                    currentMealsIds.length > 6 ? 25.nsp : 28.nsp,
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
        ),
        staggeredTileBuilder: (index) => currentMealsIds.length > 6
            ? StaggeredTile.count(1, 1.2)
            : StaggeredTile.count(1, 1.2));
  }
}
