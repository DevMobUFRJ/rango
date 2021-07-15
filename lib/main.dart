import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/SplashScreen.dart';
import 'package:rango/screens/auth/AuthScreen.dart';
import 'package:rango/screens/auth/ForgotPasswordScreen.dart';
import 'package:rango/screens/auth/LoginScreen.dart';
import 'package:rango/screens/main/tabs/NewTabsScreen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/seller.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  const AndroidInitializationSettings initializationAndroidSettings = AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationAndroidSettings);
  await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          print(payload);
        }
      });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rango',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          elevation: 0,
          color: Colors.transparent,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Color(0xFF8FDDCE),
          ),
        ),
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        backgroundColor: Color(0xFFF5F5F5),
        accentColor: Color(0xFFFFC744F),
        primaryColor: Color(0xFF8FDDCE),
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme)
            .copyWith(
          headline1: TextStyle(
            fontSize: 35,
            color: Colors.deepOrange[300],
            fontWeight: FontWeight.w500,
          ),
          headline2: TextStyle(
            fontSize: 20,
            color: Color(0xFFF9B152),
          ),
          button: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Color.fromRGBO(252, 116, 79, 1),
            textStyle: GoogleFonts.montserrat(fontSize: 26),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, AsyncSnapshot<User> userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }

          if (userSnapshot.hasError) {
            return LoginScreen();
          }

          if (userSnapshot.hasData) {
            return StreamBuilder(
              stream: Repository.instance.getSeller(userSnapshot.data.uid),
              builder: (ctx, AsyncSnapshot<DocumentSnapshot<Seller>> sellerSnapshot) {
                if (!sellerSnapshot.hasData || sellerSnapshot.connectionState == ConnectionState.waiting) {
                  return SplashScreen();
                }

                if (sellerSnapshot.hasError) {
                  return LoginScreen();
                }

                return NewTabsScreen(sellerSnapshot.data.data());
              }
            );
          }
          return LoginScreen();
        },
      ),
      routes: {
        AuthScreen.routeName: (ctx) => AuthScreen(),
        ForgotPasswordScreen.routeName: (ctx) => ForgotPasswordScreen(),
      },
    );
  }
}
