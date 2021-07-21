import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/widgets/home/SellerGridVertical.dart';

class SellersList extends StatelessWidget {
  final List<Seller> sellerList;
  final AsyncSnapshot<Position> locationSnapshot;
  final String clientId;
  final PersistentTabController controller;

  const SellersList(
    this.sellerList,
    this.locationSnapshot,
    this.clientId,
    this.controller,
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Repository.instance.getClientStream(clientId),
      builder: (context, AsyncSnapshot<DocumentSnapshot> clientSnapshot) {
        if (!clientSnapshot.hasData ||
            clientSnapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 0.5.hp,
            alignment: Alignment.center,
            child: SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(
                color: Theme.of(context).accentColor,
              ),
            ),
          );
        }
        if (clientSnapshot.hasError) {
          return Container(
            height: 0.6.hp - 56,
            alignment: Alignment.center,
            child: AutoSizeText(
              clientSnapshot.error.toString(),
              style: GoogleFonts.montserrat(
                  fontSize: 45.nsp, color: Theme.of(context).accentColor),
            ),
          );
        }

        // Ordena por sellers favoritos
        Client client = clientSnapshot.data.data();
        var favorites = client.favoriteSellers;
        if (favorites != null) {
          sellerList.sort(
            (a, b) =>
                favorites.indexOf(b.id).compareTo(favorites.indexOf(a.id)),
          );
        }

        return SellerGridVertical(
          title: 'Vendedores',
          sellers: sellerList,
          userLocation: locationSnapshot.data,
          controller: controller,
        );
      },
    );
  }
}
