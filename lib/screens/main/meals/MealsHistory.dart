import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/screens/main/meals/ManageMeal.dart';
import 'package:rango/utils/string_formatters.dart';

class MealsHistory extends StatefulWidget {
  // Essa tela possui todas as meals
  final List<Meal> meals;

  MealsHistory(this.meals);

  @override
  _MealsHistoryState createState() => _MealsHistoryState();
}

class _MealsHistoryState extends State<MealsHistory> {
  List<bool> ordersCheckedValue;
  bool _hasAnySelected;

  @override
  void initState() {
    setState(() {
      ordersCheckedValue = List.filled(widget.meals.length, false);
      _hasAnySelected = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            'Histórico',
            maxLines: 1,
            style: GoogleFonts.montserrat(
              color: Theme.of(context).accentColor,
              fontSize: 35.nsp,
            ),
          ),
        ),
        body: _buildScreen(widget.meals));
  }

  Widget _buildScreen(List<Meal> meals) {
    if (meals.isEmpty) {
      return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 0.1.wp),
        child: AutoSizeText(
            "Sem quentinhas criadas! Comece a criar seu cardápio na tela anterior.",
            style: GoogleFonts.montserrat(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.w400,
              fontSize: 52.nsp,
            )),
      );
    } else {
      return Container(
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: Container(
                child: StaggeredGridView.countBuilder(
                  scrollDirection: Axis.vertical,
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  itemCount: meals.length,
                  staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                  itemBuilder: (ctx, index) {
                    Meal meal = meals[index];

                    return Container(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          GestureDetector(
                            onTap: () => pushNewScreen(
                              context,
                              screen: ManageMeal(
                                "",
                                meal: meal,
                              ),
                              withNavBar: false,
                            ),
                            child: Container(
                              child: Card(
                                semanticContainer: true,
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      constraints: BoxConstraints(
                                          maxHeight: 100, minWidth: 0.5.wp),
                                      child: meal.picture != null
                                          ? FadeInImage.assetNetwork(
                                              placeholder:
                                                  'assets/imgs/quentinha_placeholder.png',
                                              image: meal.picture,
                                              fit: BoxFit.fitWidth,
                                            )
                                          : Image.asset(
                                              'assets/imgs/quentinha_placeholder.png',
                                              fit: BoxFit.fitHeight,
                                            ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5),
                                      child: Column(
                                        children: <Widget>[
                                          AutoSizeText(
                                            meal.name,
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                                fontSize: 24.nsp),
                                          ),
                                          AutoSizeText(
                                            intToCurrency(meal.price),
                                            style: GoogleFonts.montserrat(
                                                fontSize: 24.nsp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Theme(
                            data: ThemeData(
                              unselectedWidgetColor:
                                  Theme.of(context).accentColor,
                            ),
                            child: Checkbox(
                              activeColor: Theme.of(context).accentColor,
                              value: ordersCheckedValue[index],
                              onChanged: (value) {
                                setState(() => {
                                      ordersCheckedValue[index] = value,
                                      if (!ordersCheckedValue.contains(true))
                                        {_hasAnySelected = false}
                                      else
                                        {_hasAnySelected = true}
                                    });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                color: Color(0xFFF5F5F5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      child: ElevatedButton(
                        child: AutoSizeText(
                          //TODO Adicionar lógica do firebase, adicionando os mealIds selecionados aos currentMeals
                          "Adicionar",
                          style: GoogleFonts.montserrat(
                              color: Colors.white, fontSize: 36.nsp),
                        ),
                        onPressed: ordersCheckedValue == null ||
                                ordersCheckedValue.length == 0 ||
                                _hasAnySelected == false
                            ? null
                            : () => {},
                      ),
                    ),
                    ElevatedButton(
                      child: AutoSizeText(
                        "Remover",
                        style: GoogleFonts.montserrat(
                            color: Colors.white, fontSize: 36.nsp),
                      ),
                      onPressed: ordersCheckedValue == null ||
                              ordersCheckedValue.length == 0 ||
                              _hasAnySelected == false
                          ? null
                          : () => {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
