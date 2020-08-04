import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:rango/models/meals.dart';
import 'package:flutter/foundation.dart';

class GridVertical extends StatelessWidget {
  final String title;
  final List<Meal> meals;

  GridVertical({
    @required this.title,
    @required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.47,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04),
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Container(
            height: MediaQuery.of(context).size.height * 0.43,
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.02),
            width: double.infinity,
            child: StaggeredGridView.countBuilder(
              crossAxisCount: 2,
              itemCount: meals.length,
              itemBuilder: (ctx, index) => Container(
                child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: <Widget>[
                      FadeInImage.assetNetwork(
                        placeholder: 'assets/imgs/quentinha_placeholder.png',
                        image: meals[index].picture,
                        fit: BoxFit.fitWidth,
                      ),
                      Container(
                        child: Column(
                          children: <Widget>[
                            Text(
                              meals[index].name,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              'R\$${meals[index].price}',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              staggeredTileBuilder: (index) => StaggeredTile.fit(1),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
          ),
        ],
      ),
    );
  }
}
