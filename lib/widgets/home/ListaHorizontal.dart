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
import 'package:shimmer/shimmer.dart';
import 'package:transparent_image/transparent_image.dart';

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
          constraints: BoxConstraints(maxHeight: 280.h),
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
                    height: 0.2.hp,
                    width: 0.45.wp,
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            flex: 2,
                            child: Stack(
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Color.fromRGBO(255, 175, 153, 1),
                                  highlightColor: Colors.white,
                                  child: Container(
                                    color: Colors.white,
                                    child: SizedBox(
                                      height: 0.12.hp,
                                      width: 0.45.wp,
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
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: Color.fromRGBO(255, 175, 153, 1),
                                    highlightColor: Colors.white,
                                    child: Container(
                                      color: Colors.grey[300],
                                      child: SizedBox(
                                        width: 0.3.wp,
                                        height: 0.02.hp,
                                      ),
                                    ),
                                  ),
                                  Shimmer.fromColors(
                                    baseColor: Color.fromRGBO(255, 175, 153, 1),
                                    highlightColor: Colors.white,
                                    child: Container(
                                      margin: EdgeInsets.only(top: 6),
                                      color: Colors.grey[300],
                                      child: SizedBox(
                                        width: 0.1.wp,
                                        height: 0.02.hp,
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
                            color: Color.fromRGBO(255, 146, 117, 1),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                var mealSnapshotData =
                    mealSnapshot.data.data() as Map<String, dynamic>;
                Meal meal = Meal.fromJson(
                  mealSnapshotData,
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
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Color.fromRGBO(255, 175, 153, 1),
                                  highlightColor: Colors.white,
                                  child: Container(
                                    color: Colors.white,
                                    child: SizedBox(
                                      height: 170.h,
                                      width: 0.45.wp,
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
                                FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: meal.picture,
                                  fit: BoxFit.cover,
                                  height: 170.h,
                                  width: 0.45.wp,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            constraints: BoxConstraints(maxHeight: 100.h),
                            padding: EdgeInsets.symmetric(horizontal: 1),
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
                                    minFontSize: 15,
                                    maxFontSize: 15,
                                    style: GoogleFonts.montserrat(),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: AutoSizeText(
                                    intToCurrency(meal.price),
                                    textAlign: TextAlign.center,
                                    minFontSize: 15,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
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
