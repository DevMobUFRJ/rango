import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/meal_request.dart';
import 'package:rango/models/meals.dart';
import 'package:flutter/foundation.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/reserva/DetalhesQuentinhaScreen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/utils/string_formatters.dart';

class ListaHorizontal extends StatelessWidget {
  final String title;
  final double tagM;
  final List<MealRequest> meals;

  ListaHorizontal({
    @required this.title,
    @required this.tagM,
    @required this.meals,
  });

  @override
  Widget build(BuildContext context) {
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
          constraints: BoxConstraints(maxHeight: 0.2.hp),
          width: double.infinity,
          child: ListView.builder(
            itemCount: meals.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: false,
            itemBuilder: (ctx, index) => StreamBuilder(
              stream: Repository.instance.getMealFromSeller(
                meals[index].mealId,
                meals[index].seller.id,
              ),
              builder: (context, AsyncSnapshot<DocumentSnapshot> mealSnapshot) {
                if (mealSnapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: 0.4.wp,
                    child: Card(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                  );
                }
                if (mealSnapshot.hasError) {
                  return Container(
                    width: 0.4.wp,
                    child: Card(
                      child: Center(
                        child: AutoSizeText(
                          mealSnapshot.error.toString(),
                          style: GoogleFonts.montserrat(
                            fontSize: 45.nsp,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                Meal meal = Meal.fromJson(
                  mealSnapshot.data.data,
                  id: meals[index].mealId,
                );
                return GestureDetector(
                  onTap: () => pushNewScreen(
                    context,
                    screen: DetalhesQuentinhaScreen(
                      marmita: meal,
                      seller: meals[index].seller,
                      tagM: tagM,
                    ),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  ),
                  child: Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Flexible(
                          flex: 0,
                          child: Hero(
                            tag: meal.hashCode * tagM,
                            child: FadeInImage.assetNetwork(
                              placeholder:
                                  'assets/imgs/quentinha_placeholder.png',
                              image: meal.picture,
                              fit: BoxFit.cover,
                              height: 150.h,
                              width: 0.45.wp,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 2),
                            width: 0.45.wp,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  flex: 2,
                                  child: AutoSizeText(
                                    meal.name,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 28.ssp,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: AutoSizeText(
                                    intToCurrency(meal.price),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 32.ssp,
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
          ),
        )
      ],
    );
  }
}
