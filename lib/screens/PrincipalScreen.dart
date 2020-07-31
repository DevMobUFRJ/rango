import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrincipalScreen extends StatefulWidget {
  @override
  _PrincipalScreenState createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  @override
  void initState() {
    _getUser();
    super.initState();
  }

  String _name = "";
  var _loading = true;

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
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _loading
                  ? CircularProgressIndicator()
                  : Text('Olá, $_name!\nBateu a fome?')
            ],
          ),
        ),
      ),
    );
  }
}
