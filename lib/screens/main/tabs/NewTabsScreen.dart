import 'package:flutter/material.dart';
import 'package:rango/main.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/screens/main/tabs/ManageMealsScreen.dart';
import 'package:rango/screens/main/tabs/HomeScreen.dart';
import 'package:rango/screens/main/tabs/ProfileScreen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class NewTabsScreen extends StatefulWidget {
  final Seller seller;
  final PersistentTabController controller;

  NewTabsScreen(this.seller, this.controller);

  @override
  _NewTabsScreenState createState() => _NewTabsScreenState();
}

class _NewTabsScreenState extends State<NewTabsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: PersistentTabView(
        controller: widget.controller,
        navBarStyle: NavBarStyle.style6,
        confineInSafeArea: true,
        backgroundColor: Theme.of(context).backgroundColor,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardShows: true,
        popAllScreensOnTapOfSelectedTab: true,
        itemAnimationProperties: ItemAnimationProperties(
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.easeIn,
          duration: Duration(milliseconds: 180),
        ),
        screens: <Widget>[
          HomeScreen(widget.seller, widget.controller, key: currentKey),
          ManageMealsScreen(widget.seller),
          ProfileScreen(widget.seller),
        ],
        items: [
          PersistentBottomNavBarItem(
              icon: Icon(Icons.list_alt, size: 40),
              activeColor: Color(0xFF609B90),
              inactiveColor: Theme.of(context).primaryColor),
          PersistentBottomNavBarItem(
              icon: Icon(Icons.local_dining, size: 40),
              activeColor: Color(0xFF609B90),
              inactiveColor: Theme.of(context).primaryColor),
          PersistentBottomNavBarItem(
              icon: Icon(Icons.person, size: 40),
              activeColor: Color(0xFF609B90),
              inactiveColor: Theme.of(context).primaryColor),
        ],
      ),
    );
  }
}
