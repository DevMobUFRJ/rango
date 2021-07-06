import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/widgets/home/SellerGridVertical.dart';

class SellersList extends StatelessWidget {
  final List<Seller> sellerList;
  final AsyncSnapshot<Position> locationSnapshot;
  final String clientId;

  const SellersList(
    this.sellerList,
    this.locationSnapshot,
    this.clientId,
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
        var clientSnapshotdata =
            clientSnapshot.data.data() as Map<String, dynamic>;
        var favorites = clientSnapshotdata['favoriteSellers'];
        if (favorites != null) {
          sellerList.sort(
            (a, b) =>
                favorites.indexOf(b.id).compareTo(favorites.indexOf(a.id)),
          );
        }

        return SellerGridVertical(
          tagM: Random().nextDouble(),
          title: 'Vendedores',
          sellers: sellerList,
          userLocation: locationSnapshot.data,
        );
      },
    );
  }
}
