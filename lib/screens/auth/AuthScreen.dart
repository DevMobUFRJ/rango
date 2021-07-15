import 'dart:io';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:rango/models/contact.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/models/shift.dart';
import 'package:rango/models/user_notification_settings.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/widgets/auth/AuthForm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

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
    File image,
    String password,
    BuildContext ctx,
  }) async {
    UserCredential authResult;

    try {
      setState(() => _isLoading = true);
      if (_isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        setState(() => _isLoading = true);
        authResult = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        String url;
        if (image != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('users/${authResult.user.uid}/logo.png');
          await ref.putFile(image).whenComplete(() => null);
          url = await ref.getDownloadURL();
        }
        var seller = Seller(
          id: authResult.user.uid,
          email: email,
          name: name,
          active: false,
          canReservate: true,
          logo: url != null ? url : null,
          description: null,
          paymentMethods: null,
          location: null,
          contact: Contact(
            name: null,
            phone: null,
          ),
          shift: null,
          address: null,
          currentMeals: null,
          notificationSettings: UserNotificationSettings(
              messages: true,
              newOrder: true,
              orderCanceled: true
          )
        );
        print(seller.id);
        print('create seller');
        await Repository.instance.createSeller(seller);
        print('finished creating seller');
      }
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
    } on PlatformException catch (error) {
      var message = 'Ocorreu um erro';
      if (error.message != null) {
        message = error.message;
      }
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
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
        backgroundColor: Colors.grey[200],
        title: Text(
          isLogin ? 'Login' : 'Cadastro',
          style: TextStyle(
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: AuthForm(_submitAuthForm, _isLoading, _isLogin),
    );
  }
}
