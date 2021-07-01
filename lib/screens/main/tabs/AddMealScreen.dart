import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/seller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/main/meals/ManageOrder.dart';
import 'package:rango/screens/main/meals/MealsHistory.dart';
import 'package:rango/widgets/home/GridHorizontal.dart';

class AddMealScreen extends StatefulWidget {
  final Seller usuario;

  AddMealScreen(this.usuario);

  @override
  _AddMealScreenState createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        height: 1.hp - 56,
        child: StreamBuilder(
          stream: Repository.instance.getSeller(widget.usuario.id),
          builder: (context, AsyncSnapshot<DocumentSnapshot> sellerSnapshot) {
            if (!sellerSnapshot.hasData ||
                sellerSnapshot.connectionState == ConnectionState.waiting) {
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

            if (sellerSnapshot.hasError) {
              return Container(
                height: 0.6.hp - 56,
                alignment: Alignment.center,
                child: AutoSizeText(
                  sellerSnapshot.error.toString(),
                  style: GoogleFonts.montserrat(
                      fontSize: 45.nsp,
                      color: Theme.of(context).accentColor),
                ),
              );
            }

            Seller seller = Seller.fromJson(sellerSnapshot.data.data);
            List<String> currentMealsIds = seller.currentMeals.keys.toList();

            if (currentMealsIds.isEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  Flexible(
                    flex: 4,
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            margin:
                            EdgeInsets.only(left: 15, right: 15, top: 8),
                            child: AutoSizeText(
                                'Você ainda não configurou o cardápio do dia! Clique nos botões abaixo para configurar:',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 36.nsp,
                                )),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              child: _buildButtons()
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          child: AutoSizeText(
                              'Quentinhas criadas serão mostradas aqui para adição rápida ao cardápio do dia!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 36.nsp,
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  Flexible(
                    flex: currentMealsIds.length > 6 ? 4 : 2,
                    child: Container(
                      child: Column(
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
                          Expanded(
                            flex: currentMealsIds.length > 6 ? 5 : 1,
                            child: Container(
                              child: GridHorizontal(
                                sellerId: seller.id,
                                currentMealsIds: currentMealsIds,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 0,
                            child: Container(
                                child: _buildButtons()
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Column(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.center,
                            child: AutoSizeText(
                              "Adicionar pratos já cadastrados:",
                              style: GoogleFonts.montserrat(
                                color: Theme.of(context).accentColor,
                                fontSize: 32.nsp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildMealsList()
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            margin: EdgeInsets.only(right: 0.05.wp),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
              onPressed: () => pushNewScreen(
                context,
                screen: ManageOrder(),
                withNavBar: false,
              ),
              child: AutoSizeText(
                "Adicionar",
                style: GoogleFonts.montserrat(
                  fontSize: 32.nsp,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
              onPressed: () => pushNewScreen(
                context,
                screen: MealsHistory(sellerId: widget.usuario.id),
                withNavBar: false,
              ),
              child: AutoSizeText(
                "Histórico",
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
            margin: EdgeInsets.only(
                left: 0.02.wp, top: 0.07.hp, bottom: 0.01.hp),
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

  Widget _buildMealsList() {
    return Flexible(
      flex: 9,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.2.wp),
        child: Container(
          child: StreamBuilder(
            stream: Repository.instance.getSellerMeals(widget.usuario.id),
            builder: (context, AsyncSnapshot<QuerySnapshot> mealsSnapshot) {
              if (!mealsSnapshot.hasData ||
                  mealsSnapshot.connectionState == ConnectionState.waiting) {
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

              return ListView.builder(
                padding: EdgeInsets.all(0),
                itemCount: mealsSnapshot.data.documents.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (ctx, index) => Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      constraints:
                      BoxConstraints(maxWidth: 0.5.wp),
                      child: GestureDetector(
                        onTap: () => {},
                        child: AutoSizeText(
                          // TODO Adicionar lógica a isso, vai adicionar o mealId no currentMeals
                          mealsSnapshot.data.documents[index].data['name'],
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            color: Color(0xFFF9B152),
                            fontWeight: FontWeight.w500,
                            fontSize: 28.ssp,
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.add_circle,
                      color: Color(0xFFF9B152),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
