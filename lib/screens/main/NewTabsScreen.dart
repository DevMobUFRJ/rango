import 'package:flutter/material.dart';
import 'package:rango/main.dart';
import 'package:rango/models/client.dart';
import 'package:rango/screens/main/tabs/HomeScreen.dart';
import 'package:rango/screens/main/tabs/OrderHistory.dart';
import 'package:rango/screens/main/tabs/ProfileScreen.dart';
import 'package:rango/screens/main/tabs/SearchScreen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NewTabsScreen extends StatefulWidget {
  final Client client;
  final PersistentTabController controller;

  NewTabsScreen(this.client, this.controller);
  @override
  _NewTabsScreenState createState() => _NewTabsScreenState();
}

class _NewTabsScreenState extends State<NewTabsScreen> {
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snap) {
        // if (snap.connectionState == ConnectionState.waiting ||
        //     !snap.hasData) {
        //   return Container(
        //     height: 1.hp - 56,
        //     child: Scaffold(
        //       body: NoConecctionWidget(),
        //     ),
        //   );
        // }
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
            SearchScreen(widget.client),
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
      },
    );
  }
}
