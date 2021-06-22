import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/order.dart';
import 'package:rango/screens/main/meals/ManageOrder.dart';

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
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 0.1.wp),
              child: AutoSizeText(
                  "Sem histórico de quentinhas! Reservas já finalizadas aparecerão aqui.",
                  style: GoogleFonts.montserrat(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 52.nsp,
                  )),
            )
          : Container(
              height: 1.hp - 0.216.hp,
              child: Column(
                children: [
                  Flexible(
                    flex: 6,
                    child: Container(
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
                                        image: widget.orders[index]
                                            .quentinhas[0].quentinha.picture,
                                        fit: BoxFit.fitWidth,
                                      ),
                                      Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: Column(
                                          children: <Widget>[
                                            AutoSizeText(
                                              widget.orders[index].quentinhas[0]
                                                  .quentinha.name,
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 24.nsp),
                                            ),
                                            AutoSizeText(
                                              'R\$${widget.orders[index].quentinhas[0].quentinha.price}',
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
                              Theme(
                                data: ThemeData(
                                  unselectedWidgetColor:
                                      Theme.of(context).accentColor,
                                ),
                                child: Checkbox(
                                  activeColor: Theme.of(context).accentColor,
                                  value: ordersCheckedValue[index],
                                  onChanged: (value) => setState(() => {
                                        ordersCheckedValue[index] = value,
                                        if (!ordersCheckedValue.contains(true))
                                          {_hasAnySelected = false}
                                        else
                                          {_hasAnySelected = true}
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Color(0xFFF5F5F5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 5),
                            child: ElevatedButton(
                              child: AutoSizeText(
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
            ),
    );
  }
}
