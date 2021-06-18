import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/dadosMarretados.dart';
import 'package:rango/models/client.dart';
import 'package:rango/screens/main/home/ChatScreen.dart';

class ClientProfile extends StatefulWidget {
  final Client client;

  ClientProfile(this.client);

  @override
  _ClientProfileState createState() => _ClientProfileState();
}

class _ClientProfileState extends State<ClientProfile> {
  bool isFavorite = false;
  bool loading = true;
  Client client;

  @override
  void initState() {
    setState(() {
      client =
          clients.firstWhere((element) => element.name == widget.client.name);
      loading = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final yellow = Color(0xFFF9B152);
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
      body: loading
          ? CircularProgressIndicator()
          : Center(
              child: Column(
                children: [
                  Container(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 40, bottom: 40),
                          height: 140,
                          width: 140,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(ScreenUtil().setSp(30)),
                            color: yellow,
                          ),
                        ),
                        if (client.picture != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(120),
                            child: Container(
                              width: 160,
                              height: 160,
                              color: Theme.of(context).accentColor,
                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/imgs/user_placeholder.png',
                                image: client.picture,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        if (client.picture == null)
                          FittedBox(
                            fit: BoxFit.cover,
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).accentColor,
                              backgroundImage: AssetImage(
                                  'assets/imgs/user_placeholder.png'),
                              radius: 120.w,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  if (client.phone != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, size: 38.nsp),
                        GestureDetector(
                          //TODO clicar e copiar para área de transferência
                          onTap: () => {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('teste'),
                                duration: const Duration(seconds: 1),
                              ),
                            )
                          },
                          child: Container(
                            child: AutoSizeText(
                              client.phone,
                              maxLines: 1,
                              style: GoogleFonts.montserrat(
                                fontSize: 32.nsp,
                              ),
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
                      '${client.name} comprou X vezes com você, gastando um total de R\$YY,YY',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(fontSize: 32.nsp),
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
            ),
    );
  }
}
