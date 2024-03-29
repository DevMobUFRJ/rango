import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:flutter/foundation.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/screens/seller/SellerProfile.dart';
import 'package:rango/utils/string_formatters.dart';
import 'package:shimmer/shimmer.dart';
import 'package:transparent_image/transparent_image.dart';

class SellerGridVertical extends StatelessWidget {
  final String title;
  final List<Seller> sellers;
  final Position userLocation;
  final PersistentTabController controller;

  SellerGridVertical({
    @required this.title,
    @required this.sellers,
    @required this.userLocation,
    @required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0.04.wp),
          child: AutoSizeText(
            title,
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 28.nsp,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0.02.hp),
          width: double.infinity,
          child: StaggeredGridView.countBuilder(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            crossAxisCount: 2,
            physics:
                NeverScrollableScrollPhysics(), // Desativa o scroll separado e mantem somente o da tela principal
            itemCount: sellers.length,
            staggeredTileBuilder: (index) => StaggeredTile.fit(1),
            itemBuilder: (ctx, index) => GestureDetector(
              onTap: () => pushNewScreen(
                ctx,
                withNavBar: false,
                screen: SellerProfile(
                  sellers[index].id,
                  sellers[index].name,
                  controller,
                ),
              ),
              child: Container(
                constraints: BoxConstraints.expand(height: 430.h),
                child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: <Widget>[
                      Flexible(
                        flex: 0,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (sellers[index].logo != null) ...{
                              _renderWithImage(),
                              CachedNetworkImage(
                                imageUrl: sellers[index].logo,
                                height: 330.h,
                                width: 330.w,
                                fit: BoxFit.cover,
                                placeholder: (ctx, url) => Image(
                                    image: MemoryImage(kTransparentImage)),
                                errorWidget: (ctx, url, error) =>
                                    _renderWithoutImage(ctx),
                              ),
                            } else ...{
                              _renderWithoutImage(ctx)
                            }
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: 1),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  flex: 1,
                                  child: AutoSizeText(
                                    sellers[index].name,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    minFontSize: 15,
                                    maxFontSize: 15,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(),
                                  ),
                                ),
                                SizedBox(height: 3),
                                Flexible(
                                  flex: 1,
                                  child: AutoSizeText(
                                    distanceInKM(sellers[index], userLocation),
                                    minFontSize: 15,
                                    maxFontSize: 15,
                                    style: GoogleFonts.montserrat(),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderWithImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Shimmer.fromColors(
          baseColor: Color.fromRGBO(255, 175, 153, 1),
          highlightColor: Colors.white,
          child: Container(
            height: 330.h,
            width: 330.w,
            color: Colors.white,
          ),
        ),
        Center(
          child: Icon(
            Icons.store,
            size: 75,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _renderWithoutImage(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 330.h,
          color: Theme.of(context).accentColor,
        ),
        Center(
          child: Icon(
            Icons.store,
            size: 75,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
