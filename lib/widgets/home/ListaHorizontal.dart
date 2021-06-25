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
          height: 250.h,
          width: double.infinity,
          child: ListView.builder(
            itemCount: meals.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (ctx, index) => StreamBuilder(
                stream: Repository.instance.getMealFromSeller(meals[index].mealId, meals[index].seller.id),
                builder: (context, AsyncSnapshot<DocumentSnapshot> mealSnapshot) {
                  if (!mealSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (mealSnapshot.hasError) {
                    return Text(mealSnapshot.error.toString());
                  }

                  Meal meal = Meal.fromJson(mealSnapshot.data.data, id: meals[index].mealId);
                  return GestureDetector(
                    onTap: () => pushNewScreen(context,
                        screen: DetalhesQuentinhaScreen(marmita: meal, seller: meals[index].seller, tagM: tagM),
                        withNavBar: false,
                        pageTransitionAnimation: PageTransitionAnimation.cupertino),
                    child: Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Hero(
                            tag: meal.hashCode * tagM,
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/imgs/quentinha_placeholder.png',
                              image: meal.picture,
                              fit: BoxFit.cover,
                              height: 150.h,
                              width: 0.4.wp,
                            ),
                          ),
                          Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                  width: 0.35.wp,
                                  child: Text(
                                    meal.name,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: GoogleFonts.montserrat(fontSize: 28.ssp),
                                  ),
                                ),
                                Container(
                                  width: 0.35.wp,
                                  child: AutoSizeText(
                                    intToCurrency(meal.price),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(fontSize: 28.ssp),
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
            ),
          ),
        )
      ],
    );
  }
}
