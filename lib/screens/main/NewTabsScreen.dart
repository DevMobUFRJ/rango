import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rango/main.dart';
import 'package:rango/models/client.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/SplashScreen.dart';
import 'package:rango/screens/main/tabs/HomeScreen.dart';
import 'package:rango/screens/main/tabs/OrderHistory.dart';
import 'package:rango/screens/main/tabs/ProfileScreen.dart';
import 'package:rango/screens/main/tabs/SearchScreen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NewTabsScreen extends StatefulWidget {
  final PersistentTabController controller;

  NewTabsScreen(this.controller);
  @override
  _NewTabsScreenState createState() => _NewTabsScreenState();
}

class _NewTabsScreenState extends State<NewTabsScreen> {
  @override
  void initState() {
    _getUserId();
    super.initState();
  }

  String userId;
  Client actualClient;
  bool loading = true;

  void _getUserId() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() => {
          loading = false,
          userId = user.uid,
        });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? SplashScreen()
        : StreamBuilder(
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
              return StreamBuilder(
                stream: Repository.instance.getClientStream(userId),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData ||
                      snapshot.data.data == null) {
                    return SplashScreen();
                  }
                  Client cliente = snapshot.data.data() as Client;
                  // if (snap.hasData && snap.data == ConnectivityResult.none) {
                  //   return Container(
                  //     height: 1.hp - 56,
                  //     child: Scaffold(
                  //       body: NoConecctionWidget(),
                  //     ),
                  //   );
                  // }
                  actualClient = cliente;
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
                      HomeScreen(cliente, widget.controller, key: currentKey),
                      SearchScreen(cliente),
                      OrderHistoryScreen(widget.controller),
                      ProfileScreen(cliente, widget.controller),
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
            },
          );
  }
}
