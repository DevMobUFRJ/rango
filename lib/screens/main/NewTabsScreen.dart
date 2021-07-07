import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rango/main.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/SplashScreen.dart';
import 'package:rango/screens/main/tabs/HomeScreen.dart';
import 'package:rango/screens/main/tabs/OrderHistory.dart';
import 'package:rango/screens/main/tabs/ProfileScreen.dart';
import 'package:rango/screens/main/tabs/SearchScreen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rango/screens/seller/ChatScreen.dart';

class NewTabsScreen extends StatefulWidget {
  @override
  _NewTabsScreenState createState() => _NewTabsScreenState();
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

Future<void> _receiveOnBackgroundMessage(RemoteMessage message) async {
  _showNotification(message.data);
}

class _NewTabsScreenState extends State<NewTabsScreen> {
  Future<void> _registerOnFirebase() async {
    await FirebaseMessaging.instance.subscribeToTopic('all');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message.data);
    });
    FirebaseMessaging.onBackgroundMessage(_receiveOnBackgroundMessage);
  }

  void _configNotification() async {
    const AndroidInitializationSettings initializationAndroidSettings =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationAndroidSettings);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          if (payload == 'historico') {
            pushNewScreen(
              context,
              screen: OrderHistoryScreen(),
              withNavBar: true,
            );
          } else if (payload.contains('chat')) {
            String sellerId = payload.split('/')[1];
            print('clicou na notificação');
            var sellerJson = await FirebaseFirestore.instance
                .collection('sellers')
                .doc(sellerId)
                .get();
            Seller seller = Seller.fromJson(sellerJson.data());
            pushNewScreen(context, screen: ChatScreen(seller));
          }
        }
      },
    );
  }

  @override
  void initState() {
    _configNotification();
    _getUserId();
    _registerOnFirebase();
    super.initState();
  }

  String userId;
  Client actualClient;
  bool loading = true;

  void _getUserId() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() => {
          loading = false,
          userId = user.uid,
        });
  }

  @override
  Widget build(BuildContext context) {
    PersistentTabController _controller;
    _controller = PersistentTabController(initialIndex: 0);
    return loading
        ? SplashScreen()
        : StreamBuilder(
            stream: Repository.instance.getClientStream(userId),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData ||
                  snapshot.data.data == null) {
                return SplashScreen();
              }
              Client cliente = snapshot.data.data() as Client;
              actualClient = cliente;
              return PersistentTabView(
                controller: _controller,
                navBarStyle: NavBarStyle.style6,
                confineInSafeArea: true,
                backgroundColor: Theme.of(context).backgroundColor,
                handleAndroidBackButtonPress: true,
                resizeToAvoidBottomInset: true,
                stateManagement: true,
                hideNavigationBarWhenKeyboardShows: true,
                popAllScreensOnTapOfSelectedTab: true,
                itemAnimationProperties: ItemAnimationProperties(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.ease,
                ),
                screenTransitionAnimation: ScreenTransitionAnimation(
                  animateTabTransition: true,
                  curve: Curves.easeIn,
                  duration: Duration(milliseconds: 180),
                ),
                screens: <Widget>[
                  HomeScreen(cliente),
                  SearchScreen(cliente),
                  OrderHistoryScreen(),
                  ProfileScreen(cliente),
                ],
                items: [
                  PersistentBottomNavBarItem(
                      icon: Icon(Icons.home, size: 40),
                      activeColor: Color(0xFF609B90),
                      inactiveColor: Theme.of(context).primaryColor),
                  PersistentBottomNavBarItem(
                      icon: Icon(Icons.location_on, size: 40),
                      activeColor: Color(0xFF609B90),
                      inactiveColor: Theme.of(context).primaryColor),
                  PersistentBottomNavBarItem(
                      icon: Icon(Icons.history, size: 40),
                      activeColor: Color(0xFF609B90),
                      inactiveColor: Theme.of(context).primaryColor),
                  PersistentBottomNavBarItem(
                      icon: Icon(Icons.person, size: 40),
                      activeColor: Color(0xFF609B90),
                      inactiveColor: Theme.of(context).primaryColor),
                ],
              );
            },
          );
  }
}
