import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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
        try {
          var sellers = await FirebaseFirestore.instance
              .collection('sellers')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
          bool isSeller = sellers.docs.isNotEmpty;
          if (!isSeller) {
            authResult = await _auth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
            Map<String, dynamic> dataToUpdate = {};
            dataToUpdate['deviceToken'] =
                await FirebaseMessaging.instance.getToken();
            await FirebaseFirestore.instance
                .collection('clients')
                .doc(FirebaseAuth.instance.currentUser.uid)
                .update(dataToUpdate);
            Navigator.of(context).pop();
          } else {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
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
              errorText =
                  'Acesso a conta bloqueado, tente mais tarde ou resete sua senha.';
              break;
            case 'user-not-found':
              errorText = 'Essa conta não existe';
              break;
            case 'wrong-password':
              errorText = 'Senha inválida';
              break;
            case 'network-request-failed':
              errorText = 'Erro de conexão, tente novamente';
              break;
            default:
              errorText = 'Ocorreu um erro';
          }
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
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
        User user = _auth.currentUser;
        user.updateDisplayName(name);

        String url;
        if (image != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('user_image')
              .child(authResult.user.uid + '.jpg');
          await ref.putFile(image).whenComplete(() => null);
          url = 'gs://rango-ufrj.appspot.com/${ref.fullPath}';
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
            content: Text(
              'Erro de conexão, tente novamente.',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(
              error.message,
              textAlign: TextAlign.center,
            ),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
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
