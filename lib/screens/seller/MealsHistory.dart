import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/models/order.dart';

class MealsHistory extends StatefulWidget {
  final List<Order> orders;

  MealsHistory({@required this.orders});

  @override
  _MealsHistoryState createState() => _MealsHistoryState();
}

class _MealsHistoryState extends State<MealsHistory> {
  List<bool> ordersCheckedValue;

  @override
  void initState() {
    setState(() {
      ordersCheckedValue = List.filled(widget.orders.length, false);
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
              child: StaggeredGridView.countBuilder(
                scrollDirection: Axis.vertical,
                crossAxisCount: 2,
                shrinkWrap: true,
                itemCount: widget.orders.length,
                staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                itemBuilder: (ctx, index) => Container(
                  child: Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            FadeInImage.assetNetwork(
                              placeholder:
                                  'assets/imgs/quentinha_placeholder.png',
                              image: widget.orders[index].quentinha.picture,
                              fit: BoxFit.fitWidth,
                            ),
                            Checkbox(
                              value: ordersCheckedValue[index],
                              onChanged: (value) => setState(
                                  () => ordersCheckedValue[index] = value),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Column(
                            children: <Widget>[
                              AutoSizeText(
                                widget.orders[index].quentinha.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(fontSize: 24.nsp),
                              ),
                              AutoSizeText(
                                'R\$${widget.orders[index].quentinha.price}',
                                style: GoogleFonts.montserrat(fontSize: 24.nsp),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
