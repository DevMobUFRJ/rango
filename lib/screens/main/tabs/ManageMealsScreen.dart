import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/seller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/main/meals/ManageMeal.dart';
import 'package:rango/utils/constants.dart';
import 'package:rango/utils/string_formatters.dart';
import 'package:rango/widgets/home/GridHorizontal.dart';

class ManageMealsScreen extends StatefulWidget {
  final Seller usuario;

  ManageMealsScreen(this.usuario);

  @override
  _ManageMealsScreenState createState() => _ManageMealsScreenState();
}

class _ManageMealsScreenState extends State<ManageMealsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        height: 1.hp - 56,
        child: StreamBuilder(
          stream: Repository.instance.getSellerMeals(widget.usuario.id),
          builder:
              (context, AsyncSnapshot<QuerySnapshot<Meal>> mealsSnapshot) {
            // Para buscar meals
            if (!mealsSnapshot.hasData) {
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

            if (mealsSnapshot.hasError) {
              return Container(
                height: 0.6.hp - 56,
                alignment: Alignment.center,
                child: AutoSizeText(
                  mealsSnapshot.error.toString(),
                  style: GoogleFonts.montserrat(
                      fontSize: 45.nsp,
                      color: Theme.of(context).accentColor),
                ),
              );
            }

            Seller seller = widget.usuario;
            List<String> currentMealsIds = seller.currentMeals != null
                ? seller.currentMeals.keys.toList()
                : [];
            List<Meal> meals = mealsSnapshot.data.docs
                .map((snapshot) => snapshot.data())
                .toList();
            meals.sort((a, b) => a.quantity > 0 ? -1 : 1);
            List<Meal> currentMeals = meals
                .where((doc) => currentMealsIds.contains(doc.id))
                .where((doc) => doc.quantity > 0)
                .toList();

            return Column(
              children: [
                _buildHeader(),
                if (currentMeals.isEmpty) ...{
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15, top: 8),
                    child: AutoSizeText(
                      'Você ainda não configurou o cardápio do dia! Ative as quentinhas na lista abaixo ou crie uma nova.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 36.nsp,
                      ),
                    ),
                  ),
                } else ...{
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 0.03.wp),
                          child: AutoSizeText(
                            "Cardápio do dia",
                            style: GoogleFonts.montserrat(
                              color: Theme.of(context).accentColor,
                              fontSize: 30.ssp,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(maxHeight: 280.h),
                        child: GridHorizontal(
                          sellerId: seller.id,
                          currentMeals: currentMeals,
                        ),
                      ),
                    ],
                  )
                },
                _buildButtons(seller.id),
                Flexible(
                  flex: 4,
                  child: Scrollbar(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 0),
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: meals[index].quantity == 0
                              ? Colors.grey
                              : Color(0xFFF9B152),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(0),
                            trailing: Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                      activeColor:
                                      Theme.of(context).primaryColor,
                                      value: seller.currentMeals[
                                      meals[index].id] !=
                                          null &&
                                          meals[index].quantity > 0,
                                      onChanged: (value) async {
                                        if (meals[index].quantity == 0) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              duration:
                                              Duration(seconds: 2),
                                              backgroundColor:
                                              Theme.of(context)
                                                  .errorColor,
                                              content: Text(
                                                'Você não possui mais unidades dessa quentinha! Adicione mais unidades para disponibilizar ela.',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        try {
                                          if (value) {
                                            Repository.instance
                                                .addMealToCurrent(
                                                meals[index].id,
                                                seller.id);
                                          } else {
                                            Repository.instance
                                                .removeMealFromCurrent(
                                                meals[index].id,
                                                seller.id);
                                          }
                                        } catch (e) {
                                          print(e);
                                        }
                                      }),
                                  IconButton(
                                    onPressed: seller.currentMeals[
                                    meals[index].id] ==
                                        null ||
                                        meals[index].quantity == 0
                                        ? null
                                        : () async {
                                      try {
                                        if (seller
                                            .currentMeals[
                                        meals[index].id]
                                            .featured ==
                                            false) {
                                          var featuredMeals = seller
                                              .currentMeals.values
                                              .where((item) =>
                                          item.featured ==
                                              true)
                                              .length;
                                          if (featuredMeals >=
                                              maxFeaturedMeals) {
                                            ScaffoldMessenger.of(
                                                context)
                                                .showSnackBar(
                                              SnackBar(
                                                duration: Duration(
                                                    seconds: 2),
                                                backgroundColor:
                                                Theme.of(context)
                                                    .errorColor,
                                                content: Text(
                                                  'Você pode selecionar até $maxFeaturedMeals quentinhas em destaque',
                                                  textAlign: TextAlign
                                                      .center,
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                        }

                                        Repository.instance
                                            .toggleMealFeatured(
                                            meals[index].id,
                                            seller);
                                      } catch (e) {
                                        print(e);
                                      }
                                    },
                                    icon: Icon(
                                        seller.currentMeals[
                                        meals[index].id] !=
                                            null &&
                                            seller
                                                .currentMeals[
                                            meals[index].id]
                                                .featured
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: seller.currentMeals[
                                        meals[index].id] ==
                                            null
                                            ? Color(0xFFF9B152)
                                            : meals[index].quantity == 0
                                            ? Colors.grey
                                            : Colors.white),
                                  ),
                                  IconButton(
                                    onPressed: () => pushNewScreen(context,
                                        screen: ManageMeal(
                                          seller.id,
                                          meal: meals[index],
                                        ),
                                        withNavBar: false,
                                        pageTransitionAnimation:
                                        PageTransitionAnimation
                                            .cupertino),
                                    icon: Icon(Icons.edit,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            title: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    meals[index].name,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(height: 5),
                                  AutoSizeText(
                                    intToCurrency(meals[index].price),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(height: 5),
                                  AutoSizeText(
                                    '${meals[index].quantity} ${meals[index].quantity < 2 ? 'disponível' : 'disponíveis'}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  //SizedBox(height: 10)
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        )
      ),
    );
  }

  Widget _buildButtons(String sellerId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () => pushNewScreen(
              context,
              screen: ManageMeal(sellerId),
              withNavBar: false,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AutoSizeText(
                "Adicionar",
                style: GoogleFonts.montserrat(
                  fontSize: 32.nsp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final String assetName = 'assets/imgs/curva_principal.svg';
    return Stack(
      children: [
        SvgPicture.asset(
          assetName,
          semanticsLabel: 'curvaHome',
          width: 1.wp,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin:
                EdgeInsets.only(left: 0.02.wp, top: 0.07.hp, bottom: 0.01.hp),
            width: 0.6.wp,
            child: AutoSizeText(
              "E aí, o que tem pra hoje?",
              maxLines: 2,
              textAlign: TextAlign.start,
              style: GoogleFonts.montserrat(
                color: Colors.deepOrange[300],
                fontWeight: FontWeight.w500,
                fontSize: 60.nsp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
