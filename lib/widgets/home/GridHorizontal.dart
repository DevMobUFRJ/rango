import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:flutter/foundation.dart';
import 'package:rango/models/order.dart';
import 'package:rango/screens/main/meals/ManageOrder.dart';

class GridHorizontal extends StatelessWidget {
  final List<Order> orders;

  GridHorizontal({
    @required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
        scrollDirection: Axis.horizontal,
        crossAxisCount: orders.length > 6 ? 2 : 1,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        padding: EdgeInsets.all(0),
        itemCount: orders.length,
        itemBuilder: (ctx, index) => GestureDetector(
              onTap: () => pushNewScreen(context,
                  screen: ManageOrder(
                    order: orders[index],
                  ),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino),
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: orders.length > 6 ? 3 : 4,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 0.5.wp),
                        child: orders[index].quentinhas[0].quentinha.picture !=
                                null
                            ? FadeInImage.assetNetwork(
                                placeholder:
                                    'assets/imgs/quentinha_placeholder.png',
                                image: orders[index]
                                    .quentinhas[0]
                                    .quentinha
                                    .picture,
                                fit: orders.length > 6
                                    ? BoxFit.fitWidth
                                    : BoxFit.fitWidth,
                              )
                            : Image.asset(
                                'assets/imgs/quentinha_placeholder.png',
                                fit: BoxFit.fitHeight,
                              ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: AutoSizeText(
                                  orders[index].quentinhas[0].quentinha.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    fontSize:
                                        orders.length > 6 ? 25.nsp : 30.nsp,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  'R\$${orders[index].quentinhas[0].quentinha.price}',
                                  style: GoogleFonts.montserrat(
                                    fontSize:
                                        orders.length > 6 ? 25.nsp : 28.nsp,
                                  ),
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
            ),
        staggeredTileBuilder: (index) => orders.length > 6
            ? StaggeredTile.count(1, 1.2)
            : StaggeredTile.count(1, 1.2));
  }
}
