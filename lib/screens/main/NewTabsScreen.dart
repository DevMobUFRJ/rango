import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rango/screens/builders/HomeScreenBuilder.dart';
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
  int _selectedPageIndex = 0;

  @override
  void initState() {
    _getUser();
    _pages = [
      {'page': HomeScreen(_name)},
      {'page': SearchScreen()},
      {'page': ProfileScreen()},
    ];
    super.initState();
  }

  String _name = "";
  var _loading = true;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _getUser() async {
    final user = await FirebaseAuth.instance.currentUser();
    final userData =
        await Firestore.instance.collection("clients").document(user.uid).get();
    setState(() {
      _pages = [
        {
          'page':
              HomeScreenBuilder(userData.data['name'].toString().split(" ")[0])
        },
        {'page': SearchScreen()},
        {'page': ProfileScreen()},
      ];
      _name = userData.data['name'].toString().split(" ")[0];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    PersistentTabController _controller;
    _controller = PersistentTabController(initialIndex: 0);

    return PersistentTabView(
      controller: _controller,
      navBarStyle: NavBarStyle.style2,
      confineInSafeArea: true,
      backgroundColor: Theme.of(context).backgroundColor,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      //decoration: ,
      popAllScreensOnTapOfSelectedTab: true,
      itemAnimationProperties: ItemAnimationProperties(
        // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 200),
      ),
      screens: <Widget>[
        HomeScreen('Gabriel'),
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
