import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/widgets/home/SellerGridVertical.dart';

class SellersList extends StatelessWidget {
  final List<Seller> sellerList;
  final AsyncSnapshot<Position> locationSnapshot;
  final Client client;
  final PersistentTabController controller;

  const SellersList(
    this.sellerList,
    this.locationSnapshot,
    this.client,
    this.controller,
  );

  @override
  Widget build(BuildContext context) {
    // Ordena por sellers favoritos
    var favorites = client.favoriteSellers;
    if (favorites != null) {
      sellerList.sort(
        (a, b) => favorites.indexOf(b.id).compareTo(favorites.indexOf(a.id)),
      );
    }

    return SellerGridVertical(
      title: 'Vendedores',
      sellers: sellerList,
      userLocation: locationSnapshot.data,
      controller: controller,
    );
  }
}
