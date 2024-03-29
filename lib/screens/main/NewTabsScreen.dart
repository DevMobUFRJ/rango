import 'package:flutter/material.dart';
import 'package:rango/main.dart';
import 'package:rango/models/client.dart';
import 'package:rango/screens/main/tabs/HomeScreen.dart';
import 'package:rango/screens/main/tabs/NewSearchScreen.dart';
import 'package:rango/screens/main/tabs/OrderHistory.dart';
import 'package:rango/screens/main/tabs/ProfileScreen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class NewTabsScreen extends StatefulWidget {
  final Client client;
  final PersistentTabController controller;

  NewTabsScreen(this.client, this.controller);
  @override
  _NewTabsScreenState createState() => _NewTabsScreenState();
}

class _NewTabsScreenState extends State<NewTabsScreen> {
  Widget build(BuildContext context) {
    return PersistentTabView(
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
        HomeScreen(widget.client, widget.controller, key: currentKey),
        NewSearchScreen(widget.controller),
        OrderHistoryScreen(widget.controller),
        ProfileScreen(widget.client, widget.controller),
      ],
      items: [
        PersistentBottomNavBarItem(
            icon: Icon(Icons.home, size: 40),
            activeColor: Color(0xFF609B90),
            inactiveColor: Theme.of(context).primaryColor),
        PersistentBottomNavBarItem(
            icon: Icon(Icons.location_on, size: 40),
            activeColor: Color(0xFF609B90),
            inactiveColor: Theme.of(context).primaryColor),
        PersistentBottomNavBarItem(
            icon: Icon(Icons.history, size: 40),
            activeColor: Color(0xFF609B90),
            inactiveColor: Theme.of(context).primaryColor),
        PersistentBottomNavBarItem(
            icon: Icon(Icons.person, size: 40),
            activeColor: Color(0xFF609B90),
            inactiveColor: Theme.of(context).primaryColor),
      ],
    );
  }
}
