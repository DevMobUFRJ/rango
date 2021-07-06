import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rango/main.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/user_notification_settings.dart';
import 'package:rango/screens/SplashScreen.dart';
import 'package:rango/screens/main/tabs/HomeScreen.dart';
import 'package:rango/screens/main/tabs/OrderHistory.dart';
import 'package:rango/screens/main/tabs/ProfileScreen.dart';
import 'package:rango/screens/main/tabs/SearchScreen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NewTabsScreen extends StatefulWidget {
  @override
  _NewTabsScreenState createState() => _NewTabsScreenState();
}

Future<void> _showNotification(Map<String, dynamic> message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    '1',
    'teste',
    'descr',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  print(message);
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    message['title'],
    message['description'],
    platformChannelSpecifics,
    payload: 'item x',
  );
}

Future<void> _teste(RemoteMessage message) async {
  print(message);
  _showNotification(message.data);
}

class _NewTabsScreenState extends State<NewTabsScreen> {
  Future<void> _registerOnFirebase() async {
    await FirebaseMessaging.instance.subscribeToTopic('all');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('otario');
      print(message.data);
      _showNotification(message.data);
    });
    FirebaseMessaging.onBackgroundMessage(_teste);
  }

  @override
  void initState() {
    _getUserId();
    _registerOnFirebase();
    super.initState();
  }

  String userId;
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
            stream: FirebaseFirestore.instance
                .collection('clients')
                .doc(userId)
                .snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData ||
                  snapshot.data.data == null) {
                //      !snapshot.data.data containsKey('email')
                return SplashScreen();
              }
              Client client = new Client(
                id: userId,
                email: snapshot?.data['email']?.toString(),
                picture: snapshot?.data['picture']?.toString(),
                name: snapshot.data['name'].toString(),
                phone: snapshot?.data['phone']?.toString(),
                notificationSettings: snapshot.data['notifications'] != null
                    ? UserNotificationSettings(
                        discounts: snapshot.data['notifications']['discounts'],
                        favoriteSellers: snapshot.data['notifications']
                            ['favoriteSellers'],
                        messages: snapshot.data['notifications']['messages'],
                        reservations: snapshot.data['notifications']
                            ['reservations'],
                      )
                    : null,
              );
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
                  HomeScreen(client),
                  SearchScreen(client),
                  OrderHistoryScreen(),
                  ProfileScreen(client),
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
