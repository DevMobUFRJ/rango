import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rango/screens/main/tabs/HomeScreen.dart';
import 'package:rango/screens/main/tabs/ProfileScreen.dart';
import 'package:rango/screens/main/tabs/SearchScreen.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
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
        {'page': HomeScreen(userData.data['name'].toString().split(" ")[0])},
        {'page': SearchScreen()},
        {'page': ProfileScreen()},
      ];
      _name = userData.data['name'].toString().split(" ")[0];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          onTap: _selectPage,
          currentIndex: _selectedPageIndex,
          backgroundColor: Theme.of(context).backgroundColor,
          selectedItemColor: Color(0xFF609B90),
          unselectedItemColor: Theme.of(context).primaryColor,
          elevation: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 40), title: Text('Home')),
            BottomNavigationBarItem(
                icon: Icon(Icons.search, size: 40), title: Text('Search')),
            BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 40), title: Text('Account'))
          ]),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _pages[_selectedPageIndex]['page'],
    );
  }
}
