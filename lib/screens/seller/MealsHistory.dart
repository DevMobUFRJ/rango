import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/order.dart';
import 'package:rango/screens/seller/ManageOrder.dart';

class MealsHistory extends StatefulWidget {
  final List<Order> orders;

  MealsHistory({@required this.orders});

  @override
  _MealsHistoryState createState() => _MealsHistoryState();
}

class _MealsHistoryState extends State<MealsHistory> {
  List<bool> ordersCheckedValue;
  bool _hasAnySelected;

  @override
  void initState() {
    setState(() {
      ordersCheckedValue = List.filled(widget.orders.length, false);
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
      body: ordersCheckedValue == null || ordersCheckedValue.length == 0
          ? Container(
              child: Text("vazio"),
            )
          : Container(
              height: 1.hp - 0.2.hp,
              child: Column(
                children: [
                  Container(
                    height: 0.7.hp,
                    child: StaggeredGridView.countBuilder(
                      scrollDirection: Axis.vertical,
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      itemCount: widget.orders.length,
                      staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                      itemBuilder: (ctx, index) => Container(
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            GestureDetector(
                              onTap: () => pushNewScreen(
                                context,
                                screen: ManageOrder(
                                  order: widget.orders[index],
                                ),
                              ),
                              child: Card(
                                semanticContainer: true,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  children: <Widget>[
                                    FadeInImage.assetNetwork(
                                      placeholder:
                                          'assets/imgs/quentinha_placeholder.png',
                                      image: widget
                                          .orders[index].quentinha.picture,
                                      fit: BoxFit.fitWidth,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5),
                                      child: Column(
                                        children: <Widget>[
                                          AutoSizeText(
                                            widget.orders[index].quentinha.name,
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                                fontSize: 24.nsp),
                                          ),
                                          AutoSizeText(
                                            'R\$${widget.orders[index].quentinha.price}',
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
                            Checkbox(
                              value: ordersCheckedValue[index],
                              onChanged: (value) => setState(() => {
                                    ordersCheckedValue[index] = value,
                                    if (!ordersCheckedValue.contains(true))
                                      {_hasAnySelected = false}
                                    else
                                      {_hasAnySelected = true}
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 5),
                            child: RaisedButton(
                              child: Text("Adicionar"),
                              disabledColor: Colors.grey,
                              onPressed: ordersCheckedValue == null ||
                                      ordersCheckedValue.length == 0 ||
                                      _hasAnySelected == false
                                  ? null
                                  : () => {},
                            ),
                          ),
                          RaisedButton(
                            child: Text("Remover"),
                            disabledColor: Colors.grey,
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
            ),
    );
  }
}
