import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/main.dart';
import 'package:rango/models/client.dart';
import 'package:rango/models/meal_request.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/main/tabs/SearchScreen.dart';
import 'package:rango/screens/seller/ChatScreen.dart';
import 'package:rango/utils/constants.dart';
import 'package:rango/utils/date_time.dart';
import 'package:rango/widgets/home/ListaHorizontal.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rango/widgets/user/UserPicture.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;

class SellerProfile extends StatefulWidget {
  final String sellerName;
  final String sellerId;
  final PersistentTabController controller;
  final bool fromMap;

  SellerProfile(
    this.sellerId,
    this.sellerName,
    this.controller, {
    this.fromMap = false,
  });

  @override
  _SellerProfileState createState() => _SellerProfileState();
}

void _showShiftDialog(Seller seller, BuildContext context) async {
  await showDialog(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      title: Text('Horários de funcionamento',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 38.ssp,
          )),
      content: Text(_retrieveSellerShift(seller),
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 32.nsp,
          )),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(
            'Fechar',
            style: GoogleFonts.montserrat(
              decoration: TextDecoration.underline,
              color: Colors.white,
              fontSize: 34.nsp,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
      backgroundColor: Color(0xFFF9B152),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 0.1.wp),
    ),
  );
}

void _showPaymentsDialog(Seller seller, BuildContext context) async {
  await showDialog(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      title: Text(
        'Formas de pagamento',
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 38.ssp,
        ),
      ),
      content: Text(seller.paymentMethods,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 32.nsp,
          )),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(
            'Fechar',
            style: GoogleFonts.montserrat(
              decoration: TextDecoration.underline,
              color: Colors.white,
              fontSize: 34.nsp,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
      backgroundColor: Color(0xFFF9B152),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 0.1.wp),
    ),
  );
}

String _formatOpeningAndClosingTime(String openingTime, String closingTime) {
  String openingTimePadded = openingTime.padLeft(4, '0');
  String closingTimePadded = closingTime.padLeft(4, '0');
  String openingTimeFormatted =
      '${openingTimePadded.substring(0, 2)}:${openingTimePadded.substring(2, openingTimePadded.length)}';
  String closingTimeFormatted =
      '${closingTimePadded.substring(0, 2)}:${closingTimePadded.substring(2, closingTimePadded.length)}';
  return '$openingTimeFormatted - $closingTimeFormatted';
}

String _retrieveSellerShift(Seller seller) {
  String shift = '';
  if (seller.shift.monday.open) {
    shift =
        'Domingo: ${_formatOpeningAndClosingTime(seller.shift.monday.openingTime.toString(), seller.shift.monday.closingTime.toString())}';
  }
  if (seller.shift.sunday.open) {
    shift +=
        '\nSegunda: ${_formatOpeningAndClosingTime(seller.shift.sunday.openingTime.toString(), seller.shift.sunday.closingTime.toString())}';
  }
  if (seller.shift.tuesday.open) {
    shift +=
        '\nTerça: ${_formatOpeningAndClosingTime(seller.shift.tuesday.openingTime.toString(), seller.shift.tuesday.closingTime.toString())}';
  }
  if (seller.shift.wednesday.open) {
    shift +=
        '\nQuarta: ${_formatOpeningAndClosingTime(seller.shift.wednesday.openingTime.toString(), seller.shift.wednesday.closingTime.toString())}';
  }
  if (seller.shift.thursday.open) {
    shift +=
        '\nQuinta: ${_formatOpeningAndClosingTime(seller.shift.thursday.openingTime.toString(), seller.shift.thursday.closingTime.toString())}';
  }
  if (seller.shift.friday.open) {
    shift +=
        '\nSexta: ${_formatOpeningAndClosingTime(seller.shift.friday.openingTime.toString(), seller.shift.friday.closingTime.toString())}';
  }
  if (seller.shift.saturday.open) {
    shift +=
        '\nSábado: ${_formatOpeningAndClosingTime(seller.shift.saturday.openingTime.toString(), seller.shift.saturday.closingTime.toString())}';
  }
  return shift;
}

class _SellerProfileState extends State<SellerProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            widget.sellerName,
            maxLines: 1,
            style: GoogleFonts.montserrat(
              color: Theme.of(context).accentColor,
              fontSize: 38.nsp,
            ),
          ),
          actions: [_buildFavoriteButton()],
        ),
        body: SingleChildScrollView(
          child: StreamBuilder(
            stream: Repository.instance.getSeller(widget.sellerId),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 0.5.hp,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Container(
                  height: 0.6.hp - 56,
                  alignment: Alignment.center,
                  child: AutoSizeText(
                    snapshot.error.toString(),
                    style: GoogleFonts.montserrat(
                        fontSize: 45.nsp, color: Theme.of(context).accentColor),
                  ),
                );
              }

              Seller seller = snapshot.data.data();
              var currentMeals = seller.currentMeals;
              List<MealRequest> allCurrentMeals =
                  currentMeals.entries.map((meal) {
                return MealRequest(mealId: meal.key, seller: seller);
              }).toList();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    flex: 0,
                    child: UserPicture(seller.logo),
                  ),
                  if (seller.description != null)
                    Flexible(
                      flex: 0,
                      child: Container(
                        margin: EdgeInsets.only(top: 8),
                        constraints: BoxConstraints(maxWidth: 0.7.wp),
                        child: AutoSizeText(
                          seller.description,
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(fontSize: 30.nsp),
                        ),
                      ),
                    ),
                  if (seller.paymentMethods != null)
                    Flexible(
                      flex: 0,
                      child: GestureDetector(
                        onTap: () => _showPaymentsDialog(
                          seller,
                          context,
                        ),
                        child: Container(
                            margin: EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Formas de pagamento',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 30.nsp,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 3),
                                  child: FaIcon(
                                    FontAwesomeIcons.moneyBillAlt,
                                    size: 30.nsp,
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ),
                  if (seller.shift != null)
                    Flexible(
                      flex: 0,
                      child: GestureDetector(
                        onTap: () => _showShiftDialog(
                          seller,
                          context,
                        ),
                        child: Container(
                          margin: EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Horário de funcionamento',
                                style: GoogleFonts.montserrat(
                                  fontSize: 30.nsp,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 3),
                                child: FaIcon(
                                  FontAwesomeIcons.clock,
                                  size: 30.nsp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (seller.contact != null && seller.contact.phone != null)
                    Flexible(
                      flex: 0,
                      child: Container(
                        margin: EdgeInsets.only(top: 8),
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: GestureDetector(
                                onTap: () => {
                                  Clipboard.setData(
                                    ClipboardData(text: seller.contact.phone),
                                  ),
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor:
                                          Theme.of(context).accentColor,
                                      content: AutoSizeText(
                                        'Número copiado para área de transferência',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(),
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  )
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AutoSizeText(
                                      seller.contact.phone,
                                      maxLines: 1,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 30.nsp,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 3),
                                      child: Icon(Icons.phone, size: 32.nsp),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                try {
                                  final Uri whatsAppUrl = Uri(
                                    scheme: 'http',
                                    path:
                                        "wa.me/+55${seller.contact.phone.replaceAll('(', '').replaceAll(')', '')}",
                                  );
                                  launch(whatsAppUrl.toString());
                                } catch (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: Duration(seconds: 2),
                                      content: Text(
                                        'WhatsApp não instalado',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AutoSizeText(
                                    'Abrir no WhatsApp',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 30.nsp,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 3),
                                    child: FaIcon(
                                      FontAwesomeIcons.whatsapp,
                                      size: 36.nsp,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!seller.isOpen()) ...{
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20, right: 20, left: 20),
                        child: AutoSizeText(
                          'Esse vendedor está fechado no momento',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: Theme.of(context).errorColor,
                            fontSize: 35.nsp,
                          ),
                        ),
                      ),
                    )
                  },
                  Flexible(
                    flex: 0,
                    child: Container(
                      margin: EdgeInsets.only(top: 20, bottom: 10),
                      child: ListaHorizontal(
                          title:
                              'Quentinhas ${seller.isOpen() == true ? ' disponíveis' : ''}',
                          tagM: Random().nextDouble(),
                          meals: allCurrentMeals,
                          isFromSellerScreen: true,
                          controller: widget.controller),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: ToggleButtons(
                      isSelected: [true, true],
                      borderRadius: BorderRadius.circular(10),
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Chat',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 30.nsp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.map,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Localização',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 30.nsp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onPressed: (index) {
                        if (index == 0) {
                          pushNewScreen(
                            context,
                            screen: ChatScreen(
                              seller.id,
                              seller.name,
                              key: chatScreenKey,
                            ),
                          ); //a
                        }
                        if (index == 1) {
                          if (widget.fromMap)
                            Navigator.pop(context, seller);
                          else {
                            pushNewScreen(
                              context,
                              screen: SearchScreen(
                                widget.controller,
                                seller: seller,
                              ),
                              withNavBar: true,
                            );
                          }
                        }
                      },
                      color: Theme.of(context).accentColor,
                      fillColor: Theme.of(context).accentColor,
                    ),
                  ),
                ],
              );
            },
          ),
        ));
  }

  _buildFavoriteButton() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, AsyncSnapshot<User> authSnapshot) {
        if (!authSnapshot.hasData || authSnapshot.hasError) {
          return Padding(
            padding: EdgeInsets.only(
              right: 20,
            ),
            child: Icon(
              Icons.star_border,
              size: 48.nsp,
            ),
          );
        }

        return StreamBuilder(
            stream: Repository.instance.getClientStream(authSnapshot.data.uid),
            builder: (context, AsyncSnapshot<DocumentSnapshot> clientSnapshot) {
              if (!clientSnapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: 20,
                  ),
                  child: Icon(
                    Icons.star_border,
                    size: 48.nsp,
                  ),
                );
              }

              if (clientSnapshot.hasError) {
                return SizedBox();
              }
              var isFavorite = false;
              Client client = clientSnapshot.data.data();
              if (client.favoriteSellers != null) {
                isFavorite = client.favoriteSellers.contains(widget.sellerId);
              }
              return Padding(
                padding: EdgeInsets.only(
                  right: 20,
                ),
                child: GestureDetector(
                  onTap: () async {
                    if (isFavorite) {
                      Repository.instance.removeSellerFromClientFavorites(
                          clientSnapshot.data.id, widget.sellerId);
                    } else {
                      Repository.instance.addSellerToClientFavorites(
                          clientSnapshot.data.id, widget.sellerId);
                    }
                  },
                  child: Icon(
                    isFavorite == true ? Icons.star : Icons.star_border,
                    size: 48.nsp,
                  ),
                ),
              );
            });
      },
    );
  }
}
