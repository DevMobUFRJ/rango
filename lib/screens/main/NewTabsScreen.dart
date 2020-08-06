import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rango/screens/SplashScreen.dart';
import 'package:rango/screens/main/tabs/HomeScreen.dart';
import 'package:rango/screens/main/tabs/ProfileScreen.dart';
import 'package:rango/screens/main/tabs/SearchScreen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class NewTabsScreen extends StatefulWidget {
  @override
  _NewTabsScreenState createState() => _NewTabsScreenState();
}

class _NewTabsScreenState extends State<NewTabsScreen> {
  List<Map<String, Object>> _pages;

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  String _name = "";
  bool _loading = true;

  Future<void> _getUser() async {
    final user = await FirebaseAuth.instance.currentUser();
    final userData =
        await Firestore.instance.collection("clients").document(user.uid).get();
    setState(() {
      _name = userData.data['name'].toString().split(" ")[0];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    PersistentTabController _controller;
    _controller = PersistentTabController(initialIndex: 0);

    return _loading
        ? SplashScreen()
        : PersistentTabView(
            controller: _controller,
            navBarStyle: NavBarStyle.style2,
            confineInSafeArea: true,
            bottomScreenMargin: 0,
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
              duration: Duration(milliseconds: 200),
            ),
            screens: <Widget>[
              HomeScreen(_name),
              SearchScreen(),
              ProfileScreen(),
            ],
            items: [
              PersistentBottomNavBarItem(
                  icon: Icon(Icons.home, size: 40),
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
          );
  }
}