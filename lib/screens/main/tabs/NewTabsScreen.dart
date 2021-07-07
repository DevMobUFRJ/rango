import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rango/models/contact.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/models/user_notification_settings.dart';
import 'package:rango/screens/SplashScreen.dart';
import 'package:rango/screens/main/tabs/AddMealScreen.dart';
import 'package:rango/screens/main/tabs/HomeScreen.dart';
import 'package:rango/screens/main/tabs/ProfileScreen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/main.dart';

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

Future<void> _handleNotification(RemoteMessage message) async {
  _showNotification(message.data);
}

class _NewTabsScreenState extends State<NewTabsScreen> {
  Future<void> _registerOnFirebase() async {
    await FirebaseMessaging.instance.subscribeToTopic('all');
    var token = await FirebaseMessaging.instance.getToken();
    print("Token: $token");
    //TODO Salvar token no firebase o atual é diferente do novo
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message.data);
    });
    FirebaseMessaging.onBackgroundMessage(_handleNotification);
  }

  @override
  void initState() {
    _getUser();
    _registerOnFirebase();
    super.initState();
  }

  Seller seller;
  bool _loading = true;

  Future<void> _getUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final userData =
        await FirebaseFirestore.instance.collection("sellers").doc(user.uid).get();
    setState(() {
      seller = new Seller(
        id: user.uid,
        email: userData?.data()['email']?.toString(),
        picture: userData?.data()['picture']?.toString(),
        description: userData?.data()['description'].toString(),
        paymentMethods: userData?.data()['paymentMethods'].toString(),
        name: userData.data()['name'].toString(),
        contact: userData?.data()['contact'] != null
            ? Contact(
                phone: userData?.data()['contact']['phone']?.toString(),
                name: userData?.data()['contact']['name']?.toString(),
              )
            : null,
        canReservate: userData?.data()['canReservate'],
        active: userData?.data()['active'],
        notificationSettings: userData.data()['notificationSettings'] != null
            ? UserNotificationSettings(
                discounts: userData.data()['notifications']['discounts'],
                favoriteSellers: userData.data()['notifications']
                    ['favoriteSellers'],
                messages: userData.data()['notifications']['messages'],
                reservations: userData.data()['notifications']['reservations'],
              )
            : null,
      );
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    PersistentTabController _controller;
    _controller = PersistentTabController(initialIndex: 0);

    return _loading
        ? SplashScreen()
        : SafeArea(
            top: false,
            left: false,
            right: false,
            child: PersistentTabView(
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
                HomeScreen(seller),
                AddMealScreen(seller),
                ProfileScreen(seller),
              ],
              items: [
                PersistentBottomNavBarItem(
                    icon: Icon(Icons.home, size: 40),
                    activeColor: Color(0xFF609B90),
                    inactiveColor: Theme.of(context).primaryColor),
                PersistentBottomNavBarItem(
                    icon: Icon(Icons.local_dining, size: 40),
                    activeColor: Color(0xFF609B90),
                    inactiveColor: Theme.of(context).primaryColor),
                PersistentBottomNavBarItem(
                    icon: Icon(Icons.person, size: 40),
                    activeColor: Color(0xFF609B90),
                    inactiveColor: Theme.of(context).primaryColor),
              ],
            ),
          );
  }
}
