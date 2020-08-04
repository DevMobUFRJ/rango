import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  final _username;

  HomeScreen(this._username);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final String assetName = 'assets/imgs/curva_principal.svg';
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Stack(
          children: <Widget>[
            Container(
              child: SvgPicture.asset(
                assetName,
                semanticsLabel: 'curvaHome',
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 40),
              padding: EdgeInsets.symmetric(horizontal: 18),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Olá, ${widget._username}!\nBateu a fome?',
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  SizedBox(height: 50),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Sugestões do dia',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          height: 120,
                          width: double.infinity,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              Card(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  children: <Widget>[
                                    Image.network(
                                      'https://img.itdg.com.br/tdg/images/recipes/000/174/031/173715/173715_original.jpg?mode=crop&width=710&height=400',
                                      width: 150,
                                    ),
                                    Text("Strogonoff"),
                                  ],
                                ),
                              ),
                              Card(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  children: <Widget>[
                                    Image.network(
                                      'https://img.itdg.com.br/tdg/images/recipes/000/174/031/173715/173715_original.jpg?mode=crop&width=710&height=400',
                                      width: 150,
                                    ),
                                    Text("Teste"),
                                  ],
                                ),
                              ),
                              Card(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  children: <Widget>[
                                    Image.network(
                                      'https://img.itdg.com.br/tdg/images/recipes/000/174/031/173715/173715_original.jpg?mode=crop&width=710&height=400',
                                      width: 150,
                                    ),
                                    Text("Teste2"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Promoções da semana',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                            height: 220,
                            child: GridView.count(
                              childAspectRatio: (150 / 100),
                              crossAxisCount: 2,
                              children: <Widget>[
                                Container(
                                  child: Card(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Column(
                                      children: <Widget>[
                                        Image.network(
                                          'https://img.itdg.com.br/tdg/images/recipes/000/174/031/173715/173715_original.jpg?mode=crop&width=710&height=400',
                                          width: 150,
                                        ),
                                        Text("Strogonoff"),
                                      ],
                                    ),
                                  ),
                                ),
                                Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Column(
                                    children: <Widget>[
                                      Image.network(
                                        'https://img.itdg.com.br/tdg/images/recipes/000/174/031/173715/173715_original.jpg?mode=crop&width=710&height=400',
                                        width: 150,
                                      ),
                                      Text("Strogonoff"),
                                    ],
                                  ),
                                ),
                                Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Column(
                                    children: <Widget>[
                                      Image.network(
                                        'https://img.itdg.com.br/tdg/images/recipes/000/174/031/173715/173715_original.jpg?mode=crop&width=710&height=400',
                                        width: 150,
                                      ),
                                      Text("Strogonoff"),
                                    ],
                                  ),
                                ),
                                Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Column(
                                    children: <Widget>[
                                      Image.network(
                                        'https://img.itdg.com.br/tdg/images/recipes/000/174/031/173715/173715_original.jpg?mode=crop&width=710&height=400',
                                        width: 150,
                                      ),
                                      Text("Strogonoff"),
                                    ],
                                  ),
                                ),
                              ],
                            ))
                      ],
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
}
