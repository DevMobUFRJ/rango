import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:rango/models/user_notification_settings.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/utils/constants.dart';
import 'package:rango/widgets/auth/AuthForm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
    File image,
    String password,
    String phone,
    BuildContext ctx,
  }) async {
    UserCredential authResult;

    try {
      setState(() => _isLoading = true);
      if (_isLogin) {
        try {
          await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          var sellers = await FirebaseFirestore.instance
              .collection('sellers')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
          bool isSeller = sellers.docs.isNotEmpty;
          if (!isSeller) {
            Map<String, dynamic> dataToUpdate = {};
            dataToUpdate['deviceToken'] =
                await FirebaseMessaging.instance.getToken();
            Repository.instance.updateClient(
                FirebaseAuth.instance.currentUser.uid, dataToUpdate);
            Navigator.of(context).pop();
          } else {
            _auth.signOut();
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 2),
                content: Text(
                  'Você tentou entrar com uma conta de vendedor! Use o app do vendedor para isso.',
                  textAlign: TextAlign.center,
                ),
                backgroundColor: Theme.of(context).errorColor,
              ),
            );
          }
        } on FirebaseAuthException catch (error) {
          print(error.code);
          String errorText;
          switch (error.code) {
            case 'too-many-requests':
              errorText = tooManyRequestsErrorMessage;
              break;
            case 'user-not-found':
              errorText = userNotFoundErrorMessage;
              break;
            case 'wrong-password':
              errorText = wrongPasswordErrorMessage;
              break;
            case 'network-request-failed':
              errorText = networkErrorMessage;
              break;
            default:
              errorText = defaultErrorMessage;
          }
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 2),
              content: Text(
                errorText,
                textAlign: TextAlign.center,
              ),
              backgroundColor: Theme.of(context).errorColor,
            ),
          );
        } catch (error) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 2),
              content: Text(
                'Ocorreu um erro',
                textAlign: TextAlign.center,
              ),
              backgroundColor: Theme.of(context).errorColor,
            ),
          );
        }
      } else {
        setState(() => _isLoading = true);
        authResult = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        await authResult.user.updateDisplayName(name);
        _auth.currentUser.reload();

        String url;
        if (image != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('users/${authResult.user.uid}/picture.png');
          await ref.putFile(image).whenComplete(() => null);
          url = await ref.getDownloadURL();
        }
        String deviceToken = await FirebaseMessaging.instance.getToken();
        await FirebaseFirestore.instance
            .collection('clients')
            .doc(authResult.user.uid)
            .set(
          {
            'name': name,
            'email': email,
            'picture': url != null ? url : null,
            'deviceToken': deviceToken,
            'phone': phone,
            'notifications':
                UserNotificationSettings(messages: true, reservations: true)
                    .toJson()
          },
        );
        Navigator.of(context).pop();
      }
      setState(() => _isLoading = false);
    } on FirebaseAuthException catch (error) {
      setState(() => _isLoading = false);
      if (error.code == 'network-request-failed') {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text(
              networkErrorMessage,
              textAlign: TextAlign.center,
            ),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text(
              error.message,
              textAlign: TextAlign.center,
            ),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      }
    } catch (error) {
      authResult.user.delete();
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            'Ocorreu um erro',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLogin = ModalRoute.of(context).settings.arguments;
    setState(
      () {
        _isLogin = isLogin;
      },
    );
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
