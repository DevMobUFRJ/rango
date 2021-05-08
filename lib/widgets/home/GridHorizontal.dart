import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:flutter/foundation.dart';
import 'package:rango/models/order.dart';
import 'package:rango/screens/seller/ManageOrder.dart';

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
            withNavBar: true,
            pageTransitionAnimation: PageTransitionAnimation.cupertino),
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: <Widget>[
              FadeInImage.assetNetwork(
                placeholder: 'assets/imgs/quentinha_placeholder.png',
                image: orders[index].quentinha.picture,
                fit: BoxFit.fitWidth,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  children: <Widget>[
                    AutoSizeText(
                      orders[index].quentinha.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: orders.length > 6 ? 24.nsp : 28.nsp,
                      ),
                    ),
                    AutoSizeText(
                      'R\$${orders[index].quentinha.price}',
                      style: GoogleFonts.montserrat(
                        fontSize: orders.length > 6 ? 24.nsp : 28.nsp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      staggeredTileBuilder: (index) => StaggeredTile.fit(1),
    );
  }
}
