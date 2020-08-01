import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrincipalScreen extends StatefulWidget {
  @override
  _PrincipalScreenState createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  int _selectedPageIndex = 0;

  @override
  void initState() {
    _getUser();
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
      _loading = false;
      _name = userData.data['name'].toString().split(" ")[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
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
      body: Center(
        child: Container(
          color: Theme.of(context).backgroundColor,
          padding: EdgeInsets.symmetric(horizontal: 18),
          width: double.infinity,
          child: _loading
              ? CircularProgressIndicator()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Olá, $_name!\nBateu a fome?',
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.headline1),
                    SizedBox(height: 10),
                    Text('Sugestões do dia'),
                  ],
                ),
        ),
      ),
    );
  }
}
