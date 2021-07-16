import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/client.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/main/home/ChatScreen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rango/widgets/user/UserPicture.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientProfile extends StatefulWidget {
  final String clientId;

  ClientProfile(this.clientId);

  @override
  _ClientProfileState createState() => _ClientProfileState();
}

class _ClientProfileState extends State<ClientProfile> {
  bool isFavorite = false;
  bool loading = true;
  Client client;

  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Repository.instance.getClientStream(widget.clientId),
        builder: (context, AsyncSnapshot<DocumentSnapshot<Client>> snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
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

          Client client = snapshot.data.data();

          return Scaffold(
              appBar: AppBar(
                title: AutoSizeText(
                  client.name,
                  maxLines: 1,
                  style: GoogleFonts.montserrat(
                    color: Theme.of(context).accentColor,
                    fontSize: 35.nsp,
                  ),
                ),
              ),
              body: Center(
                child: Column(
                  children: [
                    UserPicture(picture: client.picture),
                    SizedBox(height: 10),
                    if (client.phone != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone,
                            size: 38.nsp,
                          ),
                          GestureDetector(
                            onTap: () => {
                              Clipboard.setData(
                                ClipboardData(text: client.phone),
                              ),
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: AutoSizeText(
                                    'Número copiado para área de transferência',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(),
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              )
                            },
                            child: Container(
                              child: AutoSizeText(
                                client.phone,
                                maxLines: 1,
                                style: GoogleFonts.montserrat(
                                  fontSize: 38.nsp,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 4,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                try {
                                  final Uri teste = Uri(
                                    scheme: 'http',
                                    path:
                                        "wa.me/+55${client.phone.replaceAll('(', '').replaceAll(')', '')}",
                                  );
                                  launch(teste.toString());
                                } catch (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: Duration(seconds: 2),
                                      backgroundColor:
                                          Theme.of(context).errorColor,
                                      content: Text(
                                        'WhatsApp não instalado!',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: FaIcon(
                                FontAwesomeIcons.whatsapp,
                                color: Colors.green,
                                size: 42.nsp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 0.2.wp,
                        vertical: 0.01.hp,
                      ),
                      child: AutoSizeText(
                        //TODO GetClientOrders e calcular isso
                        '${client.name} comprou X vezes com você, gastando um total de R\$YY,YY',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 35.nsp,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.chat, size: 38.nsp),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () => pushNewScreen(
                        context,
                        screen: ChatScreen(client),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      ),
                      label: Container(
                        width: 0.5.wp,
                        child: AutoSizeText(
                          'Chat com o cliente',
                          maxLines: 1,
                          style: GoogleFonts.montserrat(fontSize: 36.nsp),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        });
  }
}
