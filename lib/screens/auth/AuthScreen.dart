import 'package:flutter/material.dart';
import 'package:rango/widgets/auth/AuthForm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth-screen';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;
  bool _isLogin;

  void _submitAuthForm({
    String email,
    String name,
    String password,
    BuildContext ctx,
  }) async {
    AuthResult authResult;

    try {
      setState(() => _isLoading = true);
      if (_isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        setState(() => _isLoading = true);
        authResult = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        await Firestore.instance
            .collection('clients')
            .document(authResult.user.uid)
            .setData({
          'name': name,
          'email': email,
        });
      }
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
    } on PlatformException catch (error) {
      var message = 'Ocorreu um erro';
      if (error.message != null) {
        message = error.message;
      }
      Scaffold.of(ctx).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).errorColor,
      ));
      setState(() => _isLoading = false);
    } catch (error) {
      setState(() => _isLoading = false);
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLogin = ModalRoute.of(context).settings.arguments;
    setState(() {
      _isLogin = isLogin;
    });
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.greenAccent),
        elevation: 0,
        backgroundColor: Colors.grey[200],
        title: Text(
          'Cadastro',
          style: TextStyle(
            color: Colors.deepOrange[300],
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[200],
      body: AuthForm(_submitAuthForm, _isLoading, _isLogin),
    );
  }
}
