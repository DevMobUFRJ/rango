import 'package:flutter/material.dart';
import 'package:rango/models/meals.dart';
import 'package:flutter/foundation.dart';
import 'package:rango/screens/reserva/DetalhesQuentinhaScreen.dart';

class ListaHorizontal extends StatelessWidget {
  final String title;
  final List<Meal> meals;

  ListaHorizontal({
    @required this.title,
    @required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        Container(
          height: MediaQuery.of(context).size.height * 0.18,
          width: double.infinity,
          child: ListView.builder(
            itemCount: meals.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, index) => GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(
                  DetalhesQuentinhaScreen.routeName,
                  arguments: meals[index]),
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
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height * 0.10,
                      width: MediaQuery.of(context).size.width * 0.38,
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
          ),
        )
      ],
    );
  }
}
