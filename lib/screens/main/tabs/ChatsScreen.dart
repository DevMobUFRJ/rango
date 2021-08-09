import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/chat.dart';
import 'package:rango/models/seller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/main/home/ChatScreen.dart';

class ChatsScreen extends StatefulWidget {
  final Seller usuario;

  ChatsScreen(this.usuario);

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          "Conversas recentes",
          maxLines: 1,
          style: GoogleFonts.montserrat(color: Theme.of(context).accentColor),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        height: 1.hp - 56,
        margin: EdgeInsets.symmetric(horizontal: 7),
        child: PaginateFirestore(
          query: Repository.instance.chatsRef
              .where('sellerId', isEqualTo: widget.usuario.id)
              .orderBy('lastMessageSentAt', descending: true),
          isLive: true,
          itemsPerPage: 10,
          initialLoader: Center(
            child: Container(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
          emptyDisplay: Center(
            child: AutoSizeText(
              'Você ainda não possui conversas com clientes!',
              style: GoogleFonts.montserrat(
                fontSize: 50.nsp,
                color: Theme.of(context).accentColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          itemBuilderType: PaginateBuilderType.listView,
          itemBuilder: (index, ctx, snapshot) {
            final Chat chat = snapshot.data();
            return GestureDetector(
              onTap: () => pushNewScreen(
                ctx,
                withNavBar: false,
                screen: ChatScreen(
                  chat.clientId,
                  chat.clientName,
                ),
              ),
              child: Card(
                elevation: 3,
                color: Color(0xFFF9B152),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chat.clientName,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Última mensagem:',
                              style:
                                  GoogleFonts.montserrat(color: Colors.white),
                            ),
                            Text(
                              chat.lastMessageSent,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  GoogleFonts.montserrat(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            AutoSizeText(
                              'Enviada às',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                              ),
                            ),
                            AutoSizeText(
                              '${DateFormat("HH:mm").format(chat.lastMessageSentAt.toDate())}',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
