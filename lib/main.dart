import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/SplashScreen.dart';
import 'package:rango/screens/auth/AuthScreen.dart';
import 'package:rango/screens/auth/ForgotPasswordScreen.dart';
import 'package:rango/screens/auth/LoginScreen.dart';
import 'package:rango/screens/main/home/ChatScreen.dart';
import 'package:rango/screens/main/tabs/NewTabsScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/seller.dart';

var currentKey = GlobalKey();

PersistentTabController _controller = PersistentTabController(initialIndex: 0);
final chatScreenKey = new GlobalKey<State<ChatScreen>>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  const AndroidInitializationSettings initializationAndroidSettings =
      AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationAndroidSettings);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String payload) async {
      if (payload != null) {
        if (payload == 'orders') {
          _controller.jumpToTab(0);
        } else if (payload == 'meals') {
          _controller.jumpToTab(1);
        } else if (payload.contains('chat')) {
          String clientId = payload.split('/')[1];
          String clientName = payload.split('/')[2];
          pushNewScreen(
            currentKey.currentState.context,
            withNavBar: false,
            screen: ChatScreen(clientId, clientName, key: chatScreenKey),
          );
        }
      }
    },
  );

  await FirebaseMessaging.instance.subscribeToTopic('all');
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if ((message.data['payload'].toString().contains('chat') &&
            chatScreenKey.currentState == null) ||
        !message.data['payload'].toString().contains('chat')) {
      _showNotification(message.data);
    }
  });
  FirebaseMessaging.onBackgroundMessage(_receiveOnBackgroundMessage);
  runApp(MyApp());
}

Future<void> _receiveOnBackgroundMessage(RemoteMessage message) async {
  _showNotification(message.data);
}

Future<void> _showNotification(Map<String, dynamic> message) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    message['channelId'],
    message['channelName'],
    message['channelDescription'],
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    int.parse(message['id']),
    message['title'],
    message['description'],
    platformChannelSpecifics,
    payload: message['payload'],
  );
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
            textStyle: GoogleFonts.montserrat(),
            padding: EdgeInsets.symmetric(vertical: 10),
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
            return FutureBuilder(
                future:
                    Repository.instance.getSellerFuture(userSnapshot.data.uid),
                builder: (ctx,
                    AsyncSnapshot<DocumentSnapshot<Seller>> sellerSnapshot) {
                  if (!sellerSnapshot.hasData ||
                      sellerSnapshot.connectionState ==
                          ConnectionState.waiting) {
                    return SplashScreen();
                  }

                  if (sellerSnapshot.hasError) {
                    return LoginScreen();
                  }

                  FirebaseMessaging.instance.onTokenRefresh
                      .listen((newToken) async {
                    Map<String, dynamic> dataToUpdate = {};
                    Seller seller = sellerSnapshot.data.data();
                    var sellerInstance =
                        Repository.instance.sellersRef.doc(seller.id);
                    dataToUpdate['deviceToken'] = newToken;
                    await sellerInstance.update(dataToUpdate);
                  });

                  return NewTabsScreen(sellerSnapshot.data.data(), _controller);
                });
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
